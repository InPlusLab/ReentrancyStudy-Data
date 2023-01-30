/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

pragma solidity ^0.4.25;
// Interface to ERC20 functions used in this contract
interface ERC20token {
    function balanceOf(address who) constant returns (uint);
    function transfer(address to, uint value) returns (bool ok);
    function allowance(address owner, address spender) constant returns (uint);
    function transferFrom(address from, address to, uint value) returns (bool ok);
}

contract ExoTokensMarketSimple {
    ERC20token ExoToken;
    address owner;
    uint256 gweiPerToken;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    constructor() public {
        owner = msg.sender;
        gweiPerToken = 1000000;
    }

    function setGweiPerToken(uint256 _gweiPerToken) public onlyOwner {
        gweiPerToken = _gweiPerToken;
    }
    function getGweiPerToken() public view returns(uint256) {
        return gweiPerToken;
    }
    function setERC20Token(address tokenAddr) public onlyOwner  {
        ExoToken = ERC20token(tokenAddr);
    }
    function getERC20Token() public view returns(address) {
        return ExoToken;
    }
    function getERC20Balance() public view returns(uint256) {
        return ExoToken.balanceOf(this);
    }
    function depositERC20Token(uint256 _exo_amount) public  {
        require(ExoToken.allowance(msg.sender, this) >= _exo_amount);
        require(ExoToken.transferFrom(msg.sender, this, _exo_amount));
    }

    // ERC20(GUP) buying function
    // All of the ETH included in the TX is converted to GUP
    function BuyTokens() public payable{
        require(msg.value > 0, "eth value must be non zero");
        uint256 exo_balance = ExoToken.balanceOf(this);
        uint256 tokensToXfer = (msg.value*gweiPerToken)/10**18;
        require(exo_balance >= tokensToXfer, "Not enough tokens in contract");
        require(ExoToken.transfer(msg.sender, tokensToXfer), "Couldn't send funds");
    }

    // Withdraw erc20 tokens
    function withdrawERC20Tokens(uint _val) public onlyOwner {
        require(ExoToken.transfer(msg.sender, _val), "Couldn't send funds");
    }

    // Withdraw Ether
    function withdrawEther() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    // change the owner
    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }
    // fallback
    function() external payable { }
}