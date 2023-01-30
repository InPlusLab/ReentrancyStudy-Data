/**
 *Submitted for verification at Etherscan.io on 2019-11-01
*/

// File: contracts/equity/IERC20.sol

/**	
* MIT License	
*	
* Copyright (c) 2016-2019 zOS Global Limited	
*	
* Permission is hereby granted, free of charge, to any person obtaining a copy	
* of this software and associated documentation files (the "Software"), to deal	
* in the Software without restriction, including without limitation the rights	
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell	
* copies of the Software, and to permit persons to whom the Software is	
* furnished to do so, subject to the following conditions:	
*	
* The above copyright notice and this permission notice shall be included in all	
* copies or substantial portions of the Software.	
*	
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR	
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,	
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE	
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER	
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,	
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE	
* SOFTWARE.	
*/

pragma solidity 0.5.10;

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/dispenser/ShareDispenser.sol

/**
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2019 Equility AG (alethena.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;




/**
 * @title Alethena Share Dispenser for Draggable ServiceHunter Shares (DSHS)
 * @author Benjamin Rickenbacher, benjamin@alethena.com
 * @dev This contract uses the open-zeppelin library.
 *
 * This smart contract is intended to serve as a tool that ServiceHunter AG can use to
 * provide liquidity for their DSHS.
 *
 * The currency used for payment is the Crypto Franc XCHF (https://www.swisscryptotokens.ch/)
 * which makes it possible to quote DSHS prices directly in Swiss Francs.
 *
 * ServiceHunter AG can allocate a certain number of DSHS and (optionally) also some XCHF
 * to the Share Dispenser and defines a linear price dependency.
 **/

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function totalShares() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
}


