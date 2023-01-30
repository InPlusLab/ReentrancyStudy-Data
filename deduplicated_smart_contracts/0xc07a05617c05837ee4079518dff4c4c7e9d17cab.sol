/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity ^0.5.16;

// **INTERFACES**

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

interface ICEther {
    function mint() external payable;
    function repayBorrow() external payable;
}

interface ICToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address borrower) external payable;

    function liquidateBorrow(address borrower, uint256 repayAmount, address cTokenCollateral)
        external
        returns (uint256);

    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function borrowRatePerBlock() external returns (uint256);

    function totalReserves() external returns (uint256);

    function reserveFactorMantissa() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account) external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function getCash() external returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function underlying() external returns (address);
}

interface IComptroller {
    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

    function getAssetsIn(address account) external view returns (address[] memory);

    function getAccountLiquidity(address account) external view returns (uint256, uint256, uint256);

    function markets(address cTokenAddress) external view returns (bool, uint);
}

// DfWallet - logic of user's wallet for cTokens
contract DfWallet {

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    // address public constant DF_FINANCE_OPEN = address(0xBA3EEeb0cf1584eE565F34fCaBa74d3e73268c0b);  // TODO: DfFinanceCompound address
    address public constant DF_FINANCE_OPEN = address(0x7eF7eBf6c5DA51A95109f31063B74ECf269b22bE);  // TODO: DfFinanceCompound address

    address public dfFinanceClose;

    // **MODIFIERS**

    modifier authUpgrade {
        require(dfFinanceClose == address(0) || msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    modifier authDeposit {
        require(msg.sender == DF_FINANCE_OPEN || msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    modifier authWithdraw {
        require(msg.sender == dfFinanceClose, "Permission denied");
        _;
    }

    // **PUBLIC SET function**

    function setDfFinanceClose(address _dfFinanceClose) public authUpgrade {
        require(_dfFinanceClose != address(0), "Address dfFinanceClose must not be zero");
        dfFinanceClose = _dfFinanceClose;
    }

    // **PUBLIC PAYABLE functions**

    // Example: _collToken = Eth, _borrowToken = USDC
    function deposit(
        address _collToken, address _cCollToken, uint _collAmount, address _borrowToken, address _cBorrowToken, uint _borrowAmount
    ) public payable authDeposit {
        // add _cCollToken to market
        enterMarketInternal(_cCollToken);

        // mint _cCollToken
        mintInternal(_collToken, _cCollToken, _collAmount);

        // borrow and withdraw _borrowToken
        if (_borrowToken != address(0)) {
            borrowInternal(_borrowToken, _cBorrowToken, _borrowAmount);
        }
    }

    // Example: _collToken = Eth, _borrowToken = USDC
    function withdraw(
        address _collToken, address _cCollToken, address _borrowToken, address _cBorrowToken
    ) public payable authWithdraw {
        // repayBorrow _cBorrowToken
        paybackInternal(_borrowToken, _cBorrowToken);

        // redeem _cCollToken
        redeemInternal(_collToken, _cCollToken);
    }

    // **INTERNAL functions**

    function approveCTokenInternal(address _tokenAddr, address _cTokenAddr) internal {
        if (_tokenAddr != ETH_ADDRESS) {
            if (IERC20(_tokenAddr).allowance(address(this), address(_cTokenAddr)) != uint256(-1)) {
                IERC20(_tokenAddr).approve(_cTokenAddr, uint(-1));
            }
        }
    }

    function enterMarketInternal(address _cTokenAddr) internal {
        address[] memory markets = new address[](1);
        markets[0] = _cTokenAddr;

        IComptroller(COMPTROLLER).enterMarkets(markets);
    }

    function mintInternal(address _tokenAddr, address _cTokenAddr, uint _amount) internal {
        // approve _cTokenAddr to pull the _tokenAddr tokens
        approveCTokenInternal(_tokenAddr, _cTokenAddr);

        if (_tokenAddr != ETH_ADDRESS) {
            require(ICToken(_cTokenAddr).mint(_amount) == 0);
        } else {
            ICEther(_cTokenAddr).mint.value(msg.value)(); // reverts on fail
        }
    }

    function borrowInternal(address _tokenAddr, address _cTokenAddr, uint _amount) internal {
        require(ICToken(_cTokenAddr).borrow(_amount) == 0);

        // withdraw funds to msg.sender (DfFinance contract)
        if (_tokenAddr != ETH_ADDRESS) {
            IERC20(_tokenAddr).transfer(msg.sender, IERC20(_tokenAddr).balanceOf(address(this)));
        } else {
            transferEthInternal(msg.sender, address(this).balance);
        }
    }

    function paybackInternal(address _tokenAddr, address _cTokenAddr) internal {
        // approve _cTokenAddr to pull the _tokenAddr tokens
        approveCTokenInternal(_tokenAddr, _cTokenAddr);

        if (_tokenAddr != ETH_ADDRESS) {
            uint amount = ICToken(_cTokenAddr).borrowBalanceCurrent(address(this));

            IERC20(_tokenAddr).transferFrom(msg.sender, address(this), amount);
            require(ICToken(_cTokenAddr).repayBorrow(amount) == 0);
        } else {
            ICEther(_cTokenAddr).repayBorrow.value(msg.value)();
            if (address(this).balance > 0) {
                transferEthInternal(msg.sender, address(this).balance);  // send back the extra eth
            }
        }
    }

    function redeemInternal(address _tokenAddr, address _cTokenAddr) internal {
        // converts all _cTokenAddr into the underlying asset (_tokenAddr)
        require(ICToken(_cTokenAddr).redeem(IERC20(_cTokenAddr).balanceOf(address(this))) == 0);

        // withdraw funds to msg.sender
        if (_tokenAddr != ETH_ADDRESS) {
            IERC20(_tokenAddr).transfer(msg.sender, IERC20(_tokenAddr).balanceOf(address(this)));
        } else {
            transferEthInternal(msg.sender, address(this).balance);
        }
    }

    function transferEthInternal(address _receiver, uint _amount) internal {
        address payable receiverPayable = address(uint160(_receiver));
        (bool result, ) = receiverPayable.call.value(_amount)("");
        require(result, "Transfer of ETH failed");
    }

    // **FALLBACK functions**
    function() external payable {}

}