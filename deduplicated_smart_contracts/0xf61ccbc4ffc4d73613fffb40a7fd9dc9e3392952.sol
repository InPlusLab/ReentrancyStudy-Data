/**
 *Submitted for verification at Etherscan.io on 2019-10-28
*/

pragma solidity ^0.5.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SymmaGold is IERC20 {
    
    using SafeMath for uint256;

    address public owner;
    
    modifier Ownable {
        require(owner == msg.sender);
        _;
    }

    event Transfer( address indexed _from, address indexed _to, uint256 _value );
    event Approval( address indexed _tokenOwner, address indexed _spender, uint256 _tokens);

    string public name = "SYMMA GOLD";
    string public symbol = "SYMG";
    string public standard = "SYMG Token v1.0";
    uint8 public decimals = 7;
    uint256 _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(uint256 totalSupply) public {
        owner = msg.sender;
        _totalSupply = totalSupply * 10 ** uint(decimals);
        balances[msg.sender] = _totalSupply;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view returns(uint256){
        return balances[_address];
    }
    
    function transfer(address _receiver, uint256 _symmaValue) public returns(bool){
        require(_symmaValue <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_symmaValue);
        balances[_receiver] = balances[_receiver].add(_symmaValue);
        emit Transfer(msg.sender, _receiver, _symmaValue);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }
    
    function transferFrom(address _from, address _to, uint256 _symmaValue) public returns (bool){
        require(_symmaValue <= balances[_from]);
        require(_symmaValue <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_symmaValue);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_symmaValue);
        balances[_to] = balances[_to].add(_symmaValue);
        emit Transfer(_from, _to, _symmaValue);
        return true;
    }

    function approve(address _spender, uint256 _symmaValue) public returns (bool){
        allowed[msg.sender][_spender] = _symmaValue;
        emit Approval(msg.sender, _spender, _symmaValue);
        return true;
    }
    
    function increaseSupply(uint256 _supply) public Ownable returns (bool) {
        _totalSupply = _totalSupply.add(_supply * 10 ** uint(decimals));
        balances[msg.sender] = _totalSupply;
        return true;
    }
}