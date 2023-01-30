pragma solidity ^0.4.13;

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

  function getOwner() returns(address){
    return owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/*
 * ���ѧ٧�ӧ�� �ܧ�ߧ��ѧܧ�, �ܧ������ ���էէ֧�اڧӧѧ֧� ����ѧߧ�ӧܧ� ����էѧ�
 */

contract Haltable is Ownable {
    bool public halted;

    modifier stopInEmergency {
        require(!halted);
        _;
    }

    /* ����էڧ�ڧܧѧ���, �ܧ������ �ӧ�٧�ӧѧ֧��� �� �����ާܧѧ� */
    modifier onlyInEmergency {
        require(halted);
        _;
    }

    /* ����٧�� ���ߧܧ�ڧ� ���֧�ӧ֧� ����էѧا�, �ӧ�٧�ӧѧ�� �ާ�ا֧� ���ݧ�ܧ� �ӧݧѧէ֧ݧ֧� */
    function halt() external onlyOwner {
        halted = true;
    }

    /* ����٧�� �ӧ�٧ӧ�ѧ�ѧ֧� ��֧اڧ� ����էѧ� */
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
    }

}

/**
 * ���ѧ٧ݧڧ�ߧ�� �ӧѧݧڧէѧ����
 */

contract ValidationUtil {
    function requireNotEmptyAddress(address value) internal{
        require(isAddressValid(value));
    }

    function isAddressValid(address value) internal constant returns (bool result){
        return value != 0;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

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
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

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
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until 
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) 
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * ���ѧҧݧ�� �էݧ� ���ܧ֧ߧ�, �ܧ������ �ާ�اߧ� ��ا֧��
*/
contract BurnableToken is StandardToken, Ownable, ValidationUtil {
    using SafeMath for uint;

    address public tokenOwnerBurner;

    /** ����ҧ��ڧ�, ��ܧ�ݧ�ܧ� ���ܧ֧ߧ�� �ާ� ���اԧݧ� */
    event Burned(address burner, uint burnedAmount);

    function setOwnerBurner(address _tokenOwnerBurner) public onlyOwner invalidOwnerBurner{
        // �����ӧ֧�ܧ�, ���� �ѧէ�֧� �ߧ� �������
        requireNotEmptyAddress(_tokenOwnerBurner);

        tokenOwnerBurner = _tokenOwnerBurner;
    }

    /**
     * ���اڧԧѧ֧� ���ܧ֧ߧ� �ߧ� �ҧѧݧѧߧ�� �ӧݧѧէ֧ݧ��� ���ܧ֧ߧ��, �ӧ�٧ӧѧ�� �ާ�ا֧� ���ݧ�ܧ� tokenOwnerBurner
     */
    function burnOwnerTokens(uint burnAmount) public onlyTokenOwnerBurner validOwnerBurner{
        burnTokens(tokenOwnerBurner, burnAmount);
    }

    /**
     * ���اڧԧѧ֧� ���ܧ֧ߧ� �ߧ� �ҧѧݧѧߧ�� �ѧէ�֧�� ���ܧ֧ߧ��, �ӧ�٧ӧѧ�� �ާ�ا֧� ���ݧ�ܧ� tokenOwnerBurner
     */
    function burnTokens(address _address, uint burnAmount) public onlyTokenOwnerBurner validOwnerBurner{
        balances[_address] = balances[_address].sub(burnAmount);

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        Burned(_address, burnAmount);
    }

    /**
     * ���اڧԧѧ֧� �ӧ�� ���ܧ֧ߧ� �ߧ� �ҧѧݧѧߧ�� �ӧݧѧէ֧ݧ���
     */
    function burnAllOwnerTokens() public onlyTokenOwnerBurner validOwnerBurner{
        uint burnAmount = balances[tokenOwnerBurner];
        burnTokens(tokenOwnerBurner, burnAmount);
    }

    /** ����էڧ�ڧܧѧ����
     */
    modifier onlyTokenOwnerBurner() {
        require(msg.sender == tokenOwnerBurner);

        _;
    }

    modifier validOwnerBurner() {
        // �����ӧ֧�ܧ�, ���� �ѧէ�֧� �ߧ� �������
        requireNotEmptyAddress(tokenOwnerBurner);

        _;
    }

    modifier invalidOwnerBurner() {
        // �����ӧ֧�ܧ�, ���� �ѧէ�֧� �ߧ� �������
        require(!isAddressValid(tokenOwnerBurner));

        _;
    }
}

/**
 * ����ܧ֧� ����էѧ�
 *
 * ERC-20 ���ܧ֧�, �էݧ� ICO
 *
 */

contract CrowdsaleToken is StandardToken, Ownable {

    /* ����ڧ�ѧߧڧ� ���. �� �ܧ�ߧ����ܧ���� */
    string public name;

    string public symbol;

    uint public decimals;

    address public mintAgent;

    /** ����ҧ��ڧ� ��ҧߧ�ӧݧ֧ߧڧ� ���ܧ֧ߧ� (�ڧާ� �� ��ڧާӧ��) */
    event UpdatedTokenInformation(string newName, string newSymbol);

    /** ����ҧ��ڧ� �ӧ����ܧ� ���ܧ֧ߧ�� */
    event TokenMinted(uint amount, address toAddress);

    /**
     * ����ߧ����ܧ���
     *
     * ����ܧ֧� �է�ݧا֧� �ҧ��� ���٧էѧ� ���ݧ�ܧ� �ӧݧѧէ֧ݧ��֧� ��֧�֧� �ܧ��֧ݧ֧� (�ݧڧҧ� �� �ާ�ݧ��ڧ��է�ڧ���, �ݧڧҧ� �ҧ֧� �ߧ֧�)
     *
     * @param _name - �ڧާ� ���ܧ֧ߧ�
     * @param _symbol - ��ڧާӧ�� ���ܧ֧ߧ�
     * @param _decimals - �ܧ��-�ӧ� �٧ߧѧܧ�� ����ݧ� �٧ѧ�����
     */
    function CrowdsaleToken(string _name, string _symbol, uint _decimals) {
        owner = msg.sender;

        name = _name;
        symbol = _symbol;

        decimals = _decimals;
    }

    /**
     * ���ݧѧէ֧ݧ֧� �է�ݧا֧� �ӧ�٧ӧѧ�� ���� ���ߧܧ�ڧ�, ����ҧ� �ӧ�����ڧ�� ���ܧ֧ߧ� �ߧ� �ѧէ�֧�
     */
    function mintToAddress(uint amount, address toAddress) onlyMintAgent{
        // ��֧�֧ӧ�� ���ܧ֧ߧ�� �ߧ� �ѧܧܧѧ�ߧ�
        balances[toAddress] = amount;

        // �ӧ�٧�ӧѧ֧� ���ҧ��ڧ�
        TokenMinted(amount, toAddress);
    }

    /**
     * ���ݧѧէ֧ݧ֧� �ާ�ا֧� ��ҧߧ�ӧڧ�� �ڧߧ�� ��� ���ܧ֧ߧ�
     */
    function setTokenInformation(string _name, string _symbol) onlyOwner {
        name = _name;
        symbol = _symbol;

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        UpdatedTokenInformation(name, symbol);
    }

    /**
     * ����ݧ�ܧ� �ӧݧѧէ֧ݧ֧� �ާ�ا֧� ��ҧߧ�ӧڧ�� �ѧԧ֧ߧ�� �էݧ� ���٧էѧߧڧ� ���ܧ֧ߧ��
     */
    function setMintAgent(address _address) onlyOwner {
        mintAgent =  _address;
    }

    modifier onlyMintAgent(){
        require(msg.sender == mintAgent);

        _;
    }
}

/**
 * ���ѧҧݧ�� �էݧ� ����էѧ� ���ܧ֧ߧ�, �ܧ������ �ާ�اߧ� ��ا֧��
 *
 */
contract BurnableCrowdsaleToken is BurnableToken, CrowdsaleToken {

    function BurnableCrowdsaleToken(string _name, string _symbol, uint _decimals) CrowdsaleToken(_name, _symbol, _decimals) BurnableToken(){

    }
}

/**
 * ���ѧ٧�ӧ�� �ܧ�ߧ��ѧܧ� �էݧ� ����էѧ�
 *
 * ����է֧�اڧ�
 * - ���ѧ�� �ߧѧ�ѧݧ� �� �ܧ�ߧ��
 */

/* �����էѧا� �ާ�ԧ�� �ҧ��� ����ѧߧ�ӧݧ֧ߧ� �� �ݧ�ҧ�� �ާ�ާ֧ߧ� ��� �ӧ�٧�ӧ� halt() */

contract AllocatedCappedCrowdsale is Haltable, ValidationUtil {
    using SafeMath for uint;

    // �����-�ӧ� ���ܧ֧ߧ�� �էݧ� ��ѧ���֧է֧ݧ֧ߧڧ�
    uint public advisorsTokenAmount = 8040817;
    uint public supportTokenAmount = 3446064;
    uint public marketingTokenAmount = 3446064;
    uint public teamTokenAmount = 45947521;

    uint public teamTokensIssueDate;

    /* ����ܧ֧�, �ܧ������ ����էѧ֧� */
    BurnableCrowdsaleToken public token;

    /* ���է�֧�, �ܧ�է� �ҧ�է�� ��֧�֧ӧ֧է֧ߧ� ���ҧ�ѧߧߧѧ� ���ާާ�, �� ��ݧ��ѧ� ����֧�� */
    address public destinationMultisigWallet;

    /* ���֧�ӧѧ� ���ѧէڧ� �� ����ާѧ�� UNIX timestamp */
    uint public firstStageStartsAt;
    /* ����ߧ֧� ����էѧ� �� ����ާѧ�� UNIX timestamp */
    uint public firstStageEndsAt;

    /* ������ѧ� ���ѧէڧ� �� ����ާѧ�� UNIX timestamp */
    uint public secondStageStartsAt;
    /* ����ߧ֧� ����էѧ� �� ����ާѧ�� UNIX timestamp */
    uint public secondStageEndsAt;

    /* ���ڧߧڧާѧݧ�ߧѧ� �ܧ֧�ܧ� �էݧ� ��֧�ӧ�� ���ѧէڧ� �� ��֧ߧ�ѧ� */
    uint public softCapFundingGoalInCents = 392000000;

    /* ���ڧߧڧާѧݧ�ߧѧ� �ܧ֧�ܧ� �էݧ� �ӧ����� ���ѧէڧ� �� ��֧ߧ�ѧ� */
    uint public hardCapFundingGoalInCents = 985000000;

    /* ���ܧ�ݧ�ܧ� �ӧ�֧ԧ� �� wei �ާ� ���ݧ��ڧݧ� 10^18 wei = 1 ether */
    uint public weiRaised;

    /* ���ܧ�ݧ�ܧ� �ӧ�֧ԧ� ���ҧ�ѧݧ� �� ��֧ߧѧ� �ߧ� ��֧�ӧ�� ���ѧէڧ� */
    uint public firstStageRaisedInWei;

    /* ���ܧ�ݧ�ܧ� �ӧ�֧ԧ� ���ҧ�ѧݧ� �� ��֧ߧѧ� �ߧ� �ӧ����� ���ѧէڧ� */
    uint public secondStageRaisedInWei;

    /* �����-�ӧ� ��ߧڧܧѧݧ�ߧ�� �ѧէ�֧���, �ܧ������ �� �ߧ�c ���ݧ��ڧݧ� ���ܧ֧ߧ� */
    uint public investorCount;

    /*  ���ܧ�ݧ�ܧ� wei ���էѧݧ� �ڧߧӧ֧����ѧ� �ߧ� refund'�� �� wei */
    uint public weiRefunded;

    /*  ���ܧ�ݧ�ܧ� ���ܧ֧ߧ�� ����էѧݧ� �ӧ�֧ԧ� */
    uint public tokensSold;

    /* ���ݧѧ� ���ԧ�, ���� ���ѧҧ��ѧ� ��ڧߧѧݧڧ٧ѧ��� ��֧�ӧ�� ���ѧէڧ� */
    bool public isFirstStageFinalized;

    /* ���ݧѧ� ���ԧ�, ���� ���ѧҧ��ѧ� ��ڧߧѧݧڧ٧ѧ��� �ӧ����� ���ѧէڧ� */
    bool public isSecondStageFinalized;

    /* ���ݧѧ� �ߧ��ާѧݧ�ߧ�ԧ� �٧ѧӧ֧��ߧ֧ߧڧ� ����էѧ� */
    bool public isSuccessOver;

    /* ���ݧѧ� ���ԧ�, ���� �ߧѧ�ѧݧ�� �����֧�� �ӧ�٧ӧ�ѧ�� */
    bool public isRefundingEnabled;

    /*  ���ܧ�ݧ�ܧ� ��֧ۧ�ѧ� ����ڧ� 1 eth �� ��֧ߧ�ѧ�, ��ܧ��ԧݧ֧ߧߧѧ� �է� ��֧ݧ�� */
    uint public currentEtherRateInCents;

    /* ���֧ܧ��ѧ� ����ڧާ���� ���ܧ֧ߧ� �� ��֧ߧ�ѧ� */
    uint public oneTokenInCents = 7;

    /* �������֧ߧ� �ݧ� ���ܧ֧ߧ� �էݧ� ��֧�ӧ�� ���ѧէڧ� */
    bool public isFirstStageTokensMinted;

    /* �������֧ߧ� �ݧ� ���ܧ֧ߧ� �էݧ� �ӧ����� ���ѧէڧ� */
    bool public isSecondStageTokensMinted;

    /* �����-�ӧ� ���ܧ֧ߧ�� �էݧ� ��֧�ӧ�� ���ѧէڧ� */
    uint public firstStageTotalSupply = 112000000;

    /* �����-�ӧ� ���ܧ֧ߧ�� ����էѧߧߧ�� �ߧ� ��֧�ӧ�� ���ѧէڧ�*/
    uint public firstStageTokensSold;

    /* �����-�ӧ� ���ܧ֧ߧ�� �էݧ� �ӧ����� ���ѧէڧ� */
    uint public secondStageTotalSupply = 229737610;

    /* �����-�ӧ� ���ܧ֧ߧ�� ����էѧߧߧ�� �ߧ� �ӧ����� ���ѧէڧ�*/
    uint public secondStageTokensSold;

    /* �����-�ӧ� ���ܧ֧ߧ��, �ܧ������ �ߧѧ��է���� �� ��֧٧֧�ӧ� �� �ߧ� ����էѧ����, ����ݧ� ����֧��, ��ߧ� ��ѧ���֧է֧ݧ����� �� �����ӧ֧��ӧڧ� �� Token Policy �ߧ� �ӧ����� ���ѧէڧ�*/
    uint public secondStageReserve = 60880466;

    /* �����-�ӧ� ���ܧ֧ߧ�� ���֧էߧѧ٧ߧѧ�֧ߧߧ�� �էݧ� ����էѧا�, �ߧ� �ӧ����� ���ѧէڧ�*/
    uint public secondStageTokensForSale;

    /* ���ѧ�� �ѧէ�֧� �ڧߧӧ֧����� - �ܧ��-�ӧ� �ӧ�էѧߧߧ�� ���ܧ֧ߧ�� */
    mapping (address => uint) public tokenAmountOf;

    /* ���ѧ��, �ѧէ�֧� �ڧߧӧ֧����� - �ܧ��-�ӧ� ���ڧ�� */
    mapping (address => uint) public investedAmountOf;

    /* ���է�֧��, �ܧ�է� �ҧ�է�� ��ѧ���֧է֧ݧ֧ߧ� ���ܧ֧ߧ� */
    address public advisorsAccount;
    address public marketingAccount;
    address public supportAccount;
    address public teamAccount;

    /** ����٧ާ�اߧ�� �������ߧڧ�
     *
     * - Prefunding: ���էԧ���ӧܧ�, �٧ѧݧڧݧ� �ܧ�ߧ��ѧܧ�, �ߧ� ��֧ܧ��ѧ� �էѧ�� �ާ֧ߧ��� �էѧ�� ��֧�ӧ�� ���ѧէڧ�
     * - FirstStageFunding: �����էѧا� ��֧�ӧ�� ���ѧէڧ�
     * - FirstStageEnd: ���ܧ�ߧ�֧ߧ� ����էѧا� ��֧�ӧ�� ���ѧէڧ�, �ߧ� �֧�� �ߧ� �ӧ�٧ӧѧ� ��ڧߧѧݧڧ٧ѧ��� ��֧�ӧ�� ���ѧէڧ�
     * - SecondStageFunding: �����էѧا� �ӧ����ԧ� ���ѧ��
     * - SecondStageEnd: ���ܧ�ߧ�֧ߧ� ����էѧا� �ӧ����� ���ѧէڧ�, �ߧ� �ߧ� �ӧ�٧ӧѧ� ��ڧߧѧݧڧ٧ѧ��� �ӧ����� ��էѧէڧ�
     * - Success: �����֧�ߧ� �٧ѧܧ��ݧ� ICO
     * - Failure: ���� ���ҧ�ѧݧ� Soft Cap
     * - Refunding: ����٧ӧ�ѧ�ѧ֧� ���ҧ�ѧߧߧ�� ���ڧ�
     */
    enum State{PreFunding, FirstStageFunding, FirstStageEnd, SecondStageFunding, SecondStageEnd, Success, Failure, Refunding}

    // ����ҧ��ڧ� ���ܧ��ܧ� ���ܧ֧ߧ�
    event Invested(address indexed investor, uint weiAmount, uint tokenAmount, uint centAmount, uint txId);

    // ����ҧ��ڧ� �ڧ٧ާ֧ߧ֧ߧڧ� �ܧ���� eth
    event ExchangeRateChanged(uint oldExchangeRate, uint newExchangeRate);

    // ����ҧ��ڧ� �ڧ٧ާ֧ߧ֧ߧڧ� �էѧ�� ��ܧ�ߧ�ѧߧڧ� ��֧�ӧ�� ���ѧէڧ�
    event FirstStageStartsAtChanged(uint newFirstStageStartsAt);
    event FirstStageEndsAtChanged(uint newFirstStageEndsAt);

    // ����ҧ��ڧ� �ڧ٧ާ֧ߧ֧ߧڧ� �էѧ�� ��ܧ�ߧ�ѧߧڧ� �ӧ����� ���ѧէڧ�
    event SecondStageStartsAtChanged(uint newSecondStageStartsAt);
    event SecondStageEndsAtChanged(uint newSecondStageEndsAt);

    // ����ҧ��ڧ� �ڧ٧ާ֧ߧ֧ߧڧ� Soft Cap'��
    event SoftCapChanged(uint newGoal);

    // ����ҧ��ڧ� �ڧ٧ާ֧ߧ֧ߧڧ� Hard Cap'��
    event HardCapChanged(uint newGoal);

    // ����ߧ����ܧ���
    function AllocatedCappedCrowdsale(uint _currentEtherRateInCents, address _token, address _destinationMultisigWallet, uint _firstStageStartsAt, uint _firstStageEndsAt, uint _secondStageStartsAt, uint _secondStageEndsAt, address _advisorsAccount, address _marketingAccount, address _supportAccount, address _teamAccount, uint _teamTokensIssueDate) {
        requireNotEmptyAddress(_destinationMultisigWallet);
        // �����ӧ֧�ܧ�, ���� �էѧ�� ����ѧߧ�ӧݧ֧ߧ�
        require(_firstStageStartsAt != 0);
        require(_firstStageEndsAt != 0);

        require(_firstStageStartsAt < _firstStageEndsAt);

        require(_secondStageStartsAt != 0);
        require(_secondStageEndsAt != 0);

        require(_secondStageStartsAt < _secondStageEndsAt);
        require(_teamTokensIssueDate != 0);

        // ����ܧ֧�, �ܧ������ ���էէ֧�اڧӧѧ֧� ��اڧԧѧߧڧ�
        token = BurnableCrowdsaleToken(_token);

        destinationMultisigWallet = _destinationMultisigWallet;

        firstStageStartsAt = _firstStageStartsAt;
        firstStageEndsAt = _firstStageEndsAt;
        secondStageStartsAt = _secondStageStartsAt;
        secondStageEndsAt = _secondStageEndsAt;

        // ���է�֧�� �ܧ��֧ݧ�ܧ�� �էݧ� �ѧէӧڧ٧����, �ާѧ�ܧ֧�ڧߧԧ�, �ܧ�ާѧߧէ�
        advisorsAccount = _advisorsAccount;
        marketingAccount = _marketingAccount;
        supportAccount = _supportAccount;
        teamAccount = _teamAccount;

        teamTokensIssueDate = _teamTokensIssueDate;

        currentEtherRateInCents = _currentEtherRateInCents;

        secondStageTokensForSale = secondStageTotalSupply.sub(secondStageReserve);
    }

    /**
     * ����ߧܧ�ڧ�, �ڧߧڧ�ڧڧ����ѧ� �ߧ�اߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ�� �էݧ� ��֧�ӧ�ԧ� ���ѧ�� ����էѧ�, �ӧ�٧ӧѧ�� �ާ�اߧ� ���ݧ�ܧ� 1 ��ѧ�
     */
    function mintTokensForFirstStage() public onlyOwner {
        // ����ݧ� ��ا� ���٧էѧݧ� ���ܧ֧ߧ� �էݧ� ��֧�ӧ�� ���ѧէڧ�, �է֧ݧѧ֧� ���ܧѧ�
        require(!isFirstStageTokensMinted);

        uint tokenMultiplier = 10 ** token.decimals();

        token.mintToAddress(firstStageTotalSupply.mul(tokenMultiplier), address(this));

        isFirstStageTokensMinted = true;
    }

    /**
     * ����ߧܧ�ڧ�, �ڧߧڧ�ڧڧ����ѧ� �ߧ�اߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ�� �էݧ� �ӧ����ԧ� ���ѧ�� ����էѧ�, ���ݧ�ܧ� �� ��ݧ��ѧ�, �֧�ݧ� ���� �֧�� �ߧ� ��է֧ݧѧߧ� �� �ҧ�ݧ� ���٧էѧߧ� ���ܧ֧ߧ� �էݧ� ��֧�ӧ�� ���ѧէڧ�
     */
    function mintTokensForSecondStage() private {
        // ����ݧ� ��ا� ���٧էѧݧ� ���ܧ֧ߧ� �էݧ� �ӧ����� ���ѧէڧ�, �է֧ݧѧ֧� ���ܧѧ�
        require(!isSecondStageTokensMinted);

        require(isFirstStageTokensMinted);

        uint tokenMultiplier = 10 ** token.decimals();

        token.mintToAddress(secondStageTotalSupply.mul(tokenMultiplier), address(this));

        isSecondStageTokensMinted = true;
    }

    /**
     * ����ߧܧ�ڧ� �ӧ�٧ӧ�ѧ�ѧ��ѧ� ��֧ܧ���� ����ڧާ���� 1 ���ܧ֧ߧ� �� wei
     */
    function getOneTokenInWei() external constant returns(uint){
        return oneTokenInCents.mul(10 ** 18).div(currentEtherRateInCents);
    }

    /**
     * ����ߧܧ�ڧ�, �ܧ����ѧ� ��֧�֧ӧ�էڧ� wei �� ��֧ߧ�� ��� ��֧ܧ��֧ާ� �ܧ����
     */
    function getWeiInCents(uint value) public constant returns(uint){
        return currentEtherRateInCents.mul(value).div(10 ** 18);
    }

    /**
     * ���֧�֧ӧ�� ���ܧ֧ߧ�� ���ܧ��ѧ�֧ݧ�
     */
    function assignTokens(address receiver, uint tokenAmount) private {
        // ����ݧ� ��֧�֧ӧ�� �ߧ� ��էѧݧ��, ���ܧѧ��ӧѧ֧� ���ѧߧ٧ѧܧ�ڧ�
        if (!token.transfer(receiver, tokenAmount)) revert();
    }

    /**
     * Fallback ���ߧܧ�ڧ� �ӧ�٧�ӧѧ��ѧ��� ���� ��֧�֧ӧ�է� ���ڧ��
     */
    function() payable {
        buy();
    }

    /**
     * ���ڧ٧ܧ����ӧߧ֧ӧѧ� ���ߧܧ�ڧ� ��֧�֧ӧ�է� ���ڧ�� �� �ӧ�էѧ�� ���ܧ֧ߧ��
     */
    function internalAssignTokens(address receiver, uint tokenAmount, uint weiAmount, uint centAmount, uint txId) internal {
        // ���֧�֧ӧ�էڧ� ���ܧ֧ߧ� �ڧߧӧ֧�����
        assignTokens(receiver, tokenAmount);

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        Invested(receiver, weiAmount, tokenAmount, centAmount, txId);

        // ����ا֧� ��֧�֧���֧է֧ݧ�֧���� �� �ߧѧ�ݧ֧էߧڧܧѧ�
    }

    /**
     * ���ߧӧ֧��ڧ�ڧ�
     * ����ݧا֧� �ҧ��� �ӧܧݧ��֧� ��֧اڧ� ����էѧ� ��֧�ӧ�� �ڧݧ� �ӧ����� ���ѧէڧ� �� �ߧ� ���ҧ�ѧ� Hard Cap
     * @param receiver - ���ڧ�ߧ�� �ѧէ�֧� ���ݧ��ѧ�֧ݧ�
     * @param txId - id �ӧߧ֧�ߧ֧� ���ѧߧ٧ѧܧ�ڧ�
     */
    function internalInvest(address receiver, uint weiAmount, uint txId) stopInEmergency inFirstOrSecondFundingState notHardCapReached internal {
        State currentState = getState();

        uint tokenMultiplier = 10 ** token.decimals();

        uint amountInCents = getWeiInCents(weiAmount);

        // ����֧ߧ� �ӧߧڧާѧ�֧ݧ�ߧ� �ߧ�اߧ� �ާ֧ߧ��� �٧ߧѧ�֧ߧڧ�, ��.��. �էݧ� �ӧ����� ���ѧէڧ� 1000%, ����ҧ� ���֧��� �է��ҧߧ�� �٧ߧѧ�֧ߧڧ�
        uint bonusPercentage = 0;
        uint bonusStateMultiplier = 1;

        // �֧�ݧ� �٧ѧ���֧ߧ� ��֧�ӧѧ� ���ѧէڧ�, �� �ܧ�ߧ����ܧ���� ��ا� �ӧ�����ڧݧ� �ߧ�اߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ�� �էݧ� ��֧�ӧ�� ���ѧէڧ�
        if (currentState == State.FirstStageFunding){
            // �ާ֧ߧ��� 25000$ �ߧ� ���ڧߧڧާѧ֧�
            require(amountInCents >= 2500000);

            // [25000$ - 50000$) - 50% �ҧ�ߧ���
            if (amountInCents >= 2500000 && amountInCents < 5000000){
                bonusPercentage = 50;
            // [50000$ - 100000$) - 75% �ҧ�ߧ���
            }else if(amountInCents >= 5000000 && amountInCents < 10000000){
                bonusPercentage = 75;
            // >= 100000$ - 100% �ҧ�ߧ���
            }else if(amountInCents >= 10000000){
                bonusPercentage = 100;
            }else{
                revert();
            }

        // �֧�ݧ� �٧ѧ���֧ߧ� �ӧ���ѧ� ���ѧէڧ�
        } else if(currentState == State.SecondStageFunding){
            // ������֧ߧ� ����էѧߧߧ�� ���ܧ֧ߧ��, �ҧ�է֧� ���ڧ�ѧ�� �� �ާߧ�اڧ�֧ݧ֧� 10, ��.��. �֧��� �է��ҧߧ�� �٧ߧѧ�֧ߧڧ�
            bonusStateMultiplier = 10;

            // �����-�ӧ� ����էѧߧߧ�� ���ܧ֧ߧ�� �ߧ�اߧ� ���ڧ�ѧ�� ��� �٧ߧѧ�֧ߧڧ� ��֧� ���ܧ֧ߧ��, �ܧ������ ���֧էߧѧ٧ߧѧ�֧ߧ� �էݧ� ����էѧ�, ��.��. secondStageTokensForSale
            uint tokensSoldPercentage = secondStageTokensSold.mul(100).div(secondStageTokensForSale.mul(tokenMultiplier));

            // �ާ֧ߧ��� 7$ �ߧ� ���ڧߧڧާѧ֧�
            require(amountInCents >= 700);

            // (0% - 10%) - 20% �ҧ�ߧ���
            if (tokensSoldPercentage >= 0 && tokensSoldPercentage < 10){
                bonusPercentage = 200;
            // [10% - 20%) - 17.5% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 10 && tokensSoldPercentage < 20){
                bonusPercentage = 175;
            // [20% - 30%) - 15% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 20 && tokensSoldPercentage < 30){
                bonusPercentage = 150;
            // [30% - 40%) - 12.5% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 30 && tokensSoldPercentage < 40){
                bonusPercentage = 125;
            // [40% - 50%) - 10% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 40 && tokensSoldPercentage < 50){
                bonusPercentage = 100;
            // [50% - 60%) - 8% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 50 && tokensSoldPercentage < 60){
                bonusPercentage = 80;
            // [60% - 70%) - 6% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 60 && tokensSoldPercentage < 70){
                bonusPercentage = 60;
            // [70% - 80%) - 4% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 70 && tokensSoldPercentage < 80){
                bonusPercentage = 40;
            // [80% - 90%) - 2% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 80 && tokensSoldPercentage < 90){
                bonusPercentage = 20;
            // >= 90% - 0% �ҧ�ߧ���
            }else if (tokensSoldPercentage >= 90){
                bonusPercentage = 0;
            }else{
                revert();
            }
        } else revert();

        // ��ܧ�ݧ�ܧ� ���ܧ֧ߧ�� �ߧ�اߧ� �ӧ�էѧ�� �ҧ֧� �ҧ�ߧ���
        uint resultValue = amountInCents.mul(tokenMultiplier).div(oneTokenInCents);

        // �� ���֧��� �ҧ�ߧ���
        uint tokenAmount = resultValue.mul(bonusStateMultiplier.mul(100).add(bonusPercentage)).div(bonusStateMultiplier.mul(100));

        // �ܧ�ѧ֧ӧ�� ��ݧ��ѧ�, �ܧ�ԧէ� �٧ѧ����ڧݧ� �ҧ�ݧ���, ��֧� �ާ�ا֧� �ӧ�էѧ��
        uint tokensLeft = getTokensLeftForSale(currentState);
        if (tokenAmount > tokensLeft){
            tokenAmount = tokensLeft;
        }

        // �����-�ӧ� 0?, �է֧ݧѧ֧� ���ܧѧ�
        require(tokenAmount != 0);

        // ����ӧ�� �ڧߧӧ֧����?
        if (investedAmountOf[receiver] == 0) {
            investorCount++;
        }

        // ���ڧէѧ֧� ���ܧ֧ߧ� �ڧߧӧ֧�����
        internalAssignTokens(receiver, tokenAmount, weiAmount, amountInCents, txId);

        // ���ҧߧ�ӧݧ�֧� ���ѧ�ڧ��ڧܧ�
        updateStat(currentState, receiver, tokenAmount, weiAmount);

        // ���ݧ֧� �ߧ� �ܧ��֧ݧק� ���ڧ�
        // ����ߧܧ�ڧ� - �����ݧ�ۧܧ� �էݧ� �ӧ�٧ާ�اߧ���� ��֧�֧���֧է֧ݧ֧ߧڧ� �� �է��֧�ߧڧ� �ܧݧѧ��ѧ�
        // ����ݧ� ���� �ӧߧ֧�ߧڧ� �ӧ�٧��, ��� �է֧��٧ڧ� �ߧ� �ܧݧѧէ֧�
        if (txId == 0){
            internalDeposit(destinationMultisigWallet, weiAmount);
        }

        // ����ا֧� ��֧�֧���֧է֧ݧ�֧���� �� �ߧѧ�ݧ֧էߧڧܧѧ�
    }

    /**
     * ���ڧ٧ܧ����ӧߧ֧ӧѧ� ���ߧܧ�ڧ� ��֧�֧ӧ�է� ���ڧ�� �ߧ� �ܧ�ߧ��ѧܧ�, ���ߧܧ�ڧ� �է�����ߧ� �էݧ� ��֧�֧���֧է֧ݧ֧ߧڧ� �� �է��֧�ߧڧ� �ܧݧѧ��ѧ�, �ߧ� �ߧ� ���ҧݧڧ�ߧ�
     */
    function internalDeposit(address receiver, uint weiAmount) internal{
        // ���֧�֧���֧է֧ݧ�֧��� �� �ߧѧ�ݧ֧էߧڧܧѧ�
    }

    /**
     * ���ڧ٧ܧ����ӧߧ֧ӧѧ� ���ߧܧ�ڧ� �էݧ� �ӧ�٧ӧ�ѧ�� ���֧է���, ���ߧܧ�ڧ� �է�����ߧ� �էݧ� ��֧�֧���֧է֧ݧ֧ߧڧ� �� �է��֧�ߧڧ� �ܧݧѧ��ѧ�, �ߧ� �ߧ� ���ҧݧڧ�ߧ�
     */
    function internalRefund(address receiver, uint weiAmount) internal{
        // ���֧�֧���֧է֧ݧ�֧��� �� �ߧѧ�ݧ֧էߧڧܧѧ�
    }

    /**
     * ���ڧ٧ܧ����ӧߧ֧ӧѧ� ���ߧܧ�ڧ� �էݧ� �ӧܧݧ��֧ߧڧ� ��֧اڧާ� �ӧ�٧ӧ�ѧ�� ���֧է���
     */
    function internalEnableRefunds() internal{
        // ���֧�֧���֧է֧ݧ�֧��� �� �ߧѧ�ݧ֧էߧڧܧѧ�
    }

    /**
     * ����֧�. ���ߧܧ�ڧ�, �ܧ����ѧ� ���٧ӧ�ݧ�֧� ����էѧӧѧ�� ���ܧ֧ߧ� �ӧߧ� ��֧ߧ�ӧ�� ���ݧڧ�ڧܧ�, �է�����ܧ� ���ݧ�ܧ� �ӧݧѧէ֧ݧ���
     * ���֧٧�ݧ��ѧ�� ��ڧ����� �� ��ҧ��� ���ѧ�ڧ��ڧܧ�, �ҧ֧� ��ѧ٧է֧ݧ֧ߧڧ� �ߧ� ���ѧէڧ�
     * @param receiver - ���ݧ��ѧ�֧ݧ�
     * @param tokenAmount - ��ҧ�֧� �ܧ��-�ӧ� ���ܧ֧ߧ�� c decimals!!!
     * @param weiAmount - ��֧ߧ� �� wei
     */
    function internalPreallocate(State currentState, address receiver, uint tokenAmount, uint weiAmount) internal {
        // C�ܧ�ݧ�ܧ� ���ܧ֧ߧ�� ����ѧݧ��� �էݧ� ����էѧا�? ����ݧ��� ����ԧ� �٧ߧѧ�֧ߧڧ� �ӧ�էѧ�� �ߧ� �ާ�ا֧�!
        require(getTokensLeftForSale(currentState) >= tokenAmount);

        // ����ا֧� �ҧ��� 0, �ӧ�էѧ֧� ���ܧ֧ߧ� �ҧ֧��ݧѧ�ߧ�
        internalAssignTokens(receiver, tokenAmount, weiAmount, getWeiInCents(weiAmount), 0);

        // ���ҧߧ�ӧݧ�֧� ���ѧ�ڧ��ڧܧ�
        updateStat(currentState, receiver, tokenAmount, weiAmount);

        // ����ا֧� ��֧�֧���֧է֧ݧ�֧���� �� �ߧѧ�ݧ֧էߧڧܧѧ�
    }

    /**
     * ���ڧ٧ܧ����ӧߧ֧ӧѧ� ���ߧܧ�ڧ� �էݧ� �է֧ۧ��ӧڧ�, �� ��ݧ��ѧ� ����֧��
     */
    function internalSuccessOver() internal {
        // ���֧�֧���֧է֧ݧ�֧��� �� �ߧѧ�ݧ֧էߧڧܧѧ�
    }

    /**
     * ����ߧܧ�ڧ�, �ܧ����ѧ� ��֧�֧���֧է֧ݧ�֧��� �� �ߧѧէݧ֧էߧڧܧѧ� �� �ӧ���ݧߧ�֧��� ����ݧ� ����ѧߧ�ӧܧ� �ѧէ�֧�� �ѧܧܧѧ�ߧ�� �էݧ� ��֧�֧ӧ�է� ���֧է���
     */
    function internalSetDestinationMultisigWallet(address destinationAddress) internal{
    }

    /**
     * ���ҧߧ�ӧݧ�֧� ���ѧ�ڧ��ڧܧ� �էݧ� ��֧�ӧ�� �ڧݧ� �ӧ����� ���ѧէڧ�
     */
    function updateStat(State currentState, address receiver, uint tokenAmount, uint weiAmount) private{
        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokenAmount);

        // ����ݧ� ���� ��֧�ӧѧ� ���ѧէڧ�
        if (currentState == State.FirstStageFunding){
            // ���ӧ֧ݧڧ�ڧӧѧ֧� ���ѧ��
            firstStageRaisedInWei = firstStageRaisedInWei.add(weiAmount);
            firstStageTokensSold = firstStageTokensSold.add(tokenAmount);
        }

        // ����ݧ� ���� �ӧ���ѧ� ���ѧէڧ�
        if (currentState == State.SecondStageFunding){
            // ���ӧ֧ݧڧ�ڧӧѧ֧� ���ѧ��
            secondStageRaisedInWei = secondStageRaisedInWei.add(weiAmount);
            secondStageTokensSold = secondStageTokensSold.add(tokenAmount);
        }

        investedAmountOf[receiver] = investedAmountOf[receiver].add(weiAmount);
        tokenAmountOf[receiver] = tokenAmountOf[receiver].add(tokenAmount);
    }

    /**
     * ����ߧܧ�ڧ�, �ܧ����ѧ� ���٧ӧ�ݧ�֧� �ާ֧ߧ��� �ѧէ�֧� �ѧܧܧѧ�ߧ��, �ܧ�է� �ҧ�է�� ��֧�֧ӧ֧է֧ߧ� ���֧է��ӧ�, �� ��ݧ��ѧ� ����֧��,
     * �ާ֧ߧ��� �ާ�ا֧� ���ݧ�ܧ� �ӧݧѧէ֧ݧ֧� �� ���ݧ�ܧ� �� ��ݧ��ѧ� �֧�ݧ� ����էѧا� �֧�� �ߧ� �٧ѧӧ֧��֧ߧ� ����֧���
     */
    function setDestinationMultisigWallet(address destinationAddress) public onlyOwner canSetDestinationMultisigWallet{
        destinationMultisigWallet = destinationAddress;

        internalSetDestinationMultisigWallet(destinationAddress);
    }

    /**
     * ����ߧܧ�ڧ�, �ܧ����ѧ� �٧ѧէѧ֧� ��֧ܧ��ڧ� �ܧ��� eth �� ��֧ߧ�ѧ�
     */
    function changeCurrentEtherRateInCents(uint value) public onlyOwner {
        // ����ݧ� ��ݧ��ѧۧߧ� �٧ѧէѧݧ� 0, �ߧ� ���ܧѧ��ӧѧ֧� ���ѧߧ٧ѧܧ�ڧ�
        require(value > 0);

        currentEtherRateInCents = value;

        ExchangeRateChanged(currentEtherRateInCents, value);
    }

    /**
    * ���ѧ٧է֧ݧڧ� �ߧ� 2 �ާ֧��է�, ����ҧ� �ߧ� �٧ѧ���ѧ���� ���� �ӧ�٧�ӧ�
    * ����� ���ߧܧ�ڧ� �ߧ�اߧ� �� 2-�� ��ݧ��ѧ��: �ߧ֧ާߧ�ԧ� �ߧ� ���ҧ�ѧݧ� �է� Cap'��, ��ѧާ� �է�ܧڧէ�ӧѧ֧� �ߧ֧�ҧ��էڧާ�� ���ާާ�, �֧��� ���ڧӧѧ�ߧ�� �ڧߧӧ֧�����, �էݧ� �ܧ������ ����֧��ӧ��� ����ҧ�� ���ݧ�ӧڧ�
    */

    /* ���ݧ� ��֧�ӧ�� ���ѧէڧ� */
    function preallocateFirstStage(address receiver, uint tokenAmount, uint weiAmount) public onlyOwner isFirstStageFundingOrEnd {
        internalPreallocate(State.FirstStageFunding, receiver, tokenAmount, weiAmount);
    }

    /* ���ݧ� �ӧ����� ���ѧէڧ�, �ӧ�էѧ�� �ާ�ا֧� �ߧ� �ҧ�ݧ��� ����ѧ�ܧ� �էݧ� ����էѧا� */
    function preallocateSecondStage(address receiver, uint tokenAmount, uint weiAmount) public onlyOwner isSecondStageFundingOrEnd {
        internalPreallocate(State.SecondStageFunding, receiver, tokenAmount, weiAmount);
    }

    /* �� ��ݧ��ѧ� ����֧��, �٧ѧҧݧ�ܧڧ��ӧѧߧߧ�� ���ܧ֧ߧ� �էݧ� �ܧ�ާѧߧէ� �ާ�ԧ�� �ҧ��� �ӧ����֧ҧ�ӧѧߧ� ���ݧ�ܧ� �֧�ݧ� �ߧѧ����ڧݧ� ����֧է֧ݧ֧ߧߧѧ� �էѧ�� */
    function issueTeamTokens() public onlyOwner inState(State.Success) {
        require(block.timestamp >= teamTokensIssueDate);

        uint teamTokenTransferAmount = teamTokenAmount.mul(10 ** token.decimals());

        if (!token.transfer(teamAccount, teamTokenTransferAmount)) revert();
    }

    /**
    * ���ܧݧ��ѧ֧� ��֧اڧ� �ӧ�٧ӧ�ѧ���, ���ݧ�ܧ� �� ��ݧ��ѧ� �֧�ݧ� ��֧اڧ� �ӧ�٧ӧ�ѧ�� �֧�� �ߧ� ����ѧߧ�ӧݧ֧� �� ����էѧا� �ߧ� �٧ѧӧ֧��֧ߧ� ����֧���
    * ����٧ӧѧ�� �ާ�اߧ� ���ݧ�ܧ� 1 ��ѧ�
    */
    function enableRefunds() public onlyOwner canEnableRefunds{
        isRefundingEnabled = true;

        // ���اڧԧѧ֧� ����ѧ�ܧ� �ߧ� �ҧѧݧѧߧ�� ��֧ܧ��֧ԧ� �ܧ�ߧ��ѧܧ��
        token.burnAllOwnerTokens();

        internalEnableRefunds();
    }

    /**
     * ����ܧ��ܧ� ���ܧ֧ߧ��, �ܧڧէѧ֧� ���ܧ֧ߧ� �ߧ� �ѧէ�֧� �����ѧӧڧ�֧ݧ�
     */
    function buy() public payable {
        internalInvest(msg.sender, msg.value, 0);
    }

    /**
     * ����ܧ��ܧ� ���ܧ֧ߧ�� ��֧�֧� �ӧߧ֧�ߧڧ� ��ڧ��֧ާ�
     */
    function externalBuy(address buyerAddress, uint weiAmount, uint txId) external onlyOwner {
        require(txId != 0);

        internalInvest(buyerAddress, weiAmount, txId);
    }

    /**
     * ���ߧӧ֧����� �ާ�ԧ�� �٧ѧ��֧ҧ�ӧѧ�� �ӧ�٧ӧ�ѧ� ���֧է���, ���ݧ�ܧ� �� ��ݧ��ѧ�, �֧�ݧ� ��֧ܧ��֧� �������ߧڧ� - Refunding
     */
    function refund() public inState(State.Refunding) {
        // ����ݧ��ѧ֧� �٧ߧѧ�֧ߧڧ�, �ܧ������ �ߧѧ� �ҧ�ݧ� ��֧�֧ӧ֧է֧ߧ� �� ���ڧ��
        uint weiValue = investedAmountOf[msg.sender];

        require(weiValue != 0);

        // �����-�ӧ� ���ܧ֧ߧ�� �ߧ� �ҧѧݧѧߧ��, �ҧ֧�֧� 2 �٧ߧѧ�֧ߧڧ�: �ܧ�ߧ��ѧܧ� ����էѧ� �� �ܧ�ߧ��ѧܧ� ���ܧ֧ߧ�.
        // ���֧�ߧ��� wei �ާ�ا֧� ���ݧ�ܧ� ���ԧէ�, �ܧ�ԧէ� ���� �٧ߧѧ�֧ߧڧ� ���ӧ�ѧէѧ��, �֧�ݧ� �ߧ� ���ӧ�ѧէѧ��, �٧ߧѧ�ڧ� �ҧ�ݧ� �ܧѧܧڧ�-���
        // �ާѧߧڧ��ݧ��ڧ� �� ���ܧ֧ߧѧާ� �� ��ѧܧڧ� ��ڧ��ѧ�ڧ� �ҧ�է�� ��֧�ѧ���� �� �ڧߧէڧӧڧէ�ѧݧ�ߧ�� �����էܧ�, ��� �٧ѧ�����
        uint saleContractTokenCount = tokenAmountOf[msg.sender];
        uint tokenContractTokenCount = token.balanceOf(msg.sender);

        require(saleContractTokenCount <= tokenContractTokenCount);

        investedAmountOf[msg.sender] = 0;
        weiRefunded = weiRefunded.add(weiValue);

        // ����ҧ��ڧ� �ԧ֧ߧ֧�ڧ��֧��� �� �ߧѧ�ݧ֧էߧڧܧѧ�
        internalRefund(msg.sender, weiValue);
    }

    /**
     * ���ڧߧѧݧڧ٧ѧ��� ��֧�ӧ�� ���ѧէڧ�, �ӧ�٧ӧѧ�� �ާ�ا֧� ���ݧ�ܧ� �ӧݧѧէ֧ݧ֧� ���� ���ݧ�ӧڧ� �֧�� �ߧ֧٧ѧӧ֧��ڧӧ�֧ۧ�� ����էѧا�
     * ����ݧ� �ӧ�٧ӧѧ� halt, ��� ��ڧߧѧݧڧ٧ѧ��� �ӧ�٧ӧѧ�� �ߧ� �ާ�ا֧�
     * ����٧ӧѧ�� �ާ�اߧ� ���ݧ�ܧ� 1 ��ѧ�
     */
    function finalizeFirstStage() public onlyOwner isNotSuccessOver {
        require(!isFirstStageFinalized);

        // ���اڧԧѧ֧� ����ѧ�ܧ�
        // ����֧ԧ� �ާ�ا֧� ����էѧ�� firstStageTotalSupply
        // �����էѧݧ� - firstStageTokensSold
        // ����� ���ܧ֧ߧ� �ߧ� �ҧѧݧѧߧ�� �ܧ�ߧ��ѧܧ�� ��اڧԧѧ֧� - ���� �ҧ�է֧� ����ѧ���

        token.burnAllOwnerTokens();

        // ���֧�֧��էڧ� �ܧ� �ӧ����� ���ѧէڧ�
        // ����ݧ� ���ӧ���ߧ� �ӧ�٧ӧѧ�� ��ڧߧѧݧڧ٧ѧ���, ��� �֧�� ��ѧ� ���ܧ֧ߧ� �ߧ� ���٧էѧէ����, ���ݧ�ӧڧ� �ӧߧ����
        mintTokensForSecondStage();

        isFirstStageFinalized = true;
    }

    /**
     * ���ڧߧѧݧڧ٧ѧ��� �ӧ����� ���ѧէڧ�, �ӧ�٧ӧѧ�� �ާ�ا֧� ���ݧ�ܧ� �ӧݧѧէ֧ݧ֧�, �� ���ݧ�ܧ� �� ��ݧ��ѧ� ��ڧߧڧݧڧ٧ڧ��ӧѧߧߧ�� ��֧�ӧ�� ���ѧէڧ�
     * �� ���ݧ�ܧ� �� ��ݧ��ѧ�, �֧�ݧ� ��ҧ��� �֧�� �ߧ� �٧ѧӧ֧��ڧݧڧ�� ����֧���. ����ݧ� �ӧ�٧ӧѧ� halt, ��� ��ڧߧѧݧڧ٧ѧ��� �ӧ�٧ӧѧ�� �ߧ� �ާ�ا֧�.
     * ����٧ӧѧ�� �ާ�اߧ� ���ݧ�ܧ� 1 ��ѧ�
     */
    function finalizeSecondStage() public onlyOwner isNotSuccessOver {
        require(isFirstStageFinalized && !isSecondStageFinalized);

        // ���اڧԧѧ֧� ����ѧ�ܧ�
        // ����֧ԧ� �ާ�ا֧� ����էѧ�� secondStageTokensForSale
        // �����էѧݧ� - secondStageTokensSold
        // ���ѧ٧ߧڧ�� �ߧ�اߧ� ��ا֧��, �� �ݧ�ҧ�� ��ݧ��ѧ�

        // ����ݧ� �է���ڧԧߧ�� Soft Cap, ��� ���ڧ�ѧ֧� �ӧ����� ���ѧէڧ� ����֧�ߧ��
        if (isSoftCapGoalReached()){
            uint tokenMultiplier = 10 ** token.decimals();

            uint remainingTokens = secondStageTokensForSale.mul(tokenMultiplier).sub(secondStageTokensSold);

            // ����ݧ� �ܧ��-�ӧ� ����ѧӧ�ڧ��� ���ܧ֧ߧ�� > 0, ��� ��اڧԧѧ֧� �ڧ�
            if (remainingTokens > 0){
                token.burnOwnerTokens(remainingTokens);
            }

            // ���֧�֧ӧ�էڧ� �ߧ� ���էԧ���ӧݧ֧ߧߧ�� �ѧܧܧѧ�ߧ��: advisorsWalletAddress, marketingWalletAddress, teamWalletAddress
            uint advisorsTokenTransferAmount = advisorsTokenAmount.mul(tokenMultiplier);
            uint marketingTokenTransferAmount = marketingTokenAmount.mul(tokenMultiplier);
            uint supportTokenTransferAmount = supportTokenAmount.mul(tokenMultiplier);

            // ����ܧ֧ߧ� �էݧ� �ܧ�ާѧߧէ� �٧ѧҧݧ�ܧڧ��ӧѧߧ� �է� �էѧ�� teamTokensIssueDate �� �ާ�ԧ�� �ҧ��� �ӧ����֧ҧ�ӧѧߧ�, ���ݧ�ܧ� ���� �ӧ�٧�ӧ� ���֧�. ���ߧܧ�ڧ�
            // issueTeamTokens

            if (!token.transfer(advisorsAccount, advisorsTokenTransferAmount)) revert();
            if (!token.transfer(marketingAccount, marketingTokenTransferAmount)) revert();
            if (!token.transfer(supportAccount, supportTokenTransferAmount)) revert();

            // ����ߧ��ѧܧ� �ӧ���ݧߧ֧�!
            isSuccessOver = true;

            // ����٧�ӧѧ֧� �ާ֧��� ����֧��
            internalSuccessOver();
        }else{
            // ����ݧ� �ߧ� ���ҧ�ѧݧ� Soft Cap, ��� ��اڧԧѧ֧� �ӧ�� ���ܧ֧ߧ� �ߧ� �ҧѧݧѧߧ�� �ܧ�ߧ��ѧܧ��
            token.burnAllOwnerTokens();
        }

        isSecondStageFinalized = true;
    }

    /**
     * ����٧ӧ�ݧ�֧� �ާ֧ߧ��� �ӧݧѧէ֧ݧ��� �էѧ�� ���ѧէڧ�
     */
    function setFirstStageStartsAt(uint time) public onlyOwner {
        firstStageStartsAt = time;

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        FirstStageStartsAtChanged(firstStageStartsAt);
    }

    function setFirstStageEndsAt(uint time) public onlyOwner {
        firstStageEndsAt = time;

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        FirstStageEndsAtChanged(firstStageEndsAt);
    }

    function setSecondStageStartsAt(uint time) public onlyOwner {
        secondStageStartsAt = time;

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        SecondStageStartsAtChanged(secondStageStartsAt);
    }

    function setSecondStageEndsAt(uint time) public onlyOwner {
        secondStageEndsAt = time;

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        SecondStageEndsAtChanged(secondStageEndsAt);
    }

    /**
     * ����٧ӧ�ݧ�֧� �ާ֧ߧ��� �ӧݧѧէ֧ݧ��� Cap'��
     */
    function setSoftCapInCents(uint value) public onlyOwner {
        require(value > 0);

        softCapFundingGoalInCents = value;

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        SoftCapChanged(softCapFundingGoalInCents);
    }

    function setHardCapInCents(uint value) public onlyOwner {
        require(value > 0);

        hardCapFundingGoalInCents = value;

        // ����٧�ӧѧ֧� ���ҧ��ڧ�
        HardCapChanged(hardCapFundingGoalInCents);
    }

    /**
     * �����ӧ֧�ܧ� ��ҧ��� Soft Cap'��
     */
    function isSoftCapGoalReached() public constant returns (bool) {
        // �����ӧ֧�ܧ� ��� ��֧ܧ��֧ާ� �ܧ���� �� ��֧ߧ�ѧ�, ���ڧ�ѧ֧� ��� ��ҧ�ڧ� ����էѧ�
        return getWeiInCents(weiRaised) >= softCapFundingGoalInCents;
    }

    /**
     * �����ӧ֧�ܧ� ��ҧ��� Hard Cap'��
     */
    function isHardCapGoalReached() public constant returns (bool) {
        // �����ӧ֧�ܧ� ��� ��֧ܧ��֧ާ� �ܧ���� �� ��֧ߧ�ѧ�, ���ڧ�ѧ֧� ��� ��ҧ�ڧ� ����էѧ�
        return getWeiInCents(weiRaised) >= hardCapFundingGoalInCents;
    }

    /**
     * ����٧ӧ�ѧ�ѧ֧� �ܧ��-�ӧ� �ߧ֧�ѧ����էѧߧߧ�� ���ܧ֧ߧ��, �ܧ������ �ާ�اߧ� ����էѧ��, �� �٧ѧӧڧ�ڧާ���� ��� ���ѧէڧ�
     */
    function getTokensLeftForSale(State forState) public constant returns (uint) {
        // �����-�ӧ� ���ܧ֧ߧ��, �ܧ������ �ѧէ�֧� �ܧ�ߧ��ѧܧ�� �ާ�ا֧�� ��ߧ��� �� owner'�� �� �֧��� �ܧ��-�ӧ� ����ѧӧ�ڧ��� ���ܧ֧ߧ��, �ڧ� ����� ���ާާ� �ߧ�اߧ� �ӧ��֧��� �ܧ��-�ӧ� �ܧ������ �ߧ� ���ѧ��ӧ�֧� �� ����էѧا�
        uint tokenBalance = token.balanceOf(address(this));
        uint tokensReserve = 0;
        if (forState == State.SecondStageFunding) tokensReserve = secondStageReserve.mul(10 ** token.decimals());

        if (tokenBalance <= tokensReserve){
            return 0;
        }

        return tokenBalance.sub(tokensReserve);
    }

    /**
     * ����ݧ��ѧ֧� ���֧ۧ�
     *
     * ���� ��ڧ�֧� �� ��֧�֧ާ֧ߧߧ��, ����ҧ� �ߧ� �ҧ�ݧ� �ӧ�٧ާ�اߧ���� ���ާ֧ߧ��� �ڧ٧ӧߧ�, ���ݧ�ܧ� �ӧ�٧�� ���ߧܧ�ڧ� �ާ�ا֧� ����ѧ٧ڧ�� ��֧ܧ��֧� �������ߧڧ�
     * ����. �ԧ�ѧ� �������ߧڧ�
     */
    function getState() public constant returns (State) {
        // ����ߧ��ѧܧ� �ӧ���ݧߧ֧�
        if (isSuccessOver) return State.Success;

        // ����ߧ��ѧܧ� �ߧѧ��էڧ��� �� ��֧اڧާ� �ӧ�٧ӧ�ѧ��
        if (isRefundingEnabled) return State.Refunding;

        // ����ߧ��ѧܧ� �֧�� �ߧ� �ߧѧ�ѧ� �է֧ۧ��ӧ�ӧѧ��
        if (block.timestamp < firstStageStartsAt) return State.PreFunding;

        //����ݧ� ��֧�ӧѧ� ���ѧէڧ� - �ߧ� ��ڧߧѧݧڧ٧ڧ��ӧѧߧ�
        if (!isFirstStageFinalized){
            // ���ݧѧ� ���ԧ�, ���� ��֧ܧ��ѧ� �էѧ�� �ߧѧ��էڧ��� �� �ڧߧ�֧�ӧѧݧ� ��֧�ӧ�� ���ѧէڧ�
            bool isFirstStageTime = block.timestamp >= firstStageStartsAt && block.timestamp <= firstStageEndsAt;

            // ����ݧ� �ڧէ֧� ��֧�ӧѧ� ���ѧէڧ�
            if (isFirstStageTime) return State.FirstStageFunding;
            // ���ߧѧ�� ��֧�ӧ�� ���ѧ� - �٧ѧܧ�ߧ�֧�
            else return State.FirstStageEnd;

        } else {

            // ����ݧ� ��֧�ӧѧ� ���ѧէڧ� ��ڧߧѧݧڧ٧ڧ��ӧѧߧ� �� ��֧ܧ��֧� �ӧ�֧ާ� �ҧݧ�� ��֧ۧߧ� �ާ֧ߧ��� �ߧѧ�ѧݧ� �ӧ����� ���ѧէڧ�, ��� ���� ��٧ߧѧ�ѧ֧�, ���� ��֧�ӧѧ� ���ѧէڧ� - ��ܧ�ߧ�֧ߧ�
            if(block.timestamp < secondStageStartsAt)return State.FirstStageEnd;

            // ���ݧѧ� ���ԧ�, ���� ��֧ܧ��ѧ� �էѧ�� �ߧѧ��էڧ��� �� �ڧߧ�֧�ӧѧݧ� �ӧ����� ���ѧէڧ�
            bool isSecondStageTime = block.timestamp >= secondStageStartsAt && block.timestamp <= secondStageEndsAt;

            // ���֧�ӧѧ� ���ѧէڧ� ��ڧߧѧݧڧ٧ڧ��ӧѧߧ�, �ӧ���ѧ� - ��ڧߧѧݧڧ٧ڧ��ӧѧߧ�
            if (isSecondStageFinalized){

                // ����ݧ� �ߧѧҧ�ѧݧ� Soft Cap ���� ���ݧ�ӧڧ� ��ڧߧѧݧڧ٧ѧ�ڧ� �ӧ����� ��էѧէڧ� - ���� ����֧�ߧ�� �٧ѧܧ���ڧ� ����էѧ�
                if (isSoftCapGoalReached())return State.Success;
                // ����ҧ�ѧ�� Soft Cap �ߧ� ��էѧݧ���, ��֧ܧ��֧� �������ߧڧ� - ����ӧѧ�
                else return State.Failure;

            }else{

                // ������ѧ� ���ѧէڧ� - �ߧ� ��ڧߧѧݧڧ٧ڧ��ӧѧߧ�
                if (isSecondStageTime)return State.SecondStageFunding;
                // ������ѧ� ���ѧէڧ� - �٧ѧܧ�ߧ�ڧݧѧ��
                else return State.SecondStageEnd;

            }
        }
    }

   /**
    * ����էڧ�ڧܧѧ����
    */

    /** ����ݧ�ܧ�, �֧�ݧ� ��֧ܧ��֧� �������ߧڧ� �����ӧ֧��ӧ�֧� �������ߧڧ�  */
    modifier inState(State state) {
        require(getState() == state);

        _;
    }

    /** ����ݧ�ܧ�, �֧�ݧ� ��֧ܧ��֧� �������ߧڧ� - ����էѧا�: ��֧�ӧѧ� �ڧݧ� �ӧ���ѧ� ���ѧէڧ� */
    modifier inFirstOrSecondFundingState() {
        State curState = getState();
        require(curState == State.FirstStageFunding || curState == State.SecondStageFunding);

        _;
    }

    /** ����ݧ�ܧ�, �֧�ݧ� �ߧ� �է���ڧԧߧ�� Hard Cap */
    modifier notHardCapReached(){
        require(!isHardCapGoalReached());

        _;
    }

    /** ����ݧ�ܧ�, �֧�ݧ� ��֧ܧ��֧� �������ߧڧ� - ����էѧا� ��֧�ӧ�� ���ѧէڧ� �ڧݧ� ��֧�ӧѧ� ���ѧէڧ� �٧ѧܧ�ߧ�ڧݧѧ�� */
    modifier isFirstStageFundingOrEnd() {
        State curState = getState();
        require(curState == State.FirstStageFunding || curState == State.FirstStageEnd);

        _;
    }

    /** ����ݧ�ܧ�, �֧�ݧ� �ܧ�ߧ��ѧܧ� �ߧ� ��ڧߧѧݧڧ٧ڧ��ӧѧ� */
    modifier isNotSuccessOver() {
        require(!isSuccessOver);

        _;
    }

    /** ����ݧ�ܧ�, �֧�ݧ� �ڧէ֧� �ӧ���ѧ� ���ѧէڧ� �ڧݧ� �ӧ���ѧ� ���ѧէڧ� �٧ѧӧ֧��ڧݧѧ�� */
    modifier isSecondStageFundingOrEnd() {
        State curState = getState();
        require(curState == State.SecondStageFunding || curState == State.SecondStageEnd);

        _;
    }

    /** ����ݧ�ܧ�, �֧�ݧ� �֧�� �ߧ� �ӧܧݧ��֧� ��֧اڧ� �ӧ�٧ӧ�ѧ�� �� ����էѧا� �ߧ� �٧ѧӧ֧��֧ߧ� ����֧��� */
    modifier canEnableRefunds(){
        require(!isRefundingEnabled && getState() != State.Success);

        _;
    }

    /** ����ݧ�ܧ�, �֧�ݧ� ����էѧا� �ߧ� �٧ѧӧ֧��֧ߧ� ����֧��� */
    modifier canSetDestinationMultisigWallet(){
        require(getState() != State.Success);

        _;
    }
}

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

