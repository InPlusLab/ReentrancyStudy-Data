/**

 *Submitted for verification at Etherscan.io on 2018-10-03

*/



pragma solidity ^0.4.24;

//____________________________________________________________________________________
//
//  Welcome to Steganograph!
//____________________________________________________________________________________|



contract Steganograph
{


    address     owner = 0x12C3Fd99ab45Bd806128E96062dc5A6C273d8AF6;


    string      public standard = 'Token 0.1';
    string      public name = 'Steganograph'; 
    string      public symbol = 'PHY';
    uint8       public decimals = 3; 
    uint256     public totalSupply = 1168000000000;
    

    mapping (address => uint256) balances;  
    mapping (address => mapping (address => uint256)) allowed;


    modifier ownerOnly() 
    {
        require(msg.sender == owner);
        _;
    }       


    // We might change the token name only in case of emergency
    // ____________________________________________________________________________________
    function changeName(string _name) public ownerOnly returns(bool success) 
    {

        name = _name;
        emit NameChange(name);

        return true;
    }


    // We might change the token symbol only in case of emergency
    // ____________________________________________________________________________________
    function changeSymbol(string _symbol) public ownerOnly returns(bool success) 
    {

        symbol = _symbol;
        emit SymbolChange(symbol);

        return true;
    }


    // Use it to get your real PHY balance
    // ____________________________________________________________________________________
    function balanceOf(address _owner) public constant returns(uint256 tokens) 
    {

        return balances[_owner];
    }
    

    // Use it to transfer PHY to another address
    // ____________________________________________________________________________________
    function transfer(address _to, uint256 _value) public returns(bool success)
    { 

        require(_value > 0 && balances[msg.sender] >= _value);


        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        return true;
    }


    // How much someone allows you to transfer from his/her address
    // ____________________________________________________________________________________
    function canTransferFrom(address _owner, address _spender) public constant returns(uint256 tokens) 
    {

        require(_owner != 0x0 && _spender != 0x0);
        

        if (_owner == _spender)
        {
            return balances[_owner];
        }
        else 
        {
            return allowed[_owner][_spender];
        }
    }

    
    // Transfer allowed amount of PHY tokens from another address
    // ____________________________________________________________________________________
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) 
    {

        require(_value > 0 && _from != 0x0 &&
                allowed[_from][msg.sender] >= _value && 
                balances[_from] >= _value);
                

        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;    
        emit Transfer(_from, _to, _value);

        return true;
    }

    
    // Allow someone transfer PHY tokens from your address
    // ____________________________________________________________________________________
    function approve(address _spender, uint256 _value) public returns(bool success)  
    {

        require(_spender != 0x0 && _spender != msg.sender);


        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }


    // Token constructor
    // ____________________________________________________________________________________
    constructor() public
    {
        owner = msg.sender;
        balances[owner] = totalSupply;
        emit TokenDeployed(totalSupply);
    }


    // ====================================================================================
    //
    // List of all events

    event NameChange(string _name);
    event SymbolChange(string _symbol);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event TokenDeployed(uint256 _totalSupply);

}