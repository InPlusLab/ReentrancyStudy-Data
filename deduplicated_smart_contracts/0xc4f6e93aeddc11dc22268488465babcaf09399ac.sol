// SPDX-License-Identifier: MIT

pragma solidity 0.4.26;

import './SafeMath.sol';



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable 
{
  address public owner;
  address private proposedOwner;

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
    require(msg.sender == owner, "lack permission");
    _;
  }

  /**
   * @dev propose a new owner by an existing owner
   * @param _newOwner The address proposed to transfer ownership to.
   */
  function proposeOwner(address _newOwner) public onlyOwner {
    proposedOwner = _newOwner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   */
  function takeOwnership() public {
    require(proposedOwner == msg.sender, "not the proposed owner");
    _transferOwnership(proposedOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0), "zero address not allowed");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
  
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable 
{
  event Pause();
  event Unpause();

  bool public paused; //default as false

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused, "already paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused, "not paused");
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
   * @dev called by the owner to unpauseunpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic 
{
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic 
{
  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic 
{
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 public totalSupply;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
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

}


/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken 
{

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
  function allowance(address _owner, address _spender) public view returns (uint256) {
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
  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
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
  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = allowed[msg.sender][_spender];
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
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable 
{

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint256 _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint256 _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

}


/**
 * @title Frozenable Token
 * @dev Illegal address that can be frozened.
 */
contract FrozenableToken is Ownable 
{
    mapping (address => bool) public Approvers; 

    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address indexed to, bool frozen);

    modifier whenNotFrozen(address _who) {
      require(!frozenAccount[msg.sender] && !frozenAccount[_who], "account frozen");
      _;
    }

    function setApprover(address _wallet, bool _approve) public onlyOwner {
        Approvers[_wallet] = _approve;

        if (!_approve)
          delete Approvers[_wallet];
    }

    function freezeAccount(address _to, bool _freeze) public {
        require(Approvers[msg.sender], "lack approvers permission");
        require(_to != address(0), "not to self");

        frozenAccount[_to] = _freeze;
        emit FrozenFunds(_to, _freeze);
    }

}


/**
*------------------Mintable token----------------------------
*/
contract MintableToken is StandardToken, Ownable {
    
      event Mint(address indexed to, uint256 amount);

      /**
      * @dev Mint method
      * @param _to newly minted tokens will be sent to this address 
      * @param _amount amount to mint
      * @return A boolean that indicates if the operation was successful.
      */
      function _mint(address _to, uint256 _amount) internal returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
      }
}



/**
 * @title hiDollar
 * @author hi.com
 */
contract hiDollar is PausableToken, FrozenableToken, MintableToken
{
    using SafeMath for uint256;

    string public constant name = "hi Dollar";
    string public constant symbol = "HI";
    uint256 public constant decimals = 18;
    uint public constant totalHolders = 6; // total number is fixed, wont change in future
                                  // but holders address can be updated thru setMintSplitHolder method

    // uint256 INITIAL_SUPPLY = 10 *(10 ** 5) * (10 ** uint256(decimals));
    uint256 private INITIAL_SUPPLY = 0;

    mapping (uint => address) public holders;
    mapping (uint => uint256) public MintSplitHolderRatios; //index -> ratio boosted by 10000
    mapping (address => bool) public Proposers; 
    mapping (address => uint256) public Proposals; //address -> mintAmount

    /**
     * @dev Initializes the total release
     */
    constructor() public {
        holders[0] = 0x3AeEFC8dDf3f0787c216b60ea732163455B5163b; //HI_LID
        holders[1] = 0x142Fc12540Dc0FA4e24fB7BedB220397A9e77bF5; //HI_EG
        holders[2] = 0xb1E5f7E027C4ecd9b52C0C285bb628351CF0F5c6; //HI_NLTI
        holders[3] = 0x300Ae38eC675756Ad53bf8c579A0aEC9E09de1D7; //HI_CR
        holders[4] = 0x592f9A9c2F16D27Db43c0Df28e53D0D6184db1C4; //HI_FR
        holders[5] = 0xFa318277eC9633709d5cE641DD8ca80BB9Cc733D; //HI_FT

        MintSplitHolderRatios[0] = 2720; //27.2%
        MintSplitHolderRatios[1] = 1820; //18.2%
        MintSplitHolderRatios[2] = 1820; //18.2%
        MintSplitHolderRatios[3] = 1360; //13.6%
        MintSplitHolderRatios[4] = 1360; //13.6%
        MintSplitHolderRatios[5] = 920;  //9.2%, remaining
        
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
 
    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public whenNotFrozen(_to) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public whenNotFrozen(_from) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }        
    
   
    function setProposer(address _wallet, bool _on) public onlyOwner {
        Proposers[_wallet] = _on;

        if (!_on)
          delete Proposers[_wallet];
    }

    /**
     *  to update an split holder ratio at the index
     *  index ranges from 0..totalHolders -1
     */
    function setMintSplitHolder(uint256 index, address _wallet, uint256 _ratio) public onlyOwner returns (bool) {
        if (index > totalHolders - 1)
          return false;

        holders[ index ] = _wallet;
        MintSplitHolderRatios[ index ] = _ratio;

        return true;
    }

    /**
    * @dev propose to mint
    * @param _amount amount to mint
    * @return mint propose ID
    */
    function proposeMint(uint256 _amount) public returns(bool) {
        require(Proposers[msg.sender], "Non-proposer not allowed");

        Proposals[msg.sender] = _amount; //mint once for a propoer at a time otherwise would be overwritten
        return true;
    }

    function approveMint(address _proposer, uint256 _amount, bool _approve) public returns(bool) {
      require( Approvers[msg.sender], "None-approver not allowed" );

      if (!_approve) {
          delete Proposals[_proposer];
          return true;
      }

      require( _amount > 0, "zero amount not allowed" );
      require( Proposals[_proposer] >= _amount, "Over-approve mint amount not allowed" );

      uint256 remaining = _amount;
      address _to;
      for (uint256 i = 0; i < totalHolders - 1; i++) {
        _to = holders[i];
        uint256 _amt = _amount.mul(MintSplitHolderRatios[i]).div(10000);
        remaining = remaining.sub(_amt);

        _mint(_to, _amt);
      }

      _to = holders[totalHolders - 1];
      _mint(_to, remaining); //for the last holder in the list

      Proposals[_proposer] -= _amount;
      if (Proposals[_proposer] == 0)
        delete Proposals[_proposer];

      return true;

    }
}