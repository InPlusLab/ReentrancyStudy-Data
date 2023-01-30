/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

pragma solidity ^0.6.6;

abstract contract ERC20TokenObject {

  function totalSupply() virtual public view returns (uint);
  function balanceOf(address who) virtual public view returns (uint);
  function transferFrom(address from, address to, uint256 value) virtual public returns (bool);
  function transfer(address to, uint value) virtual public returns (bool);
  function allowance(address owner_, address spender) virtual public view returns (uint);
  function approve(address spender, uint value) virtual public returns (bool);
  function increaseAllowance(address spender, uint addedValue) virtual public returns (bool);
  function decreaseAllowance(address spender, uint subtractedValue) virtual public returns (bool);

}

contract SwapperV2Orbi {
    
    address public _owner;
    address public ERC20TokenAddress0;
    address public ERC20TokenAddress1;
    bool public presaleActive = true;
    uint public weiRaised = 0;
    uint public token0Raised = 0;
    ERC20TokenObject private ERC20Token0;
    ERC20TokenObject private ERC20Token1;
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    event SetERC20TokenAddresses(address, address);
    
    constructor() public {
        _owner = msg.sender;
    }
    
    function setERC20TokenAddresses(address addr0, address addr1) onlyOwner public returns (bool) {
        ERC20TokenAddress0 = addr0;
        ERC20TokenAddress1 = addr1;
        ERC20Token0 = ERC20TokenObject(addr0);
        ERC20Token1 = ERC20TokenObject(addr1);
        emit SetERC20TokenAddresses(addr0, addr1);
        return true;
    } 
    
    function depositERC20Token(uint amount) onlyOwner public {
        ERC20Token1.transferFrom(msg.sender, address(this), amount);
    }
    
    function swapERC20Token0ForERC20Token1(uint inputTokens) public returns (bool) {
        uint amountERC20TokenToTransfer = inputTokens * 1;
        require(amountERC20TokenToTransfer > 0, "NOT_ENOUGH_TOKENS");
        ERC20Token0.transferFrom(msg.sender, address(this), inputTokens);
        ERC20Token1.transfer(msg.sender, amountERC20TokenToTransfer);
        token0Raised = token0Raised + inputTokens;
        return true;
    }
    
    function endPresale() onlyOwner public returns (bool) {
        
        ERC20Token0.transfer(msg.sender, ERC20Token0.balanceOf(address(this)));
        ERC20Token1.transfer(msg.sender, ERC20Token1.balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
        presaleActive = false;
        return true;
        
    }
    
}