/**

 *Submitted for verification at Etherscan.io on 2019-04-16

*/



pragma solidity 0.5.00;



library Strings {

  // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol MIT licence

  

  function Concatenate(string memory a, string memory b) public pure returns (string memory concatenatedString) {

    bytes memory bytesA = bytes(a);

    bytes memory bytesB = bytes(b);

    string memory concatenatedAB = new string(bytesA.length + bytesB.length);

    bytes memory bytesAB = bytes(concatenatedAB);

    uint concatendatedIndex = 0;

    uint index = 0;

    for (index = 0; index < bytesA.length; index++) {

      bytesAB[concatendatedIndex++] = bytesA[index];

    }

    for (index = 0; index < bytesB.length; index++) {

      bytesAB[concatendatedIndex++] = bytesB[index];

    }

      

    return string(bytesAB);

  }



  function UintToString(uint value) public pure returns (string memory uintAsString) {

    uint tempValue = value;

    

    if (tempValue == 0) {

      return "0";

    }

    uint j = tempValue;

    uint length;

    while (j != 0) {

      length++;

      j /= 10;

    }

    bytes memory byteString = new bytes(length);

    uint index = length - 1;

    while (tempValue != 0) {

      byteString[index--] = byte(uint8(48 + tempValue % 10));

      tempValue /= 10;

    }

    return string(byteString);

  }

}