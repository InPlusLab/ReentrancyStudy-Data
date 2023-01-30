/**

 *Submitted for verification at Etherscan.io on 2019-04-08

*/



// Verified using https://dapp.tools

// hevm: flattened sources of src/Unwraper.sol
pragma solidity >=0.5.0 <0.6.0;

////// src/interfaces/IERC20.sol
/* pragma solidity >=0.5.0 <0.6.0; */

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}
////// src/interfaces/IWrappedEther.sol
/* pragma solidity >=0.5.0 <0.6.0; */

/* import "./IERC20.sol"; */

contract IWrappedEther is IERC20 {
    function deposit() external payable;
    function withdraw(uint amount) external;
}
////// src/Unwraper.sol
/* pragma solidity >=0.5.0 <0.6.0; */

/* import "./interfaces/IWrappedEther.sol"; */

contract Unwraper {
    IWrappedEther constant weth = IWrappedEther(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function unwrapAll() public {
        uint256 amount = weth.balanceOf(address(this));
        weth.withdraw(amount);
        msg.sender.transfer(amount);
    }
}