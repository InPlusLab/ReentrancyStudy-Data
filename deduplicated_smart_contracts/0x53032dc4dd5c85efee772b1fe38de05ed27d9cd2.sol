// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

import { IVault } from "./Vaults/IVault.sol";
import { IFujiAdmin } from "./IFujiAdmin.sol";
import { IFujiERC1155 } from "./FujiERC1155/IFujiERC1155.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Flasher } from "./Flashloans/Flasher.sol";
import { FlashLoan } from "./Flashloans/LibFlashLoan.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Errors } from "./Libraries/Errors.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { LibUniversalERC20 } from "./Libraries/LibUniversalERC20.sol";
import {
  IUniswapV2Router02
} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IVaultExt is IVault {
  //Asset Struct
  struct VaultAssets {
    address collateralAsset;
    address borrowAsset;
    uint64 collateralID;
    uint64 borrowID;
  }

  function vAssets() external view returns (VaultAssets memory);
}

interface IFujiERC1155Ext is IFujiERC1155 {
  function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
    external
    view
    returns (uint256[] memory);
}

contract Fliquidator is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using LibUniversalERC20 for IERC20;

  struct Factor {
    uint64 a;
    uint64 b;
  }

  // Flash Close Fee Factor
  Factor public flashCloseF;

  IFujiAdmin private _fujiAdmin;
  IUniswapV2Router02 public swapper;

  // Log Liquidation
  event Liquidate(
    address indexed userAddr,
    address liquidator,
    address indexed asset,
    uint256 amount
  );
  // Log FlashClose
  event FlashClose(address indexed userAddr, address indexed asset, uint256 amount);
  // Log Liquidation
  event FlashLiquidate(address userAddr, address liquidator, address indexed asset, uint256 amount);

  modifier isAuthorized() {
    require(msg.sender == owner(), Errors.VL_NOT_AUTHORIZED);
    _;
  }

  modifier onlyFlash() {
    require(msg.sender == _fujiAdmin.getFlasher(), Errors.VL_NOT_AUTHORIZED);
    _;
  }

  modifier isValidVault(address _vaultAddr) {
    require(_fujiAdmin.validVault(_vaultAddr), "Invalid vault!");
    _;
  }

  constructor() public {
    // 1.013
    flashCloseF.a = 1013;
    flashCloseF.b = 1000;
  }

  receive() external payable {}

  // FLiquidator Core Functions

  /**
   * @dev Liquidate an undercollaterized debt and get bonus (bonusL in Vault)
   * @param _userAddrs: Address array of users whose position is liquidatable
   * @param _vault: Address of the vault in where liquidation will occur
   */
  function batchLiquidate(address[] calldata _userAddrs, address _vault)
    external
    nonReentrant
    isValidVault(_vault)
  {
    // Update Balances at FujiERC1155
    IVault(_vault).updateF1155Balances();

    // Create Instance of FujiERC1155
    IFujiERC1155Ext f1155 = IFujiERC1155Ext(IVault(_vault).fujiERC1155());

    // Struct Instance to get Vault Asset IDs in f1155
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

    address[] memory formattedUserAddrs = new address[](2 * _userAddrs.length);
    uint256[] memory formattedIds = new uint256[](2 * _userAddrs.length);

    // Build the required Arrays to query balanceOfBatch from f1155
    for (uint256 i = 0; i < _userAddrs.length; i++) {
      formattedUserAddrs[2 * i] = _userAddrs[i];
      formattedUserAddrs[2 * i + 1] = _userAddrs[i];
      formattedIds[2 * i] = vAssets.collateralID;
      formattedIds[2 * i + 1] = vAssets.borrowID;
    }

    // Get user Collateral and Debt Balances
    uint256[] memory usrsBals = f1155.balanceOfBatch(formattedUserAddrs, formattedIds);

    uint256 neededCollateral;
    uint256 debtBalanceTotal;

    for (uint256 i = 0; i < formattedUserAddrs.length; i += 2) {
      // Compute Amount of Minimum Collateral Required including factors
      neededCollateral = IVault(_vault).getNeededCollateralFor(usrsBals[i + 1], true);

      // Check if User is liquidatable
      if (usrsBals[i] < neededCollateral) {
        // If true, add User debt balance to the total balance to be liquidated
        debtBalanceTotal = debtBalanceTotal.add(usrsBals[i + 1]);
      } else {
        // Replace User that is not liquidatable by Zero Address
        formattedUserAddrs[i] = address(0);
        formattedUserAddrs[i + 1] = address(0);
      }
    }

    // Check there is at least one user liquidatable
    require(debtBalanceTotal > 0, Errors.VL_USER_NOT_LIQUIDATABLE);

    // Check Liquidator Allowance
    require(
      IERC20(vAssets.borrowAsset).allowance(msg.sender, address(this)) >= debtBalanceTotal,
      Errors.VL_MISSING_ERC20_ALLOWANCE
    );

    // Transfer borrowAsset funds from the Liquidator to Here
    IERC20(vAssets.borrowAsset).transferFrom(msg.sender, address(this), debtBalanceTotal);

    // Transfer Amount to Vault
    IERC20(vAssets.borrowAsset).univTransfer(payable(_vault), debtBalanceTotal);

    // TODO: Get => corresponding amount of BaseProtocol Debt and FujiDebt

    // Repay BaseProtocol debt
    IVault(_vault).payback(int256(debtBalanceTotal));

    //TODO: Transfer corresponding Debt Amount to Fuji Treasury

    // Compute the Liquidator Bonus bonusL
    uint256 globalBonus = IVault(_vault).getLiquidationBonusFor(debtBalanceTotal, false);
    // Compute how much collateral needs to be swapt
    uint256 globalCollateralInPlay =
      _getCollateralInPlay(vAssets.borrowAsset, debtBalanceTotal.add(globalBonus));

    // Burn Collateral f1155 tokens for each liquidated user
    _burnMultiLoop(formattedUserAddrs, usrsBals, IVault(_vault), f1155, vAssets);

    // Withdraw collateral
    IVault(_vault).withdraw(int256(globalCollateralInPlay));

    // Swap Collateral
    _swap(vAssets.borrowAsset, debtBalanceTotal.add(globalBonus), globalCollateralInPlay);

    // Transfer to Liquidator the debtBalance + bonus
    IERC20(vAssets.borrowAsset).univTransfer(msg.sender, debtBalanceTotal.add(globalBonus));

    // Burn Debt f1155 tokens and Emit Liquidation Event for Each Liquidated User
    for (uint256 i = 0; i < formattedUserAddrs.length; i += 2) {
      if (formattedUserAddrs[i] != address(0)) {
        f1155.burn(formattedUserAddrs[i], vAssets.borrowID, usrsBals[i + 1]);
        emit Liquidate(formattedUserAddrs[i], msg.sender, vAssets.borrowAsset, usrsBals[i + 1]);
      }
    }
  }

  /**
   * @dev Initiates a flashloan used to repay partially or fully the debt position of msg.sender
   * @param _amount: Pass -1 to fully close debt position, otherwise Amount to be repaid with a flashloan
   * @param _vault: The vault address where the debt position exist.
   * @param _flashnum: integer identifier of flashloan provider
   */
  function flashClose(
    int256 _amount,
    address _vault,
    uint8 _flashnum
  ) external nonReentrant isValidVault(_vault) {
    Flasher flasher = Flasher(payable(_fujiAdmin.getFlasher()));

    // Update Balances at FujiERC1155
    IVault(_vault).updateF1155Balances();

    // Create Instance of FujiERC1155
    IFujiERC1155Ext f1155 = IFujiERC1155Ext(IVault(_vault).fujiERC1155());

    // Struct Instance to get Vault Asset IDs in f1155
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

    // Get user  Balances
    uint256 userCollateral = f1155.balanceOf(msg.sender, vAssets.collateralID);
    uint256 userDebtBalance = f1155.balanceOf(msg.sender, vAssets.borrowID);

    // Check Debt is > zero
    require(userDebtBalance > 0, Errors.VL_NO_DEBT_TO_PAYBACK);

    uint256 amount = _amount < 0 ? userDebtBalance : uint256(_amount);

    uint256 neededCollateral = IVault(_vault).getNeededCollateralFor(amount, false);
    require(userCollateral >= neededCollateral, Errors.VL_UNDERCOLLATERIZED_ERROR);

    address[] memory userAddressArray = new address[](1);
    userAddressArray[0] = msg.sender;

    FlashLoan.Info memory info =
      FlashLoan.Info({
        callType: FlashLoan.CallType.Close,
        asset: vAssets.borrowAsset,
        amount: amount,
        vault: _vault,
        newProvider: address(0),
        userAddrs: userAddressArray,
        userBalances: new uint256[](0),
        userliquidator: address(0),
        fliquidator: address(this)
      });

    flasher.initiateFlashloan(info, _flashnum);
  }

  /**
   * @dev Close user's debt position by using a flashloan
   * @param _userAddr: user addr to be liquidated
   * @param _vault: Vault address
   * @param _amount: amount received by Flashloan
   * @param _flashloanFee: amount extra charged by flashloan provider
   * Emits a {FlashClose} event.
   */
  function executeFlashClose(
    address payable _userAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanFee
  ) external onlyFlash {
    // Create Instance of FujiERC1155
    IFujiERC1155 f1155 = IFujiERC1155(IVault(_vault).fujiERC1155());

    // Struct Instance to get Vault Asset IDs in f1155
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

    // Get user Collateral and Debt Balances
    uint256 userCollateral = f1155.balanceOf(_userAddr, vAssets.collateralID);
    uint256 userDebtBalance = f1155.balanceOf(_userAddr, vAssets.borrowID);

    // Get user Collateral + Flash Close Fee to close posisition, for _amount passed
    uint256 userCollateralInPlay =
      IVault(_vault)
        .getNeededCollateralFor(_amount.add(_flashloanFee), false)
        .mul(flashCloseF.a)
        .div(flashCloseF.b);

    // TODO: Get => corresponding amount of BaseProtocol Debt and FujiDebt

    // Repay BaseProtocol debt
    IVault(_vault).payback(int256(_amount));

    //TODO: Transfer corresponding Debt Amount to Fuji Treasury

    // Full close
    if (_amount == userDebtBalance) {
      f1155.burn(_userAddr, vAssets.collateralID, userCollateral);

      // Withdraw Full collateral
      IVault(_vault).withdraw(int256(userCollateral));

      // Send unUsed Collateral to User
      IERC20(vAssets.collateralAsset).univTransfer(
        _userAddr,
        userCollateral.sub(userCollateralInPlay)
      );
    } else {
      f1155.burn(_userAddr, vAssets.collateralID, userCollateralInPlay);

      // Withdraw Collateral in play Only
      IVault(_vault).withdraw(int256(userCollateralInPlay));
    }

    // Swap Collateral for underlying to repay Flashloan
    uint256 remaining =
      _swap(vAssets.borrowAsset, _amount.add(_flashloanFee), userCollateralInPlay);

    // Send FlashClose Fee to FujiTreasury
    IERC20(vAssets.collateralAsset).univTransfer(_fujiAdmin.getTreasury(), remaining);

    // Send flasher the underlying to repay Flashloan
    IERC20(vAssets.borrowAsset).univTransfer(
      payable(_fujiAdmin.getFlasher()),
      _amount.add(_flashloanFee)
    );

    // Burn Debt f1155 tokens
    f1155.burn(_userAddr, vAssets.borrowID, _amount);

    emit FlashClose(_userAddr, vAssets.borrowAsset, userDebtBalance);
  }

  /**
   * @dev Initiates a flashloan to liquidate array of undercollaterized debt positions,
   * gets bonus (bonusFlashL in Vault)
   * @param _userAddrs: Array of Address whose position is liquidatable
   * @param _vault: The vault address where the debt position exist.
   * @param _flashnum: integer identifier of flashloan provider
   */
  function flashBatchLiquidate(
    address[] calldata _userAddrs,
    address _vault,
    uint8 _flashnum
  ) external isValidVault(_vault) nonReentrant {
    // Update Balances at FujiERC1155
    IVault(_vault).updateF1155Balances();

    // Create Instance of FujiERC1155
    IFujiERC1155Ext f1155 = IFujiERC1155Ext(IVault(_vault).fujiERC1155());

    // Struct Instance to get Vault Asset IDs in f1155
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

    address[] memory formattedUserAddrs = new address[](2 * _userAddrs.length);
    uint256[] memory formattedIds = new uint256[](2 * _userAddrs.length);

    // Build the required Arrays to query balanceOfBatch from f1155
    for (uint256 i = 0; i < _userAddrs.length; i++) {
      formattedUserAddrs[2 * i] = _userAddrs[i];
      formattedUserAddrs[2 * i + 1] = _userAddrs[i];
      formattedIds[2 * i] = vAssets.collateralID;
      formattedIds[2 * i + 1] = vAssets.borrowID;
    }

    // Get user Collateral and Debt Balances
    uint256[] memory usrsBals = f1155.balanceOfBatch(formattedUserAddrs, formattedIds);

    uint256 neededCollateral;
    uint256 debtBalanceTotal;

    for (uint256 i = 0; i < formattedUserAddrs.length; i += 2) {
      // Compute Amount of Minimum Collateral Required including factors
      neededCollateral = IVault(_vault).getNeededCollateralFor(usrsBals[i + 1], true);

      // Check if User is liquidatable
      if (usrsBals[i] < neededCollateral) {
        // If true, add User debt balance to the total balance to be liquidated
        debtBalanceTotal = debtBalanceTotal.add(usrsBals[i + 1]);
      } else {
        // Replace User that is not liquidatable by Zero Address
        formattedUserAddrs[i] = address(0);
        formattedUserAddrs[i + 1] = address(0);
      }
    }

    // Check there is at least one user liquidatable
    require(debtBalanceTotal > 0, Errors.VL_USER_NOT_LIQUIDATABLE);

    Flasher flasher = Flasher(payable(_fujiAdmin.getFlasher()));

    FlashLoan.Info memory info =
      FlashLoan.Info({
        callType: FlashLoan.CallType.BatchLiquidate,
        asset: vAssets.borrowAsset,
        amount: debtBalanceTotal,
        vault: _vault,
        newProvider: address(0),
        userAddrs: formattedUserAddrs,
        userBalances: usrsBals,
        userliquidator: msg.sender,
        fliquidator: address(this)
      });

    flasher.initiateFlashloan(info, _flashnum);
  }

  /**
   * @dev Liquidate a debt position by using a flashloan
   * @param _userAddrs: array **See formattedUserAddrs construction in 'function flashBatchLiquidate'
   * @param _usrsBals: array **See construction in 'function flashBatchLiquidate'
   * @param _liquidatorAddr: liquidator address
   * @param _vault: Vault address
   * @param _amount: amount of debt to be repaid
   * @param _flashloanFee: amount extra charged by flashloan provider
   * Emits a {FlashLiquidate} event.
   */
  function executeFlashBatchLiquidation(
    address[] calldata _userAddrs,
    uint256[] calldata _usrsBals,
    address _liquidatorAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanFee
  ) external onlyFlash {
    // Create Instance of FujiERC1155
    IFujiERC1155 f1155 = IFujiERC1155(IVault(_vault).fujiERC1155());

    // Struct Instance to get Vault Asset IDs in f1155
    IVaultExt.VaultAssets memory vAssets = IVaultExt(_vault).vAssets();

    // TODO: Get => corresponding amount of BaseProtocol Debt and FujiDebt
    // TODO: Transfer corresponding Debt Amount to Fuji Treasury

    // Repay BaseProtocol debt to release collateral
    IVault(_vault).payback(int256(_amount));

    // Compute the Liquidator Bonus bonusFlashL
    uint256 globalBonus = IVault(_vault).getLiquidationBonusFor(_amount, true);

    // Compute how much collateral needs to be swapt for all liquidated Users
    uint256 globalCollateralInPlay =
      _getCollateralInPlay(vAssets.borrowAsset, _amount.add(_flashloanFee).add(globalBonus));

    // Burn Collateral f1155 tokens for each liquidated user
    _burnMultiLoop(_userAddrs, _usrsBals, IVault(_vault), f1155, vAssets);

    // Withdraw collateral
    IVault(_vault).withdraw(int256(globalCollateralInPlay));

    _swap(vAssets.borrowAsset, _amount.add(_flashloanFee).add(globalBonus), globalCollateralInPlay);

    // Send flasher the underlying to repay Flashloan
    IERC20(vAssets.borrowAsset).univTransfer(
      payable(_fujiAdmin.getFlasher()),
      _amount.add(_flashloanFee)
    );

    // Transfer Bonus bonusFlashL to liquidator, minus FlashloanFee convenience
    IERC20(vAssets.borrowAsset).univTransfer(
      payable(_liquidatorAddr),
      globalBonus.sub(_flashloanFee)
    );

    // Burn Debt f1155 tokens and Emit Liquidation Event for Each Liquidated User
    for (uint256 i = 0; i < _userAddrs.length; i += 2) {
      if (_userAddrs[i] != address(0)) {
        f1155.burn(_userAddrs[i], vAssets.borrowID, _usrsBals[i + 1]);
        emit FlashLiquidate(_userAddrs[i], _liquidatorAddr, vAssets.borrowAsset, _usrsBals[i + 1]);
      }
    }
  }

  /**
   * @dev Swap an amount of underlying
   * @param _borrowAsset: Address of vault borrowAsset
   * @param _amountToReceive: amount of underlying to receive
   * @param _collateralAmount: collateral Amount sent for swap
   */
  function _swap(
    address _borrowAsset,
    uint256 _amountToReceive,
    uint256 _collateralAmount
  ) internal returns (uint256) {
    // Swap Collateral Asset to Borrow Asset
    address[] memory path = new address[](2);
    path[0] = swapper.WETH();
    path[1] = _borrowAsset;
    uint256[] memory swapperAmounts =
      swapper.swapETHForExactTokens{ value: _collateralAmount }(
        _amountToReceive,
        path,
        address(this),
        // solhint-disable-next-line
        block.timestamp
      );

    return _collateralAmount.sub(swapperAmounts[0]);
  }

  /**
   * @dev Get exact amount of collateral to be swapt
   * @param _borrowAsset: Address of vault borrowAsset
   * @param _amountToReceive: amount of underlying to receive
   */
  function _getCollateralInPlay(address _borrowAsset, uint256 _amountToReceive)
    internal
    view
    returns (uint256)
  {
    address[] memory path = new address[](2);
    path[0] = swapper.WETH();
    path[1] = _borrowAsset;
    uint256[] memory amounts = swapper.getAmountsIn(_amountToReceive, path);

    return amounts[0];
  }

  /**
   * @dev Abstracted function to perform MultBatch Burn of Collateral in Batch Liquidation
   * checking bonus paid to liquidator by each
   * See "function executeFlashBatchLiquidation"
   */
  function _burnMultiLoop(
    address[] memory _userAddrs,
    uint256[] memory _usrsBals,
    IVault _vault,
    IFujiERC1155 _f1155,
    IVaultExt.VaultAssets memory _vAssets
  ) internal {
    uint256 bonusPerUser;
    uint256 collateralInPlayPerUser;

    for (uint256 i = 0; i < _userAddrs.length; i += 2) {
      if (_userAddrs[i] != address(0)) {
        bonusPerUser = _vault.getLiquidationBonusFor(_usrsBals[i + 1], true);

        collateralInPlayPerUser = _getCollateralInPlay(
          _vAssets.borrowAsset,
          _usrsBals[i + 1].add(bonusPerUser)
        );

        _f1155.burn(_userAddrs[i], _vAssets.collateralID, collateralInPlayPerUser);
      }
    }
  }

  // Administrative functions

  /**
   * @dev Set Factors "a" and "b" for a Struct Factor flashcloseF
   * For flashCloseF;  should be > 1, a/b
   * @param _newFactorA: A number
   * @param _newFactorB: A number
   */
  function setFlashCloseFee(uint64 _newFactorA, uint64 _newFactorB) external isAuthorized {
    flashCloseF.a = _newFactorA;
    flashCloseF.b = _newFactorB;
  }

  /**
   * @dev Sets the fujiAdmin Address
   * @param _newFujiAdmin: FujiAdmin Contract Address
   */
  function setFujiAdmin(address _newFujiAdmin) external isAuthorized {
    _fujiAdmin = IFujiAdmin(_newFujiAdmin);
  }

  /**
   * @dev Changes the Swapper contract address
   * @param _newSwapper: address of new swapper contract
   */
  function setSwapper(address _newSwapper) external isAuthorized {
    swapper = IUniswapV2Router02(_newSwapper);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface IVault {
  // Events

  // Log Users Deposit
  event Deposit(address indexed userAddrs, address indexed asset, uint256 amount);
  // Log Users withdraw
  event Withdraw(address indexed userAddrs, address indexed asset, uint256 amount);
  // Log Users borrow
  event Borrow(address indexed userAddrs, address indexed asset, uint256 amount);
  // Log Users debt repay
  event Payback(address indexed userAddrs, address indexed asset, uint256 amount);

  // Log New active provider
  event SetActiveProvider(address providerAddr);
  // Log Switch providers
  event Switch(
    address vault,
    address fromProviderAddrs,
    address toProviderAddr,
    uint256 debtamount,
    uint256 collattamount
  );

  // Core Vault Functions

  function deposit(uint256 _collateralAmount) external payable;

  function withdraw(int256 _withdrawAmount) external;

  function borrow(uint256 _borrowAmount) external;

  function payback(int256 _repayAmount) external payable;

  function executeSwitch(
    address _newProvider,
    uint256 _flashLoanDebt,
    uint256 _fee
  ) external;

  //Getter Functions

  function activeProvider() external view returns (address);

  function borrowBalance(address _provider) external view returns (uint256);

  function depositBalance(address _provider) external view returns (uint256);

  function getNeededCollateralFor(uint256 _amount, bool _withFactors)
    external
    view
    returns (uint256);

  function getLiquidationBonusFor(uint256 _amount, bool _flash) external view returns (uint256);

  function getProviders() external view returns (address[] memory);

  function fujiERC1155() external view returns (address);

  //Setter Functions

  function setActiveProvider(address _provider) external;

  function updateF1155Balances() external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12 <0.8.0;

interface IFujiAdmin {
  function validVault(address _vaultAddr) external view returns (bool);

  function getFlasher() external view returns (address);

  function getFliquidator() external view returns (address);

  function getController() external view returns (address);

  function getTreasury() external view returns (address payable);

  function getaWhiteList() external view returns (address);

  function getVaultHarvester() external view returns (address);

  function getBonusFlashL() external view returns (uint64, uint64);

  function getBonusLiq() external view returns (uint64, uint64);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;

interface IFujiERC1155 {
  //Asset Types
  enum AssetType {
    //uint8 = 0
    collateralToken,
    //uint8 = 1
    debtToken
  }

  //General Getter Functions

  function getAssetID(AssetType _type, address _assetAddr) external view returns (uint256);

  function qtyOfManagedAssets() external view returns (uint64);

  function balanceOf(address _account, uint256 _id) external view returns (uint256);

  //function splitBalanceOf(address account,uint256 _AssetID) external view  returns (uint256,uint256);

  //function balanceOfBatchType(address account, AssetType _Type) external view returns (uint256);

  //Permit Controlled  Functions
  function mint(
    address _account,
    uint256 _id,
    uint256 _amount,
    bytes memory _data
  ) external;

  function burn(
    address _account,
    uint256 _id,
    uint256 _amount
  ) external;

  function updateState(uint256 _assetID, uint256 _newBalance) external;

  function addInitializeAsset(AssetType _type, address _addr) external returns (uint64);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12 <0.8.0;
pragma experimental ABIEncoderV2;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { UniERC20 } from "../Libraries/LibUniERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IFujiAdmin } from "../IFujiAdmin.sol";
import { Errors } from "../Libraries/Errors.sol";

import { ILendingPool, IFlashLoanReceiver } from "./AaveFlashLoans.sol";
import { Actions, Account, DyDxFlashloanBase, ICallee, ISoloMargin } from "./DyDxFlashLoans.sol";
import { ICTokenFlashloan, ICFlashloanReceiver } from "./CreamFlashLoans.sol";
import { FlashLoan } from "./LibFlashLoan.sol";
import { IVault } from "../Vaults/IVault.sol";

interface IFliquidator {
  function executeFlashClose(
    address _userAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanfee
  ) external;

  function executeFlashBatchLiquidation(
    address[] calldata _userAddrs,
    uint256[] calldata _usrsBals,
    address _liquidatorAddr,
    address _vault,
    uint256 _amount,
    uint256 _flashloanFee
  ) external;
}

interface IFujiMappings {
  function addressMapping(address) external view returns (address);
}

contract Flasher is DyDxFlashloanBase, IFlashLoanReceiver, ICFlashloanReceiver, ICallee, Ownable {
  using SafeMath for uint256;
  using UniERC20 for IERC20;

  IFujiAdmin private _fujiAdmin;

  address private immutable _aaveLendingPool = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
  address private immutable _dydxSoloMargin = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
  IFujiMappings private immutable _crMappings =
    IFujiMappings(0x03BD587Fe413D59A20F32Fc75f31bDE1dD1CD6c9);

  receive() external payable {}

  modifier isAuthorized() {
    require(
      msg.sender == _fujiAdmin.getController() ||
        msg.sender == _fujiAdmin.getFliquidator() ||
        msg.sender == owner(),
      Errors.VL_NOT_AUTHORIZED
    );
    _;
  }

  /**
   * @dev Sets the fujiAdmin Address
   * @param _newFujiAdmin: FujiAdmin Contract Address
   */
  function setFujiAdmin(address _newFujiAdmin) public onlyOwner {
    _fujiAdmin = IFujiAdmin(_newFujiAdmin);
  }

  /**
   * @dev Routing Function for Flashloan Provider
   * @param info: struct information for flashLoan
   * @param _flashnum: integer identifier of flashloan provider
   */
  function initiateFlashloan(FlashLoan.Info calldata info, uint8 _flashnum) external isAuthorized {
    if (_flashnum == 0) {
      _initiateAaveFlashLoan(info);
    } else if (_flashnum == 1) {
      _initiateDyDxFlashLoan(info);
    } else if (_flashnum == 2) {
      _initiateCreamFlashLoan(info);
    }
  }

  // ===================== DyDx FlashLoan ===================================

  /**
   * @dev Initiates a DyDx flashloan.
   * @param info: data to be passed between functions executing flashloan logic
   */
  function _initiateDyDxFlashLoan(FlashLoan.Info calldata info) internal {
    ISoloMargin solo = ISoloMargin(_dydxSoloMargin);

    // Get marketId from token address
    uint256 marketId = _getMarketIdFromTokenAddress(solo, info.asset);

    // 1. Withdraw $
    // 2. Call callFunction(...)
    // 3. Deposit back $
    Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

    operations[0] = _getWithdrawAction(marketId, info.amount);
    // Encode FlashLoan.Info for callFunction
    operations[1] = _getCallAction(abi.encode(info));
    // add fee of 2 wei
    operations[2] = _getDepositAction(marketId, info.amount.add(2));

    Account.Info[] memory accountInfos = new Account.Info[](1);
    accountInfos[0] = _getAccountInfo(address(this));

    solo.operate(accountInfos, operations);
  }

  /**
   * @dev Executes DyDx Flashloan, this operation is required
   * and called by Solo when sending loaned amount
   * @param sender: Not used
   * @param account: Not used
   */
  function callFunction(
    address sender,
    Account.Info calldata account,
    bytes calldata data
  ) external override {
    require(msg.sender == _dydxSoloMargin && sender == address(this), Errors.VL_NOT_AUTHORIZED);
    account;

    FlashLoan.Info memory info = abi.decode(data, (FlashLoan.Info));

    //Estimate flashloan payback + premium fee of 2 wei,
    uint256 amountOwing = info.amount.add(2);

    // Transfer to Vault the flashloan Amount
    IERC20(info.asset).uniTransfer(payable(info.vault), info.amount);

    if (info.callType == FlashLoan.CallType.Switch) {
      IVault(info.vault).executeSwitch(info.newProvider, info.amount, 2);
    } else if (info.callType == FlashLoan.CallType.Close) {
      IFliquidator(info.fliquidator).executeFlashClose(
        info.userAddrs[0],
        info.vault,
        info.amount,
        2
      );
    } else {
      IFliquidator(info.fliquidator).executeFlashBatchLiquidation(
        info.userAddrs,
        info.userBalances,
        info.userliquidator,
        info.vault,
        info.amount,
        2
      );
    }

    //Approve DYDXSolo to spend to repay flashloan
    IERC20(info.asset).approve(_dydxSoloMargin, amountOwing);
  }

  // ===================== Aave FlashLoan ===================================

  /**
   * @dev Initiates an Aave flashloan.
   * @param info: data to be passed between functions executing flashloan logic
   */
  function _initiateAaveFlashLoan(FlashLoan.Info calldata info) internal {
    //Initialize Instance of Aave Lending Pool
    ILendingPool aaveLp = ILendingPool(_aaveLendingPool);

    //Passing arguments to construct Aave flashloan -limited to 1 asset type for now.
    address receiverAddress = address(this);
    address[] memory assets = new address[](1);
    assets[0] = address(info.asset);
    uint256[] memory amounts = new uint256[](1);
    amounts[0] = info.amount;

    // 0 = no debt, 1 = stable, 2 = variable
    uint256[] memory modes = new uint256[](1);
    //modes[0] = 0;

    //address onBehalfOf = address(this);
    //bytes memory params = abi.encode(info);
    //uint16 referralCode = 0;

    //Aave Flashloan initiated.
    aaveLp.flashLoan(receiverAddress, assets, amounts, modes, address(this), abi.encode(info), 0);
  }

  /**
   * @dev Executes Aave Flashloan, this operation is required
   * and called by Aaveflashloan when sending loaned amount
   */
  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external override returns (bool) {
    require(msg.sender == _aaveLendingPool && initiator == address(this), Errors.VL_NOT_AUTHORIZED);

    FlashLoan.Info memory info = abi.decode(params, (FlashLoan.Info));

    //Estimate flashloan payback + premium fee,
    uint256 amountOwing = amounts[0].add(premiums[0]);

    // Transfer to the vault ERC20
    IERC20(assets[0]).uniTransfer(payable(info.vault), amounts[0]);

    if (info.callType == FlashLoan.CallType.Switch) {
      IVault(info.vault).executeSwitch(info.newProvider, amounts[0], premiums[0]);
    } else if (info.callType == FlashLoan.CallType.Close) {
      IFliquidator(info.fliquidator).executeFlashClose(
        info.userAddrs[0],
        info.vault,
        amounts[0],
        premiums[0]
      );
    } else {
      IFliquidator(info.fliquidator).executeFlashBatchLiquidation(
        info.userAddrs,
        info.userBalances,
        info.userliquidator,
        info.vault,
        amounts[0],
        premiums[0]
      );
    }

    //Approve aaveLP to spend to repay flashloan
    IERC20(assets[0]).uniApprove(payable(_aaveLendingPool), amountOwing);

    return true;
  }

  // ===================== CreamFinance FlashLoan ===================================

  /**
   * @dev Initiates an CreamFinance flashloan.
   * @param info: data to be passed between functions executing flashloan logic
   */
  function _initiateCreamFlashLoan(FlashLoan.Info calldata info) internal {
    // Get crToken Address for Flashloan Call
    address crToken = _crMappings.addressMapping(info.asset);

    // Prepara data for flashloan execution
    bytes memory params = abi.encode(info);

    // Initialize Instance of Cream crLendingContract
    ICTokenFlashloan(crToken).flashLoan(address(this), info.amount, params);
  }

  /**
   * @dev Executes CreamFinance Flashloan, this operation is required
   * and called by CreamFinanceflashloan when sending loaned amount
   */
  function executeOperation(
    address sender,
    address underlying,
    uint256 amount,
    uint256 fee,
    bytes calldata params
  ) external override {
    // Check Msg. Sender is crToken Lending Contract
    address crToken = _crMappings.addressMapping(underlying);

    require(msg.sender == crToken && address(this) == sender, Errors.VL_NOT_AUTHORIZED);
    require(IERC20(underlying).balanceOf(address(this)) >= amount, Errors.VL_FLASHLOAN_FAILED);

    FlashLoan.Info memory info = abi.decode(params, (FlashLoan.Info));

    // Estimate flashloan payback + premium fee,
    uint256 amountOwing = amount.add(fee);

    // Transfer to the vault ERC20
    IERC20(underlying).uniTransfer(payable(info.vault), amount);

    // Do task according to CallType
    if (info.callType == FlashLoan.CallType.Switch) {
      IVault(info.vault).executeSwitch(info.newProvider, amount, fee);
    } else if (info.callType == FlashLoan.CallType.Close) {
      IFliquidator(info.fliquidator).executeFlashClose(info.userAddrs[0], info.vault, amount, fee);
    } else {
      IFliquidator(info.fliquidator).executeFlashBatchLiquidation(
        info.userAddrs,
        info.userBalances,
        info.userliquidator,
        info.vault,
        amount,
        fee
      );
    }

    // Transfer flashloan + fee back to crToken Lending Contract
    IERC20(underlying).uniTransfer(payable(crToken), amountOwing);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.5;

library FlashLoan {
  /**
   * @dev Used to determine which vault's function to call post-flashloan:
   * - Switch for executeSwitch(...)
   * - Close for executeFlashClose(...)
   * - Liquidate for executeFlashLiquidation(...)
   * - BatchLiquidate for executeFlashBatchLiquidation(...)
   */
  enum CallType { Switch, Close, BatchLiquidate }

  /**
   * @dev Struct of params to be passed between functions executing flashloan logic
   * @param asset: Address of asset to be borrowed with flashloan
   * @param amount: Amount of asset to be borrowed with flashloan
   * @param vault: Vault's address on which the flashloan logic to be executed
   * @param newProvider: New provider's address. Used when callType is Switch
   * @param userAddrs: User's address array Used when callType is BatchLiquidate
   * @param userBals:  Array of user's balances, Used when callType is BatchLiquidate
   * @param userliquidator: The user's address who is  performing liquidation. Used when callType is Liquidate
   * @param fliquidator: Fujis Liquidator's address.
   */
  struct Info {
    CallType callType;
    address asset;
    uint256 amount;
    address vault;
    address newProvider;
    address[] userAddrs;
    uint256[] userBalances;
    address userliquidator;
    address fliquidator;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity <0.8.0;

/**
 * @title Errors library
 * @author Fuji
 * @notice Defines the error messages emitted by the different contracts of the Aave protocol
 * @dev Error messages prefix glossary:
 *  - VL = Validation Logic 100 series
 *  - MATH = Math libraries 200 series
 *  - RF = Refinancing 300 series
 *  - VLT = vault 400 series
 *  - SP = Special 900 series
 */
library Errors {
  //Errors
  string public constant VL_INDEX_OVERFLOW = "100"; // index overflows uint128
  string public constant VL_INVALID_MINT_AMOUNT = "101"; //invalid amount to mint
  string public constant VL_INVALID_BURN_AMOUNT = "102"; //invalid amount to burn
  string public constant VL_AMOUNT_ERROR = "103"; //Input value >0, and for ETH msg.value and amount shall match
  string public constant VL_INVALID_WITHDRAW_AMOUNT = "104"; //Withdraw amount exceeds provided collateral, or falls undercollaterized
  string public constant VL_INVALID_BORROW_AMOUNT = "105"; //Borrow amount does not meet collaterization
  string public constant VL_NO_DEBT_TO_PAYBACK = "106"; //Msg sender has no debt amount to be payback
  string public constant VL_MISSING_ERC20_ALLOWANCE = "107"; //Msg sender has not approved ERC20 full amount to transfer
  string public constant VL_USER_NOT_LIQUIDATABLE = "108"; //User debt position is not liquidatable
  string public constant VL_DEBT_LESS_THAN_AMOUNT = "109"; //User debt is less than amount to partial close
  string public constant VL_PROVIDER_ALREADY_ADDED = "110"; // Provider is already added in Provider Array
  string public constant VL_NOT_AUTHORIZED = "111"; //Not authorized
  string public constant VL_INVALID_COLLATERAL = "112"; //There is no Collateral, or Collateral is not in active in vault
  string public constant VL_NO_ERC20_BALANCE = "113"; //User does not have ERC20 balance
  string public constant VL_INPUT_ERROR = "114"; //Check inputs. For ERC1155 batch functions, array sizes should match.
  string public constant VL_ASSET_EXISTS = "115"; //Asset intended to be added already exists in FujiERC1155
  string public constant VL_ZERO_ADDR_1155 = "116"; //ERC1155: balance/transfer for zero address
  string public constant VL_NOT_A_CONTRACT = "117"; //Address is not a contract.
  string public constant VL_INVALID_ASSETID_1155 = "118"; //ERC1155 Asset ID is invalid.
  string public constant VL_NO_ERC1155_BALANCE = "119"; //ERC1155: insufficient balance for transfer.
  string public constant VL_MISSING_ERC1155_APPROVAL = "120"; //ERC1155: transfer caller is not owner nor approved.
  string public constant VL_RECEIVER_REJECT_1155 = "121"; //ERC1155Receiver rejected tokens
  string public constant VL_RECEIVER_CONTRACT_NON_1155 = "122"; //ERC1155: transfer to non ERC1155Receiver implementer
  string public constant VL_OPTIMIZER_FEE_SMALL = "123"; //Fuji OptimizerFee has to be > 1 RAY (1e27)
  string public constant VL_UNDERCOLLATERIZED_ERROR = "124"; // Flashloan-Flashclose cannot be used when User's collateral is worth less than intended debt position to close.
  string public constant VL_MINIMUM_PAYBACK_ERROR = "125"; // Minimum Amount payback should be at least Fuji Optimizerfee accrued interest.
  string public constant VL_HARVESTING_FAILED = "126"; // Harvesting Function failed, check provided _farmProtocolNum or no claimable balance.
  string public constant VL_FLASHLOAN_FAILED = "127"; // Flashloan failed

  string public constant MATH_DIVISION_BY_ZERO = "201";
  string public constant MATH_ADDITION_OVERFLOW = "202";
  string public constant MATH_MULTIPLICATION_OVERFLOW = "203";

  string public constant RF_NO_GREENLIGHT = "300"; // Conditions for refinancing are not met, greenLight, deltaAPRThreshold, deltatimestampThreshold
  string public constant RF_INVALID_RATIO_VALUES = "301"; // Ratio Value provided is invalid, _ratioA/_ratioB <= 1, and > 0, or activeProvider borrowBalance = 0
  string public constant RF_CHECK_RATES_FALSE = "302"; //Check Rates routine returned False

  string public constant VLT_CALLER_MUST_BE_VAULT = "401"; // The caller of this function must be a vault

  string public constant SP_ALPHA_WHITELIST = "901"; // One ETH cap value for Alpha Version < 1 ETH
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

library LibUniversalERC20 {
  using SafeERC20 for IERC20;

  IERC20 private constant _ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  IERC20 private constant _ZERO_ADDRESS = IERC20(0);

  function isETH(IERC20 token) internal pure returns (bool) {
    return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
  }

  function univBalanceOf(IERC20 token, address account) internal view returns (uint256) {
    if (isETH(token)) {
      return account.balance;
    } else {
      return token.balanceOf(account);
    }
  }

  function univTransfer(
    IERC20 token,
    address payable to,
    uint256 amount
  ) internal {
    if (amount > 0) {
      if (isETH(token)) {
        (bool sent, ) = to.call{ value: amount }("");
        require(sent, "Failed to send Ether");
      } else {
        token.safeTransfer(to, amount);
      }
    }
  }

  function univApprove(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    require(!isETH(token), "Approve called on ETH");

    if (amount == 0) {
      token.safeApprove(to, 0);
    } else {
      uint256 allowance = token.allowance(address(this), to);
      if (allowance < amount) {
        if (allowance > 0) {
          token.safeApprove(to, 0);
        }
        token.safeApprove(to, amount);
      }
    }
  }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

library UniERC20 {
  using SafeERC20 for IERC20;

  IERC20 private constant _ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  IERC20 private constant _ZERO_ADDRESS = IERC20(0);

  function isETH(IERC20 token) internal pure returns (bool) {
    return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
  }

  function uniBalanceOf(IERC20 token, address account) internal view returns (uint256) {
    if (isETH(token)) {
      return account.balance;
    } else {
      return token.balanceOf(account);
    }
  }

  function uniTransfer(
    IERC20 token,
    address payable to,
    uint256 amount
  ) internal {
    if (amount > 0) {
      if (isETH(token)) {
        to.transfer(amount);
      } else {
        token.safeTransfer(to, amount);
      }
    }
  }

  function uniApprove(
    IERC20 token,
    address to,
    uint256 amount
  ) internal {
    require(!isETH(token), "Approve called on ETH");

    if (amount == 0) {
      token.safeApprove(to, 0);
    } else {
      uint256 allowance = token.allowance(address(this), to);
      if (allowance < amount) {
        if (allowance > 0) {
          token.safeApprove(to, 0);
        }
        token.safeApprove(to, amount);
      }
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.5;

interface IFlashLoanReceiver {
  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external returns (bool);
}

interface ILendingPool {
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.5;
pragma experimental ABIEncoderV2;

library Account {
  enum Status { Normal, Liquid, Vapor }
  struct Info {
    address owner; // The address that owns the account
    uint256 number; // A nonce that allows a single address to control many accounts
  }
}

library Actions {
  enum ActionType {
    Deposit, // supply tokens
    Withdraw, // borrow tokens
    Transfer, // transfer balance between accounts
    Buy, // buy an amount of some token (publicly)
    Sell, // sell an amount of some token (publicly)
    Trade, // trade tokens against another account
    Liquidate, // liquidate an undercollateralized or expiring account
    Vaporize, // use excess tokens to zero-out a completely negative account
    Call // send arbitrary data to an address
  }

  struct ActionArgs {
    ActionType actionType;
    uint256 accountId;
    Types.AssetAmount amount;
    uint256 primaryMarketId;
    uint256 secondaryMarketId;
    address otherAddress;
    uint256 otherAccountId;
    bytes data;
  }
}

library Types {
  enum AssetDenomination {
    Wei, // the amount is denominated in wei
    Par // the amount is denominated in par
  }

  enum AssetReference {
    Delta, // the amount is given as a delta from the current value
    Target // the amount is given as an exact number to end up at
  }

  struct AssetAmount {
    bool sign; // true if positive
    AssetDenomination denomination;
    AssetReference ref;
    uint256 value;
  }
}

/**
 * @title ICallee
 * @author dYdX
 *
 * Interface that Callees for Solo must implement in order to ingest data.
 */
interface ICallee {
  /**
   * Allows users to send this contract arbitrary data.
   *
   * @param  sender       The msg.sender to Solo
   * @param  accountInfo  The account from which the data is being sent
   * @param  data         Arbitrary data given by the sender
   */
  function callFunction(
    address sender,
    Account.Info memory accountInfo,
    bytes memory data
  ) external;
}

interface ISoloMargin {
  function getNumMarkets() external view returns (uint256);

  function getMarketTokenAddress(uint256 marketId) external view returns (address);

  function operate(Account.Info[] memory accounts, Actions.ActionArgs[] memory actions) external;
}

contract DyDxFlashloanBase {
  // -- Internal Helper functions -- //

  function _getMarketIdFromTokenAddress(ISoloMargin solo, address token)
    internal
    view
    returns (uint256)
  {
    uint256 numMarkets = solo.getNumMarkets();

    address curToken;
    for (uint256 i = 0; i < numMarkets; i++) {
      curToken = solo.getMarketTokenAddress(i);

      if (curToken == token) {
        return i;
      }
    }

    revert("No marketId found");
  }

  function _getAccountInfo(address receiver) internal pure returns (Account.Info memory) {
    return Account.Info({ owner: receiver, number: 1 });
  }

  function _getWithdrawAction(uint256 marketId, uint256 amount)
    internal
    view
    returns (Actions.ActionArgs memory)
  {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Withdraw,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: false,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: amount
        }),
        primaryMarketId: marketId,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: ""
      });
  }

  function _getCallAction(bytes memory data) internal view returns (Actions.ActionArgs memory) {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Call,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: false,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: 0
        }),
        primaryMarketId: 0,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: data
      });
  }

  function _getDepositAction(uint256 marketId, uint256 amount)
    internal
    view
    returns (Actions.ActionArgs memory)
  {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Deposit,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: true,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: amount
        }),
        primaryMarketId: marketId,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: ""
      });
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.5;

interface ICFlashloanReceiver {
  function executeOperation(
    address sender,
    address underlying,
    uint256 amount,
    uint256 fee,
    bytes calldata params
  ) external;
}

interface ICTokenFlashloan {
  function flashLoan(
    address receiver,
    uint256 amount,
    bytes calldata params
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

{
  "optimizer": {
    "enabled": true,
    "runs": 1000
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}