/**
 *Submitted for verification at Etherscan.io on 2019-09-07
*/

pragma solidity ^0.4.17;
contract Token{
    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns
    (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns
    (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256
    _value);
}
contract  CCG is Token {

    string public name;
    uint8 public decimals;
    string public symbol;
    /*@CTK "CCG constructor"
      @tag assume_completion
      @post __post.totalSupply == _initialAmount * 10 ** uint256(_decimalUnits)
      @post __post.balances[msg.sender] == __post.totalSupply
      @post __post.name == _tokenName
      @post __post.decimals == _decimalUnits
      @post __post.symbol == _tokenSymbol
    */
    function CCG (uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) public {
        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits);
        balances[msg.sender] = totalSupply;

        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }
    //@CTK NO_OVERFLOW
    //@CTK NO_BUF_OVERFLOW
    //@CTK NO_ASF
    /*@CTK transfer
      @tag assume_completion
      @post balances[msg.sender] >= _value /\ balances[_to] + _value > balances[_to]
      @post _to != 0x0
      @post msg.sender != _to -> __post.balances[_to] == balances[_to] + _value
      @post msg.sender != _to -> __post.balances[msg.sender] == balances[msg.sender] - _value
      @post msg.sender == _to -> __post.balances[_to] == balances[_to]
      @post msg.sender == _to -> __post.balances[msg.sender] == balances[msg.sender]
      @post success
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {


        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != 0x0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    //@CTK NO_BUF_OVERFLOW
    //@CTK NO_ASF
    /*@CTK transferFrom
      @tag assume_completion
      @post balances[_from] >= _value /\ allowed[_from][msg.sender] >= _value
      @post _to != _from -> __post.balances[_from] == balances[_from] - _value
      @post _to != _from -> __post.balances[_to] == balances[_to] + _value
      @post _to == _from -> __post.balances[_from] == balances[_from]
      @post __post.allowed[_from][msg.sender] == allowed[_from][msg.sender] - _value
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns
    (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
    //@CTK NO_OVERFLOW
    //@CTK NO_BUF_OVERFLOW
    //@CTK NO_ASF
    /*@CTK balanceOf
      @post __reverted == false
      @post balance == balances[_owner]
      @post this == __post
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    //@CTK NO_OVERFLOW
    //@CTK NO_BUF_OVERFLOW
    //@CTK NO_ASF
    /*@CTK approve
      @tag assume_completion
      @post _value == 0 \/ allowed[msg.sender][_spender] == 0
      @post __post.allowed[msg.sender][_spender] == _value
     */
    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    //@CTK NO_OVERFLOW
    //@CTK NO_BUF_OVERFLOW
    //@CTK NO_ASF
    /*@CTK allowance
      @post __reverted == false
      @post remaining == allowed[_owner][_spender]
      @post this == __post
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}