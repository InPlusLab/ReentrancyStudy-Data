/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

pragma solidity ^0.5.16;

/**
 * Math operations with safety checks
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ETH2Validator is Ownable{
    using SafeMath for uint;
    mapping (address => uint8) private _vipPowerMap;

    mapping (uint32  => address) private _userList;
    uint32 private _currentUserCount;

    event BuyPower(address indexed from, uint256 amount);
    event GovWithdraw(address indexed to, uint256 value);

    uint constant private basePrice = 1 ether;

    constructor()public {
    }

    function buyPower() public payable{
        uint8 addP = uint8(msg.value/ basePrice);
        uint8 oldP = _vipPowerMap[msg.sender];
        uint8 newP = oldP + addP;
        require(newP > 0, "vip level over min");
        require(newP <= 10, "vip level over max");
        require(addP* basePrice == msg.value, "1 to 10 ether only");
        
        if(oldP==0){
            _userList[_currentUserCount] = msg.sender;
            _currentUserCount++;
        }
        
        _vipPowerMap[msg.sender] = newP;
        emit BuyPower(msg.sender, msg.value);
    }

    function govWithdraw(uint256 _amount)onlyOwner public {
        require(_amount > 0, "!zero input");

        msg.sender.transfer(_amount);
        emit GovWithdraw(msg.sender, _amount);
    }

    function powerOf(address account) public view returns (uint) {
        return _vipPowerMap[account];
    }

    function currentUserCount() public view returns (uint32) {
        return _currentUserCount;
    }

    function userList(uint32 i) public view returns (address) {
        return _userList[i];
    }

}