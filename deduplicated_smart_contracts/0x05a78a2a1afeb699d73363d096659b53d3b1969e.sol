/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


contract Manager {
    function cdpCan(address, uint, address) public view returns (uint);
    function ilks(uint) public view returns (bytes32);
    function owns(uint) public view returns (address);
    function urns(uint) public view returns (address);
    function vat() public view returns (address);
    function open(bytes32, address) public returns (uint);
    function give(uint, address) public;
    function cdpAllow(uint, address, uint) public;
    function urnAllow(address, uint) public;
    function frob(uint, int, int) public;
    function flux(uint, address, uint) public;
    function move(uint, address, uint) public;
    function exit(address, uint, address, uint) public;
    function quit(uint, address) public;
    function enter(address, uint) public;
    function shift(uint, uint) public;
}

contract Static {

    enum Method { Boost, Repay }
}

contract ISubscriptions is Static {

    function canCall(Method _method, uint _cdpId) external view returns(bool, uint);
    function getOwner(uint _cdpId) external view returns(address);
    function ratioGoodAfter(Method _method, uint _cdpId) external view returns(bool, uint);
    function getRatio(uint _cdpId) public view returns (uint);
}

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface ExchangeInterface {
    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) payable external returns(uint, uint);
    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint);
    function swapTokenToToken(address _src, address _dest, uint _amount) external payable returns(uint);

    function getExpectedRate(address src, address dest, uint srcQty) external view
        returns (uint expectedRate);
}

contract ConstantAddressesMainnet {
    address public constant MAKER_DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    address public constant IDAI_ADDRESS = 0x14094949152EDDBFcd073717200DA82fEd8dC960;
    address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;
    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant MKR_ADDRESS = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant VOX_ADDRESS = 0x9B0F70Df76165442ca6092939132bBAEA77f2d7A;
    address public constant PETH_ADDRESS = 0xf53AD2c6851052A81B42133467480961B2321C09;
    address public constant TUB_ADDRESS = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    address payable public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;
    address public constant LOGGER_ADDRESS = 0xeCf88e1ceC2D2894A0295DB3D86Fe7CE4991E6dF;
    address public constant OTC_ADDRESS = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;
    address public constant DISCOUNT_ADDRESS = 0x1b14E8D511c9A4395425314f849bD737BAF8208F;

    address public constant KYBER_WRAPPER = 0x8F337bD3b7F2b05d9A8dC8Ac518584e833424893;
    address public constant UNISWAP_WRAPPER = 0x1e30124FDE14533231216D95F7798cD0061e5cf8;
    address public constant ETH2DAI_WRAPPER = 0xd7BBB1777E13b6F535Dec414f575b858ed300baF;
    address public constant OASIS_WRAPPER = 0xCbE344DBBcCEbF04c0D045102A4bfA76c49b33c9;

    address public constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    address public constant UNISWAP_FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;
    address public constant PIP_INTERFACE_ADDRESS = 0x729D19f657BD0614b4985Cf1D82531c67569197B;

    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;
    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;

    address public constant SAVINGS_LOGGER_ADDRESS = 0x89b3635BD2bAD145C6f92E82C9e83f06D5654984;

    address public constant SAVER_EXCHANGE_ADDRESS = 0x865B41584A22F8345Fca4B71c42a1E7aBcD67eCB;

    
    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;
    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;

    
    address public constant MANAGER_ADDRESS = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address public constant VAT_ADDRESS = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address public constant SPOTTER_ADDRESS = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;

    address public constant JUG_ADDRESS = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address public constant DAI_JOIN_ADDRESS = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public constant ETH_JOIN_ADDRESS = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;

    address public constant SAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    address public constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address payable public constant SCD_MCD_MIGRATION = 0xc73e0383F3Aff3215E6f04B0331D58CeCf0Ab849;

    
    address public constant SUBSCRIPTION_ADDRESS = 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;
    address public constant MONITOR_ADDRESS = 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;

}

