/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface MemoryInterface {
    function getUint(uint _id) external returns (uint _num);
    function setUint(uint _id, uint _val) external;
}

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

interface AaveV1Interface {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;
    function redeemUnderlying(
        address _reserve,
        address payable _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    ) external;
    
    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;
    function getUserReserveData(address _reserve, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentBorrowBalance,
        uint256 principalBorrowBalance,
        uint256 borrowRateMode,
        uint256 borrowRate,
        uint256 liquidityRate,
        uint256 originationFee,
        uint256 variableBorrowIndex,
        uint256 lastUpdateTimestamp,
        bool usageAsCollateralEnabled
    );
    function borrow(address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode) external;
    function repay(address _reserve, uint256 _amount, address payable _onBehalfOf) external payable;
}

interface AaveProviderInterface {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
}

interface AaveV1CoreInterface {
    function getReserveATokenAddress(address _reserve) external view returns (address);
}

interface ATokenInterface {
    function redeem(uint256 _amount) external;
    function balanceOf(address _user) external view returns(uint256);
    function principalBalanceOf(address _user) external view returns(uint256);

    function allowance(address, address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface AaveV2Interface {
    function deposit(address _asset, uint256 _amount, address _onBehalfOf, uint16 _referralCode) external;
    function withdraw(address _asset, uint256 _amount, address _to) external;
    function borrow(
        address _asset,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode,
        address _onBehalfOf
    ) external;
    function repay(address _asset, uint256 _amount, uint256 _rateMode, address _onBehalfOf) external;
    function setUserUseReserveAsCollateral(address _asset, bool _useAsCollateral) external;
    function getUserAccountData(address user) external view returns (
        uint256 totalCollateralETH,
        uint256 totalDebtETH,
        uint256 availableBorrowsETH,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    );
}

interface AaveV2LendingPoolProviderInterface {
    function getLendingPool() external view returns (address);
}

// Aave Protocol Data Provider
interface AaveV2DataProviderInterface {
    function getReserveTokensAddresses(address _asset) external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    );
    function getUserReserveData(address _asset, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentStableDebt,
        uint256 currentVariableDebt,
        uint256 principalStableDebt,
        uint256 scaledVariableDebt,
        uint256 stableBorrowRate,
        uint256 liquidityRate,
        uint40 stableRateLastUpdated,
        bool usageAsCollateralEnabled
    );
    function getReserveConfigurationData(address asset) external view returns (
        uint256 decimals,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        bool usageAsCollateralEnabled,
        bool borrowingEnabled,
        bool stableBorrowRateEnabled,
        bool isActive,
        bool isFrozen
    );
}

interface AaveV2AddressProviderRegistryInterface {
    function getAddressesProvidersList() external view returns (address[] memory);
}

interface ATokenV2Interface {
    function scaledBalanceOf(address _user) external view returns (uint256);
    function isTransferAllowed(address _user, uint256 _amount) external view returns (bool);
    function balanceOf(address _user) external view returns(uint256);
    function transferFrom(address, address, uint) external returns (bool);
}

interface DSAInterface {
    function isAuth(address) external view returns(bool);
}

contract DSMath {

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
    /**
     * @dev Return ethereum address
     */
    function getEthAddr() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    /**
     * @dev Return Weth address
    */
    function getWethAddr() internal pure returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet WETH Address
        // return 0xd0A1E359811322d97991E03f863a0C30C2cF029C; // Kovan WETH Address
    }

    /**
     * @dev Return Memory Variable Address
     */
    function getMemoryAddr() internal pure returns (address) {
        return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
    }

    /**
     * @dev Get Uint value from InstaMemory Contract.
    */
    function getUint(uint getId, uint val) internal returns (uint returnVal) {
        returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
    }

    /**
     * @dev Set Uint value in InstaMemory Contract.
    */
    function setUint(uint setId, uint val) internal {
        if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
    }

