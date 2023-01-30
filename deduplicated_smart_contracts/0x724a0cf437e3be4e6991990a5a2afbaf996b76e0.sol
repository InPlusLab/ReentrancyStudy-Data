/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.5.0;

interface IVoomo {
    function checkState() external;
}

contract Owner {
    IVoomo public voomo;
    address payable public owner1;
    address payable public owner2;
    uint256 public constant limit = 1 ether;

    modifier onlyOwners {
        require(msg.sender == owner1 || msg.sender == owner2, "onlyOwners: access denied");
        _;
    }

    constructor (address payable _owner1, address payable _owner2) public {
        require(_owner1 != address(0) && _owner2 != address(0), 'Owner: invalid addresses');
        owner1 = _owner1;
        owner2 = _owner2;
    }

    function () external payable {
        // empty fallback method
    }

    function setContractAddress(IVoomo _voomo) external {
        require(address(voomo) == address(0), "setContractAddress: invalid adderss");
        voomo = _voomo;
    }

    function checkState() external onlyOwners {
        voomo.checkState();
    }

    function withdraw() external onlyOwners {
        uint256 balance = address(this).balance;
        owner1.transfer(balance/2);
        owner2.transfer(balance/2);
    }
}