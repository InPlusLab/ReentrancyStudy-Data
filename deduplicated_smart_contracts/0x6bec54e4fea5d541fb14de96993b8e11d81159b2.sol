// our mirrors:
// ftec.io
// ftec.ai 
// our official Telegram group:
// t.me/FTECofficial

pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract MultiOwnable {

    mapping (address => bool) public isOwner;
    address[] public ownerHistory;

    event OwnerAddedEvent(address indexed _newOwner);
    event OwnerRemovedEvent(address indexed _oldOwner);

    function MultiOwnable() public {
        // Add default owner
        address owner = msg.sender;
        ownerHistory.push(owner);
        isOwner[owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender]);
        _;
    }
    
    function ownerHistoryCount() public view returns (uint) {
        return ownerHistory.length;
    }

    /** Add extra owner. */
    function addOwner(address owner) onlyOwner public {
        require(owner != address(0));
        require(!isOwner[owner]);
        ownerHistory.push(owner);
        isOwner[owner] = true;
        OwnerAddedEvent(owner);
    }

    /** Remove extra owner. */
    function removeOwner(address owner) onlyOwner public {
        require(isOwner[owner]);
        isOwner[owner] = false;
        OwnerRemovedEvent(owner);
    }
}

contract ERC20 {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20 {
    
    using SafeMath for uint;

    mapping(address => uint256) balances;
    
    mapping(address => mapping(address => uint256)) allowed;

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract CommonToken is StandardToken, MultiOwnable {
    
    string public constant name   = 'FTEC';
    string public constant symbol = 'FTEC';
    uint8 public constant decimals = 18;
    
    uint256 public saleLimit;   // 85% of tokens for sale.
    uint256 public teamTokens;  // 7% of tokens goes to the team and will be locked for 1 year.
    // 8% of the rest tokens will be used for bounty, advisors, and airdrops.
    
    // 7% of team tokens will be locked at this address for 1 year.
    address public teamWallet; // Team address.
    
    uint public unlockTeamTokensTime = now + 1 years;

    // The main account that holds all tokens at the beginning and during tokensale.
    address public seller; // Seller address (main holder of tokens)

    uint256 public tokensSold; // (e18) Number of tokens sold through all tiers or tokensales.
    uint256 public totalSales; // Total number of sales (including external sales) made through all tiers or tokensales.

    // Lock the transfer functions during tokensales to prevent price speculations.
    bool public locked = true;
    
    event SellEvent(address indexed _seller, address indexed _buyer, uint256 _value);
    event ChangeSellerEvent(address indexed _oldSeller, address indexed _newSeller);
    event Burn(address indexed _burner, uint256 _value);
    event Unlock();

    function CommonToken(
        address _seller,
        address _teamWallet
    ) MultiOwnable() public {
        
        totalSupply = 998400000 ether;
        saleLimit   = 848640000 ether;
        teamTokens  =  69888000 ether;

        seller = _seller;
        teamWallet = _teamWallet;

        uint sellerTokens = totalSupply - teamTokens;
        balances[seller] = sellerTokens;
        Transfer(0x0, seller, sellerTokens);
        
        balances[teamWallet] = teamTokens;
        Transfer(0x0, teamWallet, teamTokens);
    }
    
    modifier ifUnlocked(address _from) {
        require(!locked);
        
        // If requested a transfer from the team wallet:
        if (_from == teamWallet) {
            require(now >= unlockTeamTokensTime);
        }
        
        _;
    }
    
    /** Can be called once by super owner. */
    function unlock() onlyOwner public {
        require(locked);
        locked = false;
        Unlock();
    }

    /**
     * An address can become a new seller only in case it has no tokens.
     * This is required to prevent stealing of tokens  from newSeller via 
     * 2 calls of this function.
     */
    function changeSeller(address newSeller) onlyOwner public returns (bool) {
        require(newSeller != address(0));
        require(seller != newSeller);
        
        // To prevent stealing of tokens from newSeller via 2 calls of changeSeller:
        require(balances[newSeller] == 0);

        address oldSeller = seller;
        uint256 unsoldTokens = balances[oldSeller];
        balances[oldSeller] = 0;
        balances[newSeller] = unsoldTokens;
        Transfer(oldSeller, newSeller, unsoldTokens);

        seller = newSeller;
        ChangeSellerEvent(oldSeller, newSeller);
        return true;
    }

    /**
     * User-friendly alternative to sell() function.
     */
    function sellNoDecimals(address _to, uint256 _value) public returns (bool) {
        return sell(_to, _value * 1e18);
    }

    function sell(address _to, uint256 _value) onlyOwner public returns (bool) {

        // Check that we are not out of limit and still can sell tokens:
        require(tokensSold.add(_value) <= saleLimit);

        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[seller]);

        balances[seller] = balances[seller].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(seller, _to, _value);

        totalSales++;
        tokensSold = tokensSold.add(_value);
        SellEvent(seller, _to, _value);
        return true;
    }
    
    /**
     * Until all tokens are sold, tokens can be transfered to/from owner's accounts.
     */
    function transfer(address _to, uint256 _value) ifUnlocked(msg.sender) public returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * Until all tokens are sold, tokens can be transfered to/from owner's accounts.
     */
    function transferFrom(address _from, address _to, uint256 _value) ifUnlocked(_from) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function burn(uint256 _value) public returns (bool) {
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Transfer(msg.sender, 0x0, _value);
        Burn(msg.sender, _value);
        return true;
    }
}

contract ProdToken is CommonToken {
    function ProdToken() CommonToken(
        0x292FDFdD7E2967fc0251e35A2eF6CBA3F312dAd7, 
        0x5f448809De9e2bBe3120005D94e4D7C0D84d3710  
    ) public {}
}