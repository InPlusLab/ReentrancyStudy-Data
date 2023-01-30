/**
 *Submitted for verification at Etherscan.io on 2019-12-07
*/

contract SafeBalanceOf {
    function safeBalanceOf(address _tok, address _addr) external returns (uint256) {
        (bool success, bytes memory _data) = _tok.call(
            abi.encodeWithSignature(
                "balanceOf(address)",
                _addr
            )
        );
        
        if (success) {
            return abi.decode(_data, (uint256));
        }
    }
}