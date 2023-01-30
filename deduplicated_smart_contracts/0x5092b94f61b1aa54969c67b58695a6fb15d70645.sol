/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
}

interface CdpsLike {
    function getCdpsAsc(address, address) external view returns (uint[] memory, address[] memory, bytes32[] memory);
}

interface VatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);

}

interface JugLike {
    function ilks(bytes32) external view returns (uint, uint);
    function base() external view returns (uint);
}

interface PotLike {
    function dsr() external view returns (uint);
    function pie(address) external view returns (uint);
    function chi() external view returns (uint);
}

interface SpotLike {
    function ilks(bytes32) external view returns (PipLike, uint);
}

interface PipLike {
    function peek() external view returns (bytes32, bool);
}

interface OtcInterface {
    function getPayAmount(address, address, uint) external view returns (uint);
}

interface InstaMcdAddress {
    function manager() external view returns (address);
    function dai() external view returns (address);
    function daiJoin() external view returns (address);
    function vat() external view returns (address);
    function jug() external view returns (address);
    function cat() external view returns (address);
    function gov() external view returns (address);
    function adm() external view returns (address);
    function vow() external view returns (address);
    function spot() external view returns (address);
    function pot() external view returns (address);
    function esm() external view returns (address);
    function mcdFlap() external view returns (address);
    function mcdFlop() external view returns (address);
    function mcdDeploy() external view returns (address);
    function mcdEnd() external view returns (address);
    function proxyActions() external view returns (address);
    function proxyActionsEnd() external view returns (address);
    function proxyActionsDsr() external view returns (address);
    function getCdps() external view returns (address);
    function saiTub() external view returns (address);
    function weth() external view returns (address);
    function bat() external view returns (address);
    function sai() external view returns (address);
    function ethAJoin() external view returns (address);
    function ethAFlip() external view returns (address);
    function batAJoin() external view returns (address);
    function batAFlip() external view returns (address);
    function ethPip() external view returns (address);
    function batAPip() external view returns (address);
    function saiJoin() external view returns (address);
    function saiFlip() external view returns (address);
    function saiPip() external view returns (address);
    function migration() external view returns (address payable);
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

}


contract Helpers is DSMath {
    /**
     * @dev get MakerDAO MCD Address contract
     */
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0; 
    }

    /**
     * @dev get OTC Address
     */
    function getOtcAddress() public pure returns (address otcAddr) {
        otcAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; // main
    }

    address public mkrAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; 

    struct CdpData {
        uint id;
        address owner;
        bytes32 ilk;
        uint ink;
        uint art;
        uint debt;
        uint stabiltyRate;
        uint price;
        uint liqRatio;
        address urn;
    }

}


contract McdResolver is Helpers {
    function getDsr() external view returns (uint dsr) {
        address pot = InstaMcdAddress(getMcdAddresses()).pot();
        dsr = PotLike(pot).dsr();
    }

    function getDaiDeposited(address owner) external view returns (uint amt) {
        address pot = InstaMcdAddress(getMcdAddresses()).pot();
        uint chi = PotLike(pot).chi();
        uint pie = PotLike(pot).pie(owner);
        amt = rmul(pie,chi);
    }

    function getCdpsByAddress(address owner) external view returns (CdpData[] memory) {
        (uint[] memory ids, address[] memory urns, bytes32[] memory ilks) = CdpsLike(InstaMcdAddress(getMcdAddresses()).getCdps()).getCdpsAsc(InstaMcdAddress(getMcdAddresses()).manager(), owner);
        CdpData[] memory cdps = new CdpData[](ids.length);

        for (uint i = 0; i < ids.length; i++) {
            (uint ink, uint art) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).urns(ilks[i], urns[i]);
            (,uint rate, uint priceMargin,,) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).ilks(ilks[i]);
            uint mat = getIlkRatio(ilks[i]);
            uint debt = rmul(art,rate);
            uint price = rmul(priceMargin, mat);

            cdps[i] = CdpData(
                ids[i],
                owner,
                ilks[i],
                ink,
                art,
                debt,
                getFee(ilks[i]),
                price,
                mat,
                urns[i]
            );
        }
        return cdps;
    }

    function getCdpsById(uint id) external view returns (CdpData memory) {
        address urn = ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).urns(id);
        bytes32 ilk = ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).ilks(id);
        address owner = ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).owns(id);

        (uint ink, uint art) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).urns(ilk, urn);
        (,uint rate, uint priceMargin,,) = VatLike(ManagerLike(InstaMcdAddress(getMcdAddresses()).manager()).vat()).ilks(ilk);
        uint debt = rmul(art,rate);

        uint mat = getIlkRatio(ilk);
        uint price = rmul(priceMargin, mat);

        uint feeRate = getFee(ilk);
        CdpData memory cdp = CdpData(
            id,
            owner,
            ilk,
            ink,
            art,
            debt,
            feeRate,
            price,
            mat,
            urn
        );
        return cdp;
    }

    function getFee(bytes32 ilk) public view returns (uint fee) {
        address jug = InstaMcdAddress(getMcdAddresses()).jug();
        (uint duty,) = JugLike(jug).ilks(ilk);
        uint base = JugLike(jug).base();
        fee = add(duty, base);
    }

    function getIlkPrice(bytes32 ilk) public view returns (uint price) {
        address spot = InstaMcdAddress(getMcdAddresses()).spot();
        address vat = InstaMcdAddress(getMcdAddresses()).vat();
        (, uint mat) = SpotLike(spot).ilks(ilk);
        (,,uint spotPrice,,) = VatLike(vat).ilks(ilk);
        price = rmul(mat, spotPrice);
    }

    function getIlkRatio(bytes32 ilk) public view returns (uint ratio) {
        address spot = InstaMcdAddress(getMcdAddresses()).spot();
        (, ratio) = SpotLike(spot).ilks(ilk);
    }

    function getMkrToTknAmt(address tokenAddr, uint mkrAmt) public view returns (uint tknAmt) {
        tknAmt = OtcInterface(getOtcAddress()).getPayAmount(tokenAddr, address(mkrAddr), mkrAmt);
    }
}