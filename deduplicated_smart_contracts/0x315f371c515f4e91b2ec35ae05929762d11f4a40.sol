/**
 *Submitted for verification at Etherscan.io on 2020-01-09
*/

pragma solidity ^0.5.6;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

contract Escrow {

    address payable public tokenRecipient;
    address payable public ethRecipient;
    uint256 public tokenAmount;
    uint256 public ethAmount;
    uint public withdrawalDate;
    bool public isReleased = false;
    IERC20 mbn;

    constructor(
        address payable _tokenRecipient,
        address payable _ethRecipient,
        uint256 _tokenAmount,
        uint256 _ethAmount,
        address tokenAddress
    )
    public {
        tokenRecipient = _tokenRecipient;
        ethRecipient = _ethRecipient;
        tokenAmount = _tokenAmount;
        ethAmount = _ethAmount;
        withdrawalDate = now + 6 hours;
        mbn = IERC20(tokenAddress);
    }

    function() external payable {}

    function withdraw() public {
        if (!isReleased) {
            require(now > withdrawalDate, "escrow is locked");
        }

        uint256 ethOnContract = address(this).balance;
        uint256 tokenOnContract = mbn.balanceOf(address(this));
        if (ethOnContract > 0) {
            tokenRecipient.transfer(ethOnContract);
        }
        if (tokenOnContract > 0) {
            mbn.transfer(ethRecipient, tokenOnContract);
        }

    }

    function release() public {
        require(address(this).balance >= ethAmount, "not enough ether");
        require(mbn.balanceOf(address(this)) >= tokenAmount, "not enough tokens");
        mbn.transfer(tokenRecipient, tokenAmount);
        ethRecipient.transfer(ethAmount);
        isReleased = true;
    }
}