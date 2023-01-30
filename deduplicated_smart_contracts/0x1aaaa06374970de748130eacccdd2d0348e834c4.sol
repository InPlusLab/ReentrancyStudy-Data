// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;

// VokenTB (TeraByte) EarlyBird-Sale
//
// More info:
//   https://voken.io
//
// Contact us:
//   support@voken.io


import "LibSafeMath.sol";
import "LibIERC20.sol";
import "LibIVesting.sol";
import "LibIVokenTB.sol";
import "LibAuthPause.sol";
import "EbWithEtherUSDPrice.sol";
import "EbWithVestingPermille.sol";
import "EbWithResaleFund.sol";
import "EbWithTeamFund.sol";


/**
 * @dev EarlyBird-Sale
 */
contract EarlyBirdSale is IVesting, AuthPause, WithEtherUSDPrice, WithVestingPermille, WithResaleFund, WithTeamFund {
    using SafeMath for uint256;

    struct Account {
        uint256 issued;
        uint256 bonuses;
        uint256 volume;
    }

    uint256 private immutable VOKEN_ISSUE_MAX = 10_500_000e9;  // 10.5 million for early-birds
    uint256 private immutable VOKEN_ISSUE_MID =  5_250_000e9;
    uint256 private immutable WEI_PAYMENT_MAX = 1.0 ether;
    uint256 private immutable WEI_PAYMENT_MID = 0.5 ether;
    uint256 private immutable WEI_PAYMENT_MIN = 0.1 ether;
    uint256 private immutable USD_PRICE_START = 0.5e6;  // $ 0.5 USD
    uint256 private immutable USD_PRICE_DISTA = 0.2e6;  // $ 0.2 USD = 0.7 - 0.5

    uint256 private _vokenIssued;
    uint256 private _vokenBonuses;
    uint8[10] private REWARDS_PCT = [10, 3, 2, 1, 1, 1, 1, 1, 1, 1];

    IVokenTB private immutable VOKEN_TB = IVokenTB(0x1234567a022acaa848E7D6bC351d075dBfa76Dd4);

    mapping (address => Account) private _accounts;

    event Payment(address indexed account, uint256 etherUsdPrice, uint256 weiPayment);
    event Reward(address indexed account, address indexed referrer, uint8 level, uint256 weiReward);

    receive()
        external
        payable
    {
        _swap();
    }

    function status()
        public
        view
        returns (
            uint256 vokenCap,
            uint256 vokenTotalSupply,

            uint256 vokenIssued,
            uint256 vokenBonuses,
            uint256 etherUSD,
            uint256 vokenUSD,
            uint256 weiMin,
            uint256 weiMax
        )
    {
        vokenCap = VOKEN_TB.cap();
        vokenTotalSupply = VOKEN_TB.totalSupply();

        vokenIssued = _vokenIssued;
        vokenBonuses = _vokenBonuses;
        etherUSD = etherUSDPrice();
        vokenUSD = vokenUSDPrice();

        weiMin = WEI_PAYMENT_MIN;
        weiMax = _vokenIssued < VOKEN_ISSUE_MID ? WEI_PAYMENT_MAX : WEI_PAYMENT_MID;
    }

    function getAccountStatus(address account)
        public
        view
        returns (
            uint256 issued,
            uint256 bonuses,
            uint256 volume,

            uint256 etherBalance,
            uint256 vokenBalance,

            uint160 voken,
            address referrer,
            uint160 referrerVoken
        )
    {
        issued = _accounts[account].issued;
        bonuses = _accounts[account].bonuses;
        volume = _accounts[account].volume;

        etherBalance = account.balance;
        vokenBalance = VOKEN_TB.balanceOf(account);
        
        voken = VOKEN_TB.address2voken(account);
        referrer = VOKEN_TB.referrer(account);

        if (referrer != address(0)) {
            referrerVoken = VOKEN_TB.address2voken(referrer);
        }
    }

    /**
     * @dev Returns the vesting amount of VOKEN by `account`, only for this Early-Bird contract/program.
     */
    function vestingOf(address account)
        public
        override
        view
        returns (uint256 Vesting)
    {
        Vesting = Vesting.add(_getVestingAmountForIssued(_accounts[account].issued));
        Vesting = Vesting.add(_getVestingAmountForBonuses(_accounts[account].bonuses));
    }

    /**
     * @dev Returns current Voken price in USD.
     */
    function vokenUSDPrice()
        public
        view
        returns (uint256)
    {
        return USD_PRICE_START.add(USD_PRICE_DISTA.mul(_vokenIssued).div(VOKEN_ISSUE_MAX));
    }

    function _swap()
        private
        onlyNotPaused
    {
        require(msg.value >= WEI_PAYMENT_MIN, "Insufficient ether");
        require(_vokenIssued < VOKEN_ISSUE_MAX, "Early-Bird sale completed");
        require(_accounts[msg.sender].issued == 0, "Caller is already an early-bird");

        uint256 weiPayment = msg.value;
        uint256 weiPaymentMax = _vokenIssued < VOKEN_ISSUE_MID ? WEI_PAYMENT_MAX : WEI_PAYMENT_MID;
        uint256 etherUSD = etherUSDPrice();
        uint256 vokenIssued;
        uint256 vokenBonus;

        // Limit the Payment and Refund (if needed)
        if (weiPayment > weiPaymentMax)
        {
            msg.sender.transfer(weiPayment.sub(weiPaymentMax));
            weiPayment = weiPaymentMax;
        }

        // Voken Issued
        vokenIssued = weiPayment.mul(etherUSD).div(vokenUSDPrice()).div(1e15).mul(1e6);
        VOKEN_TB.mintWithVesting(msg.sender, vokenIssued, address(this));
        _vokenIssued = _vokenIssued.add(vokenIssued);
        _accounts[msg.sender].issued = _accounts[msg.sender].issued.add(vokenIssued);

        // Voken Bonus & Ether Rewards
        address payable referrer = VOKEN_TB.referrer(msg.sender);
        if (referrer != address(0))
        {
            // Reffer
            _accounts[referrer].volume = _accounts[referrer].volume.add(weiPayment);

            // Voken Bonus: 1% - 10%
            vokenBonus = vokenIssued.mul(uint256(blockhash(block.number - 1)).mod(10).add(1)).div(100);
            VOKEN_TB.mintWithVesting(msg.sender, vokenBonus, address(this));
            _vokenBonuses = _vokenBonuses.add(vokenBonus);
            _accounts[msg.sender].bonuses = _accounts[msg.sender].bonuses.add(vokenBonus);

            // Ether Payouts (rewards)
            for(uint8 i = 0; i < REWARDS_PCT.length; i++)
            {
                if (i > 2 && _accounts[referrer].volume < i * 1 ether)
                {
                    continue;
                }

                uint256 weiReward = weiPayment.mul(REWARDS_PCT[i]).div(100);
                referrer.transfer(weiReward);
                emit Reward(msg.sender, referrer, i, weiReward);

                if (i < REWARDS_PCT.length - 1)
                {
                    referrer = VOKEN_TB.referrer(referrer);
                    if (referrer == address(0))
                    {
                        break;
                    }
                }
            }
        }

        // Payment Event
        emit Payment(msg.sender, etherUSD, weiPayment);

        // Resale Fund
        sendResaleFund(weiPayment);

        // Fund
        sendTeamFund();
    }
}

