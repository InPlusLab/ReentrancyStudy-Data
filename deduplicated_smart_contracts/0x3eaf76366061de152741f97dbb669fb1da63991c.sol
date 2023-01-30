/**

 *Submitted for verification at Etherscan.io on 2019-01-12

*/



pragma solidity ^0.5.0;



contract ListingService {

  event Log(bytes32 ethtx);



  bytes32[] public ethTxs;



  function logEthTx(bytes32 _ethtx) public {

    ethTxs.push(_ethtx);



    emit Log(_ethtx);

  }

}