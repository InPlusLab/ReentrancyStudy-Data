/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

pragma solidity ^0.5.11;

// Voken panel
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
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
 * @dev Interface of the ERC20 standard
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


/**
 * @dev Interface of Voken2.0
 */
interface IVoken2 {
    function totalSupply() external view returns (uint256);
    function whitelistingMode() external view returns (bool);
    function safeMode() external view returns (bool);
    function burningMode() external view returns (bool, uint16);
    function balanceOf(address account) external view returns (uint256);
    function reservedOf(address account) external view returns (uint256);
    function whitelisted(address account) external view returns (bool);
    function whitelistCounter() external view returns (uint256);
    function whitelistReferralsCount(address account) external view returns (uint256);
}


/**
 * @title Voken2 Panel
 */
contract Voken2Panel is Ownable {

    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);

    event Donate(address indexed account, uint256 amount);


    /**
     * @dev Donate
     */
    function () external payable {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    function voken2() public view returns (uint256 totalSupply,
                                           uint256 whitelistCounter,
                                           bool whitelistingMode,
                                           bool safeMode,
                                           bool burningMode) {
        totalSupply = _VOKEN.totalSupply();

        whitelistCounter = _VOKEN.whitelistCounter();
        whitelistingMode = _VOKEN.whitelistingMode();
        safeMode = _VOKEN.safeMode();
        (burningMode,) = _VOKEN.burningMode();
    }


    function accountVoken2(address account) public view returns (bool whitelisted,
                                                                 uint256 whitelistReferralsCount,
                                                                 uint256 balance,
                                                                 uint256 reserved) {
        whitelisted = _VOKEN.whitelisted(account);
        whitelistReferralsCount = _VOKEN.whitelistReferralsCount(account);
        balance = _VOKEN.balanceOf(account);
        reserved = _VOKEN.reservedOf(account);
    }
}