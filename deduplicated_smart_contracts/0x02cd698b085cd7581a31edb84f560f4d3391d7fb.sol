/**
 *Submitted for verification at Etherscan.io on 2020-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;


interface ERC20 {
    function totalSupply() external view returns(uint supply);

    function balanceOf(address _owner) external view returns(uint balance);

    function transfer(address _to, uint _value) external returns(bool success);

    function transferFrom(address _from, address _to, uint _value) external returns(bool success);

    function approve(address _spender, uint _value) external returns(bool success);

    function allowance(address _owner, address _spender) external view returns(uint remaining);

    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface WrappedETH {
    function totalSupply() external view returns(uint supply);

    function balanceOf(address _owner) external view returns(uint balance);

    function transfer(address _to, uint _value) external returns(bool success);

    function transferFrom(address _from, address _to, uint _value) external returns(bool success);

    function approve(address _spender, uint _value) external returns(bool success);

    function allowance(address _owner, address _spender) external view returns(uint remaining);

    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function deposit() external payable;

    function withdraw(uint256 wad) external;

}

interface UniswapFactory{
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}



interface UniswapV2{


   function addLiquidity ( address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) external returns ( uint256 amountA, uint256 amountB, uint256 liquidity );
   function addLiquidityETH ( address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external returns ( uint256 amountToken, uint256 amountETH, uint256 liquidity );
   function removeLiquidityETH ( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external returns ( uint256 amountToken, uint256 amountETH );
   function removeLiquidity ( address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) external returns ( uint256 amountA, uint256 amountB );

   function swapExactTokensForTokens ( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns ( uint256[] memory amounts );
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
   function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}





library SafeMath {
  function mul(uint256 a, uint256 b) internal view returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal view returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }



  function sub(uint256 a, uint256 b) internal view returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal view returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}





contract WrapAndUnWrap{

  using SafeMath
    for uint256;

  address payable public owner;
  //placehodler token address for specifying eth tokens
  address public ETH_TOKEN_ADDRESS  = address(0x0);
  address public WETH_TOKEN_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  WrappedETH wethToken = WrappedETH(WETH_TOKEN_ADDRESS);
  uint256 approvalAmount = 1000000000000000000000000000000;
  uint256 longTimeFromNow = 1000000000000000000000000000;
  address uniAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address uniFactoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  UniswapV2 uniswapExchange = UniswapV2(uniAddress);
  UniswapFactory factory = UniswapFactory(uniFactoryAddress);
  mapping (address => address[]) public lpTokenAddressToPairs;



  modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
}

    fallback() external payable {


    }

  constructor() public payable {

        owner= msg.sender;

  }


  function wrap(address sourceToken, address[] memory destinationTokens, uint256 amount) public payable returns(address, uint256){


    ERC20 sToken = ERC20(sourceToken);
    ERC20 dToken = ERC20(destinationTokens[0]);







      if(destinationTokens.length==1){

        if(sourceToken != ETH_TOKEN_ADDRESS){
          require(sToken.transferFrom(msg.sender, address(this), amount), "You have not approved this contract or do not have enough token for this transfer 1");
          sToken.approve(uniAddress, approvalAmount);
        }

        conductUniswap(sourceToken, destinationTokens[0], amount);
        uint256 thisBalance = dToken.balanceOf(address(this));
        dToken.transfer(msg.sender, thisBalance);
        return (destinationTokens[0], thisBalance);

      }

      else{

        bool updatedweth =false;
        if(sourceToken == ETH_TOKEN_ADDRESS){
          WrappedETH sToken1 = WrappedETH(WETH_TOKEN_ADDRESS);
          sToken1.deposit{value:msg.value}();
          sToken = ERC20(WETH_TOKEN_ADDRESS);
          amount = msg.value;
          sourceToken = WETH_TOKEN_ADDRESS;
          updatedweth =true;
        }


        if(sourceToken != ETH_TOKEN_ADDRESS && updatedweth==false){
          require(sToken.transferFrom(msg.sender, address(this), amount), "You have not approved this contract or do not have enough token for this transfer  2");
          sToken.approve(uniAddress, approvalAmount);
        }

        if(destinationTokens[0] == ETH_TOKEN_ADDRESS){
              destinationTokens[0] = WETH_TOKEN_ADDRESS;
        }
        if(destinationTokens[1] == ETH_TOKEN_ADDRESS){
            destinationTokens[1] = WETH_TOKEN_ADDRESS;
        }



        if(sourceToken !=destinationTokens[0]){
            conductUniswap(sourceToken, destinationTokens[0], amount.div(2));
        }
        if(sourceToken !=destinationTokens[1]){

            conductUniswap(sourceToken, destinationTokens[1], amount.div(2));
        }

        ERC20 dToken2 = ERC20(destinationTokens[1]);
        uint256 dTokenBalance = dToken.balanceOf(address(this));
        uint256 dTokenBalance2 = dToken2.balanceOf(address(this));

        dToken.approve(uniAddress, approvalAmount);
        dToken2.approve(uniAddress, approvalAmount);





        (,,uint liquidityCoins)  = uniswapExchange.addLiquidity(destinationTokens[0],destinationTokens[1], dTokenBalance, dTokenBalance2, 1,1, msg.sender, longTimeFromNow);


        address thisPairAddress = factory.getPair(destinationTokens[0],destinationTokens[1]);
        ERC20 lpToken = ERC20(thisPairAddress);
        lpTokenAddressToPairs[thisPairAddress] =[destinationTokens[0], destinationTokens[1]];
        uint256 thisBalance =lpToken.balanceOf(address(this));
        lpToken.transfer(msg.sender, thisBalance);
        return (thisPairAddress,thisBalance) ;
      }



    }


      function unwrap(address sourceToken, address destinationToken, uint256 amount) public payable returns( uint256){

        ERC20 sToken = ERC20(sourceToken);
        ERC20 dToken = ERC20(destinationToken);




        if(sourceToken != ETH_TOKEN_ADDRESS){
          require(sToken.transferFrom(msg.sender, address(this), amount), "You have not approved this contract or do not have enough token for this transfer  3 unwrapping");
        }


        if(lpTokenAddressToPairs[sourceToken].length !=0){
            sToken.approve(uniAddress, approvalAmount);
          uniswapExchange.removeLiquidity(lpTokenAddressToPairs[sourceToken][0], lpTokenAddressToPairs[sourceToken][1], amount, 0,0, msg.sender, longTimeFromNow);

          ERC20 pToken1 = ERC20(lpTokenAddressToPairs[sourceToken][0]);
          ERC20 pToken2 = ERC20(lpTokenAddressToPairs[sourceToken][1]);

          uint256 pTokenBalance = pToken1.balanceOf(address(this));
          uint256 pTokenBalance2 = pToken2.balanceOf(address(this));
          pToken1.approve(uniAddress, approvalAmount);
          pToken2.approve(uniAddress, approvalAmount);
          if(lpTokenAddressToPairs[sourceToken][0] != destinationToken){
              conductUniswap(lpTokenAddressToPairs[sourceToken][0], destinationToken, pTokenBalance);
          }
          if(lpTokenAddressToPairs[sourceToken][1] != destinationToken){
              conductUniswap(lpTokenAddressToPairs[sourceToken][1], destinationToken, pTokenBalance2);
          }


          uint256 destinationTokenBalance = dToken.balanceOf(address(this));
          dToken.transfer(msg.sender, destinationTokenBalance);
          return destinationTokenBalance;

        }
        else{

            sToken.approve(uniAddress, approvalAmount);
            if(sourceToken != destinationToken){
                conductUniswap(sourceToken, destinationToken, amount);
            }
          uint256 destinationTokenBalance = dToken.balanceOf(address(this));
          dToken.transfer(msg.sender, destinationTokenBalance);
          return destinationTokenBalance;
        }







      }







  function updateOwnerAddress(address payable newOwner) onlyOwner public returns (bool){
     owner = newOwner;
     return true;
   }

   function updateUniswapExchange(address newAddress ) public onlyOwner returns (bool){

    uniswapExchange = UniswapV2( newAddress);
    uniAddress = newAddress;
    return true;

  }

  function updateUniswapFactory(address newAddress ) public onlyOwner returns (bool){

   factory = UniswapFactory( newAddress);
   uniFactoryAddress = newAddress;
   return true;

 }



  function conductUniswap(address sellToken, address buyToken, uint amount) internal returns (uint256 amounts1){

            if(sellToken ==ETH_TOKEN_ADDRESS && buyToken == WETH_TOKEN_ADDRESS){
                wethToken.deposit{value:msg.value}();
            }
            else if(sellToken == address(0x0)){
                address [] memory addresses = new address[](2);
                addresses[0] = WETH_TOKEN_ADDRESS;
                addresses[1] = buyToken;
                uniswapExchange.swapExactETHForTokens{value:msg.value}(0, addresses, address(this), 1000000000000000 );

            }

            else if(sellToken == WETH_TOKEN_ADDRESS){
                wethToken.withdraw(amount);

                address [] memory addresses = new address[](2);
                addresses[0] = WETH_TOKEN_ADDRESS;
                addresses[1] = buyToken;
                uniswapExchange.swapExactETHForTokens{value:amount}(0, addresses, address(this), 1000000000000000 );

            }



            else{
          address [] memory addresses = new address[](2);
          addresses[0] = sellToken;
          addresses[1] = buyToken;
           uint256 [] memory amounts = conductUniswapT4T(addresses, amount );
           uint256 resultingTokens = amounts[1];
           return resultingTokens;
            }
    }

    function conductUniswapT4T(address  [] memory theAddresses, uint amount) internal returns (uint256[] memory amounts1){

           uint256 deadline = 1000000000000000;
           uint256 [] memory amounts =  uniswapExchange.swapExactTokensForTokens(amount, 0, theAddresses, address(this),deadline );
           return amounts;

    }

    function adminEmergencyWithdrawTokens(address token, uint amount, address payable destination) public onlyOwner returns(bool) {

      if (address(token) == ETH_TOKEN_ADDRESS) {
          destination.transfer(amount);
      }
      else {
          ERC20 tokenToken = ERC20(token);
          require(tokenToken.transfer(destination, amount));
      }
      return true;
  }


  //this function is here for easy testing in production on a sandbox
   function getUserTokenBalance(address userAddress, address tokenAddress) public view returns (uint256){
    ERC20 token = ERC20(tokenAddress);
    return token.balanceOf(userAddress);

  }




  function kill() virtual public onlyOwner {
         selfdestruct(owner);
  }





}