/**
 * ���ѧҧݧ�� �ܧݧѧ��� ���ѧߧڧݧڧ�� ���֧է���, �ܧ������ �ڧ���ݧ�٧�֧��� �� �ܧ�ߧ��ѧܧ�� ����էѧ�
 * ����էէ֧�اڧӧѧ֧� �ӧ�٧ӧ�ѧ� ���֧է���, �� ��ѧܧ�� ��֧�֧ӧ�� ���֧է��� �ߧ� �ܧ��֧ݧ֧�, �� ��ݧ��ѧ� ����֧�ߧ�ԧ� ����ӧ֧է֧ߧڧ� ����էѧ�
 */
contract FundsVault is Ownable, ValidationUtil {
    using SafeMath for uint;
    using Math for uint;

    enum State {Active, Refunding, Closed}

    mapping (address => uint256) public deposited;

    address public wallet;

    State public state;

    event Closed();

    event RefundsEnabled();

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    /**
     * ���ܧѧ٧�ӧѧ֧� �ߧ� �ܧѧܧ�� �ܧ��֧ݧ֧� �ҧ�է�� ������ ��֧�֧ӧ֧է֧ߧ� ���ҧ�ѧߧߧ�� ���֧է��ӧ�, �� ��ݧ��ѧ�, �֧�ݧ� �ҧ�է֧� �ӧ�٧ӧѧߧ� ���ߧܧ�ڧ� close()
     * ����էէ֧�اڧӧѧ֧� �ӧ�٧ӧ�ѧ� ���֧է���, �� ��ѧܧ�� ��֧�֧ӧ�� ���֧է��� �ߧ� �ܧ��֧ݧ֧�, �� ��ݧ��ѧ� ����֧�ߧ�ԧ� ����ӧ֧է֧ߧڧ� ����էѧ�
     */
    function FundsVault(address _wallet) {
        requireNotEmptyAddress(_wallet);

        wallet = _wallet;

        state = State.Active;
    }

    /**
     * ����ݧ�اڧ�� �է֧��٧ڧ� �� ���ѧߧڧݧڧ��
     */
    function deposit(address investor) public payable onlyOwner inState(State.Active) {
        deposited[investor] = deposited[investor].add(msg.value);
    }

    /**
     * ���֧�֧ӧ�� ���ҧ�ѧߧߧ�� ���֧է��� �ߧ� ��ܧѧ٧ѧߧߧ�� �ܧ��֧ݧ֧�
     */
    function close() public onlyOwner inState(State.Active) {
        state = State.Closed;

        Closed();

        wallet.transfer(this.balance);
    }

    /**
     * �����ѧߧ�ӧݧڧӧѧ֧� �ܧ��֧ݧ֧�
     */
    function setWallet(address newWalletAddress) public onlyOwner inState(State.Active) {
        wallet = newWalletAddress;
    }

    /**
     * �����ѧߧ�ӧڧ�� ��֧اڧ� �ӧ�٧ӧ�ѧ�� �է֧ߧ֧�
     */
    function enableRefunds() public onlyOwner inState(State.Active) {
        state = State.Refunding;

        RefundsEnabled();
    }

    /**
     * ����ߧܧ�ڧ� �ӧ�٧ӧ�ѧ�� ���֧է���
     */
    function refund(address investor, uint weiAmount) public onlyOwner inState(State.Refunding){
        uint256 depositedValue = weiAmount.min256(deposited[investor]);
        deposited[investor] = 0;
        investor.transfer(depositedValue);

        Refunded(investor, depositedValue);
    }

    /** ����ݧ�ܧ�, �֧�ݧ� ��֧ܧ��֧� �������ߧڧ� �����ӧ֧��ӧ�֧� �������ߧڧ�  */
    modifier inState(State _state) {
        require(state == _state);

        _;
    }

}

