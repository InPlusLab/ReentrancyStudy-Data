pragma solidity ^0.4.21;


// If your investment is less than 300 ETHs. Send ETH here, this contract will
// transfer VNETs to you automatically. And I just make a small profit.
//
// And you can get more details via etherscan.io - "Read Contract"


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);


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
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    /**
     * @dev Rescue compatible ERC20Basic Token
     *
     * @param _token ERC20Basic The address of the token contract
     */
    function rescueTokens(ERC20Basic _token) external onlyOwner {
        uint256 balance = _token.balanceOf(this);
        assert(_token.transfer(owner, balance));
    }

    /**
     * @dev Withdraw Ether
     */
    function withdrawEther() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}


/**
 * @title Sell Tokens
 */
contract SellTokens is Ownable {
    using SafeMath for uint256;

    ERC20Basic public token;

    uint256 decimalDiff;
    uint256 public rate;
    string public description;
    string public telegram;


    /**
     * @dev Constructor
     */
    constructor(ERC20Basic _token, uint256 _tokenDecimals, uint256 _rate, string _description, string _telegram) public {
        uint256 etherDecimals = 18;

        token = _token;
        decimalDiff = etherDecimals.sub(_tokenDecimals);
        rate = _rate;
        description = _description;
        telegram = _telegram;
    }

    /**
     * @dev receive ETH and send tokens
     */
    function () public payable {
        uint256 weiAmount = msg.value;
        uint256 tokenAmount = weiAmount.mul(rate).div(10 ** decimalDiff);
        
        require(tokenAmount > 0);
        
        assert(token.transfer(msg.sender, tokenAmount));
        owner.transfer(address(this).balance);
    }

    /**
     * @dev Set Rate
     * 
     * @param _rate uint256
     */
    function setRate(uint256 _rate) external onlyOwner returns (bool) {
        rate = _rate;
        return true;
    }

    /**
     * @dev Set Description
     * 
     * @param _description string
     */
    function setDescription(string _description) external onlyOwner returns (bool) {
        description = _description;
        return true;
    }

    /**
     * @dev Set Telegram
     * 
     * @param _telegram string
     */
    function setTelegram(string _telegram) external onlyOwner returns (bool) {
        telegram = _telegram;
        return true;
    }
}