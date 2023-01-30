/**

 *Submitted for verification at Etherscan.io on 2019-06-07

*/



pragma solidity ^0.5.0;



contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);

    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);

    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);

    }



    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;

    }

    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;

    }

    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;

    }

    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;

    }



    uint constant WAD = 10 ** 18;

    uint constant RAY = 10 ** 27;



    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;

    }

    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;

    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;

    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;

    }



    // This famous algorithm is called "exponentiation by squaring"

    // and calculates x^n with x as fixed-point and n as regular unsigned.

    //

    // It's O(log n), instead of O(n) for naive repeated multiplication.

    //

    // These facts are why it works:

    //

    //  If n is even, then x^n = (x^2)^(n/2).

    //  If n is odd,  then x^n = x * x^(n-1),

    //   and applying the equation for even x gives

    //    x^n = x * (x^2)^((n-1) / 2).

    //

    //  Also, EVM division is flooring and

    //    floor[(n-1) / 2] = floor[n / 2].

    //

    function rpow(uint x, uint n) internal pure returns (uint z) {

        z = n % 2 != 0 ? x : RAY;



        for (n /= 2; n != 0; n /= 2) {

            x = rmul(x, x);



            if (n % 2 != 0) {

                z = rmul(z, x);

            }

        }

    }

}



interface ERC20 {

    function totalSupply() external view returns (uint supply);

    function balanceOf(address _owner) external view returns (uint balance);

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint _value) external returns (bool success);

    function approve(address _spender, uint _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint remaining);

    function decimals() external view returns(uint digits);

    function allocateTo(address recipient, uint256 value) external;

    event Approval(address indexed _owner, address indexed _spender, uint _value);

}



contract CTokenInterface is ERC20 {

    function mint(uint mintAmount) external returns (uint);

    function mint() external payable;

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

    function repayBorrow(uint repayAmount) external returns (uint);

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    function repayBorrowBehalf(address borrower) external payable;

    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint);

    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;



    function exchangeRateCurrent() external returns (uint);

    function supplyRatePerBlock() external returns (uint);

    function borrowRatePerBlock() external returns (uint);

    function totalReserves() external returns (uint);

    function reserveFactorMantissa() external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);

    function totalBorrowsCurrent() external returns (uint);

    function getCash() external returns (uint);

    function balanceOfUnderlying(address owner) external returns (uint);

}



contract TokenInterface {

    function allowance(address, address) public returns (uint);

    function balanceOf(address) public returns (uint);

    function approve(address, uint) public;

    function transfer(address, uint) public returns (bool);

    function transferFrom(address, address, uint) public returns (bool);

    function deposit() public payable;

    function withdraw(uint) public;

}



contract PipInterface {

    function read() public returns (bytes32);

}



contract PepInterface {

    function peek() public returns (bytes32, bool);

}



contract VoxInterface {

    function par() public returns (uint);

}



contract TubInterface {

    event LogNewCup(address indexed lad, bytes32 cup);



    function open() public returns (bytes32);

    function join(uint) public;

    function exit(uint) public;

    function lock(bytes32, uint) public;

    function free(bytes32, uint) public;

    function draw(bytes32, uint) public;

    function wipe(bytes32, uint) public;

    function give(bytes32, address) public;

    function shut(bytes32) public;

    function bite(bytes32) public;

    function cups(bytes32) public returns (address, uint, uint, uint);

    function gem() public returns (TokenInterface);

    function gov() public returns (TokenInterface);

    function skr() public returns (TokenInterface);

    function sai() public returns (TokenInterface);

    function vox() public returns (VoxInterface);

    function ask(uint) public returns (uint);

    function mat() public returns (uint);

    function chi() public returns (uint);

    function ink(bytes32) public returns (uint);

    function tab(bytes32) public returns (uint);

    function rap(bytes32) public returns (uint);

    function per() public returns (uint);

    function pip() public returns (PipInterface);

    function pep() public returns (PepInterface);

    function tag() public returns (uint);

    function drip() public;

    function lad(bytes32 cup) public view returns (address);

}



contract KyberNetworkProxyInterface {

    function maxGasPrice() external view returns(uint);

    function getUserCapInWei(address user) external view returns(uint);

    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);

    function enabled() external view returns(bool);

    function info(bytes32 id) external view returns(uint);



    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public

        returns (uint expectedRate, uint slippageRate);



    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,

        uint minConversionRate, address walletId, bytes memory hint) public payable returns(uint);



    function trade(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,

        uint minConversionRate, address walletId) public payable returns(uint);



    function swapEtherToToken(ERC20 token, uint minConversionRate) external payable returns(uint);

    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external payable returns(uint);

    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) public returns(uint);

}



contract ActionLogger {

    event Log(string indexed _type, address indexed owner, uint _first, uint _second);



    function logEvent(string memory _type, address _owner, uint _first, uint _second) public {

        emit Log(_type, _owner, _first, _second);

    }

}





