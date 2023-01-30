/**
 *Submitted for verification at Etherscan.io on 2020-06-16
*/

//Written by blurr

pragma solidity ^0.5.0;

interface vethrInterface {
    function burnTokensForMember(address token, uint amount, address member) external;
}

interface chiInterface {
    function mint(uint256 value) external;
    function freeFromUpTo(address from, uint256 value) external returns (uint256);
}

interface tokenInterface {
    function balanceOf(address _address) external view returns (uint balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function approve(address _address, uint amount) external returns (bool success);
}

contract Burner {
    
    address owner = msg.sender;
    address vethr = 0x31Bb711de2e457066c6281f231fb473FC5c2afd3; 
    address chi = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
    address burnToken = 0xC25317201a3603a75E5dc587dEc2B9ea120b55a8;
    
    constructor() public {
        tokenInterface(burnToken).approve(vethr, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        tokenInterface(chi).approve(address(this), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }
    
    function attack() public {
        uint256 gasStart = gasleft();
            require(msg.sender == owner);
            vethrInterface(vethr).burnTokensForMember(burnToken, 1000000000000000000, msg.sender);
        uint256 msgLength = 16 * msg.data.length;
        uint256 gasSpent = 21000 + gasStart - gasleft() + msgLength;
        chiInterface(chi).freeFromUpTo(address(this), (gasSpent + 14154) / 41947);
    }
    
    function withdrawAllTokens(address tokenAddress) public {
        require (msg.sender == owner);
        uint balance = tokenInterface(tokenAddress).balanceOf(address(this));
        tokenInterface(tokenAddress).transfer(owner, balance);
    }
}