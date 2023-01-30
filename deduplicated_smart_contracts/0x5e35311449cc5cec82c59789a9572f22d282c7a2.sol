/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

contract MWT_interests is Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    bytes32 midId; // mid term partition identifier
    bytes32 lngId; // long term partition identifier
    bytes32 perId; // perpetual partition identifier

    /**
      * @dev Represents the balance of a given user. The 'previous' field is used to store the
      *     balance of the previous month in order to ponderate the bond's held time when updating
      *     interests
      */
    struct Balance {
        // Total number of tokens held last month
        uint256 previousBalance;
        // Total number of tokens held atm
        uint256 currentBalance;
        // Total number of months these tokens have been held as of last month
        uint256 previousHolding;
        // Total number of months these tokens have been held atm
        uint256 currentHolding;
        // How much tokens has been bought through referral
        uint256 refereeBalance;
        // Customizable interests rate for specific investors
        uint256 customInterestRate;
    }

    /**
      * @dev Represents all about an investor.
      */
    struct Info {
        // Calculated according to the balance, the held time, and the token type (multiply by 1000 to get the € value)
        uint256 balanceInterests;        
        // Total of midterm bond tokens
        Balance mid;
        // Total of longterm bond tokens
        Balance lng;
        // Total of perpetual bond tokens
        Balance per;
    }

    mapping (address => Info) investors;

    uint256 FLOAT_FACTOR = 100000000000000; // 10^14

    constructor(
        bytes32 _midId,
        bytes32 _lngId,
        bytes32 _perId
    )
    public
    {
        midId = _midId;
        lngId = _lngId;
        perId = _perId;
    }


    /**************************** MWT_interests events ********************************/

    event Refered (
        address referer,
        address referee,
        uint256 midAmount,
        uint256 lngAmount,
        uint256 perAmount
    );

    event ModifiedReferee (
        address investor,
        bytes32 partitionId,
        uint256 amount
    );
    event ModifiedInterests (
        address investor,
        uint256 value
    );
    event UpdatedInterests (
        address investor,
        uint256 interests
    );
    event CustomizedInterests (
        address investor,
        uint256 midRate,
        uint256 lngRate,
        uint256 perRate
    );


    /**************************** MWT_interests getters ********************************/

    /**
      * @dev Get the interests balance of an investor
      *      this needs to be divided by FLOAT_FACTOR to get the actual amount of MWT interests
      */
    function interestsOf (address investor) external view returns (uint256) {
        return (investors[investor].balanceInterests);
    }

    /**
      * @dev Get the midterm bond infos of an investor
      */
    function midtermBondInfosOf (address investor) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            investors[investor].mid.previousBalance,
            investors[investor].mid.currentBalance,
            investors[investor].mid.previousHolding,
            investors[investor].mid.currentHolding,
            investors[investor].mid.refereeBalance,
            investors[investor].mid.customInterestRate
        );
    }

    /**
      * @dev Get the longterm bond infos of an investor
      */
    function longtermBondInfosOf (address investor) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            investors[investor].lng.previousBalance,
            investors[investor].lng.currentBalance,
            investors[investor].lng.previousHolding,
            investors[investor].lng.currentHolding,
            investors[investor].lng.refereeBalance,
            investors[investor].lng.customInterestRate
        );
    }

    /**
      * @dev Get the perpetual bond infos of an investor
      */
    function perpetualBondInfosOf (address investor) external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            investors[investor].per.previousBalance,
            investors[investor].per.currentBalance,
            investors[investor].per.previousHolding,
            investors[investor].per.currentHolding,
            investors[investor].per.refereeBalance,
            investors[investor].per.customInterestRate

        );
    }

    /**************************** MWT_interests external functions ********************************/

    /**
      * @dev Set the interests balance of an investor
      *      this MUST NOT be multiplied by FLOAT_FACTOR before
      */
    function setInterests (address investor, uint256 value) external onlyOwner nonReentrant {
        investors[investor].balanceInterests = value * FLOAT_FACTOR * 10000;

        emit ModifiedInterests (investor, value);
    }

    /**
      * @dev Set a different interest rate for specific investors
      * @param investor Address for whom we decide to set a custom rate
      * @param midRate The custom midterm bond intrest rate
      * @param lngRate The custom longterm bond intrest rate
      * @param perRate The custom perpetual bond intrest rate
      */
    function setCustomInterestRate (address investor, uint256 midRate, uint256 lngRate, uint256 perRate) external onlyOwner {
        require(midRate <= 100 && lngRate <= 100 && perRate <= 100, "The rate is not a percentage");

        investors[investor].mid.customInterestRate = midRate * 100 * FLOAT_FACTOR;
        investors[investor].lng.customInterestRate = lngRate * 100 * FLOAT_FACTOR;
        investors[investor].per.customInterestRate = perRate * 100 * FLOAT_FACTOR;

        emit CustomizedInterests (investor, midRate, lngRate, perRate);
    }

    /**
      * @dev Increases the referer interests balance of a given amount
      *
      * @param referer The address of the referal initiator
      * @param referee The address of the referal consumer
      * @param percent The percentage of interests earned by the referer
      * @param midAmount How many mid term bonds the referee bought through this referal
      * @param lngAmount How many long term bonds the referee bought through this referal
      * @param perAmount How many perpetual tokens the referee bought through this referal
      */
    function updateReferralInfos (
        address referer,
        address referee,
        uint256 percent,
        uint256 midAmount,
        uint256 lngAmount,
        uint256 perAmount
    ) external onlyOwner {
        require (referer != referee && referer != address(0) && referee != address(0),
                 "Referee and/or referer address(es) is(/are) not valid.");
        require (percent >= 1 && percent <= 100, "The given percent parameter is not a valid percentage.");

        // updates referer interest balance accounting for the referee investment
        investors[referer].balanceInterests = investors[referer].balanceInterests.add(midAmount * percent * 100 * FLOAT_FACTOR);
        investors[referer].balanceInterests = investors[referer].balanceInterests.add(lngAmount * percent * 100 * FLOAT_FACTOR);
        investors[referer].balanceInterests = investors[referer].balanceInterests.add(perAmount * percent * 100 * FLOAT_FACTOR);

        investors[referee].mid.refereeBalance = investors[referee].mid.refereeBalance.add(midAmount);
        investors[referee].lng.refereeBalance = investors[referee].lng.refereeBalance.add(lngAmount);
        investors[referee].per.refereeBalance = investors[referee].per.refereeBalance.add(perAmount);

        emit Refered (referer, referee, midAmount, lngAmount, perAmount);
    }

    /**
      * @dev Set the referee balance of an investor
      *
      * @param investor The address of the investor whose balance has to be modified
      * @param partitionId The partition identifier of the token for which to modify the referee balance
      * @param amount The new referee balance of the investor
      */
    function setRefereeAmountByPartition (
        address investor,
        bytes32 partitionId,
        uint256 amount
    ) external onlyOwner {
        if ( partitionId == midId ) {
            investors[investor].mid.refereeBalance = amount;
        } else if ( partitionId == lngId ) {
            investors[investor].lng.refereeBalance = amount;
        } else if ( partitionId == perId ) {
            investors[investor].per.refereeBalance = amount;
        } else {
            revert("The partition identifier passed as parameter is not a valid one.");
        }

        emit ModifiedReferee (investor, partitionId, amount);
    }

    /**
      * @dev Updates the investor's interests
      * @dev Should (and will) be called each month
      *
      * @param investor The address of the investor for which to update interests
      * @param midBalance Balance of mid term bond
      * @param lngBalance Balance of long term bond
      * @param perBalance Balance of perpetual token
      */
    function updateInterests (address investor, uint256 midBalance, uint256 lngBalance, uint256 perBalance) external onlyOwner nonReentrant {
        // Investor's balance in each bond may have changed since last month
        investors[investor].mid.currentBalance = midBalance;
        investors[investor].lng.currentBalance = lngBalance;
        investors[investor].per.currentBalance = perBalance;

        // Increment the hodling counter : we pass to the next month. The hodling (in months) has to be adjusted
        // if the longterm or perpetual bonds balance has increased
        // A factor 1000 is applied to months to have a significant amount of digits for calculus
        if (investors[investor].mid.currentBalance > 0) {
            investors[investor].mid.currentHolding = investors[investor].mid.currentHolding.add(1000);
        }
        if (investors[investor].lng.currentBalance > 0) {
            if (investors[investor].lng.currentBalance > investors[investor].lng.previousBalance &&
                investors[investor].lng.previousBalance > 0) {
                uint256 adjustmentRate = (
                    (
                        investors[investor].lng.currentBalance.sub(investors[investor].lng.previousBalance)
                    ).mul(
                      FLOAT_FACTOR.div(
                        investors[investor].lng.currentBalance
                      )
                    )
                );
                investors[investor].lng.currentHolding = (
                  FLOAT_FACTOR.sub(adjustmentRate)
                ).mul(
                  (
                    investors[investor].lng.previousHolding.add(1000)
                  ).div(FLOAT_FACTOR)
                );
            }
            else {
                investors[investor].lng.currentHolding = investors[investor].lng.currentHolding.add(1000);
            }
        }
        if (investors[investor].per.currentBalance > 0) {
            if (investors[investor].per.currentBalance > investors[investor].per.previousBalance &&
                investors[investor].per.previousBalance > 0) {
                uint256 adjustmentRate = (
                    (
                        investors[investor].per.currentBalance.sub(investors[investor].per.previousBalance)
                    ).mul(FLOAT_FACTOR.div(investors[investor].per.currentBalance))
                );
                investors[investor].per.currentHolding = (
                  (
                    FLOAT_FACTOR.sub(adjustmentRate)
                  ).mul(
                    investors[investor].per.previousHolding.add(1000)
                  ).div(FLOAT_FACTOR)
                );
            }
            else {
                investors[investor].per.currentHolding = investors[investor].per.currentHolding.add(1000);
            }
        }

        // Update the investor's total interests
        if (investors[investor].mid.customInterestRate > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].mid.customInterestRate.mul(investors[investor].mid.currentBalance)
              ).div(12)
            );
        }
        if (investors[investor].lng.customInterestRate > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].lng.customInterestRate.mul(investors[investor].lng.currentBalance)
              ).div(12)
            );
        }
        if (investors[investor].per.customInterestRate > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].per.customInterestRate.mul(investors[investor].per.currentBalance)
              ).div(12)
            );
        }
        if (investors[investor].mid.customInterestRate == 0 &&
            investors[investor].lng.customInterestRate == 0 &&
            investors[investor].per.customInterestRate == 0) {
          _minterest(investor);
        }

        // We pass to the next month, hence the previous month is now the current one :D
        investors[investor].per.previousHolding = investors[investor].per.currentHolding;
        investors[investor].lng.previousHolding = investors[investor].lng.currentHolding;

        // Same thing for balances
        investors[investor].per.previousBalance = investors[investor].per.currentBalance;
        investors[investor].mid.previousBalance = investors[investor].mid.currentBalance;
        investors[investor].lng.previousBalance = investors[investor].lng.currentBalance;

        emit UpdatedInterests (investor, investors[investor].balanceInterests);
    }


    /******************** MWT_interests internal functions ************************/

    /**
     *  @dev Calculate the investor's total interests given how many tokens he holds, their type, and
     *       for how long he's been holding them.
     *       For midterm bonds tokens, the interest rate is constant. For longterm and perpetual bonds tokens
     *       rates are given by a table designed by the token issuer (Montessori Worldwide) which is
     *       translated in Solidity as a set of conditions.
     */
    function _minterest (address investor) internal {
        // midRate represents the interest rate of the user's midterm bonds multiplied by 10^13 (10000 * FLOAT_FACTOR)
        uint256 midRate = FLOAT_FACTOR.mul(575);

        // lngRate represents the interest rate of the user's midterm bonds multiplied by 10^13 (10000 * FLOAT_FACTOR)
        uint256 lngRate = 0;
        if (investors[investor].lng.currentBalance > 0) {
            if (investors[investor].lng.currentHolding < 12000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(700);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(730);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(749);
                }
                else {
                    lngRate = FLOAT_FACTOR.mul(760);
                }
            }
            else if (investors[investor].lng.currentHolding < 36000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(730);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(745);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(756);
                }
                else {
                    lngRate = FLOAT_FACTOR.mul(764);
                }
            }
            else if (investors[investor].lng.currentHolding < 72000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(749);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(757);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(763);
                }
                else {
                    lngRate = FLOAT_FACTOR.mul(767);
                }
            }
            else if (investors[investor].lng.currentHolding >= 72000) {
                if (investors[investor].lng.currentBalance < 800) {
                    lngRate = FLOAT_FACTOR.mul(760);
                }
                else if (investors[investor].lng.currentBalance < 2400) {
                    lngRate = FLOAT_FACTOR.mul(764);
                }
                else if (investors[investor].lng.currentBalance < 7200) {
                    lngRate = FLOAT_FACTOR.mul(767);
                }
                else if (investors[investor].lng.currentBalance >= 7200) {
                    lngRate = FLOAT_FACTOR.mul(770);
                }
            }
            assert(lngRate != 0);
        }

        // perRate represents the interest rate of the user's midterm bonds multiplied by 10^13 (10000 * FLOAT_FACTOR)
        uint256 perRate = 0;
        if (investors[investor].per.currentBalance > 0) {
            if (investors[investor].per.currentHolding < 12000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(850);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(888);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(911);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(925);
                }
            }
            else if (investors[investor].per.currentHolding < 36000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(888);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(906);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(919);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(930);
                }
            }
            else if (investors[investor].per.currentHolding < 72000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(911);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(919);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(927);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(934);
                }
            }
            else if (investors[investor].per.currentHolding >= 72000) {
                if (investors[investor].per.currentBalance < 800) {
                    perRate = FLOAT_FACTOR.mul(925);
                }
                else if (investors[investor].per.currentBalance < 2400) {
                    perRate = FLOAT_FACTOR.mul(930);
                }
                else if (investors[investor].per.currentBalance < 7200) {
                    perRate = FLOAT_FACTOR.mul(934);
                }
                else if (investors[investor].per.currentBalance >= 7200) {
                    perRate = FLOAT_FACTOR.mul(937);
                }
            }
            assert(perRate != 0);
        }

        // The total user interests are incremented by this month's interests in each bond
        // We divide by 12 because the interest rate is calculated on a yearly basis
        // "102" factor is applied in the case the user benefits from the referee bonus of 2% (only applies to the "referee" balance)
        if (investors[investor].mid.refereeBalance > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  midRate.mul(102)
                ).mul(investors[investor].mid.refereeBalance)
              ).div(1200)
            );
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  investors[investor].mid.currentBalance.sub(investors[investor].mid.refereeBalance)
                ).mul(midRate)
              ).div(12)
            );
        } else {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                investors[investor].mid.currentBalance.mul(midRate)
              ).div(12)
            );
        }

        if (investors[investor].lng.refereeBalance > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  lngRate.mul(102)
                ).mul(investors[investor].lng.refereeBalance)
              ).div(1200)
            );
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  investors[investor].lng.currentBalance.sub(investors[investor].lng.refereeBalance)
                ).mul(lngRate)
              ).div(12)
            );
        } else {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                lngRate.mul(investors[investor].lng.currentBalance)
              ).div(12)
            );
        }    

        if (investors[investor].per.refereeBalance > 0) {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  perRate.mul(investors[investor].per.refereeBalance)
                ).mul(102)
              ).div(1200)
            );
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                (
                  investors[investor].per.currentBalance.sub(investors[investor].per.refereeBalance)
                ).mul(perRate)
              ).div(12)
            );
        } else {
            investors[investor].balanceInterests = investors[investor].balanceInterests.add(
              (
                perRate.mul(investors[investor].per.currentBalance)
              ).div(12)
            );
        }
    }
}