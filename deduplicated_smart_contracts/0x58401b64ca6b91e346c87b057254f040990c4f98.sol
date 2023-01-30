/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

// hevm: flattened sources of src/DssSpell.sol
pragma solidity =0.5.12 >=0.5.12;

////// lib/dss-interfaces/src/dapp/DSPauseAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/dapphub/ds-pause
interface DSPauseAbstract {
    function owner() external view returns (address);
    function authority() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
    function setDelay(uint256) external;
    function plans(bytes32) external view returns (bool);
    function proxy() external view returns (address);
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function drop(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

////// lib/dss-interfaces/src/dapp/DSTokenAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/dapphub/ds-token/blob/master/src/token.sol
interface DSTokenAbstract {
    function name() external view returns (bytes32);
    function symbol() external view returns (bytes32);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function approve(address) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function push(address, uint256) external;
    function pull(address, uint256) external;
    function move(address, address, uint256) external;
    function mint(uint256) external;
    function mint(address,uint) external;
    function burn(uint256) external;
    function burn(address,uint) external;
    function setName(bytes32) external;
    function authority() external view returns (address);
    function owner() external view returns (address);
    function setOwner(address) external;
    function setAuthority(address) external;
}

////// lib/dss-interfaces/src/dss/CatAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss/blob/master/src/cat.sol
interface CatAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function box() external view returns (uint256);
    function litter() external view returns (uint256);
    function ilks(bytes32) external view returns (address, uint256, uint256);
    function live() external view returns (uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function file(bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
    function bite(bytes32, address) external returns (uint256);
    function claw(uint256) external;
    function cage() external;
}
////// lib/dss-interfaces/src/dss/ChainlogAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss-chain-log
interface ChainlogAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function keys() external view returns (bytes32[] memory);
    function version() external view returns (string memory);
    function ipfs() external view returns (string memory);
    function setVersion(string calldata) external;
    function setSha256sum(string calldata) external;
    function setIPFS(string calldata) external;
    function setAddress(bytes32,address) external;
    function removeAddress(bytes32) external;
    function count() external view returns (uint256);
    function get(uint256) external view returns (bytes32,address);
    function list() external view returns (bytes32[] memory);
    function getAddress(bytes32) external view returns (address);
}

// Helper function for returning address or abstract of Chainlog
//  Valid on Mainnet, Kovan, Rinkeby, Ropsten, and Goerli
contract ChainlogHelper {
    address          public constant ADDRESS  = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;
    ChainlogAbstract public constant ABSTRACT = ChainlogAbstract(ADDRESS);
}

////// lib/dss-interfaces/src/dss/DssAutoLineAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss-auto-line/blob/master/src/DssAutoLine.sol
interface DssAutoLineAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilks(bytes32) external view returns (uint256,uint256,uint48,uint48,uint48);
    function setIlk(bytes32,uint256,uint256,uint256) external;
    function remIlk(bytes32) external;
    function exec(bytes32) external returns (uint256);
}

////// lib/dss-interfaces/src/dss/FaucetAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/token-faucet/blob/master/src/RestrictedTokenFaucet.sol
interface FaucetAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function list(address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function amt(address) external view returns (uint256);
    function done(address, address) external view returns (bool);
    function gulp(address) external;
    function gulp(address, address[] calldata) external;
    function shut(address) external;
    function undo(address, address) external;
    function setAmt(address, uint256) external;
}

////// lib/dss-interfaces/src/dss/FlipAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss/blob/master/src/flip.sol
interface FlipAbstract {
    function wards(address) external view returns (uint256);
    function rely(address usr) external;
    function deny(address usr) external;
    function bids(uint256) external view returns (uint256, uint256, address, uint48, uint48, address, address, uint256);
    function vat() external view returns (address);
    function cat() external view returns (address);
    function ilk() external view returns (bytes32);
    function beg() external view returns (uint256);
    function ttl() external view returns (uint48);
    function tau() external view returns (uint48);
    function kicks() external view returns (uint256);
    function file(bytes32, uint256) external;
    function kick(address, address, uint256, uint256, uint256) external returns (uint256);
    function tick(uint256) external;
    function tend(uint256, uint256, uint256) external;
    function dent(uint256, uint256, uint256) external;
    function deal(uint256) external;
    function yank(uint256) external;
}

////// lib/dss-interfaces/src/dss/GemJoinAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss/blob/master/src/join.sol
interface GemJoinAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function ilk() external view returns (bytes32);
    function gem() external view returns (address);
    function dec() external view returns (uint256);
    function live() external view returns (uint256);
    function cage() external;
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

////// lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/ilk-registry
interface IlkRegistryAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function vat() external view returns (address);
    function cat() external view returns (address);
    function spot() external view returns (address);
    function ilkData(bytes32) external view returns (
        uint256, address, address, address, address, uint256, string memory, string memory
    );
    function ilks() external view returns (bytes32[] memory);
    function ilks(uint) external view returns (bytes32);
    function add(address) external;
    function remove(bytes32) external;
    function update(bytes32) external;
    function removeAuth(bytes32) external;
    function file(bytes32, address) external;
    function file(bytes32, bytes32, address) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, string calldata) external;
    function count() external view returns (uint256);
    function list() external view returns (bytes32[] memory);
    function list(uint256, uint256) external view returns (bytes32[] memory);
    function get(uint256) external view returns (bytes32);
    function info(bytes32) external view returns (
        string memory, string memory, uint256, address, address, address, address
    );
    function pos(bytes32) external view returns (uint256);
    function gem(bytes32) external view returns (address);
    function pip(bytes32) external view returns (address);
    function join(bytes32) external view returns (address);
    function flip(bytes32) external view returns (address);
    function dec(bytes32) external view returns (uint256);
    function symbol(bytes32) external view returns (string memory);
    function name(bytes32) external view returns (string memory);
}

