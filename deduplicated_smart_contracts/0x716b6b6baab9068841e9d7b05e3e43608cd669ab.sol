/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity ^0.5.11;

contract chainLinkOracleCashout{
    address payable owner;
    
    address constant chainLinkToken = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant dexBlueAddress = 0x000000000000541E251335090AC5B47176AF4f7E;
    
    address oracleAddress;
    address payable arbiterAddress;
    address payable payoutAddress;
    
    uint payoutThreshold      = 1000000000000000000;  //  1 ETH as standard
    uint arbiterTargetBalance = 10000000000000000000; // 10 ETH as standard
    uint arbiterRefillBalance = 9000000000000000000;  //  9 ETH as standard
    
    // We accept ETH sends
    function() external payable {}
    
    constructor(
        address _oracleAddress,
        address payable _arbiterAddress,
        address payable _payoutAddress
    ) public {
        // set initial owner
        owner = msg.sender;
        
        // set oracle and payout addresses
        oracleAddress  = _oracleAddress;
        arbiterAddress = _arbiterAddress;
        payoutAddress  = _payoutAddress;
        
        // dexBlue contract is known and not upgradable so we can grant
        Token(chainLinkToken).approve(dexBlueAddress, 2**256 - 1);
    }
    
    function trade(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount) public payable returns(bool success){
        require(msg.sender == dexBlueAddress);
        
        // Are we offered to trade LINK for ETH
        if(
            buy_token != chainLinkToken
            || sell_token != address(0)
        ){
            return false;
        }

        uint linkBalance  = Token(chainLinkToken).balanceOf(address(this));     // get this contracts link balance

        // Check if we need to withdraw from oracle contract
        if(linkBalance < buy_amount){
            uint withdrawable = Oracle(oracleAddress).withdrawable();           // get the link balance available in the oracle contract

            if(linkBalance + withdrawable < buy_amount){
                return false;
            }

            // Withdraw the LINK from the oracle contract
            Oracle(oracleAddress).withdraw(address(this), withdrawable);
        }
 
        // deposit the link for this trade
        dexBlue(dexBlueAddress).depositToken(chainLinkToken, buy_amount);
        
        // Payout ETH
        payoutIfAboveThreshold();
        
        // return that we accepted the trade
        return true;
    }
    
    // offer the reserve to enter a trade a a taker
    function offer(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount) public returns(bool accept){
        require(msg.sender == dexBlueAddress);
        
        // Are we offered to trade LINK for ETH
        if(
            sell_token   != chainLinkToken
            || buy_token != address(0)
        ){
            return false;
        }

        uint linkBalance  = Token(chainLinkToken).balanceOf(address(this));     // get this contracts link balance

        // Check if we need to withdraw from oracle contract
        if(linkBalance < sell_amount){
            uint withdrawable = Oracle(oracleAddress).withdrawable();           // get the link balance available in the oracle contract

            if(linkBalance + withdrawable < sell_amount){
                return false;
            }

            // Withdraw the LINK from the oracle contract
            Oracle(oracleAddress).withdraw(address(this), withdrawable);
        }
        
        // deposit the link for this trade
        dexBlue(dexBlueAddress).depositToken(chainLinkToken, sell_amount);

        // return that we would accept the trade
        return true;
    }
    
    // callback function, to inform the reserve that an offer has been accepted by the maker reserve
    function offerExecuted(address, uint256, address, uint256) public{
        require(msg.sender == dexBlueAddress);
        
        // Payout ETH
        payoutIfAboveThreshold();
    }

    // payout the acquired ETH if the balance is above the payout threshold
    function payoutIfAboveThreshold() internal {
        // cache this contracts balance in memory
        uint myBalance      = address(this).balance;
        
        if(myBalance >= payoutThreshold){
            // cache arbiter balance in memory
            uint arbiterBalance = arbiterAddress.balance;
            
            // If arbiterAddress needs a refill we send ETH to it
            if(arbiterBalance <= arbiterRefillBalance){
                uint arbiterPayout = arbiterTargetBalance - arbiterBalance;
                
                if(arbiterPayout > myBalance) arbiterPayout = myBalance;
                
                myBalance -= arbiterPayout;
                arbiterAddress.transfer(arbiterPayout);
            }
            
            // Rest goes to payoutAddress
            if(myBalance >= payoutThreshold){
                payoutAddress.transfer(myBalance);
            }
        }
    }
    
    function changePayoutAddress(address payable _payoutAddress) public {
        require(msg.sender == owner);
        
        payoutAddress = _payoutAddress;
    }
    
    function changeArbiterAddress(address payable newArbiterAddress) public {
        require(msg.sender == owner);
        
        arbiterAddress = newArbiterAddress;
    }
    
    function changeArbiterBalances(uint _arbiterTargetBalance, uint _arbiterRefillBalance) public {
        require(
            msg.sender == owner
            && _arbiterTargetBalance > _arbiterRefillBalance
        );
        
        arbiterTargetBalance = _arbiterTargetBalance;
        arbiterRefillBalance = _arbiterRefillBalance;
    }
    
    function changePayoutThreshold(uint _payoutThreshold) public {
        require(msg.sender == owner);
        
        payoutThreshold = _payoutThreshold;
    }
        
    function changeOwner(address payable newOwner) public {
        require(msg.sender == owner);
        
        owner = newOwner;
    }
    
    // Oracle Owner Function Passthrough: 

    function changeOracleOwnership(address payable newOwner) public {
        require(msg.sender == owner);
        
        Oracle(oracleAddress).transferOwnership(newOwner);
    }
    
    function setOracleFulfillmentPermission(address _node, bool _allowed) public {
        require(msg.sender == owner);
        
        Oracle(oracleAddress).setFulfillmentPermission(_node, _allowed);
    }

    // Token / ETH recovery functions
    
    function approveTokenFor(address token, address spender, uint256 amount) public {
        require(msg.sender == owner);
        
        Token(token).approve(spender, amount);
    }
    
    function withdrawToken(address token, uint256 amount) public {
        require(msg.sender == owner);
        
        require(Token(token).transfer(owner, amount));      // Withdraw ERC20
    }
    
    function withdrawEther(uint256 amount) public {
        require(msg.sender == owner);
        
        require(
            owner.send(amount),
            "Sending of ETH failed."
        );
    }
    
    
    // unused dexBlue reserve functions
    
    // uninsured swap
    function swap(address, uint256, address,  uint256) public payable returns(uint256){
        revert();
    }
    
    // get output amount of swap
    function getSwapOutput(address, uint256, address) public pure returns(uint256){
        return 0;
    }
    
    function tradeWithData(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount, bytes32[] memory) public payable returns(bool success){
        // we dont handle any data, fallback to trade function
        return trade(sell_token, sell_amount, buy_token,  buy_amount);
    }
    
    function offerWithData(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount, bytes32[] memory) public returns(bool accept){
        // we dont handle any data, fallback to the offer function
        return offer(sell_token, sell_amount, buy_token, buy_amount);
    }
}


