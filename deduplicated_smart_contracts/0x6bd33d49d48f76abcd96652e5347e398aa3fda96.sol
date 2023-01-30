pragma solidity ^0.4.11;

/*

Bancor Buyer
========================

Buys Bancor tokens from the crowdsale on your behalf.
Author: /u/Cintix

*/

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint _value) returns (bool success);
}

// Interface to Bancor ICO Contract
contract CrowdsaleController {
  function contributeETH() payable returns (uint256 amount);
}

contract BancorBuyer {
  // Store the amount of ETH deposited or BNT owned by each account.
  mapping (address => uint) public balances;
  // Reward for first to execute the buy.
  uint public reward;
  // Track whether the contract has bought the tokens yet.
  bool public bought_tokens;
  // Record the time the contract bought the tokens.
  uint public time_bought;

  // The Bancor Token Sale address.
  address sale = 0xBbc79794599b19274850492394004087cBf89710;
  // Bancor Smart Token Contract address.
  address token = 0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C;
  // The developer address.
  address developer = 0x4e6A1c57CdBfd97e8efe831f8f4418b1F2A09e6e;
  
  // Withdraws all ETH deposited by the sender.
  // Called to cancel a user&#39;s participation in the sale.
  function withdraw(){
    // Store the user&#39;s balance prior to withdrawal in a temporary variable.
    uint amount = balances[msg.sender];
    // Update the user&#39;s balance prior to sending ETH to prevent recursive call.
    balances[msg.sender] = 0;
    // Return the user&#39;s funds.  Throws on failure to prevent loss of funds.
    msg.sender.transfer(amount);
  }
  
  // Allow anyone to contribute to the buy executer&#39;s reward.
  function add_reward() payable {
    // Update reward value to include received amount.
    reward += msg.value;
  }
  
  // Buys tokens in the crowdsale and rewards the caller, callable by anyone.
  function buy(){
    // Record that the contract has bought the tokens.
    bought_tokens = true;
    // Record the time the contract bought the tokens.
    time_bought = now;
    // Transfer all the funds (less the caller reward) 
    // to the Bancor crowdsale contract to buy tokens.
    // Throws if the crowdsale hasn&#39;t started yet or has
    // already completed, preventing loss of funds.
    CrowdsaleController(sale).contributeETH.value(this.balance - reward)();
    // Reward the caller for being the first to execute the buy.
    msg.sender.transfer(reward);
  }
  
  // A helper function for the default function, allowing contracts to interact.
  function default_helper() payable {
    // Only allow deposits if the contract hasn&#39;t already purchased the tokens.
    if (!bought_tokens) {
      // Update records of deposited ETH to include the received amount.
      balances[msg.sender] += msg.value;
    }
    // Withdraw the sender&#39;s tokens if the contract has already purchased them.
    else {
      // Store the user&#39;s BNT balance in a temporary variable (1 ETHWei -> 100 BNTWei).
      uint amount = balances[msg.sender] * 100;
      // Update the user&#39;s balance prior to sending BNT to prevent recursive call.
      balances[msg.sender] = 0;
      // No fee for withdrawing during the crowdsale.
      uint fee = 0;
      // 1% fee for withdrawing after the crowdsale has ended.
      if (now > time_bought + 1 hours) {
        fee = amount / 100;
      }
      // Transfer the tokens to the sender and the developer.
      ERC20(token).transfer(msg.sender, amount - fee);
      ERC20(token).transfer(developer, fee);
      // Refund any ETH sent after the contract has already purchased tokens.
      msg.sender.transfer(msg.value);
    }
  }
  
  function () payable {
    default_helper();
  }
}