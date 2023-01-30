/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity ^0.5.8;
/**
 This scd to mcd migration works without pool.
 ETH free(scd) => lock(mcd) ==> dai draw(mcd) => swap(dai=>sai) => wipe(scd)
*/

interface TubInterface {
    function open() external returns (bytes32);
    function join(uint) external;
    function exit(uint) external;
    function lock(bytes32, uint) external;
    function free(bytes32, uint) external;
    function draw(bytes32, uint) external;
    function wipe(bytes32, uint) external;
    function give(bytes32, address) external;
    function shut(bytes32) external;
    function cups(bytes32) external view returns (address, uint, uint, uint);
    function gem() external view returns (TokenInterface);
    function gov() external view returns (TokenInterface);
    function skr() external view returns (TokenInterface);
    function sai() external view returns (TokenInterface);
    function ink(bytes32) external view returns (uint);
    function tab(bytes32) external returns (uint);
    function rap(bytes32) external returns (uint);
    function per() external view returns (uint);
    function pep() external view returns (PepInterface);
}

interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function deposit() external payable;
    function withdraw(uint) external;
}

interface PepInterface {
    function peek() external returns (bytes32, bool);
}

interface UniswapExchange {
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);
    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint256 deadline,
        address tokenAddr
    ) external returns (uint256  tokensSold);
    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns (uint256  ethSold);
}

interface UniswapFactoryInterface {
    function getExchange(address token) external view returns (address exchange);
}

interface MCDInterface {
    function swapDaiToSai(uint wad) external;
    function migrate(bytes32 cup) external returns (uint cdp);
}

interface PoolInterface {
    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;
    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;
}

interface OtcInterface {
    function getPayAmount(address, address, uint) external view returns (uint);
    function buyAllAmount(
        address,
        uint,
        address,
        uint
    ) external;
}

interface GemLike {
    function approve(address, uint) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint);
}

interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint);
    function give(uint, address) external;
    function cdpAllow(uint, address, uint) external;
    function urnAllow(address, uint) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
    function exit(
        address,
        uint,
        address,
        uint
    ) external;
    function quit(uint, address) external;
    function enter(address, uint) external;
    function shift(uint, uint) external;
}

interface VatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(
        bytes32,
        address,
        address,
        address,
        int,
        int
    ) external;
    function hope(address) external;
    function move(address, address, uint) external;
}

interface GemJoinLike {
    function dec() external returns (uint);
    function gem() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface GNTJoinLike {
    function bags(address) external view returns (address);
    function make(address) external returns (address);
}

interface DaiJoinLike {
    function vat() external returns (VatLike);
    function dai() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

/** Swap Functionality */
interface ScdMcdMigration {
    function swapDaiToSai(uint daiAmt) external;
    function swapSaiToDai(uint saiAmt) external;
}

interface InstaMcdAddress {
    function manager() external returns (address);
    function dai() external returns (address);
    function daiJoin() external returns (address);
    function vat() external returns (address);
    function jug() external returns (address);
    function cat() external returns (address);
    function gov() external returns (address);
    function adm() external returns (address);
    function vow() external returns (address);
    function spot() external returns (address);
    function pot() external returns (address);
    function esm() external returns (address);
    function mcdFlap() external returns (address);
    function mcdFlop() external returns (address);
    function mcdDeploy() external returns (address);
    function mcdEnd() external returns (address);
    function proxyActions() external returns (address);
    function proxyActionsEnd() external returns (address);
    function proxyActionsDsr() external returns (address);
    function getCdps() external returns (address);
    function saiTub() external returns (address);
    function weth() external returns (address);
    function bat() external returns (address);
    function sai() external returns (address);
    function ethAJoin() external returns (address);
    function ethAFlip() external returns (address);
    function batAJoin() external returns (address);
    function batAFlip() external returns (address);
    function ethPip() external returns (address);
    function batAPip() external returns (address);
    function saiJoin() external returns (address);
    function saiFlip() external returns (address);
    function saiPip() external returns (address);
    function migration() external returns (address payable);
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y <= x ? x - y : 0;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

}


contract Helpers is DSMath {

    /**
     * @dev get MakerDAO SCD CDP engine
     */
    function getSaiTubAddress() public pure returns (address sai) {
        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    }

     /**
     * @dev get MakerDAO MCD Address contract
     */
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;
    }

    /**
     * @dev get ETH Address
     */
    function getETHAddress() public pure returns (address ethAddr) {
        ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // main
    }

