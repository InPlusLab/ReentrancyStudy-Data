/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity 0.5.10;

/// @title Contract for sending any ERC20 tokens to lots of addresses in batches quickly and efficiently
/// @author The EraSwap Team
/// @notice Due to Ethereum block gas limitations, you can send about 200 in one transaction.
/// @dev For using, you can approve this contract for all the batches amount once and then send individual batches.
contract BatchSendTokens {
    
    /// @notice This function is more suitable when you have same amount to send to multiple addresses
    /// @param token - address of ERC20 token contract on which transfer transactions need to be sent
    /// @param addressArray - address to whom tokens will be sent
    /// @param amountToEachAddress - amount of tokens which will be sent to all addresses in addressArray
    /// @param totalAmount - amount of total tokens in one batch
    /// @dev Please note that you have to approve this contract as spender for the totalAmount tokens
    function sendTokensBySameAmount(
        ERC20Interface token, 
        address[] memory addressArray, 
        uint256 amountToEachAddress,
        uint256 totalAmount
    ) public {
        token.transferFrom(msg.sender, address(this), totalAmount);
        uint256 lengthOfArray = addressArray.length;
        for(uint256 i = 0; i < lengthOfArray; i++) {
            token.transfer(addressArray[i], amountToEachAddress);
        }
    }
    
    /// @notice This function is more suitable when you have different amounts to send to multiple addresses
    /// @param token - address of ERC20 token contract on which transfer transactions need to be sent
    /// @param addressArray - address to whom tokens will be sent
    /// @param amountArray - amount that will be sent to addressArray in order
    /// @param totalAmount - amount of total tokens in one batch
    /// @dev Please note that you have to approve this contract as spender for the totalAmount tokens
    function sendTokensByDifferentAmount(
        ERC20Interface token, 
        address[] memory addressArray, 
        uint256[] memory amountArray,
        uint256 totalAmount
    ) public {
        token.transferFrom(msg.sender, address(this), totalAmount);
        uint256 lengthOfArray = addressArray.length;
        for(uint256 i = 0; i < lengthOfArray; i++) {
            token.transfer(addressArray[i], amountArray[i]);
        }
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function transfer(address to, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}