////// lib/dss-interfaces/src/dss/JugAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss/blob/master/src/jug.sol
interface JugAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) external view returns (uint256, uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function base() external view returns (address);
    function init(bytes32) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, uint256) external;
    function file(bytes32, address) external;
    function drip(bytes32) external returns (uint256);
}

////// lib/dss-interfaces/src/dss/MedianAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/median
interface MedianAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function age() external view returns (uint32);
    function wat() external view returns (bytes32);
    function bar() external view returns (uint256);
    function orcl(address) external view returns (uint256);
    function bud(address) external view returns (uint256);
    function slot(uint8) external view returns (address);
    function read() external view returns (uint256);
    function peek() external view returns (uint256, bool);
    function lift(address[] calldata) external;
    function drop(address[] calldata) external;
    function setBar(uint256) external;
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
    function poke(uint256[] calldata, uint256[] calldata, uint8[] calldata, bytes32[] calldata, bytes32[] calldata) external;
}

////// lib/dss-interfaces/src/dss/OsmAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/osm
interface OsmAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function stopped() external view returns (uint256);
    function src() external view returns (address);
    function hop() external view returns (uint16);
    function zzz() external view returns (uint64);
    function cur() external view returns (uint128, uint128);
    function nxt() external view returns (uint128, uint128);
    function bud(address) external view returns (uint256);
    function stop() external;
    function start() external;
    function change(address) external;
    function step(uint16) external;
    function void() external;
    function pass() external view returns (bool);
    function poke() external;
    function peek() external view returns (bytes32, bool);
    function peep() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
}

////// lib/dss-interfaces/src/dss/OsmMomAbstract.sol
/* pragma solidity >=0.5.12; */


// https://github.com/makerdao/osm-mom
interface OsmMomAbstract {
    function owner() external view returns (address);
    function authority() external view returns (address);
    function osms(bytes32) external view returns (address);
    function setOsm(bytes32, address) external;
    function setOwner(address) external;
    function setAuthority(address) external;
    function stop(bytes32) external;
}

////// lib/dss-interfaces/src/dss/SpotAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss/blob/master/src/spot.sol
interface SpotAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function ilks(bytes32) external view returns (address, uint256);
    function vat() external view returns (address);
    function par() external view returns (uint256);
    function live() external view returns (uint256);
    function file(bytes32, bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function poke(bytes32) external;
    function cage() external;
}

