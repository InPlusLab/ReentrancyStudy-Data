pragma solidity 0.5.12;


import "./IERC20.sol";


contract TokenMultiSender {

    uint256 internal constant ARRAY_LIMIT = 50;
    
    address constant public token = 0x1C83501478f1320977047008496DACBD60Bb15ef;

    event MultiSent(address[] receivers, uint256[] amounts);
    
    function tokenFallback(address sender, uint total, bytes calldata data) external {
        require(data.length > 0, "Token transfer without data");
        address[] memory receivers;
        uint256[] memory amounts;
        (receivers, amounts) = abi.decode(data, (address[], uint256[]));
        
        require(receivers.length <= ARRAY_LIMIT, "Array length limit");
        require(receivers.length == amounts.length, "Arrays lengths are different");
        
        uint256 i = 0;
        uint256 length = receivers.length;
        for (i; i < length; i++) {
            require(total >= amounts[i], "token value is less than sum of amounts");
            (bool success, ) = token.call.gas(80000)(abi.encodeWithSelector(IERC20(token).transfer.selector, receivers[i], amounts[i]));
            if (success) {
                total = total - amounts[i];
            }
        }
        
        if (total > 0) {
            IERC20(token).transfer(sender, total);
        }
        
        emit MultiSent(receivers, amounts);
    }

}
