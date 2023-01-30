/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity ^0.5.16;

interface Contract{
  function approve(address spender, uint256 value) external returns (bool);
  function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
  function balanceOf(address account) external view returns (uint256);
}

contract Arb{
  
    address payable private OUSDcontractAddress = 0x7c0AFD49D40Ec308d49E2926E5c99B037d54EE7e;
    address private UniswapExchangeAddress = 0xD9a1476a57DCF02B57eC87ac7b66568485B8B108;
    
    constructor () public {
        
        uint zero = 0;
        uint one = 1;
        
        //Give Uniswap infinite approval to move contract's OUSD
        Contract(OUSDcontractAddress).approve(UniswapExchangeAddress, zero - one);
    }
   
    function () external payable {
        
        //Send received Eth to OUSD contract
        OUSDcontractAddress.call.value(msg.value)("");
         
        //Send received OUSD to Uniswap then transfer back the Eth
        uint OUSDBalance = Contract(OUSDcontractAddress).balanceOf(address(this));
        Contract(UniswapExchangeAddress).tokenToEthTransferInput(OUSDBalance, 1, 33136721784, msg.sender);
                                                                                 
    }
}