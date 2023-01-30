/**
 *Submitted for verification at Etherscan.io on 2019-09-01
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract ProtocolInterface {
    function deposit(address _user, uint _amount) public;
    function withdraw(address _user, uint _amount) public;
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

contract ITokenInterface is ERC20 {

    function assetBalanceOf(address _owner) public view returns(uint256);
    function mint(address receiver, uint256 depositAmount) external returns(uint256 mintAmount);
    function burn(address receiver, uint256 burnAmount) external returns(uint256 loanAmountPaid);
    function balanceOf(address _owner) external view returns (uint balance);
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
    address public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;
    address public constant LOGGER_ADDRESS = 0xeCf88e1ceC2D2894A0295DB3D86Fe7CE4991E6dF;
    address public constant OTC_ADDRESS = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;

    address public constant KYBER_WRAPPER = 0xAae7ba823679889b12f71D1f18BEeCBc69E62237;
    address public constant UNISWAP_WRAPPER = 0x0aa70981311D60a9521C99cecFDD68C3E5a83B83;
    address public constant ETH2DAI_WRAPPER = 0xd7BBB1777E13b6F535Dec414f575b858ed300baF;

    address public constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    address public constant UNISWAP_FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;
    address public constant PIP_INTERFACE_ADDRESS = 0x729D19f657BD0614b4985Cf1D82531c67569197B;

    // Kovan addresses, don't have mainnet
    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x64A436ae831C1672AE81F674CAb8B6775df3475C;
    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000170CcC93903185bE5A2094C870Df62;

    // Kovan addresses, not used on mainnet
    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;
    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;
}

contract ConstantAddresses is ConstantAddressesMainnet {
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


contract FulcrumSavingsProtocol is ProtocolInterface, ConstantAddresses, DSAuth {

    address public savingsProxy;

    function addSavingsProxy(address _savingsProxy) public auth {
        savingsProxy = _savingsProxy;
    }

    function deposit(address _user, uint _amount) public {
        require(msg.sender == _user);

        // get dai from user
        require(ERC20(MAKER_DAI_ADDRESS).transferFrom(_user, address(this), _amount));

        // approve dai to Fulcrum
        ERC20(MAKER_DAI_ADDRESS).approve(IDAI_ADDRESS, uint(-1));

        // mint iDai
        ITokenInterface(IDAI_ADDRESS).mint(_user, _amount);
    }

    function withdraw(address _user, uint _amount) public {
        require(msg.sender == _user);

        // transfer all users tokens to our contract
        require(ERC20(IDAI_ADDRESS).transferFrom(_user, address(this), ITokenInterface(IDAI_ADDRESS).balanceOf(_user)));

        // approve iDai to that contract
        ERC20(IDAI_ADDRESS).approve(IDAI_ADDRESS, uint(-1));

        // get dai from iDai contract
        ITokenInterface(IDAI_ADDRESS).burn(_user, _amount);

        // return all remaining tokens back to user
        require(ERC20(IDAI_ADDRESS).transfer(_user, ITokenInterface(IDAI_ADDRESS).balanceOf(address(this))));
    }
}