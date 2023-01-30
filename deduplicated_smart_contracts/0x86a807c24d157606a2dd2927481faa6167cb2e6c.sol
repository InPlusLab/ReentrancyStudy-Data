/**

 *Submitted for verification at Etherscan.io on 2018-09-09

*/



pragma solidity ^0.4.24;





contract IAddressDeployerOwner {

    function ownershipTransferred(address _byWhom) public returns(bool);

}





contract AddressDeployer {

    event Deployed(address at);



    address public owner = msg.sender;



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        owner = _newOwner;

    }



    function transferOwnershipAndNotify(IAddressDeployerOwner _newOwner) public onlyOwner {

        owner = _newOwner;

        require(_newOwner.ownershipTransferred(msg.sender));

    }



    function deploy(bytes _data) public onlyOwner returns(address addr) {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            addr := create(0, add(_data, 0x20), mload(_data))

        }

        require(addr != 0);

        emit Deployed(addr);



        // For some reason selfdestruct fails! Will fix in next update!

        owner = 0; // selfdestruct(msg.sender);

    }

}