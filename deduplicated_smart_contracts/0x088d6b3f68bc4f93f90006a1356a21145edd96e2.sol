/**
 *Submitted for verification at Etherscan.io on 2021-03-01
*/

// hevm: flattened sources of src/DssSpell.sol
pragma solidity =0.6.11 >=0.5.12 >=0.6.11 <0.7.0;

////// lib/dss-exec-lib/src/CollateralOpts.sol
/* pragma solidity ^0.6.11; */

struct CollateralOpts {
    bytes32 ilk;
    address gem;
    address join;
    address flip;
    address pip;
    bool    isLiquidatable;
    bool    isOSM;
    bool    whitelistOSM;
    uint256 ilkDebtCeiling;
    uint256 minVaultAmount;
    uint256 maxLiquidationAmount;
    uint256 liquidationPenalty;
    uint256 ilkStabilityFee;
    uint256 bidIncrease;
    uint256 bidDuration;
    uint256 auctionDuration;
    uint256 liquidationRatio;
}

////// lib/dss-exec-lib/src/DssExecLib.sol
//
// DssExecLib.sol -- MakerDAO Executive Spellcrafting Library
//
// Copyright (C) 2020 Maker Ecosystem Growth Holdings, Inc.
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
/* pragma solidity ^0.6.11; */

interface Initializable {
    function init(bytes32) external;
}

interface Authorizable {
    function rely(address) external;
    function deny(address) external;
}

