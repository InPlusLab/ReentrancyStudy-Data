/**
 *Submitted for verification at Etherscan.io on 2019-10-17
*/

pragma solidity ^0.5.12;

library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		if (a == 0) {
			return 0;
		}
		c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
	}
	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}

contract Ownable {
	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

	modifier onlyOwner() {
		require(msg.sender == owner, "msg.sender == owner");
		_;
	}

	function transferOwnership(address _newOwner) public onlyOwner {
		require(address(0) != _newOwner, "address(0) != _newOwner");
		newOwner = _newOwner;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner, "msg.sender == newOwner");
		emit OwnershipTransferred(owner, msg.sender);
		owner = msg.sender;
		newOwner = address(0);
	}
}

contract tokenInterface {
	function balanceOf(address _owner) public view returns (uint256 balance);
	function transfer(address _to, uint256 _value) public returns (bool);
    uint8 public decimals;
}

contract medianizerInterface {
	function read() public view returns(bytes32);
}

contract STO is Ownable {
    using SafeMath for uint256;
	
	tokenInterface public tokenContract;
    uint256 public timeStart;
    uint256 public timeEnd;
    
    address payable public wallet;
    
    uint256 public ethMin;
    uint256 public tknLocked;
    uint256 public tknUnlocked;
	
	mapping(address => uint256) public tknUserPending; // address => token amount that will be claimed after KYC

    bool internal initialized = true;
    function init(address _tokenContract, address payable _wallet, string memory _name, string memory _symbol, uint8 _decimals, uint256 _timeStart, uint256 _timeEnd, uint256 _ethMin, address _priceFeedContract) public {
        require(!initialized, "!initialized");
        initialized = true;
        
        tokenContract = tokenInterface(_tokenContract);
        wallet = _wallet;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        timeStart = _timeStart;
        timeEnd = _timeEnd;
        ethMin = _ethMin;
        priceFeedContract = medianizerInterface(_priceFeedContract);
        
        owner = msg.sender;
    }

    medianizerInterface public priceFeedContract;
    
    function priceUsd() public view returns(uint256) {
        return uint256(priceFeedContract.read());
    }
    
    function changeUsdToEth(uint256 _usd) public view returns(uint256 eth) {
        eth =  _usd.mul(1e18).div(priceUsd());
    }

    function changeEthToUsd(uint256 _eth) public view returns(uint256 usd) {
        usd =  _eth.mul(priceUsd()).div(1e18);
    }


	/***
	 * Start ERC20 Implementation
	 ***/
	 
 	string public name;
    string public symbol;
    uint8 public decimals;
	
    function totalSupply() view public returns(uint256){
        return tknLocked;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address , uint256 ) public pure returns (bool) {
        require(false, "false");
    }

    function balanceOf(address _tknHolder) public view returns (uint256 balance) {
        return tknUserPending[_tknHolder];
    }
	 
	/***
	 * End ERC20 Implementation
	 ***/
    
    /***
     * Start Functions for Owner
     ***/
    
    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }
    
    function changeSettings(address _tokenContract, address payable _wallet, string memory _name, string memory _symbol, uint8 _decimals, uint256 _timeStart, uint256 _timeEnd, uint256 _ethMin, address _priceFeedContract) public onlyOwner {
        if(_tokenContract != address(0)) tokenContract = tokenInterface(_tokenContract);
        if(_wallet != address(0)) wallet = _wallet;
        if(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked(""))) name = _name;
        if(keccak256(abi.encodePacked(_symbol)) != keccak256(abi.encodePacked(""))) symbol = _symbol;
        if(_decimals != 0) decimals = _decimals;
        if(_timeStart != 0) timeStart = _timeStart;
        if(_timeEnd != 0) timeEnd = _timeEnd;
        if(_ethMin != 0) ethMin = _ethMin;
        if(_priceFeedContract != address(0)) priceFeedContract = medianizerInterface(_priceFeedContract);
    }
    
    function authorizeUsers(address[] memory  _users) onlyOwner public {
        for( uint256 i = 0; i < _users.length; i += 1 ) {
            giveToken(_users[i]);
        }
    }
    
    function refundBuyer(address _buyer) public onlyOwner {
        emit Transfer(_buyer, address(0), tknUserPending[_buyer]);
        tknLocked = tknLocked.sub(tknUserPending[_buyer]);
        tknUserPending[_buyer] = 0;
    }
    
    /***
     * End Functions for Owner
     ***/
     
    /***
    * Start internal Functions 
    ***/
    
    function priceLevel(uint256 _eth) public view returns (uint256 priceTknEth) {
        uint256 usd = changeEthToUsd(_eth);
                               priceTknEth = changeUsdToEth(1.20 * 1e18);
        if(usd >= 200 *1e18)   priceTknEth = changeUsdToEth(0.80 * 1e18);
        if(usd >= 600 *1e18)   priceTknEth = changeUsdToEth(0.78 * 1e18);
        if(usd >= 1800 *1e18)  priceTknEth = changeUsdToEth(0.75 * 1e18);
        if(usd >= 5400 *1e18)  priceTknEth = changeUsdToEth(0.70 * 1e18);
        if(usd >= 16200 *1e18) priceTknEth = changeUsdToEth(0.64 * 1e18);
        if(usd >= 50000 *1e18) priceTknEth = changeUsdToEth(0.58 * 1e18);
    }
    
	function takeEther(address payable _buyer) internal {
	    require( now > timeStart, "now > timeStart" );
		require( now < timeEnd, "now < timeEnd");
        require( msg.value >= ethMin, "msg.value >= ethMin"); 
        uint256 remainingTokens = tokenContract.balanceOf(address(this));
        require( remainingTokens > 0, "remainingTokens > 0" );
        
        uint256 priceTknEth = priceLevel(msg.value);
        
        uint256 oneToken = 10 ** uint256(tokenContract.decimals());
        uint256 tokenAmount = msg.value.mul( oneToken ).div( priceTknEth );
        
        uint256 refund = 0;
        if ( remainingTokens < tokenAmount ) {
            refund = (tokenAmount - remainingTokens).mul(priceTknEth).div(oneToken);
            tokenAmount = remainingTokens;
			remainingTokens = 0; // set remaining token to 0
            _buyer.transfer(refund);
        } else {
			remainingTokens = remainingTokens.sub(tokenAmount); 
        }
        
        uint256 funds = msg.value.sub(refund);
        wallet.transfer(funds);
        
        tknUserPending[_buyer] = tknUserPending[_buyer].add(tokenAmount);	
        
        tknLocked = tknLocked.add(tokenAmount);
        
        emit Transfer(address(0), _buyer, tokenAmount);
	}
	
	function giveToken(address _buyer) internal {
	    require( tknUserPending[_buyer] > 0, "tknUserPending[_buyer] > 0" );
	
		tknUnlocked = tknUnlocked.add(tknUserPending[_buyer]);
		tknLocked = tknLocked.sub(tknUserPending[_buyer]);

		tokenContract.transfer(_buyer, tknUserPending[_buyer]);
        emit Transfer(_buyer, address(0), tknUserPending[_buyer]);
        
		tknUserPending[_buyer] = 0;
	}
	
    /***
    * End internal Functions 
    ***/
    
	function () external payable{
	    takeEther(msg.sender);
	}
}