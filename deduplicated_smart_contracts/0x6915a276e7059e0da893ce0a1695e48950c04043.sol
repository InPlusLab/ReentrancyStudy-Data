/**

 *Submitted for verification at Etherscan.io on 2018-12-28

*/



pragma solidity >=0.4.22 <0.6.0;



contract IMigrationContract {

    function migrate(address addr, uint256 nas) public returns (bool success);

}



contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {

        uint256 z = x + y;

        assert((z >= x) && (z >= y));

        return z;

    }



    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {

        assert(x >= y);

        uint256 z = x - y;

        return z;

    }



    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {

        uint256 z = x * y;

        assert((x == 0)||(z/x == y));

        return z;

    }

}



contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



/// ERC 20 token

contract StandardToken is Token {



    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            emit Transfer(msg.sender, _to, _value);

            return true;

        } else {

            return false;

        }

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            emit Transfer(_from, _to, _value);

            return true;

        } else {

            return false;

        }

    }



    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract BitriceToken is StandardToken, SafeMath {



    // metadata

    string  public constant name = "Bitrice";

    string  public constant symbol = "BTR";

    uint256 public constant decimals = 18;

    uint256 public constant total = 2100 * (10 ** 6); // two billion one hundred million

    string  public version = "1.0";



    // contracts

    address public ethFundDeposit;              // deposit address for ETH for BTR team

    address public newContractAddr;



    // crowdsale parameters

    bool    public isFunding;                   // allow coin transfers

    uint256 public fundingStartBlock;

    uint256 public fundingStopBlock;



    uint256 public currentSupply;               // total selling tokens

    uint256 public tokenRaised = 0;             // total raised tokens

    uint256 public tokenMigrated = 0;           // total migrated tokens

    uint256 public tokenExchangeRate = 0;       // ? BTR per 1 ETH



    // events

    event AllocateToken(address indexed _to, uint256 _value);

    event IssueToken(address indexed _to, uint256 _value);

    event IncreaseSupply(uint256 _value);

    event DecreaseSupply(uint256 _value);

    event Migrate(address indexed _to, uint256 _value);

    event CreateBTR(address indexed _to, uint256 _value);



    function formatDecimals(uint256 _value) internal pure returns (uint256) {

        return _value * 10 ** decimals;

    }



    // constructor

    constructor(address _owner) public {

        ethFundDeposit = _owner;



        isFunding = false;

        fundingStartBlock = 0;

        fundingStopBlock = 0;



        totalSupply = formatDecimals(total);

        currentSupply = formatDecimals(total); // just equal totalSupply

        balances[_owner] = totalSupply;

        emit CreateBTR(ethFundDeposit, totalSupply);

    }



    modifier onlyOwner() {

        require(msg.sender == ethFundDeposit, "auth fail"); 

        _;

    }



    /// set rate

    function setTokenExchangeRate(uint256 _tokenExchangeRate) external onlyOwner {

        require(_tokenExchangeRate != 0, "_tokenExchangeRate is zero");

        require(_tokenExchangeRate != tokenExchangeRate, "_tokenExchangeRate not changed");



        tokenExchangeRate = _tokenExchangeRate;

    }



    function increaseSupply (uint256 _value) external onlyOwner {

        uint256 value = formatDecimals(_value);

        require(value + currentSupply <= totalSupply, "require");

        currentSupply = safeAdd(currentSupply, value);

        emit IncreaseSupply(value);

    }



    function decreaseSupply (uint256 _value) external onlyOwner {

        uint256 value = formatDecimals(_value);

        require(value + tokenRaised <= currentSupply, "require");



        currentSupply = safeSubtract(currentSupply, value);

        emit DecreaseSupply(value);

    }



    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) external onlyOwner {

        require(!isFunding, "require");

        require(_fundingStartBlock < _fundingStopBlock, "require");

        require(block.number < _fundingStartBlock, "require");



        fundingStartBlock = _fundingStartBlock;

        fundingStopBlock = _fundingStopBlock;

        isFunding = true;

    }



    function stopFunding() external onlyOwner {

        require(isFunding, "require");

        isFunding = false;

    }



    /// new owner

    function changeOwner(address _newFundDeposit) external onlyOwner {

        require(_newFundDeposit != address(0x0), "_newFundDeposit is empty");

        ethFundDeposit = _newFundDeposit;

    }



    /// update token

    function setMigrateContract(address _newContractAddr) external onlyOwner {

        require(_newContractAddr != newContractAddr, "require");

        newContractAddr = _newContractAddr;

    }



    function migrate() external {

        require(!isFunding, "require");

        require(newContractAddr != address(0x0), "new contract address is empty");



        uint256 tokens = balances[msg.sender];

        require(tokens != 0, "your balances is zero");



        balances[msg.sender] = 0;

        tokenMigrated = safeAdd(tokenMigrated, tokens);



        IMigrationContract newContract = IMigrationContract(newContractAddr);

        require(newContract.migrate(msg.sender, tokens), "require");



        emit Migrate(msg.sender, tokens);

    }



    function allocateToken (address _addr, uint256 _eth) external onlyOwner {

        require(_eth != 0, "_eth is zero");

        require(_addr != address(0x0), "_addr is empty");



        uint256 tokens = safeMult(formatDecimals(_eth), tokenExchangeRate);

        require(tokens + tokenRaised <= currentSupply, "require");



        tokenRaised = safeAdd(tokenRaised, tokens);

        balances[_addr] += tokens;



        emit AllocateToken(_addr, tokens);

    }



    function () external payable {

        require(isFunding, "require");

        require(msg.value != 0, "require");



        require(block.number >= fundingStartBlock, "require");

        require(block.number <= fundingStopBlock, "require");



        uint256 tokens = safeMult(msg.value, tokenExchangeRate);

        require(tokens + tokenRaised <= currentSupply, "require");



        tokenRaised = safeAdd(tokenRaised, tokens);

        balances[msg.sender] += tokens;



        emit IssueToken(msg.sender, tokens);

    }

}