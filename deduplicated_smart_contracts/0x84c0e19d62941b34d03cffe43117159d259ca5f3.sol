pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * DAO Fund Locked Till DEC 15th 2020   
 *
 */

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;
    address public pendingOwner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyPendingOwner() {
    assert(msg.sender != address(0));
    require(msg.sender == pendingOwner);
    _;
  }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    pendingOwner = _newOwner;
  }
  
  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    _transferOwnership(pendingOwner);
    pendingOwner = address(0);
  }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface token {
    function transfer(address, uint) external returns (bool);
}

contract TokenLock is Ownable {
    

    address public constant beneficiary = 0xb5D899CB1a141ADeeD2C330E22a85Fb39a972d6F;

    
    // unlock timestamp in seconds (Dec 15 2020 UTC)
    uint public constant unlockTime = 1607990400;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked(), "Cannot transfer tokens while locked.");
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}