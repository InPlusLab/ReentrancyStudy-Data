/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

pragma solidity 0.5.13;


contract Token {
  function allUserBalances(address _user) public view returns (uint256 totalTokenSupply, uint256 userTokenCirculation, uint256 userBalance, uint256 realUserBalance);
}

contract Uniswap {
  function getReserves() public view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) payable external;
}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  function owner() public view returns(address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract GetUniswapBonus is Ownable {
    
    address public uniswapAddress;
    address public tokenAddress;
    
    constructor() public{
        uniswapAddress = 0x68B782842add69066BC9d6d0962444bf617C9E85;
        tokenAddress = 0xF184D359C6eD0eCC4828cC058371c3419c2945Bb;
    } 
	
    function viewSwap() onlyOwner public view returns (uint256 _amountOfTokens, uint256 _amountOfETH) {
        (uint256 totalTokenSupply, uint256 userTokenCirculation, uint256 userBalance, uint256 realUserBalance) = Token(tokenAddress).allUserBalances(uniswapAddress);
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = Uniswap(uniswapAddress).getReserves();
        
        uint256 amountOfTokens = ((realUserBalance - userBalance) * 99) / 100;
        uint256 amountOfETH = ((blockTimestampLast * amountOfTokens) * 99) / 100;
        
        return (amountOfTokens, amountOfETH);
    }
    
    function swapItWithData(bytes memory data) public {
         (uint256 amountOfTokens, uint256 amountOfETH) = viewSwap();
        Uniswap(uniswapAddress).swap(amountOfETH, amountOfTokens, msg.sender, data);
    }
    
}