contract ShareDispenser is Ownable, Pausable {
    constructor(
        address initialXCHFContractAddress,
        address initialDSHSContractAddress,
        address initialusageFeeAddress,
        address initialBackendAddress
        ) public {

        require(initialXCHFContractAddress != address(0), "XCHF does not reside at address 0!");
        require(initialDSHSContractAddress != address(0), "DSHS does not reside at address 0!");
        require(initialusageFeeAddress != address(0), "Usage fee address cannot be 0!");

        XCHFContractAddress = initialXCHFContractAddress;
        DSHSContractAddress = initialDSHSContractAddress;
        usageFeeAddress = initialusageFeeAddress;
        backendAddress = initialBackendAddress;
    }

    /*
     * Fallback function to prevent accidentally sending Ether to the contract
     * It is still possible to force Ether into the contract as this cannot be prevented fully.
     * Sending Ether to this contract does not create any problems for the contract, but the Ether will be lost.
    */

    function () external payable {
        revert("This contract does not accept Ether.");
    }

    using SafeMath for uint256;

    // Variables

    address public XCHFContractAddress;     // Address where XCHF is deployed
    address public DSHSContractAddress;     // Address where DSHS is deployed
    address public usageFeeAddress;         // Address where usage fee is collected
    address public backendAddress;          // Address used by backend server (triggers buy/sell)

    uint256 public usageFeeBSP  = 0;       // 0.9% usage fee (10000 basis points = 100%)
    uint256 public minVolume = 1;          // Minimum number of shares to buy/sell

    uint256 public minPriceInXCHF = 200*10**18; // Minimum price
    uint256 public maxPriceInXCHF = 600*10**18; // Maximum price
    uint256 public initialNumberOfShares = 400; //Price slope (TBD)

    bool public buyEnabled = true;
    bool public sellEnabled = true;

    // Events

    event XCHFContractAddressSet(address newXCHFContractAddress);
    event DSHSContractAddressSet(address newDSHSContractAddress);
    event UsageFeeAddressSet(address newUsageFeeAddress);

    event SharesPurchased(address indexed buyer, uint256 amount, uint256 price, uint256 nextPrice);
    event SharesSold(address indexed seller, uint256 amount, uint256 buyBackPrice, uint256 nextPrice);

    event TokensRetrieved(address contractAddress, address indexed to, uint256 amount);

    event UsageFeeSet(uint256 usageFee);
    event MinVolumeSet(uint256 minVolume);
    event MinPriceSet(uint256 minPrice);
    event MaxPriceSet(uint256 maxPrice);
    event InitialNumberOfSharesSet(uint256 initialNumberOfShares);

    event BuyStatusChanged(bool newStatus);
    event SellStatusChanged(bool newStatus);


    // Function for buying shares

    function buyShares(address buyer, uint256 numberOfSharesToBuy) public whenNotPaused() returns (bool) {

        // Check that buying is enabled
        require(buyEnabled, "Buying is currenty disabled");
        require(numberOfSharesToBuy >= minVolume, "Volume too low");

        // Check user is allowed to trigger buy
        require(msg.sender == buyer || msg.sender == backendAddress, "You do not have permission to trigger buying shares for someone else.");

        // Fetch the price (excluding the usage fee)
        uint256 sharesAvailable = getERC20Balance(DSHSContractAddress);
        uint256 price = getCumulatedPrice(numberOfSharesToBuy, sharesAvailable);

        // Check that there are enough shares available
        require(sharesAvailable >= numberOfSharesToBuy, "Not enough shares available");

       // Compute usage fee
        uint256 usageFee = price.mul(usageFeeBSP).div(10000);

        // Check that allowance is set XCHF balance is sufficient to cover price + usage fee
        require(getERC20Available(XCHFContractAddress, buyer) >= price.add(usageFee), "Payment not authorized or funds insufficient");

        // Instantiate contracts
        ERC20 DSHS = ERC20(DSHSContractAddress);
        ERC20 XCHF = ERC20(XCHFContractAddress);

        // Transfer usage fee and total price
        require(XCHF.transferFrom(buyer, usageFeeAddress, usageFee), "Usage fee transfer failed");
        require(XCHF.transferFrom(buyer, address(this), price), "XCHF payment failed");

        // Transfer the shares
        require(DSHS.transfer(buyer, numberOfSharesToBuy), "Share transfer failed");
        uint256 nextPrice = getCumulatedPrice(1, sharesAvailable.sub(numberOfSharesToBuy));
        emit SharesPurchased(buyer, numberOfSharesToBuy, price, nextPrice);
        return true;
    }

    // Function for selling shares

    function sellShares(address seller, uint256 numberOfSharesToSell, uint256 limitInXCHF) public whenNotPaused() returns (bool) {

        // Check that selling is enabled
        require(sellEnabled, "Selling is currenty disabled");
        require(numberOfSharesToSell >= minVolume, "Volume too low");

        // Check user is allowed to trigger sale;
        require(msg.sender == seller || msg.sender == backendAddress, "You do not have permission to trigger selling shares for someone else.");

        uint256 XCHFAvailable = getERC20Balance(XCHFContractAddress);
        uint256 sharesAvailable = getERC20Balance(DSHSContractAddress);

        // The full price. The usage fee is deducted from this to obtain the seller's payout
        uint256 price = getCumulatedBuyBackPrice(numberOfSharesToSell, sharesAvailable);
        require(limitInXCHF <= price, "Price too low");

        // Check that XCHF reserve is sufficient
        require(XCHFAvailable >= price, "Reserves to small to buy back this amount of shares");

        // Check that seller has sufficient shares and allowance is set
        require(getERC20Available(DSHSContractAddress, seller) >= numberOfSharesToSell, "Seller doesn't have enough shares");

        // Instantiate contracts
        ERC20 DSHS = ERC20(DSHSContractAddress);
        ERC20 XCHF = ERC20(XCHFContractAddress);

        // Transfer the shares
        require(DSHS.transferFrom(seller, address(this), numberOfSharesToSell), "Share transfer failed");

        // Compute usage fee
        uint256 usageFee = price.mul(usageFeeBSP).div(10000);

        // Transfer usage fee and buyback price
        require(XCHF.transfer(usageFeeAddress, usageFee), "Usage fee transfer failed");
        require(XCHF.transfer(seller, price.sub(usageFee)), "XCHF payment failed");
        uint256 nextPrice = getCumulatedBuyBackPrice(1, sharesAvailable.add(numberOfSharesToSell));
        emit SharesSold(seller, numberOfSharesToSell, price, nextPrice);
        return true;
    }

    // Getters for ERC20 balances (for convenience)

    function getERC20Balance(address contractAddress) public view returns (uint256) {
        ERC20 contractInstance = ERC20(contractAddress);
        return contractInstance.balanceOf(address(this));
    }

    function getERC20Available(address contractAddress, address owner) public view returns (uint256) {
        ERC20 contractInstance = ERC20(contractAddress);
        uint256 allowed = contractInstance.allowance(owner, address(this));
        uint256 bal = contractInstance.balanceOf(owner);
        return (allowed <= bal) ? allowed : bal;
    }

    // Price getters

    function getCumulatedPrice(uint256 amount, uint256 supply) public view returns (uint256) {
        uint256 cumulatedPrice = 0;
        if (supply <= initialNumberOfShares) {
            uint256 first = initialNumberOfShares.add(1).sub(supply);
            uint256 last = first.add(amount).sub(1);
            cumulatedPrice = helper(first, last);
        } else if (supply.sub(amount) >= initialNumberOfShares) {
            cumulatedPrice = minPriceInXCHF.mul(amount);
        } else {
            cumulatedPrice = supply.sub(initialNumberOfShares).mul(minPriceInXCHF);
            uint256 first = 1;
            uint256 last = amount.sub(supply.sub(initialNumberOfShares));
            cumulatedPrice = cumulatedPrice.add(helper(first,last));
        }

        return cumulatedPrice;
    }

    function getCumulatedBuyBackPrice(uint256 amount, uint256 supply) public view returns (uint256) {
        return getCumulatedPrice(amount, supply.add(amount)); // For symmetry reasons
    }

    // Function to retrieve DSHS or XCHF from contract
    // This can also be used to retrieve any other ERC-20 token sent to the smart contract by accident

    function retrieveERC20(address contractAddress, address to, uint256 amount) public onlyOwner() returns(bool) {
        ERC20 contractInstance = ERC20(contractAddress);
        require(contractInstance.transfer(to, amount), "Transfer failed");
        emit TokensRetrieved(contractAddress, to, amount);
        return true;
    }

    // Setters for addresses

    function setXCHFContractAddress(address newXCHFContractAddress) public onlyOwner() {
        require(newXCHFContractAddress != address(0), "XCHF does not reside at address 0");
        XCHFContractAddress = newXCHFContractAddress;
        emit XCHFContractAddressSet(XCHFContractAddress);
    }

    function setDSHSContractAddress(address newDSHSContractAddress) public onlyOwner() {
        require(newDSHSContractAddress != address(0), "DSHS does not reside at address 0");
        DSHSContractAddress = newDSHSContractAddress;
        emit DSHSContractAddressSet(DSHSContractAddress);
    }

    function setUsageFeeAddress(address newUsageFeeAddress) public onlyOwner() {
        require(newUsageFeeAddress != address(0), "DSHS does not reside at address 0");
        usageFeeAddress = newUsageFeeAddress;
        emit UsageFeeAddressSet(usageFeeAddress);
    }

    function setBackendAddress(address newBackendAddress) public onlyOwner() {
        backendAddress = newBackendAddress;
    }

    // Setters for constants

    function setUsageFee(uint256 newUsageFeeInBSP) public onlyOwner() {
        require(newUsageFeeInBSP <= 10000, "Usage fee must be given in basis points");
        usageFeeBSP = newUsageFeeInBSP;
        emit UsageFeeSet(usageFeeBSP);
    }

    function setMinVolume(uint256 newMinVolume) public onlyOwner() {
        require(newMinVolume > 0, "Minimum volume can't be zero");
        minVolume = newMinVolume;
        emit MinVolumeSet(minVolume);
    }

    function setminPriceInXCHF(uint256 newMinPriceInRappen) public onlyOwner() {
        require(newMinPriceInRappen > 0, "Price must be positive number");
        minPriceInXCHF = newMinPriceInRappen.mul(10**16);
        require(minPriceInXCHF <= maxPriceInXCHF, "Minimum price cannot exceed maximum price");
        emit MinPriceSet(minPriceInXCHF);
    }

    function setmaxPriceInXCHF(uint256 newMaxPriceInRappen) public onlyOwner() {
        require(newMaxPriceInRappen > 0, "Price must be positive number");
        maxPriceInXCHF = newMaxPriceInRappen.mul(10**16);
        require(minPriceInXCHF <= maxPriceInXCHF, "Minimum price cannot exceed maximum price");
        emit MaxPriceSet(maxPriceInXCHF);
    }

    function setInitialNumberOfShares(uint256 newInitialNumberOfShares) public onlyOwner() {
        require(newInitialNumberOfShares > 0, "Initial number of shares must be positive");
        initialNumberOfShares = newInitialNumberOfShares;
        emit InitialNumberOfSharesSet(initialNumberOfShares);
    }

    // Enable buy and sell separately

    function buyStatus(bool newStatus) public onlyOwner() {
        buyEnabled = newStatus;
        emit BuyStatusChanged(newStatus);
    }

    function sellStatus(bool newStatus) public onlyOwner() {
        sellEnabled = newStatus;
        emit SellStatusChanged(newStatus);
    }

    // Helper functions

    function helper(uint256 first, uint256 last) internal view returns (uint256) {
        uint256 tempa = last.sub(first).add(1).mul(minPriceInXCHF);                                   // (l-m+1)*p_min
        uint256 tempb = maxPriceInXCHF.sub(minPriceInXCHF).div(initialNumberOfShares.sub(1)).div(2);  // (p_max-p_min)/(2(N-1))
        uint256 tempc = last.mul(last).add(first.mul(3)).sub(last).sub(first.mul(first)).sub(2);      // l*l+3*m-l-m*m-2)
        return tempb.mul(tempc).add(tempa);
    }

}

