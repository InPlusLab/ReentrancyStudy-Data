pragma solidity ^0.4.16;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
    address public owner;

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
        owner = msg.sender;
    }
    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));      
        owner = newOwner;
    }

}

contract TestCrypteriumToken is Ownable {
    
    uint256 public totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    string public constant name = "TestCrypteriumToken";
    string public constant symbol = "TCRPT";
    uint32 public constant decimals = 18;

    uint constant restrictedPercent = 30; //should never be set above 100
    address constant restricted = 0x40bA941094e6E74ECa3eE804C65eD0c48524842C;
    uint constant start = 1509458400;
    uint constant period = 87;
    uint256 public constant hardcap = 300000000 * 1 ether;
    
    bool public transferAllowed = false;
    bool public mintingFinished = false;
    
    modifier whenTransferAllowed() {
        if(msg.sender != owner){
            require(transferAllowed);
        }
        _;
    }

    modifier saleIsOn() {
        require(now > start && now < start + period * 1 days);
        _;
    }
    
    modifier canMint() {
        require(!mintingFinished);
        _;
    }
  
    function transfer(address _to, uint256 _value) whenTransferAllowed public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        assert(balances[_to] >= _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transferFrom(address _from, address _to, uint256 _value) whenTransferAllowed public  returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        assert(balances[_to] >= _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
    
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
   
    function allowTransfer() onlyOwner public {
        transferAllowed = true;
    }
  
    function mint(address _to, uint256 _value) onlyOwner saleIsOn canMint public returns (bool) {
        require(_to != address(0));
        
        uint restrictedTokens = _value * restrictedPercent / (100 - restrictedPercent);
        uint _amount = _value + restrictedTokens;
        assert(_amount >= _value);
        
        if(_amount + totalSupply <= hardcap){
        
            totalSupply = totalSupply + _amount;
            
            assert(totalSupply >= _amount);
            
            balances[msg.sender] = balances[msg.sender] + _amount;
            assert(balances[msg.sender] >= _amount);
            Mint(msg.sender, _amount);
        
            transfer(_to, _value);
            transfer(restricted, restrictedTokens);
        }
        return true;
    }

    function finishMinting() onlyOwner public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
    
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender&#39;s balance is greater than the totalSupply, which *should* be an assertion failure
        balances[msg.sender] = balances[msg.sender] - _value;
        totalSupply = totalSupply - _value;
        Burn(msg.sender, _value);
        return true;
    }
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from]);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] = balances[_from] - _value;                         // Subtract from the targeted balance
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;             // Subtract from the sender&#39;s allowance
        totalSupply = totalSupply - _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    event Burn(address indexed burner, uint256 value);

}