    /**
     * @dev Connector Details.
     */
    function connectorID() public pure returns(uint model, uint id) {
        (model, id) = (1, 64);
    }
}

contract AaveImportHelpers is Helpers {

    /**
     * @dev get Aave Provider
    */
    function getAaveProvider() internal pure returns (AaveProviderInterface) {
        return AaveProviderInterface(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8); //mainnet
        // return AaveProviderInterface(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5); //kovan
    }

    /**
     * @dev get Aave Lending Pool Provider
    */
    function getAaveV2Provider() internal pure returns (AaveV2LendingPoolProviderInterface) {
        return AaveV2LendingPoolProviderInterface(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); //mainnet
        // return AaveV2LendingPoolProviderInterface(0x652B2937Efd0B5beA1c8d54293FC1289672AFC6b); //kovan
    }

    /**
     * @dev get Aave Protocol Data Provider
    */
    function getAaveV2DataProvider() internal pure returns (AaveV2DataProviderInterface) {
        return AaveV2DataProviderInterface(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d); //mainnet
        // return AaveV2DataProviderInterface(0x744C1aaA95232EeF8A9994C4E0b3a89659D9AB79); //kovan
    }

    /**
     * @dev get Referral Code
    */
    function getReferralCode() internal pure returns (uint16) {
        return 3228;
    }

    /**
     * @dev get Referral Code V2
    */
    function getReferralCodeV2() internal pure returns (uint16) {
        return 3228;
    }

    function getBorrowRateMode(AaveV1Interface aave, address token) internal view returns (uint rateMode) {
        (, , , rateMode, , , , , , ) = aave.getUserReserveData(token, address(this));
    }

    function getWithdrawBalance(address token) internal view returns (uint bal) {
        AaveV1Interface aave = AaveV1Interface(getAaveProvider().getLendingPool());
        (bal, , , , , , , , , ) = aave.getUserReserveData(token, address(this));
    }

    function getPaybackBalance(AaveV1Interface aave, address account, address token) internal view returns (uint bal, uint fee) {
        (, bal, , , , , fee, , , ) = aave.getUserReserveData(token, account);
    }

    function getTotalBorrowBalance(AaveV1Interface aave, address account, address token) internal view returns (uint amt) {
        (, uint bal, , , , , uint fee, , , ) = aave.getUserReserveData(token, account);
        amt = add(bal, fee);
    }

    function getIsCollV2(AaveV2DataProviderInterface aaveData, address token, address user) internal view returns (bool isCol) {
        (, , , , , , , , isCol) = aaveData.getUserReserveData(token, user);
    }

    function convertEthToWeth(bool isEth, TokenInterface token, uint amount) internal {
        if(isEth) token.deposit.value(amount)();
    }

    function convertWethToEth(bool isEth, TokenInterface token, uint amount) internal {
       if(isEth) {
            token.approve(address(token), amount);
            token.withdraw(amount);
        }
    }
}

contract AaveV1Resolver is AaveImportHelpers {

    function _v1PaybackBehalf(
        uint _length,
        AaveV1Interface aaveV1,
        address[] memory tokens,
        uint[] memory amts,
        address userAccount
    ) internal {
        address ethAddr = getEthAddr();
        
        for (uint i = 0; i < _length; i++) {

            address token = tokens[i];
            uint256 amt = amts[i];

            if (amts[i] > 0) {
                uint ethAmt;
                if (token == ethAddr) {
                    ethAmt = amt;
                } else {
                    TokenInterface(token).approve(getAaveProvider().getLendingPoolCore(), amt);
                }

                aaveV1.repay.value(ethAmt)(token, amt, payable(userAccount));
            }
        }
    }

    
    function _v1Withdraw(
        uint _length,
        ATokenInterface[] memory atokenContracts,
        uint256[] memory amts
    ) internal {

        for (uint i = 0; i < _length; i++) {
            if (amts[i] > 0) {
                atokenContracts[i].redeem(amts[i]);
            }
        }
    }

    function _v1TransferATokens(
        uint _length,
        ATokenInterface[] memory atokenContracts,
        uint256[] memory amts,
        address userAccount
    ) internal {
        for (uint i = 0; i < _length; i++) {
            if (amts[i] > 0) {
                atokenContracts[i].transferFrom(userAccount, address(this), amts[i]);
            }
        }
    }
}

