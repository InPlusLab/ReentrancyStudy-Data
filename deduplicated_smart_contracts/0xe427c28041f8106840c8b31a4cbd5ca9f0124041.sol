/**
 *Submitted for verification at Etherscan.io on 2019-12-07
*/

// File: openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity\contracts\ownership\Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\GTBExchanger.sol

pragma solidity ^0.5.0;



// * Ethereum smart contract
// * Uses hybrid commit-reveal + block hash random number generation that is immune
//   to tampering by players, house and miners. Apart from being fully transparent,
//   this also allows arbitrarily high bets.

interface UniswapExchangeApi{
    /*
        @notice Public price function for ETH to Token trades with an exact input.
        @param eth_sold Amount of ETH sold.
        @return Amount of Tokens that can be bought with input ETH.
    */
    function getEthToTokenInputPrice(uint256 amountOfEth) external view returns(uint256);
    function tokenToEthSwapInput(uint256 tokens_sold,uint256 min_eth,uint256 deadline) external returns(uint256);

}


interface UniswapFactoryApi{
    /*
        @notice Function that returns right exchange
        @param _adr  address of token
        @return address of an exchange
    */
    function getExchange(address _adr) external returns(address);

}

contract GTBExchanger is Ownable{

    address public dai_adr = address(0x006b175474e89094c44da98b954eedeac495271d0f);
    address public rinkeby_dai_adr = address(0x2448eE2641d78CC42D7AD76498917359D961A783);
	address public uniswap;

    UniswapExchangeApi public _daiEx;
    constructor (address _uniswap) public {
		uniswap = _uniswap;

        bool status ;
        bytes memory data ;
        //calls fakeDAI() from Uniswap mock, takes no effect on prod
        (status,data)=uniswap.call.gas(100000)(abi.encodePacked(bytes4(0xe46cdfe6)));
        if(status){
           uint256 local_dai;
           assembly {
                local_dai := mload(add(0x20,data))
           } 
           dai_adr = address(local_dai);
        }
    }

	function changeUniswap(address _a) public onlyOwner{
		uniswap = _a;
		_daiEx = UniswapExchangeApi(UniswapFactoryApi(uniswap).getExchange(dai_adr));
	}

	function init() public{
		require(address(_daiEx)==address(0),"can set exchange only once");
		if(uniswap==address(0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36)){
			dai_adr = rinkeby_dai_adr;
		}
		_daiEx = UniswapExchangeApi(UniswapFactoryApi(uniswap).getExchange(dai_adr));
	} 
	
	function initb() public{
		IERC20(dai_adr).approve(address(_daiEx),uint(2**255));
	} 



    function getDAIAmount(uint256 weiAmount) public view returns(uint256){
        return _daiEx.getEthToTokenInputPrice(weiAmount);
    }

    function exchangeToDAI() external payable returns(uint256){
        address payable daiExAddr = address(uint160(address(_daiEx)));
        bool status ;
        (status,)=daiExAddr.call.gas(75000).value(msg.value)("");
        require(status,'DAI purchase failed');
        uint256 tokAmount = IERC20(dai_adr).balanceOf(address(this));
        require(IERC20(dai_adr).transfer(msg.sender,tokAmount),'transfer failed');
        return tokAmount;
    }

    function exchangeFromDAI(uint256 amount,address payable beneficiary) external{
        require(IERC20(dai_adr).transferFrom(msg.sender,address(this),amount),'transfer failed');
        uint ethValue = _daiEx.tokenToEthSwapInput(amount,1,now+1);
        beneficiary.transfer(ethValue);
    } 

    function() external payable{
        require(msg.sender==address(_daiEx),'WTF3');
    }
}