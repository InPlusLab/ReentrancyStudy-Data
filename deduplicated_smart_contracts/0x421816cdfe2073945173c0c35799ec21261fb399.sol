/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

pragma solidity 0.5.16;


interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
}


/// @notice This contract serves as an isolated execution environment for
/// performing Eth-to-Dai and Dai-to-Eth trades. DO NOT give this contract
/// any ERC20 allowances, as it will be able to steal the approved tokens.
/// To trade Dai-to-Eth, instead transfer in Dai and call `tradeDaiForEth`
/// (obviously, these steps must be performed atomically). For Eth-to-Dai,
/// simply supply an amount of ETH alongside the call to `tradeEthForDai`.
/// Be sure to include a parameter with the expected amount - this serves
/// as a minimum that must end up in the contract at the end of the trade.
/// Both calls will revert if the received amount is less than this value.
/// @author 0age
contract EthToDaiTradeHelperV3 {
    IERC20 internal constant _DAI = IERC20(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    
    /// @notice target is the dex to call and data is the payload
    function tradeEthForDai(
        uint256 daiExpected, address payable target, bytes calldata data
    ) external payable returns (uint256 daiReceived) {
        // Call into the provided target, supplying ETH and data.
        (bool ok,) = target.call.value(address(this).balance)(data);
        
        // Revert with reason if the call was not successful.
        _revertOnFailure(ok);
        
        // Determine the total Dai balance of this contract.
        daiReceived = _DAI.balanceOf(address(this));
        
        // Ensure that enough Dai was received.
        require(
            daiReceived >= daiExpected,
            "Trade did not result in the expected amount of Dai."
        );
        
        // Transfer the Dai to the caller and revert on failure.
        ok = (_DAI.transfer(msg.sender, daiReceived));
        require(ok, "Dai transfer out failed.");
    }

    /// @notice target is the dex to call and data is the payload
    function tradeDaiForEth(
        uint256 ethExpected, address target, bytes calldata data
    ) external returns (uint256 ethReceived) {
        // Ensure that target has allowance to transfer Dai.
        if (_DAI.allowance(address(this), target) != uint256(-1)) {
            _DAI.approve(target, uint256(-1));
        }
        
        // Call into the provided target, providing data.
        (bool ok,) = target.call(data);
        
        // Revert with reason if the call was not successful.
        _revertOnFailure(ok);
        
        // Determine the total Ether balance of this contract.
        ethReceived = address(this).balance;

        // Ensure that enough Ether was received.
        require(
            ethReceived >= ethExpected,
            "Trade did not result in the expected amount of Ether."
        );
   
        // Transfer the Ether to the caller and revert on failure.
        (ok, ) = msg.sender.call.gas(4999).value(ethReceived)("");

        // Revert with reason if the call was not successful.
        _revertOnFailure(ok);
    }
    
    /// @notice pass along revert reasons on external calls.
    function _revertOnFailure(bool ok) internal pure {
        if (!ok) {
            assembly {
                returndatacopy(0, 0, returndatasize)
                revert(0, returndatasize)
            }
        }
    }
}