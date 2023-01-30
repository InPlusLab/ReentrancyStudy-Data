/**

 *Submitted for verification at Etherscan.io on 2019-05-02

*/



contract BlockHashSaver {

    bytes32 public currentHash;

    bytes32 public prevHash;

    

    function saveHash() public {

        currentHash = blockhash(block.number);

        prevHash = blockhash(block.number - 1);

    }

}