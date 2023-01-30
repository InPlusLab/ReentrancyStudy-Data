/**
 *Submitted for verification at Etherscan.io on 2020-07-19
*/

pragma solidity ^0.5.8;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

contract WDXSale {
    IERC20Token public tokenContract;  // the token being sold
    uint256 public price;              // the price, in wei, per token
    address owner;

    uint256 public tokensSold;

    event Sold(address buyer, uint256 amount);

    constructor(IERC20Token _tokenContract, uint256 _price) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        price = _price;
    }

    // Guards against integer overflows
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
    
    function safeDivision(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function buyTokens(uint256 numberOfTokens) public payable {
        require(msg.value == safeMultiply(numberOfTokens, price));


        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        tokenContract.transfer(msg.sender, numberOfTokens);
    }
    
    function() external payable {
        uint256 numberOfTokens = safeDivision(msg.value, price);
        
        emit Sold(msg.sender, numberOfTokens);
        tokensSold += numberOfTokens;

        tokenContract.transfer(msg.sender, numberOfTokens);
    }
    
    function endSale() public {
        require(msg.sender == owner);

        // Send unsold tokens to the owner.
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));

        msg.sender.transfer(address(this).balance);
    }

}