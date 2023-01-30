// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;

// Resale Voken1.0/2.0 or Upgrade to VokenTB.
//
// More info:
//   https://voken.io
//
// Contact us:
//   support@voken.io


import "LibSafeMath.sol";
import "LibAuthPause.sol";
import "LibIVesting.sol";
import "LibIERC20.sol";
import "LibIVokenTB.sol";
import "LibIVokenAudit.sol";
import "RouWithResaleOnly.sol";
import "RouWithDeadline.sol";
import "RouWithCoeff.sol";
import "RouWithUSDPrice.sol";
import "RouWithUSDToken.sol";
import "RouWithVestingPermille.sol";


/**
 * @title Resale Voken1.0/2.0 or Upgrade to VokenTB.
 */
contract ResaleOrUpgradeToVokenTB is IVesting, AuthPause, WithResaleOnly, WithDeadline, WithCoeff, WithUSDPrice, WithUSDToken, WithVestingPermille {
    using SafeMath for uint256;

    struct Resale {
        uint256 usdAudit;
        uint256 usdClaimed;
        uint256 timestamp;
    }

    struct Upgraded {
        uint256 claimed;
        uint256 bonuses;
        uint256 etherUSDPrice;
        uint256 vokenUSDPrice;
        uint256 timestamp;
    }

    uint256 private immutable VOKEN_UPGRADED_CAP = 21_000_000e9;

    uint256 private _usdAudit;
    uint256 private _usdClaimed;

    uint256 private _v1Claimed;
    uint256 private _v1Bonuses;
    uint256 private _v2Claimed;
    uint256 private _v2Bonuses;

    IVokenTB private immutable VOKEN_TB = IVokenTB(0x1234567a022acaa848E7D6bC351d075dBfa76Dd4);

    IERC20 private immutable VOKEN_1 = IERC20(0x82070415FEe803f94Ce5617Be1878503e58F0a6a);  // Voken1.0
    IERC20 private immutable VOKEN_2 = IERC20(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);  // Voken2.0

    IVokenAudit private immutable VOKEN_1_AUDIT = IVokenAudit(0x11111eA590876f5E8416cD4a81A0CFb9DfA2b08E);
    IVokenAudit private immutable VOKEN_2_AUDIT = IVokenAudit(0x22222eA5b84E877A1790b4653a70ad0df8e3E890);

    mapping (address => Resale) private _v1ResaleApplied;
    mapping (address => Resale) private _v2ResaleApplied;
    mapping (address => Upgraded) private _v1UpgradeApplied;
    mapping (address => Upgraded) private _v2UpgradeApplied;


    /**
     * @dev Accept Ether.
     */
    receive()
        external
        payable
    {
        //
    }

    /**
     * @dev Apply re-sale. 
     */
    function applyV1Resale()
        external
    {
        _v1Resale(msg.sender);
    }

    function applyV2Resale()
        external
    {
        _v2Resale(msg.sender);
    }

    /**
     * @dev Apply upgrade.
     */
    function applyV1Upgrade()
        external
    {
        _v1Upgrade(msg.sender);
    }

    function applyV2Upgrade()
        external
    {
        _v2Upgrade(msg.sender);
    }

    /**
     * @dev Claim USD, according to re-sale.
     */
    function claimV1USD()
        external
    {
        _v1ClaimUSD();
    }

    function claimV2USD()
        external
    {
        _v2ClaimUSD();
    }

    /**
     * @dev Returns the status.
     */
    function status()
        public
        view
        returns (
            uint256 deadline,

            uint256 usdAudit,
            uint256 usdClaimed,
            uint256 usdReceived,

            uint256 resaleEtherUSD,

            uint256 v1Claimed,
            uint256 v1Bonuses,
            uint256 v2Claimed,
            uint256 v2Bonuses,

            uint256 etherUSD,
            uint256 vokenUSD
        )
    {
        deadline = _deadline();
        
        usdAudit = _usdAudit;
        usdClaimed = _usdClaimed;
        usdReceived = _usdReceived();

        resaleEtherUSD = resaleEtherUSDPrice();

        v1Claimed = _v1Claimed;
        v1Bonuses = _v1Bonuses;
        v2Claimed =  _v2Claimed;
        v2Bonuses = _v2Bonuses;
        
        etherUSD = _etherUSDPrice();
        vokenUSD = vokenUSDPrice();
    }

    /**
     * @dev Returns status of `account`.
     */
    function getAccountStatus(address account)
        public
        view
        returns (
            bool canOnlyResale,
            uint256 v1ResaleAppliedTimestamp,
            uint256 v2ResaleAppliedTimestamp,
            uint256 v1UpgradeAppliedTimestamp,
            uint256 v2UpgradeAppliedTimestamp,

            uint256 v1Balance,
            uint256 v2Balance,
            
            uint256 etherBalance
        )
    {
        canOnlyResale = isResaleOnly(account);

        v1ResaleAppliedTimestamp = _v1ResaleApplied[account].timestamp;
        v1UpgradeAppliedTimestamp = _v1UpgradeApplied[account].timestamp;
        v1Balance = VOKEN_1.balanceOf(account);

        v2ResaleAppliedTimestamp = _v2ResaleApplied[account].timestamp;
        v2UpgradeAppliedTimestamp = _v2UpgradeApplied[account].timestamp;
        v2Balance = VOKEN_2.balanceOf(account);
        
        etherBalance = account.balance;
    }

    /**
     * @dev Returns the re-sale status.
     */
    function v1ResaleStatus(address account)
        public
        view
        returns (
            uint256 usdQuota,
            uint256 usdAudit,
            uint256 usdClaimed,
            uint256 timestamp
        )
    {
        timestamp = _v1ResaleApplied[account].timestamp;
        if (timestamp > 0) {
            usdQuota = _v1USDQuota(account);
            usdAudit = _v1ResaleApplied[account].usdAudit;
            usdClaimed = _v1ResaleApplied[account].usdClaimed;
        }
    }

    function v2ResaleStatus(address account)
        public
        view
        returns (
            uint256 usdQuota,
            uint256 usdAudit,
            uint256 usdClaimed,
            uint256 timestamp
        )
    {
        timestamp = _v2ResaleApplied[account].timestamp;
        if (timestamp > 0) {
            usdQuota = _v2USDQuota(account);
            usdAudit = _v2ResaleApplied[account].usdAudit;
            usdClaimed = _v2ResaleApplied[account].usdClaimed;
        }
    }

    /**
     * @dev Returns the upgrade status.
     */
    function v1UpgradeStatus(address account)
        public
        view
        returns (
            uint72 weiPurchased,
            uint72 weiRewarded,
            uint72 weiAudit,
            uint16 txsIn,
            uint16 txsOut,

            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,

            uint256 timestamp
        )
    {
        (weiPurchased, weiRewarded, weiAudit, txsIn, txsOut) = VOKEN_1_AUDIT.getAccount(account);
        (claim, bonus, etherUSD, vokenUSD, timestamp) = _v1UpgradeQuota(account);
    }

    function v2UpgradeStatus(address account)
        public
        view
        returns (
            uint72 weiPurchased,
            uint72 weiRewarded,
            uint72 weiAudit,
            uint16 txsIn,
            uint16 txsOut,

            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,
            uint256 timestamp
        )
    {
        (weiPurchased, weiRewarded, weiAudit, txsIn, txsOut) = VOKEN_2_AUDIT.getAccount(account);
        (claim, bonus, etherUSD, vokenUSD, timestamp) = _v2UpgradeQuota(account);
    }

    /**
     * @dev Returns the vesting amount of VOKEN by `account`, only for this re-sale/upgrade contract/program.
     */
    function vestingOf(address account)
        public
        override
        view
        returns (uint256 vesting)
    {
        vesting = vesting.add(_getV1ClaimedVestingAmount(_v1UpgradeApplied[account].claimed));
        vesting = vesting.add(_getV1BonusesVestingAmount(_v1UpgradeApplied[account].bonuses));
        vesting = vesting.add(_getV2ClaimedVestingAmount(_v2UpgradeApplied[account].claimed));
        vesting = vesting.add(_getV2BonusesVestingAmount(_v2UpgradeApplied[account].bonuses));
    }

    /**
     * @dev Returns USD received.
     */
    function _usdReceived()
        private
        view
        returns (uint256)
    {
        return _usdClaimed.add(_getUSDBalance());
    }

    /**
     * @dev Re-Sale.
     */
    function _v1Resale(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {
        require(_v1ResaleApplied[account].timestamp == 0, "Voken1 Resale: already applied before");
        require(_v1UpgradeApplied[account].timestamp == 0, "Voken1 Resale: already applied for upgrade");

        (, , uint256 weiAudit, ,) = VOKEN_1_AUDIT.getAccount(account);
        require(weiAudit > 0, "Voken1 Resale: audit ETH is zero");

        uint256 usdAudit = resaleEtherUSDPrice().mul(weiAudit).div(1 ether);
        _usdAudit = _usdAudit.add(usdAudit);
        _v1ResaleApplied[account].usdAudit = usdAudit;
        _v1ResaleApplied[account].timestamp = block.timestamp;
    }

    function _v2Resale(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {
        require(_v2ResaleApplied[account].timestamp == 0, "Voken2 Resale: already applied before");
        require(_v2UpgradeApplied[account].timestamp == 0, "Voken2 Resale: already applied for upgrade");

        (, , uint256 weiAudit, ,) = VOKEN_2_AUDIT.getAccount(account);
        require(weiAudit > 0, "Voken2 Resale: audit ETH is zero");

        uint256 usdAudit = resaleEtherUSDPrice().mul(weiAudit).div(1 ether);
        _usdAudit = _usdAudit.add(usdAudit);
        _v2ResaleApplied[account].usdAudit = usdAudit;
        _v2ResaleApplied[account].timestamp = block.timestamp;
    }

    /**
     * @dev Upgrade.
     */
    function _v1Upgrade(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {
        require(!isResaleOnly(account), "Upgrade from Voken1: can only apply for resale");
        require(_v1ResaleApplied[account].timestamp == 0, "Upgrade from Voken1: already applied for resale");
        require(_v1UpgradeApplied[account].timestamp == 0, "Upgrade from Voken1: already applied before");

        (uint256 claim, uint256 bonus, uint256 etherUSD, uint256 vokenUSD,) = _v1UpgradeQuota(account);
        require(claim > 0 || bonus > 0, "Upgrade from Voken1: not upgradeable");


        uint256 vokenUpgraded = _v1Claimed.add(_v1Bonuses).add(_v2Claimed).add(_v2Bonuses);
        require(vokenUpgraded < VOKEN_UPGRADED_CAP, "Upgrade from Voken1: out of the cap");

        if (claim > 0) {
            VOKEN_TB.mintWithVesting(account, claim, address(this));
            _v1Claimed = _v1Claimed.add(claim);
            _v1UpgradeApplied[account].claimed = claim;
        }

        if (bonus > 0) {
            VOKEN_TB.mintWithVesting(account, bonus, address(this));
            _v1Bonuses = _v1Bonuses.add(bonus);
            _v1UpgradeApplied[account].bonuses = bonus;
        }

        _v1UpgradeApplied[account].etherUSDPrice = etherUSD;
        _v1UpgradeApplied[account].vokenUSDPrice = vokenUSD;
        _v1UpgradeApplied[account].timestamp = block.timestamp;
    }

    function _v2Upgrade(address account)
        private
        onlyBeforeDeadline
        onlyNotPaused
    {
        require(!isResaleOnly(account), "Upgrade from Voken2: can only apply for resale");
        require(_v2ResaleApplied[account].timestamp == 0, "Upgrade from Voken2: already applied for resale");
        require(_v2UpgradeApplied[account].timestamp == 0, "Upgrade from Voken2: already applied for upgrade");

        (uint256 claim, uint256 bonus, uint256 etherUSD, uint256 vokenUSD,) = _v2UpgradeQuota(account);
        require(claim > 0 || bonus > 0, "Upgrade from Voken2: not upgradeable");

        uint256 vokenUpgraded = _v1Claimed.add(_v1Bonuses).add(_v2Claimed).add(_v2Bonuses);
        require(vokenUpgraded < VOKEN_UPGRADED_CAP, "Upgrade from Voken2: out of the cap");

        if (claim > 0) {
            VOKEN_TB.mintWithVesting(account, claim, address(this));
            _v2Claimed = _v2Claimed.add(claim);
            _v2UpgradeApplied[account].claimed = claim;
        }

        if (bonus > 0) {
            VOKEN_TB.mintWithVesting(account, bonus, address(this));
            _v2Bonuses = _v2Bonuses.add(bonus);
            _v2UpgradeApplied[account].bonuses = bonus;
        }

        _v2UpgradeApplied[account].etherUSDPrice = etherUSD;
        _v2UpgradeApplied[account].vokenUSDPrice = vokenUSD;
        _v2UpgradeApplied[account].timestamp = block.timestamp;
    }

    /**
     * @dev Claim USD.
     */
    function _v1ClaimUSD()
        private
    {
        require(_v1ResaleApplied[msg.sender].timestamp > 0, "Have not applied for resale yet");

        uint256 balance = _getUSDBalance();
        require(balance > 0, "USD balance is zero");

        uint256 quota = _v1USDQuota(msg.sender);
        require(quota > 0, "No USD quota to claim");

        if (quota < balance) {
            _usdClaimed = _usdClaimed.add(quota);
            _v1ResaleApplied[msg.sender].usdClaimed = _v1ResaleApplied[msg.sender].usdClaimed.add(quota);
            _transferUSD(msg.sender, quota);
        }

        else {
            _usdClaimed = _usdClaimed.add(balance);
            _v1ResaleApplied[msg.sender].usdClaimed = _v1ResaleApplied[msg.sender].usdClaimed.add(balance);
            _transferUSD(msg.sender, balance);
        }
    }

    function _v2ClaimUSD()
        private
    {
        require(_v2ResaleApplied[msg.sender].timestamp > 0, "Have not applied for resale yet");
        
        uint256 balance = _getUSDBalance();
        require(balance > 0, "USD balance is zero");

        uint256 quota = _v2USDQuota(msg.sender);
        require(quota > 0, "No USD quota to claim");

        if (quota < balance) {
            _usdClaimed = _usdClaimed.add(quota);
            _v2ResaleApplied[msg.sender].usdClaimed = _v2ResaleApplied[msg.sender].usdClaimed.add(quota);
            _transferUSD(msg.sender, quota);
        }

        else {
            _usdClaimed = _usdClaimed.add(balance);
            _v2ResaleApplied[msg.sender].usdClaimed = _v2ResaleApplied[msg.sender].usdClaimed.add(balance);
            _transferUSD(msg.sender, balance);
        }
    }

    /**
     * @dev Returns the USD amount of an `account` in re-sale.
     */
    function _v1USDQuota(address account)
        private
        view
        returns (uint256 quota)
    {
        if (_v1ResaleApplied[account].usdAudit > 0 && _usdAudit > 0) {
            uint256 amount = _usdReceived().mul(_v1ResaleApplied[account].usdAudit).div(_usdAudit);

            if (_v1ResaleApplied[account].usdClaimed <= amount) {
                quota = amount.sub(_v1ResaleApplied[account].usdClaimed);
            }

            uint256 balance = _getUSDBalance();
            if (balance < quota) {
                quota = balance;
            }

            uint256 diff = _v1ResaleApplied[account].usdAudit.sub(_v1ResaleApplied[account].usdClaimed);
            
            if (diff < quota) {
                quota = diff;
            }
        }
    }

    function _v2USDQuota(address account)
        private
        view
        returns (uint256 quota)
    {
        if (_v2ResaleApplied[account].usdAudit > 0 && _usdAudit > 0) {
            uint256 amount = _usdReceived().mul(_v2ResaleApplied[account].usdAudit).div(_usdAudit);

            if (_v2ResaleApplied[account].usdClaimed <= amount) {
                quota = amount.sub(_v2ResaleApplied[account].usdClaimed);
            }
            
            uint256 balance = _getUSDBalance();
            if (balance < quota) {
                quota = balance;
            }

            uint256 diff = _v2ResaleApplied[account].usdAudit.sub(_v2ResaleApplied[account].usdClaimed);
            
            if (diff < quota) {
                quota = diff;
            }
        }
    }

    /**
     * @dev Returns upgrading data/quota.
     */
    function _v1UpgradeQuota(address account)
        private
        view
        returns (
            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,
            uint256 timestamp
        )
    {
        timestamp = _v1UpgradeApplied[account].timestamp;

        if (timestamp > 0) {
            claim = _v1UpgradeApplied[account].claimed;
            bonus = _v1UpgradeApplied[account].bonuses;
            etherUSD = _v1UpgradeApplied[account].etherUSDPrice;
            vokenUSD = _v1UpgradeApplied[account].vokenUSDPrice;
        }

        else {
            (, , uint256 wei_audit, ,) = VOKEN_1_AUDIT.getAccount(account);
            
            if (!isResaleOnly(account)) {
                etherUSD = _etherUSDPrice();
                vokenUSD = vokenUSDPrice();

                claim = wei_audit.mul(etherUSD).div(1e15).div(vokenUSD).mul(1e6);
                bonus = claim.mul(v1BonusCoeff()).div(1e3);

                uint256 shift = VOKEN_1.balanceOf(account).div(v1ClaimRatio()).div(1e3).mul(1e6);
                uint256 mint = claim.add(bonus);
        
                if (mint < shift) {
                    bonus = shift.sub(claim);
                }
            }
        }
    }

    function _v2UpgradeQuota(address account)
        private
        view
        returns (
            uint256 claim,
            uint256 bonus,
            uint256 etherUSD,
            uint256 vokenUSD,
            uint256 timestamp
        )
    {
        timestamp = _v2UpgradeApplied[account].timestamp;

        if (timestamp > 0) {
            claim = _v2UpgradeApplied[account].claimed;
            bonus = _v2UpgradeApplied[account].bonuses;
            etherUSD = _v2UpgradeApplied[account].etherUSDPrice;
            vokenUSD = _v2UpgradeApplied[account].vokenUSDPrice;
        }

        else {
            (, , uint256 wei_audit, ,) = VOKEN_2_AUDIT.getAccount(account);
            
            if (!isResaleOnly(account)) {
                etherUSD = _etherUSDPrice();
                vokenUSD = vokenUSDPrice();

                claim = wei_audit.mul(etherUSD).div(1e15).div(vokenUSD).mul(1e6);
                bonus = claim.mul(v2BonusCoeff()).div(1e3);

                uint256 shift = VOKEN_2.balanceOf(account).div(v2ClaimRatio()).div(1e3).mul(1e6);
                uint256 mint = claim.add(bonus);
        
                if (mint < shift) {
                    bonus = shift.sub(claim);
                }
            }
        }
    }

    /**
     * @dev Returns the bigger one between `a` and `b`.
     */
    function max(uint256 a, uint256 b)
        private
        pure
        returns (uint256)
    {
        return a > b ? a : b;
    }
}
