/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

pragma solidity ^0.5.0;

interface EtheleGenerator {
    function earth() external view returns(address);
}
interface Token {
    function balanceOf(address) external view returns (uint256);
}

/**
 * Reward to garner some interest in Ethereum Elements
 */
contract EtheleReward {
    address private constant _generator = 0x3e3D41DA3273D4A56c8a04Ba0ae6a8F0E4B63601;
    
    constructor() public payable {
    }
    
    function claimReward() public  {
        EtheleGenerator generator = EtheleGenerator(_generator);
        Token token = Token(generator.earth());
        
        // token has 18 decimal places, hence 10**18.
        require(token.balanceOf(msg.sender) > 300000 * 10**18, "Insufficient balance to claim reward");
        
        msg.sender.transfer(address(this).balance);
    }

}