contract AaveV2Resolver is AaveV1Resolver {

    function _v2Deposit(
        uint _length,
        AaveV2Interface aaveV2,
        AaveV2DataProviderInterface aaveDataV2,
        address[] memory tokens,
        uint256[] memory amts
    ) internal {
        address ethAddr = getEthAddr();
        for (uint i = 0; i < _length; i++) {
            address token = tokens[i];
            uint256 amt = amts[i];

            if (amt > 0) {

                bool isEth = token ==ethAddr;
                address _token = isEth ? getWethAddr() : token;
                TokenInterface tokenContract = TokenInterface(_token);

                if (isEth) {
                    convertEthToWeth(isEth, tokenContract, amt);
                }

                tokenContract.approve(address(aaveV2), amt);
                aaveV2.deposit(_token, amt, address(this), getReferralCodeV2());

                if (!getIsCollV2(aaveDataV2, _token, address(this))) {
                    aaveV2.setUserUseReserveAsCollateral(_token, true);
                }
            }
        }
    }


    function _v2Borrow(
        uint _length,
        AaveV2Interface aaveV2,
        address[] memory tokens,
        uint256[] memory amts,
        uint256[] memory rateModes
    ) internal {
        address ethAddr = getEthAddr();
        for (uint i = 0; i < _length; i++) {
            address token = tokens[i];
            uint256 amt = amts[i];
            uint256 rateMode = rateModes[i];

            if (amt > 0) {
                bool isEth = token == ethAddr;
                address _token = isEth ? getWethAddr() : token;

                aaveV2.borrow(_token, amt, rateMode, getReferralCode(), address(this));
                convertWethToEth(isEth, TokenInterface(_token), amt);
            }
        }
    }
}