/**
* ����ߧ��ѧܧ� ����էѧا�
* ����٧ӧ�ѧ� ���֧է��� ���էէ֧�اާӧѧ֧��� ���ݧ�ܧ� ��֧�, �ܧ�� �ܧ��ڧ� ���ܧ֧ߧ� ��֧�֧� ���ߧܧ�ڧ� internalInvest
* ���ѧܧڧ� ��ҧ�ѧ٧��, �֧�ݧ� �ڧߧӧ֧����� �ҧ�է�� ��ҧާ֧ߧڧӧѧ���� ���ܧ֧ߧѧާ�, ��� �ӧ֧�ߧ��� �ާ�اߧ� �ҧ�է֧� ���ݧ�ܧ� ��֧�, �� �ܧ�ԧ� �� �ܧ�ߧ��ѧܧ�� ����էѧ�
* ��ѧܧѧ� �ا� ���ާާ� ���ܧ֧ߧ��, �ܧѧ� �� �� �ܧ�ߧ��ѧܧ�� ���ܧ֧ߧ�, �� �����ڧӧߧ�� ��ݧ��ѧ� ��֧�֧ӧ֧է֧ߧߧ�� ���ڧ� ����ѧ֧��� �ߧѧӧ�֧ԧէ� �� ��ڧ��֧ާ� �� �ߧ� �ާ�ا֧� �ҧ��� �ӧ�ӧ֧է֧�
*/
contract RefundableAllocatedCappedCrowdsale is AllocatedCappedCrowdsale {

    /**
    * ����ѧߧڧݧڧ��, �ܧ�է� �ҧ�է�� ���ҧڧ�ѧ���� ���֧է��ӧ�, �է֧ݧѧ֧��� �էݧ� ���ԧ�, ����ҧ� �ԧѧ�ѧߧ�ڧ��ӧѧ�� �ӧ�٧ӧ�ѧ��
    */
    FundsVault public fundsVault;

    /** ���ѧ�� �ѧէ�֧� �ڧߧӧ֧����� - �ҧ�� �ݧ� ���ӧ֧��֧� �ӧ�٧ӧ�ѧ� ���֧��� */
    mapping (address => bool) public refundedInvestors;

    function RefundableAllocatedCappedCrowdsale(uint _currentEtherRateInCents, address _token, address _destinationMultisigWallet, uint _firstStageStartsAt, uint _firstStageEndsAt, uint _secondStageStartsAt, uint _secondStageEndsAt, address _advisorsAccount, address _marketingAccount, address _supportAccount, address _teamAccount, uint _teamTokensIssueDate) AllocatedCappedCrowdsale(_currentEtherRateInCents, _token, _destinationMultisigWallet, _firstStageStartsAt, _firstStageEndsAt, _secondStageStartsAt, _secondStageEndsAt, _advisorsAccount, _marketingAccount, _supportAccount, _teamAccount, _teamTokensIssueDate) {
        // ����٧էѧ֧� ��� �ܧ�ߧ��ѧܧ�� ����էѧ� �ߧ�ӧ�� ���ѧߧڧݧڧ��, �է����� �� �ߧ֧ާ� �ڧާ֧֧� ���ݧ�ܧ� �ܧ�ߧ��ѧܧ� ����էѧ�
        // ����� ����֧�ߧ�� �٧ѧӧ֧��֧ߧڧ� ����էѧ�, �ӧ�� ���ҧ�ѧߧߧ�� ���֧է��ӧ� ��������� �ߧ� _destinationMultisigWallet
        // �� �����ڧӧߧ�� ��ݧ��ѧ� �ާ�ԧ�� �ҧ��� ��֧�֧ӧ֧է֧ߧ� ��ҧ�ѧ�ߧ� �ڧߧӧ֧����ѧ�
        fundsVault = new FundsVault(_destinationMultisigWallet);

    }

    /** �����ѧߧѧӧݧڧӧѧ֧� �ߧ�ӧ�� �ܧ��֧ݧ֧� �էݧ� ��ڧߧѧݧ�ߧ�ԧ� ��֧�֧ӧ�է�
    */
    function internalSetDestinationMultisigWallet(address destinationAddress) internal{
        fundsVault.setWallet(destinationAddress);

        super.internalSetDestinationMultisigWallet(destinationAddress);
    }

    /** ���ڧߧѧݧڧ٧ѧ�ڧ� �ӧ����ԧ� ���ѧ��
    */
    function internalSuccessOver() internal {
        // �����֧�ߧ� �٧ѧܧ��ӧѧ֧� ���ѧߧڧݧڧ�� ���֧է��� �� ��֧�֧ӧ�էڧ� ���ڧ� �ߧ� ��ܧѧ٧ѧߧߧ�� �ܧ��֧ݧ֧�
        fundsVault.close();

        super.internalSuccessOver();
    }

    /** ���֧�֧���֧է֧ݧ֧ߧڧ� ���ߧܧ�ڧ� ���ڧߧ��ڧ� �է���٧ڧ�� �ߧ� ���֧�, �� �էѧߧߧ�� ��ݧ��ѧ�, �ڧէ�� �ҧ�է֧� ��֧�֧� vault
    */
    function internalDeposit(address receiver, uint weiAmount) internal{
        // ���ݧ֧� �ߧ� �ܧ��֧ݧק� ���ڧ�
        fundsVault.deposit.value(weiAmount)(msg.sender);
    }

    /** ���֧�֧���֧է֧ݧ֧ߧڧ� ���ߧܧ�ڧ� �ӧܧݧ��֧ߧڧ� �������ߧڧ� �ӧ�٧ӧ�ѧ��
    */
    function internalEnableRefunds() internal{
        super.internalEnableRefunds();

        fundsVault.enableRefunds();
    }

    /** ���֧�֧���֧է֧ݧ֧ߧڧ� ���ߧܧ�ڧ� �ӧ�٧ӧ�ѧ��, �ӧ�٧ӧ�ѧ� �ާ�اߧ� ��է֧ݧѧ�� ���ݧ�ܧ� ��ѧ�
    */
    function internalRefund(address receiver, uint weiAmount) internal{
        // ���֧ݧѧ֧� �ӧ�٧ӧ�ѧ�
        // ����էէ֧�اڧӧѧ֧� ���ݧ�ܧ� 1 �ӧ�٧ӧ�ѧ�

        if (refundedInvestors[receiver]) revert();

        fundsVault.refund(receiver, weiAmount);

        refundedInvestors[receiver] = true;
    }

}