contract dexBlue{
    function depositToken(address token, uint256 amount) public {}
    function depositEther() public payable{}
    function getTokens() view public returns(address[] memory){}
}

// dexBlueReserve
contract dexBlueReserve{
    // insured trade function with fixed outcome
    function trade(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount) public payable returns(bool success){}
    
    // insured trade function with fixed outcome, passes additional data to the reserve
    function tradeWithData(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount, bytes32[] memory data) public payable returns(bool success){}
    
    // offer the reserve to enter a trade a a taker
    function offer(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount) public returns(bool accept){}
    
    // offer the reserve to enter a trade a a taker, passes additional data to the reserve
    function offerWithData(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount, bytes32[] memory data) public returns(bool accept){}
    
    // callback function, to inform the reserve that an offer has been accepted by the maker reserve
    function offerExecuted(address sell_token, uint256 sell_amount, address buy_token,  uint256 buy_amount) public{}

    // uninsured swap
    function swap(address sell_token, uint256 sell_amount, address buy_token,  uint256 min_output) public payable returns(uint256 output){}
    
    // get output amount of swap
    function getSwapOutput(address sell_token, uint256 sell_amount, address buy_token) public view returns(uint256 output){}
}


contract Oracle {
    
    function withdraw(address _recipient, uint256 _amount) public {}
  
    function withdrawable() external view returns (uint256) {}
    
    function transferOwnership(address newOwner) public {}

    function setFulfillmentPermission(address _node, bool _allowed) external {}
}


contract Token {
    /** @return total amount of tokens
      */
    function totalSupply() view public returns (uint256 supply) {}

    /** @param _owner The address from which the balance will be retrieved
      * @return The balance
      */
    function balanceOf(address _owner) view public returns (uint256 balance) {}

    /** @notice send `_value` token to `_to` from `msg.sender`
      * @param  _to     The address of the recipient
      * @param  _value  The amount of tokens to be transferred
      * @return whether the transfer was successful or not
      */
    function transfer(address _to, uint256 _value) public returns(bool) {}

    /** @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
      * @param  _from   The address of the sender
      * @param  _to     The address of the recipient
      * @param  _value  The amount of tokens to be transferred
      * @return whether the transfer was successful or not
      */
    function transferFrom(address _from, address _to, uint256 _value)  public returns(bool) {}

    /** @notice `msg.sender` approves `_addr` to spend `_value` tokens
      * @param  _spender The address of the account able to transfer the tokens
      * @param  _value   The amount of wei to be approved for transfer
      * @return whether the approval was successful or not
      */
    function approve(address _spender, uint256 _value) public returns(bool)  {}

    /** @param  _owner   The address of the account owning tokens
      * @param  _spender The address of the account able to transfer the tokens
      * @return Amount of remaining tokens allowed to spend
      */
    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint256 public decimals;
    string public name;
}