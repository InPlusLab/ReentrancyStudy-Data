/**

 *Submitted for verification at Etherscan.io on 2019-04-29

*/



// File: contracts/interfaces/IERC173.sol



pragma solidity ^0.5.7;





/// @title ERC-173 Contract Ownership Standard

/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md

///  Note: the ERC-165 identifier for this interface is 0x7f5828d0

contract IERC173 {

    /// @dev This emits when ownership of a contract changes.

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);



    /// @notice Get the address of the owner

    /// @return The address of the owner.

    //// function owner() external view returns (address);



    /// @notice Set the address of the new owner of the contract

    /// @param _newOwner The address of the new owner of the contract

    function transferOwnership(address _newOwner) external;

}



// File: contracts/commons/Ownable.sol



pragma solidity ^0.5.7;







contract Ownable is IERC173 {

    address internal _owner;



    modifier onlyOwner() {

        require(msg.sender == _owner, "The owner should be the sender");

        _;

    }



    constructor() public {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0x0), msg.sender);

    }



    function owner() external view returns (address) {

        return _owner;

    }



    /**

        @dev Transfers the ownership of the contract.



        @param _newOwner Address of the new owner

    */

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "0x0 Is not a valid owner");

        emit OwnershipTransferred(_owner, _newOwner);

        _owner = _newOwner;

    }

}





contract Proxy is Ownable {

    event SetImplementation(address _prev, address _new);



    address private iimplementation;



    function implementation() external view returns (address) {

        return iimplementation;

    }



    function setImplementation(address _implementation) external onlyOwner {

        emit SetImplementation(iimplementation, _implementation);

        iimplementation = _implementation;

    }

    

    function() external {

        address _impl = iimplementation;

        assembly {

            let ptr := mload(0x40)

            calldatacopy(ptr, 0, calldatasize)

            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)

            let size := returndatasize

            returndatacopy(ptr, 0, size)



            if iszero(result) {

                revert(ptr, size)

            }



            return(ptr, size)

        }

    }

}