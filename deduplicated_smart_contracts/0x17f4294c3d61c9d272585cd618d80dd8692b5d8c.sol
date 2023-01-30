/**
 *Submitted for verification at Etherscan.io on 2021-05-31
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
	
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {

    address public owner;
	
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
	
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
    
}

contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;
  
	modifier whenNotPaused() {
		require(!paused);
		_;
	}
  
	modifier whenPaused() {
		require(paused);
		_;
	}
  
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}
	
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
	event Burn(address indexed burner, uint256 value);
	
	event DestroyedBlackFunds(address _blackListedUser, uint _balance);
    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);
}

contract ERC20Basic is IERC20,Pausable {
    
	using SafeMath for uint256;
    
	mapping(address => uint256) balances;
	
	mapping (address => bool) public isBlackListed;

    mapping(address => mapping (address => uint256)) allowed;
	
    uint256 totalSupply_;
	
    function totalSupply() public override view returns (uint256) {
       return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }
	
    function transfer(address receiver, uint256 numTokens) public whenNotPaused override returns (bool) {
        require(numTokens <= balances[msg.sender], "transfer amount exceeds balance");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }
	
    function transferFrom(address sender, address receiver, uint256 numTokens) public whenNotPaused override returns (bool) {
        require(!isBlackListed[sender]);
		require(numTokens <= balances[sender], "transfer amount exceeds balance");
        require(numTokens <= allowed[sender][msg.sender]);
        balances[sender] = balances[sender].sub(numTokens);
        allowed[sender][msg.sender] = allowed[sender][msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(sender, receiver, numTokens);
        return true;
    }
	
	function burn(uint256 _value) public whenNotPaused{
	    require(!isBlackListed[msg.sender]);
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
	
	function getBlackListStatus(address _maker) public view returns (bool) {
        return isBlackListed[_maker];
    }
	
	function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }
	
    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        totalSupply_ -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
}

contract IND is ERC20Basic {
    string public constant name = "INDIA COIN";
    string public constant symbol = "IND";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1400000000 * 10**18;
	constructor(address _owner){
	   owner = _owner;
       totalSupply_ = INITIAL_SUPPLY;
       balances[_owner] = INITIAL_SUPPLY;
	   emit Transfer(address(0), _owner, INITIAL_SUPPLY);
   }
}