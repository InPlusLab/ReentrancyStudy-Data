pragma solidity ^0.5.0;
import "./LinkedList.sol";

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes memory _data) public;
}


contract tfy{
    
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function name() public pure returns (string memory _name){
        _name = "TradeForYou";
    }
    
    function symbol() public pure returns (bytes32 _symbol){
        _symbol = "TFY";
    }
    
    function decimals() public pure returns (uint8 _decimals){
        _decimals = 8;
    }
    
    mapping (address => bool) public isOwner;
    uint private _quantidadeOwners = 0;
    LinkedList private _owners;
    
    mapping(address=>account) users;
    
    struct account{
        uint balance;
        uint headDividendos;
        uint[] dividendos;
    }

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    constructor() public{
        _totalSupply= 200000000* 10 ** uint(decimals());
        users[msg.sender].balance=_totalSupply;
        isOwner[msg.sender]=true;
        _quantidadeOwners++;
        _owners = new LinkedList(msg.sender);
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address owner) public view returns (uint256) {
        return users[owner].balance;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function transfer(address to, uint256 value) public returns (bool) {
        bytes memory empty;
        transfer(to, value, empty);
        return true;
    }
    function transfer(address to, uint256 value, bytes memory data) public returns (bool) {
        _transfer(msg.sender, to, value, data);
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        bytes memory empty;
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));
        _transfer(from, to, value, empty);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    function _transfer(address from, address to, uint256 value, bytes memory data) internal {
        uint codeLength;
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }
        require(to != address(0), "ERC20: transfer to the zero address");
        users[from].balance = users[from].balance.sub(value);
        users[to].balance = users[to].balance.add(value);
        emit Transfer(from, to, value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, data);
        }
    }
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    
    function getOwnersList() public view returns(address[] memory){
         return _owners.getList();
    }
    
    function addOwner(address _newOwner) public returns(bool){
        require(isOwner[msg.sender]);
        isOwner[_newOwner]=true;
        _quantidadeOwners++;
        _owners.add(_newOwner);
        return true;
    }
    function removeOwner(address _oldOwner) public returns(bool){
        require(isOwner[msg.sender]);
        require(_quantidadeOwners>1);
        isOwner[_oldOwner]=false;
        _quantidadeOwners--;
        _owners.remove(_oldOwner);
        return true;
    }
    
    function mintTokens(uint _toMint) public{
        require(isOwner[msg.sender]);
        users[msg.sender].balance+=_toMint;
        _totalSupply+=_toMint;
    }
    
}