////// lib/dss-interfaces/src/dss/VatAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss/blob/master/src/vat.sol
interface VatAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function can(address, address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function urns(bytes32, address) external view returns (uint256, uint256);
    function gem(bytes32, address) external view returns (uint256);
    function dai(address) external view returns (uint256);
    function sin(address) external view returns (uint256);
    function debt() external view returns (uint256);
    function vice() external view returns (uint256);
    function Line() external view returns (uint256);
    function live() external view returns (uint256);
    function init(bytes32) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function cage() external;
    function slip(bytes32, address, int256) external;
    function flux(bytes32, address, address, uint256) external;
    function move(address, address, uint256) external;
    function frob(bytes32, address, address, address, int256, int256) external;
    function fork(bytes32, address, address, int256, int256) external;
    function grab(bytes32, address, address, address, int256, int256) external;
    function heal(uint256) external;
    function suck(address, address, uint256) external;
    function fold(bytes32, address, int256) external;
}

////// src/DssSpell.sol
// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity 0.5.12; */

/* import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol"; */
/* import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/ChainlogAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/VatAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/SpotAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/FlipAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/JugAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/CatAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/FaucetAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/OsmAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/OsmMomAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/MedianAbstract.sol"; */
/* import "lib/dss-interfaces/src/dss/DssAutoLineAbstract.sol"; */


