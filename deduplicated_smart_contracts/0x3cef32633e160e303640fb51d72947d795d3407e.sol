/**

 *Submitted for verification at Etherscan.io on 2018-12-19

*/



pragma solidity ^0.4.18;



// File: contracts/library/Ownable.sol



/*

 * Ownable

 *

 * Base contract with an owner.

 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.

 */

contract Ownable {

  address public owner;



  function Ownable() public {

    owner = msg.sender;

  }



  modifier onlyOwner() {

    require(msg.sender == owner);



    _;

  }



  function transferOwnership(address newOwner) onlyOwner public {

    if (newOwner != address(0)) {

      owner = newOwner;

    }

  }



}



// File: contracts/library/upgradeable/Proxied.sol



contract Proxied is Ownable {

    address public target;

    mapping (address => bool) public initialized;



    event EventUpgrade(address indexed newTarget, address indexed oldTarget, address indexed admin);

    event EventInitialized(address indexed target);



    function upgradeTo(address _target) public;

}



// File: contracts/library/upgradeable/Upgradeable.sol



contract Upgradeable is Proxied {

    /*

     * @notice Modifier to make body of function only execute if the contract has not already been initialized.

     */

    modifier initializeOnceOnly() {

         if(!initialized[target]) {

             initialized[target] = true;

             emit EventInitialized(target);

             _;

         } else revert();

     }



    /**

     * @notice Will always fail if called. This is used as a placeholder for the contract ABI.

     * @dev This is code is never executed by the Proxy using delegate call

     */

    function upgradeTo(address) public {

        assert(false);

    }



    /**

     * @notice Initialize any state variables that would normally be set in the contructor.

     * @dev Initialization functionality MUST be implemented in inherited upgradeable contract if the child contract requires

     * variable initialization on creation. This is because the contructor of the child contract will not execute

     * and set any state when the Proxy contract targets it.

     * This function MUST be called stright after the Upgradeable contract is set as the target of the Proxy. This method

     * can be overwridden so that it may have arguments. Make sure that the initializeOnceOnly() modifier is used to protect

     * from being initialized more than once.

     * If a contract is upgraded twice, pay special attention that the state variables are not initialized again

     */

    function initialize() initializeOnceOnly public {

        // initialize contract state variables here

    }

}



// File: contracts/MerkleClaims.sol



contract MerkleClaims is Upgradeable {

    mapping (uint256 => bytes32) public rootByTimeKey;

    event NewRootAdded(uint256 timeKey,bytes32 root);

    function addMerkleRoot(uint256 timeKey, bytes32 root) public onlyOwner {

        require(rootByTimeKey[timeKey]==0);

        rootByTimeKey[timeKey] = root;

        emit NewRootAdded(timeKey,root);

    }

}