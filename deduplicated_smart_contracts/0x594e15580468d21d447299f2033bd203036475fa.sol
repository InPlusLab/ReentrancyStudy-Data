/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

// File: contracts/IAllocationStrategy.sol

pragma solidity ^0.5.8;

/**
 * @notice Allocation strategy for assets.
 *         - It invests the underlying assets into some yield generating contracts,
 *           usually lending contracts, in return it gets new assets aka. saving assets.
 *         - Sainv assets can be redeemed back to the underlying assets plus interest any time.
 */
interface IAllocationStrategy {

    /**
     * @notice Underlying asset for the strategy
     * @return address Underlying asset address
     */
    function underlying() external view returns (address);

    /**
     * @notice Calculates the exchange rate from the underlying to the saving assets
     * @return uint256 Calculated exchange rate scaled by 1e18
     */
    function exchangeRateStored() external view returns (uint256);

    /**
      * @notice Applies accrued interest to all savings
      * @dev This should calculates interest accrued from the last checkpointed
      *      block up to the current block and writes new checkpoint to storage.
      * @return bool success(true) or failure(false)
      */
    function accrueInterest() external returns (bool);

    /**
     * @notice Sender supplies underlying assets into the market and receives saving assets in exchange
     * @dev Interst shall be accrued
     * @param investAmount The amount of the underlying asset to supply
     * @return uint256 Amount of saving assets created
     */
    function investUnderlying(uint256 investAmount) external returns (uint256);

    /**
     * @notice Sender redeems saving assets in exchange for a specified amount of underlying asset
     * @dev Interst shall be accrued
     * @param redeemAmount The amount of underlying to redeem
     * @return uint256 Amount of saving assets burned
     */
    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: compound/contracts/CErc20Interface.sol

pragma solidity >=0.4.21 <0.6.0;

// converted from ethereum/contracts/compound/abi/CErc20.json
interface CErc20Interface {

    function name() external view returns (
        string memory
    );

    function approve(
        address spender,
        uint256 amount
    ) external returns (
        bool
    );

    function repayBorrow(
        uint256 repayAmount
    ) external returns (
        uint256
    );

    function reserveFactorMantissa() external view returns (
        uint256
    );

    function borrowBalanceCurrent(
        address account
    ) external returns (
        uint256
    );

    function totalSupply() external view returns (
        uint256
    );

    function exchangeRateStored() external view returns (
        uint256
    );

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (
        bool
    );

    function repayBorrowBehalf(
        address borrower,
        uint256 repayAmount
    ) external returns (
        uint256
    );

    function pendingAdmin() external view returns (
        address
    );

    function decimals() external view returns (
        uint256
    );

    function balanceOfUnderlying(
        address owner
    ) external returns (
        uint256
    );

    function getCash() external view returns (
        uint256
    );

    function _setComptroller(
        address newComptroller
    ) external returns (
        uint256
    );

    function totalBorrows() external view returns (
        uint256
    );

    function comptroller() external view returns (
        address
    );

    function _reduceReserves(
        uint256 reduceAmount
    ) external returns (
        uint256
    );

    function initialExchangeRateMantissa() external view returns (
        uint256
    );

    function accrualBlockNumber() external view returns (
        uint256
    );

    function underlying() external view returns (
        address
    );

    function balanceOf(
        address owner
    ) external view returns (
        uint256
    );

    function totalBorrowsCurrent() external returns (
        uint256
    );

    function redeemUnderlying(
        uint256 redeemAmount
    ) external returns (
        uint256
    );

    function totalReserves() external view returns (
        uint256
    );

    function symbol() external view returns (
        string memory
    );

    function borrowBalanceStored(
        address account
    ) external view returns (
        uint256
    );

    function mint(
        uint256 mintAmount
    ) external returns (
        uint256
    );

    function accrueInterest() external returns (
        uint256
    );

    function transfer(
        address dst,
        uint256 amount
    ) external returns (
        bool
    );

    function borrowIndex() external view returns (
        uint256
    );

    function supplyRatePerBlock() external view returns (
        uint256
    );

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (
        uint256
    );

    function _setPendingAdmin(
        address newPendingAdmin
    ) external returns (
        uint256
    );

    function exchangeRateCurrent() external returns (
        uint256
    );

    function getAccountSnapshot(
        address account
    ) external view returns (
        uint256,
        uint256,
        uint256,
        uint256
    );