contract CarefulMath {

    enum MathError {

        NO_ERROR,

        DIVISION_BY_ZERO,

        INTEGER_OVERFLOW,

        INTEGER_UNDERFLOW

    }



    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (a == 0) {

            return (MathError.NO_ERROR, 0);

        }



        uint c = a * b;



        if (c / a != b) {

            return (MathError.INTEGER_OVERFLOW, 0);

        } else {

            return (MathError.NO_ERROR, c);

        }

    }



    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b == 0) {

            return (MathError.DIVISION_BY_ZERO, 0);

        }



        return (MathError.NO_ERROR, a / b);

    }

}



contract Exponential is CarefulMath {

    uint constant expScale = 1e18;

    uint constant halfExpScale = expScale/2;

    uint constant mantissaOne = expScale;



    struct Exp {

        uint mantissa;

    }



    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint numerator) = mulUInt(expScale, scalar);

        if (err0 != MathError.NO_ERROR) {

            return (err0, Exp({mantissa: 0}));

        }

        return getExp(numerator, divisor.mantissa);

    }



    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {

        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);

        if (err != MathError.NO_ERROR) {

            return (err, 0);

        }



        return (MathError.NO_ERROR, truncate(fraction));

    }



    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);

        if (err0 != MathError.NO_ERROR) {

            return (err0, Exp({mantissa: 0}));

        }



        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);

        if (err1 != MathError.NO_ERROR) {

            return (err1, Exp({mantissa: 0}));

        }



        return (MathError.NO_ERROR, Exp({mantissa: rational}));

    }



    function truncate(Exp memory exp) pure internal returns (uint) {

        // Note: We are not using careful math here as we're performing a division that cannot fail

        return exp.mantissa / expScale;

    }

}



/// @title CompoundProxy implements CDP and Compound direct interactions

