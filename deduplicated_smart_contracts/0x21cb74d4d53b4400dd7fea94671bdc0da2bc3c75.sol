/**
 *Submitted for verification at Etherscan.io on 2019-12-26
*/

pragma solidity ^0.5.15;

interface ERC20CompatibleToken {
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer (address to, uint tokens) external returns (bool success);
    function transferFrom (address from, address to, uint tokens) external returns (bool success);
}

/**
 * Math operations with safety checks that throw on overflows.
 */
library SafeMath {

    function mul (uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Multiplication overflow");
        return c;
    }

    function div (uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub (uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction underflow");
        return a - b;
    }

    function add (uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "Sum overflow");
        return c;
    }

}

/**
 * Token reserve contract makes it possible to time-lock ERC20 {tokenContractAddress} tokens for {lockPeriod}, specified in the constructor.
 *
 * The time-lock is bracketed by ~30 days by default (the closest approximation to a calendar month). E.g. if {lockPeriod=5 years} and you lock 10 tokens multiple times during one month bracket,
 * you will get all tokens unlocked at a single moment after 5 years. If you lock more tokens in the next month bracket, you get them unlocked after 5 years
 * and 30 days via a single transaction.
 *
 * Example:
 * {lockPeriod = 1 year (365 days)}
 *  		   	  				  	  	      		 			  		 	  	 		 	 		 		 	  	 			 	   		    	  	 			  			 	   		 	 		
 * Year 0  ↓ You locked 10 tokens in a single month bracket    Year 1  ↓ Those 10 tokens are unlocked here
 *   |    :X   :XXX :    :    :    :    :    :    :    :    :    |    :X   :X   :    :    :    :    :
 *              ↑↑↑ You locked 50 tokens 3 times in a month bracket         ↑ Those 50 tokens are unlocked here just once
 *
 * Made with ♥ by DreamTeam. Find more info about this smart contract and others here: https://github.com/dreamteam-gg/smart-contracts
 * You can deploy similar contracts using the factory deployed at 0x67ce531B44D09cDdb2abEE72610dcbf9BC0d4f64 (Mainnet) or 0xE2906a63F512697D1e639bFe06C719f9631cDd94 (Ropsten).
 */ 		   	  				  	  	      		 			  		 	  	 		 	 		 		 	  	 			 	   		    	  	 			  			 	   		 	 		
