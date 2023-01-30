/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.4.25;

pragma experimental ABIEncoderV2;



contract SelectorProvider {

    bytes4 constant getAmountToGive = bytes4(keccak256("getAmountToGive(bytes)"));

    bytes4 constant staticExchangeChecks = bytes4(keccak256("staticExchangeChecks(bytes)"));

    bytes4 constant dynamicExchangeChecks = bytes4(keccak256("dynamicExchangeChecks(bytes,uint256)"));

    bytes4 constant performBuyOrder = bytes4(keccak256("performBuyOrder(bytes,uint256)"));

    bytes4 constant performSellOrder = bytes4(keccak256("performSellOrder(bytes,uint256)"));



    function getSelector(bytes4 genericSelector) public pure returns (bytes4);

}



/// @title ZeroExExchangeSelectorProvider

/// @notice Provides this exchange implementation with correctly formatted function selectors

contract ZeroExExchangeSelectorProvider is SelectorProvider {

    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {

        if (genericSelector == getAmountToGive) {

            return bytes4(keccak256("getAmountToGive_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));

        } else if (genericSelector == staticExchangeChecks) {

            return bytes4(keccak256("staticExchangeChecks_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));

        } else if (genericSelector == dynamicExchangeChecks) {

            return bytes4(keccak256("dynamicExchangeChecks_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));

        } else if (genericSelector == performBuyOrder) {

            return bytes4(keccak256("performBuyOrder_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));

        } else if (genericSelector == performSellOrder) {

            return bytes4(keccak256("performSellOrder_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));

        } else {

            return bytes4(0x0);

        }

    }

}