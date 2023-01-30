/**
 *Submitted for verification at Etherscan.io on 2019-10-09
*/

pragma solidity ^0.5.1;

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
}

contract IERC223Recipient { 
    function tokenFallback(address _from, uint _value, bytes memory _data) public;
}

contract IERC223 {
    uint public totalSupply;
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public returns (bool success);
    function transfer(address to, uint value, bytes memory data) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC223Token is IERC223 {
    using SafeMath for uint;
    
    address private _owner;
    bool private _paused;
    
    event Paused();
    event Unpaused();

    mapping(address => uint) balances; // List of user balances.
    
    constructor () internal {
        _paused = false;
        _owner = msg.sender;
    }
    
    function transfer(address _to, uint _value, bytes memory _data) public whenNotPaused returns (bool success){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        if (_data.length == 0) emit Transfer(msg.sender, _to, _value);
        else emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    function transfer(address _to, uint _value) public whenNotPaused returns (bool success){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(isContract(_to)) {
            bytes memory empty = hex"00000000";
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function balanceOf(address owner) public view returns (uint balance) {
        return balances[owner];
    }
    
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }
    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }
    
    modifier whenPaused() {
        require(_paused);
        _;
    }
    
    function paused() public view returns(bool) {
        return _paused;
    }
    
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused();
    }
    
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused();
    }
}

contract ERC223Mintable is ERC223Token {
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    mapping (address => bool) public _minters;

    constructor () internal {
        _addMinter(msg.sender);
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

    function mint(uint256 amount) public onlyMinter whenNotPaused returns (bool) {
        totalSupply = totalSupply.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        emit Transfer(address(0x0), msg.sender, amount);
        return true;
    }
}

contract TestCash is ERC223Mintable {
    string public constant name = 'TestCash';
    string public constant symbol = 'TFF';
    uint8 public constant decimals = 18;
    
    constructor() public {
        totalSupply = 250000000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
}