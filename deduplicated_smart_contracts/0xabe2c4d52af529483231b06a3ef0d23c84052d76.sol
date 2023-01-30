/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint256 public totalSupply;

    function balanceOf(address who) public view returns(uint256);

    function transfer(address to, uint256 value) public returns(bool);

    function allowance(address owner, address spender) public view returns(uint256);

    function transferFrom(address from, address to, uint256 value) public returns(bool);

    function approve(address spender, uint256 value) public returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is ERC20 {
    using SafeMath
    for uint256;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;


    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract BGCToken is StandardToken {
    string public constant name = "BoFa Block Chain Token";
    string public constant symbol = "BGC";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 300000000 * (10 ** uint256(decimals));
    
    // circulation address
    address public circulationAddress = 0xbE3148D214199A04f9A2D641a74c8DF6A826d625;
    // the share of circulationAddress
    uint8 public constant CIRCULATION_ADDRESS_SHARE = 20;


    // mining address
    address public miningAddress = 0xf63c3958cC818C87F2667983B8ea004DE276096E;
    // the share of MiningAddress
    uint8 public constant MINING_ADDRESS_SHARE = 40;


    // fund address
    address public fundAddress = 0x9fe58B77Be12EEEfe5814ab1be78B16F29d65175;
    // the share of fundAddress
    uint8 public constant FUND_ADDRESS_SHARE = 20;

    // developer address
    address public developerAddress = 0x090992a898E777e25119776f119c3f2D69A45837;
    // the share of developerAddress
    uint8 public constant DEVELOPER_ADDRESS_SHARE = 10;


    // community address
    address public communityAddress = 0x7BccB3Ad1556fC55608aC5eA0b2D182E7DE7E752;
    // the share of communityAddress
    uint8 public constant COMMUNITY_ADDRESS_SHARE = 10;

    /**
     * Constructor that gives five address all existing tokens.
     */
    constructor() public {
        totalSupply = INITIAL_SUPPLY;

        uint256 valueCirculationAddress = INITIAL_SUPPLY.mul(CIRCULATION_ADDRESS_SHARE).div(100);
        balances[circulationAddress] = valueCirculationAddress;
        emit Transfer(address(0), circulationAddress, valueCirculationAddress);

        uint256 valueMiningAddress = INITIAL_SUPPLY.mul(MINING_ADDRESS_SHARE).div(100);
        balances[miningAddress] = valueMiningAddress;
        emit Transfer(address(0), miningAddress, valueMiningAddress);

        uint256 valueFundAddress = INITIAL_SUPPLY.mul(FUND_ADDRESS_SHARE).div(100);
        balances[fundAddress] = valueFundAddress;
        emit Transfer(address(0), fundAddress, valueFundAddress);

        uint256 valueDeveloperAddress = INITIAL_SUPPLY.mul(DEVELOPER_ADDRESS_SHARE).div(100);
        balances[developerAddress] = valueDeveloperAddress;
        emit Transfer(address(0), developerAddress, valueDeveloperAddress);
        

        uint256 valueCommunityAddress = INITIAL_SUPPLY.mul(COMMUNITY_ADDRESS_SHARE).div(100);
        balances[communityAddress] = valueCommunityAddress;
        emit Transfer(address(0), communityAddress, valueCommunityAddress);

    }
}