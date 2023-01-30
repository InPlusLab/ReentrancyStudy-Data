/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

/**
 * @title ColorPicker
 * @dev Store, update & retrieve a hex color. Costs 0.001 ETH to change it.
 */
contract ColorPicker {
    address private immutable owner;
    bytes3 private color;
    uint private cost;

    event ColorChanged(
        address indexed _from,
        bytes3 indexed _newColor,
        uint indexed cost
    );

    constructor () {
        // Owner is the contract deployer address
        owner = msg.sender;

        // Default color is white
        color = 0xffffff;

        // Default update cost is 0.001 ETH
        cost = 1000000000000000;
    }

    /**
     * @dev Fallback function
     */
    fallback() external payable {}
    
    /**
     * @dev Receive ether function
     */
    receive() external payable {}

    /**
     * @dev Get the contract owner
     * @return the contract owner
     */
    function getOwner() public view returns(address) {
        return owner;
    }

    /**
     * @dev Get the current color
     * @return the current color
     */
    function getColor() public view returns(bytes3) {
        return color;
    }

    /**
     * @dev Get the current cost of updating the color
     * @return the current cost of updating the color
     */
    function getCost() public view returns(uint) {
        return cost;
    }

    /**
     * @dev Set newColor in color if the cost is payed.
     * @param newColor value to store
     */
    function setColor(bytes3 newColor) public payable {
        require(
            msg.value == cost,
            "Payment does not equal cost."
        );
        color = newColor;
        emit ColorChanged(msg.sender, newColor, cost);
    }

    /**
     * @dev Set the update cost if you're the owner
     * @param newCost the new color update cost
     */
    function setCost(uint newCost) public {
        require(
            msg.sender == owner,
            "Unauthorized access detected."
        );
        cost = newCost;
    }
    
    /**
     * @dev Withdraw the contract balance if you're the owner
     */
    function withdrawBalance() external {
        require(
            msg.sender == owner,
            "Unauthorized access detected."
        );
        require(
            address(this).balance > 0,
            "Contract balance is zero."
        );
        msg.sender.transfer(address(this).balance);
    }
}