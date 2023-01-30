/**

 *Submitted for verification at Etherscan.io on 2018-08-31

*/



pragma solidity ^0.4.24;



interface token {

    function transfer(address receiver, uint256 amount) external;

    function balanceOf(address _address) external returns(uint256);

}



contract Ownable {



    address public owner;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address newOwner) public onlyOwner {

        owner = newOwner;

    }

}



contract ZenswapDistribution_ZNTZLTU is Ownable {

    

    bool public isLive = true;

    address public beneficiary;

    uint256 public rateOfZNT = 500000;

    uint256 public rateOfZLT = 3000;

    uint256 public amountEthRaised = 0;

    uint256 public availableZNT;

    uint256 public availableZLT;

    token public tokenZNT;

    token public tokenZLT;

    

    mapping(address => uint256) public donationOf;

    

    constructor() public {

        

        beneficiary = msg.sender;

    }



    // Callback function, distribute tokens to sender when ETH donation is recieved

    function () payable public {

        

        require(isLive);

        uint256 donation = msg.value;

        uint256 amountZNT = donation * rateOfZNT;

        uint256 amountZLT = donation * rateOfZLT;

        require(availableZNT >= amountZNT && availableZLT >= amountZLT);

        donationOf[msg.sender] += donation;

        amountEthRaised += donation;

        availableZNT -= amountZNT;

        availableZLT -= amountZLT;

        tokenZNT.transfer(msg.sender, amountZNT);

        tokenZLT.transfer(msg.sender, amountZLT);

        beneficiary.transfer(donation);

    }

    

    // Halts or resumes the distribution process

    function toggleIsLive() public onlyOwner {

        if(isLive) {

            isLive = false;

        } else {

            isLive = true;

        }

    }



    // Withdraw available token in this contract

    function withdrawAvailableToken(address _address, uint256 amountZNT, uint256 amountZLT) public onlyOwner {

        require(availableZNT >= amountZNT && availableZLT >= amountZLT);

        availableZNT -= amountZNT;

        availableZLT -= amountZLT;

        tokenZNT.transfer(_address, amountZNT);

        tokenZLT.transfer(_address, amountZLT);

    }

    

    // Set token rate per ETH donation/contribution

    function setTokensPerEth(uint256 rateZNT, uint256 rateZLT) public onlyOwner {

        

        rateOfZNT = rateZNT;

        rateOfZLT = rateZLT;

    }

    

    // Set token contract addresses of tokens involved in distribution

    function setTokenReward(address _addressZNT, address _addressZLT) public onlyOwner {

        

        tokenZNT = token(_addressZNT);

        tokenZLT = token(_addressZLT);

        setAvailableToken();

    }

    

    // Set the available token balance of this contract

    function setAvailableToken() public onlyOwner {

        

        availableZNT = tokenZNT.balanceOf(this);

        availableZLT = tokenZLT.balanceOf(this);

    }

    

    // Set the available token balance of this contract manually

    function setAvailableTokenManually(uint256 amountZNT, uint256 amountZLT) public onlyOwner {

        

        availableZNT = amountZNT;

        availableZLT = amountZLT;

    }

    

    // Set the new beneficiary address

    function setNewBeneficiary(address _address) public onlyOwner {

        

        beneficiary = _address;

    }

    

    // Withdraw ETH, this function can only be used just in case there is bug on ETH transfer / payable

    function withEth(uint256 _amount) public onlyOwner {

        

        require(address(this).balance > 0);

        beneficiary.transfer(_amount);

    }

}