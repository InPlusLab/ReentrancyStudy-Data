/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

pragma solidity 0.4.24;

/**


||========      ===========  ||=========     ||          ||     ||=========      ==========    
||                  ||       ||        ||    ||          ||     ||                   ||
||=======           ||       ||      ||      ||          ||     ||========||         ||
||                  ||       ||   ||         ||          ||               ||         ||
||========          ||       ||       ||     || ======== ||     ||========||         ||


                                        ()


|| \\    || \\    ||=======||   || \\     ||   ||========    \\   ||
||  \\  ||  \\    ||       ||   ||  \\    ||   ||              \\||
||   \\||   \\    ||       ||   ||   \\   ||   ||=======        ||    
||          \\    ||       ||   ||    \\  ||   ||               ||
||          \\    ||=======||   ||     \\ ||   ||========       ||

*/




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract eTrustmoney is Ownable {
    event Multisended(uint256 value , address sender);
    using SafeMath for uint256;
    address MaintenaceFeeAddress;
    uint256 lastUserId = 1;
    
    struct User {
        uint txnNumber;
        address userAddress;
        address referralAddress;
        uint userId;
        address LevelContribution;
        address LevelIncomeLevel1;
        address LevelIncomeLevel2;
        address LevelIncomeLevel3;
        address LevelIncomeLevel4;
        address AutoPoolBatch1;
        address AutoPoolBatch2;
        address AutoPoolBatch3;
        address AutoPoolBatch4;
        address AutoPoolBatch5;
        
        
    }
    
        uint256 referralAamount;
        uint256 LevelContributionAmount;
        uint256 LevelIncomeLevel1Amount;
        uint256 LevelIncomeLevel2Amount;
        uint256 LevelIncomeLevel3Amount;
        uint256 LevelIncomeLevel4Amount;
        uint256 AutoPoolBatch1Amount;
        uint256 AutoPoolBatch2Amount;
        uint256 AutoPoolBatch3Amount;
        uint256 AutoPoolBatch4Amount;
        uint256 AutoPoolBatch5Amount;
        uint256 MaintenaceFeeAmount;
        
    mapping(address => User) public users;
    // mapping(uint256 => userBalances) public balances;

    constructor () public {
        MaintenaceFeeAddress = 0xE58bc8A11a5584007B33513b653b39C272DcaF0b;
    }
    
    function registration(address referrar) public payable {
        require(msg.value == 0.14 ether);
        users[msg.sender].userAddress = msg.sender;
        users[msg.sender].referralAddress = referrar;
        users[msg.sender].txnNumber = lastUserId;
      
        MaintenaceFeeAddress.transfer(0.02 ether);
        referrar.transfer(0.12 ether);
        
        lastUserId++;
        
    }
    
    function getLastUserId() public view returns(uint256) {
        return lastUserId;
    }
    
    function X12Transfers(uint8 status, address userAddress, uint userId,  address referralAddress, address LevelContribution, address LevelIncomeLevel1, address LevelIncomeLevel2, 
        address LevelIncomeLevel3, address LevelIncomeLevel4, address AutoPoolBatch1, address AutoPoolBatch2,address AutoPoolBatch3, 
        address AutoPoolBatch4, address AutoPoolBatch5) public payable  {
            
        require(status == 2 || status == 3 || status == 4, "Invalid status");
        
        if (status == 2) {
        
             referralAamount = 0.05 ether;
             LevelContributionAmount = 0.05 ether;
             LevelIncomeLevel1Amount = 0.0125 ether;
             LevelIncomeLevel2Amount = 0.0125 ether;
             LevelIncomeLevel3Amount = 0.0125 ether;
             LevelIncomeLevel4Amount = 0.0125 ether;
             AutoPoolBatch1Amount = 0.01 ether;
             AutoPoolBatch2Amount = 0.01 ether;
             AutoPoolBatch3Amount = 0.01 ether;
             AutoPoolBatch4Amount = 0.01 ether;
             AutoPoolBatch5Amount = 0.01 ether;
             MaintenaceFeeAmount = 0.02 ether;
        }
        else if (status == 3 ) {
             referralAamount = 0.1 ether;
             LevelContributionAmount = 0.1 ether;
             LevelIncomeLevel1Amount = 0.025 ether;
             LevelIncomeLevel2Amount = 0.025 ether;
             LevelIncomeLevel3Amount = 0.025 ether;
             LevelIncomeLevel4Amount = 0.025 ether;
             AutoPoolBatch1Amount = 0.02 ether;
             AutoPoolBatch2Amount = 0.02 ether;
             AutoPoolBatch3Amount = 0.02 ether;
             AutoPoolBatch4Amount = 0.02 ether;
             AutoPoolBatch5Amount = 0.02 ether;
             MaintenaceFeeAmount = 0.02 ether;
        } else if (status == 4 ){
            referralAamount = 0.4 ether;
             LevelContributionAmount = 0.4 ether;
             LevelIncomeLevel1Amount = 0.1 ether;
             LevelIncomeLevel2Amount = 0.1 ether;
             LevelIncomeLevel3Amount = 0.1 ether;
             LevelIncomeLevel4Amount = 0.1 ether;
             AutoPoolBatch1Amount = 0.08 ether;
             AutoPoolBatch2Amount = 0.08 ether;
             AutoPoolBatch3Amount = 0.08 ether;
             AutoPoolBatch4Amount = 0.08 ether;
             AutoPoolBatch5Amount = 0.08 ether;
             MaintenaceFeeAmount = 0.2 ether;
        }
            referralAddress.transfer(referralAamount);
            LevelContribution.transfer(LevelContributionAmount);
            LevelIncomeLevel1.transfer(LevelIncomeLevel1Amount);
            LevelIncomeLevel2.transfer(LevelIncomeLevel2Amount);
            LevelIncomeLevel3.transfer(LevelIncomeLevel3Amount);
            LevelIncomeLevel4.transfer(LevelIncomeLevel4Amount);
            AutoPoolBatch1.transfer(AutoPoolBatch1Amount);
            AutoPoolBatch2.transfer(AutoPoolBatch2Amount);
            AutoPoolBatch3.transfer(AutoPoolBatch3Amount);
            AutoPoolBatch4.transfer(AutoPoolBatch4Amount);
            AutoPoolBatch5.transfer(AutoPoolBatch5Amount);
            MaintenaceFeeAddress.transfer(MaintenaceFeeAmount);
            
            users[userAddress].userAddress = userAddress;
            users[userAddress].referralAddress = referralAddress;
            users[userAddress].userId = userId;
            users[userAddress].LevelContribution = LevelContribution;
            users[userAddress].LevelIncomeLevel1 = LevelIncomeLevel1;
            users[userAddress].LevelIncomeLevel2 = LevelIncomeLevel2;
            users[userAddress].LevelIncomeLevel3 = LevelIncomeLevel3;
            users[userAddress].LevelIncomeLevel4 = LevelIncomeLevel4;
            
            users[userAddress].AutoPoolBatch1 = AutoPoolBatch1;
            users[userAddress].AutoPoolBatch2 = AutoPoolBatch2;
            users[userAddress].AutoPoolBatch3 = AutoPoolBatch3;
            users[userAddress].AutoPoolBatch4 = AutoPoolBatch4;
            users[userAddress].AutoPoolBatch5 = AutoPoolBatch5;
            
            lastUserId++;


    }
    
     function X7Transfers(uint8 status, address userAddress, uint userId,  address referralAddress, address LevelContribution, 
     address AutoPoolBatch1, address AutoPoolBatch2,address AutoPoolBatch3, 
        address AutoPoolBatch4, address AutoPoolBatch5) public payable  {
            
        require(status == 5 || status == 6 || status == 7, "Invalid status");
        
        if (status == 5) {
             referralAamount = 1 ether;
             LevelContributionAmount = 3 ether;
             AutoPoolBatch1Amount = 0.4 ether;
             AutoPoolBatch2Amount = 0.4 ether;
             AutoPoolBatch3Amount = 0.4 ether;
             AutoPoolBatch4Amount = 0.4 ether;
             AutoPoolBatch5Amount = 0.4 ether;
             MaintenaceFeeAmount = 0.2 ether;
        }
        else if (status == 6 ) {
              referralAamount = 1 ether;
             LevelContributionAmount = 5 ether;
             AutoPoolBatch1Amount = 0.8 ether;
             AutoPoolBatch2Amount = 0.8 ether;
             AutoPoolBatch3Amount = 0.8 ether;
             AutoPoolBatch4Amount = 0.8 ether;
             AutoPoolBatch5Amount = 0.8 ether;
             MaintenaceFeeAmount = 0.25 ether;
        } else if (status == 7 ){
            referralAamount = 2 ether;
             LevelContributionAmount = 8 ether;
             AutoPoolBatch1Amount = 2 ether;
             AutoPoolBatch2Amount = 2 ether;
             AutoPoolBatch3Amount = 2 ether;
             AutoPoolBatch4Amount = 2 ether;
             AutoPoolBatch5Amount = 2 ether;
             MaintenaceFeeAmount = 0.5 ether;
        }
            referralAddress.transfer(referralAamount);
            LevelContribution.transfer(LevelContributionAmount);
            AutoPoolBatch1.transfer(AutoPoolBatch1Amount);
            AutoPoolBatch2.transfer(AutoPoolBatch2Amount);
            AutoPoolBatch3.transfer(AutoPoolBatch3Amount);
            AutoPoolBatch4.transfer(AutoPoolBatch4Amount);
            AutoPoolBatch5.transfer(AutoPoolBatch5Amount);
            MaintenaceFeeAddress.transfer(MaintenaceFeeAmount);
            
            users[userAddress].userAddress = userAddress;
            users[userAddress].referralAddress = referralAddress;
            users[userAddress].userId = userId;
            users[userAddress].LevelContribution = LevelContribution;
            
            users[userAddress].AutoPoolBatch1 = AutoPoolBatch1;
            users[userAddress].AutoPoolBatch2 = AutoPoolBatch2;
            users[userAddress].AutoPoolBatch3 = AutoPoolBatch3;
            users[userAddress].AutoPoolBatch4 = AutoPoolBatch4;
            users[userAddress].AutoPoolBatch5 = AutoPoolBatch5;
            
            lastUserId++;

    }
    
    function fastTrack(address qr50Address, address affiliateIncome1, address affiliateIncome2,  address rebirthIncome1, 
     address rebirthIncome2, address rebirthIncome3,address rebirthIncome4, 
        address rebirthIncome5) public payable {
            
        require(msg.value == 0.14 ether, "Invalid value");
         
            qr50Address.transfer(0.07 ether);
            affiliateIncome1.transfer(0.005 ether);
            affiliateIncome2.transfer(0.005 ether);
            rebirthIncome1.transfer(0.01 ether);
            rebirthIncome2.transfer(0.01 ether);
            rebirthIncome3.transfer(0.01 ether);
            rebirthIncome4.transfer(0.01 ether);
            rebirthIncome5.transfer(0.01 ether);
            MaintenaceFeeAddress.transfer(0.01 ether);
            
            // lastUserId++;

    }
    
    function goodDay(address referralAddress, address qr10Address, address level1) public payable {
            
        require(msg.value == 0.05 ether, "Invalid value");
         
            referralAddress.transfer(0.005 ether);
            qr10Address.transfer(0.005 ether);

            level1.transfer(0.035 ether);
           
            MaintenaceFeeAddress.transfer(0.005 ether);
            
            // lastUserId++;

    }
    
    function greenTrack(address referralAddress1, address referralAddress2, address qr25Address, address level1) public payable {
            
        require(msg.value == 0.09 ether, "Invalid value");
         
            referralAddress1.transfer(0.005 ether);
            referralAddress2.transfer(0.005 ether);

            qr25Address.transfer(0.0225 ether);

            level1.transfer(0.0525 ether);
            MaintenaceFeeAddress.transfer(0.005 ether);
            
            // lastUserId++;

    }
    
    function allTransfer() public onlyOwner {
        MaintenaceFeeAddress.transfer(address(this).balance);
    }
    
    function multisendEther(address[] _contributors, uint256[] _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        emit Multisended(msg.value, msg.sender);
    }
}