interface Fileable {
    function file(bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
}

interface Drippable {
    function drip() external returns (uint256);
    function drip(bytes32) external returns (uint256);
}

interface Pricing {
    function poke(bytes32) external;
}

interface ERC20 {
    function decimals() external returns (uint8);
}

interface DssVat {
    function hope(address) external;
    function nope(address) external;
    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
    function Line() external view returns (uint256);
    function suck(address, address, uint) external;
}

interface AuctionLike {
    function vat() external returns (address);
    function cat() external returns (address); // Only flip
    function beg() external returns (uint256);
    function pad() external returns (uint256); // Only flop
    function ttl() external returns (uint256);
    function tau() external returns (uint256);
    function ilk() external returns (bytes32); // Only flip
    function gem() external returns (bytes32); // Only flap/flop
}

interface JoinLike {
    function vat() external returns (address);
    function ilk() external returns (bytes32);
    function gem() external returns (address);
    function dec() external returns (uint256);
    function join(address, uint) external;
    function exit(address, uint) external;
}

// Includes Median and OSM functions
interface OracleLike_2 {
    function src() external view returns (address);
    function lift(address[] calldata) external;
    function drop(address[] calldata) external;
    function setBar(uint256) external;
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
}

interface MomLike {
    function setOsm(bytes32, address) external;
}

interface RegistryLike {
    function add(address) external;
    function info(bytes32) external view returns (
        string memory, string memory, uint256, address, address, address, address
    );
    function ilkData(bytes32) external view returns (
        uint256       pos,
        address       gem,
        address       pip,
        address       join,
        address       flip,
        uint256       dec,
        string memory name,
        string memory symbol
    );
}

// https://github.com/makerdao/dss-chain-log
interface ChainlogLike {
    function setVersion(string calldata) external;
    function setIPFS(string calldata) external;
    function setSha256sum(string calldata) external;
    function getAddress(bytes32) external view returns (address);
    function setAddress(bytes32, address) external;
    function removeAddress(bytes32) external;
}

interface IAMLike {
    function ilks(bytes32) external view returns (uint256,uint256,uint48,uint48,uint48);
    function setIlk(bytes32,uint256,uint256,uint256) external;
    function remIlk(bytes32) external;
    function exec(bytes32) external returns (uint256);
}

library DssExecLib {

    // Function stubs - check the actual library address for implementations
    function dai()        public view returns (address) {}
    function mkr()        public view returns (address) {}
    function vat()        public view returns (address) {}
    function cat()        public view returns (address) {}
    function jug()        public view returns (address) {}
    function pot()        public view returns (address) {}
    function vow()        public view returns (address) {}
    function end()        public view returns (address) {}
    function reg()        public view returns (address) {}
    function spotter()    public view returns (address) {}
    function flap()       public view returns (address) {}
    function flop()       public view returns (address) {}
    function osmMom()     public view returns (address) {}
    function govGuard()   public view returns (address) {}
    function flipperMom() public view returns (address) {}
    function pauseProxy() public view returns (address) {}
    function autoLine()   public view returns (address) {}
    function daiJoin()    public view returns (address) {}
    function flip(bytes32 ilk) public view returns (address _flip) {
    }
    function getChangelogAddress(bytes32 key) public view returns (address) {
    }
    function setChangelogAddress(bytes32 _key, address _val) public {
    }
    function setChangelogVersion(string memory _version) public {
    }
    function setChangelogIPFS(string memory _ipfsHash) public {
    }
    function setChangelogSHA256(string memory _SHA256Sum) public {
    }
    function authorize(address _base, address _ward) public {
    }
    function deauthorize(address _base, address _ward) public {
    }
    function delegateVat(address _usr) public {
    }
    function undelegateVat(address _usr) public {
    }
    function accumulateDSR() public {
    }
    function accumulateCollateralStabilityFees(bytes32 _ilk) public {
    }
    function updateCollateralPrice(bytes32 _ilk) public {
    }
    function setContract(address _base, bytes32 _what, address _addr) public {
    }
    function setContract(address _base, bytes32 _ilk, bytes32 _what, address _addr) public {
    }
    function setGlobalDebtCeiling(uint256 _amount) public {
    }
    function increaseGlobalDebtCeiling(uint256 _amount) public {
    }
    function decreaseGlobalDebtCeiling(uint256 _amount) public {
    }
    function setDSR(uint256 _rate) public {
    }
    function setSurplusAuctionAmount(uint256 _amount) public {
    }
    function setSurplusBuffer(uint256 _amount) public {
    }
    function setMinSurplusAuctionBidIncrease(uint256 _pct_bps) public {
    }
    function setSurplusAuctionBidDuration(uint256 _duration) public {
    }
    function setSurplusAuctionDuration(uint256 _duration) public {
    }
    function setDebtAuctionDelay(uint256 _duration) public {
    }
    function setDebtAuctionDAIAmount(uint256 _amount) public {
    }
    function setDebtAuctionMKRAmount(uint256 _amount) public {
    }
    function setMinDebtAuctionBidIncrease(uint256 _pct_bps) public {
    }
    function setDebtAuctionBidDuration(uint256 _duration) public {
    }
    function setDebtAuctionDuration(uint256 _duration) public {
    }
    function setDebtAuctionMKRIncreaseRate(uint256 _pct_bps) public {
    }
    function setMaxTotalDAILiquidationAmount(uint256 _amount) public {
    }
    function setEmergencyShutdownProcessingTime(uint256 _duration) public {
    }
    function setGlobalStabilityFee(uint256 _rate) public {
    }
    function setDAIReferenceValue(uint256 _value) public {
    }
    function setIlkDebtCeiling(bytes32 _ilk, uint256 _amount) public {
    }
    function increaseIlkDebtCeiling(bytes32 _ilk, uint256 _amount, bool _global) public {
    }
    function decreaseIlkDebtCeiling(bytes32 _ilk, uint256 _amount, bool _global) public {
    }
    function setIlkAutoLineParameters(bytes32 _ilk, uint256 _amount, uint256 _gap, uint256 _ttl) public {
    }
    function setIlkAutoLineDebtCeiling(bytes32 _ilk, uint256 _amount) public {
    }
    function removeIlkFromAutoLine(bytes32 _ilk) public {
    }
    function setIlkMinVaultAmount(bytes32 _ilk, uint256 _amount) public {
    }
    function setIlkLiquidationPenalty(bytes32 _ilk, uint256 _pct_bps) public {
    }
    function setIlkMaxLiquidationAmount(bytes32 _ilk, uint256 _amount) public {
    }
    function setIlkLiquidationRatio(bytes32 _ilk, uint256 _pct_bps) public {
    }
    function setIlkMinAuctionBidIncrease(bytes32 _ilk, uint256 _pct_bps) public {
    }
    function setIlkBidDuration(bytes32 _ilk, uint256 _duration) public {
    }
    function setIlkAuctionDuration(bytes32 _ilk, uint256 _duration) public {
    }
    function setIlkStabilityFee(bytes32 _ilk, uint256 _rate, bool _doDrip) public {
    }
    function addWritersToMedianWhitelist(address _median, address[] memory _feeds) public {
        OracleLike_2(_median).lift(_feeds);
    }
    function removeWritersFromMedianWhitelist(address _median, address[] memory _feeds) public {
        OracleLike_2(_median).drop(_feeds);
    }
    function addReadersToMedianWhitelist(address _median, address[] memory _readers) public {
        OracleLike_2(_median).kiss(_readers);
    }
    function addReaderToMedianWhitelist(address _median, address _reader) public {
        OracleLike_2(_median).kiss(_reader);
    }
    function removeReadersFromMedianWhitelist(address _median, address[] memory _readers) public {
    }
    function removeReaderFromMedianWhitelist(address _median, address _reader) public {
    }
    function setMedianWritersQuorum(address _median, uint256 _minQuorum) public {
    }
    function addReaderToOSMWhitelist(address _osm, address _reader) public {
    }
    function removeReaderFromOSMWhitelist(address _osm, address _reader) public {
    }
    function allowOSMFreeze(address _osm, bytes32 _ilk) public {
    }
    function addCollateralBase(
        bytes32 _ilk,
        address _gem,
        address _join,
        address _flip,
        address _pip
    ) public {
    }
    function sendPaymentFromSurplusBuffer(address _target, uint256 _amount) public {
    }
}

////// lib/dss-exec-lib/src/DssAction.sol
//
// DssAction.sol -- DSS Executive Spell Actions
//
// Copyright (C) 2020 Maker Ecosystem Growth Holdings, Inc.
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

/* pragma solidity ^0.6.11; */

/* import "./CollateralOpts.sol"; */
/* import { DssExecLib } from "./DssExecLib.sol"; */

interface OracleLike_1 {
    function src() external view returns (address);
}

abstract contract DssAction {

    using DssExecLib for *;

    // Office Hours defaults to true by default.
    //   To disable office hours, override this function and
    //    return false in the inherited action.
    function officeHours() public virtual returns (bool) {
        return true;
    }

    // DssExec calls execute. We limit this function subject to officeHours modifier.
    function execute() external limited {
        actions();
    }

    // DssAction developer must override `actions()` and place all actions to be called inside.
    //   The DssExec function will call this subject to the officeHours limiter
    //   By keeping this function public we allow simulations of `execute()` on the actions outside of the cast time.
    function actions() public virtual;

    // Modifier required to
    modifier limited {
        if (officeHours()) {
            uint day = (block.timestamp / 1 days + 3) % 7;
            require(day < 5, "Can only be cast on a weekday");
            uint hour = block.timestamp / 1 hours % 24;
            require(hour >= 14 && hour < 21, "Outside office hours");
        }
        _;
    }

    /*****************************/
    /*** Collateral Onboarding ***/
    /*****************************/

    // Complete collateral onboarding logic.
    function addNewCollateral(CollateralOpts memory co) internal {
        // Add the collateral to the system.
        DssExecLib.addCollateralBase(co.ilk, co.gem, co.join, co.flip, co.pip);

        // Allow FlipperMom to access to the ilk Flipper
        address _flipperMom = DssExecLib.flipperMom();
        DssExecLib.authorize(co.flip, _flipperMom);
        // Disallow Cat to kick auctions in ilk Flipper
        if(!co.isLiquidatable) { DssExecLib.deauthorize(_flipperMom, co.flip); }

        if(co.isOSM) { // If pip == OSM
            // Allow OsmMom to access to the TOKEN OSM
            DssExecLib.authorize(co.pip, DssExecLib.osmMom());
            if (co.whitelistOSM) { // If median is src in OSM
                // Whitelist OSM to read the Median data (only necessary if it is the first time the token is being added to an ilk)
                DssExecLib.addReaderToMedianWhitelist(address(OracleLike_1(co.pip).src()), co.pip);
            }
            // Whitelist Spotter to read the OSM data (only necessary if it is the first time the token is being added to an ilk)
            DssExecLib.addReaderToOSMWhitelist(co.pip, DssExecLib.spotter());
            // Whitelist End to read the OSM data (only necessary if it is the first time the token is being added to an ilk)
            DssExecLib.addReaderToOSMWhitelist(co.pip, DssExecLib.end());
            // Set TOKEN OSM in the OsmMom for new ilk
            DssExecLib.allowOSMFreeze(co.pip, co.ilk);
        }
        // Increase the global debt ceiling by the ilk ceiling
        DssExecLib.increaseGlobalDebtCeiling(co.ilkDebtCeiling);
        // Set the ilk debt ceiling
        DssExecLib.setIlkDebtCeiling(co.ilk, co.ilkDebtCeiling);
        // Set the ilk dust
        DssExecLib.setIlkMinVaultAmount(co.ilk, co.minVaultAmount);
        // Set the dunk size
        DssExecLib.setIlkMaxLiquidationAmount(co.ilk, co.maxLiquidationAmount);
        // Set the ilk liquidation penalty
        DssExecLib.setIlkLiquidationPenalty(co.ilk, co.liquidationPenalty);

        // Set the ilk stability fee
        DssExecLib.setIlkStabilityFee(co.ilk, co.ilkStabilityFee, true);

        // Set the ilk percentage between bids
        DssExecLib.setIlkMinAuctionBidIncrease(co.ilk, co.bidIncrease);
        // Set the ilk time max time between bids
        DssExecLib.setIlkBidDuration(co.ilk, co.bidDuration);
        // Set the ilk max auction duration
        DssExecLib.setIlkAuctionDuration(co.ilk, co.auctionDuration);
        // Set the ilk min collateralization ratio
        DssExecLib.setIlkLiquidationRatio(co.ilk, co.liquidationRatio);

        // Update ilk spot value in Vat
        DssExecLib.updateCollateralPrice(co.ilk);
    }
}

////// lib/dss-exec-lib/src/DssExec.sol
//
// DssExec.sol -- MakerDAO Executive Spell Template
//
// Copyright (C) 2020 Maker Ecosystem Growth Holdings, Inc.
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

/* pragma solidity ^0.6.11; */

interface PauseAbstract {
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

interface Changelog {
    function getAddress(bytes32) external view returns (address);
}

interface SpellAction {
    function officeHours() external view returns (bool);
}

contract DssExec {

    Changelog      constant public log   = Changelog(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    uint256                 public eta;
    bytes                   public sig;
    bool                    public done;
    bytes32       immutable public tag;
    address       immutable public action;
    uint256       immutable public expiration;
    PauseAbstract immutable public pause;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://<executive-vote-canonical-post> -q -O - 2>/dev/null)"
    string                  public description;

    function officeHours() external view returns (bool) {
        return SpellAction(action).officeHours();
    }

    function nextCastTime() external view returns (uint256 castTime) {
        require(eta != 0, "DssExec/spell-not-scheduled");
        castTime = block.timestamp > eta ? block.timestamp : eta; // Any day at XX:YY

        if (SpellAction(action).officeHours()) {
            uint256 day    = (castTime / 1 days + 3) % 7;
            uint256 hour   = castTime / 1 hours % 24;
            uint256 minute = castTime / 1 minutes % 60;
            uint256 second = castTime % 60;

            if (day >= 5) {
                castTime += (6 - day) * 1 days;                 // Go to Sunday XX:YY
                castTime += (24 - hour + 14) * 1 hours;         // Go to 14:YY UTC Monday
                castTime -= minute * 1 minutes + second;        // Go to 14:00 UTC
            } else {
                if (hour >= 21) {
                    if (day == 4) castTime += 2 days;           // If Friday, fast forward to Sunday XX:YY
                    castTime += (24 - hour + 14) * 1 hours;     // Go to 14:YY UTC next day
                    castTime -= minute * 1 minutes + second;    // Go to 14:00 UTC
                } else if (hour < 14) {
                    castTime += (14 - hour) * 1 hours;          // Go to 14:YY UTC same day
                    castTime -= minute * 1 minutes + second;    // Go to 14:00 UTC
                }
            }
        }
    }

    // @param _description  A string description of the spell
    // @param _expiration   The timestamp this spell will expire. (Ex. now + 30 days)
    // @param _spellAction  The address of the spell action
    constructor(string memory _description, uint256 _expiration, address _spellAction) public {
        pause       = PauseAbstract(log.getAddress("MCD_PAUSE"));
        description = _description;
        expiration  = _expiration;
        action      = _spellAction;

        sig = abi.encodeWithSignature("execute()");
        bytes32 _tag;                    // Required for assembly access
        address _action = _spellAction;  // Required for assembly access
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + PauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
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
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
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
/* pragma solidity 0.6.11; */

/* import "dss-exec-lib/DssExec.sol"; */
/* import "dss-exec-lib/DssAction.sol"; */
/* import "lib/dss-interfaces/src/dss/VatAbstract.sol"; */

interface ChainlogAbstract_2 {
    function removeAddress(bytes32) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/44f3b05bc9da83a9b59163ac7645e78b82397246/governance/votes/Community%20Executive%20vote%20-%20March%201%2C%202021.md -q -O - 2>/dev/null)"
    string public constant description =
        "2021-03-01 MakerDAO Executive Spell | Hash: 0x883a580e50389497383818938dc2e1be5d28e8e6cde890bca89ed7d3ef4ba7ac";


    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //

    uint256 constant WAD        = 10**18;
    uint256 constant RAD        = 10**45;
    uint256 constant MILLION    = 10**6;

    address constant LERP = 0x7b3799b30f268BA55f926d7F714a3001aF89d359;

    // Turn off office hours
    function officeHours() public override returns (bool) {
        return false;
    }

    function actions() public override {
        VatAbstract vat = VatAbstract(DssExecLib.vat());

        // De-authorize the lerp contract from adjusting the PSM-USDC-A DC
        DssExecLib.deauthorize(address(vat), LERP);

        // Increase PSM-USDC-A to 1 Billion from its current value.
        DssExecLib.setIlkDebtCeiling("PSM-USDC-A", 1000 * MILLION);

        // Decrease the USDC-A Debt Ceiling to zero from its current value.
        (,,,uint256 line,) = vat.ilks("USDC-A");
        DssExecLib.setIlkDebtCeiling("USDC-A", 0);

        // Global debt ceiling for PSM was previously set to the end lerp value of 500M
        // Increase it by another 500M to match the 1B target debt ceiling
        // Also subtract out the USDC-A line
        vat.file("Line", vat.Line() + (500 * MILLION * RAD) - line);
    }
}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}