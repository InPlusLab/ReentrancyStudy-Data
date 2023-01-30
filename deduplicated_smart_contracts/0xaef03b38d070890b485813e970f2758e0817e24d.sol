/**

 *Submitted for verification at Etherscan.io on 2019-04-18

*/



pragma solidity ^ 0.4 .18;

contract Shuffle {

 function shuffle(uint random)

  public pure returns(uint[])

  {



   uint[] memory data=new uint[](52);



   for(uint i=0;i<52;i++)

   {

       data[i]=i;

   }

   for(uint j=0;j<100;j++)

  {



      uint m=(j%52);

      uint seed= uint256(keccak256(abi.encodePacked(random+j)));

      uint inx=seed%52;

      uint t=data[inx];

      data[inx]=data[m];

      data[m]=t;

  }



   return data;

   }

}