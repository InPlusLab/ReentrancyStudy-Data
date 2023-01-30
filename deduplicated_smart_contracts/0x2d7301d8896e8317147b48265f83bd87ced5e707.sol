/**
 *Submitted for verification at Etherscan.io on 2020-04-07
*/

pragma solidity ^0.5.16;


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20{
    function transfer(address recipient, uint256 amount) external returns (bool);
     function balanceOf(address account) public view returns (uint256);
}

contract Ownable is Context {
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
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
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

contract Treasury is Ownable{

 address public _hexLotto;
 address token;
 
 constructor () public {
        token = address(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39); //HEX token
        _hexLotto = address(0xFAA2919aC89975ca7FB2B8326e9393f56de5F28B);
    }

    function setHexLottoContract(address newHexLotto) external onlyOwner{
        require(newHexLotto != address(0), "HexLotto is the zero address");
        _hexLotto = newHexLotto;
    }

     /**
     * @dev Throws if called by any account other than the hex lotto contract.
     */
    modifier onlyHexLotto() {
        require(msg.sender == _hexLotto, "Caller is not the hex lotto contract");
        _;
    }

    /**
     * @dev Withdraw remaining treasury amount to another wallet
     */
    function withdraw(address to) external onlyOwner returns(bool) {
        require(ERC20(token).balanceOf(address(this)) > 0, "Balance is empty");
        require(to != address(0), "Can not withdraw to zero address");

        require(ERC20(token).transfer(to, ERC20(token).balanceOf(address(this))), "Withdrawal of treasury failed");
        return true;
    }

    /**
     * @dev Throws if called by any account other than the hex lotto contract.
     */
    function transfer(address to, uint256 amount) external onlyHexLotto returns(bool){ 
       require(ERC20(token).transfer(to, amount), "Transfer bonus amount failed");
       return true;
    }
}