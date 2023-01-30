/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity 0.5.8;


library SafeMath {

    uint256 constant internal MAX_UINT = 2 ** 256 - 1; // max uint256

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        if (_a == 0) {
            return 0;
        }
        require(MAX_UINT / _a >= _b);
        return _a * _b;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b != 0);
        return _a / _b;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        return _a - _b;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(MAX_UINT - _a >= _b);
        return _a + _b;
    }

}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () public {
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
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

/**
 * @title ERC20 Private Token Generation Program
 */
contract CSSSale is Pausable {

    using SafeMath for uint256;

    ERC20 public tokenContract;
    address payable public teamWallet;
    uint256 public rate = 1825;
    uint256 public minValue = 0.1 ether;
    uint256 public maxValue = 0 ether;

    uint256 public minDate = 0;
    uint256 public maxDate = 0;

    uint256 public totalSupply = 0;

    event Buy(address indexed sender, address indexed recipient, uint256 value, uint256 tokens);
    event NewRate(uint256 rate);

    mapping(address => uint256) public records;

    constructor(address _tokenContract, address payable _teamWallet, uint256 _rate, uint256 _minDate, uint256 _maxDate) public {
        require(_tokenContract != address(0));
        require(_teamWallet != address(0));
        tokenContract = ERC20(_tokenContract);
        teamWallet = _teamWallet;
        rate = _rate;
        minDate = _minDate;
        maxDate = _maxDate;
    }


    function () payable external {
        buy(msg.sender);
    }

    function buy(address recipient) payable public whenNotPaused {
        require(msg.value >= minValue);
        require(maxValue == 0 || msg.value <= maxValue);
        require(minDate == 0 || now >= minDate);
        require(maxDate == 0 || now <= maxDate);

        uint256 tokens =  rate.mul(msg.value).div(10**10);

        tokenContract.transferFrom(teamWallet, recipient, tokens);

        records[recipient] = records[recipient].add(tokens);
        totalSupply = totalSupply.add(tokens);

        emit Buy(msg.sender, recipient, msg.value, tokens);

    }


    /**
     * change rate
     */
    function changeRate(uint256 _rate) public onlyOwner {
        rate = _rate;
        emit NewRate(_rate);
    }

    /**
     * change min value
     */
    function changeMinValue(uint256 _value) public onlyOwner {
        minValue = _value;
    }
    /**
     * change max value
     */
    function changeMaxValue(uint256 _value) public onlyOwner {
        maxValue = _value;
    }

        /**
     * change min date
     */
    function changeMinDate(uint256 _date) public onlyOwner {
        minDate = _date;
    }
    /**
     * change max date
     */
    function changeMaxDate(uint256 _date) public onlyOwner {
        maxDate = _date;
    }
    /**
     * change team wallet
     */
    function changeTeamWallet(address payable _teamWallet) public onlyOwner {
        require(_teamWallet != address(0));
        teamWallet = _teamWallet;
    }

    /**
     * change Token Contract
     */
    function changeTokenContract(address _tokenContract) public onlyOwner {
        require(_tokenContract != address(0));
        tokenContract = ERC20(_tokenContract);
    }

    /**
     * withdraw ether
     */
    function withdrawEth() public onlyOwner {
        teamWallet.transfer(address(this).balance);
    }


    /**
     * withdraw foreign tokens
     */
    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {
        ERC20Basic token = ERC20Basic(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }

}