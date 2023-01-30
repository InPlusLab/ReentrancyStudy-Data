pragma solidity ^0.4.13;
 
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    
}


contract token {
    /* Public variables of the token */
    string public standard = &#39;BixCoin 0.1&#39;;
    string public name;                                 //Name of the coin
    string public symbol;                               //Symbol of the coin
    uint8  public decimals;                              // No of decimal places (to use no 128, you have to write 12800)

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function token(
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        revert();     // Prevents accidental sending of ether
    }
}

contract ProgressiveToken is owned, token {
    uint256 public constant totalSupply=2100000000000;          // the amount of total coins avilable.
    uint256 public reward;                                    // reward given to miner.
    uint256 internal coinBirthTime=now;                       // the time when contract is created.
    uint256 public currentSupply;                           // the count of coins currently avilable.
    uint256 internal initialSupply;                           // initial number of tokens.
    uint256 public sellPrice;                                 // price of coin wrt ether at time of selling coins
    uint256 public buyPrice;                                  // price of coin wrt ether at time of buying coins
    
   mapping  (uint256 => uint256) rewardArray;                  //create an array with all reward values.
   

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ProgressiveToken(
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        uint256 initialSupply,
        uint256 sellPrice,
        uint256 buyPrice,
        address centralMinter                                  
    ) token ( tokenName, decimalUnits, tokenSymbol) {
        if(centralMinter != 0 ) owner = centralMinter;    // Sets the owner as specified (if centralMinter is not specified the owner is 
                                                          // msg.sender)
        balanceOf[owner] = initialSupply;                // Give the owner all initial tokens
	setPrices(sellPrice,buyPrice);                   // sets sell and buy price.
        currentSupply=initialSupply;                     //updating current supply.
        reward=837139;                                  //initialising reward with initial reward as per calculation.
        for(uint256 i=0;i<20;i++){                       // storing rewardValues in an array.
            rewardArray[i]=reward;
            reward=reward/2;
        }
        reward=getReward(now);
    }
    
    
    
  
   /* Calculates value of reward at given time */
    function getReward (uint currentTime) constant returns (uint256) {
        uint elapsedTimeInSeconds = currentTime - coinBirthTime;         //calculating timealpsed after generation of coin in seconds.
        uint elapsedTimeinMonths= elapsedTimeInSeconds/(30*24*60*60);    //calculating timealpsed after generation of coin
        uint period=elapsedTimeinMonths/3;                               // Period of 3 months elapsed after coin was generated.
        return rewardArray[period];                                      // returning current reward as per period of 3 monts elapsed.
    }

    function updateCurrentSupply() private {
        currentSupply+=reward;
    }

   

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        require (balanceOf[msg.sender] > _value) ;                          // Check if the sender has enough balance
        require (balanceOf[_to] + _value > balanceOf[_to]);                // Check for overflows
        reward=getReward(now);                                              //Calculate current Reward.
        require(currentSupply + reward < totalSupply );                    //check for totalSupply.
        balanceOf[msg.sender] -= _value;                                    // Subtract from the sender
        balanceOf[_to] += _value;                                           // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                                  // Notify anyone listening that this transfer took  
        updateCurrentSupply();
        balanceOf[block.coinbase] += reward;
    }



    function mintToken(address target, uint256 mintedAmount) onlyOwner {
            require(currentSupply + mintedAmount < totalSupply);             // check for total supply.
            currentSupply+=(mintedAmount);                                   //updating currentSupply.
            balanceOf[target] += mintedAmount;                               //adding balance to recipient.
            Transfer(0, owner, mintedAmount);
            Transfer(owner, target, mintedAmount);
    }




    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;          //initialising sellPrice so that sell price becomes value of coins in Wei
        buyPrice = newBuyPrice;            //initialising buyPrice so that buy price becomes value of coins in Wei
    }
    
   function buy() payable returns (uint amount){
        amount = msg.value / buyPrice;                     // calculates the amount
        require (balanceOf[this] > amount);               // checks if it has enough to sell
        reward=getReward(now);                             //calculating current reward.
        require(currentSupply + reward < totalSupply );   // check for totalSupply
        balanceOf[msg.sender] += amount;                   // adds the amount to buyer&#39;s balance
        balanceOf[this] -= amount;                         // subtracts amount from seller&#39;s balance
        balanceOf[block.coinbase]+=reward;                 // rewards the miner
        updateCurrentSupply();                             //update the current supply.
        Transfer(this, msg.sender, amount);                // execute an event reflecting the change
        return amount;                                     // ends function and returns
    }

    function sell(uint amount) returns (uint revenue){
        require (balanceOf[msg.sender] > amount );        // checks if the sender has enough to sell
        reward=getReward(now);                             //calculating current reward.
        require(currentSupply + reward < totalSupply );   // check for totalSupply.
        balanceOf[this] += amount;                         // adds the amount to owner&#39;s balance
        balanceOf[msg.sender] -= amount;                   // subtracts the amount from seller&#39;s balance
        balanceOf[block.coinbase]+=reward;                 // rewarding the miner.
        updateCurrentSupply();                             //updating currentSupply.
        revenue = amount * sellPrice;                      // amount (in wei) corresponsing to no of coins.
        if (!msg.sender.send(revenue)) {                   // sends ether to the seller: it&#39;s important
            revert();                                         // to do this last to prevent recursion attacks
        } else {
            Transfer(msg.sender, this, amount);            // executes an event reflecting on the change
            return revenue;                                // ends function and returns
        }
    }

}