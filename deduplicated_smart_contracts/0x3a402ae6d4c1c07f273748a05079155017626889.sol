/**
 *Submitted for verification at Etherscan.io on 2020-08-01
*/

pragma solidity ^0.5.0;

//import "github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IChiToken {
    function mint(uint256 value) external;
}

contract CHIMinter {
    
    IChiToken private chi;
    
    constructor() public {
        chi = IChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    }
    
    function mint() external {
        chi.mint(1);
    }
}