contract SpellAction {
    // Office hours enabled if true
    bool constant public officeHours = true;

    // MAINNET ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/mainnet/active/contracts.json
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    // UNI-A
    address constant UNI               = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address constant MCD_JOIN_UNI_A    = 0x3BC3A58b4FC1CbE7e98bB4aB7c99535e8bA9b8F1;
    address constant MCD_FLIP_UNI_A    = 0xF5b8cD9dB5a0EC031304A7B815010aa7761BD426;
    address constant PIP_UNI           = 0xf363c7e351C96b910b92b45d34190650df4aE8e7;
    bytes32 constant ILK_UNI_A         = "UNI-A";

    // RENBTC-A
    address constant RENBTC            = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address constant MCD_JOIN_RENBTC_A = 0xFD5608515A47C37afbA68960c1916b79af9491D0;
    address constant MCD_FLIP_RENBTC_A = 0x30BC6eBC27372e50606880a36B279240c0bA0758;
    address constant PIP_RENBTC        = 0xf185d0682d50819263941e5f4EacC763CC5C6C42;
    bytes32 constant ILK_RENBTC_A      = "RENBTC-A";

    // DC IAM
    address constant MCD_IAM_AUTO_LINE = 0xC7Bdd1F2B16447dcf3dE045C4a039A60EC2f0ba3;

    // YEARN PROXY
    address constant YEARN_PROXY       = 0x208EfCD7aad0b5DD49438E0b6A0f38E951A50E5f;

    // decimals & precision
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant ZERO_PERCENT_RATE  = 1000000000000000000000000000;
    uint256 constant THREE_PERCENT_RATE = 1000000000937303470807876289;
    uint256 constant SIX_PERCENT_RATE   = 1000000001847694957439350562;
    uint256 constant TEN_PERCENT_RATE   = 1000000003022265980097387650;

    modifier limited {
        if (officeHours) {
            uint day = (now / 1 days + 3) % 7;
            require(day < 5, "Can only be cast on a weekday");
            uint hour = now / 1 hours % 24;
            require(hour >= 14 && hour < 21, "Outside office hours");
        }
        _;
    }

    function execute() external limited {
        address MCD_VAT      = CHANGELOG.getAddress("MCD_VAT");
        address MCD_CAT      = CHANGELOG.getAddress("MCD_CAT");
        address MCD_JUG      = CHANGELOG.getAddress("MCD_JUG");
        address MCD_SPOT     = CHANGELOG.getAddress("MCD_SPOT");
        address MCD_END      = CHANGELOG.getAddress("MCD_END");
        address FLIPPER_MOM  = CHANGELOG.getAddress("FLIPPER_MOM");
        address OSM_MOM      = CHANGELOG.getAddress("OSM_MOM"); // Only if PIP_TOKEN = Osm
        address ILK_REGISTRY = CHANGELOG.getAddress("ILK_REGISTRY");
        address PIP_YFI      = CHANGELOG.getAddress("PIP_YFI");

        //
        // Add UNI
        //

        // Sanity checks
        require(GemJoinAbstract(MCD_JOIN_UNI_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNI_A).ilk() == ILK_UNI_A, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNI_A).gem() == UNI, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_UNI_A).dec() == DSTokenAbstract(UNI).decimals(), "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_UNI_A).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_UNI_A).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_UNI_A).ilk() == ILK_UNI_A, "flip-ilk-not-match");

        // Set the UNI PIP in the Spotter
        SpotAbstract(MCD_SPOT).file(ILK_UNI_A, "pip", PIP_UNI);

        // Set the UNI-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ILK_UNI_A, "flip", MCD_FLIP_UNI_A);

        // Init UNI-A ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ILK_UNI_A);
        JugAbstract(MCD_JUG).init(ILK_UNI_A);

        // Allow UNI-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_UNI_A);
        // Allow the UNI-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_UNI_A);
        // Allow Cat to kick auctions in UNI-A Flipper
        FlipAbstract(MCD_FLIP_UNI_A).rely(MCD_CAT);
        // Allow End to yank auctions in UNI-A Flipper
        FlipAbstract(MCD_FLIP_UNI_A).rely(MCD_END);
        // Allow FlipperMom to access to the UNI-A Flipper
        FlipAbstract(MCD_FLIP_UNI_A).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in UNI-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        //FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_UNI_A);

        // Allow OsmMom to access to the UNI Osm
        // !!!!!!!! Only if PIP_UNI = Osm and hasn't been already relied due a previous deployed ilk
        OsmAbstract(PIP_UNI).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNI = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        MedianAbstract(OsmAbstract(PIP_UNI).src()).kiss(PIP_UNI);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNI = Osm or PIP_UNI = Median and hasn't been already whitelisted due a previous deployed ilk
        OsmAbstract(PIP_UNI).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_UNI = Osm or PIP_UNI = Median and hasn't been already whitelisted due a previous deployed ilk
        OsmAbstract(PIP_UNI).kiss(MCD_END);
        // Set UNI Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_UNI = Osm
        OsmMomAbstract(OSM_MOM).setOsm(ILK_UNI_A, PIP_UNI);

        // Set the UNI-A debt ceiling
        VatAbstract(MCD_VAT).file(ILK_UNI_A, "line", 15 * MILLION * RAD);
        // Set the UNI-A dust
        VatAbstract(MCD_VAT).file(ILK_UNI_A, "dust", 500 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ILK_UNI_A, "dunk", 50 * THOUSAND * RAD);
        // Set the UNI-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ILK_UNI_A, "chop", 113 * WAD / 100);
        // Set the UNI-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ILK_UNI_A, "duty", THREE_PERCENT_RATE);
        // Set the UNI-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_UNI_A).file("beg", 103 * WAD / 100);
        // Set the UNI-A time max time between bids
        FlipAbstract(MCD_FLIP_UNI_A).file("ttl", 6 hours);
        // Set the UNI-A max auction duration to
        FlipAbstract(MCD_FLIP_UNI_A).file("tau", 6 hours);
        // Set the UNI-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ILK_UNI_A, "mat", 175 * RAY / 100);

        // Update UNI-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ILK_UNI_A);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_UNI_A);

        // Update the changelog
        CHANGELOG.setAddress("UNI", UNI);
        CHANGELOG.setAddress("MCD_JOIN_UNI_A", MCD_JOIN_UNI_A);
        CHANGELOG.setAddress("MCD_FLIP_UNI_A", MCD_FLIP_UNI_A);
        CHANGELOG.setAddress("PIP_UNI", PIP_UNI);

        //
        // Add renBTC
        //

        // Add RENBTC-A ilk
        require(GemJoinAbstract(MCD_JOIN_RENBTC_A).vat() == MCD_VAT, "join-vat-not-match");
        require(GemJoinAbstract(MCD_JOIN_RENBTC_A).ilk() == ILK_RENBTC_A, "join-ilk-not-match");
        require(GemJoinAbstract(MCD_JOIN_RENBTC_A).gem() == RENBTC, "join-gem-not-match");
        require(GemJoinAbstract(MCD_JOIN_RENBTC_A).dec() == DSTokenAbstract(RENBTC).decimals(), "join-dec-not-match");
        require(FlipAbstract(MCD_FLIP_RENBTC_A).vat() == MCD_VAT, "flip-vat-not-match");
        require(FlipAbstract(MCD_FLIP_RENBTC_A).cat() == MCD_CAT, "flip-cat-not-match");
        require(FlipAbstract(MCD_FLIP_RENBTC_A).ilk() == ILK_RENBTC_A, "flip-ilk-not-match");

        SpotAbstract(MCD_SPOT).file(ILK_RENBTC_A, "pip", PIP_RENBTC);

        // Set the RENBTC-A Flipper in the Cat
        CatAbstract(MCD_CAT).file(ILK_RENBTC_A, "flip", MCD_FLIP_RENBTC_A);

        // Init RENBTC-A ilk in Vat & Jug
        VatAbstract(MCD_VAT).init(ILK_RENBTC_A);
        JugAbstract(MCD_JUG).init(ILK_RENBTC_A);

        // Allow RENBTC-A Join to modify Vat registry
        VatAbstract(MCD_VAT).rely(MCD_JOIN_RENBTC_A);
        // Allow the RENBTC-A Flipper to reduce the Cat litterbox on deal()
        CatAbstract(MCD_CAT).rely(MCD_FLIP_RENBTC_A);
        // Allow Cat to kick auctions in RENBTC-A Flipper
        FlipAbstract(MCD_FLIP_RENBTC_A).rely(MCD_CAT);
        // Allow End to yank auctions in RENBTC-A Flipper
        FlipAbstract(MCD_FLIP_RENBTC_A).rely(MCD_END);
        // Allow FlipperMom to access to the RENBTC-A Flipper
        FlipAbstract(MCD_FLIP_RENBTC_A).rely(FLIPPER_MOM);
        // Disallow Cat to kick auctions in RENBTC-A Flipper
        // !!!!!!!! Only for certain collaterals that do not trigger liquidations like USDC-A)
        // FlipperMomAbstract(FLIPPER_MOM).deny(MCD_FLIP_RENBTC_A);

        // Allow OsmMom to access to the RENBTC Osm
        // !!!!!!!! Only if PIP_RENBTC = Osm and hasn't been already relied due a previous deployed ilk
        // OsmAbstract(PIP_RENBTC).rely(OSM_MOM);
        // Whitelist Osm to read the Median data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_RENBTC = Osm, its src is a Median and hasn't been already whitelisted due a previous deployed ilk
        // MedianAbstract(OsmAbstract(PIP_RENBTC).src()).kiss(PIP_RENBTC);
        // Whitelist Spotter to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_RENBTC = Osm or PIP_RENBTC = Median and hasn't been already whitelisted due a previous deployed ilk
        // OsmAbstract(PIP_RENBTC).kiss(MCD_SPOT);
        // Whitelist End to read the Osm data (only necessary if it is the first time the token is being added to an ilk)
        // !!!!!!!! Only if PIP_RENBTC = Osm or PIP_RENBTC = Median and hasn't been already whitelisted due a previous deployed ilk
        // OsmAbstract(PIP_RENBTC).kiss(MCD_END);
        // Set RENBTC Osm in the OsmMom for new ilk
        // !!!!!!!! Only if PIP_RENBTC = Osm
        OsmMomAbstract(OSM_MOM).setOsm(ILK_RENBTC_A, PIP_RENBTC);

        // Set the RENBTC-A debt ceiling
        VatAbstract(MCD_VAT).file(ILK_RENBTC_A, "line", 2 * MILLION * RAD);
        // Set the RENBTC-A dust
        VatAbstract(MCD_VAT).file(ILK_RENBTC_A, "dust", 500 * RAD);
        // Set the Lot size
        CatAbstract(MCD_CAT).file(ILK_RENBTC_A, "dunk", 50 * THOUSAND * RAD);
        // Set the RENBTC-A liquidation penalty (e.g. 13% => X = 113)
        CatAbstract(MCD_CAT).file(ILK_RENBTC_A, "chop", 113 * WAD / 100);
        // Set the RENBTC-A stability fee (e.g. 1% = 1000000000315522921573372069)
        JugAbstract(MCD_JUG).file(ILK_RENBTC_A, "duty", SIX_PERCENT_RATE);
        // Set the RENBTC-A percentage between bids (e.g. 3% => X = 103)
        FlipAbstract(MCD_FLIP_RENBTC_A).file("beg", 103 * WAD / 100);
        // Set the RENBTC-A time max time between bids
        FlipAbstract(MCD_FLIP_RENBTC_A).file("ttl", 6 hours);
        // Set the RENBTC-A max auction duration to
        FlipAbstract(MCD_FLIP_RENBTC_A).file("tau", 6 hours);
        // Set theRENBTC-A min collateralization ratio (e.g. 150% => X = 150)
        SpotAbstract(MCD_SPOT).file(ILK_RENBTC_A, "mat", 175 * RAY / 100);

        // Update RENBTC-A spot value in Vat
        SpotAbstract(MCD_SPOT).poke(ILK_RENBTC_A);

        // Add new ilk to the IlkRegistry
        IlkRegistryAbstract(ILK_REGISTRY).add(MCD_JOIN_RENBTC_A);

        // Update the changelog
        CHANGELOG.setAddress("RENBTC", RENBTC);
        CHANGELOG.setAddress("MCD_JOIN_RENBTC_A", MCD_JOIN_RENBTC_A);
        CHANGELOG.setAddress("MCD_FLIP_RENBTC_A", MCD_FLIP_RENBTC_A);
        CHANGELOG.setAddress("PIP_RENBTC", PIP_RENBTC);

        //
        // MIP27: Debt Ceiling Instant Access Module
        //

        // Give permissions to the MCD_IAM_AUTO_LINE to file() the vat
        VatAbstract(MCD_VAT).rely(MCD_IAM_AUTO_LINE);

        // Set ilks in MCD_IAM_AUTO_LINE
        DssAutoLineAbstract(MCD_IAM_AUTO_LINE).setIlk(
            "ETH-B", 50 * MILLION * RAD, 5 * MILLION * RAD, 12 hours
        );

        // Add MCD_IAM_AUTO_LINE
        CHANGELOG.setAddress("MCD_IAM_AUTO_LINE", MCD_IAM_AUTO_LINE);

        // Bump version
        CHANGELOG.setVersion("1.2.1");

        //
        // Various polling changes
        //

        // Allow yearn finance to access the YFI/USD OSM
        OsmAbstract(PIP_YFI).kiss(YEARN_PROXY);

        // Set the YFI-A debt ceiling
        //
        // Existing debt ceiling: 20 million
        // New debt ceiling: 30 million
        VatAbstract(MCD_VAT).file("YFI-A", "line", 30 * MILLION * RAD);

        // Set the YFI-A stability fee
        //
        // Previous: 4%
        // New: 10%
        JugAbstract(MCD_JUG).drip("YFI-A");
        JugAbstract(MCD_JUG).file("YFI-A", "duty", TEN_PERCENT_RATE);

        // Set the USDC-A stability fee
        //
        // Previous: 4%
        // New: 0%
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).file("USDC-A", "duty", ZERO_PERCENT_RATE);

        // Set the TUSD-A stability fee
        //
        // Previous: 4%
        // New: 0%
        JugAbstract(MCD_JUG).drip("TUSD-A");
        JugAbstract(MCD_JUG).file("TUSD-A", "duty", ZERO_PERCENT_RATE);

        // Set the PAXUSD-A stability fee
        //
        // Previous: 4%
        // New: 0%
        JugAbstract(MCD_JUG).drip("PAXUSD-A");
        JugAbstract(MCD_JUG).file("PAXUSD-A", "duty", ZERO_PERCENT_RATE);

        // Set the GUSD-A stability fee
        //
        // Previous: 4%
        // New: 0%
        JugAbstract(MCD_JUG).drip("GUSD-A");
        JugAbstract(MCD_JUG).file("GUSD-A", "duty", ZERO_PERCENT_RATE);

        // Set the global debt ceiling
        VatAbstract(MCD_VAT).file("Line", 1_608_750_000 * RAD);
    }
}

contract DssSpell {
    ChainlogAbstract constant CHANGELOG =
        ChainlogAbstract(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    address MCD_PAUSE = CHANGELOG.getAddress("MCD_PAUSE");

    DSPauseAbstract public pause = DSPauseAbstract(MCD_PAUSE);
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/1b36aea23b5baeda96a420b4afc3cd743e708b8d/governance/votes/Executive%20vote%20-%20December%2011%2C%202020.md -q -O - 2>/dev/null)"
    string constant public description =
        "2020-12-02 MakerDAO Executive Spell | Hash: 0xa2aeed0dab500692caf4fa55c99bc87b57853792de711724668012a21e9bb83a";

    function officeHours() external view returns (bool) {
        return SpellAction(action).officeHours();
    }

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function schedule() external {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() external {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}