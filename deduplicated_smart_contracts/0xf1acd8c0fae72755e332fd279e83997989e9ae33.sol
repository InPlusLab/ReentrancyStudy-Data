/**
 *Submitted for verification at Etherscan.io on 2021-07-17
*/

pragma solidity ^0.4.12;
 
/**
 *  IMigration operations with safety checks
 */
contract IMigrationContract {
    function migrate(address addr, uint256 nas) returns (bool success);
}
 

/**
 *  Math operations with safety checks
 */
contract SafeMath {
    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }
 
    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }
 
    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
 
}


/**
 *  Base Contract Definition
 */ 
contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
 
/**
 *  Standard Contract Definition
 */ 
contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
 
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
 
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
 

/**
 *  Target Contract Definition
 */ 
contract METToken is StandardToken, SafeMath {
 	//Base Info
    string  public constant name     = "MET.KEY";
    string  public constant symbol   = "MET.KEY";
    uint256 public constant decimals = 18;
    uint256 public currentSupply     = 0;          
    uint256 public tokenRaised       = 0;          
    uint256 public tokenMigrated     = 0;        
    uint256 public tokenExchangeRate = 1000; 
 
    //Base Contracts
    address public ethFundDeposit;         
    address public newContractAddr;        
 
    //Base Funding
    bool    public isFunding;            
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;
 
 
    //Base Events
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
	event Migrate(address indexed _to, uint256 _value);
	event IssueToken(address indexed _to, uint256 _value);   
    event AllocateToken(address indexed _to, uint256 _value);
 
 
    //Number Format
    function formatDecimals(uint256 _value) internal returns (uint256 ) {
        return _value * 10 ** decimals;
    }
 
    //MET Contract Constructor
    function METToken(address _ethFundDeposit, uint256 _currentSupply) {
        isFunding            = false; 
        fundingStartBlock    = 0;
        fundingStopBlock     = 0;
        ethFundDeposit       = _ethFundDeposit;
        currentSupply        = formatDecimals(_currentSupply);
        totalSupply          = formatDecimals(1000000000);
        balances[msg.sender] = totalSupply;
        if(currentSupply > totalSupply) throw;
    }
 
 	//Modifier to check if caller is owner
    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }
 
    //Reset Token Exchange Rate
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        if (_tokenExchangeRate == 0) throw;
        if (_tokenExchangeRate == tokenExchangeRate) throw;
        tokenExchangeRate = _tokenExchangeRate;
    }
 

    function increaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + currentSupply > totalSupply) throw;

        currentSupply = safeAdd(currentSupply, value);
        IncreaseSupply(value);
    }
 

    function decreaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + tokenRaised > currentSupply) throw;
 
        currentSupply = safeSubtract(currentSupply, value);
        DecreaseSupply(value);
    }
 
    //Starting Funding
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        if (isFunding) throw;
        if (_fundingStartBlock >= _fundingStopBlock) throw;
        if (block.number >= _fundingStartBlock) throw;
        
        isFunding         = true;
        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock  = _fundingStopBlock;
    }
 
    //Stopping Funding
    function stopFunding() isOwner external {
        if (!isFunding) throw;
        isFunding = false;
    }
 
    //Reset Contract
    function setMigrateContract(address _newContractAddr) isOwner external {
        if (_newContractAddr == newContractAddr) throw;
        newContractAddr = _newContractAddr;
    }
 
    //Rest Contract Owner
    function changeOwner(address _newFundDeposit) isOwner external {
        if (_newFundDeposit == address(0x0)) throw;
        ethFundDeposit = _newFundDeposit;
    }
 
    //Trasfer Token To New Contract
    function migrate() isOwner external {
        if(isFunding) throw;
        if(newContractAddr == address(0x0)) throw;
 
        uint256 tokens = balances[msg.sender];
        if (tokens == 0) throw;
 
        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);
 
        IMigrationContract newContract = IMigrationContract(newContractAddr);
        if (!newContract.migrate(msg.sender, tokens)) throw;
 
        Migrate(msg.sender, tokens); //Log It
    }
 
  
    function transferETH() isOwner external {
        if (this.balance == 0) throw;
        if (!ethFundDeposit.send(this.balance)) throw;
    }
 

    function allocateToken (address _addr, uint256 _eth) isOwner external {
        if (_eth == 0) throw;
        if (_addr == address(0x0)) throw;
 
        uint256 tokens = safeMult(formatDecimals(_eth), tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) throw;
 
        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[_addr] += tokens;
 
        AllocateToken(_addr, tokens); //Log It
    }
 

    function () payable {
        if (!isFunding) throw;
        if (msg.value == 0) throw;
 
        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingStopBlock) throw;
 
        uint256 tokens = safeMult(msg.value, tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) throw;
 
        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[msg.sender] += tokens;
 
        IssueToken(msg.sender, tokens); //Log It
    }
}