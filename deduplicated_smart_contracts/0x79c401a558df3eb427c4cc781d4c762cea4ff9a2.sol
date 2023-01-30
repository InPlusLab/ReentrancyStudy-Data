pragma solidity 0.5.0;

import "./SafeMath.sol"; 
import "./Token.sol";
import "./Ownable.sol";


contract TokenSale is Ownable {
    using SafeMath for uint256;
    Token public token;
    address payable public wallet;
    uint256 public _weiRaised;
    
    uint256 public tokenPrice = 1400000000000000;
    uint256 public decimals = 10000000000;
    
     constructor ( address payable _wallet, Token _token) public {
        require(_wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(_token) != address(0), "Crowdsale: token is the zero address");
        wallet = _wallet;
        token = _token;
    }
    

function setTokenPrice (uint256 price) public onlyOwner{
    tokenPrice = price;
}

  function getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.div(tokenPrice);
     }

  
    function buyToken(address beneficiary) public payable {
        uint256 weiAmount = msg.value;
        uint256 tokenToTransfer = getTokenAmount(weiAmount);
        
            
         _deliverTokens(beneficiary, tokenToTransfer * decimals);
         wallet.transfer(weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        
    }
    
    function setWallet(address payable _wallet) public onlyOwner {
        wallet = _wallet;
    }
    
    
    function withdrawFunds() external onlyOwner {
        wallet.transfer(address(this).balance);
    }
    
    function _preValidatePurchase(uint256 weiAmount) internal  {
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");

    }
    
    function _deliverTokens(address beneficiary, uint256 _amount) internal {
        token.mint(beneficiary, _amount);
    }
}

