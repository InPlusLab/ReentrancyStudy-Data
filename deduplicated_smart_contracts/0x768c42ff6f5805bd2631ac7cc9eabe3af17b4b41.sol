pragma solidity 0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
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

/**ERC20OldBasic.sol
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
contract ERC20OldBasic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public;
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Old is ERC20OldBasic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public;
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
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

/*

  Copyright Ethfinex Inc 2018

  Licensed under the Apache License, Version 2.0
  http://www.apache.org/licenses/LICENSE-2.0

*/

contract WrapperLockEth is BasicToken, Ownable {
    using SafeMath for uint256;

    address public TRANSFER_PROXY;
    mapping (address => bool) public isSigner;

    string public name;
    string public symbol;
    uint public decimals;
    address public originalToken = 0x00;

    mapping (address => uint) public depositLock;
    mapping (address => uint256) public balances;

    function WrapperLockEth(string _name, string _symbol, uint _decimals, address _transferProxy) Ownable() {
        TRANSFER_PROXY = _transferProxy;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        isSigner[msg.sender] = true;
    }

    function deposit(uint _value, uint _forTime) public payable returns (bool success) {
        require(_forTime >= 1);
        require(now + _forTime * 1 hours >= depositLock[msg.sender]);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        totalSupply_ = totalSupply_.add(msg.value);
        depositLock[msg.sender] = now + _forTime * 1 hours;
        return true;
    }

    function withdraw(
        uint _value,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint signatureValidUntilBlock
    )
        public
        returns
        (bool)
    {
        require(balanceOf(msg.sender) >= _value);
        if (now > depositLock[msg.sender]) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            totalSupply_ = totalSupply_.sub(msg.value);
            msg.sender.transfer(_value);
        } else {
            require(block.number < signatureValidUntilBlock);
            require(isValidSignature(keccak256(msg.sender, address(this), signatureValidUntilBlock), v, r, s));
            balances[msg.sender] = balances[msg.sender].sub(_value);
            totalSupply_ = totalSupply_.sub(msg.value);
            depositLock[msg.sender] = 0;
            msg.sender.transfer(_value);
        }
        return true;
    }

    function withdrawDifferentToken(address _token, bool _erc20old) public onlyOwner returns (bool) {
        require(ERC20(_token).balanceOf(address(this)) > 0);
        if (_erc20old) {
            ERC20Old(_token).transfer(msg.sender, ERC20(_token).balanceOf(address(this)));
        } else {
            ERC20(_token).transfer(msg.sender, ERC20(_token).balanceOf(address(this)));
        }
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        return false;
    }

    function transferFrom(address _from, address _to, uint _value) public {
        require(isSigner[_to] || isSigner[_from]);
        assert(msg.sender == TRANSFER_PROXY);
        balances[_to] = balances[_to].add(_value);
        depositLock[_to] = depositLock[_to] > now ? depositLock[_to] : now + 1 hours;
        balances[_from] = balances[_from].sub(_value);
        Transfer(_from, _to, _value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        if (_spender == TRANSFER_PROXY) {
            return 2**256 - 1;
        }
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }

    function isValidSignature(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s)
        public
        constant
        returns (bool)
    {
        return isSigner[ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", hash),
            v,
            r,
            s
        )];
    }

    function addSigner(address _newSigner) public {
        require(isSigner[msg.sender]);
        isSigner[_newSigner] = true;
    }

    function keccak(address _sender, address _wrapper, uint _validTill) public constant returns(bytes32) {
        return keccak256(_sender, _wrapper, _validTill);
    }
}