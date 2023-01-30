/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

/**                  ____ 
                  .'* *.'
               __/_*_*(_
              / _______ \
             _\_)/___\(_/_ 
            / _((\- -/))_ \
            \ \())(-)(()/ /
             ' \(((()))/ '
            / ' \)).))/ ' \
           / _ \ - | - /_  \
          (   ( .;''';. .'  )
          _\"__ /    )\ __"/_
            \/  \   ' /  \/
             .'  '...' ' )
              / /  |  \ \
             / .   .   . \
            /   .     .   \
           /   /   |   \   \
         .'   /    b    '.  '.
     _.-'    /     Bb     '-. '-._ 
 _.-'       |      BBb       '-.  '-. 
(___________\____.dBBBb.________)____)
    
╔╦╗┌─┐┌─┐┬┌─┐  ╔╗ ┌─┐┬  ┌─┐┌┐┌┌─┐┌─┐┬─┐
║║║├─┤│ ┬││    ╠╩╗├─┤│  ├─┤││││  ├┤ ├┬┘
╩ ╩┴ ┴└─┘┴└─┘  ╚═╝┴ ┴┴─┘┴ ┴┘└┘└─┘└─┘┴└─
     https://magicbalancer.org/
     
*/
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;
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

contract Ownable {
  address payable owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    owner = payable(msg.sender);
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address payable newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

interface MGBToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address _owner) external returns (uint256 balance);
    function mint(address wallet, address buyer, uint256 tokenAmount) external;
    function showMyTokenBalance(address addr) external;
}

contract Presale is Ownable {
    
    using SafeMath for uint256;
    
    uint256 public startTime;
    uint256 public endTime;
  
    mapping(address=>uint256) public ownerAddresses;  
    mapping(address=>uint256) public BuyerList;
    address public _burnaddress = 0x000000000000000000000000000000000000dEaD;
    address payable[] owners;

    uint256 public MAX_BUY_LIMIT = 3000000000000000000;
    uint256 public majorOwnerShares = 100;
    uint public    referralReward = 10;
    uint256 public coinPercentage = 56;
    uint256 public rate = 999;
    uint256 public weiRaised;
  
    bool public isPresaleStopped = false;
  
    bool public isPresalePaused = false;
    
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event Transfered(address indexed purchaser, address indexed referral, uint256 amount);

  
    MGBToken public token;
    
    
    constructor(address payable _walletMajorOwner) 
    {
        token = MGBToken(0xF4f3d6A60765bF705B27716f50FccBa5F0eA0CA1); 
        startTime = 1614340592 ;   
        endTime = startTime + 90 days;
        require(endTime >= startTime);
        require(_walletMajorOwner != address(0));
        
        ownerAddresses[_walletMajorOwner] = majorOwnerShares;
        
        owners.push(_walletMajorOwner);
        
        owner = _walletMajorOwner;
    }
    
    fallback() external payable {
        buy(msg.sender, owner);
    }
    
    receive() external payable {}
    
    function isContract(address _addr) public view returns (bool _isContract){
        uint32 size;
        assembly {
        size := extcodesize(_addr)}
        
        return (size > 0);
    }
    
    function buy(address beneficiary, address payable referral) public payable
    {
        require (isPresaleStopped != true, 'Presale is stopped');
        require (isPresalePaused != true, 'Presale is paused');
        require ( !(isContract(msg.sender)), 'Bots not allowed');
        require(beneficiary != address(0), 'user asking for tokens sent to be on 0 address');
        require(validPurchase(), 'its not a valid purchase');
        require(BuyerList[msg.sender] < MAX_BUY_LIMIT, 'MAX_BUY_LIMIT Achieved already for this wallet');
        uint256 weiAmount = msg.value;
        require(weiAmount <3000000000000000001 , 'MAX_BUY_LIMIT is 3 ETH'); 
        uint256 tokens = weiAmount.mul(rate);
        
        uint256 weiMinusfee = msg.value - (msg.value * referralReward / 100);
        uint256 refReward = msg.value * referralReward / 100;
        
        weiRaised = weiRaised.add(weiAmount);
        splitFunds(referral, refReward);
        
        token.transfer(beneficiary,tokens);
         uint partnerCoins = tokens.mul(coinPercentage);
        partnerCoins = partnerCoins.div(100);
        
        BuyerList[msg.sender] = BuyerList[msg.sender].add(msg.value);
        
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds(partnerCoins, weiMinusfee);
    }
    
    function splitFunds(address payable _b, uint256 amount) internal {

        _b.transfer(amount);
        
         emit Transfered(msg.sender, _b, amount);
    }
    
    function forwardFunds(uint256 partnerTokenAmount, uint256 weiMinusfee) internal {
      for (uint i=0;i<owners.length;i++)
      {
         uint percent = ownerAddresses[owners[i]];
         uint amountToBeSent = weiMinusfee.mul(percent);
         amountToBeSent = amountToBeSent.div(100);
         owners[i].transfer(amountToBeSent);
         
         if (owners[i]!=owner &&  ownerAddresses[owners[i]]>0)
         {
             token.transfer(owners[i],partnerTokenAmount);
         }
      }
    }
 
    function addLiquidityPool(address payable partner) public onlyOwner {

        require(partner != address(0));
        require(ownerAddresses[owner] >=78);
        require(ownerAddresses[partner] == 0);
        owners.push(partner);
        ownerAddresses[partner] = 78;
        uint majorOwnerShare = ownerAddresses[owner];
        ownerAddresses[owner] = majorOwnerShare.sub(78);
    }

    function validPurchase() internal returns (bool) {
        bool withinPeriod = block.timestamp >= startTime && block.timestamp <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function hasEnded() public view returns (bool) {
        return block.timestamp > endTime;
    }
  
    function showMyTokenBalance(address myAddress) public returns (uint256 tokenBalance) {
       tokenBalance = token.balanceOf(myAddress);
    }

    function setEndDate(uint256 daysToEndFromToday) public onlyOwner returns(bool) {
        daysToEndFromToday = daysToEndFromToday * 1 days;
        endTime = block.timestamp + daysToEndFromToday;
        return true;
    }

    function setPriceRate(uint256 newPrice) public onlyOwner returns (bool) {
        rate = newPrice;
         return true;
    }
    
    function setReferralReward(uint256 newReward) public onlyOwner returns (bool) {
        referralReward = newReward;
         return true;
    }

    function pausePresale() public onlyOwner returns(bool) {
        isPresalePaused = true;
         return isPresalePaused;
    }

    function resumePresale() public onlyOwner returns (bool) {
        isPresalePaused = false;
        return !isPresalePaused;
    }

    function stopPresale() public onlyOwner returns (bool) {
        isPresaleStopped = true;
        return true;
    }
    function BurnUnsoldTokens() public onlyOwner {
        uint256 unsold = token.balanceOf(address(this));
        token.transfer(_burnaddress,unsold);
    }
    
    function startPresale() public onlyOwner returns (bool) {
        isPresaleStopped = false;
        startTime = block.timestamp; 
        return true;
    }
    
    function tokensRemainingForSale(address contractAddress) public returns (uint balance) {
        balance = token.balanceOf(contractAddress);
    }

    function checkOwnerShare (address owner) public view onlyOwner returns (uint) {
        uint share = ownerAddresses[owner];
        return share;
    }
}