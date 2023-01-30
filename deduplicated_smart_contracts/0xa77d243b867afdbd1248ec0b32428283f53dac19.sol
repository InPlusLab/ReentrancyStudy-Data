pragma solidity ^0.5.16;

import "./VERCO_ERC20_SmartContract.sol";

contract VERCO is ERC1384BasicContract {
  //  using SafeMath for uint256;

	constructor() public {
		name = "Vector Robotics";
		decimals = 18;
		totalSupply = 1000000000000000000;
		symbol = "VERCO";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}

contract Crowdsale is VERCO {


    /**@dev Sell tokens for ether
    
    */
    function buyTokens () public payable{
	    require(balances[project_owner] >= msg.value);
	    require(msg.value > 0, "AMOUNT EQUALS ZERO");
	    require(msg.sender != project_owner, "NOT BUYER");
	    balances[project_owner] = balances[project_owner].sub(msg.value);
	    balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

 /*
    //@dev  accept ETH
    function () external payable {
    buyTokens();
    saleAgent.transfer(msg.value);
    emit Received(msg.sender, msg.value);
    }
    */
}