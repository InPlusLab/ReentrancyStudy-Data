// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import 'diamond-2/contracts/libraries/LibDiamond.sol';

import '../interfaces/IPayout.sol';

import '../storage/PayoutStorage.sol';

import '../libraries/LibSherX.sol';
import '../libraries/LibSherXERC20.sol';

contract Payout is IPayout {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  //
  // Modifiers
  //

  modifier onlyGovMain() {
    require(msg.sender == GovStorage.gs().govMain, 'NOT_GOV_MAIN');
    _;
  }

  modifier onlyGovPayout() {
    require(msg.sender == PayoutStorage.ps().govPayout, 'NOT_GOV_PAY');
    _;
  }

  //
  // View methods
  //

  function getGovPayout() external view override returns (address) {
    return PayoutStorage.ps().govPayout;
  }

  //
  // State changing methods
  //

  function setInitialGovPayout(address _govPayout) external override {
    PayoutStorage.Base storage ps = PayoutStorage.ps();

    require(msg.sender == LibDiamond.contractOwner(), 'NOT_DEV');
    require(_govPayout != address(0), 'ZERO_GOV');
    require(ps.govPayout == address(0), 'ALREADY_SET');

    ps.govPayout = _govPayout;
  }

  function transferGovPayout(address _govPayout) external override onlyGovMain {
    PayoutStorage.Base storage ps = PayoutStorage.ps();

    require(_govPayout != address(0), 'ZERO_GOV');
    require(ps.govPayout != _govPayout, 'SAME_GOV');
    ps.govPayout = _govPayout;
  }

  /// @notice Transfer certain amount of underlying tokens of unallocated SherX to `_payout`
  /// @param _payout Account to receive underlying tokens
  /// @param _exclude Token to exclude from payout
  /// @param curTotalUsdPool The current `sx.totalUsdPool`
  /// @param totalSherX The amount of SherX to use for payout
  /// @return sherUsd Total amount of USD of the underlying tokens that are excluded being transferred
  function _doSherX(
    address _payout,
    address _exclude,
    uint256 curTotalUsdPool,
    uint256 totalSherX
  ) private returns (uint256 sherUsd) {
    SherXStorage.Base storage sx = SherXStorage.sx();
    // Calculate the current `amounts` of underlying `tokens` for `totalSherX`
    (IERC20[] memory tokens, uint256[] memory amounts) = LibSherX.calcUnderlying(totalSherX);
    uint256 subUsdPool;

    for (uint256 i; i < tokens.length; i++) {
      PoolStorage.Base storage ps = PoolStorage.ps(tokens[i]);

      if (address(tokens[i]) == _exclude) {
        // Return USD value of token that is excluded from payout
        sherUsd = amounts[i].mul(sx.tokenUSD[tokens[i]]).div(10**18);
      } else {
        // Expensive operation, only execute to prevent tx reverts
        if (amounts[i] > ps.sherXUnderlying) {
          LibPool.payOffDebtAll(tokens[i]);
        }
        // Remove the token as underlying of SherX
        ps.sherXUnderlying = ps.sherXUnderlying.sub(amounts[i]);
        // As the tokens are transferred, remove from the current usdPool
        // By summing the total that needs to be deducted in the `subUsdPool` value
        subUsdPool = subUsdPool.add(amounts[i].mul(sx.tokenUSD[tokens[i]]).div(10**18));
        // NOTE: transfer can potentially be optimized, as payout call itself also does transfers
        tokens[i].safeTransfer(_payout, amounts[i]);
      }
    }
    // Subtract the total amount that needs to be subtracted from the `sx.totalUsdPool`
    sx.totalUsdPool = curTotalUsdPool.sub(subUsdPool);
  }

  function payout(
    address _payout,
    IERC20[] memory _tokens,
    uint256[] memory _firstMoneyOut,
    uint256[] memory _amounts,
    uint256[] memory _unallocatedSherX,
    address _exclude
  ) external override onlyGovPayout {
    // all pools (including SherX pool) can be deducted fmo and balance
    // deducting balance will reduce the users underlying value of stake token
    // for every pool, _unallocatedSherX can be deducted, this will decrease outstanding SherX rewards
    // for users that did not claim them (e.g materialized them and included in SherX pool)

    require(address(_payout) != address(0), 'ZERO_PAY');
    require(address(_payout) != address(this), 'THIS_PAY');
    require(_tokens.length == _firstMoneyOut.length, 'LENGTH_1');
    require(_tokens.length == _amounts.length, 'LENGTH_2');
    require(_tokens.length == _unallocatedSherX.length, 'LENGTH_3');

    LibSherX.accrueSherX();

    uint256 totalSherX;

    for (uint256 i; i < _tokens.length; i++) {
      IERC20 token = _tokens[i];
      uint256 firstMoneyOut = _firstMoneyOut[i];
      uint256 amounts = _amounts[i];
      // Unallocated SHERX can not be used for a payout. This could break lock token transfers.
      // Keep this line here until a fix is found
      require(_unallocatedSherX[i] == 0, 'NO_UNALLOC');

      PoolStorage.Base storage ps = PoolStorage.ps(token);
      require(address(ps.lockToken) != address(0), 'INIT');

      uint256 total = firstMoneyOut.add(amounts);
      if (total == 0) {
        continue;
      }
      if (firstMoneyOut != 0) {
        ps.firstMoneyOut = ps.firstMoneyOut.sub(firstMoneyOut);
      }
      ps.stakeBalance = ps.stakeBalance.sub(total);
      // If stakeBalance is 0, it could break stake() function
      require(ps.stakeBalance >= 1, 'STAKE');

      if (address(token) == address(this)) {
        // If the token address == address(this), it's SherX
        totalSherX = total;
      } else {
        // NOTE: Inside the _doSherX() call tokens are also transferred, potential gas optimalisation if tokens
        // are transferred at once
        token.safeTransfer(_payout, total);
      }
    }

    if (totalSherX == 0) {
      return;
    }

    // NOTE: sx20().totalSupply is always != 0 when this codes hit.

    uint256 curTotalUsdPool = LibSherX.viewAccrueUSDPool();
    uint256 excludeUsd = _doSherX(_payout, _exclude, curTotalUsdPool, totalSherX);

    // usd excluded, divided by the price per SherX token = amount of sherx to not burn.
    uint256 deduction = excludeUsd.mul(SherXERC20Storage.sx20().totalSupply).div(curTotalUsdPool);
    // deduct that amount from the tokens being burned, to keep the same USD value
    uint256 burnAmount = totalSherX.sub(deduction);

    LibSherXERC20.burn(address(this), burnAmount);
    LibSherX.settleInternalSupply(burnAmount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
*
* This is gas optimized by reducing storage reads and storage writes.
* This code is as complex as it is to reduce gas costs.
/******************************************************************************/

import "../interfaces/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DiamondStorage {
        // maps function selectors to the facets that execute the functions.
        // and maps the selectors to their position in the selectorSlots array.
        // func selector => address facet, selector position
        mapping(bytes4 => bytes32) facets;
        // array of slots of function selectors.
        // each slot holds 8 function selectors.
        mapping(uint256 => bytes32) selectorSlots;
        // The number of function selectors in selectorSlots
        uint16 selectorCount;
        // owner of the contract
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    modifier onlyOwner {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
        _;
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

    // Internal function version of diamondCut
    // This code is almost the same as the external diamondCut,
    // except it is using 'Facet[] memory _diamondCut' instead of
    // 'Facet[] calldata _diamondCut'.
    // The code is duplicated to prevent copying calldata to memory which
    // causes an error for a two dimensional array.
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        if (selectorCount % 8 > 0) {
            // get last selectorSlot
            selectorSlot = ds.selectorSlots[selectorCount / 8];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        if (selectorCount % 8 > 0) {
            ds.selectorSlots[selectorCount / 8] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addReplaceRemoveFacetSelectors(
        uint256 _selectorCount,
        bytes32 _selectorSlot,
        address _newFacetAddress,
        IDiamondCut.FacetCutAction _action,
        bytes4[] memory _selectors
    ) internal returns (uint256, bytes32) {
        DiamondStorage storage ds = diamondStorage();
        require(_selectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        if (_action == IDiamondCut.FacetCutAction.Add) {
            require(_newFacetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Add facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                require(address(bytes20(oldFacet)) == address(0), "LibDiamondCut: Can't add function that already exists");
                // add facet for selector
                ds.facets[selector] = bytes20(_newFacetAddress) | bytes32(_selectorCount);
                uint256 selectorInSlotPosition = (_selectorCount % 8) * 32;
                // clear selector position in slot and add selector
                _selectorSlot = (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) | (bytes32(selector) >> selectorInSlotPosition);
                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    ds.selectorSlots[_selectorCount / 8] = _selectorSlot;
                    _selectorSlot = 0;
                }
                _selectorCount++;
            }
        } else if (_action == IDiamondCut.FacetCutAction.Replace) {
            require(_newFacetAddress != address(0), "LibDiamondCut: Replace facet can't be address(0)");
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Replace facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));
                // only useful if immutable functions exist
                require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
                require(oldFacetAddress != _newFacetAddress, "LibDiamondCut: Can't replace function with same function");
                require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
                // replace old facet address
                ds.facets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(_newFacetAddress);
            }
        } else if (_action == IDiamondCut.FacetCutAction.Remove) {
            require(_newFacetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
            uint256 selectorSlotCount = _selectorCount / 8;
            uint256 selectorInSlotIndex = (_selectorCount % 8) - 1;
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                if (_selectorSlot == 0) {
                    // get last selectorSlot
                    selectorSlotCount--;
                    _selectorSlot = ds.selectorSlots[selectorSlotCount];
                    selectorInSlotIndex = 7;
                }
                bytes4 lastSelector;
                uint256 oldSelectorsSlotCount;
                uint256 oldSelectorInSlotPosition;
                // adding a block here prevents stack too deep error
                {
                    bytes4 selector = _selectors[selectorIndex];
                    bytes32 oldFacet = ds.facets[selector];
                    require(address(bytes20(oldFacet)) != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
                    // only useful if immutable functions exist
                    require(address(bytes20(oldFacet)) != address(this), "LibDiamondCut: Can't remove immutable function");
                    // replace selector with last selector in ds.facets
                    // gets the last selector
                    lastSelector = bytes4(_selectorSlot << (selectorInSlotIndex * 32));
                    if (lastSelector != selector) {
                        // update last selector slot position info
                        ds.facets[lastSelector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(ds.facets[lastSelector]);
                    }
                    delete ds.facets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    oldSelectorsSlotCount = oldSelectorCount / 8;
                    oldSelectorInSlotPosition = (oldSelectorCount % 8) * 32;
                }
                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = ds.selectorSlots[oldSelectorsSlotCount];
                    // clears the selector we are deleting and puts the last selector in its place.
                    oldSelectorSlot =
                        (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                    // update storage with the modified slot
                    ds.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    // clears the selector we are deleting and puts the last selector in its place.
                    _selectorSlot =
                        (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }
                if (selectorInSlotIndex == 0) {
                    delete ds.selectorSlots[selectorSlotCount];
                    _selectorSlot = 0;
                }
                selectorInSlotIndex--;
            }
            _selectorCount = selectorSlotCount * 8 + selectorInSlotIndex + 1;
        } else {
            revert("LibDiamondCut: Incorrect FacetCutAction");
        }
        return (_selectorCount, _selectorSlot);
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Sherlock Payout Controller
/// @author Evert Kors
/// @notice This contract is used for doing payouts
/// @dev Contract is meant to be included as a facet in the diamond
/// @dev Storage library is used
interface IPayout {
  /// @notice Returns the governance address able to do payouts
  /// @return Payout governance address
  function getGovPayout() external view returns (address);

  /// @notice Set initial payout governance address
  /// @param _govPayout The address of the payout governance
  /// @dev Diamond deployer - GovDev - is able to call this function
  function setInitialGovPayout(address _govPayout) external;

  /// @notice Transfer the payout governance
  /// @param _govPayout New address for the payout governance
  function transferGovPayout(address _govPayout) external;

  /// @notice Send `_tokens` to `_payout`
  /// @param _payout Account to receive payout
  /// @param _tokens Tokens to be paid out
  /// @param _firstMoneyOut Amount used from first money out
  /// @param _amounts Amount used staker balance
  /// @param _unallocatedSherX Amount of unallocated SHERX used
  /// @param _exclude Token excluded from payout
  function payout(
    address _payout,
    IERC20[] memory _tokens,
    uint256[] memory _firstMoneyOut,
    uint256[] memory _amounts,
    uint256[] memory _unallocatedSherX,
    address _exclude
  ) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

library PayoutStorage {
  bytes32 constant PAYOUT_STORAGE_POSITION = keccak256('diamond.sherlock.payout');

  struct Base {
    address govPayout;
  }

  function ps() internal pure returns (Base storage psx) {
    bytes32 position = PAYOUT_STORAGE_POSITION;
    assembly {
      psx.slot := position
    }
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '../storage/PoolStorage.sol';
import '../storage/GovStorage.sol';

import './LibSherXERC20.sol';
import './LibPool.sol';

library LibSherX {
  using SafeMath for uint256;

  function viewAccrueUSDPool() public view returns (uint256 totalUsdPool) {
    SherXStorage.Base storage sx = SherXStorage.sx();
    totalUsdPool = sx.totalUsdPool.add(
      block.number.sub(sx.totalUsdLastSettled).mul(sx.totalUsdPerBlock)
    );
  }

  function accrueUSDPool() external returns (uint256 totalUsdPool) {
    SherXStorage.Base storage sx = SherXStorage.sx();
    totalUsdPool = viewAccrueUSDPool();
    sx.totalUsdPool = totalUsdPool;
    sx.totalUsdLastSettled = block.number;
  }

  function settleInternalSupply(uint256 _deduct) external {
    SherXStorage.Base storage sx = SherXStorage.sx();
    sx.internalTotalSupply = getTotalSherX().sub(_deduct);
    sx.internalTotalSupplySettled = block.number;
  }

  function getTotalSherX() public view returns (uint256) {
    // calc by taking base supply, block at, and calc it by taking base + now - block_at * sherxperblock
    // update baseSupply on every premium update
    SherXStorage.Base storage sx = SherXStorage.sx();
    return
      sx.internalTotalSupply.add(
        block.number.sub(sx.internalTotalSupplySettled).mul(sx.sherXPerBlock)
      );
  }

  function calcUnderlying(uint256 _amount)
    external
    view
    returns (IERC20[] memory tokens, uint256[] memory amounts)
  {
    GovStorage.Base storage gs = GovStorage.gs();

    uint256 length = gs.tokensSherX.length;

    tokens = gs.tokensSherX;
    amounts = new uint256[](length);

    uint256 total = getTotalSherX();

    for (uint256 i; i < length; i++) {
      IERC20 token = gs.tokensSherX[i];

      if (total != 0) {
        PoolStorage.Base storage ps = PoolStorage.ps(token);
        amounts[i] = ps.sherXUnderlying.add(LibPool.getTotalAccruedDebt(token)).mul(_amount).div(
          total
        );
      }
    }
  }

  function accrueSherX(IERC20 _token) external {
    SherXStorage.Base storage sx = SherXStorage.sx();
    uint256 sherX = _accrueSherX(_token, sx.sherXPerBlock);
    if (sherX != 0) {
      LibSherXERC20.mint(address(this), sherX);
    }
  }

  function accrueSherXWatsons() external {
    SherXStorage.Base storage sx = SherXStorage.sx();
    _accrueSherXWatsons(sx.sherXPerBlock);
  }

  function accrueSherX() external {
    // loop over pools, increase the pool + pool_weight based on the distribution weights
    SherXStorage.Base storage sx = SherXStorage.sx();
    GovStorage.Base storage gs = GovStorage.gs();
    uint256 sherXPerBlock = sx.sherXPerBlock;
    uint256 sherX;
    uint256 length = gs.tokensStaker.length;
    for (uint256 i; i < length; i++) {
      sherX = sherX.add(_accrueSherX(gs.tokensStaker[i], sherXPerBlock));
    }
    if (sherX != 0) {
      LibSherXERC20.mint(address(this), sherX);
    }

    _accrueSherXWatsons(sherXPerBlock);
  }

  function _accrueSherXWatsons(uint256 sherXPerBlock) private {
    GovStorage.Base storage gs = GovStorage.gs();

    uint256 sherX =
      block
        .number
        .sub(gs.watsonsSherxLastAccrued)
        .mul(sherXPerBlock)
        .mul(gs.watsonsSherxWeight)
        .div(type(uint16).max);
    // need to settle before return, as updating the sherxperlblock/weight
    // after it was 0 will result in a too big amount (accured will be < block.number)
    gs.watsonsSherxLastAccrued = uint40(block.number);
    if (sherX == 0) {
      return;
    }
    LibSherXERC20.mint(gs.watsonsAddress, sherX);
  }

  function _accrueSherX(IERC20 _token, uint256 sherXPerBlock) private returns (uint256 sherX) {
    PoolStorage.Base storage ps = PoolStorage.ps(_token);
    uint256 lastAccrued = ps.sherXLastAccrued;
    if (lastAccrued == block.number) {
      return 0;
    }
    sherX = block.number.sub(lastAccrued).mul(sherXPerBlock).mul(ps.sherXWeight).div(
      type(uint16).max
    );
    // need to settle before return, as updating the sherxperlblock/weight
    // after it was 0 will result in a too big amount (accured will be < block.number)
    ps.sherXLastAccrued = uint40(block.number);
    if (address(_token) == address(this)) {
      ps.stakeBalance = ps.stakeBalance.add(sherX);
    } else {
      ps.unallocatedSherX = ps.unallocatedSherX.add(sherX);
      ps.sWeight = ps.sWeight.add(sherX);
    }
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz

* Inspired by: https://github.com/pie-dao/PieVaults/blob/master/contracts/facets/ERC20/LibERC20.sol
/******************************************************************************/

import '@openzeppelin/contracts/math/SafeMath.sol';

import '../storage/SherXERC20Storage.sol';

library LibSherXERC20 {
  using SafeMath for uint256;

  // Need to include events locally because `emit Interface.Event(params)` does not work
  event Transfer(address indexed from, address indexed to, uint256 amount);

  function mint(address _to, uint256 _amount) internal {
    SherXERC20Storage.Base storage sx20 = SherXERC20Storage.sx20();

    sx20.balances[_to] = sx20.balances[_to].add(_amount);
    sx20.totalSupply = sx20.totalSupply.add(_amount);
    emit Transfer(address(0), _to, _amount);
  }

  function burn(address _from, uint256 _amount) internal {
    SherXERC20Storage.Base storage sx20 = SherXERC20Storage.sx20();

    sx20.balances[_from] = sx20.balances[_from].sub(_amount);
    sx20.totalSupply = sx20.totalSupply.sub(_amount);
    emit Transfer(_from, address(0), _amount);
  }

  function approve(
    address _from,
    address _to,
    uint256 _amount
  ) internal returns (bool) {
    SherXERC20Storage.sx20().allowances[_from][_to] = _amount;
    return true;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '../interfaces/ILock.sol';
import '../interfaces/IStrategy.sol';

// TokenStorage
library PoolStorage {
  bytes32 constant POOL_STORAGE_PREFIX = 'diamond.sherlock.pool.';

  struct Base {
    address govPool;
    // Variable used to calculate the fee when activating the cooldown
    // Max value is type(uint32).max which creates a 100% fee on the withdrawal
    uint32 activateCooldownFee;
    // How much sherX is distributed to stakers of this token
    // The max value is type(uint16).max, which means 100% of the total SherX minted is allocated to this pool
    uint16 sherXWeight;
    // The last block the total amount of rewards were accrued.
    // Accrueing SherX increases the `unallocatedSherX` variable
    uint40 sherXLastAccrued;
    // Indicates if protocol are able to pay premiums with this token
    // If this value is true, the token is also included as underlying of the SherX
    bool premiums;
    // Protocol debt can only be settled at once for all the protocols at the same time
    // This variable is the block number the last time all the protocols debt was settled
    uint40 totalPremiumLastPaid;
    //
    // Staking
    //
    // Indicates if stakers can stake funds in the pool
    bool stakes;
    // Address of the lockToken. Representing stakes in this pool
    ILock lockToken;
    // The total amount staked by the stakers in this pool, including value of `firstMoneyOut`
    // if you exclude the `firstMoneyOut` from this value, you get the actual amount of tokens staked
    // This value is also excluding funds deposited in a strategy.
    uint256 stakeBalance;
    // All the withdrawals by an account
    // The values of the struct are all deleted if expiry() or unstake() function is called
    mapping(address => UnstakeEntry[]) unstakeEntries;
    // Represents the amount of tokens in the first money out pool
    uint256 firstMoneyOut;
    // If the `stakes` = true, the stakers can be rewarded by sherx
    // stakers can claim their rewards by calling the harvest() function
    // SherX could be minted before the stakers call the harvest() function
    // Minted SherX that is assigned as reward for the pool will be added to this value
    uint256 unallocatedSherX;
    // Non-native variables
    // These variables are used to calculate the right amount of SherX rewards for the token staked
    mapping(address => uint256) sWithdrawn;
    uint256 sWeight;
    // Storing the protocol token balance based on the protocols bytes32 indentifier
    mapping(bytes32 => uint256) protocolBalance;
    // Storing the protocol premium, the amount of debt the protocol builds up per block.
    // This is based on the bytes32 identifier of the protocol.
    mapping(bytes32 => uint256) protocolPremium;
    // The sum of all the protocol premiums, the total amount of debt that builds up in this token. (per block)
    uint256 totalPremiumPerBlock;
    // How much tokens are used as underlying for SherX
    uint256 sherXUnderlying;
    // Check if the protocol is included in the token pool
    // The protocol can deposit balances if this is the case
    mapping(bytes32 => bool) isProtocol;
    // Array of protocols that are registered in this pool
    bytes32[] protocols;
    // Active strategy for this token pool
    IStrategy strategy;
  }

  struct UnstakeEntry {
    // The block number the cooldown is activated
    uint40 blockInitiated;
    // The amount of lock tokens to be withdrawn
    uint256 lock;
  }

  function ps(IERC20 _token) internal pure returns (Base storage psx) {
    bytes32 position = keccak256(abi.encodePacked(POOL_STORAGE_PREFIX, _token));
    assembly {
      psx.slot := position
    }
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library GovStorage {
  bytes32 constant GOV_STORAGE_POSITION = keccak256('diamond.sherlock.gov');

  struct Base {
    // The address appointed as the govMain entity
    address govMain;
    // NOTE: UNUSED
    mapping(bytes32 => address) protocolManagers;
    // Based on the protocol identifier, get the address of the protocol that is able the withdraw balances
    mapping(bytes32 => address) protocolAgents;
    // Check if the protocol is included in the solution at all
    mapping(bytes32 => bool) protocolIsCovered;
    // The array of tokens the accounts are able to stake in
    IERC20[] tokensStaker;
    // The array of tokens the protocol are able to pay premium in
    // These tokens will also be the underlying for SherX
    IERC20[] tokensSherX;
    // The address of the watsons, an account that can receive SherX rewards
    address watsonsAddress;
    // How much sherX is distributed to this account
    // The max value is type(uint16).max, which means 100% of the total SherX minted is allocated to this acocunt
    uint16 watsonsSherxWeight;
    // The last block the total amount of rewards were accrued.
    uint40 watsonsSherxLastAccrued;
    // Max amount of SherX token to be in the `tokensSherX` array
    uint8 maxTokensSherX;
    // Max amount of Staker token to be in the `tokensStaker` array
    uint8 maxTokensStaker;
    // Max amount of protocol to be in single pool
    uint8 maxProtocolPool;
    // The amount of blocks the cooldown period takes
    uint40 unstakeCooldown;
    // The amount of blocks for the window of opportunity of unstaking
    uint40 unstakeWindow;
  }

  function gs() internal pure returns (Base storage gsx) {
    bytes32 position = GOV_STORAGE_POSITION;
    assembly {
      gsx.slot := position
    }
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

import '../storage/PoolStorage.sol';
import '../storage/SherXStorage.sol';

library LibPool {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using SafeERC20 for ILock;

  function stakeBalance(PoolStorage.Base storage ps) public view returns (uint256) {
    uint256 balance = ps.stakeBalance;

    if (address(ps.strategy) != address(0)) {
      balance = balance.add(ps.strategy.balanceOf());
    }

    return balance.sub(ps.firstMoneyOut);
  }

  function accruedDebt(bytes32 _protocol, IERC20 _token) external view returns (uint256) {
    PoolStorage.Base storage ps = PoolStorage.ps(_token);
    return _accruedDebt(ps, _protocol, block.number.sub(ps.totalPremiumLastPaid));
  }

  function getTotalAccruedDebt(IERC20 _token) external view returns (uint256) {
    PoolStorage.Base storage ps = PoolStorage.ps(_token);
    return _getTotalAccruedDebt(ps, block.number.sub(ps.totalPremiumLastPaid));
  }

  function getTotalUnmintedSherX(IERC20 _token) public view returns (uint256 sherX) {
    PoolStorage.Base storage ps = PoolStorage.ps(_token);
    SherXStorage.Base storage sx = SherXStorage.sx();
    sherX = block.number.sub(ps.sherXLastAccrued).mul(sx.sherXPerBlock).mul(ps.sherXWeight).div(
      type(uint16).max
    );
  }

  function getUnallocatedSherXFor(address _user, IERC20 _token)
    external
    view
    returns (uint256 withdrawable_amount)
  {
    PoolStorage.Base storage ps = PoolStorage.ps(_token);

    uint256 userAmount = ps.lockToken.balanceOf(_user);
    uint256 totalAmount = ps.lockToken.totalSupply();
    if (totalAmount == 0) {
      return 0;
    }

    uint256 raw_amount =
      ps.sWeight.add(getTotalUnmintedSherX(_token)).mul(userAmount).div(totalAmount);
    withdrawable_amount = raw_amount.sub(ps.sWithdrawn[_user]);
  }

  function stake(
    PoolStorage.Base storage ps,
    uint256 _amount,
    address _receiver
  ) external returns (uint256 lock) {
    uint256 totalLock = ps.lockToken.totalSupply();
    if (totalLock == 0) {
      // mint initial lock
      lock = 10**18;
    } else {
      // mint lock based on funds in pool
      lock = _amount.mul(totalLock).div(stakeBalance(ps));
    }
    ps.stakeBalance = ps.stakeBalance.add(_amount);
    ps.lockToken.mint(_receiver, lock);
  }

  function payOffDebtAll(IERC20 _token) external {
    PoolStorage.Base storage ps = PoolStorage.ps(_token);
    uint256 blocks = block.number.sub(ps.totalPremiumLastPaid);

    uint256 totalAccruedDebt;
    uint256 length = ps.protocols.length;
    for (uint256 i = 0; i < length; i++) {
      totalAccruedDebt = totalAccruedDebt.add(_payOffDebt(ps, ps.protocols[i], blocks));
    }
    // move funds to the sherX etf
    ps.sherXUnderlying = ps.sherXUnderlying.add(totalAccruedDebt);
    ps.totalPremiumLastPaid = uint40(block.number);
  }

  function _payOffDebt(
    PoolStorage.Base storage ps,
    bytes32 _protocol,
    uint256 _blocks
  ) private returns (uint256 debt) {
    debt = _accruedDebt(ps, _protocol, _blocks);
    ps.protocolBalance[_protocol] = ps.protocolBalance[_protocol].sub(debt);
  }

  function _accruedDebt(
    PoolStorage.Base storage ps,
    bytes32 _protocol,
    uint256 _blocks
  ) private view returns (uint256) {
    return _blocks.mul(ps.protocolPremium[_protocol]);
  }

  function _getTotalAccruedDebt(PoolStorage.Base storage ps, uint256 _blocks)
    private
    view
    returns (uint256)
  {
    return _blocks.mul(ps.totalPremiumPerBlock);
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Lock Token
/// @author Evert Kors
/// @notice Lock tokens represent a stake in Sherlock
interface ILock is IERC20 {
  /// @notice Returns the owner of this contract
  /// @return Owner address
  /// @dev Should be equal to the Sherlock address
  function getOwner() external view returns (address);

  /// @notice Returns token it represents
  /// @return Token address
  function underlying() external view returns (IERC20);

  /// @notice Mint `_amount` tokens for `_account`
  /// @param _account Account to receive tokens
  /// @param _amount Amount to be minted
  function mint(address _account, uint256 _amount) external;

  /// @notice Burn `_amount` tokens for `_account`
  /// @param _account Account to be burned
  /// @param _amount Amount to be burned
  function burn(address _account, uint256 _amount) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

interface IStrategy {
  function want() external view returns (ERC20);

  function withdrawAll() external returns (uint256);

  function withdraw(uint256 _amount) external;

  function deposit() external;

  function balanceOf() external view returns (uint256);

  function sweep(address _receiver, IERC20[] memory _extraTokens) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz

* Inspired by: https://github.com/pie-dao/PieVaults/blob/master/contracts/facets/ERC20/LibERC20Storage.sol
/******************************************************************************/

library SherXERC20Storage {
  bytes32 constant SHERX_ERC20_STORAGE_POSITION = keccak256('diamond.sherlock.x.erc20');

  struct Base {
    string name;
    string symbol;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
  }

  function sx20() internal pure returns (Base storage sx20x) {
    bytes32 position = SHERX_ERC20_STORAGE_POSITION;
    assembly {
      sx20x.slot := position
    }
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

/******************************************************************************\
* Author: Evert Kors <[email protected]> (https://twitter.com/evert0x)
* Sherlock Protocol: https://sherlock.xyz
/******************************************************************************/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library SherXStorage {
  bytes32 constant SHERX_STORAGE_POSITION = keccak256('diamond.sherlock.x');

  struct Base {
    mapping(IERC20 => uint256) tokenUSD;
    uint256 totalUsdPerBlock;
    uint256 totalUsdPool;
    uint256 totalUsdLastSettled;
    uint256 sherXPerBlock;
    uint256 internalTotalSupply;
    uint256 internalTotalSupplySettled;
  }

  function sx() internal pure returns (Base storage sxx) {
    bytes32 position = SHERX_STORAGE_POSITION;
    assembly {
      sxx.slot := position
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

{
  "optimizer": {
    "enabled": true,
    "runs": 200
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
  "libraries": {
    "@sherlock/v1-core/contracts/libraries/LibPool.sol": {
      "LibPool": "0xedda10a93767b07f6913cb01479f6418eb35ab7e"
    },
    "@sherlock/v1-core/contracts/libraries/LibSherX.sol": {
      "LibSherX": "0x22b6d0df02ff7480c77d73a755e5e5ecdac53b1e"
    }
  }
}