contract TokenReserve {
 		   	  				  	  	      		 			  		 	  	 		 	 		 		 	  	 			 	   		    	  	 			  			 	   		 	 		
    using SafeMath for uint256;
    uint public constant bracketingStartDate = 1546300800; // Tue, 01 Jan 2019 00:00:00 GMT - the beginning of a new year/month/day/hour/minute

    // = 5 years, can be reassigned in constructor (see the exact number in blockchain explorer)
    uint public lockPeriod = 5 * (365 days + 6 hours);
    uint public bracketSize = 30 days + 10 hours; // Pretends to be the best approximation of a calendar month. Reassigned in constructor.
    address public tokenContractAddress; // Assigned in constructor
    mapping(address => bool) public authorizedWithdrawalAddress; // Assigned in constructor

    // Linked list of unlock records bracketed by {bracketSize}
    struct BracketRecord {
        uint nextBracket;
        uint value;
    }
    mapping(uint => BracketRecord) brackets;
    uint firstUnlockBracket;
    uint lastUnlockBracket;
    uint totalValueLocked;

    event TokensLocked(uint value, uint unlockTimestamp);
    event TokensUnlocked(uint value, uint unlockTimestamp); // Does not include tokens accidentally sent to this smart contract
    event AccountAuthorized(address account, address authorizedBy);
    event AccountDeauthorized(address account);

    modifier authorizedAccessOnly() {
        require(authorizedWithdrawalAddress[msg.sender], "Only authorized addresses can call this function");
        _;
    }

    constructor(address _tokenContractAddress, uint _lockPeriod, address[] memory authorizedWithdrawalAddresses, uint _bracketSize) public {
        require(_lockPeriod > _bracketSize, "Lock period must be strictly more than bracket size");
        lockPeriod = _lockPeriod;
        tokenContractAddress = _tokenContractAddress;
        bracketSize = _bracketSize;
        for (uint i = 0; i < authorizedWithdrawalAddresses.length; i++) {
            authorizedWithdrawalAddress[authorizedWithdrawalAddresses[i]] = true;
            emit AccountAuthorized(authorizedWithdrawalAddresses[i], address(0x0));
        }
    }

    /**
     * This function takes {value} tokens from the {msg.sender} and locks them on a smart contract within the right computed bracket.
     * Anyone can lock their tokens on this smart contract, but only an admin can unlock them.
     * Tokens have to be approved in the token smart contract before the smart contract can take them as specified.
     */
    function lockTokens(uint value) public {
        lockTokensInternal(msg.sender, value);
    }
    function lockTokensInternal(address from, uint value) internal {
        ERC20CompatibleToken(tokenContractAddress).transferFrom(from, address(this), value);
        uint unlockBracket = getBracketByTimestamp(block.timestamp.add(lockPeriod));
        if (unlockBracket == lastUnlockBracket) {
            brackets[lastUnlockBracket].value = brackets[lastUnlockBracket].value.add(value);
        } else {
            if (lastUnlockBracket == 0) {
                firstUnlockBracket = unlockBracket;
            } else {
                brackets[lastUnlockBracket].nextBracket = unlockBracket;
            }
            brackets[lastUnlockBracket = unlockBracket] = BracketRecord({
                nextBracket: 0,
                value: value
            });
        }
        totalValueLocked = totalValueLocked.add(value);
        emit TokensLocked(value, block.timestamp);
    }

    /**
     * Unlocks tokens available at the moment and sends them to message sender. Callable only by an authorized address.
     * Throws an error if no tokens are available.
     */
    function unlockTokens() public authorizedAccessOnly {
        unlockTokensInternal(msg.sender);
    }
    function unlockTokensInternal(address receiver) internal {
        uint totalUnlocked = 0;
        uint currentBracket = getBracketByTimestamp(block.timestamp);
        uint limit = 0;
        uint wasLocked = totalValueLocked;
        // Inlined (don't uses getUnlockedValue()) because it clears the storage, making an operation cheaper + has a limit to prevent possible gas overflow
        // Assuming one loop takes 30000 gas (intentially more than it takes), with an extra allowance of 300000 gas, excluding the gas refund.
        while (firstUnlockBracket > 0 && firstUnlockBracket <= currentBracket && limit++ < (block.gaslimit - 300000) / 30000) {
            totalUnlocked = totalUnlocked.add(brackets[firstUnlockBracket].value);
            uint nextBracket = brackets[firstUnlockBracket].nextBracket;
            delete brackets[firstUnlockBracket];
            firstUnlockBracket = nextBracket;
        }
        if (firstUnlockBracket == 0) {
            lastUnlockBracket = 0;
        }
        if (totalUnlocked != 0) {
            totalValueLocked = totalValueLocked.sub(totalUnlocked);
            emit TokensUnlocked(totalUnlocked, block.timestamp);
        }
        // Add tokens that were sent to a smart contract accidentally
        if (ERC20CompatibleToken(tokenContractAddress).balanceOf(address(this)) > wasLocked) {
            totalUnlocked = totalUnlocked.add(ERC20CompatibleToken(tokenContractAddress).balanceOf(address(this)).sub(wasLocked));
        }
        require(totalUnlocked != 0, "Nothing to unlock");
        ERC20CompatibleToken(tokenContractAddress).transfer(receiver, totalUnlocked);
    }

    /**
     * Any authorized address can authorize more addresses.
     */
    function authorizeWithdrawalAddress(address _authorizedWithdrawalAddress) public authorizedAccessOnly {
        require(!authorizedWithdrawalAddress[_authorizedWithdrawalAddress], "Account is already authorized");
        authorizedWithdrawalAddress[_authorizedWithdrawalAddress] = true;
        emit AccountAuthorized(_authorizedWithdrawalAddress, msg.sender);
    }

    /**
     * Only the withdrawal address itself can deauthorize. This prevents possible deadlock in case one of the authorized private keys leak.
     */
    function deauthorizeWithdrawalAddress() public authorizedAccessOnly {
        require(authorizedWithdrawalAddress[msg.sender], "Account was not authorized");
        authorizedWithdrawalAddress[msg.sender] = false;
        emit AccountDeauthorized(msg.sender);
    }

    /**
     * Public getter for blockchain explorer to show how many tokens are unlocked at the moment.
     */
    function getUnlockedValue() public view returns (uint) {
        uint totalUnlocked = 0;
        uint currentBracket = getBracketByTimestamp(block.timestamp);
        uint bracket = firstUnlockBracket;
        while (bracket > 0 && bracket <= currentBracket) {
            totalUnlocked = totalUnlocked.add(brackets[bracket].value);
            bracket = brackets[bracket].nextBracket;
        }
        return totalUnlocked;
    }

    /**
     * Public getter for blockchain explorer to show when is the next unlock possible.
     * Returns unix timestamp either in the past (if unlock is already available) or in the future (if not yet available)
     */
    function getNextUnlockTimestamp() public view returns (uint) {
        return getTimestampByBracket(firstUnlockBracket);
    }

    function getBracketByTimestamp(uint timestamp) internal view returns (uint) {
        return (timestamp - bracketingStartDate) / bracketSize;
    }

    function getTimestampByBracket(uint bracket) internal view returns (uint) {
        return bracketingStartDate + bracket * bracketSize;
    }

    /**
     * This function enables locking and unlocking of tokens via a single call from the token smart contract (incl. delegated calls).
     * If {value} == 0, receiveApproval will try to unlock tokens.
     * If {value} > 0, receiveApproval will try to lock {value} tokens.
     */
    function receiveApproval(address from, uint256 value, address, bytes calldata) external {
        require(msg.sender == tokenContractAddress, "Sender must be a token contract address");
        if (value == 0) {
            require(authorizedWithdrawalAddress[from], "Only authorized addresses can unlock tokens");
            unlockTokensInternal(from);
        } else {
            lockTokensInternal(from, value);
        }
    }
 		   	  				  	  	      		 			  		 	  	 		 	 		 		 	  	 			 	   		    	  	 			  			 	   		 	 		
}