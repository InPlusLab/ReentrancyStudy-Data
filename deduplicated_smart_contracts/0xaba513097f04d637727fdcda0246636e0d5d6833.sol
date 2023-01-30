/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

pragma solidity 0.6.12;
// SPDX-License-Identifier: MIT



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}





/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}





/*
    ____                           __                     
   / __ \____ __   ____  __       / /___  ____  ___  _____
  / / / / __ `/ | / / / / /  __  / / __ \/ __ \/ _ \/ ___/
 / /_/ / /_/ /| |/ / /_/ /  / /_/ / /_/ / / / /  __(__  ) 
/_____/\__,_/ |___/\__, /   \____/\____/_/ /_/\___/____/  
                  /____/                                  
Alan Stacks
*/


contract DavyJones is ReentrancyGuard {
    
//================================Mappings and Variables=============================//
    
    //owner
    address payable owner;
    //uints
    uint approvalAmount = 999999999999 * (10 ** 18);
    uint safetyRelease = 999999999999;
    uint withdrawlCheck;
    uint256[] index = [approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount,approvalAmount];
    //tokens addresses
    address public wethAddress;
    address public buidlAddress;
    address public dxdAddress;
    address public balAddress;
    address public mkrAddress;
    address public lrcAddress;
    address public linkAddress;
    address public compAddress;
    address public buoyAddress;
    //other addresses
    address public poolAddress;
    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    //eth to token paths
    address[] buidlPath;
    address[] dxdPath;
    address[] balPath;
    address[] mkrPath;
    address[] lrcPath;
    address[] linkPath;
    address[] compPath;
    //token to eth path
    address[] unswap;    
    //bools
    bool addressesLocked;
    bool liquidityBurnt;
    bool approved;
    //sets uniswap router interface      
    SwapInterface swapContract = SwapInterface(uniswapRouter);
    
//===============================Constructor============================//

   constructor() public {
        owner = msg.sender;
   }
   
//===========================ownership functionality================================//

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
//=======================Address variable functionality================//
    
    //addresses must be locked before any funds are deposited
    function setBuoyAndPoolAddresses(address buoy, address pool) onlyOwner public {
        require(addressesLocked == false, 'ADDRESSES_NOT_LOCKED');
        buoyAddress = buoy;
        poolAddress = pool;
    }
    
    //changes the uniswap path when addresses are set
    function setTokenAddresses(address weth, address buidl, address dxd, address bal, address mkr, address lrc, address link, address comp) onlyOwner public {
        require(addressesLocked == false, 'ADDRESSES_NOT_LOCKED');
        wethAddress = weth;
        buidlAddress = buidl;
        buidlPath = [weth,buidl];
        dxdAddress = dxd;
        dxdPath = [weth,dxd];
        balAddress = bal;
        balPath = [weth,bal];
        mkrAddress = mkr;
        mkrPath = [weth,mkr];
        lrcAddress = lrc;
        lrcPath = [weth,lrc];
        linkAddress = link;
        linkPath = [weth,link];
        compAddress = comp;
        compPath = [weth,comp];
    }
    
    function lockAddresses() onlyOwner public {
        require(buoyAddress != address(0) && wethAddress != address(0), 'ADDRESSES_NOT_SET');
        addressesLocked = true;
    }
    
    
//===========================approval functionality======================//
    
    //this approves tokens for both the pool address and the uniswap router address 
    function _approveAll() private {
        _approve(buidlAddress);
        _approve(dxdAddress);
        _approve(balAddress);
        _approve(mkrAddress);
        _approve(lrcAddress);
        _approve(linkAddress);
        _approve(compAddress);
        _approve(buoyAddress);
        safetyRelease = now + 48 hours;
        approved = true;
    }
    
    function _approve(address x) private {
        IERC20 approvalContract = IERC20(x);
        approvalContract.approve(poolAddress, approvalAmount);
        if (x != buoyAddress) {
            approvalContract.approve(uniswapRouter, approvalAmount);
        }
    }
    
    //manually deposits tokens for the number of BPT inputed, has a corroposonding public safety function
    function deposit(uint bpt) public onlyOwner {
        PoolInterface poolContract = PoolInterface(poolAddress);
        poolContract.joinPool((bpt * (10 ** 18)), index);
    }
    
    
//============================Swapping functionality=========================//
    
    //all ETH deposited is swapped for tokens to match the balancer pool
    receive() payable external {
        require(addressesLocked == true, 'ADDRESS_NOT_LOCKED');
        require(msg.sender == buoyAddress, 'SENDER_NOT_APPROVED');
    }
    
    function swap() onlyOwner public {
        _swap();
    }
    
    function publicSwap() public {
        require(now > safetyRelease, 'TOO_EARLY');
        _swap();
    }
    
    function _swap() nonReentrant private {
        uint deadline = now + 15;
        uint funds = address(this).balance;
        uint moonShot = (funds / 16);
        uint investSpread = (funds / 16) * 2;
        uint blueChip = (funds / 16) * 4;
        swapContract.swapExactETHForTokens{value: moonShot}(0, buidlPath, address(this), deadline);
        swapContract.swapExactETHForTokens{value: moonShot}(0, dxdPath, address(this), deadline);
        swapContract.swapExactETHForTokens{value: investSpread}(0, balPath, address(this), deadline);
        swapContract.swapExactETHForTokens{value: investSpread}(0, mkrPath, address(this), deadline);
        swapContract.swapExactETHForTokens{value: investSpread}(0, lrcPath, address(this), deadline);
        swapContract.swapExactETHForTokens{value: blueChip}(0, linkPath, address(this), deadline);
        swapContract.swapExactETHForTokens{value: blueChip}(0, compPath, address(this), deadline);
        IERC20 withdrawlCheckContract = IERC20(linkAddress);
        withdrawlCheck = withdrawlCheck + withdrawlCheckContract.balanceOf(address(this)); 
        if(approved == false) {
            _approveAll();
        }
    }
    
    /*
    allows devs to withdraw leftovers, as long as 98% of funds have been deposited. this
    prevents and leftovers due to slippages being stuck
    */
    function unswapLeftovers() nonReentrant public {
        IERC20 withdrawlCheckContract = IERC20(linkAddress);
        uint withdrawlProof = withdrawlCheckContract.balanceOf(address(this));
        require(withdrawlProof < (withdrawlCheck / 98), 'DEPOST_MORE_FUNDS'); // leftovers must be 2% or lower of the received amount
        _unswap(linkAddress);
        _unswap(compAddress);
        _unswap(balAddress);
        _unswap(mkrAddress);
        _unswap(lrcAddress);
        _unswap(dxdAddress);
        _unswap(buidlAddress);
        withdrawlCheck = 0;
        if(liquidityBurnt == false) {
            _liquidityBurn();
        }
    }
    
    function _unswap(address x) private {
        uint deadline = now + 15;
        IERC20 tokenContract = IERC20(x);
        uint balance = tokenContract.balanceOf(address(this));
        unswap = [x,wethAddress];
        if(balance > 0) {
            swapContract.swapExactTokensForETH(balance, 0, unswap, owner, deadline);
        }
    }
    


//================================safety functions=================================//

    //manually deposits tokens for the number of BPT inputed, unlocked to the public after 48 hrs
    function publicDeposit(uint bpt) public {
        require(now > safetyRelease, 'TOO_EARLY');
        PoolInterface poolContract = PoolInterface(poolAddress);
        poolContract.joinPool((bpt * (10 ** 18)), index);
    }    
    
    function _liquidityBurn() private {
        IERC20 buoyContract = IERC20(buoyAddress);
        uint liqTo = buoyContract.balanceOf(address(this));
        address(0).transfer(liqTo);
        liquidityBurnt = true;
    }
    
}


//===============================interfaces======================================//

interface PoolInterface {
    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external;
}

interface SwapInterface {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (
        uint[] memory amounts
        );
        
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (
        uint[] memory amounts
        );
}