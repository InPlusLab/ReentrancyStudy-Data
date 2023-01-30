pragma solidity ^0.4.4;

// ERC20 token interface is implemented only partially
// (no SafeMath is used because contract code is very simple)
// 
// Some functions left undefined:
//  - transfer, transferFrom,
//  - approve, allowance.
contract PresaleToken
{
/// Fields:
    string public constant name = "IMMLA Presale Token v.2";
    string public constant symbol = "IML";
    uint public constant decimals = 18;
    uint public constant PRICE = 5200;  // per 1 Ether

    //  price
    // Cap is 600 ETH
    // 1 eth = 5200 presale IMMLA tokens
    // 
    // ETH price 320$ - 15.10.2017
    uint public constant TOKEN_SUPPLY_LIMIT = PRICE * 600 * (1 ether / 1 wei);

    enum State{
       Init,
       Running,
       Paused,
       Migrating,
       Migrated
    }

    State public currentState = State.Init;
    uint public totalSupply = 0; // amount of tokens already sold

    // Gathered funds can be withdrawn only to escrow&#39;s address.
    address public escrow;

    // Token manager has exclusive priveleges to call administrative
    // functions on this contract.
    address public tokenManager;

    // Crowdsale manager has exclusive priveleges to burn presale tokens.
    address public crowdsaleManager;

    mapping (address => uint256) private balance;

/// Modifiers:
    modifier onlyTokenManager()     { if(msg.sender != tokenManager) throw; _; }
    modifier onlyCrowdsaleManager() { if(msg.sender != crowdsaleManager) throw; _; }
    modifier onlyInState(State state){ if(state != currentState) throw; _; }

/// Events:
    event LogBuy(address indexed owner, uint value);
    event LogBurn(address indexed owner, uint value);
    event LogStateSwitch(State newState);

/// Functions:
    /// @dev Constructor
    function PresaleToken()
    {
        tokenManager = msg.sender;
        escrow = 0x9a6Fb86bd26CbcBF5ba1b9dFd55f479875F310Cb;
        crowdsaleManager = msg.sender;
    }

    function buyTokens(address _buyer) public payable onlyInState(State.Running)
    {
        if(msg.value == 0) throw;
        uint newTokens = msg.value * PRICE;

        if (totalSupply + newTokens > TOKEN_SUPPLY_LIMIT) throw;

        balance[_buyer] += newTokens;
        totalSupply += newTokens;

        LogBuy(_buyer, newTokens);
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function burnTokens(address _owner) public onlyCrowdsaleManager onlyInState(State.Migrating)
    {
        uint tokens = balance[_owner];
        if(tokens == 0) throw;

        balance[_owner] = 0;
        totalSupply -= tokens;

        LogBurn(_owner, tokens);

        // Automatically switch phase when migration is done.
        if(totalSupply == 0) 
        {
            currentState = State.Migrated;
            LogStateSwitch(State.Migrated);
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256) 
    {
        return balance[_owner];
    }

    function setPresaleState(State _nextState) public onlyTokenManager
    {
        // Init -> Running
        // Running -> Paused
        // Running -> Migrating
        // Paused -> Running
        // Paused -> Migrating
        // Migrating -> Migrated
        bool canSwitchState
             =  (currentState == State.Init && _nextState == State.Running)
             || (currentState == State.Running && _nextState == State.Paused)
             // switch to migration phase only if crowdsale manager is set
             || ((currentState == State.Running || currentState == State.Paused)
                 && _nextState == State.Migrating
                 && crowdsaleManager != 0x0)
             || (currentState == State.Paused && _nextState == State.Running)
             // switch to migrated only if everyting is migrated
             || (currentState == State.Migrating && _nextState == State.Migrated
                 && totalSupply == 0);

        if(!canSwitchState) throw;

        currentState = _nextState;
        LogStateSwitch(_nextState);
    }

    function withdrawEther() public onlyTokenManager
    {
        if(this.balance > 0) 
        {
            if(!escrow.send(this.balance)) throw;
        }
    }

/// Setters/getters
    function setTokenManager(address _mgr) public onlyTokenManager
    {
        tokenManager = _mgr;
    }

    function setCrowdsaleManager(address _mgr) public onlyTokenManager
    {
        // You can&#39;t change crowdsale contract when migration is in progress.
        if(currentState == State.Migrating) throw;

        crowdsaleManager = _mgr;
    }

    function getTokenManager()constant returns(address)
    {
        return tokenManager;
    }

    function getCrowdsaleManager()constant returns(address)
    {
        return crowdsaleManager;
    }

    function getCurrentState()constant returns(State)
    {
        return currentState;
    }

    function getPrice()constant returns(uint)
    {
        return PRICE;
    }

    function getTotalSupply()constant returns(uint)
    {
        return totalSupply;
    }


    // Default fallback function
    function() payable 
    {
        buyTokens(msg.sender);
    }
}