/**
 *Submitted for verification at Etherscan.io on 2019-09-06
*/

pragma solidity ^0.5.11;

// Send more than 1 ETH for 1,001 Voken2¡£0, and get unused ETH refund automatically.
//   Use the current voken price of Voken Public-Sale.
//   Discount: 20% OFF.
//
// Conditions:
//   1. You have no Voken2.0 yet.
//   2. You are not in the whitelist yet.
//   3. Send more than 1 ETH (for balance verification).
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow checks.
 */
library SafeMath256 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


/**
 * @dev Interface of the ERC20 standard
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
contract Ownable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the addresses of the current and new owner.
     */
    function owner() public view returns (address currentOwner, address newOwner) {
        currentOwner = _owner;
        newOwner = _newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * IMPORTANT: Need to run {acceptOwnership} by the new owner.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _newOwner = newOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Accept ownership of the contract.
     *
     * Can only be called by the new owner.
     */
    function acceptOwnership() public {
        require(msg.sender == _newOwner, "Ownable: caller is not the new owner address");
        require(msg.sender != address(0), "Ownable: caller is the zero address");

        emit OwnershipAccepted(_owner, msg.sender);
        _owner = msg.sender;
        _newOwner = address(0);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * Can only be called by the current owner.
     */
    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(recipient != address(0), "Rescue: recipient is the zero address");
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount, "Rescue: amount exceeds balance");
        _token.transfer(recipient, amount);
    }

    /**
     * @dev Withdraw Ether
     *
     * Can only be called by the current owner.
     */
    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Withdraw: recipient is the zero address");

        uint256 balance = address(this).balance;

        require(balance >= amount, "Withdraw: amount exceeds balance");
        recipient.transfer(amount);
    }
}


/**
 * @title Voken2.0 interface.
 */
interface IVoken2 {
    function balanceOf(address owner) external view returns (uint256);
    function mint(address account, uint256 amount) external returns (bool);
    function whitelisted(address account) external view returns (bool);
}


/**
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    bool private _paused;

    event Paused();
    event Unpaused();


    /**
     * @dev Constructor
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @return Returns true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Paused");
        _;
    }

    /**
     * @dev Sets paused state.
     *
     * Can only be called by the current owner.
     */
    function setPaused(bool value) external onlyOwner {
        _paused = value;

        if (_paused) {
            emit Paused();
        } else {
            emit Unpaused();
        }
    }
}


/**
 * @title Voken2.0 public-sale interface.
 */
interface VokenPublicSale {
    function status() external view returns (uint16 stage,
                                             uint16 season,
                                             uint256 etherUsdPrice,
                                             uint256 vokenUsdPrice,
                                             uint256 shareholdersRatio);
}


/**
 * @title Get 1001 Voken2.0
 */
contract Get1001Voken2 is Ownable, Pausable {
    using SafeMath256 for uint256;

    // Addresses
    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);
    VokenPublicSale private _PUBLIC_SALE = VokenPublicSale(0xd4260e4Bfb354259F5e30279cb0D7F784Ea5f37A);

    uint256 private WEI_MIN = 1 ether;
    uint256 private VOKEN_PER_TX = 1001000000; // 1001.000000 Voken2.0

    uint256 private _txs;

    mapping (address => bool) _got;

    /**
     * @dev Returns the VOKEN main contract address.
     */
    function VOKEN() public view returns (IVoken2) {
        return _VOKEN;
    }

    /**
     * @dev Returns the VOKEN public-sale contract address.
     */
    function PUBLIC_SALE() public view returns (VokenPublicSale) {
        return _PUBLIC_SALE;
    }

    /**
     * @dev Transaction counter
     */
    function txs() public view returns (uint256) {
        return _txs;
    }

    /**
     * @dev Get 1001 Voken2.0 and ETH refund.
     */
    function () external payable whenNotPaused {
        require(msg.value >= WEI_MIN, "Get1001Voken2: sent less than 1 ether");
        require(!(_VOKEN.balanceOf(msg.sender) > 0), "Get1001Voken2: balance is greater than zero");
        require(!_VOKEN.whitelisted(msg.sender), "Get1001Voken2: already whitelisted");
        require(!_got[msg.sender], "Get1001Voken2: had got already");

        (, , uint256 __etherUsdPrice, uint256 __vokenUsdPrice, ) = _PUBLIC_SALE.status();
        __vokenUsdPrice = __vokenUsdPrice.mul(8).div(10);
        require(__etherUsdPrice > 0, "Voken2PublicSale2: empty ether price");

        uint256 __usd = VOKEN_PER_TX.mul(__vokenUsdPrice).div(1000000);
        uint256 __wei = __usd.mul(1 ether).div(__etherUsdPrice);

        require(msg.value >= __wei, "Get1001Voken2: ether is not enough");

        _txs = _txs.add(1);
        _got[msg.sender] = true;

        msg.sender.transfer(msg.value.sub(__wei));
        assert(_VOKEN.mint(msg.sender, VOKEN_PER_TX));
    }
}