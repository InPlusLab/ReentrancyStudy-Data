pragma solidity 0.4.24;

import "./TokenInterface.sol";
contract SR_Coin is TokenInterface {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public token_balances;
    mapping (address => mapping (address => uint256)) public allowed;

    string public token_name;                   
    uint8 public decimalUnits;                
    string public token_symbol;                 
    address public token_owner;
    uint256 public token_price;
    uint256 public token_current_batch_sold;    

    function SR_Coin(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        uint256 _price,
        uint256 _batch_sold
    ) public {
        token_balances[msg.sender] = _initialAmount;               
        totalSupply = _initialAmount;                        
        token_name = _tokenName;                                   
        decimalUnits = _decimalUnits;                            
        token_symbol = _tokenSymbol;                               
        token_owner = msg.sender;   
        token_price = _price;
        token_current_batch_sold = _batch_sold;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(token_balances[msg.sender] >= _value);
        token_balances[msg.sender] -= _value;
        token_balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[token_owner][_from];
        require(token_balances[_from] >= _value && allowance >= _value);
        token_balances[_to] += _value;
        token_balances[_from] -= _value;
        allowed[token_owner][_from] -= _value;
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return token_balances[_owner];
    }
    
    function get_price() public constant returns (uint256 result){
        return token_price;
    }
    
    function tokenBalanceOf(address _owner) public constant returns (uint256 balance) {
        return token_balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
}