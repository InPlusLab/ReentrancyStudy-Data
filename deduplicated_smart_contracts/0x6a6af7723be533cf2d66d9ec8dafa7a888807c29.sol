/**
 *Submitted for verification at Etherscan.io on 2020-02-22
*/

pragma solidity >=0.4.22 <0.7.0;

contract Donation {
    
    address public owner;
    string public donor;
    string public contractResume;
    bool public isDonated = false;
    string public priceDonateEth = "0";
    
    function Donation(string _donor, string _contractResume) {
        contractResume = _contractResume;
        donor = _donor;
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function DonateInEth(string ammontDonateEth) onlyOwner {
        if(keccak256(abi.encodePacked(ammontDonateEth)) != "0") {
            priceDonateEth = ammontDonateEth;
            isDonated = true;
        } else {
            revert();
        }
    }
    
}