/**

 *Submitted for verification at Etherscan.io on 2019-06-04

*/



contract Hashlock {

    bytes32 internal hash;

    constructor(bytes32 h) public payable {

        hash = h;

    }

    

    function reveal(bytes32 p) external {

        require(keccak256(abi.encode(p)) == hash);

        selfdestruct(msg.sender);

    }

}