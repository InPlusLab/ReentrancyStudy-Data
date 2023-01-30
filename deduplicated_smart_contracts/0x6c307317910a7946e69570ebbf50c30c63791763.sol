/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }   

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    
    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Whitelisted {
    mapping (address => bool) WhiteBearer;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);
    

    function isWhitelisted(address account) public view returns (bool) {
        return WhiteBearer[account];
    }

    function _addWhitelisted(address account) internal virtual {
        WhiteBearer[account] = true;
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal virtual {
        WhiteBearer[account] = false;
        emit WhitelistedRemoved(account);
    }
}

abstract contract Bluelisted {
    mapping (address => bool) BlueBearer;

    event BluelistededAdded(address indexed account);
    event BluelistedRemoved(address indexed account);
    

    function isBluelisted(address account) public view returns (bool) {
        return BlueBearer[account];
    }

    function _addBluelisted(address account) internal virtual {
        BlueBearer[account] = true;
        emit BluelistededAdded(account);
    }

    function _removeBluelisted(address account) internal virtual {
        BlueBearer[account] = false;
        emit BluelistedRemoved(account);
    }
}

contract CrowdSale is Ownable, Whitelisted, Bluelisted {
    using SafeMath for uint256;
    
    struct holdTokens {
        uint256 releseHeldTime;
        uint8 round;
        uint256 amount;
        uint256 installment;
    }
    
    mapping(address => uint256[]) purchaseList;
    mapping(address => mapping(uint256 => holdTokens)) purchaseDetails;
    
    uint256 private lockTokens;
    uint256 private randomNonce = 1;
    
    // The token being sold
    IERC20 public token;
    
    // Max Sellable Token
    uint256 public maxSaleToken;
    // Tokens currently sold
    uint256 public currentSoldToken;
    // 1 wei to AQUbits exchange rate
    uint256 public rate;
    
    // Lock tokens for months
    uint8 public lockForMonths;
    // Whether to sell
    bool public isSale;
    
    constructor (IERC20 token_, uint256 rate_, uint8 lockForMonths_) public {
        require(address(token_) != address(0));
        require(rate_ > 0);
        
        token = token_;
        rate = rate_;
        lockForMonths = lockForMonths_;
        isSale = true;
    }
    
    function startSale() public onlyOwner {
        require(!isSale);
        isSale = true;
    }
    
    function stopSale() public onlyOwner {
        require(isSale);
        isSale = false;
    }
    
    /**
     * 1USDToWei = 10 ^ 18 / EtherToUSD
     * 1weiToAQUbits = 10 ^ 18 / 1USDtowei
     * rate = 1weiToAQUbits / AQUToUSD_
     **/
    function updateRate(uint256 rate_) public onlyOwner {
        require(rate != rate_);
        
        rate = rate_;
    }

    function updateLockForMonths(uint8 lockForMonths_) public onlyOwner {
        require(lockForMonths != lockForMonths_);

        lockForMonths = lockForMonths_;
    }
    
    function addMaxSaleToken(uint256 amount) public onlyOwner {
        require(token.balanceOf(_msgSender()) >= amount);
        
        maxSaleToken = maxSaleToken.add(amount);
        token.transferFrom(_msgSender(), address(this), amount);
    }
    
    fallback() external payable {
        require(isBluelisted(_msgSender()) || isWhitelisted(_msgSender()));
        
        if (isBluelisted(_msgSender())){
            buyTokens();
        } 
        
        if (isWhitelisted(_msgSender())){
            buyLockTokens();    
        }
    }
    
    function buyTokens() public payable {
        require(isSale);
    
        uint256 weiAmount = msg.value;
        uint256 tokens = rate.mul(weiAmount);
        
        require(tokens <= getSaleableBalanceToken());
        
        currentSoldToken = currentSoldToken.add(tokens);
        token.transfer(_msgSender(), tokens);
    }

    function buyLockTokens() public payable {
        require(isSale);
    
        uint256 weiAmount = msg.value;
        uint256 tokens = rate.mul(weiAmount);
        
        require(tokens <= getSaleableBalanceToken());
        
        uint256 timestamp = block.timestamp;
        uint256 LockForTime = uint256(lockForMonths).mul(30 days);
        uint256 nonce = uint256(keccak256(abi.encode(timestamp, msg.sender, randomNonce)));
        
        randomNonce++;
        
        lockTokens = lockTokens.add(tokens);
        currentSoldToken = currentSoldToken.add(tokens);
        purchaseList[_msgSender()].push(nonce);
        
        purchaseDetails[_msgSender()][nonce].releseHeldTime = timestamp.add(LockForTime);
        purchaseDetails[_msgSender()][nonce].round = 1;
        purchaseDetails[_msgSender()][nonce].amount = tokens;
        purchaseDetails[_msgSender()][nonce].installment = tokens.div(uint256(5));
    }
    
    function getContractBalanceEther() public view returns (uint256) {
        return address(this).balance;
    }
    
    function getContractBalanceToken() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    function getSaleableBalanceToken() public view returns (uint256) {
        return maxSaleToken.sub(currentSoldToken);
    }
    
    function addWhitelisted(address account) public virtual onlyOwner {
        require(!isBluelisted(account));
        require(!isWhitelisted(account));
        
        Whitelisted.WhiteBearer[account] = true;
        emit WhitelistedAdded(account);
    }

    function removeWhitelisted(address account) public virtual onlyOwner {
        require(isWhitelisted(account));
        
        Whitelisted.WhiteBearer[account] = false;
        emit WhitelistedRemoved(account);
    }
    
    function addBluelisted(address account) public virtual onlyOwner {
        require(!isBluelisted(account));
        require(!isWhitelisted(account));
        
        Bluelisted.BlueBearer[account] = true;
        emit BluelistededAdded(account);
    }

    function removeBluelisted(address account) public virtual onlyOwner {
        require(isBluelisted(account));
        
        Bluelisted.BlueBearer[account] = false;
        emit BluelistedRemoved(account);
    }
    
    function withdrawEther() public onlyOwner {
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }
    
    function withdrawToken() public onlyOwner {
        require(getContractBalanceToken() > 0);
        
        token.transfer(owner(), token.balanceOf(address(this)).sub(lockTokens));
        maxSaleToken = currentSoldToken;
    }
    
    function getPurchaseList(address account) public view returns (uint256[] memory) {
        return purchaseList[account];
    }
    
    function getPurchaseDetails(address account, uint256 nonce) public view returns (holdTokens memory) {
        return purchaseDetails[account][nonce];
    }
    
    function removePurchaseList(address account, uint256 nonce) public onlyOwner {
        lockTokens = lockTokens.sub(purchaseDetails[account][nonce].amount);
        currentSoldToken = currentSoldToken.sub(purchaseDetails[account][nonce].amount);
        
        for (uint256 index = 0; index < purchaseList[account].length; index++) {
            if (purchaseList[account][index] == nonce) {
                purchaseList[account][index] = 0;
            }
        }
        delete purchaseDetails[account][nonce];
    }
    
    function releaseHeldTokens(uint256 nonce) public {
        require(block.timestamp >= purchaseDetails[_msgSender()][nonce].releseHeldTime);
        require(purchaseDetails[_msgSender()][nonce].round > 0);
        
        uint256 releseHeldTime = purchaseDetails[_msgSender()][nonce].releseHeldTime;
        uint256 installment = purchaseDetails[_msgSender()][nonce].installment;
        uint8 round = purchaseDetails[_msgSender()][nonce].round;
        uint8 count = 0;
        
        while(round <= 5) {
            if(releseHeldTime > block.timestamp) {
                break;
            } else if(releseHeldTime <= block.timestamp){
                count++;
                releseHeldTime = releseHeldTime.add(30 days);
            }
            round++;
        }

        if (round <= 5) {
            installment = installment.mul(uint256(count));
            
            purchaseDetails[_msgSender()][nonce].releseHeldTime = releseHeldTime;
            purchaseDetails[_msgSender()][nonce].round = round;
            purchaseDetails[_msgSender()][nonce].amount = purchaseDetails[_msgSender()][nonce].amount.sub(installment);
            
            lockTokens = lockTokens.sub(installment);
            
            token.transfer(_msgSender(), installment);
        } else if (round > 5) {
            installment = installment.mul(uint256(count));
            
            purchaseDetails[_msgSender()][nonce].releseHeldTime = 0;
            purchaseDetails[_msgSender()][nonce].round = 0;
            purchaseDetails[_msgSender()][nonce].amount = 0;
            purchaseDetails[_msgSender()][nonce].installment = 0;
            
            lockTokens = lockTokens.sub(installment);
            
            token.transfer(_msgSender(), installment);
        }
    }
}