    /**
     * @dev get Sai (Dai v1) address
     */
    function getSaiAddress() public pure returns (address sai) {
        sai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    }

    /**
     * @dev get Dai (Dai v2) address
     */
    function getDaiAddress() public pure returns (address dai) {
        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    /**
     * @dev get Compound WETH Address
     */
    function getWETHAddress() public pure returns (address wethAddr) {
        wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // main
    }

    /**
     * @dev get OTC Address
     */
    function getOtcAddress() public pure returns (address otcAddr) {
        otcAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; // main
    }

    /**
     * @dev get InstaDApp CDP's Address
     */
    function getGiveAddress() public pure returns (address addr) {
        addr = 0xc679857761beE860f5Ec4B3368dFE9752580B096;
    }

    /**
     * @dev get uniswap MKR exchange
     */
    function getUniswapMKRExchange() public pure returns (address ume) {
        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;
    }

    /**
     * @dev get uniswap MKR exchange
     */
    function getUniFactoryAddr() public pure returns (address ufa) {
        ufa = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    }

    /**
     * @dev setting allowance if required
     */
    function setApproval(address erc20, uint srcAmt, address to) internal {
        TokenInterface erc20Contract = TokenInterface(erc20);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, uint(-1));
        }
    }

}


contract MKRSwapper is  Helpers {

    function getBestMkrSwap(address srcTknAddr, uint destMkrAmt) public view returns(uint bestEx, uint srcAmt) {
        uint oasisPrice = getOasisSwap(srcTknAddr, destMkrAmt);
        uint uniswapPrice = getUniswapSwap(srcTknAddr, destMkrAmt);
        require(oasisPrice != 0 && uniswapPrice != 0, "swap price 0");
        srcAmt = oasisPrice < uniswapPrice ? oasisPrice : uniswapPrice;
        bestEx = oasisPrice < uniswapPrice ? 0 : 1; // if 0 then use Oasis for Swap, if 1 then use Uniswap
    }

    function getOasisSwap(address tokenAddr, uint destMkrAmt) public view returns(uint srcAmt) {
        TokenInterface mkr = TubInterface(getSaiTubAddress()).gov();
        address srcTknAddr = tokenAddr == getETHAddress() ? getWETHAddress() : tokenAddr;
        srcAmt = OtcInterface(getOtcAddress()).getPayAmount(srcTknAddr, address(mkr), destMkrAmt);
    }

    function getUniswapSwap(address srcTknAddr, uint destMkrAmt) public view returns(uint srcAmt) {
        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());
        if (srcTknAddr == getETHAddress()) {
            srcAmt = mkrEx.getEthToTokenOutputPrice(destMkrAmt);
        } else {
            address buyTknExAddr = UniswapFactoryInterface(getUniFactoryAddr()).getExchange(srcTknAddr);
            UniswapExchange buyTknEx = UniswapExchange(buyTknExAddr);
            srcAmt = buyTknEx.getTokenToEthOutputPrice(mkrEx.getEthToTokenOutputPrice(destMkrAmt)); //Check thrilok is this correct
        }
    }

    function swapToMkr(address tokenAddr, uint govFee) internal {
        (uint bestEx, uint srcAmt) = getBestMkrSwap(tokenAddr, govFee);
        if (bestEx == 0) {
            swapToMkrOtc(tokenAddr, srcAmt, govFee);
        } else {
            swapToMkrUniswap(tokenAddr, srcAmt, govFee);
        }
    }

    function swapToMkrOtc(address tokenAddr, uint srcAmt, uint govFee) internal {
        address mkr = InstaMcdAddress(getMcdAddresses()).gov();
        address srcTknAddr = tokenAddr == getETHAddress() ? getWETHAddress() : tokenAddr;
        if (srcTknAddr == getWETHAddress()) {
            TokenInterface weth = TokenInterface(getWETHAddress());
            weth.deposit.value(srcAmt)();
        } else if (srcTknAddr != getSaiAddress() && srcTknAddr != getDaiAddress()) {
            require(TokenInterface(srcTknAddr).transferFrom(msg.sender, address(this), srcAmt), "Tranfer-failed");
        }

        setApproval(srcTknAddr, srcAmt, getOtcAddress());
        OtcInterface(getOtcAddress()).buyAllAmount(
            mkr,
            govFee,
            srcTknAddr,
            srcAmt
        );
    }

    function swapToMkrUniswap(address tokenAddr, uint srcAmt, uint govFee) internal {
        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());
        address mkr = InstaMcdAddress(getMcdAddresses()).gov();

        if (tokenAddr == getETHAddress()) {
            mkrEx.ethToTokenSwapOutput.value(srcAmt)(govFee, uint(1899063809));
        } else {
            if (tokenAddr != getSaiAddress() && tokenAddr != getDaiAddress()) {
               require(TokenInterface(tokenAddr).transferFrom(msg.sender, address(this), srcAmt), "not-approved-yet");
            }
            address buyTknExAddr = UniswapFactoryInterface(getUniFactoryAddr()).getExchange(tokenAddr);
            UniswapExchange buyTknEx = UniswapExchange(buyTknExAddr);
            setApproval(tokenAddr, srcAmt, buyTknExAddr);
            buyTknEx.tokenToTokenSwapOutput(
                    govFee,
                    srcAmt,
                    uint(999000000000000000000),
                    uint(1899063809), // 6th March 2030 GMT // no logic
                    mkr
                );
        }
    }

}


