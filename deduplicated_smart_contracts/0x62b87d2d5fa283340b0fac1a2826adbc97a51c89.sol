/**

 *Submitted for verification at Etherscan.io on 2019-02-14

*/



pragma solidity ^0.5.0;



// File: contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: contracts/SendERC20Token.sol



contract SendERC20Token {

    

    function withdrawToken(address _tokenAddress) public {



        IERC20 token = IERC20(_tokenAddress);



        require(token.transfer(msg.sender, 1000000000000000000) == true);

    }

}