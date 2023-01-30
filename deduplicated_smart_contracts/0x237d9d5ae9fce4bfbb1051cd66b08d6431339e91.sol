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

    string public symbol;
    string public name;
    uint8 public decimals;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    mapping(address => bool) public _minters;
    mapping(address => uint) balances;

    constructor() public {
        symbol = "FRQN5";
        name = "FurqanTest5";
        decimals = 6;
        _addMinter(msg.sender);
        mint(msg.sender, 30000000000000);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (Address.isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value);
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
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
        _totalSupply = _totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }

    function burn(uint256 _amount) public {
        require(balanceOf(msg.sender) > _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }
}