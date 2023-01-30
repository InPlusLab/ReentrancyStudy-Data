/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity >=0.4.21 <0.7.0;


contract Xelerate {
    /**
    * @dev owner
    *
    *
    *
    */
    address payable public owner;
    /**
    * @dev constructor function
    *
    * - `msg.sender`sets to owner.
    *
    *
    *
    */
    constructor() public {
        owner = msg.sender;
    }
    function() external payable {}
    /**
    * @dev distribute commission event.
    *
    *
    *
    * Requirements:
    *
    * - trggers upon commission distribution
    */
    event DistributeCommission(
        address wallet,
        uint256 amount,
        uint256 rid
    );
        /**
    * @dev distribute commission event.
    *
    *
    *
    * Requirements:
    *
    * - trggers upon commission distribution
    */
    event DistributionStarted(
        uint256 rid
    );
    /**
    * @dev access modifier.
    *
    * restrict access this enables sensitive information available only for admin.
    *
    *
    * Requirements:
    *
    * - `msg.sender` must be an admin.
    */
    modifier onlyAdmin() { //Admin modifier
        require(
        msg.sender == owner,
        "This function can only invoked by admin"
        );
        _;
    }
    /**
    * @dev Withdraws contract balance to owner waller
    *
    ** Access modified with OnlyAdmin
    *
    * Requirements:
    *
    */
    function withdraw() public onlyAdmin {
            owner.transfer(address(this).balance);
    }
    /**
    * @dev Distributes commission
    *
    ** Access modified with OnlyAdmin
    *
    * Requirements:
    *
    */
    function distributeCommission(address[] memory addresses, uint256[] memory amounts, uint256 rid) public payable onlyAdmin {
        require(addresses.length > 0, "Atleast one address should be passed");
        require(amounts.length == addresses.length, "address and amount data missmatch");
        emit DistributionStarted(rid);
        for (uint256 i; i < addresses.length; i++) {
            uint256 value = amounts[i];
            address _to = addresses[i];
            require(value > 0, "Minimum amount need to transfer");
            address(uint160(_to)).transfer(value);
            emit DistributeCommission(_to, value, rid);
        }
    }
}