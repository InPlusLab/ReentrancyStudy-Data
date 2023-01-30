/**
 *Submitted for verification at Etherscan.io on 2019-10-15
*/

pragma solidity ^0.5.7;

interface CTokenInterface {
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint); // For ERC20
    function borrowBalanceCurrent(address account) external returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function balanceOf(address owner) external view returns (uint256 balance);
    function transferFrom(address, address, uint) external returns (bool);
    function underlying() external view returns (address);
}

interface CETHInterface {
    function repayBorrowBehalf(address borrower) external payable; // For ETH
}

interface ERC20Interface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface ComptrollerInterface {
    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function getAssetsIn(address account) external view returns (address[] memory);
}

interface PoolInterface {
    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;
    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;
}


contract DSMath {

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y <= x ? x - y : 0;
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract Helpers is DSMath {

    // address public comptrollerAddr = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    // address payable public liquidityAddr;
    
     function getCETHAddress() public pure returns (address cEthAddr) {
        cEthAddr = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5; // main
        //  troller = 0x142D11CB90a2b40f7d0C55ed1804988DfC316fAe;
    }
    // address public cEthAddr = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5; // main
    // address public cEthAddr = 0xD83F707f003A1f0B1535028AB356FCE2667ab855; // kovan
    // address public cUsdc = 0xDff375162cfE7D77473C1BEC4560dEDE974E138c;  // kovan
        /**
     * @dev get Compound Comptroller Address
     */
    function getComptrollerAddress() public pure returns (address troller) {
        troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B; // main
        //  troller = 0x142D11CB90a2b40f7d0C55ed1804988DfC316fAe;
    }
    
    function getPoolAddress() public pure returns (address payable liqAddr){
        liqAddr = 0x25b78ade6B3Ac3aC3556cDd737992EBb9cFa12dA; // main
        // liqAddr = 0x42688864aBceeF758E500571FB9df85EcD18b27b;
    }

    /**
     * @dev check if the user has entered the market and enter if not
     */
    function enterMarket(address[] memory cErc20) internal {
        ComptrollerInterface troller = ComptrollerInterface(getComptrollerAddress());
        address[] memory markets = troller.getAssetsIn(address(this));
        address[] memory toEnter = new address[](7);
        uint count = 0;
        for (uint j = 0; j < cErc20.length; j++) {
            bool isEntered = false;
            for (uint i = 0; i < markets.length; i++) {
                if (markets[i] == cErc20[j]) {
                    isEntered = true;
                    break;
                }
            }
            if (!isEntered) {
                toEnter[count] = cErc20[j];
                count += 1;
            }
        }
        troller.enterMarkets(toEnter);
    }

    /**
     * @dev get markets address owner has entered
     */
    function enteredMarkets(address owner) internal view returns (address[] memory) {
        address[] memory markets = ComptrollerInterface(getComptrollerAddress()).getAssetsIn(owner);
        return markets;
    }

    /**
     * @dev setting allowance for the "user proxy" if required
     */
    function setApproval(address erc20, uint srcAmt, address to) internal {
        ERC20Interface erc20Contract = ERC20Interface(erc20);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, uint(-1));
        }
    }

}


contract ImportResolver is Helpers {
    event LogCompoundImport(address owner, uint percentage, bool isCompound, address[] markets, address[] borrowAddr, uint[] borrowAmt);

    function importAssets(uint toConvert, bool isCompound, uint borrowLenght) external {
        uint initialBal = sub(getPoolAddress().balance, 10000000000); // subtracting 0.00000001 ETH from initial balance.
        address[] memory markets = enteredMarkets(msg.sender);
        address[] memory borrowAddr = new address[](borrowLenght);
        uint[] memory borrowAmt = new uint[](borrowLenght);
        uint borrowCount = 0;
        // create an array of borrowed address and amount
        for (uint i = 0; i < markets.length; i++) {
            address cErc20 = markets[i];
            uint toPayback = CTokenInterface(cErc20).borrowBalanceCurrent(msg.sender);
            toPayback = wmul(toPayback, toConvert);
            if (toPayback > 0) {
                borrowAddr[borrowCount] = cErc20;
                borrowAmt[borrowCount] = toPayback;
                borrowCount += 1;
            }
        }
        
        assert(borrowCount == borrowLenght);
        // Get liquidity assets to payback user wallet borrowed assets
        PoolInterface(getPoolAddress()).accessToken(borrowAddr, borrowAmt, isCompound);

        // // payback user wallet borrowed assets
        for (uint i = 0; i < borrowAddr.length; i++) {
            address cErc20 = borrowAddr[i];
            uint toPayback = borrowAmt[i];
            if (cErc20 == getCETHAddress()) {
                CETHInterface(cErc20).repayBorrowBehalf.value(toPayback)(msg.sender);
            } else {
                CTokenInterface ctknContract = CTokenInterface(cErc20);
                address erc20 = ctknContract.underlying();
                setApproval(erc20, toPayback, cErc20);
                require(ctknContract.repayBorrowBehalf(msg.sender, toPayback) == 0, "transfer approved?");
            }
        }

        // transfer minted ctokens to InstaDApp smart wallet from user wallet
        for (uint i = 0; i < markets.length; i++) {
            address cErc20 = markets[i];
            CTokenInterface ctknContract = CTokenInterface(cErc20);
            uint supplyAmt = ctknContract.balanceOf(msg.sender);
            supplyAmt = wmul(supplyAmt, toConvert);
            if (supplyAmt > 0) {
                require(ctknContract.transferFrom(msg.sender, address(this), supplyAmt), "Allowance?");
            }
        }

        // // borrow and transfer assets to payback liquidity
        enterMarket(markets);
        for (uint i = 0; i < borrowAddr.length; i++) {
            address cErc20 = borrowAddr[i];
            uint toBorrow = borrowAmt[i];
            CTokenInterface ctknContract = CTokenInterface(cErc20);
            require(ctknContract.borrow(toBorrow) == 0, "got collateral?");
            if (cErc20 == getCETHAddress()) {
                getPoolAddress().transfer(toBorrow);
            } else {
                address erc20 = ctknContract.underlying();
                require(ERC20Interface(erc20).transfer(getPoolAddress(), toBorrow), "Not-enough-amt");
            }
        }

        //payback InstaDApp liquidity
        PoolInterface(getPoolAddress()).paybackToken(borrowAddr, isCompound);
        assert(getPoolAddress().balance >= initialBal);

        emit LogCompoundImport(
            msg.sender,
            toConvert,
            isCompound,
            markets,
            borrowAddr,
            borrowAmt
        );
    }

}


contract CompImport is ImportResolver {
    function() external payable {}
}