    function borrow(
        uint256 borrowAmount
    ) external returns (
        uint256
    );

    function redeem(
        uint256 redeemTokens
    ) external returns (
        uint256
    );

    function allowance(
        address owner,
        address spender
    ) external view returns (
        uint256
    );

    function _acceptAdmin() external returns (
        uint256
    );

    function _setInterestRateModel(
        address newInterestRateModel
    ) external returns (
        uint256
    );

    function interestRateModel() external view returns (
        address
    );

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (
        uint256
    );

    function admin() external view returns (
        address
    );

    function borrowRatePerBlock() external view returns (
        uint256
    );

    function _setReserveFactor(
        uint256 newReserveFactorMantissa
    ) external returns (
        uint256
    );

    function isCToken() external view returns (
        bool
    );

    /*
    constructor(
        address underlying_,
        address comptroller_,
        address interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string  calldata name_,
        string  calldata symbol_,
        uint256 decimals_
    );
    */

    event AccrueInterest(
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 totalBorrows
    );

    event Mint(
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    );

    event Redeem(
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    );

    event Borrow(
        address borrower,
        uint256 borrowAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral,
        uint256 seizeTokens
    );

    event NewPendingAdmin(
        address oldPendingAdmin,
        address newPendingAdmin
    );

    event NewAdmin(
        address oldAdmin,
        address newAdmin
    );

    event NewComptroller(
        address oldComptroller,
        address newComptroller
    );

    event NewMarketInterestRateModel(
        address oldInterestRateModel,
        address newInterestRateModel
    );

    event NewReserveFactor(
        uint256 oldReserveFactorMantissa,
        uint256 newReserveFactorMantissa
    );

    event ReservesReduced(
        address admin,
        uint256 reduceAmount,
        uint256 newTotalReserves
    );

    event Failure(
        uint256 error,
        uint256 info,
        uint256 detail
    );

    event Transfer(
        address from,
        address to,
        uint256 amount
    );

    event Approval(
        address owner,
        address spender,
        uint256 amount
    );

}

// File: contracts/CompoundAllocationStrategy.sol

pragma solidity ^0.5.8;





contract CompoundAllocationStrategy is IAllocationStrategy, Ownable {

    CErc20Interface private cToken;
    IERC20 private token;

    constructor(CErc20Interface cToken_) public {
        cToken = cToken_;
        token = IERC20(cToken.underlying());
    }

    /// @dev ISavingStrategy.underlying implementation
    function underlying() external view returns (address) {
        return cToken.underlying();
    }

    /// @dev ISavingStrategy.exchangeRateStored implementation
    function exchangeRateStored() external view returns (uint256) {
        return cToken.exchangeRateStored();
    }

    /// @dev ISavingStrategy.accrueInterest implementation
    function accrueInterest() external returns (bool) {
        return cToken.accrueInterest() == 0;
    }

    /// @dev ISavingStrategy.investUnderlying implementation
    function investUnderlying(uint256 investAmount) external onlyOwner returns (uint256) {
        token.transferFrom(msg.sender, address(this), investAmount);
        token.approve(address(cToken), investAmount);
        uint256 cTotalBefore = cToken.totalSupply();
        // TODO should we handle mint failure?
        require(cToken.mint(investAmount) == 0, "mint failed");
        uint256 cTotalAfter = cToken.totalSupply();
        uint256 cCreatedAmount;
        if (cTotalAfter > cTotalBefore) {
            cCreatedAmount = cTotalAfter - cTotalBefore;
        } // else can there be case that we mint but we get less cTokens!?\
        return cCreatedAmount;
    }

    /// @dev ISavingStrategy.redeemUnderlying implementation
    function redeemUnderlying(uint256 redeemAmount) external onlyOwner returns (uint256) {
        uint256 cTotalBefore = cToken.totalSupply();
        // TODO should we handle redeem failure?
        require(cToken.redeemUnderlying(redeemAmount) == 0, "redeemUnderlying failed");
        uint256 cTotalAfter = cToken.totalSupply();
        uint256 cBurnedAmount;
        if (cTotalAfter < cTotalBefore) {
            cBurnedAmount = cTotalBefore - cTotalAfter;
        } // else can there be case that we end up with more cTokens ?!
        token.transfer(msg.sender, redeemAmount);
        return cBurnedAmount;
    }

}