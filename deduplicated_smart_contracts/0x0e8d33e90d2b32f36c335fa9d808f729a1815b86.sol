/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity >=0.4.22 <0.6.0;

interface collectible {
    function transfer(address receiver, uint amount) external;
}

contract Swap {
    collectible public swapaddress;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public check;

    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor
     *
     * Setup the owner
     */
    constructor(
        address addressOfCollectibleUsedAsReward
    ) public {
        swapaddress = collectible(addressOfCollectibleUsedAsReward);
    }

    
    function () payable external {
        require(check[msg.sender] == false);
        require(msg.value == 0 wei);
        balanceOf[msg.sender] += 50000000;
        swapaddress.transfer(msg.sender, 50000000);
        check[msg.sender] = true;
    }

}