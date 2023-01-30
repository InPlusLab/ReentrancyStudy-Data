/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity ^0.6.0;

interface TokenInterface {
    function approve(address, uint) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
}

interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function last(address) external view returns (uint);
    function count(address) external view returns (uint);
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
    function gem(bytes32, address) external view returns (uint);

}

interface TokenJoinInterface {
    function dec() external returns (uint);
    function gem() external returns (TokenInterface);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface DaiJoinInterface {
    function vat() external returns (VatLike);
    function dai() external returns (TokenInterface);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint);
}

interface PotLike {
    function pie(address) external view returns (uint);
    function drip() external returns (uint);
    function join(uint) external;
    function exit(uint) external;
}

interface MemoryInterface {
    function getUint(uint _id) external returns (uint _num);
    function setUint(uint _id, uint _val) external;
}

interface InstaMapping {
    function gemJoinMapping(bytes32) external view returns (address);
}

interface EventInterface {
    function emitEvent(uint _connectorType, uint _connectorID, bytes32 _eventCode, bytes calldata _eventData) external;
}

contract DSMath {

    uint256 constant RAY = 10 ** 27;
    uint constant WAD = 10 ** 18;

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

    function convertTo18(address colAddr, uint256 _amt) internal returns (uint256 amt) {
        amt = mul(
            _amt,
            10 ** (18 - TokenJoinInterface(colAddr).dec())
        );
    }
}


contract Helpers is DSMath {
    /**
     * @dev Return ETH Address.
     */
    function getAddressETH() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    /**
     * @dev Return WETH Address.
     */
    function getAddressWETH() internal pure returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }

    /**
     * @dev Return InstAaMemory Address.
     */
    function getMemoryAddr() internal pure returns (address) {
        return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F;
    }

    /**
     * @dev Return InstaEvent Address.
     */
    function getEventAddr() internal pure returns (address) {
        return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97;
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
     * @dev Connector Details
    */
    function connectorID() public pure returns(uint _type, uint _id) {
        (_type, _id) = (1, 4);
    }
}


contract MakerMCDAddresses is Helpers {
    /**
     * @dev Return Maker MCD Manager Address.
    */
    function getMcdManager() internal pure returns (address) {
        return 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    }

    /**
     * @dev Return Maker MCD DAI Address.
    */
    function getMcdDai() internal pure returns (address) {
        return 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    /**
     * @dev Return Maker MCD DAI_Join Address.
    */
    function getMcdDaiJoin() internal pure returns (address) {
        return 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    }

    /**
     * @dev Return Maker MCD Jug Address.
    */
    function getMcdJug() internal pure returns (address) {
        return 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    }

    /**
     * @dev Return Maker MCD Pot Address.
    */
    function getMcdPot() internal pure returns (address) {
        return 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    }
}

contract MakerHelpers is MakerMCDAddresses {
    /**
     * @dev Return InstaMapping Address.
     */
    function getMappingAddr() internal pure returns (address) {
        return 0xe81F70Cc7C0D46e12d70efc60607F16bbD617E88;
    }

    /**
     * @dev Return Close Vault Address.
    */
    function getGiveAddress() internal pure returns (address) {
        return 0x4dD58550eb15190a5B3DfAE28BB14EeC181fC267;
    }

    /**
     * @dev Get Vault's ilk.
    */
    function getVaultData(address manager, uint vault) internal view returns (bytes32 ilk, address urn) {
        ilk = ManagerLike(manager).ilks(vault);
        urn = ManagerLike(manager).urns(vault);
    }

    /**
     * @dev Gem Join address is ETH type collateral.
    */
    function isEth(address tknAddr) internal pure returns (bool) {
        return tknAddr == getAddressWETH() ? true : false;
    }

    /**
     * @dev Maker MCD flux.
    */
    function flux(uint vault, address dst, uint wad) internal {
        ManagerLike(getMcdManager()).flux(vault, dst, wad);
    }

    /**
     * @dev Maker MCD move.
    */
    function move(uint vault, address dst, uint rad) internal {
        ManagerLike(getMcdManager()).move(vault, dst, rad);
    }

    /**
     * @dev Maker MCD frob.
    */
    function frob(uint vault, int dink, int dart) internal {
        ManagerLike(getMcdManager()).frob(vault, dink, dart);
    }

    /**
     * @dev Get Vault Debt Amount.
    */
    function _getVaultDebt(
        address vat,
        bytes32 ilk,
        address urn
    ) internal view returns (uint debt) {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);
        debt = rmul(rate, art);

    }

    /**
     * @dev Get Borrow Amount.
    */
    function _getBorrowAmt(
        address vat,
        address urn,
        bytes32 ilk,
        uint amt
    ) internal returns (int dart)
    {
        address jug = getMcdJug();
        uint rate = JugLike(jug).drip(ilk);
        uint dai = VatLike(vat).dai(urn);
        if (dai < mul(amt, RAY)) {
            dart = toInt(sub(mul(amt, RAY), dai) / rate);
            dart = mul(uint(dart), rate) < mul(amt, RAY) ? dart + 1 : dart;
        }
    }

    /**
     * @dev Get Payback Amount.
    */
    function _getWipeAmt(
        address vat,
        uint amt,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart)
    {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);
        dart = toInt(amt / rate);
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    /**
     * @dev Convert String to bytes32.
    */
    function stringToBytes32(string memory str) internal pure returns (bytes32 result) {
        require(bytes(str).length != 0, "String-Empty");
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            result := mload(add(str, 32))
        }
    }

    /**
     * @dev Get vault ID. If `vault` is 0, get last opened vault.
    */
    function getVault(address manager, uint vault) internal view returns (uint _vault) {
        if (vault == 0) {
            require(ManagerLike(manager).count(address(this)) > 0, "No-Vault-Opened");
            _vault = ManagerLike(manager).last(address(this));
        } else {
            _vault = vault;
        }
    }
}


