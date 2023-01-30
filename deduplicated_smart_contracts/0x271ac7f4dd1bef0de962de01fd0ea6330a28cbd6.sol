pragma solidity ^0.5.4;

import "./AuctionityStorage0.sol";

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".

contract AuctionityOwnable_V1 is AuctionityStorage0 {
    event OwnershipRenounced_V1(address indexed previousOwner);
    event OwnershipTransferred_V1(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @notice get contract owner address
    /// @return _contractOwner address
    function getContractOwner_V1()
        public
        view
        returns (address _contractOwner)
    {
        return contractOwner;
    }

    /// @notice delegate receive of isContractOwner
    /// @return  _isContractOwner bool
    function delegatedReceiveIsContractOwner_V1()
        public
        payable
        returns (bool _isContractOwner)
    {
        return isContractOwner_V1();
    }

    /// @notice verify if msg.sender is contract owner
    /// @return _isContractOwner bool
    function isContractOwner_V1() public view returns (bool _isContractOwner) {
        return msg.sender == contractOwner;
    }

    /// @notice Renouncing to ownership will leave the contract without an owner.
    function renounceOwnership_V1() public {
        require(isContractOwner_V1(), "Not the owner");
        emit OwnershipRenounced_V1(contractOwner);
        contractOwner = address(0);
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership_V1(address newOwner) public {
        require(isContractOwner_V1(), "Not the owner");
        _transferOwnership_V1(newOwner);
    }

    /// @notice Transfers control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function _transferOwnership_V1(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred_V1(contractOwner, newOwner);
        contractOwner = newOwner;
    }
}
