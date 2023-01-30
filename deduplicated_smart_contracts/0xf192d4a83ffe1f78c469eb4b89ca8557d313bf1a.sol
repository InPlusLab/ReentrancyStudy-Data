/**

 *Submitted for verification at Etherscan.io on 2019-03-13

*/



pragma solidity ^0.4.18;



 

 

/**

 * SafeMath library to support basic mathematical operations 

 * Used for security of the contract

 **/ 

 

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



 function div(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}



/**

 * Ownable contract  

 * Makes an address the owner of a contract

 * Used so that onlyOwner modifier can be Used

 * onlyOwner modifier is used so that some functions can only be called by the contract owner

 **/



contract Ownable {

  address public owner;



  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() public {

    owner = msg.sender;

  }





  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }





  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));

    OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



interface Arm {

    function transfer(address receiver, uint amount) public;

    function balanceOf(address _owner) public returns (uint256 balance);

    function showMyTokenBalance(address addr) public;

}



contract newCrowdsale is Ownable {

    

    // safe math library 

    using SafeMath for uint256;

    

    // start and end timestamps of ICO (both inclusive)

    uint256 public startTime;

    uint256 public endTime;

  

    // to maintain a list of owners and their specific equity percentages

    mapping(address=>uint256) public ownerAddresses;  //note that the first one would always be the major owner

    

    address[] owners;

    

    uint256 public majorOwnerShares = 100;

    uint256 public minorOwnerShares = 10;

    uint256 public coinPercentage = 5;

    uint256 share  = 10;

    // how many token units a buyer gets per eth

    uint256 public rate = 650;



    // amount of raised money in wei

    uint256 public weiRaised;

  

    bool public isCrowdsaleStopped = false;

  

    bool public isCrowdsalePaused = false;

    

    /**

    * event for token purchase logging

    * @param purchaser who paid for the tokens

    * @param beneficiary who got the tokens

    * @param value weis paid for purchase

    * @param amount amount of tokens purchased

    */

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



  

    // The token that would be sold using this contract(Arm here)

    Arm public token;

    

    

    function newCrowdsale(address _walletMajorOwner) public 

    {

        token = Arm(0x387890e71A8B7D79114e5843D6a712ea474BA91c); 

        

        //_daysToStart = _daysToStart * 1 days;

        

        startTime = now;   

        endTime = startTime + 90 days;

        

        require(endTime >= startTime);

        require(_walletMajorOwner != 0x0);

        

        ownerAddresses[_walletMajorOwner] = majorOwnerShares;

        

        owners.push(_walletMajorOwner);

        

        owner = _walletMajorOwner;

    }

    

    // fallback function can be used to buy tokens

    function () public payable {

    buy(msg.sender);

    }

    

    function buy(address beneficiary) public payable

    {

        require (isCrowdsaleStopped != true);

        require (isCrowdsalePaused != true);

        require ((msg.value) <= 2 ether);

        require(beneficiary != 0x0);

        require(validPurchase());



        uint256 weiAmount = msg.value;

        uint256 tokens = weiAmount.mul(rate);



        // update state

        weiRaised = weiRaised.add(weiAmount);



        token.transfer(beneficiary,tokens);

         uint partnerCoins = tokens.mul(coinPercentage);

        partnerCoins = partnerCoins.div(100);

        

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);



        forwardFunds(partnerCoins);

    }

    

     // send ether to the fund collection wallet(s)

    function forwardFunds(uint256 partnerTokenAmount) internal {

      for (uint i=0;i<owners.length;i++)

      {

         uint percent = ownerAddresses[owners[i]];

         uint amountToBeSent = msg.value.mul(percent);

         amountToBeSent = amountToBeSent.div(100);

         owners[i].transfer(amountToBeSent);

         

         if (owners[i]!=owner &&  ownerAddresses[owners[i]]>0)

         {

             token.transfer(owners[i],partnerTokenAmount);

         }

      }

    }

   

     /**

     * function to add a partner

     * can only be called by the major/actual owner wallet

     **/  

    function addPartner(address partner, uint share) public onlyOwner {



        require(partner != 0x0);

        require(ownerAddresses[owner] >=20);

        require(ownerAddresses[partner] == 0);

        owners.push(partner);

        ownerAddresses[partner] = share;

        uint majorOwnerShare = ownerAddresses[owner];

        ownerAddresses[owner] = majorOwnerShare.sub(share);

    }

    

    /**

     * function to remove a partner

     * can only be called by the major/actual owner wallet

     **/ 

    function removePartner(address partner) public onlyOwner  {

        require(partner != 0x0);

        require(ownerAddresses[partner] > 0);

        require(ownerAddresses[owner] <= 90);

        uint share_remove = ownerAddresses[partner];

        ownerAddresses[partner] = 0;

        uint majorOwnerShare = ownerAddresses[owner];

        ownerAddresses[owner] = majorOwnerShare.add(share_remove);

    }



    // @return true if the transaction can buy tokens

    function validPurchase() internal constant returns (bool) {

        bool withinPeriod = now >= startTime && now <= endTime;

        bool nonZeroPurchase = msg.value != 0;

        return withinPeriod && nonZeroPurchase;

    }



    // @return true if crowdsale event has ended

    function hasEnded() public constant returns (bool) {

        return now > endTime;

    }

  

    function showMyTokenBalance(address myAddress) public returns (uint256 tokenBalance) {

       tokenBalance = token.balanceOf(myAddress);

    }



    /**

     * function to change the end date of the ICO

     **/ 

    function setEndDate(uint256 daysToEndFromToday) public onlyOwner returns(bool) {

        daysToEndFromToday = daysToEndFromToday * 1 days;

        endTime = now + daysToEndFromToday;

    }



    /**

     * function to set the new price 

     * can only be called from owner wallet

     **/ 

    function setPriceRate(uint256 newPrice) public onlyOwner returns (bool) {

        rate = newPrice;

    }

    

    /**

     * function to pause the crowdsale 

     * can only be called from owner wallet

     **/

     

    function pauseCrowdsale() public onlyOwner returns(bool) {

        isCrowdsalePaused = true;

    }



    /**

     * function to resume the crowdsale if it is paused

     * can only be called from owner wallet

     * if the crowdsale has been stopped, this function would not resume it

     **/ 

    function resumeCrowdsale() public onlyOwner returns (bool) {

        isCrowdsalePaused = false;

    }

    

    /**

     * function to stop the crowdsale

     * can only be called from the owner wallet

     **/

    function stopCrowdsale() public onlyOwner returns (bool) {

        isCrowdsaleStopped = true;

    }

    

    /**

     * function to start the crowdsale manually

     * can only be called from the owner wallet

     * this function can be used if the owner wants to start the ICO before the specified start date

     * this function can also be used to undo the stopcrowdsale, in case the crowdsale is stopped due to human error

     **/

    function startCrowdsale() public onlyOwner returns (bool) {

        isCrowdsaleStopped = false;

        startTime = now; 

    }

    

    /**

     * Shows the remaining tokens in the contract i.e. tokens remaining for sale

     **/ 

    function tokensRemainingForSale(address contractAddress) public returns (uint balance) {

        balance = token.balanceOf(contractAddress);

    }

    

    /**

     * function to show the equity percentage of an owner - major or minor

     * can only be called from the owner wallet

     **/

  /** function checkOwnerShare (address owner) public onlyOwner constant returns (uint share) {

        share = ownerAddresses[owner];

    }**/



    /**

     * function to change the coin percentage awarded to the partners

     * can only be called from the owner wallet

     **/

    function changePartnerCoinPercentage(uint percentage) public onlyOwner {

        coinPercentage = percentage;

    }

    /*function changePartnerShare(address partner, uint new_share) public onlyOwner {

        if

        ownerAddresses[partner] = new_share;

        ownerAddresses[owner]=

    }*/

    function destroy() onlyOwner public {

    // Transfer tokens back to owner

    uint256 balance = token.balanceOf(this);

    assert(balance > 0);

    token.transfer(owner, balance);



    // There should be no ether in the contract but just in case

    selfdestruct(owner);

  }

}