contract SCDResolver is MKRSwapper {
function getFeeOfCdp(bytes32 cup, uint _wad) internal returns (uint mkrFee) {
        TubInterface tub = TubInterface(getSaiTubAddress());
        (bytes32 val, bool ok) = tub.pep().peek();
        if (ok && val != 0) {
            // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value
            mkrFee = rdiv(tub.rap(cup), tub.tab(cup));
            mkrFee = rmul(_wad, mkrFee);
            mkrFee = wdiv(mkrFee, uint(val));
        }
    }

    function open() internal returns (bytes32 cup) {
        cup = TubInterface(getSaiTubAddress()).open();
    }

    function wipeSai(bytes32 cup, uint _wad, address payFeeWith) internal {
        if (_wad > 0) {
            TubInterface tub = TubInterface(getSaiTubAddress());
            TokenInterface dai = tub.sai();
            TokenInterface mkr = tub.gov();

            (address lad,,,) = tub.cups(cup);
            require(lad == address(this), "cup-not-owned");

            setAllowance(dai, getSaiTubAddress());
            setAllowance(mkr, getSaiTubAddress());

            uint mkrFee = getFeeOfCdp(cup, _wad);

            if (payFeeWith != address(mkr) && mkrFee > 0) {
                swapToMkr(payFeeWith, mkrFee); //otc or uniswap
            } else if (payFeeWith == address(mkr) && mkrFee > 0) {
                require(TokenInterface(address(mkr)).transferFrom(msg.sender, address(this), mkrFee), "Tranfer-failed");
            }

            tub.wipe(cup, _wad);
        }
    }

    function scdFree(bytes32 cup, uint jam) internal {
        if (jam > 0) {
            address tubAddr = getSaiTubAddress();

            TubInterface tub = TubInterface(tubAddr);
            TokenInterface peth = tub.skr();

            uint ink = rdiv(jam, tub.per());
            ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;
            tub.free(cup, ink);

            setAllowance(peth, tubAddr);

            tub.exit(ink);
        }
    }

    function setAllowance(TokenInterface _token, address _spender) private {
        if (_token.allowance(address(this), _spender) != uint(-1)) {
            _token.approve(_spender, uint(-1));
        }
    }
}


contract MCDResolver is SCDResolver {
    function openVault() public returns (uint cdp) {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        bytes32 ilk = 0x4554482d41000000000000000000000000000000000000000000000000000000;
        cdp = ManagerLike(manager).open(ilk, address(this));
    }

    function mcdLock(
        uint cdp,
        uint ink
    ) internal
    {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();
        GemJoinLike(ethJoin).gem().approve(address(ethJoin), ink);
        GemJoinLike(ethJoin).join(address(this), ink);

        // Locks WETH amount into the CDP
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            int(ink),
            0
        );
    }

    function daiDraw(
        uint cdp,
        uint wad
    ) internal
    {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address jug = InstaMcdAddress(getMcdAddresses()).jug();
        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        // Updates stability fee rate before generating new debt
        uint rate = JugLike(jug).drip(ilk); // Check Thrilok - check if its working

        int dart;
        // Gets actual rate from the vat
        // (, uint rate,,,) = VatLike(vat).ilks(ilk); // Check Thrilok - check if above its working
        // Gets DAI balance of the urn in the vat
        uint dai = VatLike(vat).dai(urn);

        // If there was already enough DAI in the vat balance, just exits it without adding more debt
        if (dai < mul(wad, RAY)) {
            // Calculates the needed dart so together with the existing dai in the vat is enough to exit wad amount of DAI tokens
            dart = int(sub(mul(wad, RAY), dai) / rate);
            // This is neeeded due lack of precision. It might need to sum an extra dart wei (for the given DAI wad amount)
            dart = mul(uint(dart), rate) < mul(wad, RAY) ? dart + 1 : dart;
        }

        ManagerLike(manager).frob(cdp, 0, dart);
        // Moves the DAI amount (balance in the vat in rad) to proxy's address
        ManagerLike(manager).move(cdp, address(this), toRad(wad));
        // Allows adapter to access to proxy's DAI balance in the vat
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(address(this), wad);
    }
}


