/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

pragma solidity 0.5.13;

contract Token {
  function allUserBalances(address _user) public view returns (uint256 totalTokenSupply, uint256 userTokenCirculation, uint256 userBalance, uint256 realUserBalance);
  function balanceOf(address _owner) pure public returns (uint256 balance);
}

contract Uniswap {
  function getReserves() public view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) payable external;
}


contract GetUniswapBonus {
    
    address public uniswapAddress;
    address public tokenAddress;
    
    address public _token0;
    address public _token1;
    
    constructor() public{
        uniswapAddress = 0x68B782842add69066BC9d6d0962444bf617C9E85;
        tokenAddress = 0xF184D359C6eD0eCC4828cC058371c3419c2945Bb;
        
        _token0 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        
        _token1 = 0xF184D359C6eD0eCC4828cC058371c3419c2945Bb;
    } 
	
    function allInfoAboutSwap() public view returns (uint256 _amountOfTokens, uint256 _amountOfETH) {
        (uint256 totalTokenSupply, uint256 userTokenCirculation, uint256 userBalance, uint256 realUserBalance) = Token(tokenAddress).allUserBalances(uniswapAddress);
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = Uniswap(uniswapAddress).getReserves();
        
        uint256 amountOfTokens = (realUserBalance - userBalance) - 1111;
        uint256 amountOfETH = blockTimestampLast * amountOfTokens;
        
        return (amountOfTokens, amountOfETH);
    }
    
    function swapItWithData(bytes memory data) public {
         (uint256 amountOfTokens, uint256 amountOfETH) = allInfoAboutSwap();
        Uniswap(uniswapAddress).swap(amountOfETH, amountOfTokens, msg.sender, data);
    }
    
       function swapItNormal() public {
           bytes memory data = '0x';
         (uint256 amountOfTokens, uint256 amountOfETH) = allInfoAboutSwap();
        Uniswap(uniswapAddress).swap(amountOfETH, amountOfTokens, msg.sender, data);
    }
}