contract ConstantAddressesKovan {
    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant WETH_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    address public constant MAKER_DAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    address public constant MKR_ADDRESS = 0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD;
    address public constant VOX_ADDRESS = 0xBb4339c0aB5B1d9f14Bd6e3426444A1e9d86A1d9;
    address public constant PETH_ADDRESS = 0xf4d791139cE033Ad35DB2B2201435fAd668B1b64;
    address public constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;
    address public constant LOGGER_ADDRESS = 0x32d0e18f988F952Eb3524aCE762042381a2c39E5;
    address payable public  constant WALLET_ID = 0x54b44C6B18fc0b4A1010B21d524c338D1f8065F6;
    address public constant OTC_ADDRESS = 0x4A6bC4e803c62081ffEbCc8d227B5a87a58f1F8F;
    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;
    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    address public constant IDAI_ADDRESS = 0xA1e58F3B1927743393b25f261471E1f2D3D9f0F6;
    address public constant CDAI_ADDRESS = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;
    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;
    address public constant DISCOUNT_ADDRESS = 0x1297c1105FEDf45E0CF6C102934f32C4EB780929;
    address public constant SAI_SAVER_PROXY = 0xADB7c74bCe932fC6C27ddA3Ac2344707d2fBb0E6;

    address public constant KYBER_WRAPPER = 0x68c56FF0E7BBD30AF9Ad68225479449869fC1bA0;
    address public constant UNISWAP_WRAPPER = 0x2A4ee140F05f1Ba9A07A020b07CCFB76CecE4b43;
    address public constant ETH2DAI_WRAPPER = 0x823cde416973a19f98Bb9C96d97F4FE6C9A7238B;
    address public constant OASIS_WRAPPER = 0x0257Ba4876863143bbeDB7847beC583e4deb6fE6;

    address public constant SAVER_EXCHANGE_ADDRESS = 0xACA7d11e3f482418C324aAC8e90AaD0431f692A6;


    address public constant FACTORY_ADDRESS = 0xc72E74E474682680a414b506699bBcA44ab9a930;
    
    address public constant PIP_INTERFACE_ADDRESS = 0xA944bd4b25C9F186A846fd5668941AA3d3B8425F;
    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x64A436ae831C1672AE81F674CAb8B6775df3475C;
    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000170CcC93903185bE5A2094C870Df62;
    address public constant KYBER_INTERFACE = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;

    address public constant SAVINGS_LOGGER_ADDRESS = 0xA6E5d5F489b1c00d9C11E1caF45BAb6e6e26443d;

    
    address public constant UNISWAP_FACTORY = 0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36;

    
    address public constant MANAGER_ADDRESS = 0x1476483dD8C35F25e568113C5f70249D3976ba21;
    address public constant VAT_ADDRESS = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address public constant SPOTTER_ADDRESS = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;

    address public constant JUG_ADDRESS = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address public constant DAI_JOIN_ADDRESS = 0x5AA71a3ae1C0bd6ac27A1f28e1415fFFB6F15B8c;
    address public constant ETH_JOIN_ADDRESS = 0x775787933e92b709f2a3C70aa87999696e74A9F8;

    address public constant SAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    address public constant DAI_ADDRESS = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;

    address payable public constant SCD_MCD_MIGRATION = 0x411B2Faa662C8e3E5cF8f01dFdae0aeE482ca7b0;

    
    address public constant SUBSCRIPTION_ADDRESS = 0xFC41f79776061a396635aD0b9dF7a640A05063C1;
    address public constant MONITOR_ADDRESS = 0xfC1Fc0502e90B7A3766f93344E1eDb906F8A75DD;
}

contract ConstantAddresses is ConstantAddressesMainnet {
}

contract SaverLogger {
    event Repay(uint indexed cdpId, address indexed owner, uint collateralAmount, uint daiAmount);
    event Boost(uint indexed cdpId, address indexed owner, uint daiAmount, uint collateralAmount);

    function LogRepay(uint _cdpId, address _owner, uint _collateralAmount, uint _daiAmount) public {
        emit Repay(_cdpId, _owner, _collateralAmount, _daiAmount);
    }

    function LogBoost(uint _cdpId, address _owner, uint _daiAmount, uint _collateralAmount) public {
        emit Boost(_cdpId, _owner, _daiAmount, _collateralAmount);
    }
}