contract MigrateHelper is MCDResolver {
    function swapDaiToSai(
        uint wad // Amount to swap
    ) internal
    {
        address scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();    // Migration contract address
        TokenInterface dai = TokenInterface(getDaiAddress());
        if (dai.allowance(address(this), scdMcdMigration) < wad) {
            dai.approve(scdMcdMigration, wad);
        }
        ScdMcdMigration(scdMcdMigration).swapDaiToSai(wad);
    }

     function setSplitAmount(
        bytes32 cup,
        uint toConvert,
        address payFeeWith,
        address saiJoin
    ) internal returns (uint _wad, uint _ink, uint maxConvert)
    {
        // Set ratio according to user.
        TubInterface tub = TubInterface(getSaiTubAddress());

        maxConvert = toConvert;
        uint saiBal = tub.sai().balanceOf(saiJoin);
        uint _wadTotal = tub.tab(cup);

        uint feeAmt = 0;

        // wad according to toConvert ratio
        _wad = wmul(_wadTotal, toConvert);

        // if migration is by debt method, Add fee(SAI) to _wad
        if (payFeeWith == getDaiAddress()) {
            uint mkrAmt = getFeeOfCdp(cup, _wad);
            (, feeAmt) = getBestMkrSwap(getSaiAddress(), mkrAmt);
            _wad = add(_wad, feeAmt);
        }

        //if sai_join has enough sai to migrate.
        if (saiBal < _wad) {
            // set saiBal as wad amount And sub feeAmt(feeAmt > 0, when its debt method).
            _wad = sub(saiBal, 100000);
            // set new convert ratio according to sai_join balance.
            maxConvert = sub(wdiv(saiBal, _wadTotal), 100);
        }

        // ink according to maxConvert ratio.
        _wad = sub(_wad, feeAmt);
        _ink = wmul(tub.ink(cup), maxConvert);
    }

    function ethScdToMcd(
        bytes32 scdCup,
        uint mcdCup,
        uint _ink
    ) internal
    {
        //transfer assets from scdCup to mcdCup.
        scdFree(scdCup, _ink);
        mcdLock(mcdCup, _ink);
    }

    function drawDaiAndPaySai(
        bytes32 scdCup,
        uint mcdCup,
        uint _wad,
        address payFeeWith
    ) internal
    {
        uint _wadForDebt = payFeeWith == getDaiAddress() ? add(_wad, getFeeOfCdp(scdCup, _wad)) : _wad;

        daiDraw(mcdCup, _wadForDebt);

        swapDaiToSai((payFeeWith == getSaiAddress() ? _wadForDebt :_wad));

        wipeSai(scdCup, _wad, payFeeWith);

    }
}


contract MigrateResolver is MigrateHelper {

    event LogScdToMcdMigrate(uint scdCdp, uint toConvert, uint coll, uint debt, address payFeeWith, uint mcdCdp, uint newMcdCdp);

    function migrate(
        uint scdCDP,
        uint mergeCDP,
        uint toConvert,
        address payFeeWith
    ) external payable
    {

        uint mcdCdp = mergeCDP == 0 ? openVault() : mergeCDP;
        bytes32 scdCup = bytes32(scdCDP);

        uint maxConvert = toConvert;

        uint _wad;
        uint _ink;
        (_wad, _ink, maxConvert) = setSplitAmount(
            scdCup,
            toConvert,
            payFeeWith,
            InstaMcdAddress(getMcdAddresses()).saiJoin());

        ethScdToMcd(
            scdCup,
            mcdCdp,
            _ink
        );

        drawDaiAndPaySai(
            scdCup,
            mcdCdp,
            _wad,
            payFeeWith
        );

        //Transfer if any ETH leftover.
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }

        emit LogScdToMcdMigrate(
            uint(scdCup),
            maxConvert,
            _ink,
            _wad,
            payFeeWith,
            mergeCDP,
            mcdCdp
        );
    }
}


contract InstaMcdMigrate is MigrateResolver {
    function() external payable {}
}