contract CompoundProxy is DSMath, Exponential {

    

    // Kovan addresses

    // address public constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;

    // address public constant WETH_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;

    // address public constant DAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;

    // address public constant MKR_ADDRESS = 0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD;

    // address public constant PETH_ADDRESS = 0xf4d791139cE033Ad35DB2B2201435fAd668B1b64;

    // address public constant KYBER_WRAPPER = 0x82CD6436c58A65E2D4263259EcA5843d3d7e0e65;

    // address public constant ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // address public constant CDAI_ADDRESS = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;

    // address public constant LOGGER_ADDRESS = 0x70b742b84a75aFF6482953f7883Fd7E70d3dBbac;

    // address public constant WALLET_ID = 0x54b44C6B18fc0b4A1010B21d524c338D1f8065F6;

    // address constant KYBER_INTERFACE = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;

    // address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;

    // address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;

    

    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

    address public constant MKR_ADDRESS = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;

    address public constant VOX_ADDRESS = 0x9B0F70Df76165442ca6092939132bBAEA77f2d7A;

    address public constant PETH_ADDRESS = 0xf53AD2c6851052A81B42133467480961B2321C09;

    address public constant TUB_ADDRESS = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;

    address public constant ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public constant KYBER_WRAPPER = 0xAae7ba823679889b12f71D1f18BEeCBc69E62237;

    address public constant LOGGER_ADDRESS = 0x669e1AF3D294a47366F3796F0FA66Be751A23B0D;

    address public constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;

    address public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;

    

    address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;

    

    /// @notice It will draw Dai from Compound and repay part of the CDP debt

    /// @dev User has to approve DSProxy to pull CDai before calling this

    /// @param _cup Cdp id

    /// @param _amount Amount of Dai that will be taken from Compound and put into CDP

    function repayCDPDebt(bytes32 _cup, uint _amount) public {

        TubInterface tub = TubInterface(TUB_ADDRESS);

        CTokenInterface cDaiContract = CTokenInterface(CDAI_ADDRESS);

        

        approveTub(DAI_ADDRESS);

        approveTub(MKR_ADDRESS);

        approveTub(PETH_ADDRESS);

        approveTub(WETH_ADDRESS);



        // Calculate how many cDai tokens we need to pull for the Dai _amount

        uint cAmount = getCTokenAmount(_amount, CDAI_ADDRESS);     



        cDaiContract.approve(CDAI_ADDRESS, uint(-1));

        cDaiContract.transferFrom(msg.sender, address(this), cAmount);

        

        require(cDaiContract.redeemUnderlying(_amount) == 0, "Reedem Failed");



        // Buy some Mkr to pay stability fee

        uint mkrAmount = stabilityFeeInMkr(tub, _cup, _amount);

        uint daiFee = wmul(mkrAmount, estimatedDaiPrice(_amount));

        uint amountExchanged = exchangeToken(ERC20(DAI_ADDRESS), ERC20(MKR_ADDRESS), daiFee, mkrAmount);



        require(amountExchanged == mkrAmount, "Exact amount of Mkr not exchanged");



        _amount = sub(_amount, daiFee);



        uint daiDebt = getDebt(tub, _cup);



        if (_amount > daiDebt) {

            ERC20(DAI_ADDRESS).transfer(msg.sender, sub(_amount, daiDebt));

            _amount = daiDebt;

        }

        

        tub.wipe(_cup, _amount);

        

        ActionLogger(LOGGER_ADDRESS).logEvent('repayCDPDebt', msg.sender, mkrAmount, amountExchanged);

        

    }

    

    /// @notice It will draw Dai from CDP and add it to Compound

    /// @param _cup CDP id

    /// @param _amount Amount of Dai drawn from the CDP and put into Compound

    function cdpToCompound(bytes32 _cup, uint _amount) public {

        TubInterface tub = TubInterface(TUB_ADDRESS);

        CTokenInterface cDaiContract = CTokenInterface(CDAI_ADDRESS);



        approveTub(WETH_ADDRESS);

        approveTub(PETH_ADDRESS);

        approveTub(DAI_ADDRESS);



        tub.draw(_cup, _amount);

        

        //cDai will try and pull Dai tokens from DSProxy, so approve it

        ERC20(DAI_ADDRESS).approve(CDAI_ADDRESS, uint(-1));

        

        require(cDaiContract.mint(_amount) == 0, "Failed Mint");

        

        uint cDaiMinted = cDaiContract.balanceOf(address(this));

        

        // transfer the cDai to the original sender

        ERC20(CDAI_ADDRESS).transfer(msg.sender, cDaiMinted);

        

        ActionLogger(LOGGER_ADDRESS).logEvent('cdpToCompound', msg.sender, _amount, cDaiMinted);

        

    }



    /// @notice Calculates how many cTokens you get for a _tokenAmount

    function getCTokenAmount(uint _tokenAmount, address _tokeAddress) internal returns(uint cAmount) {

        MathError error;

        (error, cAmount) = divScalarByExpTruncate(_tokenAmount,

             Exp({mantissa: CTokenInterface(_tokeAddress).exchangeRateCurrent()}));



        require(error == MathError.NO_ERROR, "Math error");

    }

    

    /// @notice Stability fee amount in Mkr

    /// @param _tub Tub interface

    /// @param _cup Id of the CDP

    /// @param _daiRepay Amount of dai we are repaying

    function stabilityFeeInMkr(TubInterface _tub, bytes32 _cup, uint _daiRepay) public returns (uint) {

        bytes32 mkrPrice;

        bool ok;



        uint feeInDai = rmul(_daiRepay, rdiv(_tub.rap(_cup), _tub.tab(_cup)));



        (mkrPrice, ok) = _tub.pep().peek();



        return wdiv(feeInDai, uint(mkrPrice));

    }

    

      /// @notice Returns expected rate for Eth -> Dai conversion

    /// @param _amount Amount of Ether

    function estimatedDaiPrice(uint _amount) internal returns (uint expectedRate) {

        (expectedRate, ) = KyberNetworkProxyInterface(KYBER_INTERFACE).getExpectedRate(ERC20(ETHER_ADDRESS), ERC20(DAI_ADDRESS), _amount);

    }

    

    /// @notice Approve a token if it's not already approved

    /// @param _tokenAddress Address of the ERC20 token we want to approve

    function approveTub(address _tokenAddress) internal {

        if (ERC20(_tokenAddress).allowance(msg.sender, _tokenAddress) < (uint(-1) / 2)) {

            ERC20(_tokenAddress).approve(TUB_ADDRESS, uint(-1));

        }

    }



    /// @notice Returns current Dai debt of the CDP

    /// @param _tub Tub interface

    /// @param _cup Id of the CDP

    function getDebt(TubInterface _tub, bytes32 _cup) internal returns (uint debt) {

        ( , , debt, ) = _tub.cups(_cup);

    }



    /// @notice Exhcanged a token on kyber

    function exchangeToken(ERC20 _sourceToken, ERC20 _destToken, uint _sourceAmount, uint _maxAmount) internal returns (uint destAmount) {

        KyberNetworkProxyInterface _kyberNetworkProxy = KyberNetworkProxyInterface(KYBER_INTERFACE);



        uint minRate;

        (, minRate) = _kyberNetworkProxy.getExpectedRate(_sourceToken, _destToken, _sourceAmount);



        require(_sourceToken.approve(address(_kyberNetworkProxy), 0));

        require(_sourceToken.approve(address(_kyberNetworkProxy), _sourceAmount));



        destAmount = _kyberNetworkProxy.trade(

            _sourceToken,

            _sourceAmount,

            _destToken,

            address(this),

            _maxAmount,

            minRate,

            WALLET_ID

        );



        return destAmount;

    }

}