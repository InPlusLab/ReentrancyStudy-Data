pragma solidity ^0.4.15;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        if (a != 0 && c / a != b) revert();
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        if (b > a) revert();
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        if (c < a) revert();
        return c;
    }
}

contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping (address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue)
    returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
    returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        }
        else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


/**
 * @title IRBTokens
 * @dev IRB Token contract based on Zeppelin StandardToken contract
 */
contract IRBToken is StandardToken, Ownable {
    using SafeMath for uint256;

    /**
     * @dev ERC20 descriptor variables
     */
    string public constant name = "IRB Tokens";

    string public constant symbol = "IRB";

    uint8 public decimals = 18;

    /**
     * @dev 489.58 millions s the initial Token sale
     */
    uint256 public constant crowdsaleTokens = 489580 * 10 ** 21;

    /**
     * @dev 10.42 millions is the initial Token presale
     */
    uint256 public constant preCrowdsaleTokens = 10420 * 10 ** 21;

    // TODO: TestRPC addresses, replace to real
    // PRE Crowdsale Tokens Wallet
    address public constant preCrowdsaleTokensWallet = 0x0CD95a59fAd089c4EBCCEB54f335eC8f61Caa80e;
    // Crowdsale Tokens Wallet
    address public constant crowdsaleTokensWallet = 0x48545E41696Dc51020C35cA8C36b678101a98437;

    /**
     * @dev Address of PRE Crowdsale contract which will be compared
     *       against in the appropriate modifier check
     */
    address public preCrowdsaleContractAddress;

    /**
     * @dev Address of Crowdsale contract which will be compared
     *       against in the appropriate modifier check
     */
    address public crowdsaleContractAddress;

    /**
     * @dev variable that holds flag of ended pre tokensake
     */
    bool isPreFinished = false;

    /**
     * @dev variable that holds flag of ended tokensake
     */
    bool isFinished = false;

    /**
     * @dev Modifier that allow only the Crowdsale contract to be sender
     */
    modifier onlyPreCrowdsaleContract() {
        require(msg.sender == preCrowdsaleContractAddress);
        _;
    }

    /**
     * @dev Modifier that allow only the Crowdsale contract to be sender
     */
    modifier onlyCrowdsaleContract() {
        require(msg.sender == crowdsaleContractAddress);
        _;
    }

    /**
     * @dev event for the burnt tokens after crowdsale logging
     * @param tokens amount of tokens available for crowdsale
     */
    event TokensBurnt(uint256 tokens);

    /**
     * @dev event for the tokens contract move to the active state logging
     * @param supply amount of tokens left after all the unsold was burned
     */
    event Live(uint256 supply);

    /**
     * @dev Contract constructor
     */
    function IRBToken() {
        // Issue pre crowdsale tokens
        balances[preCrowdsaleTokensWallet] = balanceOf(preCrowdsaleTokensWallet).add(preCrowdsaleTokens);
        Transfer(address(0), preCrowdsaleTokensWallet, preCrowdsaleTokens);

        // Issue crowdsale tokens
        balances[crowdsaleTokensWallet] = balanceOf(crowdsaleTokensWallet).add(crowdsaleTokens);
        Transfer(address(0), crowdsaleTokensWallet, crowdsaleTokens);

        // 500 millions tokens overall
        totalSupply = crowdsaleTokens.add(preCrowdsaleTokens);
    }

    /**
     * @dev back link IRBToken contract with IRBPreCrowdsale one
     * @param _preCrowdsaleAddress non zero address of IRBPreCrowdsale contract
     */
    function setPreCrowdsaleAddress(address _preCrowdsaleAddress) onlyOwner external {
        require(_preCrowdsaleAddress != address(0));
        preCrowdsaleContractAddress = _preCrowdsaleAddress;

        // Allow pre crowdsale contract
        uint256 balance = balanceOf(preCrowdsaleTokensWallet);
        allowed[preCrowdsaleTokensWallet][preCrowdsaleContractAddress] = balance;
        Approval(preCrowdsaleTokensWallet, preCrowdsaleContractAddress, balance);
    }

    /**
     * @dev back link IRBToken contract with IRBCrowdsale one
     * @param _crowdsaleAddress non zero address of IRBCrowdsale contract
     */
    function setCrowdsaleAddress(address _crowdsaleAddress) onlyOwner external {
        require(isPreFinished);
        require(_crowdsaleAddress != address(0));
        crowdsaleContractAddress = _crowdsaleAddress;

        // Allow crowdsale contract
        uint256 balance = balanceOf(crowdsaleTokensWallet);
        allowed[crowdsaleTokensWallet][crowdsaleContractAddress] = balance;
        Approval(crowdsaleTokensWallet, crowdsaleContractAddress, balance);
    }

    /**
     * @dev called only by linked IRBPreCrowdsale contract to end precrowdsale.
     */
    function endPreTokensale() onlyPreCrowdsaleContract external {
        require(!isPreFinished);
        uint256 preCrowdsaleLeftovers = balanceOf(preCrowdsaleTokensWallet);

        if (preCrowdsaleLeftovers > 0) {
            balances[preCrowdsaleTokensWallet] = 0;
            balances[crowdsaleTokensWallet] = balances[crowdsaleTokensWallet].add(preCrowdsaleLeftovers);
            Transfer(preCrowdsaleTokensWallet, crowdsaleTokensWallet, preCrowdsaleLeftovers);
        }

        isPreFinished = true;
    }

    /**
     * @dev called only by linked IRBCrowdsale contract to end crowdsale.
     */
    function endTokensale() onlyCrowdsaleContract external {
        require(!isFinished);
        uint256 crowdsaleLeftovers = balanceOf(crowdsaleTokensWallet);

        if (crowdsaleLeftovers > 0) {
            totalSupply = totalSupply.sub(crowdsaleLeftovers);

            balances[crowdsaleTokensWallet] = 0;
            Transfer(crowdsaleTokensWallet, address(0), crowdsaleLeftovers);
            TokensBurnt(crowdsaleLeftovers);
        }

        isFinished = true;
        Live(totalSupply);
    }
}