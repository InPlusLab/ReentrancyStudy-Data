pragma solidity ^0.4.18;

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
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
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

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

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
    function balanceOf(address _owner) public view returns (uint256 balance) {
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

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool) {
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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender&#39;s balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

contract UniversalCoin is BurnableToken, Ownable {

    string constant public name = "UniversalCoin";
    string constant public symbol = "UNV";
    uint256 constant public decimals = 6;
    uint256 constant public airdropReserve = 2400000000E6; // 2.4 bln tokens reserved for airdrops;
    uint256 constant public pool = 32000000000E6;

    function UniversalCoin(address uniFoundation) public {
        totalSupply = 40000000000E6; // 40 bln tokens
        balances[uniFoundation] = 5600000000E6; // 5.6 bln tokens reserved for Universal foundation
        balances[owner] = pool + airdropReserve; // 40 bln - airdrop - foundation reserve
    }

}

contract UniversalManager is Ownable {
    using SafeMath for uint256;

    uint256 public constant ADDRESS_LIMIT = 300;
    uint256 public constant TRANSFERS_PER_TRANSACTION = 150;

    uint256 public airdrop;
    UniversalCoin public token;

    uint256 private currentPool = 0;
    uint256 private index = 0;
    uint256 private airdropIndex = 0;
    address[] private participants;
    address[] private airdropParticipants;

    function UniversalManager(address uniFoundation) public {
        token = new UniversalCoin(uniFoundation);
        airdrop = token.airdropReserve().div(3);
    }

    // Set size of current week tokens pool
    function setCurrentWeekPool(uint256 _currentPool) public onlyOwner {
        require(_currentPool > 0);
        currentPool = _currentPool;
    }

    // Adds participant for the current week
    function addParticipants(address[] _participants) external onlyOwner {
        require(_participants.length != 0 && _participants.length <= ADDRESS_LIMIT);
        participants = _participants;
    }

    // Add all unique participants for receiving airdrop
    function addAirdropParticipants(address[] _airdropParticipants) public onlyOwner {
        require(_airdropParticipants.length != 0 && _airdropParticipants.length <= ADDRESS_LIMIT);
        airdropParticipants = _airdropParticipants;
    }

    // Transfer tokens to current week participants
    function transfer(uint256 _amount) public onlyOwner {
        uint256 max;
        uint256 length = participants.length;
        if ((index + TRANSFERS_PER_TRANSACTION) >= length) {
            max = length;
        } else {
            max = index + TRANSFERS_PER_TRANSACTION;
        }
        for (uint i = index; i < max; i++) {
            token.transfer(participants[i], _amount);
        }
        if (max >= length) {
            index = 0;
        } else {
            index += TRANSFERS_PER_TRANSACTION;
        }
    }

    // Transfer airdrop tokens to all registered participants
    function transferAidrop() public onlyOwner {
        uint256 max;
        uint256 length = airdropParticipants.length;
        if ((airdropIndex + TRANSFERS_PER_TRANSACTION) >= length) {
            max = length;
        } else {
            max = airdropIndex + TRANSFERS_PER_TRANSACTION;
        }
        uint256 share;
        for (uint i = airdropIndex; i < max; i++) {
            share = (airdrop.mul(token.balanceOf(airdropParticipants[i]))).div(token.totalSupply());
            if (share == 0) {
                continue;
            }
            token.transfer(airdropParticipants[i], share);
        }
        if (max >= length) {
            airdropIndex = 0;
        } else {
            airdropIndex += TRANSFERS_PER_TRANSACTION;
        }
    }
}