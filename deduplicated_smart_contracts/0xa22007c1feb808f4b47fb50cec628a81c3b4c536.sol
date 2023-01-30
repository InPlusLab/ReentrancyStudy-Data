/**
 *Submitted for verification at Etherscan.io on 2019-11-16
*/

pragma solidity ^0.4.21;

// Interface to ERC20 functions used in this contract
interface ERC20token {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract ExoTokensSwap{
    ERC20token TokenFrom;
    ERC20token TokenTo;
    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setERC20TokenFrom(address tokenAddr) public onlyOwner  {
        TokenFrom = ERC20token(tokenAddr);
    }

    function getERC20TokenFrom() public view returns(address) {
        return TokenFrom;
    }

    function setERC20TokenTo(address tokenAddr) public onlyOwner  {
        TokenTo = ERC20token(tokenAddr);
    }

    function getERC20TokenTo() public view returns(address) {
        return TokenTo;
    }
    function getERC20BalanceFrom() public view returns(uint256) {
        return TokenFrom.balanceOf(this);
    }
    function getERC20BalanceTo() public view returns(uint256) {
        return TokenTo.balanceOf(this);
    }
    function swapERC20Token(uint256 fromAmount) public returns(uint){
        require(fromAmount > 0);
        require (TokenFrom.allowance(msg.sender, this) >= fromAmount);
        uint256 wallet_tokenTo_balance = TokenTo.balanceOf(this);
        require(wallet_tokenTo_balance >= fromAmount); // must be more in the contract than what user wants to swap
        require(TokenFrom.transferFrom(msg.sender, this, fromAmount)); // Take erc20 tokens from sender
        require(TokenTo.transfer(msg.sender, fromAmount)); // send erc20 to sender
    }

    function moveERC20Tokens(address _tokenContract, address _to, uint _val) public onlyOwner {
        ERC20token token = ERC20token(_tokenContract);
        require(token.transfer(_to, _val));
    }

    // Allows the owner to move any ether on address 
    function moveEther(address _target, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance);
        _target.transfer(_amount);
    }
        // change the owner
    function setOwner(address _owner) public onlyOwner {
        owner = _owner;    
    }

    // empty fallback payable to allow ETH deposits to the contract    
    function() public payable{
    }

}