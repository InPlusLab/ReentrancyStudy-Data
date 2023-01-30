/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

pragma solidity 0.5.16;


interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

/// @author 0age
contract EthToDaiTradeHelperV2 {
    IERC20 internal constant _DAI = IERC20(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    
    function trade(
        address payable target, bytes calldata data
    ) external payable returns (uint256 daiReceived) {
        // Call into the provided target, supplying ETH and data.
        (bool ok,) = target.call.value(address(this).balance)(data);
        
        // Revert with reason if the call was not successful.
        _revertOnFailure(ok);
        
        // Determine the total Dai balance of this contract.
        daiReceived = _DAI.balanceOf(address(this));
        
        // Transfer the Dai to the caller and revert on failure.
        ok = (_DAI.transfer(msg.sender, daiReceived));
        require(ok, "Dai transfer out failed.");
    }
    
    function _revertOnFailure(bool ok) internal pure {
        if (!ok) {
            assembly {
                returndatacopy(0, 0, returndatasize)
                revert(0, returndatasize)
            }
        }
    }
}