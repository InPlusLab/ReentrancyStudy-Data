/**

 *Submitted for verification at Etherscan.io on 2019-03-01

*/



// File: openzeppelin-solidity/contracts/access/Roles.sol



pragma solidity ^0.5.0;



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */

library Roles {

    struct Role {

        mapping (address => bool) bearer;

    }



    /**

     * @dev give an account access to this role

     */

    function add(Role storage role, address account) internal {

        require(account != address(0));

        require(!has(role, account));



        role.bearer[account] = true;

    }



    /**

     * @dev remove an account's access to this role

     */

    function remove(Role storage role, address account) internal {

        require(account != address(0));

        require(has(role, account));



        role.bearer[account] = false;

    }



    /**

     * @dev check if an account has this role

     * @return bool

     */

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));

        return role.bearer[account];

    }

}



// File: openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol



pragma solidity ^0.5.0;





/**

 * @title WhitelistAdminRole

 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.

 */

contract WhitelistAdminRole {

    using Roles for Roles.Role;



    event WhitelistAdminAdded(address indexed account);

    event WhitelistAdminRemoved(address indexed account);



    Roles.Role private _whitelistAdmins;



    constructor () internal {

        _addWhitelistAdmin(msg.sender);

    }



    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(msg.sender));

        _;

    }



    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);

    }



    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);

    }



    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(msg.sender);

    }



    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);

        emit WhitelistAdminAdded(account);

    }



    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);

        emit WhitelistAdminRemoved(account);

    }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity ^0.5.0;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.5.0;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



pragma solidity ^0.5.0;







/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    using SafeMath for uint256;



    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));

    }



    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));

    }



    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        // safeApprove should only be called when setting an initial allowance,

        // or when resetting it to zero. To increase and decrease it, use

        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

        require((value == 0) || (token.allowance(msg.sender, spender) == 0));

        require(token.approve(spender, value));

    }



    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);

        require(token.approve(spender, newAllowance));

    }



    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);

        require(token.approve(spender, newAllowance));

    }

}



// File: contracts/TermDeposit.sol



pragma solidity >=0.4.14 <0.6.0;













/// @author QuarkChain Eng Team

/// @title A term deposit contract for ERC20 tokens

