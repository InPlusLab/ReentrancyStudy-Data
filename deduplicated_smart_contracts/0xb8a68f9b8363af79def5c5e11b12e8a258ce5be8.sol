/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Onigiri.sol

pragma solidity ^0.5.8;



contract Onigiri is Ownable {
    using SafeMath for uint256;

    struct InvestorInfo {
        uint256 invested;
        uint256 lockbox;
        uint256 withdrawn;
        uint256 lastInvestmentTime;
    }
    
    mapping (address => InvestorInfo) public investors;
    mapping (address => uint256) public affiliateCommission;
    mapping (address => uint256) public devCommission;
    mapping (address => uint256) public amountForAddressToMigrate;

    uint256 public investorsCount;
    uint256 public lockboxTotal;
    uint256 public withdrawnProfitTotal;
    uint256 public affiliateCommissionWithdrawnTotal;
    
    uint256 public donatedTotal;
    uint256 public gamesIncomeTotal;
    
    address private constant dev_0_master = 0x6a5D9648381b90AF0e6881c26739efA4379c19B2;
    address private constant dev_1_master = 0xDBd32Ef31Fcd7fc1EF028A7471a7A9BFC39ab609;
    address private dev_0_escrow = 0xF57924672D6dBF0336c618fDa50E284E02715000;
    address private dev_1_escrow = 0xE4Cf94e5D30FB4406A2B139CD0e872a1C8012dEf;

    uint256 public constant minInvest = 0.025 ether;
    uint256 public constant whaleLimitLockbox = 500 ether;
    uint256 public constant whaleLimitInvest = 50 ether;

    event Migrated(address indexed investor, uint256 amount);
    event Invested(address indexed investor, uint256 amount);
    event Reinvested(address indexed investor, uint256 amount);
    event WithdrawnAffiliateCommission(address indexed affiliate, uint256 amount);
    event WithdrawnProfit(address indexed investor, uint256 amount);
    event WithdrawnLockBoxPartially(address indexed investor, uint256 amount);
    event WithdrawnLockboxAndClosed(address indexed investor, uint256 amount);

    /**
     * PUBLIC
     */

    //  MIGRATION
    /**
     * @dev Adds addresses and corresponding deposit amounts to be migrated from OB 1.0
     * @param _addressList List of addresses.
     * @param _amountList List of corresponding deposit amounts.
    */
    function addAddressesAndAmountsToMigrate(address[] memory _addressList, uint256[] memory _amountList) public onlyOwner {
        require(_addressList.length == _amountList.length, "length is not equal");
        
        for (uint256 i = 0; i < _addressList.length; i ++) {
            amountForAddressToMigrate[_addressList[i]] = _amountList[i];
        }
    }

    function migrateFunds() public payable {
        require(amountForAddressToMigrate[msg.sender] > 0, "not allowed");
        require(msg.value == amountForAddressToMigrate[msg.sender], "wrong amount");

        amountForAddressToMigrate[msg.sender] = 0;

        if(getLastInvestmentTime(msg.sender) == 0) {
            investorsCount = investorsCount.add(1);
        }

        investors[msg.sender].lockbox = investors[msg.sender].lockbox.add(msg.value);
        investors[msg.sender].invested = investors[msg.sender].invested.add(msg.value);
        investors[msg.sender].lastInvestmentTime = now;
        delete investors[msg.sender].withdrawn;
        
        lockboxTotal = lockboxTotal.add(msg.value);

        emit Migrated(msg.sender, msg.value);
    }
    //  MIGRATION

     function() external payable {
        donate();
     }

     /**
     * @dev Donation for Onigiry ecosystem.
     * TESTED
     */
    function donate() public payable {
        //  2% - to developers
        uint256 devFee = msg.value.div(100);
        devCommission[dev_0_escrow] = devCommission[dev_0_escrow].add(devFee);
        devCommission[dev_1_escrow] = devCommission[dev_1_escrow].add(devFee);
        
        donatedTotal = donatedTotal.add(msg.value);
    }

    /**
     * @dev Accepts income from games for Onigiry ecosystem.
     * TESTED
     */
    function fromGame() external payable {
        //  4% - to developers
        uint256 devFee = msg.value.div(100).mul(2);
        devCommission[dev_0_escrow] = devCommission[dev_0_escrow].add(devFee);
        devCommission[dev_1_escrow] = devCommission[dev_1_escrow].add(devFee);
        
        gamesIncomeTotal = gamesIncomeTotal.add(msg.value);
    }

    /**
     * @dev Returns invested amount for investor.
     * @param _address Investor address.
     * @return invested amount.
     * TESTED
     */
    function getInvested(address _address) public view returns(uint256) {
        return investors[_address].invested;
    }

    /**
     * @dev Returns lockbox amount for investor.
     * @param _address Investor address.
     * @return lockbox amount.
     * TESTED
     */
    function getLockBox(address _address) public view returns(uint256) {
        return investors[_address].lockbox;
    }

    /**
     * @dev Returns withdrawn amount for investor.
     * @param _address Investor address.
     * @return withdrawn amount.
     * TESTED
     */
    function getWithdrawn(address _address) public view returns(uint256) {
        return investors[_address].withdrawn;
    }

    /**
     * @dev Returns last investment time amount for investor.
     * @param _address Investor address.
     * @return last investment time.
     * TESTED
     */
    function getLastInvestmentTime(address _address) public view returns(uint256) {
        return investors[_address].lastInvestmentTime;
    }

    /**
     * @dev Gets balance for current contract.
     * @return balance for current contract.
     * TESTED
     */
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    /**
     * @dev Calculates sum for lockboxes and dev fees.
     * @return Amount of guaranteed balance by constract.
     * TESTED
     */
    function guaranteedBalance() public view returns(uint256) {
        return lockboxTotal.add(devCommission[dev_0_escrow]).add(devCommission[dev_1_escrow]);
    }

    /**
     * @dev User invests funds.
     * @param _affiliate affiliate address.
     * TESTED
     */
    function invest(address _affiliate) public payable {
        require(msg.value >= minInvest, "min 0.025 eth");
        if(lockboxTotal <= whaleLimitLockbox) {
            require(msg.value <= whaleLimitInvest, "max invest 50 eth");
        }

        if(calculateProfit(msg.sender) > 0){
            withdrawProfit();
        }

        //  1% - to affiliateCommission
        if(_affiliate != msg.sender && _affiliate != address(0)) {
            uint256 commission = msg.value.div(100);
            affiliateCommission[_affiliate] = affiliateCommission[_affiliate].add(commission);
        }

        if(getLastInvestmentTime(msg.sender) == 0) {
            investorsCount = investorsCount.add(1);
        }

        uint256 lockboxAmount = msg.value.div(100).mul(84);
        investors[msg.sender].lockbox = investors[msg.sender].lockbox.add(lockboxAmount);
        investors[msg.sender].invested = investors[msg.sender].invested.add(msg.value);
        investors[msg.sender].lastInvestmentTime = now;
        delete investors[msg.sender].withdrawn;
        
        lockboxTotal = lockboxTotal.add(lockboxAmount);
        
        //  4% - to developers
        uint256 devFee = msg.value.div(100).mul(2);
        devCommission[dev_0_escrow] = devCommission[dev_0_escrow].add(devFee);
        devCommission[dev_1_escrow] = devCommission[dev_1_escrow].add(devFee);

        emit Invested(msg.sender, msg.value);
    }

    /**
     * @dev Updates escrow address for developer.
     * @param _address Address of escrow to be used.
     * TESTED
     */
    function updateDevEscrow(address _address) public {
        require(msg.sender == dev_0_master || msg.sender == dev_1_master, "not dev");
        (msg.sender == dev_0_master) ? dev_0_escrow = _address : dev_1_escrow = _address;
    }

    /**
     * @dev Allows developer to withdraw commission.
     * TESTED
     */
    function withdrawDevCommission() public {
        uint256 commission = devCommission[msg.sender];
        require(commission > 0, "no dev commission");
        require(address(this).balance.sub(commission) >= lockboxTotal, "not enough funds");

        delete devCommission[msg.sender];
        msg.sender.transfer(commission);
    }
    
    /**
     * @dev Withdraws affiliate commission for current address.
     * TESTED
     */
    function withdrawAffiliateCommission() public {
        uint256 commission = affiliateCommission[msg.sender];
        require(commission > 0, "no commission");
        require(address(this).balance.sub(commission) >= guaranteedBalance(), "not enough funds");

        delete affiliateCommission[msg.sender];
        affiliateCommissionWithdrawnTotal = affiliateCommissionWithdrawnTotal.add(commission);

        msg.sender.transfer(commission);

        emit WithdrawnAffiliateCommission(msg.sender, commission);
    }

    /**
     * @dev Withdraws profit.
     * TESTED
     */
    function withdrawProfit() public {
        uint256 profit = calculateProfit(msg.sender);
        require(profit > 0, "No profit");
        require(address(this).balance.sub(profit) >= guaranteedBalance(), "Not enough funds");
        
        investors[msg.sender].withdrawn = investors[msg.sender].withdrawn.add(profit);
        withdrawnProfitTotal = withdrawnProfitTotal.add(profit);
        investors[msg.sender].lastInvestmentTime = now;
        
        //  2% - to developers
        uint256 devFee = profit.div(100);
        devCommission[dev_0_escrow] = devCommission[dev_0_escrow].add(devFee);
        devCommission[dev_1_escrow] = devCommission[dev_1_escrow].add(devFee);
        
        //  3% - stay in contract
        msg.sender.transfer(profit.div(100).mul(95));

        emit WithdrawnProfit(msg.sender, profit);
    }

    /**
     * @dev Allows investor to withdraw lockbox funds, close deposit and clear all data.
     * @notice Pending profit stays in contract.
     * TESTED
     */
    function withdrawLockBoxAndClose() public {
        uint256 lockboxAmount = getLockBox(msg.sender);
        require(lockboxAmount > 0, "No investments");

        delete investors[msg.sender];
        investorsCount = investorsCount.sub(1);
        lockboxTotal = lockboxTotal.sub(lockboxAmount);

        msg.sender.transfer(lockboxAmount);

        emit WithdrawnLockboxAndClosed(msg.sender, lockboxAmount);
    }

    /**
     * @dev Allows investor to withdraw part of lockbox funds.
     * @param _amount Amount to withdraw.
     * TESTED
     */
    function withdrawLockBoxPartially(uint256 _amount) public {
        require(_amount > 0, "No amount");

        uint256 lockboxAmount = getLockBox(msg.sender);
        require(lockboxAmount > 0, "No investments");
        require(_amount <= lockboxAmount, "Not enough lockBox");

        if (_amount == lockboxAmount) {
            withdrawLockBoxAndClose();
            return;
        }

        investors[msg.sender].lockbox = investors[msg.sender].lockbox.sub(_amount);
        lockboxTotal = lockboxTotal.sub(_amount);
        msg.sender.transfer(_amount);

        emit WithdrawnLockBoxPartially(msg.sender, _amount);
    }
    
    /**
     * @dev Reinvests pending profit.
     * TESTED
     */
    function reinvestProfit() public {
        uint256 profit = calculateProfit(msg.sender);
        require(profit > 0, "No profit");
        require(address(this).balance.sub(profit) >= guaranteedBalance(), "not enough funds");
        
        uint256 lockboxFromProfit = profit.div(100).mul(84);
        investors[msg.sender].lockbox = investors[msg.sender].lockbox.add(lockboxFromProfit);
        investors[msg.sender].invested = investors[msg.sender].invested.add(profit);
        investors[msg.sender].lastInvestmentTime = now;
        delete investors[msg.sender].withdrawn;

        lockboxTotal = lockboxTotal.add(lockboxFromProfit);

        emit Reinvested(msg.sender, profit);
    }

    /**
     * @dev Calculates pending profit for provided customer.
     * @param _investor Address of investor.
     * @return pending profit.
     * TESTED
     */
    function calculateProfit(address _investor) public view returns(uint256){
        uint256 hourDifference = now.sub(investors[_investor].lastInvestmentTime).div(3600);
        uint256 rate = percentRateInternal(investors[_investor].lockbox);
        uint256 calculatedPercent = hourDifference.mul(rate);
        return investors[_investor].lockbox.div(100000).mul(calculatedPercent);
    }

    /**
     * @dev Calculates rate for lockbox balance for msg.sender.
     * @param _balance Balance to calculate percentage.
     * @return rate for lockbox balance.
     * TESTED
     */
    function percentRateInternal(uint256 _balance) private pure returns(uint256) {
        /**
            ~ .99 -    - 0.6%
            1 ~ 50     - 0.72% 
            51 ~ 100   - 0.84% 
            100 ~ 250  - 0.96% 
            250 ~      - 1.08% 
         */
        uint256 step_1 = .99 ether;
        uint256 step_2 = 50 ether;
        uint256 step_3 = 100 ether;
        uint256 step_4 = 250 ether;

        uint256 dailyPercent_0 = 25;   //  0.6%
        uint256 dailyPercent_1 = 30;   //  0.72%
        uint256 dailyPercent_2 = 35;   //  0.84%
        uint256 dailyPercent_3 = 40;   //  0.96%
        uint256 dailyPercent_4 = 45;   //  1.08%

        if (_balance >= step_4) {
            return dailyPercent_4;
        } else if (_balance >= step_3 && _balance < step_4) {
            return dailyPercent_3;
        } else if (_balance >= step_2 && _balance < step_3) {
            return dailyPercent_2;
        } else if (_balance >= step_1 && _balance < step_2) {
            return dailyPercent_1;
        }

        return dailyPercent_0;
    }

    /**
     * @dev Calculates rate for lockbox balance for msg.sender. User for public
     * @param _balance Balance to calculate percentage.
     * @return rate for lockbox balance.
     * TESTED
     */
    function percentRatePublic(uint256 _balance) public pure returns(uint256) {
        /**
            ~ .99 -    - 0.6%
            1 ~ 50     - 0.72% 
            51 ~ 100   - 0.84% 
            100 ~ 250  - 0.96% 
            250 ~      - 1.08% 
         */
        uint256 step_1 = .99 ether;
        uint256 step_2 = 50 ether;
        uint256 step_3 = 100 ether;
        uint256 step_4 = 250 ether;

        uint256 dailyPercent_0 = 60;   //  0.6%
        uint256 dailyPercent_1 = 72;   //  0.72%
        uint256 dailyPercent_2 = 84;   //  0.84%
        uint256 dailyPercent_3 = 96;   //  0.96%
        uint256 dailyPercent_4 = 108;   //  1.08%

        if (_balance >= step_4) {
            return dailyPercent_4;
        } else if (_balance >= step_3 && _balance < step_4) {
            return dailyPercent_3;
        } else if (_balance >= step_2 && _balance < step_3) {
            return dailyPercent_2;
        } else if (_balance >= step_1 && _balance < step_2) {
            return dailyPercent_1;
        }

        return dailyPercent_0;
    }
}