/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity 0.6.11;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;}

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;}

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;}

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;}
}

interface Uniswap{
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface Token{
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function transfer(address to, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function approve(address spender, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function primary() external view returns (address payable);
}

contract Balancer {
    
    using SafeMath for uint256;
    
    address constant public ROUTER      = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant public FACTORY     = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant public WETHAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    uint constant public INF = 33136721784;
    
    function sqrt(uint y) public pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    
    function min(uint a, uint b) public pure returns (uint) {
       
       if(a < b){
           return a;
       }else{
           return b;
       }
    }
    
    function min3(uint a, uint b, uint c) public pure returns (uint) {
        return min( min(a,b), c );
    }
    
    function Balance(address tokenAddress, uint ethPrice, uint assetPrice) public payable{
        
        //get pool address for token
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        
        uint tokenAmount = Token(tokenAddress).balanceOf(poolAddress);//token in uniswap
        uint ethAmount = Token(WETHAddress).balanceOf(poolAddress); //Eth in uniswap

        //if the $ amount in eth is greater than $ amount in asset
        if(ethAmount.mul(ethPrice) > tokenAmount.mul(assetPrice)){
            //then remove eth and add token
            
            uint a = tokenAmount;
            uint b = ethAmount;
            
            uint d = ethPrice;
            uint g = assetPrice;
            
            uint tokenAdded = ( sqrt(g*a*(9*a*g + 3988000*b*d)) - 1997*a*g )/(1994*g);
            uint userTokenAmount = Token(tokenAddress).balanceOf(msg.sender);
            uint allowance = Token(tokenAddress).allowance(msg.sender, address(this));
            
            //whichever smallest
            tokenAdded = min3(tokenAdded, userTokenAmount, allowance);

            //receive token from user
            require( Token(tokenAddress).transferFrom(msg.sender, address(this), tokenAdded), "Could not move token to this contract, no approval?");
            
            //trade with uniswap and send eth to user
            address[] memory path = new address[](2);
            path[0] = tokenAddress;
            path[1] = WETHAddress;
            Token(tokenAddress).approve(ROUTER, tokenAdded ); 
    
            Uniswap(ROUTER).swapExactTokensForETH(tokenAdded,1, path, msg.sender, INF);

        }else{
            //if not, remove token and add eth

            uint a = ethAmount;
            uint b = tokenAmount;
            
            uint d = assetPrice;
            uint g = ethPrice;
            
            uint ethAdded = ( sqrt(g*a*(9*a*g + 3988000*b*d)) - 1997*a*g )/(1994*g);
            
            //trade with uniswap and send token to user
            address[] memory path = new address[](2);
            path[0] = WETHAddress;
            path[1] = tokenAddress;
            
            if(address(this).balance < ethAdded){
                ethAdded = address(this).balance;
            }
 
            Uniswap(ROUTER).swapExactETHForTokens.value(ethAdded)(1, path, msg.sender, INF);
        }
        
        //send remaining eth back to user
        msg.sender.transfer(address(this).balance);
        
    }

}