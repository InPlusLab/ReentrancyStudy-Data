/**
 *Submitted for verification at Etherscan.io on 2019-10-19
*/

pragma solidity >=0.5.1;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    _transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param _from The address to transfer from.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function _transfer(address _from, address _to, uint256 _value) internal {
      require(_to != address(0));
      require(_value <= balances[_from]);
  
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      emit Transfer(_from, _to, _value);
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract FreezableToken is StandardToken {
    // freezing chains
    mapping (bytes32 => uint64) internal chains;
    // freezing amounts for each chain
    mapping (bytes32 => uint) internal freezings;
    // total freezing balance per address
    mapping (address => uint) internal freezingBalance;

    // reducible freezing chains
    mapping (bytes32 => uint64) internal reducibleChains;
    // reducible freezing amounts for each chain
    mapping (bytes32 => uint) internal reducibleFreezings;
    // total reducible freezing balance per address
    mapping (address => uint) internal reducibleFreezingBalance;

    event Freezed(address indexed to, uint64 release, uint amount);
    event Released(address indexed owner, uint amount);
    event FreezeReduced(address indexed owner, uint64 release, uint amount);

    /**
     * @dev Gets the balance of the specified address include freezing tokens.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return super.balanceOf(_owner) + freezingBalance[_owner] + reducibleFreezingBalance[_owner];
    }

    /**
     * @dev Gets the balance of the specified address without freezing tokens.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function actualBalanceOf(address _owner) public view returns (uint256 balance) {
        return super.balanceOf(_owner);
    }

    function freezingBalanceOf(address _owner) public view returns (uint256 balance) {
        return freezingBalance[_owner];
    }

    function reducibleFreezingBalanceOf(address _owner) public view returns (uint256 balance) {
        return reducibleFreezingBalance[_owner];
    }

    /**
     * @dev gets freezing count
     * @param _addr Address of freeze tokens owner.
     */
    function freezingCount(address _addr) public view returns (uint count) {
        uint64 release = chains[toKey(_addr, 0)];
        while (release != 0) {
            count++;
            release = chains[toKey(_addr, release)];
        }
    }

    /**
     * @dev gets reducible freezing count
     * @param _addr Address of freeze tokens owner.
     * @param _sender Address of frozen tokens sender.
     */
    function reducibleFreezingCount(address _addr, address _sender) public view returns (uint count) {
        uint64 release = reducibleChains[toKey2(_addr, _sender, 0)];
        while (release != 0) {
            count++;
            release = reducibleChains[toKey2(_addr, _sender, release)];
        }
    }

    /**
     * @dev gets freezing end date and freezing balance for the freezing portion specified by index.
     * @param _addr Address of freeze tokens owner.
     * @param _index Freezing portion index. It ordered by release date descending.
     */
    function getFreezing(address _addr, uint _index) public view returns (uint64 _release, uint _balance) {
        for (uint i = 0; i < _index + 1; i++) {
            _release = chains[toKey(_addr, _release)];
            if (_release == 0) {
                return (0, 0);
            }
        }
        _balance = freezings[toKey(_addr, _release)];
    }

    /**
     * @dev gets reducible freezing end date and reducible freezing balance for the freezing portion specified by index.
     * @param _addr Address of freeze tokens owner.
     * @param _sender Address of frozen tokens sender.
     * @param _index Freezing portion index. It ordered by release date descending.
     */
    function getReducibleFreezing(address _addr, address _sender, uint _index) public view returns (uint64 _release, uint _balance) {
        for (uint i = 0; i < _index + 1; i++) {
            _release = reducibleChains[toKey2(_addr, _sender, _release)];
            if (_release == 0) {
                return (0, 0);
            }
        }
        _balance = reducibleFreezings[toKey2(_addr, _sender, _release)];
    }

    /**
     * @dev freeze your tokens to the specified address.
     *      Be careful, gas usage is not deterministic,
     *      and depends on how many freezes _to address already has.
     * @param _to Address to which token will be freeze.
     * @param _amount Amount of token to freeze.
     * @param _until Release date, must be in future.
     */
    function freezeTo(address _to, uint _amount, uint64 _until) public {
        _freezeTo(msg.sender, _to, _amount, _until);
    }

    /**
     * @dev freeze your tokens to the specified address.
     *      Be careful, gas usage is not deterministic,
     *      and depends on how many freezes _to address already has.
     * @param _to Address to which token will be freeze.
     * @param _amount Amount of token to freeze.
     * @param _until Release date, must be in future.
     */
    function _freezeTo(address _from, address _to, uint _amount, uint64 _until) internal {
        require(_to != address(0));
        require(_amount <= balances[_from]);

        balances[_from] = balances[_from].sub(_amount);

        bytes32 currentKey = toKey(_to, _until);
        freezings[currentKey] = freezings[currentKey].add(_amount);
        freezingBalance[_to] = freezingBalance[_to].add(_amount);

        freeze(_to, _until);
        emit Transfer(_from, _to, _amount);
        emit Freezed(_to, _until, _amount);
    }

    /**
     * @dev freeze your tokens to the specified address with posibility to reduce freezing.
     *      Be careful, gas usage is not deterministic,
     *      and depends on how many freezes _to address already has.
     * @param _to Address to which token will be freeze.
     * @param _amount Amount of token to freeze.
     * @param _until Release date, must be in future.
     */
    function reducibleFreezeTo(address _to, uint _amount, uint64 _until) public {
        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
        require(_until > block.timestamp);

        balances[msg.sender] = balances[msg.sender].sub(_amount);

        bytes32 currentKey = toKey2(_to, msg.sender, _until);
        reducibleFreezings[currentKey] = reducibleFreezings[currentKey].add(_amount);
        reducibleFreezingBalance[_to] = reducibleFreezingBalance[_to].add(_amount);

        reducibleFreeze(_to, _until);
        emit Transfer(msg.sender, _to, _amount);
        emit Freezed(_to, _until, _amount);
    }

    /**
     * @dev reduce freeze time for _amount of tokens for reducible freezing of address _to by frozen tokens sender.
     *      Removes reducible freezing for _amount of tokens if _newUntil in the past
     *      Be careful, gas usage is not deterministic,
     *      and depends on how many freezes _to address already has.
     * @param _to Address to which token will be freeze.
     * @param _amount Amount of token to freeze.
     * @param _until Release date, must be in future.
     */
    function reduceFreezingTo(address _to, uint _amount, uint64 _until, uint64 _newUntil) public {
        require(_to != address(0));

        // Don't allow to move reducible freezing to the future
        require(_newUntil < _until);

        bytes32 currentKey = toKey2(_to, msg.sender, _until);
        uint amount = reducibleFreezings[currentKey];
        require(amount > 0);

        if (_amount >= amount) {
            // use amount

            // §å§Õ§Ñ§Ý§ñ§Ö§Þ §Ò§Ý§à§Ü§Ú§â§à§Ó§Ü§å
            delete reducibleFreezings[currentKey];

            uint64 next = reducibleChains[currentKey];
            bytes32 parent = toKey2(_to, msg.sender, uint64(0));
            while (reducibleChains[parent] != _until) {
                parent = toKey2(_to, msg.sender, reducibleChains[parent]);
            }

            // §Ö§ã§Ý§Ú §á§à§ã§Ý§Ö §ä§Ö§Ü§å§ë§Ö§Û §Ò§Ý§à§Ü§Ú§â§à§Ó§Ü§Ú §Ö§ã§ä§î §ï§Ý§Ö§Þ§Ö§ß§ä§í, §ä§à §ß§å§Ø§ß§à §á§Ñ§â§Ö§ß§ä§å §Õ§Ñ§ä§î §ã§ã§í§Ý§Ü§å §ß§Ñ §ã§Ý§Ö§Õ§å§ð§ë§å§ð §Ò§Ý§à§Ü§Ú§â§à§Ó§Ü§å
            if (next == 0) {
                delete reducibleChains[parent];
            }
            else {
                reducibleChains[parent] = next;
            }

            // §Ö§ã§Ý§Ú §ß§à§Ó§Ñ§ñ §Õ§Ñ§ä§Ñ §ä§Ö§Ü§å§ë§Ñ§ñ §Ú§Ý§Ú §Ó §á§â§à§ê§Ý§à§Þ, §ä§à §Ù§Ñ§é§Ú§ã§Ý§ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã §Ú §Ó§í§é§Ú§ä§Ñ§Ö§Þ §Ú§Ù §Ò§Ý§à§Ü§Ú§â§à§Ó§à§Ü
            if (_newUntil <= block.timestamp) {
                balances[_to] = balances[_to].add(amount);
                reducibleFreezingBalance[_to] = reducibleFreezingBalance[_to].sub(amount);

                emit Released(_to, amount);
            }
            else {
                // §Õ§Ö§Ý§Ñ§Ö§Þ §ß§à§Ó§å§ð §Ò§Ý§à§Ü§Ú§â§à§Ó§Ü§å §ã §ß§à§Ó§à§Û §Õ§Ñ§ä§à§Û §Ú §ã§å§Þ§Þ§à§Û _amount
                bytes32 newKey = toKey2(_to, msg.sender, _newUntil);
                reducibleFreezings[newKey] = reducibleFreezings[newKey].add(amount);

                reducibleFreeze(_to, _newUntil);

                emit FreezeReduced(_to, _newUntil, amount);
            }
        }
        else {
            reducibleFreezings[currentKey] = reducibleFreezings[currentKey].sub(_amount);
            if (_newUntil <= block.timestamp) {
                // §Ù§Ñ§á§Ú§ã§í§Ó§Ñ§Ö§Þ §ã§å§Þ§Þ§å §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ
                balances[_to] = balances[_to].add(_amount);
                // §å§Ò§Ú§â§Ñ§Ö§Þ §Ò§Ñ§Ý§Ñ§ß§ã §Ú§Ù §Ò§Ñ§Ý§Ñ§ß§ã§Ñ §Ù§Ñ§Þ§à§â§à§Ù§à§Ü
                reducibleFreezingBalance[_to] = reducibleFreezingBalance[_to].sub(_amount);

                emit Released(_to, _amount);
            }
            else {
                // §ã§à§Ù§Õ§Ñ§Ö§Þ §ß§à§Ó§å§ð §Ò§Ý§à§Ü§Ú§â§à§Ó§Ü§å §ã _amount §Ú _untilNew
                bytes32 newKey = toKey2(_to, msg.sender, _newUntil);
                reducibleFreezings[newKey] = reducibleFreezings[newKey].add(_amount);

                reducibleFreeze(_to, _newUntil);

                emit FreezeReduced(_to, _newUntil, _amount);
            }
        }
    }

    /**
     * @dev release first available freezing tokens.
     */
    function releaseOnce() public {
        bytes32 headKey = toKey(msg.sender, 0);
        uint64 head = chains[headKey];
        require(head != 0);
        require(uint64(block.timestamp) > head);
        bytes32 currentKey = toKey(msg.sender, head);

        uint64 next = chains[currentKey];

        uint amount = freezings[currentKey];
        delete freezings[currentKey];

        balances[msg.sender] = balances[msg.sender].add(amount);
        freezingBalance[msg.sender] = freezingBalance[msg.sender].sub(amount);

        if (next == 0) {
            delete chains[headKey];
        } else {
            chains[headKey] = next;
            delete chains[currentKey];
        }
        emit Released(msg.sender, amount);
    }

    /**
     * @dev release first available reducible freezing tokens.
     * @param _sender Address of frozen tokens sender.
     */
    function releaseReducibleFreezingOnce(address _sender) public {
        bytes32 headKey = toKey2(msg.sender, _sender, 0);
        uint64 head = reducibleChains[headKey];
        require(head != 0);
        require(uint64(block.timestamp) > head);
        bytes32 currentKey = toKey2(msg.sender, _sender, head);

        uint64 next = reducibleChains[currentKey];

        uint amount = reducibleFreezings[currentKey];
        delete reducibleFreezings[currentKey];

        balances[msg.sender] = balances[msg.sender].add(amount);
        reducibleFreezingBalance[msg.sender] = reducibleFreezingBalance[msg.sender].sub(amount);

        if (next == 0) {
            delete reducibleChains[headKey];
        } else {
            reducibleChains[headKey] = next;
            delete reducibleChains[currentKey];
        }
        emit Released(msg.sender, amount);
    }

    /**
     * @dev release all available for release freezing tokens. Gas usage is not deterministic!
     * @return how many tokens was released
     */
    function releaseAll() public returns (uint tokens) {
        uint release;
        uint balance;
        (release, balance) = getFreezing(msg.sender, 0);
        while (release != 0 && block.timestamp > release) {
            releaseOnce();
            tokens += balance;
            (release, balance) = getFreezing(msg.sender, 0);
        }
    }

    /**
     * @dev release all available for release reducible freezing tokens sent by _sender. Gas usage is not deterministic!
     * @param _sender Address of frozen tokens sender.
     * @return how many tokens was released
     */
    function reducibleReleaseAll(address _sender) public returns (uint tokens) {
        uint release;
        uint balance;
        (release, balance) = getReducibleFreezing(msg.sender, _sender, 0);
        while (release != 0 && block.timestamp > release) {
            releaseReducibleFreezingOnce(_sender);
            tokens += balance;
            (release, balance) = getReducibleFreezing(msg.sender, _sender, 0);
        }
    }

    function toKey(address _addr, uint _release) internal pure returns (bytes32 result) {
        result = 0x5749534800000000000000000000000000000000000000000000000000000000;
        assembly {
            result := or(result, mul(_addr, 0x10000000000000000))
            result := or(result, _release)
        }
    }

    function toKey2(address _addr1, address _addr2, uint _release) internal pure returns (bytes32 result) {
        bytes32 key1 = 0x5749534800000000000000000000000000000000000000000000000000000000;
        bytes32 key2 = 0x8926457892347780720546870000000000000000000000000000000000000000;
        assembly {
            key1 := or(key1, mul(_addr1, 0x10000000000000000))
            key1 := or(key1, _release)
            key2 := or(key2, _addr2)
        }
        result = keccak256(abi.encodePacked(key1, key2));
    }

    function freeze(address _to, uint64 _until) internal {
        require(_until > block.timestamp);
        bytes32 key = toKey(_to, _until);
        bytes32 parentKey = toKey(_to, uint64(0));
        uint64 next = chains[parentKey];

        if (next == 0) {
            chains[parentKey] = _until;
            return;
        }

        bytes32 nextKey = toKey(_to, next);
        uint parent;

        while (next != 0 && _until > next) {
            parent = next;
            parentKey = nextKey;

            next = chains[nextKey];
            nextKey = toKey(_to, next);
        }

        if (_until == next) {
            return;
        }

        if (next != 0) {
            chains[key] = next;
        }

        chains[parentKey] = _until;
    }

    function reducibleFreeze(address _to, uint64 _until) internal {
        require(_until > block.timestamp);
        bytes32 key = toKey2(_to, msg.sender, _until);
        bytes32 parentKey = toKey2(_to, msg.sender, uint64(0));
        uint64 next = reducibleChains[parentKey];

        if (next == 0) {
            reducibleChains[parentKey] = _until;
            return;
        }

        bytes32 nextKey = toKey2(_to, msg.sender, next);
        uint parent;

        while (next != 0 && _until > next) {
            parent = next;
            parentKey = nextKey;

            next = reducibleChains[nextKey];
            nextKey = toKey2(_to, msg.sender, next);
        }

        if (_until == next) {
            return;
        }

        if (next != 0) {
            reducibleChains[key] = next;
        }

        reducibleChains[parentKey] = _until;
    }
}


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


contract FreezableMintableToken is FreezableToken, MintableToken {
    /**
     * @dev Mint the specified amount of token to the specified address and freeze it until the specified date.
     *      Be careful, gas usage is not deterministic,
     *      and depends on how many freezes _to address already has.
     * @param _to Address to which token will be freeze.
     * @param _amount Amount of token to mint and freeze.
     * @param _until Release date, must be in future.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintAndFreeze(address _to, uint _amount, uint64 _until) public onlyOwner canMint returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);

        bytes32 currentKey = toKey(_to, _until);
        freezings[currentKey] = freezings[currentKey].add(_amount);
        freezingBalance[_to] = freezingBalance[_to].add(_amount);

        freeze(_to, _until);
        emit Mint(_to, _amount);
        emit Freezed(_to, _until, _amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
}

contract Consts {
    uint public constant TOKEN_DECIMALS = 18;
    uint8 public constant TOKEN_DECIMALS_UINT8 = 18;
    uint public constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;
    string public constant TOKEN_NAME = "MindsyncAI";
    string public constant TOKEN_SYMBOL = "MAI";
    uint public constant INITIAL_SUPPLY = 150000000 * TOKEN_DECIMAL_MULTIPLIER;
}


contract MindsyncToken is Consts, FreezableMintableToken, BurnableToken, Pausable
{
    uint256 startdate;

    address beneficiary1;
    address beneficiary2;
    address beneficiary3;
    address beneficiary4;
    address beneficiary5;
    address beneficiary6;

    event Initialized();
    bool public initialized = false;

    constructor() public {
        init();
    }

    function name() public pure returns (string memory) {
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string memory) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return TOKEN_DECIMALS_UINT8;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transfer(_to, _value);
    }

    function init() private {
        require(!initialized);
        initialized = true;


        // Total Supply
        uint256 amount = INITIAL_SUPPLY;

        // Mint all tokens
        mint(address(this), amount);
        finishMinting();

        // Start date is October 01, 2019
        startdate = 1569888000;


        beneficiary1 = 0x5CF8547CEE82507aBe5943195AAF59e50011Cd98; // Public sale
        beneficiary2 = 0xda610e1cE9beb971898F2100e60A0dADae120Fca; // Team 
        beneficiary3 = 0xa4890F3A79021B2eB36CDE59E3cad6947e6EDC04; // Advisors
        beneficiary4 = 0xBb0A3C9cA709484Afb4d56744C41dc52f919B5F1; // Bounty
        beneficiary5 = 0xa94Dffc127be00ce33889fFF47A1Ca6ccF1ef488; // Reward pool
        beneficiary6 = 0xd640B3AEe4C4a37896eb6fcF0e3244373337ab44; // Foundation

        // Public sale (50%)
        _transfer(address(this), beneficiary1, totalSupply().mul(50).div(100));

        // Team tokens (15%) are frozen and will be unlocked every six months after half a year.
        _freezeTo(address(this), beneficiary2, totalSupply().mul(15).div(100).div(4), uint64(startdate + 183 days));
        _freezeTo(address(this), beneficiary2, totalSupply().mul(15).div(100).div(4), uint64(startdate + 366 days));
        _freezeTo(address(this), beneficiary2, totalSupply().mul(15).div(100).div(4), uint64(startdate + 548 days));
        _freezeTo(address(this), beneficiary2, totalSupply().mul(15).div(100).div(4), uint64(startdate + 731 days));

        // Advisors tokens (5%) are frozen and will be unlocked quarterly after half a year within 1 year.
        _freezeTo(address(this), beneficiary3, totalSupply().mul(5).div(100).div(4), uint64(startdate + 183 days));
        _freezeTo(address(this), beneficiary3, totalSupply().mul(5).div(100).div(4), uint64(startdate + 274 days));
        _freezeTo(address(this), beneficiary3, totalSupply().mul(5).div(100).div(4), uint64(startdate + 366 days));
        _freezeTo(address(this), beneficiary3, totalSupply().mul(5).div(100).div(4), uint64(startdate + 458 days));

        // Bounty tokens (2%) will be frozen during the distribution process.
        _transfer(address(this), beneficiary4, totalSupply().mul(2).div(100));

        // Reward fund tokens (20%) will be stored on Mindsync reward pool smart-contract and frozen.
        // Voting will be used to allocate funds from the prize fund. Please refer to Whitepaper for more info.
        _freezeTo(address(this), beneficiary5, totalSupply().mul(20).div(100).div(4), uint64(startdate + 183 days));
        _freezeTo(address(this), beneficiary5, totalSupply().mul(20).div(100).div(4), uint64(startdate + 366 days));
        _freezeTo(address(this), beneficiary5, totalSupply().mul(20).div(100).div(4), uint64(startdate + 548 days));
        _freezeTo(address(this), beneficiary5, totalSupply().mul(20).div(100).div(4), uint64(startdate + 731 days));

        // Foundation tokens (8%) will be frozen on Mindsync foundation smart-contract for 1 year.
        _freezeTo(address(this), beneficiary6, totalSupply().mul(8).div(100), uint64(startdate + 365 days));

        emit Initialized();
    }
}