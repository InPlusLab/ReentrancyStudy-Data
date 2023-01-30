pragma solidity ^0.4.18;

// File: contracts/zeppelin-solidity/math/SafeMath.sol

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

// File: contracts/zeppelin-solidity/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/zeppelin-solidity/token/BasicToken.sol

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

// File: contracts/zeppelin-solidity/token/ERC20.sol

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

// File: contracts/zeppelin-solidity/token/StandardToken.sol

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
  function increaseApproval (address _spender, uint _addedValue) public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public
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

// File: contracts/zeppelin-solidity/token/BurnableToken.sol

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
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

// File: contracts/zeppelin-solidity/ownership/Ownable.sol

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/zeppelin-solidity/token/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  mapping (address => bool) internal userAddr;

  /**
  *
  * Add adresses that can run an airdrop 
  *
  */
  function whitelistAddressArray (address[] users) onlyOwner public {
      for (uint i = 0; i < users.length; i++) {
          userAddr[users[i]] = true;
      }
  }

  /**
  *
  * only whitelisted address can airdrop  
  *
  */

  modifier canAirDrop() {
    require(userAddr[msg.sender]);
    _;
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   *
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }
  /**
  *
  * Run air drop, only from whitelisted adresses ( can run multiple pending transactions at a time )
  * the granularity is 50 adresses at a time for the same amount, saving a good amount of gaz 
  *
  */

  function airdrop(address[] _to, uint256[] _amountList, uint8 loop) canAirDrop canMint public {
      address adr;
      uint256 _amount;
      uint8 linc = 0;
      for( uint i = 0; i < loop*50; i=i+50 ) {
          adr = _to[i];
          _amount = _amountList[linc++];
          totalSupply = totalSupply.add(_amount*50);

          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+1];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+2];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+3];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+4];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+5];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+6];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+7];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+8];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+9];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+10];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+11];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+12];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+13];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+14];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+15];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+16];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+17];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+18];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+19];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+20];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+21];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+22];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+23];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+24];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+25];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+26];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+27];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+28];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+29];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+30];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+31];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+32];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+33];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+34];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+35];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+36];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+37];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+38];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+39];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+40];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+41];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+42];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+43];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+44];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+45];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+46];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+47];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+48];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
          adr = _to[i+49];
          balances[adr] = balances[adr].add(_amount);
          Transfer(0x0, adr, _amount);
      }
    }
  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts/kdoTokenIcoListMe.sol

contract kdoTokenIcoListMe is MintableToken,BurnableToken {
    string public constant name = "A ? from ico-list.me/kdo";
    string public constant symbol = "KDO ?";
    uint8 public decimals = 3;
}