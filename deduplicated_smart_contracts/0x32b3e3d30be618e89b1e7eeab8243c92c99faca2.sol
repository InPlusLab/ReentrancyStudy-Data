/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

pragma solidity ^ 0.4 .18;
pragma experimental ABIEncoderV2;
contract Shuffle {
    
 function shuffle(uint random)
  public pure returns(string[52]) 
  {
      //init porks
       string[52] memory data=[
           "♠A","♠2","♠3","♠4","♠5","♠6","♠7","♠8","♠9","♠10","♠J","♠Q","♠K",
           "♥A","♥2","♥3","♥4","♥5","♥6","♥7","♥8","♥9","♥10","♥J","♥Q","♥K",
           "♣A","♣2","♣3","♣4","♣5","♣6","♣7","♣8","♣9","♣10","♣J","♣Q","♣K",
           "♦A","♦2","♦3","♦4","♦5","♦6","♦7","♦8","♦9","♦10","♦J","♦Q","♦K"];
      
       //exchanging
       for(uint j=0;j<100;j++)
       {
          uint m=(j%52);
          uint seed= uint256(keccak256(abi.encodePacked(random+j)));
          uint inx=seed%52;
          string memory t=data[inx];
          data[inx]=data[m];
          data[m]=t;
       }
      return data;
   }
}