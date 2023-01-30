/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity ^0.5.0;


contract DSGuard {
    function canCall(address src_, address dst_, bytes4 sig) public view returns (bool);

    function permit(bytes32 src, bytes32 dst, bytes32 sig) public;
    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public;

    function permit(address src, address dst, bytes32 sig) public;
    function forbid(address src, address dst, bytes32 sig) public;

}

contract DSGuardFactory {
    function newGuard() public returns (DSGuard guard);
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

contract TokenInterface {
    function allowance(address, address) public returns (uint);
    function balanceOf(address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
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

contract OtcInterface {
    function buyAllAmount(address, uint, address, uint) public returns (uint);

    function getPayAmount(address, address, uint) public view returns (uint);
    function getBuyAmount(address, address, uint) public view returns (uint);
}

contract ValueLike {
    function peek() public returns (uint, bool);
}

contract VoxLike {
    function par() public returns (uint);
}

contract SaiTubLike {
    function skr() public view returns (Gem);
    function gem() public view returns (Gem);
    function gov() public view returns (Gem);
    function sai() public view returns (Gem);
    function pep() public view returns (ValueLike);
    function vox() public view returns (VoxLike);
    function bid(uint) public view returns (uint);
    function ink(bytes32) public view returns (uint);
    function tag() public view returns (uint);
    function tab(bytes32) public returns (uint);
    function rap(bytes32) public returns (uint);
    function draw(bytes32, uint) public;
    function shut(bytes32) public;
    function exit(uint) public;
    function give(bytes32, address) public;
}

contract ScdMcdMigration {
    SaiTubLike public tub;
    DaiJoin public daiJoin;

    function swapSaiToDai(uint) external;
    function swapDaiToSai(uint) external;
    function migrate(bytes32) external returns (uint);
}

contract PayProxyActions is DSMath {
    function pay(
        address payable scdMcdMigration,    
        bytes32 cup,                        
        uint amount                         
    ) public {
        SaiTubLike tub = ScdMcdMigration(scdMcdMigration).tub();
        
        (uint val, bool ok) = tub.pep().peek();
        if (ok && val != 0) {
            
            uint govFee = wdiv(rmul(amount, rdiv(tub.rap(cup), tub.tab(cup))) + 1, val); 

            
            require(tub.gov().transferFrom(msg.sender, address(scdMcdMigration), govFee), "transfer-failed");
        }
    }

    function payFeeWithGem(
        address payable scdMcdMigration,    
        bytes32 cup,                        
        uint amount,                        
        address otc,                        
        address payGem                      
    ) public {
        SaiTubLike tub = ScdMcdMigration(scdMcdMigration).tub();
        
        (uint val, bool ok) = tub.pep().peek();
        if (ok && val != 0) {
            
            uint govFee = wdiv(rmul(amount, rdiv(tub.rap(cup), tub.tab(cup))) + 1, val); 
            
            uint payAmt = OtcInterface(otc).getPayAmount(payGem, address(tub.gov()), govFee);
            
            if (Gem(payGem).allowance(address(this), otc) < payAmt) {
                Gem(payGem).approve(otc, payAmt);
            }
            
            require(Gem(payGem).transferFrom(msg.sender, address(this), payAmt), "transfer-failed");
            
            OtcInterface(otc).buyAllAmount(address(tub.gov()), govFee, payGem, payAmt);
            
            require(tub.gov().transfer(address(scdMcdMigration), govFee), "transfer-failed");
        }
    }

    function _getRatio(
        SaiTubLike tub,
        bytes32 cup
    ) internal returns (uint ratio) {
        ratio = rdiv(
                        rmul(tub.tag(), tub.ink(cup)),
                        rmul(tub.vox().par(), tub.tab(cup))
                    );
    }

    function payFeeWithDebt(
        address payable scdMcdMigration,    
        bytes32 cup,                        
        uint amount,                        
        address otc,                        
        uint minRatio                       
    ) public {
        SaiTubLike tub = ScdMcdMigration(scdMcdMigration).tub();
        
        (uint val, bool ok) = tub.pep().peek();
        if (ok && val != 0) {
            
            uint govFee = wdiv(rmul(amount, rdiv(tub.rap(cup), tub.tab(cup))) + 1, val); 
            
            uint payAmt = OtcInterface(otc).getPayAmount(address(tub.sai()), address(tub.gov()), govFee);

            
            tub.draw(cup, payAmt);

            require(_getRatio(tub, cup) > minRatio, "minRatio-failed");

            
            if (Gem(address(tub.sai())).allowance(address(this), otc) < payAmt) {
                Gem(address(tub.sai())).approve(otc, payAmt);
            }
            
            OtcInterface(otc).buyAllAmount(address(tub.gov()), govFee, address(tub.sai()), payAmt);
            
            govFee = wdiv(tub.rap(cup), val);
            require(tub.gov().transfer(address(scdMcdMigration), govFee), "transfer-failed");
        }
    }
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
    function bid(uint wad) public view returns (uint);
}

contract DSProxyInterface {
    function execute(bytes memory _code, bytes memory _data) public payable returns (address, bytes32);

    function execute(address _target, bytes memory _data) public payable returns (bytes32);

    function setCache(address _cacheAddr) public payable returns (bool);

    function owner() public returns (address);
}

contract ProxyRegistryInterface {
    function proxies(address _owner) public view returns(DSProxyInterface);
    function build(address) public returns (address);
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

contract GasTokenInterface is ERC20 {
    function free(uint256 value) public returns (bool success);
    function freeUpTo(uint256 value) public returns (uint256 freed);
    function freeFrom(address from, uint256 value) public returns (bool success);
    function freeFromUpTo(address from, uint256 value) public returns (uint256 freed);
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

    
    address public constant SUBSCRIPTION_ADDRESS = 0x05A78A2a1Afeb699d73363D096659B53D3B1969E;
    address public constant MONITOR_ADDRESS = 0x3F4339816EDEF8D3d3970DB2993e2e0Ec6010760;

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

contract Monitor is DSMath, ConstantAddresses {

    
    PipInterface pip = PipInterface(PIP_INTERFACE_ADDRESS);
    TubInterface tub = TubInterface(TUB_ADDRESS);
    ProxyRegistryInterface registry = ProxyRegistryInterface(PROXY_REGISTRY_INTERFACE_ADDRESS);
    GasTokenInterface gasToken = GasTokenInterface(GAS_TOKEN_INTERFACE_ADDRESS);

    uint constant public REPAY_GAS_TOKEN = 30;
    uint constant public BOOST_GAS_TOKEN = 19;

    uint constant public MAX_GAS_PRICE = 40000000000; 

    uint constant public REPAY_GAS_COST = 1500000;
    uint constant public BOOST_GAS_COST = 750000;

    address public saverProxy;
    address public owner;
    uint public changeIndex;

    struct CdpHolder {
        uint minRatio;
        uint maxRatio;
        uint optimalRatioBoost;
        uint optimalRatioRepay;
        address owner;
    }

    mapping(bytes32 => CdpHolder) public holders;

    
    mapping(address => bool) public approvedCallers;

    event Subscribed(address indexed owner, bytes32 cdpId);
    event Unsubscribed(address indexed owner, bytes32 cdpId);
    event Updated(address indexed owner, bytes32 cdpId);

    event CdpRepay(bytes32 indexed cdpId, address caller, uint _amount, uint _ratioBefore, uint _ratioAfter);
    event CdpBoost(bytes32 indexed cdpId, address caller, uint _amount, uint _ratioBefore, uint _ratioAfter);

    modifier onlyApproved() {
        require(approvedCallers[msg.sender]);
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor(address _saverProxy) public {
        approvedCallers[msg.sender] = true;
        owner = msg.sender;

        saverProxy = _saverProxy;
        changeIndex = 0;
    }

    
    
    
    
    
    
    function subscribe(bytes32 _cdpId, uint _minRatio, uint _maxRatio, uint _optimalRatioBoost, uint _optimalRatioRepay) public {
        require(isOwner(msg.sender, _cdpId));

        bool isCreated = holders[_cdpId].owner == address(0) ? true : false;

        holders[_cdpId] = CdpHolder({
            minRatio: _minRatio,
            maxRatio: _maxRatio,
            optimalRatioBoost: _optimalRatioBoost,
            optimalRatioRepay: _optimalRatioRepay,
            owner: msg.sender
        });

        changeIndex++;

        if (isCreated) {
            emit Subscribed(msg.sender, _cdpId);
        } else {
            emit Updated(msg.sender, _cdpId);
        }
    }

    
    
    function unsubscribe(bytes32 _cdpId) public {
        require(isOwner(msg.sender, _cdpId));

        delete holders[_cdpId];

        changeIndex++;

        emit Unsubscribed(msg.sender, _cdpId);
    }

    
    
    
    
    function repayFor(bytes32 _cdpId, uint _amount) public onlyApproved {
        if (gasToken.balanceOf(address(this)) >= BOOST_GAS_TOKEN) {
            gasToken.free(BOOST_GAS_TOKEN);
        }

        CdpHolder memory holder = holders[_cdpId];
        uint ratioBefore = getRatio(_cdpId);

        require(holder.owner != address(0));
        require(ratioBefore <= holders[_cdpId].minRatio);

        uint gasCost = calcGasCost(REPAY_GAS_COST);

        DSProxyInterface(holder.owner).execute(saverProxy, abi.encodeWithSignature("repay(bytes32,uint256,uint256)", _cdpId, _amount, gasCost));

        uint ratioAfter = getRatio(_cdpId);

        require(ratioAfter > holders[_cdpId].minRatio);
        require(ratioAfter < holders[_cdpId].maxRatio);

        emit CdpRepay(_cdpId, msg.sender, _amount, ratioBefore, ratioAfter);
    }

    
    
    
    
    function boostFor(bytes32 _cdpId, uint _amount) public onlyApproved {
        if (gasToken.balanceOf(address(this)) >= REPAY_GAS_TOKEN) {
            gasToken.free(REPAY_GAS_TOKEN);
        }

        CdpHolder memory holder = holders[_cdpId];
        uint ratioBefore = getRatio(_cdpId);

        require(holder.owner != address(0));

        require(ratioBefore >= holders[_cdpId].maxRatio);

        uint gasCost = calcGasCost(BOOST_GAS_COST);

        DSProxyInterface(holder.owner).execute(saverProxy, abi.encodeWithSignature("boost(bytes32,uint256,uint256)", _cdpId, _amount, gasCost));

        uint ratioAfter = getRatio(_cdpId);

        require(ratioAfter > holders[_cdpId].minRatio);
        require(ratioAfter < holders[_cdpId].maxRatio);

        emit CdpBoost(_cdpId, msg.sender, _amount, ratioBefore, ratioAfter);
    }


    
    
    function getRatio(bytes32 _cdpId) public returns(uint) {
        return (rdiv(rmul(rmul(tub.ink(_cdpId), tub.tag()), WAD), tub.tab(_cdpId)));
    }

    
    
    
    function isOwner(address _owner, bytes32 _cdpId) internal view returns(bool) {
        require(tub.lad(_cdpId) == _owner);

        return true;
    }

    
    
    
    function calcGasCost(uint _gasAmount) internal view returns (uint) {
        uint gasPrice = tx.gasprice <= MAX_GAS_PRICE ? tx.gasprice : MAX_GAS_PRICE;

        return mul(gasPrice, _gasAmount);
    }


    

    
    
    function addCaller(address _caller) public onlyOwner {
        approvedCallers[_caller] = true;
    }

    
    
    function removeCaller(address _caller) public onlyOwner {
        approvedCallers[_caller] = false;
    }

    
    
    
    
    function transferERC20(address _tokenAddress, address _to, uint _amount) public onlyOwner {
        ERC20(_tokenAddress).transfer(_to, _amount);
    }

    
    
    
    function transferEth(address payable _to, uint _amount) public onlyOwner {
        _to.transfer(_amount);
    }
 }

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

contract PartialMigrationProxy is PayProxyActions, ConstantAddresses {

    enum MigrationType { WITH_MKR, WITH_CONVERSION, WITH_DEBT }

    function migratePart(bytes32 _cup, uint _ethAmount, uint _saiAmount, uint _minRatio, MigrationType _type, uint _currentVault) external {
        TubInterface tub = TubInterface(TUB_ADDRESS);
        Manager manager = Manager(MANAGER_ADDRESS);

        
        uint ink = rdiv(_ethAmount, tub.per());
        tub.free(_cup, ink);

        tub.exit(ink);
        tub.gem().withdraw(_ethAmount);

        
        bytes32 newCup = tub.open();
        lock(tub, newCup, _ethAmount);
        draw(tub, newCup, _saiAmount);

        
        if (_type == MigrationType.WITH_MKR) {
            pay(SCD_MCD_MIGRATION, _cup, _saiAmount);
        } else if (_type == MigrationType.WITH_CONVERSION) {
            payFeeWithGem(SCD_MCD_MIGRATION, _cup, _saiAmount, OTC_ADDRESS, MAKER_DAI_ADDRESS);
        } else if (_type == MigrationType.WITH_DEBT) {
            payFeeWithDebt(SCD_MCD_MIGRATION, _cup, _saiAmount, OTC_ADDRESS, _minRatio);
        }

        tub.wipe(_cup, _saiAmount);

        
        uint vaultId = migrate(newCup, tub);

        if (_currentVault > 0) {
            manager.shift(vaultId, _currentVault);
            
            manager.give(vaultId, WALLET_ID);
        }
    }

        
    function migrate(bytes32 _cdpId, TubInterface _tub) private returns(uint) {
        DSGuard guard = getDSGuard();

        _tub.give(_cdpId, address(SCD_MCD_MIGRATION));
        uint newCdpId = ScdMcdMigration(SCD_MCD_MIGRATION).migrate(_cdpId);

        
        guard.forbid(MONITOR_ADDRESS, address(this), bytes4(keccak256("execute(address,bytes)")));

        return newCdpId;
    }

    function draw(TubInterface tub, bytes32 cup, uint wad) private {
        if (wad > 0) {
            tub.draw(cup, wad);
        }
    }

    function lock(TubInterface tub, bytes32 cup, uint value) private {
        if (value > 0) {

            tub.gem().deposit.value(value)();

            uint ink = rdiv(value, tub.per());
            if (tub.gem().allowance(address(this), address(tub)) != uint(-1)) {
                tub.gem().approve(address(tub), uint(-1));
            }
            tub.join(ink);

            if (tub.skr().allowance(address(this), address(tub)) != uint(-1)) {
                tub.skr().approve(address(tub), uint(-1));
            }
            tub.lock(cup, ink);
        }
    }

    function getDSGuard() internal view returns (DSGuard) {
        DSProxy proxy = DSProxy(address(uint160(address(this))));
        DSAuth auth = DSAuth(address(proxy.authority));

        return DSGuard(address(auth));
    }
}