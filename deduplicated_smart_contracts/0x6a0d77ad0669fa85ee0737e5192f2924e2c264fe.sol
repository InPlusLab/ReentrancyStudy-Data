/**

 *Submitted for verification at Etherscan.io on 2018-11-04

*/



pragma solidity ^0.4.24;

//____________________________________________________________________________________
//
//  Welcome to Diagonal Blast,
//  Our token is fully ERC-20 compliant!
//____________________________________________________________________________________|



contract DiagonalBlast
{


    address     owner = 0x54d296ef087Db7b6feB2a7f64dce78bFade73Fad;


    string      public standard = 'Token 0.1';
    string      public name = 'Diagonal Blast'; 
    string      public symbol = 'DBL';
    uint8       public decimals = 2; 
    uint256     public totalSupply = 1502058000;
    

    mapping (address => uint256) balances;  
    mapping (address => mapping (address => uint256)) allowed;


    modifier ownerOnly() 
    {
        require(msg.sender == owner);
        _;
    }       


    // We might change the token name only in case of emergency
    // _______________________________________________________________________________
    function changeName(string _name) public ownerOnly returns(bool success) 
    {

        name = _name;
        emit NameChange(name);

        return true;
    }


    // We might change the token symbol only in case of emergency
    // _______________________________________________________________________________
    function changeSymbol(string _symbol) public ownerOnly returns(bool success) 
    {

        symbol = _symbol;
        emit SymbolChange(symbol);

        return true;
    }


    // In case we would like to change our wallet.
    // _______________________________________________________________________________
    function changeOwner(address _owner) public ownerOnly returns(bool success) 
    {

        require (_owner != 0x0);


        owner = _owner;
        emit OwnerChange(owner);

        return true;
    }


    // Use it to get your real DBL balance
    // _______________________________________________________________________________
    function balanceOf(address _owner) public constant returns(uint256 tokens) 
    {

        return balances[_owner];
    }
    

    // Use it to transfer DBL to another address
    // _______________________________________________________________________________
    function transfer(address _to, uint256 _value) public returns(bool success)
    { 

        require(_value > 0 && balances[msg.sender] >= _value);


        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        return true;
    }


    // How much someone allows you to transfer from his/her address
    // _______________________________________________________________________________
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

    
    // Transfer allowed amount of DBL tokens from another address
    // _______________________________________________________________________________
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

    
    // Allow someone to transfer DBL tokens from your address
    // _______________________________________________________________________________
    function approve(address _spender, uint256 _value) public returns(bool success)  
    {

        require(_spender != 0x0 && _spender != msg.sender);


        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }


    // Token constructor
    // _______________________________________________________________________________
    constructor() public
    {
        balances[owner] = totalSupply;
        emit TokenDeployed(totalSupply);
        emit Transfer(owner, owner, totalSupply);
    }


    // ===============================================================================
    //
    // List of all events

    event NameChange(string _name);
    event SymbolChange(string _symbol);
    event OwnerChange(address indexed _owner);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event TokenDeployed(uint256 _totalSupply);

}