// File: contracts/uniswap/UniswapExchangeInterface.sol

pragma solidity 0.5.10;

contract UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

// File: contracts/DispenserAdapter.sol

/**
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2019 Equility AG (alethena.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/




/**
 * @title Dispenser Adapter
 * @author Benjamin Rickenbacher, benjamin@alethena.com
 *
 * This contract serves as a bridge between the Alethena Share Dispenser and Uniswap (https://uniswap.io/).
 * By calling the function 'buySharesWithEther', users can pay for shares directly in native Ether.
 * The adapter then calls the Uniswap Crypto Francs (XCHF) instance to swap the Ether amount for XCHF.
 * This way, the user never needs to know about XCHF and the Share Dispenser never directly has to accept Ether.
 * In principle, this process could fail (e.g. if the price in Uniswap slips due to another transaction). In this case
 * the transaction would fail entirely but the gas used up to that point would be lost.
 */

pragma solidity 0.5.10;

contract DispenserAdapter {

    IERC20 private currency;
    IERC20 private tradedToken;
    ShareDispenser private dispenser;
    UniswapExchangeInterface private uniswap;

    constructor(address currencyAddress, address tradedTokenAddress, address payable dispenserAddress, address uniswapAddress) public {
        currency = IERC20(currencyAddress);
        tradedToken = IERC20(tradedTokenAddress);
        dispenser = ShareDispenser(dispenserAddress);
        uniswap = UniswapExchangeInterface(uniswapAddress);
    }

    function getBuyPriceInXCHF(uint256 numberToBuy) public view returns (uint256) {
        uint256 supply = tradedToken.balanceOf(address(dispenser));
        uint256 priceInXCHF = dispenser.getCumulatedPrice(numberToBuy, supply);
        return priceInXCHF;
    }

    function getBuyPriceInWei(uint256 numberToBuy) public view returns (uint256) {
        uint256 priceInXCHF = getBuyPriceInXCHF(numberToBuy);
        uint256 priceInEther = uniswap.getEthToTokenOutputPrice(priceInXCHF);
        return priceInEther;
    }

    function buySharesWithEther(uint256 numberToBuy) public payable returns (bool) {
        uint256 priceInXCHF = getBuyPriceInXCHF(numberToBuy);
        uint256 priceInEther = uniswap.getEthToTokenOutputPrice(priceInXCHF);
        require(msg.value >= priceInEther, "Insufficient Ether");
        require(uniswap.ethToTokenSwapOutput.value(priceInEther)(priceInXCHF, block.timestamp) >= priceInEther, "Swap at Uniswap failed");
        require(currency.approve(address(dispenser), priceInXCHF), "Allowance failed");
        require(dispenser.buyShares(address(this), numberToBuy), "Dispenser transaction failed");
        require(tradedToken.transfer(msg.sender, numberToBuy), "Token transfer failed");
        uint256 contractEtherBalance = address(this).balance;
        msg.sender.transfer(contractEtherBalance);
        return true;
    }

}