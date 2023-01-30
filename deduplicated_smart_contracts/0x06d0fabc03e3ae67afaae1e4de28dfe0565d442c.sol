/**

 *Submitted for verification at Etherscan.io on 2018-10-22

*/



pragma solidity ^0.4.24;

//____________________________________________________________________________________
//
//  Welcome to Sunlight,
//  Our token is fully ERC-20 compliant!
//____________________________________________________________________________________|



contract Sunlight
{


    address     owner = 0xc22193e4F0f220883A0bb2ba8A83Ff81D25c8623;


    string      public standard = 'Token 0.1';
    string      public name = 'Sunlight'; 
    string      public symbol = 'SNT';
    uint8       public decimals = 18; 
    uint256     public totalSupply = 10000000000000000000000;
    

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


    // Use it to get your real SNT balance
    // _______________________________________________________________________________
    function balanceOf(address _owner) public constant returns(uint256 tokens) 
    {

        return balances[_owner];
    }
    

    // Use it to transfer SNT to another address
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

    
    // Transfer allowed amount of SNT tokens from another address
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

    
    // Allow someone to transfer SNT tokens from your address
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