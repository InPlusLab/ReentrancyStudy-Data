/**
 *Submitted for verification at Etherscan.io on 2020-07-16
*/

pragma solidity ^0.5.1;

contract IERC223 {
    uint public _totalSupply;

    function balanceOf(address who) public view returns (uint);

    function transfer(address to, uint value) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
}

contract IERC223Recipient {
    function tokenFallback(address _from, uint _value) public;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

contract FurqanTest is IERC223 {
    using SafeMath for uint;

    address public owner;
    bool public locked;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public maximumSupply;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    mapping(address => bool) public _minters;
    mapping(address => uint) balances;

    constructor() public {
        locked = false;
        symbol = "FRQN6";
        name = "FurqanTest6";
        decimals = 6;
        maximumSupply = 200000000000000;

        owner = msg.sender;
        _addMinter(msg.sender);
        mint(msg.sender, 40000000000000);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "OwnerRole: caller does not have the Owner role");
        _;
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(locked == false);
        require(balanceOf(msg.sender) > _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (Address.isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value);
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function isLocked() public view returns (bool) {
        return locked;
    }

    function applyLock() public onlyOwner {
        locked = true;
    }

    function unlock() public onlyOwner {
        locked = false;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters[account] = true;
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters[account] = false;
        emit MinterRemoved(account);
    }

    function mint(address account, uint256 amount) public onlyMinter returns (bool success) {
        uint newTotalSupply = _totalSupply.add(amount);
        require(newTotalSupply <= maximumSupply);
        _totalSupply = newTotalSupply;
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }

    function burn(uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        _totalSupply = _totalSupply.sub(_amount);
        emit Transfer(msg.sender, address(0), _amount);
    }
}