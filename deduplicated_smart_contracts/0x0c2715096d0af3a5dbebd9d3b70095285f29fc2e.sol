/**

 *Submitted for verification at Etherscan.io on 2019-01-13

*/



// this labyrinth contract as a public utility can be used for deterministic random numbers, 

// using the state itself as a source of entropy (generated entirely from human social coordination 

// that is highly random. )



contract Labyrinth {



  uint entropy;

  

  function getRandomNumber() public returns (uint) {

    entropy ^= uint(blockhash(entropy % block.number));

    return entropy;

  }



}