contract BasicResolver is MakerHelpers {
    event LogOpen(uint256 indexed vault, bytes32 indexed ilk);
    event LogClose(uint256 indexed vault, bytes32 indexed ilk);
    event LogDeposit(uint256 indexed vault, bytes32 indexed ilk, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogWithdraw(uint256 indexed vault, bytes32 indexed ilk, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogBorrow(uint256 indexed vault, bytes32 indexed ilk, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogPayback(uint256 indexed vault, bytes32 indexed ilk, uint256 tokenAmt, uint256 getId, uint256 setId);

    /**
     * @dev Open Vault
     * @param colType Type of Collateral.(eg: 'ETH-A')
    */
    function open(string calldata colType) external payable returns (uint vault) {
        bytes32 ilk = stringToBytes32(colType);
        require(InstaMapping(getMappingAddr()).gemJoinMapping(ilk) != address(0), "wrong-col-type");
        vault = ManagerLike(getMcdManager()).open(ilk, address(this));

        emit LogOpen(vault, ilk);
        bytes32 _eventCode = keccak256("LogOpen(uint256,bytes32)");
        bytes memory _eventParam = abi.encode(vault, ilk);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    /**
     * @dev Close Vault
     * @param vault Vault ID to close.
    */
    function close(uint vault) external payable {
        address manager = getMcdManager();
        uint _vault = getVault(manager, vault);

        (bytes32 ilk, address urn) = getVaultData(manager, _vault);

        ManagerLike managerContract = ManagerLike(manager);

        (uint ink, uint art) = VatLike(managerContract.vat()).urns(ilk, urn);
        require(ink == 0 && art == 0, "vault-assets-not-0");
        require(managerContract.owns(_vault) == address(this), "not-owner");

        managerContract.give(_vault, getGiveAddress());

        emit LogClose(_vault, ilk);
        bytes32 _eventCode = keccak256("LogClose(uint256,bytes32)");
        bytes memory _eventParam = abi.encode(_vault, ilk);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    /**
     * @dev Deposit ETH/ERC20_Token Collateral.
     * @param vault Vault ID.
     * @param amt token amount to deposit.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function deposit(
        uint vault,
        uint amt,
        uint getId,
        uint setId
    ) external payable
    {
        address manager = getMcdManager();
        uint _amt = getUint(getId, amt);
        uint _vault = getVault(manager, vault);
        (bytes32 ilk,) = getVaultData(manager, _vault);

        address colAddr = InstaMapping(getMappingAddr()).gemJoinMapping(ilk);

        TokenJoinInterface tokenJoinContract = TokenJoinInterface(colAddr);
        TokenInterface tokenContract = tokenJoinContract.gem();
        if (isEth(address(tokenContract))) {
            _amt = _amt == uint(-1) ? address(this).balance : _amt;
            tokenContract.deposit.value(_amt)();
        } else {
            _amt = _amt == uint(-1) ?  tokenContract.balanceOf(address(this)) : _amt;
        }

        tokenContract.approve(address(colAddr), _amt);
        tokenJoinContract.join(address(this), _amt);

        ManagerLike managerContract = ManagerLike(manager);
        VatLike(managerContract.vat()).frob(
            managerContract.ilks(_vault),
            managerContract.urns(_vault),
            address(this),
            address(this),
            toInt(convertTo18(colAddr, _amt)),
            0
        );

        setUint(setId, _amt);

        emit LogDeposit(_vault, ilk, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogDeposit(uint256,bytes32,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(_vault, ilk, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    /**
     * @dev Withdraw ETH/ERC20_Token Collateral.
     * @param vault Vault ID.
     * @param amt token amount to withdraw.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function withdraw(
        uint vault,
        uint amt,
        uint getId,
        uint setId
    ) external payable {
        address manager = getMcdManager();
        uint _amt = getUint(getId, amt);
        uint _vault = getVault(manager, vault);

        (bytes32 ilk, address urn) = getVaultData(manager, _vault);

        address colAddr = InstaMapping(getMappingAddr()).gemJoinMapping(ilk);

        (uint ink,) = VatLike(ManagerLike(manager).vat()).urns(ilk, urn);
        _amt = _amt == uint(-1) ? ink : _amt;
        uint _amt18 = convertTo18(colAddr, _amt);

        frob(
            _vault,
            -toInt(_amt18),
            0
        );

        flux(
            _vault,
            address(this),
            _amt18
        );

        TokenInterface tokenContract = TokenJoinInterface(colAddr).gem();
        if (isEth(address(tokenContract))) {
            TokenJoinInterface(colAddr).exit(address(this), _amt);
            tokenContract.withdraw(_amt);
        } else {
            TokenJoinInterface(colAddr).exit(address(this), _amt);
        }

        setUint(setId, _amt);

        emit LogWithdraw(_vault, ilk, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogWithdraw(uint256,bytes32,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(_vault, ilk, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    /**
     * @dev Borrow DAI.
     * @param vault Vault ID.
     * @param amt token amount to borrow.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function borrow(
        uint vault,
        uint amt,
        uint getId,
        uint setId
    ) external payable {
        address manager = getMcdManager();

        uint _amt = getUint(getId, amt);
        uint _vault = getVault(manager, vault);

        address daiJoin = getMcdDaiJoin();
        (bytes32 ilk, address urn) = getVaultData(manager, _vault);

        address vat = ManagerLike(manager).vat();

        frob(
            _vault,
            0,
            _getBorrowAmt(
                vat,
                urn,
                ilk,
                _amt
            )
        );

        move(
            _vault,
            address(this),
            toRad(_amt)
        );

        VatLike vatContract = VatLike(vat);
        if (vatContract.can(address(this), address(daiJoin)) == 0) {
            vatContract.hope(daiJoin);
        }

        DaiJoinInterface(daiJoin).exit(address(this), _amt);

        setUint(setId, _amt);

        emit LogBorrow(_vault, ilk, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogBorrow(uint256,bytes32,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(_vault, ilk, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    /**
     * @dev Payback borrowed DAI.
     * @param vault Vault ID.
     * @param amt token amount to payback.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function payback(
        uint vault,
        uint amt,
        uint getId,
        uint setId
    ) external payable {
        address manager = getMcdManager();

        uint _amt = getUint(getId, amt);
        uint _vault = getVault(manager, vault);
        (bytes32 ilk, address urn) = getVaultData(manager, _vault);

        address vat = ManagerLike(manager).vat();

        _amt = _amt == uint(-1) ? _getVaultDebt(vat, ilk, urn) : _amt;

        DaiJoinInterface daiJoinContract = DaiJoinInterface(getMcdDaiJoin());
        daiJoinContract.dai().approve(getMcdDaiJoin(), _amt);
        daiJoinContract.join(urn, _amt);

        frob(
            _vault,
            0,
            _getWipeAmt(
                vat,
                VatLike(vat).dai(urn),
                urn,
                ilk
            )
        );

        setUint(setId, _amt);

        emit LogPayback(_vault, ilk, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogPayback(uint256,bytes32,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(_vault, ilk, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }
}


contract BasicExtraResolver is BasicResolver {
    event LogWithdrawLiquidated(uint256 indexed vault, bytes32 indexed ilk, uint256 tokenAmt, uint256 getId, uint256 setId);

    /**
     * @dev Withdraw leftover ETH/ERC20_Token after Liquidation.
     * @param vault Vault ID.
     * @param amt token amount to Withdraw.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function withdrawLiquidated(
        uint vault,
        uint amt,
        uint getId,
        uint setId
    )
    external payable {
        address manager = getMcdManager();
        uint _amt = getUint(getId, amt);

        (bytes32 ilk, address urn) = getVaultData(manager, vault);
        uint colBal = VatLike(ManagerLike(manager).vat()).gem(ilk, urn);
        address colAddr = InstaMapping(getMappingAddr()).gemJoinMapping(ilk);

        _amt = _amt == uint(-1) ? colBal : _amt;

        uint _amt18 = convertTo18(colAddr, _amt);

        flux(
            vault,
            address(this),
            _amt18
        );

        TokenJoinInterface tokenJoinContract = TokenJoinInterface(colAddr);
        TokenInterface tokenContract = tokenJoinContract.gem();
        tokenJoinContract.exit(address(this), _amt);
        if (isEth(address(tokenContract))) {
            tokenContract.withdraw(_amt);
        }

        setUint(setId, _amt);

        emit LogWithdrawLiquidated(vault, ilk, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogWithdrawLiquidated(uint256,bytes32,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(vault, ilk, _amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

}

contract DsrResolver is BasicExtraResolver {
    event LogDepositDai(uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogWithdrawDai(uint256 tokenAmt, uint256 getId, uint256 setId);

    /**
     * @dev Deposit DAI in DSR.
     * @param amt DAI amount to deposit.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function depositDai(
        uint amt,
        uint getId,
        uint setId
    ) external payable {
        uint _amt = getUint(getId, amt);
        address pot = getMcdPot();
        address daiJoin = getMcdDaiJoin();
        DaiJoinInterface daiJoinContract = DaiJoinInterface(daiJoin);

        _amt = _amt == uint(-1) ?
            daiJoinContract.dai().balanceOf(address(this)) :
            _amt;

        VatLike vat = daiJoinContract.vat();
        PotLike potContract = PotLike(pot);

        uint chi = potContract.drip();

        daiJoinContract.dai().approve(daiJoin, _amt);
        daiJoinContract.join(address(this), _amt);
        if (vat.can(address(this), address(pot)) == 0) {
            vat.hope(pot);
        }
        potContract.join(mul(_amt, RAY) / chi);
        setUint(setId, _amt);

        emit LogDepositDai(_amt, getId, setId);
        bytes32 _eventCode = keccak256("LogDepositDai(uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(_amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }

    /**
     * @dev Withdraw DAI from DSR.
     * @param amt DAI amount to withdraw.
     * @param getId Get token amount at this ID from `InstaMemory` Contract.
     * @param setId Set token amount at this ID in `InstaMemory` Contract.
    */
    function withdrawDai(
        uint amt,
        uint getId,
        uint setId
    ) external payable {
        address daiJoin = getMcdDaiJoin();

        uint _amt = getUint(getId, amt);

        DaiJoinInterface daiJoinContract = DaiJoinInterface(daiJoin);
        VatLike vat = daiJoinContract.vat();
        PotLike potContract = PotLike(getMcdPot());

        uint chi = potContract.drip();
        uint pie = _amt == uint(-1) ?
            potContract.pie(address(this)) :
            mul(_amt, RAY) / chi;

        potContract.exit(pie);

        uint bal = vat.dai(address(this));
        if (vat.can(address(this), address(daiJoin)) == 0) {
            vat.hope(daiJoin);
        }
        daiJoinContract.exit(
            address(this),
            bal >= mul(_amt, RAY) ? _amt : bal / RAY
        );

        setUint(setId, _amt);

        emit LogWithdrawDai(_amt, getId, setId);
        bytes32 _eventCode = keccak256("LogWithdrawDai(uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(_amt, getId, setId);
        (uint _type, uint _id) = connectorID();
        EventInterface(getEventAddr()).emitEvent(_type, _id, _eventCode, _eventParam);
    }
}

contract ConnectMaker is DsrResolver {
    string public constant name = "MakerDao-v1";
}