contract Discount {

    address public owner;
    mapping (address => CustomServiceFee) public serviceFees;

    uint constant MAX_SERVICE_FEE = 400;

    struct CustomServiceFee {
        bool active;
        uint amount;
    }

    constructor() public {
        owner = msg.sender;
    }

    function isCustomFeeSet(address _user) public view returns (bool) {
        return serviceFees[_user].active;
    }

    function getCustomServiceFee(address _user) public view returns (uint) {
        return serviceFees[_user].amount;
    }

    function setServiceFee(address _user, uint _fee) public {
        require(msg.sender == owner, "Only owner");
        require(_fee >= MAX_SERVICE_FEE || _fee == 0);

        serviceFees[_user] = CustomServiceFee({
            active: true,
            amount: _fee
        });
    }

    function disableServiceFee(address _user) public {
        require(msg.sender == owner, "Only owner");

        serviceFees[_user] = CustomServiceFee({
            active: false,
            amount: 0
        });
    }
}

contract PipInterface {
    function read() public returns (bytes32);
}

contract Spotter {
    struct Ilk {
        PipInterface pip;
        uint256 mat;
    }

    mapping (bytes32 => Ilk) public ilks;

    uint256 public par;

}

contract Jug {
    struct Ilk {
        uint256 duty;
        uint256  rho;
    }

    mapping (bytes32 => Ilk) public ilks;

    function drip(bytes32) public returns (uint);
}

contract Vat {

    struct Urn {
        uint256 ink;   
        uint256 art;   
    }

    struct Ilk {
        uint256 Art;   
        uint256 rate;  
        uint256 spot;  
        uint256 line;  
        uint256 dust;  
    }

    mapping (bytes32 => mapping (address => Urn )) public urns;
    mapping (bytes32 => Ilk)                       public ilks;

    function can(address, address) public view returns (uint);
    function dai(address) public view returns (uint);
    function frob(bytes32, address, address, address, int, int) public;
    function hope(address) public;
    function move(address, address, uint) public;
}

contract Gem {
    function dec() public returns (uint);
    function gem() public returns (Gem);
    function join(address, uint) public payable;
    function exit(address, uint) public;

    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
    function allowance(address, address) public returns (uint);
}

contract DaiJoin {
    function vat() public returns (Vat);
    function dai() public returns (Gem);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract SaverExchangeInterface {
    function getBestPrice(uint _amount, address _srcToken, address _destToken, uint _exchangeType) public view returns (address, uint);
}

contract ExchangeHelper is ConstantAddresses {

    
    
    
    
    
    
    
    function swap(address _src, address _dest, uint _amount, uint _minPrice, uint _exchangeType) internal returns (uint) {
        address wrapper;
        uint price;

        _src = wethToKyberEth(_src);
        _dest = wethToKyberEth(_dest);

        (wrapper, price) = SaverExchangeInterface(SAVER_EXCHANGE_ADDRESS).getBestPrice(_amount, _src, _dest, _exchangeType);

        require(price > _minPrice, "Slippage hit");

        uint tokensReturned;
        if (_src == KYBER_ETH_ADDRESS) {
            (tokensReturned,) = ExchangeInterface(wrapper).swapEtherToToken.value(_amount)(_amount, _dest, uint(-1));
        } else {
            ERC20(_src).transfer(wrapper, _amount);

            if (_dest == KYBER_ETH_ADDRESS) {
                tokensReturned = ExchangeInterface(wrapper).swapTokenToEther(_src, _amount, uint(-1));
            } else {
                tokensReturned = ExchangeInterface(wrapper).swapTokenToToken(_src, _dest, _amount);
            }
        }

        return tokensReturned;
    }

    
    
    function wethToKyberEth(address _src) internal pure returns (address) {
        return _src == WETH_ADDRESS ? KYBER_ETH_ADDRESS : _src;
    }
}

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

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache;  

    constructor(address _cacheAddr) public {
        require(setCache(_cacheAddr));
    }

    function() external payable {
    }

    
    function execute(bytes memory _code, bytes memory _data)
        public
        payable
        returns (address target, bytes32 response)
    {
        target = cache.read(_code);
        if (target == address(0)) {
            
            target = cache.write(_code);
        }

        response = execute(target, _data);
    }

    function execute(address _target, bytes memory _data)
        public
        auth
        note
        payable
        returns (bytes32 response)
    {
        require(_target != address(0));

        
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _target, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)      
            switch iszero(succeeded)
            case 1 {
                
                revert(0, 0)
            }
        }
    }

    
    function setCache(address _cacheAddr)
        public
        payable
        auth
        note
        returns (bool)
    {
        require(_cacheAddr != address(0));        
        cache = DSProxyCache(_cacheAddr);  
        return true;
    }
}