contract AaveMigrateResolver is AaveV2Resolver {
    event LogMigrate(
        address[] aTokens,
        uint[] aTknBals,
        uint[] borrowBals,
        uint[] borrowBalsFee
    );

    event LogMigrateUser(
        address user,
        address[] aTokens,
        uint[] aTknBals,
        uint[] borrowBals,
        uint[] borrowBalsFee
    );

    struct AaveData {
        address[] tokens;
        address[] atokens;
        uint[] borrowAmts;
        uint[] borrowFeeAmts;
        uint[] atokensBal;
        uint[] rateModes;
        ATokenInterface[] atokenContracts;
    }


    function migrate(address[] calldata tokens) external payable {
        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV1CoreInterface aaveCoreV1 = AaveV1CoreInterface(getAaveProvider().getLendingPoolCore());

        AaveV2Interface aaveV2 = AaveV2Interface(getAaveV2Provider().getLendingPool());
        AaveV2DataProviderInterface aaveV2Data = getAaveV2DataProvider();

        address userAccount = address(this);

        uint _length = tokens.length;
        require(_length > 0, "length-should-be-positive");

        AaveData memory _aaveData = AaveData({
            tokens: tokens,
            atokens: new address[](_length),
            borrowAmts: new uint[](_length),
            borrowFeeAmts: new uint[](_length),
            atokensBal: new uint[](_length),
            rateModes: new uint[](_length),
            atokenContracts: new ATokenInterface[](_length)
        });

        for (uint i = 0; i < _length; i++) {
            _aaveData.atokens[i] = aaveCoreV1.getReserveATokenAddress(tokens[i]);
            require(_aaveData.atokens[i] != address(0), "token-not-found");
            _aaveData.atokenContracts[i] = ATokenInterface(_aaveData.atokens[i]);
            _aaveData.atokensBal[i] = _aaveData.atokenContracts[i].balanceOf(userAccount);
            (uint amt, uint fee) = getPaybackBalance(aaveV1, userAccount, tokens[i]);
            _aaveData.borrowAmts[i] = add(amt, fee);
            _aaveData.borrowFeeAmts[i] = fee;

            // _aaveData.rateModes[i] = getBorrowRateMode(aaveV1, tokens[i]);
            _aaveData.rateModes[i] = 2;
        }

        _v2Borrow(_length, aaveV2, _aaveData.tokens, _aaveData.borrowAmts, _aaveData.rateModes);
        _v1PaybackBehalf(_length, aaveV1, _aaveData.tokens, _aaveData.borrowAmts, userAccount);
        _v1Withdraw(_length, _aaveData.atokenContracts, _aaveData.atokensBal);
        _v2Deposit(_length, aaveV2, aaveV2Data, _aaveData.tokens, _aaveData.atokensBal);

        emit LogMigrate(_aaveData.atokens, _aaveData.atokensBal, _aaveData.borrowAmts, _aaveData.borrowFeeAmts);
    }

    function migrateUser(address userAccount, address[] calldata tokens) external payable {
        require(DSAInterface(address(this)).isAuth(userAccount), "user-account-not-auth");

        uint _length = tokens.length;
        require(_length > 0, "0-tokens-not-allowed");

        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV1CoreInterface aaveCoreV1 = AaveV1CoreInterface(getAaveProvider().getLendingPoolCore());

        AaveV2Interface aaveV2 = AaveV2Interface(getAaveV2Provider().getLendingPool());
        AaveV2DataProviderInterface aaveV2Data = getAaveV2DataProvider();

        AaveData memory _aaveData = AaveData({
            tokens: tokens,
            atokens: new address[](_length),
            borrowAmts: new uint[](_length),
            borrowFeeAmts: new uint[](_length),
            atokensBal: new uint[](_length),
            rateModes: new uint[](_length),
            atokenContracts: new ATokenInterface[](_length)
        });

        for (uint i = 0; i < _length; i++) {
            _aaveData.atokens[i] = aaveCoreV1.getReserveATokenAddress(tokens[i]);
            require(_aaveData.atokens[i] != address(0), "token-not-found");
            _aaveData.atokenContracts[i] = ATokenInterface(_aaveData.atokens[i]);
            _aaveData.atokensBal[i] = _aaveData.atokenContracts[i].balanceOf(userAccount);
            (uint amt, uint fee) = getPaybackBalance(aaveV1, userAccount, tokens[i]);
            _aaveData.borrowAmts[i] = add(amt, fee);
            _aaveData.borrowFeeAmts[i] = fee;

            // _aaveData.rateModes[i] = getBorrowRateMode(aaveV1, tokens[i]);
            _aaveData.rateModes[i] = 2;
        }

        _v2Borrow(_length, aaveV2, _aaveData.tokens, _aaveData.borrowAmts, _aaveData.rateModes);
        _v1PaybackBehalf(_length, aaveV1, _aaveData.tokens, _aaveData.borrowAmts, userAccount);
        _v1TransferATokens(_length, _aaveData.atokenContracts, _aaveData.atokensBal, userAccount);
        _v1Withdraw(_length, _aaveData.atokenContracts, _aaveData.atokensBal);
        _v2Deposit(_length, aaveV2, aaveV2Data, _aaveData.tokens, _aaveData.atokensBal);

        emit LogMigrateUser(userAccount, _aaveData.atokens, _aaveData.atokensBal, _aaveData.borrowAmts, _aaveData.borrowFeeAmts);
    }
}

contract ConnectAaveMigrator is AaveMigrateResolver {
    string public name = "Aave-Migrator-v1.0";
}