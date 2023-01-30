// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity ^0.4.8;

contract SafeMath {
    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

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

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    bool public isFrozen;              // switched to true in frozen state

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (isFrozen) revert();
        //Default assumes totalSupply can&#39;t be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn&#39;t wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (isFrozen) revert();
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
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

contract PreAdsMobileToken is StandardToken, SafeMath {

    /* Public variables of the token */

    /*
        NOTE:
        The following variables are OPTIONAL vanities. One does not have to include them.
        They allow one to customise the token contract & in no way influences the core functionality.
        Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals = 18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It&#39;s like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = &#39;H0.1&#39;;       //human 0.1 standard. Just an arbitrary versioning scheme.

    // contracts
    address public ethFundDeposit;      // deposit address for ETH for AdsMobile

    // crowdsale parameters
    bool public isFinalized;              // switched to true in operational state
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;
    uint256 public checkNumber;
    uint256 public totalSupplyWithOutBonus;
    uint256 public constant tokenExchangeRate               = 400; // 400 AdsMobile tokens per 1 ETH
    uint256 public constant tokenCreationCapWithOutBonus    = 3 * (10**6) * 10**18;
    uint256 public constant tokenNeedForBonusLevel0         = 100 * (10**3) * 10**18;
    uint256 public constant bonusLevel0PercentModifier      = 300;
    uint256 public constant tokenNeedForBonusLevel1         = 50 * (10**3) * 10**18;
    uint256 public constant bonusLevel1PercentModifier      = 200;
    uint256 public constant tokenCreationMinPayment         = 50 * (10**3) * 10**18;

    // events
    event CreateAds(address indexed _to, uint256 _value);

    // constructor
    function PreAdsMobileToken(
    string _tokenName,
    string _tokenSymbol,
    address _ethFundDeposit,
    uint256 _fundingStartBlock,
    uint256 _fundingEndBlock
    )
    {
        balances[msg.sender] = 0;               // Give the creator all initial tokens
        totalSupply = 0;                        // Update total supply
        name = _tokenName;           // Set the name for display purposes
        decimals = 18;                          // Amount of decimals for display purposes
        symbol = _tokenSymbol;                        // Set the symbol for display purposes
        isFinalized = false;                    // controls pre through crowdsale state
        isFrozen = false;
        ethFundDeposit = _ethFundDeposit;
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        checkNumber = 42;                       //Answer to the Ultimate Question of Life, the Universe, and Everything
    }

    /// @dev Accepts ether and creates new ADS tokens.
    function createTokens() public payable {
        if (isFinalized) revert();
        if (block.number < fundingStartBlock) revert();
        if (block.number > fundingEndBlock) revert();
        if (msg.value == 0) revert();
        uint256 tokensWithOutBonus = safeMult(msg.value, tokenExchangeRate); // check that we&#39;re not over totals
        if (tokensWithOutBonus < tokenCreationMinPayment) revert();
        uint256 checkedSupplyWithOutBonus = safeAdd(totalSupplyWithOutBonus, tokensWithOutBonus);
        // return money if something goes wrong
        if (tokenCreationCapWithOutBonus < checkedSupplyWithOutBonus) revert();  // odd fractions won&#39;t be found
        totalSupplyWithOutBonus = checkedSupplyWithOutBonus;

        uint256 tokens = tokensWithOutBonus;
        if(tokens >= tokenNeedForBonusLevel0) {
            tokens = safeDiv(tokens, 100);
            tokens = safeMult(tokens, bonusLevel0PercentModifier);
        } else {
            if(tokens >= tokenNeedForBonusLevel1) {
                tokens = safeDiv(tokens, 100);
                tokens = safeMult(tokens, bonusLevel1PercentModifier);
            }
        }
        uint256 checkedSupply = safeAdd(totalSupply, tokens);
        totalSupply = checkedSupply;
        balances[msg.sender] += tokens;  // safeAdd not needed; bad semantics to use here
        CreateAds(msg.sender, tokens);  // logs token creation
    }

    //just for test cashin and cashout on small amount before let it go
    function cashin() external payable {
        if (isFinalized) revert();
    }

    function cashout(uint256 amount) external {
        if (isFinalized) revert();
        if (msg.sender != ethFundDeposit) revert(); // locks finalize to the ultimate ETH owner
        if (!ethFundDeposit.send(amount)) revert();  // send the eth to AdsMobile
    }

    //in case we want to transfer token to other contract we need freeze all future transfers
    function freeze() external {
        if (msg.sender != ethFundDeposit) revert(); // locks finalize to the ultimate ETH owner
        isFrozen = true;
    }

    function unFreeze() external {
        if (msg.sender != ethFundDeposit) revert(); // locks finalize to the ultimate ETH owner
        isFrozen = false;
    }

    /// @dev Ends the funding period and sends the ETH home
    function finalize() external {
        if (isFinalized) revert();
        if (msg.sender != ethFundDeposit) revert(); // locks finalize to the ultimate ETH owner
        if (block.number <= fundingEndBlock && totalSupplyWithOutBonus < tokenCreationCapWithOutBonus - tokenCreationMinPayment) revert();
        // move to operational
        if (!ethFundDeposit.send(this.balance)) revert();  // send the eth to AdsMobile
        isFinalized = true;
    }

    /**
     * @dev Fallback function which receives ether and created the appropriate number of tokens for the
     * msg.sender.
     */
    function() external payable {
        createTokens();
    }

}