contract TermDeposit is WhitelistAdminRole {



    using SafeMath for uint256;

    using SafeERC20 for IERC20;



    event DoDeposit(address indexed depositor, uint256 amount);

    event Withdraw(address indexed depositor, uint256 amount);

    event AddReferral(address indexed depositor, address indexed referrer, uint256 amount);

    event GetReferralBonus(address indexed depositor, uint256 amount);

    event Drain(address indexed admin);

    event Goodbye(address indexed admin, uint256 amount);



    uint256 public constant MIN_DEPOSIT = 100 * 1e18;  // => 100 QKC.

    // Pre-defined terms.

    bytes4 public constant TERM_3MO = "3mo";

    bytes4 public constant TERM_6MO = "6mo";

    bytes4 public constant TERM_9MO = "9mo";

    bytes4 public constant TERM_12MO = "12mo";



    struct FeatureFlag {

        uint8 version;

        bool enableInterest;

        bool enableReferralBonus;

        bool enableDepositLimit;

    }



    struct TermDepositInfo {

        uint256 depositDeadline;

        uint256 duration;

        // Interest in basis points.

        uint256 interestBp;

        uint256 totalDepositAllowed;

        uint256 totalReceived;

        mapping (address => Deposit[]) deposits;

        // Referral-related.

        uint256 totalReferralAmount;

        uint256 referralBonusRateBp;

        mapping (address => Referral) referrals;

    }



    struct Deposit {

        uint256 amount;

        uint256 depositAt;

        uint256 withdrawAt;

    }



    struct Referral {

        uint256 amount;

        uint256 withdrawAt;

    }



    mapping (bytes4 => TermDepositInfo) private _termDeposits;

    IERC20 private _token;

    FeatureFlag private _featureFlags;



    uint256 public referralBonusLockUntil;

    bytes4[] public allTerms = [TERM_3MO, TERM_6MO, TERM_9MO, TERM_12MO];



    /// Constructor for the term deposit contract.

    /// @param depositDeadline latest timestamp for accepting deposits

    /// @param token ERC20 token addresses for term deposit

    /// @param version feature flag version

    constructor(uint256 depositDeadline, IERC20 token, uint8 version) public {

        require(depositDeadline > 0, "should have sensible argument");



        processFeatureFlag(version);



        uint256 monthInSec = 2635200;

        _token = token;



        _termDeposits[TERM_3MO] = TermDepositInfo({

            depositDeadline: depositDeadline,

            duration: 3 * monthInSec,

            interestBp: 250,

            // TODO: Use real number.

            totalDepositAllowed: (10 ** 7) * 1e18,

            totalReceived: 0,

            referralBonusRateBp: 22,

            totalReferralAmount: 0

        });



        _termDeposits[TERM_6MO] = TermDepositInfo({

            depositDeadline: depositDeadline,

            duration: 6 * monthInSec,

            interestBp: 550,

            // TODO: Use real number.

            totalDepositAllowed: (10 ** 7) * 1e18,

            totalReceived: 0,

            referralBonusRateBp: 45,

            totalReferralAmount: 0

        });



        _termDeposits[TERM_9MO] = TermDepositInfo({

            depositDeadline: depositDeadline,

            duration: 9 * monthInSec,

            // TODO: Use real number.

            interestBp: 1000,

            // TODO: Use real number.

            totalDepositAllowed: (10 ** 7) * 1e18,

            totalReceived: 0,

            // TODO: Use real number.

            referralBonusRateBp: 80,

            totalReferralAmount: 0

        });



        _termDeposits[TERM_12MO] = TermDepositInfo({

            depositDeadline: depositDeadline,

            duration: 12 * monthInSec,

            interestBp: 1300,

            // TODO: Use real number.

            totalDepositAllowed: (10 ** 7) * 1e18,

            totalReceived: 0,

            referralBonusRateBp: 100,

            totalReferralAmount: 0

        });



        // Same as deposit deadline.

        referralBonusLockUntil = depositDeadline;

    }



    /// Helper function to parse version and set feature flags.

    /// @param version feature flag version

    function processFeatureFlag(uint8 version) private {

        require(version <= 2, "should only allow version <= 2");

        _featureFlags.version = version;

        // Note all feature flags are false by default.

        if (version > 0) {

            _featureFlags.enableDepositLimit = true;

        }

        if (version > 1) {

            _featureFlags.enableInterest = true;

            _featureFlags.enableReferralBonus = true;

        }

    }



    /// Getter for token address.

    /// @return the token address

    function token() public view returns (IERC20) {

        return _token;

    }



    /// Getter for feature flag version.

    /// @return version of the feature flags

    function featureFlagVersion() public view returns (uint8) {

        return _featureFlags.version;

    }



    /// Return a term deposit's key properties.

    /// @param term the byte representation of terms

    /// @return a list of deposit overview info

    function getTermDepositInfo(bytes4 term) public view returns (uint256[7] memory) {

        TermDepositInfo memory info = _termDeposits[term];

        require(info.duration > 0, "should be a valid term");

        return [

            info.depositDeadline,

            info.duration,

            info.interestBp,

            info.totalDepositAllowed,

            info.totalReceived,

            info.referralBonusRateBp,

            info.totalReferralAmount

        ];

    }



    /// Deposit users tokens into this contract.

    /// @param term the byte representation of terms

    /// @param amount token amount in wei

    /// @param referrer address of the referrer

    function deposit(bytes4 term, uint256 amount, address referrer) public {

        require(amount >= MIN_DEPOSIT, "should have amount >= minimum");

        require(referrer != msg.sender, "should not have self as the referrer");

        TermDepositInfo storage info = _termDeposits[term];

        require(info.duration > 0, "should be a valid term");

        require(now <= info.depositDeadline, "should deposit before the deadline");

        if (_featureFlags.enableDepositLimit) {

            require(

                info.totalReceived.add(amount) <= info.totalDepositAllowed,

                "should not exceed deposit limit"

            );

        }

        if (!_featureFlags.enableReferralBonus) {

            require(referrer == address(0), "should not allow referrer per FF");

        }



        Deposit[] storage deposits = info.deposits[msg.sender];

        deposits.push(Deposit({

            amount: amount,

            depositAt: now,

            withdrawAt: 0

        }));

        info.totalReceived = info.totalReceived.add(amount);

        emit DoDeposit(msg.sender, amount);



        if (referrer != address(0)) {

            Referral storage referral = info.referrals[referrer];

            referral.amount = referral.amount.add(amount);

            info.totalReferralAmount = info.totalReferralAmount.add(amount);

            emit AddReferral(msg.sender, referrer, amount);

        }



        _token.safeTransferFrom(msg.sender, address(this), amount);

    }



    /// Calculate amount of tokens a user has deposited.

    /// @param depositor the address of the depositor

    /// @param terms the list of byte representation of terms

    /// @param withdrawable boolean flag for whether to require withdrawable

    /// @param withInterests boolean flag for whether to include interests

    /// @return amount of tokens available for withdrawal

    function getDepositAmount(

        address depositor,

        bytes4[] memory terms,

        bool withdrawable,

        bool withInterests

    ) public view returns (uint256[] memory)

    {

        if (!_featureFlags.enableInterest) {

            require(!withInterests, "should not allow querying interests per FF");

        }

        uint256[] memory ret = new uint256[](terms.length);

        for (uint256 i = 0; i < terms.length; i++) {

            TermDepositInfo storage info = _termDeposits[terms[i]];

            require(info.duration > 0, "should be a valid term");

            Deposit[] memory deposits = info.deposits[depositor];



            uint256 total = 0;

            for (uint256 j = 0; j < deposits.length; j++) {

                uint256 lockUntil = deposits[j].depositAt.add(info.duration);

                if (deposits[j].withdrawAt == 0) {

                    if (!withdrawable || now >= lockUntil) {

                        total = total.add(deposits[j].amount);

                    }

                }

            }

            if (withInterests) {

                total = total.add(total.mul(info.interestBp).div(10000));

            }

            ret[i] = total;

        }

        return ret;

    }



    /// Get detailed deposit information of a user.

    /// @param depositor the address of the depositor

    /// @param term the byte representation of terms

    /// @return 3 arrays of deposit amounts, deposit / withdrawal timestamps

    function getDepositDetails(

        address depositor,

        bytes4 term

    ) public view returns (uint256[] memory, uint256[] memory, uint256[] memory)

    {

        TermDepositInfo storage info = _termDeposits[term];

        require(info.duration > 0, "should be a valid term");

        Deposit[] memory deposits = info.deposits[depositor];



        uint256[] memory amounts = new uint256[](deposits.length);

        uint256[] memory depositTs = new uint256[](deposits.length);

        uint256[] memory withdrawTs = new uint256[](deposits.length);

        for (uint256 i = 0; i < deposits.length; i++) {

            amounts[i] = deposits[i].amount;

            depositTs[i] = deposits[i].depositAt;

            withdrawTs[i] = deposits[i].withdrawAt;

        }

        return (amounts, depositTs, withdrawTs);

    }



    /// Withdraw a user's tokens plus interest to his/her own address.

    /// @param term the byte representation of terms

    /// @return whether have withdrawn some tokens successfully

    function withdraw(bytes4 term) public returns (bool) {

        TermDepositInfo storage info = _termDeposits[term];

        require(info.duration > 0, "should be a valid term");

        Deposit[] storage deposits = info.deposits[msg.sender];



        uint256 total = 0;

        for (uint256 i = 0; i < deposits.length; i++) {

            uint256 lockUntil = deposits[i].depositAt.add(info.duration);

            if (deposits[i].withdrawAt == 0 && now >= lockUntil) {

                total = total.add(deposits[i].amount);

                deposits[i].withdrawAt = now;

            }

        }



        if (total == 0) {

            return false;

        }



        info.totalReceived = info.totalReceived.sub(total);

        if (_featureFlags.enableInterest) {

            total = total.add(total.mul(info.interestBp).div(10000));

        }

        emit Withdraw(msg.sender, total);



        _token.safeTransfer(msg.sender, total);

        return true;

    }



    /// Calculate referral bonus.

    /// @param depositor the address of the depositor

    /// @param terms the list of byte representation of terms

    /// @return amount of tokens affiliated with the depositor, and the actual amount of bonus

    function calculateReferralBonus(

        address depositor, bytes4[] memory terms

    ) public view returns (uint256[] memory, uint256)

    {

        require(_featureFlags.enableReferralBonus, "should only support querying referral per FF");

        uint256 bonus = 0;

        uint256[] memory amounts = new uint256[](terms.length);

        for (uint256 i = 0; i < terms.length; i++) {

            TermDepositInfo storage info = _termDeposits[terms[i]];

            require(info.duration > 0, "should be a valid term");



            Referral memory r = info.referrals[depositor];

            if (r.amount > 0 && r.withdrawAt == 0) {

                bonus = bonus.add(r.amount.mul(info.referralBonusRateBp).div(10000));

            }

            amounts[i] = r.amount;

        }

        return (amounts, bonus);

    }



    /// Retrieve referral bonus for a user given the terms.

    /// @param terms the list of byte representation of terms

    function getReferralBonus(bytes4[] memory terms) public {

        require(

            _featureFlags.enableReferralBonus,

            "should only support retrieving referral bonus per FF"

        );

        require(now >= referralBonusLockUntil, "should only allow referral bonus after unlocked");



        uint256 bonus = 0;

        for (uint256 i = 0; i < terms.length; i++) {

            TermDepositInfo storage info = _termDeposits[terms[i]];

            require(info.duration > 0, "should be a valid term");



            Referral storage r = info.referrals[msg.sender];

            if (r.amount > 0 && r.withdrawAt == 0) {

                bonus = bonus.add(r.amount.mul(info.referralBonusRateBp).div(10000));

                r.withdrawAt = now;

                info.totalReferralAmount = info.totalReferralAmount.sub(r.amount);

            }

        }

        emit GetReferralBonus(msg.sender, bonus);

        _token.safeTransfer(msg.sender, bonus);

    }



    /// Admin function to update term deposits' deadlines.

    /// @param term the byte representation of terms

    /// @param newDepositDeadline new deposit deadline

    function updateDepositDeadline(

        bytes4 term,

        uint256 newDepositDeadline

    ) public onlyWhitelistAdmin

    {

        TermDepositInfo storage info = _termDeposits[term];

        require(info.duration > 0, "should be a valid term");

        info.depositDeadline = newDepositDeadline;

    }



    /// Admin function to update referral bonus lock.

    /// @param newTime new referral bonus lock

    function updateReferralBonusLockTime(uint256 newTime) public onlyWhitelistAdmin {

        referralBonusLockUntil = newTime;

    }



    /// Return necessary amount of tokens to cover interests and referral bonuses.

    /// @param terms the list of byte representation of terms

    /// @return total deposit, total interests and total referral bonus

    function calculateTotalPayout(bytes4[] memory terms) public view returns (uint256[3] memory) {

        // [deposit, interest, bonus].

        uint256[3] memory ret;

        for (uint256 i = 0; i < terms.length; i++) {

            TermDepositInfo memory info = _termDeposits[terms[i]];

            require(info.duration > 0, "should be a valid term");

            ret[0] = ret[0].add(info.totalReceived);

            if (_featureFlags.enableInterest) {

                ret[1] = ret[1].add(info.totalReceived.mul(info.interestBp).div(10000));

            }

            if (_featureFlags.enableReferralBonus) {

                ret[2] = ret[2].add(info.totalReferralAmount.mul(info.referralBonusRateBp).div(10000));

            }

        }

        return ret;

    }



    /// Leave enough tokens for payout, and drain the surplus.

    /// @dev only admins can call this function

    function drainSurplusTokens() external onlyWhitelistAdmin {

        for (uint256 i = 0; i < allTerms.length; i++) {

            bytes4 term = allTerms[i];

            TermDepositInfo memory info = _termDeposits[term];

            require(now > info.depositDeadline, "should pass the deposit deadline");

        }

        emit Drain(msg.sender);



        uint256[3] memory payouts = calculateTotalPayout(allTerms);

        uint256 currentAmount = _token.balanceOf(address(this));

        uint256 neededAmount = payouts[0].add(payouts[1]).add(payouts[2]);

        if (currentAmount > neededAmount) {

            uint256 surplus = currentAmount.sub(neededAmount);

            _token.safeTransfer(msg.sender, surplus);

        }

    }



    /// Drain remaining tokens and destroys the contract to save some space for the network.

    /// @dev only admins can call this function

    function goodbye() external onlyWhitelistAdmin {

        // Make sure is after deposit deadline, and no received tokens.

        for (uint256 i = 0; i < allTerms.length; i++) {

            bytes4 term = allTerms[i];

            TermDepositInfo memory info = _termDeposits[term];

            require(now > info.depositDeadline, "should pass the deposit deadline");

            require(info.totalReceived < 1000 * 1e18, "should have small enough deposits");

        }

        // Transfer remaining tokens.

        uint256 tokenAmount = _token.balanceOf(address(this));

        emit Goodbye(msg.sender, tokenAmount);

        if (tokenAmount > 0) {

            _token.safeTransfer(msg.sender, tokenAmount);

        }

        // Say goodbye.

        selfdestruct(msg.sender);

    }

}