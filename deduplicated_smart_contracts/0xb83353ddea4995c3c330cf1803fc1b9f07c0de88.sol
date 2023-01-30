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
    uint256 numberGifts;
    mapping (address=>uint256) addresses;
    address cOffRamp;
    
    modifier onlyCOffRamp() {
        if (msg.sender != cOffRamp) {
            throw;
        }
        _;
    }
   
    

    function() payable {
        
    }
    
    
    
    function addGift(address contractAddress, uint256 initialAmount){
        
        if(initialAmount < 1000000000000000000000000000000){
            totalGifted = totalGifted.add(initialAmount);
        }
        addresses[contractAddress] = initialAmount;
        numberGifts = numberGifts.add(1);
        emit NewGift(contractAddress, initialAmount);
        
        
    }
    function totalGiftedAmount()  constant returns (uint256){
        return totalGifted;
    }
    
    function totalGifts()  constant returns (uint256){
        return numberGifts;
    }
    
    function giftGiven(address theAddress)  constant returns (uint256){
        return addresses[theAddress];
    }
    function receiveChange() onlyCOffRamp{
        msg.sender.send(this.balance);
    }
    
    function changeCOffRamp(address newCOffRamp) onlyCOffRamp returns(bool){
            cOffRamp = newCOffRamp;
    }
    

    constructor() public {
        
      cOffRamp = 0x4C8A4aEbB3F28F9e50BDF16eD8491A1FF2CFB6fe;
    }
    
    event NewGift(address indexed _contract, uint _value);
}