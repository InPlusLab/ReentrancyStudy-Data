/**
 *Submitted for verification at Etherscan.io on 2020-08-04
*/

pragma solidity >=0.4.0 <0.6.0;

/* 



Hello!
This smart contract is a project affiliate program ToGETher. 
Our goal is to create a crowdfunding platform protected from fraudsters, working with fiat and cryptocurrency projects, 
which will be able to offer its users both an opportunity to make investments and options for earning money for investments.

We really hope for your support.
Below, I will describe in detail how this smart contract works.


A LITTLE ABOUT OUR PARTNERSHIP PROGRAM

The affiliate program has two directions, access to which you can get by making a donation, the amount of which is indicated in the corresponding function. 
Donate size will vary. This is necessary so that in the event of a sharp increase in ETH, the entry fee does not become too large.

The first area is the Personal Affiliate Program. Half of your donation is allocated to it. 
These funds are received by the user who is your Referrer and who invited you to the program. For FirstLine users this will be the address of the owner of the smart contract.

The second direction of the affiliate program is the Corporate affiliate program. The second half of your donation is allocated to it.
It goes to your UpLine (the person who invited the partner who invited you). You, in turn, will also receive income from the contributions
of partners who register in the program at the invitation of the users whom you brought. So the more people you invite, the higher your passive income will become.

Every fourth user you invite starts reinvestment. This is an event that allows you to invite new people. This will be charged a fee equal to the original donation. But you don't pay it. Paid automatically by every fourth partner. These funds are divided in half and distributed in two areas of the affiliate program.

Within the framework of the Personal Affiliate Program, half of the allocated funds go to your partner's Upline, who became the fourth on the account. This is the Upline for you, the Referrer.

The second half of the funds goes to the corporate affiliate program. According to its terms, funds for reinvestment go to the ETH address of the owner of the smart contract. 
We are very grateful to all of you for your efforts. Your activity is what brings the creation and full launch of our project and platform closer.

As you can see, the conditions and rules indicated in the code completely exclude fraud or the possibility of changing the conditions on our part. 
All funds are automatically distributed among recipients, which makes it impossible to scam this affiliate program.

You can donate only once from one address. More, you will not have to pay for anything, under no circumstances. The smart contract is designed in such a way that you cannot send a  donation if you have already made it earlier.

Invite people to the ToGETher Affiliate Program and earn money! 
In order to fully offset the entry costs, you only need to bring two people. Users whom you invite later will only bring you profit!


The code below is a simplified version of our Affiliate Program. We did not fill it with many incomprehensible functions,
making it as understandable as possible even for those users who have minimal knowledge of programming. 
That is why you will not see separate functions for the logic of sending and distributing funds or reinvesting here. 
All these functions are already included in the conditions prescribed in the registration functions.

Thank you very much for your attention!

*/




    contract ToGETher {
        
         struct User  {
            uint id;
            address userAddress;
            address referrerAddress;
            uint partnersCount;
            address UpLinePartner;
     }
         
         struct partner {
             address userAddress;
             address referrerAddress;
             address UpLinePartner;
         }
         
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        address public ownerWallet;  
        uint private cost = 0.06 ether;
        address[25000] private FirstLineUser;
        uint public countFirstLineUser = 25000;
    
        partner[] private partners;
       
// This is a function that denotes the owner of a smart contract. 
// It is designed so that the owner also exists as a user. He is the Upline and Referrer for all who register in the FirstLine.       
        
      constructor() public {
        ownerWallet = msg.sender; 
         User memory user = User({
            id: 1,                    
            userAddress: address (ownerWallet), 
            UpLinePartner: address(ownerWallet),
            referrerAddress: address(ownerWallet),
            partnersCount: uint(0)
        });
        users[ownerWallet] = user;
        idToAddress[1] = ownerWallet;
        lastUserId = lastUserId;
        }
    

    modifier onlyOwner() {
         require(msg.sender == ownerWallet, "Only Owner");
         _;
     }
     
      // This function is needed to adjust the size of the entry fee in case of a strong increase in the price of ETH.
    function changeCostInWei(uint NewCost)public onlyOwner returns (bool){
      cost = NewCost;
      return true;
    }
   
   //This function is necessary so that users can see the actual size of the entry cost.  The cost is indicated in WEI. 1 ETH = 1,000,000,000,000,000,000 Wei.
     function viewCost()public view  returns (uint){
       return uint (cost);
     
     }
   
// This function is for checking the balance of a smart contract. Since funds are immediately distributed among users, the balance should always be 0.
   function viewContractbalance() public view returns (uint256) {
        return address(this).balance;
     }
    
    
    
    
   
    
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Events

     event Registration (address indexed userAddress, address indexed referrerAddress, address indexed UpLinePartner);
     event RegistrationByInvitation (address indexed userAddress, address indexed referrerAddress, address indexed UpLinePartner);
   
     
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Registration

    
   function () external payable {
        revert("Invalid Transaction");
    }
    
/* 
Registration in FirsLine. These are the first partners of the project who could register without indicating the ETH address of the person who invited them. 
Otherwise, their capabilities are no different from those of other partners.

Upline and Referrer for these users will always be the owner of the smart contract. Because there are simply no addresses above this in the chain.

This type of registration has a limit on the number of people. After reaching this limit, the opportunity for registration will be closed. 
This is the condition that is written in the code.
Also, the smart contract verifies that the size of the donation you send during registration is not more or less than the specified one.
*/
    
    
   function RegistrationFirstLine(address userAddress) payable public  {
   address referrerAddress = ownerWallet;
   address receiver = ownerWallet;
   address UpLinePartner = ownerWallet;
   require(!isUserExists(userAddress), "User already Exists");
   require(msg.sender == userAddress, "You cannot register in the Partner program using someone else's ETH address or by leaving this field blank");
   require(msg.value == cost, "The amount of the contribution is indicated in the menu - Cost. The amount is indicated in Wei.");
        require(countFirstLineUser <= 25000, "The FirstLine limit has been reached. Please use the -registrationWithPartner- function and enter the ETH address of the user who invited you");
        require(countFirstLineUser > 0, "The FirstLine limit has been reached. Please use the -registrationWithPartner- function and enter the ETH address of the user who invited you");
        partners.push(partner(userAddress, referrerAddress, UpLinePartner));
     if (!address(uint160(receiver)).send(msg.value)) {
      return address(uint160(receiver)).transfer(address(this).balance);
      }
       
         User memory user = User({
            id: lastUserId,
            userAddress: address (userAddress),
            referrerAddress: address (referrerAddress),
            UpLinePartner:address (UpLinePartner),
            partnersCount: uint(0)
            
            
    });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        lastUserId = lastUserId + 1;
        countFirstLineUser = countFirstLineUser - 1;
        users[referrerAddress].partnersCount++;

       emit Registration (userAddress, referrerAddress, UpLinePartner);
        
       
         }

/*

Registration with a partner has no restrictions on the number of participants. To register using this method, you must provide the ETH address of the person who invited you.

This function contains conditions that check and prohibit re-registration. 
Also, the smart contract verifies that the size of the donation you send during registration is not more or less than the specified one.

Below are the conditions for the distribution of funds. Under normal conditions, 
the donation amount of the partner you invited is divided in half and sent to you and your Referrer (for your partner it will be UpLine).
If your partner is 4, 8, 12, 16 ... etc., by count., in the account, the Reinvest function is activated. 
In this case, the funds donated by your partner go to your Referrer (for your partner, it is Upline) and the address of the smart contract owner.

*/
        
     
    function registrationWithPartner(address referrerAddress, address userAddress) public payable {
         address UpLinePartner;
         users[userAddress].referrerAddress = referrerAddress;
         UpLinePartner = users[referrerAddress].referrerAddress;
         require(!isUserExists(userAddress), "User already exists");
         require(isUserExists(referrerAddress), "Referrer not exists"); 
         require (referrerAddress != ownerWallet, "Use registrationFirstLine. If there are no more places in the firstline - enter the ETH address of another member of the Partner program");
         require(msg.sender == userAddress, "You cannot register in the Partner program using someone else's ETH address or by leaving this field blank");
         require (msg.sender != referrerAddress, "You cannot invite yourself!");
         require(msg.value == cost, "The amount of the contribution is indicated in the menu - Cost. The amount is indicated in Wei.");
          partners.push(partner(userAddress, referrerAddress, UpLinePartner));
       
     
          User memory user = User({
            id: lastUserId,
            userAddress: msg.sender,
            referrerAddress: address (referrerAddress),
            UpLinePartner: address(UpLinePartner),
            partnersCount: uint(0)
            
 });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        lastUserId = lastUserId + 1;
        
        users[referrerAddress].partnersCount++;
        
        address receiver;
        address secondReceiverAddress;
        uint partnersCount;
        uint x = partnersCount % 4 ;
         (x == 0);
         
     if ( users[referrerAddress].partnersCount % 4 ==0 ) {
        receiver = ownerWallet;
        secondReceiverAddress = UpLinePartner;
        
         if (!address(uint160(receiver)).send(msg.value/2) ) {
        return address(uint160(receiver)).transfer(address(this).balance/2); 
               }
                if (!address(uint160(secondReceiverAddress)).send(msg.value)) {
               return address(uint160(secondReceiverAddress)).transfer(address(this).balance); 
                }
        } else {    
        
        receiver = referrerAddress;
        secondReceiverAddress = UpLinePartner;
           
        if (!address(uint160(receiver)).send(msg.value/2) ) {
        return address(uint160(receiver)).transfer(address(this).balance/2); 
               }
                if (!address(uint160(secondReceiverAddress)).send(msg.value)) {
               return address(uint160(secondReceiverAddress)).transfer(address(this).balance); 
        
           }
    }
      emit RegistrationByInvitation (referrerAddress, userAddress, UpLinePartner);
        
  
        }
        
    

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
 /*
 
 The two functions listed below are needed in order to check whether the specified user already exists among the program partners or not, 
 as well as so that the code can work with ETH addresses (bytesToAddress).
 
 */
   

 function isUserExists(address userAddress) public view returns (bool) {
        return (users[userAddress].id != 0);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
         
    mapping(address => User) public users;
    mapping(uint => address) private userIds;
    mapping(uint => address) private idToAddress;
    mapping(address => uint) private balances; 
    uint public lastUserId = 2;
     
 }