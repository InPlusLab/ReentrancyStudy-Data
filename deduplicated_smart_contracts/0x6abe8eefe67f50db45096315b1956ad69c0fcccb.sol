/**
 *Submitted for verification at Etherscan.io on 2019-12-27
*/

// File: contracts\IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev ERC20 contract interface.
 */
contract IERC20
{
	function totalSupply() public view returns (uint);
	
	function transfer(address _to, uint _value) public returns (bool success);
	
	function transferFrom(address _from, address _to, uint _value) public returns (bool success);
	
	function balanceOf(address _owner) public view returns (uint balance);
	
	function approve(address _spender, uint _value) public returns (bool success);
	
	function allowance(address _owner, address _spender) public view returns (uint remaining);
	
	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed owner, address indexed spender, uint tokens);
}

// File: contracts\SafeMathLib.sol

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------

library SafeMathLib {
	
	using SafeMathLib for uint;
	
	/**
	 * @dev Sum two uint numbers.
	 * @param a Number 1
	 * @param b Number 2
	 * @return uint
	 */
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "SafeMathLib.add: required c >= a");
    }
	
	/**
	 * @dev Substraction of uint numbers.
	 * @param a Number 1
	 * @param b Number 2
	 * @return uint
	 */
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "SafeMathLib.sub: required b <= a");
        c = a - b;
    }
	
	/**
	 * @dev Product of two uint numbers.
	 * @param a Number 1
	 * @param b Number 2
	 * @return uint
	 */
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require((a == 0 || c / a == b), "SafeMathLib.mul: required (a == 0 || c / a == b)");
    }
	
	/**
	 * @dev Division of two uint numbers.
	 * @param a Number 1
	 * @param b Number 2
	 * @return uint
	 */
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, "SafeMathLib.div: required b > 0");
        c = a / b;
    }
}

// File: contracts\FITHTokenSale.sol

pragma solidity ^0.5.0;



/**
 * @dev Fiatech FITH token sale contract.
 */
contract FITHTokenSale
{
	using SafeMathLib for uint;
	
    address payable public owner;
    
	IERC20 public tokenContract;
	
	uint256 public tokenPrice;
    uint256 public tokensSold;
	
	// tokens bought event raised when buyer purchases tokens
    event TokensBought(address _buyer, uint256 _amount, uint256 _tokensSold);
	
	// token price update event
	event TokenPriceUpdate(address _admin, uint256 _tokenPrice);
	
	
	
	/**
	 * @dev Constructor
	 */
    constructor(IERC20 _tokenContract, uint256 _tokenPrice) public
	{
		require(_tokenPrice > 0, "_tokenPrice greater than zero required");
		
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }
	
	modifier onlyOwner() {
        require(msg.sender == owner, "Owner required");
        _;
    }
	
	function tokensAvailable() public view returns (uint) {
		return tokenContract.balanceOf(address(this));
	}
	
	
	
	function _buyTokens(uint256 _numberOfTokens) internal {
        require(tokensAvailable() >= _numberOfTokens, "insufficient tokens on token-sale contract");
        require(tokenContract.transfer(msg.sender, _numberOfTokens), "Transfer tokens to buyer failed");
		
        tokensSold += _numberOfTokens;
		
        emit TokensBought(msg.sender, _numberOfTokens, tokensSold);
    }
	
	function updateTokenPrice(uint256 _tokenPrice) public onlyOwner {
        require(_tokenPrice > 0 && _tokenPrice != tokenPrice, "Token price must be greater than zero and different than current");
        
		tokenPrice = _tokenPrice;
		emit TokenPriceUpdate(owner, _tokenPrice);
    }
	
    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == (_numberOfTokens * tokenPrice), "Incorrect number of tokens");
        _buyTokens(_numberOfTokens);
    }
	
    function endSale() public onlyOwner {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))), "Transfer token-sale token balance to owner failed");
		
        // Just transfer the ether balance to the owner
        owner.transfer(address(this).balance);
    }
	
	/**
	 * Accept ETH for tokens
	 */
    function () external payable {
		uint tks = (msg.value).div(tokenPrice);
		_buyTokens(tks);
    }
	
	
	
	/**
	 * @dev Owner can transfer out (recover) any ERC20 tokens accidentally sent to this contract.
	 * @param tokenAddress Token contract address we want to recover lost tokens from.
	 * @param tokens Amount of tokens to be recovered, usually the same as the balance of this contract.
	 * @return bool
	 */
    function recoverAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool ok) {
		ok = IERC20(tokenAddress).transfer(owner, tokens);
    }
}