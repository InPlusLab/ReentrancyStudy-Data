pragma solidity ^0.4.19;

/* Functions from Kitten Coin main contract to be used by sale contract */
contract KittenCoin {
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
  function Ownable() {
    owner = msg.sender;
  }


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract KittenSelfDrop is Ownable {
    KittenCoin public kittenContract;
    uint8 public dropNumber;
    uint256 public kittensDroppedToTheWorld;
    uint256 public kittensRemainingToDrop;
    uint256 public holderAmount;
    uint256 public basicReward;
    uint256 public donatorReward;
    uint256 public holderReward;
    uint8 public totalDropTransactions;
    mapping (address => uint8) participants;
    
    
    // Initialize the cutest contract in the world
    function KittenSelfDrop () {
        address c = 0xac2BD14654BBf22F9d8f20c7b3a70e376d3436B4; // set Kitten Coin contract address
        kittenContract = KittenCoin(c); 
        dropNumber = 1;
        kittensDroppedToTheWorld = 0;
        kittensRemainingToDrop = 0;
        basicReward = 50000000000; // set initial basic reward to 500 Kitten Coins
        donatorReward = 50000000000; // set initial donator reward to 500 Kitten Coins
        holderReward = 50000000000; // set initial holder reward to 500 Kitten Coins
        holderAmount = 5000000000000; // set initial hold amount to 50000 Kitten Coins for extra reward
        totalDropTransactions = 0;
    }
    
    
    // Drop some wonderful cutest Kitten Coins to sender every time contract is called without function
    function() payable {
        require (participants[msg.sender] < dropNumber && kittensRemainingToDrop > basicReward);
        uint256 tokensIssued = basicReward;
        // Send extra Kitten Coins bonus if participant is donating Ether
        if (msg.value > 0)
            tokensIssued += donatorReward;
        // Send extra Kitten Coins bonus if participant holds at least holderAmount
        if (kittenContract.balanceOf(msg.sender) >= holderAmount)
            tokensIssued += holderReward;
        // Check if number of Kitten Coins to issue is higher than coins remaining for airdrop (last transaction of airdrop)
        if (tokensIssued > kittensRemainingToDrop)
            tokensIssued = kittensRemainingToDrop;
        
        // Give away these so cute Kitten Coins to contributor
        kittenContract.transfer(msg.sender, tokensIssued);
        participants[msg.sender] = dropNumber;
        kittensRemainingToDrop -= tokensIssued;
        kittensDroppedToTheWorld += tokensIssued;
        totalDropTransactions += 1;
    }
    
    
    function participant(address part) public constant returns (uint8 participationCount) {
        return participants[part];
    }
    
    
    // Increase the airdrop count to allow sweet humans asking for more beautiful Kitten Coins
    function setDropNumber(uint8 dropN) public onlyOwner {
        dropNumber = dropN;
        kittensRemainingToDrop = kittenContract.balanceOf(this);
    }
    
    
    // Define amount of Kitten Coins to hold in order to get holder reward
    function setHolderAmount(uint256 amount) public onlyOwner {
        holderAmount = amount;
    }
    
    
    // Define how many wonderful Kitten Coins contributors will receive for participating the selfdrop
    function setRewards(uint256 basic, uint256 donator, uint256 holder) public onlyOwner {
        basicReward = basic;
        donatorReward = donator;
        holderReward = holder;
    }
    
    
    // Sends all ETH contributions to lovely kitten owner
    function withdrawAll() public onlyOwner {
        owner.transfer(this.balance);
    }
    
    
    // Sends all remaining Kitten Coins to owner, just in case of emergency
    function withdrawKittenCoins() public onlyOwner {
        kittenContract.transfer(owner, kittenContract.balanceOf(this));
        kittensRemainingToDrop = 0;
    }
    
    
    // Update number of Kitten Coins remaining for drop, just in case it is needed
    function updateKittenCoinsRemainingToDrop() public {
        kittensRemainingToDrop = kittenContract.balanceOf(this);
    }
    
}