contract DSProxyCache {
    mapping(bytes32 => address) cache;

    function read(bytes memory _code) public view returns (address) {
        bytes32 hash = keccak256(_code);
        return cache[hash];
    }

    function write(bytes memory _code) public returns (address target) {
        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
            case 1 {
                
                revert(0, 0)
            }
        }
        bytes32 hash = keccak256(_code);
        cache[hash] = target;
    }
}

contract Join {
    bytes32 public ilk;

    function dec() public returns (uint);
    function gem() public returns (Gem);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract SaverProxyHelper is DSMath {

    
    
    
    
    function normalizeDrawAmount(uint _amount, uint _rate, uint _daiVatBalance) internal pure returns (int dart) {
        if (_daiVatBalance < mul(_amount, RAY)) {
            dart = toPositiveInt(sub(mul(_amount, RAY), _daiVatBalance) / _rate);
            dart = mul(uint(dart), _rate) < mul(_amount, RAY) ? dart + 1 : dart;
        }
    }

    
    
    function toRad(uint _wad) internal pure returns (uint) {
        return mul(_wad, 10 ** 27);
    }

    
    
    
    function convertTo18(address _joinAddr, uint256 _amount) internal returns (uint256) {
        return mul(_amount, 10 ** (18 - Join(_joinAddr).dec()));
    }

    
    
    function toPositiveInt(uint _x) internal pure returns (int y) {
        y = int(_x);
        require(y >= 0, "int-overflow");
    }

    
    
    
    
    function normalizePaybackAmount(address _vat, address _urn, bytes32 _ilk) internal view returns (int amount) {
        uint dai = Vat(_vat).dai(_urn);

        (, uint rate,,,) = Vat(_vat).ilks(_ilk);
        (, uint art) = Vat(_vat).urns(_ilk, _urn);

        amount = toPositiveInt(dai / rate);
        amount = uint(amount) <= art ? - amount : - toPositiveInt(art);
    }

    
    
    
    
    
    function getAllDebt(address _vat, address _usr, address _urn, bytes32 _ilk) internal view returns (uint daiAmount) {
        (, uint rate,,,) = Vat(_vat).ilks(_ilk);
        (, uint art) = Vat(_vat).urns(_ilk, _urn);
        uint dai = Vat(_vat).dai(_usr);

        uint rad = sub(mul(art, rate), dai);
        daiAmount = rad / RAY;

        daiAmount = mul(daiAmount, RAY) < rad ? daiAmount + 1 : daiAmount;
    }

    
    
    function getCollateralAddr(address _joinAddr) internal returns (address) {
        return address(Join(_joinAddr).gem());
    }

    
    
    
    
    function getCdpInfo(Manager _manager, uint _cdpId, bytes32 _ilk) public view returns (uint, uint) {
        address vat = _manager.vat();
        address urn = _manager.urns(_cdpId);

        (uint collateral, uint debt) = Vat(vat).urns(_ilk, urn);
        (,uint rate,,,) = Vat(vat).ilks(_ilk);

        return (collateral, rmul(debt, rate));
    }

    
    
    
    function getOwner(Manager _manager, uint _cdpId) public view returns (address) {
        DSProxy proxy = DSProxy(uint160(_manager.owns(_cdpId)));

        return proxy.owner();
    }
}

contract MCDSaverProxy is SaverProxyHelper, ExchangeHelper {

    uint public constant SERVICE_FEE = 400; 
    bytes32 public constant ETH_ILK = 0x4554482d41000000000000000000000000000000000000000000000000000000;

    Manager public constant manager = Manager(MANAGER_ADDRESS);
    Vat public constant vat = Vat(VAT_ADDRESS);
    DaiJoin public constant daiJoin = DaiJoin(DAI_JOIN_ADDRESS);
    Spotter public constant spotter = Spotter(SPOTTER_ADDRESS);

    
    
    modifier boostCheck(uint _cdpId) {
        bytes32 ilk = manager.ilks(_cdpId);
        address urn = manager.urns(_cdpId);

        (uint collateralBefore, ) = vat.urns(ilk, urn);

        _;

        (uint collateralAfter, ) = vat.urns(ilk, urn);

        require(collateralAfter > collateralBefore);
    }

    
    
    modifier repayCheck(uint _cdpId) {
        bytes32 ilk = manager.ilks(_cdpId);

        uint beforeRatio = getRatio(_cdpId, ilk);

        _;

        uint afterRatio = getRatio(_cdpId, ilk);

        require(afterRatio > beforeRatio || afterRatio == 0);
    }

    
    
    
    
    
    
    
    
    function repay(
        uint _cdpId,
        address _joinAddr,
        uint _amount,
        uint _minPrice,
        uint _exchangeType,
        uint _gasCost
    ) external repayCheck(_cdpId) {

        address owner = getOwner(manager, _cdpId);
        bytes32 ilk = manager.ilks(_cdpId);

        uint collDrawn = drawCollateral(_cdpId, ilk, _joinAddr, _amount);

        uint daiAmount = swap(getCollateralAddr(_joinAddr), DAI_ADDRESS, collDrawn, _minPrice, _exchangeType);

        uint daiAfterFee = sub(daiAmount, getFee(daiAmount, _gasCost, owner));

        paybackDebt(_cdpId, ilk, daiAfterFee, owner);

        SaverLogger(LOGGER_ADDRESS).LogRepay(_cdpId, owner, collDrawn, daiAmount);
    }

    
    
    
    
    
    
    
    
    function boost(
        uint _cdpId,
        address _joinAddr,
        uint _daiAmount,
        uint _minPrice,
        uint _exchangeType,
        uint _gasCost
    ) external boostCheck(_cdpId) {
        address owner = getOwner(manager, _cdpId);

        uint daiDrawn = drawDai(_cdpId, manager.ilks(_cdpId), _daiAmount);

        uint daiAfterFee = sub(daiDrawn, getFee(daiDrawn, _gasCost, owner));

        uint collateralAmount = swap(DAI_ADDRESS, getCollateralAddr(_joinAddr), daiAfterFee, _minPrice, _exchangeType);

        addCollateral(_cdpId, _joinAddr, collateralAmount);

        SaverLogger(LOGGER_ADDRESS).LogBoost(_cdpId, owner, daiDrawn, collateralAmount);
    }

    
    
    
    
    
    function drawDai(uint _cdpId, bytes32 _ilk, uint _daiAmount) internal returns (uint) {
        uint rate = Jug(JUG_ADDRESS).drip(_ilk);
        uint daiVatBalance = vat.dai(manager.urns(_cdpId));

        uint maxAmount = getMaxDebt(_cdpId, _ilk);

        if (_daiAmount >= maxAmount) {
            _daiAmount = sub(maxAmount, 1);
        }

        manager.frob(_cdpId, int(0), normalizeDrawAmount(_daiAmount, rate, daiVatBalance));
        manager.move(_cdpId, address(this), toRad(_daiAmount));

        if (vat.can(address(this), address(DAI_JOIN_ADDRESS)) == 0) {
            vat.hope(DAI_JOIN_ADDRESS);
        }

        DaiJoin(DAI_JOIN_ADDRESS).exit(address(this), _daiAmount);

        return _daiAmount;
    }

    
    
    
    
    function addCollateral(uint _cdpId, address _joinAddr, uint _amount) internal {
        int convertAmount = 0;

        if (_joinAddr == ETH_JOIN_ADDRESS) {
            Join(_joinAddr).gem().deposit.value(_amount)();
            convertAmount = toPositiveInt(_amount);
        } else {
            convertAmount = toPositiveInt(convertTo18(_joinAddr, _amount));
        }

        Join(_joinAddr).gem().approve(_joinAddr, _amount);
        Join(_joinAddr).join(address(this), _amount);

        vat.frob(
            manager.ilks(_cdpId),
            manager.urns(_cdpId),
            address(this),
            address(this),
            convertAmount,
            0
        );

    }

    
    
    
    
    
    
    function drawCollateral(uint _cdpId, bytes32 _ilk, address _joinAddr, uint _amount) internal returns (uint) {
        uint maxCollateral = getMaxCollateral(_cdpId, _ilk);

        if (_amount >= maxCollateral) {
            _amount = sub(maxCollateral, 1);
        }

        manager.frob(_cdpId, -toPositiveInt(_amount), 0);
        manager.flux(_cdpId, address(this), _amount);

        Join(_joinAddr).exit(address(this), _amount);

        if (_joinAddr == ETH_JOIN_ADDRESS) {
            Join(_joinAddr).gem().withdraw(_amount); 
        }

        return _amount;
    }

    
    
    
    
    
    
    function paybackDebt(uint _cdpId, bytes32 _ilk, uint _daiAmount, address _owner) internal {
        address urn = manager.urns(_cdpId);

        uint wholeDebt = getAllDebt(VAT_ADDRESS, urn, urn, _ilk);

        if (_daiAmount > wholeDebt) {
            ERC20(DAI_ADDRESS).transfer(_owner, sub(_daiAmount, wholeDebt));
            _daiAmount = wholeDebt;
        }

        daiJoin.dai().approve(DAI_JOIN_ADDRESS, _daiAmount);
        daiJoin.join(urn, _daiAmount);

        manager.frob(_cdpId, 0, normalizePaybackAmount(VAT_ADDRESS, urn, _ilk));
    }

    
    
    
    
    function getFee(uint _amount, uint _gasCost, address _owner) internal returns (uint feeAmount) {
        uint fee = SERVICE_FEE;

        if (Discount(DISCOUNT_ADDRESS).isCustomFeeSet(_owner)) {
            fee = Discount(DISCOUNT_ADDRESS).getCustomServiceFee(_owner);
        }

        feeAmount = (fee == 0) ? 0 : (_amount / fee);

        if (_gasCost != 0) {
            uint ethDaiPrice = getPrice(ETH_ILK);
            _gasCost = rmul(_gasCost, ethDaiPrice);

            feeAmount = add(feeAmount, _gasCost);
        }

        
        if (feeAmount > (_amount / 5)) {
            feeAmount = _amount / 5;
        }

        ERC20(DAI_ADDRESS).transfer(WALLET_ID, feeAmount);
    }

    
    
    
    function getMaxCollateral(uint _cdpId, bytes32 _ilk) public view returns (uint) {
        uint price = getPrice(_ilk);

        (uint collateral, uint debt) = getCdpInfo(manager, _cdpId, _ilk);

        (, uint mat) = Spotter(SPOTTER_ADDRESS).ilks(_ilk);

        return sub(collateral, (wdiv(wmul(mat, debt), price)));
    }

    
    
    
    function getMaxDebt(uint _cdpId, bytes32 _ilk) public view returns (uint) {
        uint price = getPrice(_ilk);

        (, uint mat) = spotter.ilks(_ilk);
        (uint collateral, uint debt) = getCdpInfo(manager, _cdpId, _ilk);

        return sub(wdiv(wmul(collateral, price), mat), debt);
    }

    
    
    function getPrice(bytes32 _ilk) public view returns (uint) {
        (, uint mat) = spotter.ilks(_ilk);
        (,,uint spot,,) = vat.ilks(_ilk);

        return rmul(rmul(spot, spotter.par()), mat);
    }

    
    
    
    function getRatio(uint _cdpId, bytes32 _ilk) public view returns (uint) {
        uint price = getPrice( _ilk);

        (uint collateral, uint debt) = getCdpInfo(manager, _cdpId, _ilk);

        if (debt == 0) return 0;

        return rdiv(wmul(collateral, price), debt);
    }

    
    
    function getCdpDetailedInfo(uint _cdpId) public view returns (uint collateral, uint debt, uint price, bytes32 ilk) {
        address urn = manager.urns(_cdpId);
        ilk = manager.ilks(_cdpId);

        (collateral, debt) = vat.urns(ilk, urn);
        (,uint rate,,,) = vat.ilks(ilk);

        debt = rmul(debt, rate);
        price = getPrice(ilk);
    }

}

contract Subscriptions is ISubscriptions, ConstantAddresses {

    bytes32 internal constant ETH_ILK = 0x4554482d41000000000000000000000000000000000000000000000000000000;
    bytes32 internal constant BAT_ILK = 0x4241542d41000000000000000000000000000000000000000000000000000000;

    struct CdpHolder {
        uint128 minRatio;
        uint128 maxRatio;
        uint128 optimalRatioBoost;
        uint128 optimalRatioRepay;
        address owner;
        uint cdpId;
    }

    struct SubPosition {
        uint arrPos;
        bool subscribed;
    }

    CdpHolder[] public subscribers;
    mapping (uint => SubPosition) public subscribersPos;

    mapping (bytes32 => uint) public minLimits;

    address public owner;
    uint public changeIndex;

    Manager public manager = Manager(MANAGER_ADDRESS);
    Vat public vat = Vat(VAT_ADDRESS);
    Spotter public spotter = Spotter(SPOTTER_ADDRESS);
    MCDSaverProxy public saverProxy;

    event Subscribed(address indexed owner, uint cdpId);
    event Unsubscribed(address indexed owner, uint cdpId);
    event Updated(address indexed owner, uint cdpId);

    
    constructor(address _saverProxy) public {
        owner = msg.sender;

        saverProxy = MCDSaverProxy(_saverProxy);

        minLimits[ETH_ILK] = 1700000000000000000;
        minLimits[BAT_ILK] = 1700000000000000000;
    }

    
    
    
    
    
    
    
    function subscribe(uint _cdpId, uint128 _minRatio, uint128 _maxRatio, uint128 _optimalBoost, uint128 _optimalRepay) external {
        require(isOwner(msg.sender, _cdpId), "Must be called by Cdp owner");
        require(checkParams(manager.ilks(_cdpId), _minRatio, _maxRatio), "Must be correct params");

        SubPosition storage subInfo = subscribersPos[_cdpId];

        CdpHolder memory subscription = CdpHolder({
                minRatio: _minRatio,
                maxRatio: _maxRatio,
                optimalRatioBoost: _optimalBoost,
                optimalRatioRepay: _optimalRepay,
                owner: msg.sender,
                cdpId: _cdpId
            });

        changeIndex++;

        if (subInfo.subscribed) {
            subscribers[subInfo.arrPos] = subscription;

            emit Updated(msg.sender, _cdpId);
        } else {
            subscribers.push(subscription);

            subInfo.arrPos = subscribers.length - 1;
            subInfo.subscribed = true;

            emit Subscribed(msg.sender, _cdpId);
        }
    }

    
    
    function unsubscribe(uint _cdpId) external {
        require(isOwner(msg.sender, _cdpId), "Must be called by Cdp owner");

        _unsubscribe(_cdpId);
    }

    
    function isOwner(address _owner, uint _cdpId) internal view returns (bool) {
        return getOwner(_cdpId) == _owner;
    }

    
    function checkParams(bytes32 _ilk, uint128 _minRatio, uint128 _maxRatio) internal view returns (bool) {
        if (_minRatio < minLimits[_ilk]) {
            return false;
        }

        if (_minRatio > _maxRatio) {
            return false;
        }

        return true;
    }

    
    function getRatio(uint _cdpId) public view returns (uint) {
        return saverProxy.getRatio(_cdpId, manager.ilks(_cdpId)) / (10 ** 18);
    }

    
    
    function canCall(Method _method, uint _cdpId) public view returns(bool, uint) {
        SubPosition memory subInfo = subscribersPos[_cdpId];

        if (!subInfo.subscribed) return (false, 0);

        CdpHolder memory subscriber = subscribers[subInfo.arrPos];

        if (getOwner(_cdpId) != subscriber.owner) return (false, 0);

        uint currRatio = getRatio(_cdpId);

        if (_method == Method.Repay) {
            return (currRatio < subscriber.minRatio, currRatio);
        } else if (_method == Method.Boost) {
            return (currRatio > subscriber.maxRatio, currRatio);
        }
    }

    
    function _unsubscribe(uint _cdpId) internal {
        require(subscribers.length > 0, "Must have subscribers in the list");

        SubPosition storage subInfo = subscribersPos[_cdpId];

        require(subInfo.subscribed, "Must first be subscribed");

        subscribers[subInfo.arrPos] = subscribers[subscribers.length - 1];
        delete subscribers[subscribers.length - 1];
        subscribers.length--;

        changeIndex++;
        subInfo.subscribed = false;

        emit Unsubscribed(msg.sender, _cdpId);
    }

    
    
    function getOwner(uint _cdpId) public view returns(address) {
        return manager.owns(_cdpId);
    }

    
    function ratioGoodAfter(Method _method, uint _cdpId) public view returns(bool, uint) {
        SubPosition memory subInfo = subscribersPos[_cdpId];
        CdpHolder memory subscriber = subscribers[subInfo.arrPos];

        uint currRatio = getRatio(_cdpId);

        if (_method == Method.Repay) {
            return (currRatio < subscriber.maxRatio, currRatio);
        } else if (_method == Method.Boost) {
            return (currRatio > subscriber.minRatio, currRatio);
        }
    }

    
    function getSubscribedInfo(uint _cdpId) public view returns(bool, uint128, uint128, uint128, uint128, address, uint coll, uint debt) {
        SubPosition memory subInfo = subscribersPos[_cdpId];

        if (!subInfo.subscribed) return (false, 0, 0, 0, 0, address(0), 0, 0);

        (coll, debt) = saverProxy.getCdpInfo(manager, _cdpId, manager.ilks(_cdpId));

        CdpHolder memory subscriber = subscribers[subInfo.arrPos];

        return (
            true,
            subscriber.minRatio,
            subscriber.maxRatio,
            subscriber.optimalRatioRepay,
            subscriber.optimalRatioBoost,
            subscriber.owner,
            coll,
            debt
        );
    }

    
    function getIlkInfo(bytes32 _ilk, uint _cdpId) public view returns(bytes32 ilk, uint art, uint rate, uint spot, uint line, uint dust, uint mat, uint par) {
        
        if (_ilk == bytes32(0)) {
            _ilk = manager.ilks(_cdpId);
        }

        ilk = _ilk;
        (,mat) = spotter.ilks(_ilk);
        par = spotter.par();
        (art, rate, spot, line, dust) = vat.ilks(_ilk);
    }

    
    function getSubscribers() public view returns (CdpHolder[] memory) {
        return subscribers;
    }


    

    
    function changeMinRatios(bytes32 _ilk, uint _newRatio) public {
        require(msg.sender == owner, "Must be owner");

        minLimits[_ilk] = _newRatio;
    }

    
    function unsubscribeIfMoved(uint _cdpId) public {
        require(msg.sender == owner, "Must be owner");

        SubPosition storage subInfo = subscribersPos[_cdpId];

        if (subInfo.subscribed) {
            if (getOwner(_cdpId) != subscribers[subInfo.arrPos].owner) {
                _unsubscribe(_cdpId);
            }
        }

    }
}