/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

//www.structuredeth.com/gift

pragma solidity ^0.4.26;


library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract GiftOfCompoundRegistry {
    
    using SafeMath for uint256;
    
    uint256 totalGifted;
    mapping (address=>uint256) addresses;

   
    
    //if smeone sends eth to this contract, throw it because it will just end up getting locked forever
    function() payable {
        throw;
    }
    
    function addGift(address contractAddress, uint256 initialAmount){
        totalGifted = totalGifted.add(initialAmount);
        addresses[contractAddress] = initialAmount;
        
    }
    function totalGiftedAmount()  constant returns (uint256){
        return totalGifted;
    }
    function giftGiven(address theAddress)  constant returns (uint256){
        return addresses[theAddress];
    }
    
    
    
    

    constructor() public {
        
       
        
    }
    
   
}