/**
 *Submitted for verification at Etherscan.io on 2019-12-21
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
	
    address payable public admin;
    
	IERC20 public tokenContract;
	
	uint256 public tokenPrice;
    uint256 public tokensSold;
	
	// sell event raised when buyer purchases tokens
    event Sell(address _buyer, uint256 _amount, uint256 _tokensSold);
	
	// token price update event
	event TokenPriceUpdate(address _admin, uint256 _tokenPrice);
	
	
	
	/**
	 * @dev Constructor
	 */
    constructor(IERC20 _tokenContract, uint256 _tokenPrice) public
	{
		require(_tokenPrice > 0, "_tokenPrice greater than zero required");
		
        admin = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }
	
	modifier onlyAdmin() {
        require(msg.sender == admin, "Admin required");
        _;
    }
	
	function updateTokenPrice(uint256 _tokenPrice) public onlyAdmin {
        require(_tokenPrice > 0 && _tokenPrice != tokenPrice, "Token price must be greater than zero and different than current");
        
		tokenPrice = _tokenPrice;
		emit TokenPriceUpdate(admin, _tokenPrice);
    }
	
    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == (_numberOfTokens * tokenPrice), "Incorrect number of tokens");
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens, "insufficient tokens on token-sale contract");
        require(tokenContract.transfer(msg.sender, _numberOfTokens), "Transfer tokens to buyer failed");
		
        tokensSold += _numberOfTokens;
		
        emit Sell(msg.sender, _numberOfTokens, tokensSold);
    }
	
    function endSale() public onlyAdmin {
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))), "Transfer token-sale token balance to admin failed");
		
        // Just transfer the ether balance to the admin
        admin.transfer(address(this).balance);
    }
	
	/**
	 * Do not accept ETH donations
	 */
    function () external payable {
		revert();
    }
}