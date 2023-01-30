/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

// File: contracts/ManagerLock.sol

pragma solidity ^0.4.24;



contract ManagerLock is Ownable {

    event Release(address from, uint256 value);
    event Unlock();
    event Lock();

    // ERC20 basic token contract being held
    ERC20 public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // lock flag
    bool public locked = true;

    constructor(ERC20 _token, address _owner, address _beneficiary)
    public {
        token = _token;
        beneficiary = _beneficiary;
        owner = _owner;
    }

    modifier notLocked() {
        require(locked == false);
        _;
    }

    /**
    * @dev it releases all tokens held by this contract to beneficiary.
    */
    function release() external {
        uint256 balance = token.balanceOf(address(this));
        partialRelease(balance);
    }

    /**
    * @dev it releases some tokens held by this contract to beneficiary.
    * @param _amount the number of tokens to be sent to beneficiary
    */
    function partialRelease(uint256 _amount) notLocked public {
        //restrict this tx to the legit beneficiary only
        require(msg.sender == beneficiary);

        uint256 balance = token.balanceOf(address(this));
        require(balance >= _amount);
        require(_amount > 0);

        require(token.transfer(beneficiary, _amount));
        emit Release(beneficiary, _amount);
    }

    function unLock() onlyOwner public {
        locked = false;
        emit Unlock();
    }

    function lock() onlyOwner public {
        locked = true;
        emit Lock();
    }
}