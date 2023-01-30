pragma solidity 0.5.10;

import './SafeMath.sol';
import './Eraswap.sol';
import './NRTManager.sol';

/*

Potential bugs: this contract is designed assuming NRT Release will happen every month.
There might be issues when the NRT scheduled
- added stakingMonth property in Staking struct

fix withdraw fractionFrom15 luck pool
- done

add loanactive contition to take loan
- done

ensure stakingMonth in the struct is being used every where instead of calculation
- done

remove local variables uncesessary

final the earthSecondsInMonth amount in TimeAlly as well in NRT

add events for required functions
*/

/// @author The EraSwap Team
/// @title TimeAlly Smart Contract
/// @dev all require statement message strings are commented to make contract deployable by lower the deploying gas fee
contract TimeAlly {
    using SafeMath for uint256;

    struct Staking {
        uint256 exaEsAmount;
        uint256 timestamp;
        uint256 stakingMonth;
        uint256 stakingPlanId;
        uint256 status; /// @dev 1 => active; 2 => loaned; 3 => withdrawed; 4 => cancelled; 5 => nomination mode
        uint256 loanId;
        uint256 totalNominationShares;
        mapping (uint256 => bool) isMonthClaimed;
        mapping (address => uint256) nomination;
    }

    struct StakingPlan {
        uint256 months;
        uint256 fractionFrom15; /// @dev fraction of NRT released. Alotted to TimeAlly is 15% of NRT
        // bool isPlanActive; /// @dev when plan is inactive, new stakings must not be able to select this plan. Old stakings which already selected this plan will continue themselves as per plan.
        bool isUrgentLoanAllowed; /// @dev if urgent loan is not allowed then staker can take loan only after 75% (hard coded) of staking months
    }

    struct Loan {
        uint256 exaEsAmount;
        uint256 timestamp;
        uint256 loanPlanId;
        uint256 status; // @dev 1 => not repayed yet; 2 => repayed
        uint256[] stakingIds;
    }

    struct LoanPlan {
        uint256 loanMonths;
        uint256 loanRate; // @dev amount of charge to pay, this will be sent to luck pool
        uint256 maxLoanAmountPercent; /// @dev max loan user can take depends on this percent of the plan and the stakings user wishes to put for the loan
    }

    uint256 public deployedTimestamp;
    address public owner;
    Eraswap public token;
    NRTManager public nrtManager;

    /// @dev 1 Year = 365.242 days for taking care of leap years
    uint256 public earthSecondsInMonth = 2629744;
    // uint256 earthSecondsInMonth = 30 * 12 * 60 * 60; /// @dev there was a decision for following 360 day year

    StakingPlan[] public stakingPlans;
    LoanPlan[] public loanPlans;

    // user activity details:
    mapping(address => Staking[]) public stakings;
    mapping(address => Loan[]) public loans;
    mapping(address => uint256) public launchReward;

    /// @dev TimeAlly month to exaEsAmount mapping.
    mapping (uint256 => uint256) public totalActiveStakings;

    /// @notice NRT being received from NRT Manager every month is stored in this array
    /// @dev current month is the length of this array
    uint256[] public timeAllyMonthlyNRT;

    event NewStaking (
        address indexed _userAddress,
        uint256 indexed _stakePlanId,
        uint256 _exaEsAmount,
        uint256 _stakingId
    );

    event PrincipalWithdrawl (
        address indexed _userAddress,
        uint256 _stakingId
    );

    event NomineeNew (
        address indexed _userAddress,
        uint256 indexed _stakingId,
        address indexed _nomineeAddress
    );

    event NomineeWithdraw (
        address indexed _userAddress,
        uint256 indexed _stakingId,
        address indexed _nomineeAddress,
        uint256 _liquid,
        uint256 _accrued
    );

    event BenefitWithdrawl (
        address indexed _userAddress,
        uint256 _stakingId,
        uint256[] _months,
        uint256 _halfBenefit
    );

    event NewLoan (
        address indexed _userAddress,
        uint256 indexed _loanPlanId,
        uint256 _exaEsAmount,
        uint256 _loanInterest,
        uint256 _loanId
    );

    event RepayLoan (
        address indexed _userAddress,
        uint256 _loanId
    );


    modifier onlyNRTManager() {
        require(
          msg.sender == address(nrtManager)
          // , 'only NRT manager can call'
        );
        _;
    }

    modifier onlyOwner() {
        require(
          msg.sender == owner
          // , 'only deployer can call'
        );
        _;
    }

    /// @notice sets up TimeAlly contract when deployed
    /// @param _tokenAddress - is EraSwap contract address
    /// @param _nrtAddress - is NRT Manager contract address
    constructor(address _tokenAddress, address _nrtAddress) public {
        owner = msg.sender;
        token = Eraswap(_tokenAddress);
        nrtManager = NRTManager(_nrtAddress);
        deployedTimestamp = now;
        timeAllyMonthlyNRT.push(0); /// @dev first month there is no NRT released
    }

    /// @notice this function is used by NRT manager to communicate NRT release to TimeAlly
    function increaseMonth(uint256 _timeAllyNRT) public onlyNRTManager {
        timeAllyMonthlyNRT.push(_timeAllyNRT);
    }

    /// @notice TimeAlly month is dependent on the monthly NRT release
    /// @return current month is the TimeAlly month
    function getCurrentMonth() public view returns (uint256) {
        return timeAllyMonthlyNRT.length - 1;
    }

    /// @notice this function is used by owner to create plans for new stakings
    /// @param _months - is number of staking months of a plan. for eg. 12 months
    /// @param _fractionFrom15 - NRT fraction (max 15%) benefit to be given to user. rest is sent back to NRT in Luck Pool
    /// @param _isUrgentLoanAllowed - if urgent loan is not allowed then staker can take loan only after 75% of time elapsed
    function createStakingPlan(uint256 _months, uint256 _fractionFrom15, bool _isUrgentLoanAllowed) public onlyOwner {
        stakingPlans.push(StakingPlan({
            months: _months,
            fractionFrom15: _fractionFrom15,
            // isPlanActive: true,
            isUrgentLoanAllowed: _isUrgentLoanAllowed
        }));
    }

    /// @notice this function is used by owner to create plans for new loans
    /// @param _loanMonths - number of months or duration of loan, loan taker must repay the loan before this period
    /// @param _loanRate - this is total % of loaning amount charged while taking loan, this charge is sent to luckpool in NRT manager which ends up distributed back to the community again
    function createLoanPlan(uint256 _loanMonths, uint256 _loanRate, uint256 _maxLoanAmountPercent) public onlyOwner {
        require(_maxLoanAmountPercent <= 100
            // , 'everyone should not be able to take loan more than 100 percent of their stakings'
        );
        loanPlans.push(LoanPlan({
            loanMonths: _loanMonths,
            loanRate: _loanRate,
            maxLoanAmountPercent: _maxLoanAmountPercent
        }));
    }



    /// @notice takes ES from user and locks it for a time according to plan selected by user
    /// @param _exaEsAmount - amount of ES tokens (in 18 decimals thats why 'exa') that user wishes to stake
    /// @param _stakingPlanId - plan for staking
    function newStaking(uint256 _exaEsAmount, uint256 _stakingPlanId) public {

        /// @dev 0 ES stakings would get 0 ES benefits and might cause confusions as transaction would confirm but total active stakings will not increase
        require(_exaEsAmount > 0
            // , 'staking amount should be non zero'
        );

        require(token.transferFrom(msg.sender, address(this), _exaEsAmount)
          // , 'could not transfer tokens'
        );
        uint256 stakeEndMonth = getCurrentMonth() + stakingPlans[_stakingPlanId].months;

        // @dev update the totalActiveStakings array so that staking would be automatically inactive after the stakingPlanMonthhs
        for(
          uint256 month = getCurrentMonth() + 1;
          month <= stakeEndMonth;
          month++
        ) {
            totalActiveStakings[month] = totalActiveStakings[month].add(_exaEsAmount);
        }

        stakings[msg.sender].push(Staking({
            exaEsAmount: _exaEsAmount,
            timestamp: now,
            stakingMonth: getCurrentMonth(),
            stakingPlanId: _stakingPlanId,
            status: 1,
            loanId: 0,
            totalNominationShares: 0
        }));

        emit NewStaking(msg.sender, _stakingPlanId, _exaEsAmount, stakings[msg.sender].length - 1);
    }

    /// @notice this function is used to see total stakings of any user of TimeAlly
    /// @param _userAddress - address of user
    /// @return number of stakings of _userAddress
    function getNumberOfStakingsByUser(address _userAddress) public view returns (uint256) {
        return stakings[_userAddress].length;
    }

    /// @notice this function is used to topup reward balance in smart contract. Rewards are transferable. Anyone with reward balance can only claim it as a new staking.
    /// @dev Allowance is required before topup.
    /// @param _exaEsAmount - amount to add to your rewards for sending rewards to others
    function topupRewardBucket(uint256 _exaEsAmount) public {
        require(token.transferFrom(msg.sender, address(this), _exaEsAmount));
        launchReward[msg.sender] = launchReward[msg.sender].add(_exaEsAmount);
    }

    /// @notice this function is used to send rewards to multiple users
    /// @param _addresses - array of address to send rewards
    /// @param _exaEsAmountArray - array of ExaES amounts sent to each address of _addresses with same index
    function giveLaunchReward(address[] memory _addresses, uint256[] memory _exaEsAmountArray) public onlyOwner {
        for(uint256 i = 0; i < _addresses.length; i++) {
            launchReward[msg.sender] = launchReward[msg.sender].sub(_exaEsAmountArray[i]);
            launchReward[_addresses[i]] = launchReward[_addresses[i]].add(_exaEsAmountArray[i]);
        }
    }

    /// @notice this function is used by rewardees to claim their accrued rewards. This is also used by stakers to restake their 50% benefit received as rewards
    /// @param _stakingPlanId - rewardee can choose plan while claiming rewards as stakings
    function claimLaunchReward(uint256 _stakingPlanId) public {
        // require(stakingPlans[_stakingPlanId].isPlanActive
        //     // , 'selected plan is not active'
        // );

        require(launchReward[msg.sender] > 0
            // , 'launch reward should be non zero'
        );
        uint256 reward = launchReward[msg.sender];
        launchReward[msg.sender] = 0;

        // @dev logic similar to newStaking function
        uint256 stakeEndMonth = getCurrentMonth() + stakingPlans[_stakingPlanId].months;

        // @dev update the totalActiveStakings array so that staking would be automatically inactive after the stakingPlanMonthhs
        for(
          uint256 month = getCurrentMonth() + 1;
          month <= stakeEndMonth;
          month++
        ) {
            totalActiveStakings[month] = totalActiveStakings[month].add(reward); /// @dev reward means locked ES which only staking option
        }

        stakings[msg.sender].push(Staking({
            exaEsAmount: reward,
            timestamp: now,
            stakingMonth: getCurrentMonth(),
            stakingPlanId: _stakingPlanId,
            status: 1,
            loanId: 0,
            totalNominationShares: 0
        }));

        emit NewStaking(msg.sender, _stakingPlanId, reward, stakings[msg.sender].length - 1);
    }


    /// @notice used internally to see if staking is active or not. does not include if staking is claimed.
    /// @param _userAddress - address of user
    /// @param _stakingId - staking id
    /// @param _atMonth - particular month to check staking active
    /// @return true is staking is in correct time frame and also no loan on it
    function isStakingActive(
        address _userAddress,
        uint256 _stakingId,
        uint256 _atMonth
    ) public view returns (bool) {
        //uint256 stakingMonth = stakings[_userAddress][_stakingId].timestamp.sub(deployedTimestamp).div(earthSecondsInMonth);

        return (
            /// @dev _atMonth should be a month after which staking starts
            stakings[_userAddress][_stakingId].stakingMonth + 1 <= _atMonth

            /// @dev _atMonth should be a month before which staking ends
            && stakings[_userAddress][_stakingId].stakingMonth + stakingPlans[ stakings[_userAddress][_stakingId].stakingPlanId ].months >= _atMonth

            /// @dev staking should have active status
            && stakings[_userAddress][_stakingId].status == 1

            /// @dev if _atMonth is current Month, then withdrawal should be allowed only after 30 days interval since staking
            && (
              getCurrentMonth() != _atMonth
              || now >= stakings[_userAddress][_stakingId].timestamp
                          .add(
                            getCurrentMonth()
                              .sub(stakings[_userAddress][_stakingId].stakingMonth)
                              .mul(earthSecondsInMonth)
                          )
              )
            );
    }


    /// @notice this function is used for seeing the benefits of a staking of any user
    /// @param _userAddress - address of user
    /// @param _stakingId - staking id
    /// @param _months - array of months user is interested to see benefits.
    /// @return amount of ExaES of benefits of entered months
    function seeBenefitOfAStakingByMonths(
        address _userAddress,
        uint256 _stakingId,
        uint256[] memory _months
    ) public view returns (uint256) {
        uint256 benefitOfAllMonths;
        for(uint256 i = 0; i < _months.length; i++) {
            /// @dev this require statement is converted into if statement for easier UI fetching. If there is no benefit for a month or already claimed, it will consider benefit of that month as 0 ES. But same is not done for withdraw function.
            // require(
            //   isStakingActive(_userAddress, _stakingId, _months[i])
            //   && !stakings[_userAddress][_stakingId].isMonthClaimed[_months[i]]
            //   // , 'staking must be active'
            // );
            if(isStakingActive(_userAddress, _stakingId, _months[i])
            && !stakings[_userAddress][_stakingId].isMonthClaimed[_months[i]]) {
                uint256 benefit = stakings[_userAddress][_stakingId].exaEsAmount
                                  .mul(timeAllyMonthlyNRT[ _months[i] ])
                                  .div(totalActiveStakings[ _months[i] ]);
                benefitOfAllMonths = benefitOfAllMonths.add(benefit);
            }
        }
        return benefitOfAllMonths.mul(
          stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].fractionFrom15
        ).div(15);
    }

    /// @notice this function is used for withdrawing the benefits of a staking of any user
    /// @param _stakingId - staking id
    /// @param _months - array of months user is interested to withdraw benefits of staking.
    function withdrawBenefitOfAStakingByMonths(
        uint256 _stakingId,
        uint256[] memory _months
    ) public {
        uint256 _benefitOfAllMonths;
        for(uint256 i = 0; i < _months.length; i++) {
            // require(
            //   isStakingActive(msg.sender, _stakingId, _months[i])
            //   && !stakings[msg.sender][_stakingId].isMonthClaimed[_months[i]]
            //   // , 'staking must be active'
            // );
            if(isStakingActive(msg.sender, _stakingId, _months[i])
            && !stakings[msg.sender][_stakingId].isMonthClaimed[_months[i]]) {
                uint256 _benefit = stakings[msg.sender][_stakingId].exaEsAmount
                                  .mul(timeAllyMonthlyNRT[ _months[i] ])
                                  .div(totalActiveStakings[ _months[i] ]);

                _benefitOfAllMonths = _benefitOfAllMonths.add(_benefit);
                stakings[msg.sender][_stakingId].isMonthClaimed[_months[i]] = true;
            }
        }

        uint256 _luckPool = _benefitOfAllMonths
                        .mul( uint256(15).sub(stakingPlans[stakings[msg.sender][_stakingId].stakingPlanId].fractionFrom15) )
                        .div( 15 );

        require( token.transfer(address(nrtManager), _luckPool) );
        require( nrtManager.UpdateLuckpool(_luckPool) );

        _benefitOfAllMonths = _benefitOfAllMonths.sub(_luckPool);

        uint256 _halfBenefit = _benefitOfAllMonths.div(2);
        require( token.transfer(msg.sender, _halfBenefit) );

        launchReward[msg.sender] = launchReward[msg.sender].add(_halfBenefit);

        // emit event
        emit BenefitWithdrawl(msg.sender, _stakingId, _months, _halfBenefit);
    }


    /// @notice this function is used to withdraw the principle amount of multiple stakings which have their tenure completed
    /// @param _stakingIds - input which stakings to withdraw
    function withdrawExpiredStakings(uint256[] memory _stakingIds) public {
        for(uint256 i = 0; i < _stakingIds.length; i++) {
            require(now >= stakings[msg.sender][_stakingIds[i]].timestamp
                    .add(stakingPlans[ stakings[msg.sender][_stakingIds[i]].stakingPlanId ].months.mul(earthSecondsInMonth))
              // , 'cannot withdraw before staking ends'
            );
            stakings[msg.sender][_stakingIds[i]].status = 3;

            token.transfer(msg.sender, stakings[msg.sender][_stakingIds[i]].exaEsAmount);

            emit PrincipalWithdrawl(msg.sender, _stakingIds[i]);
        }
    }

    /// @notice this function is used to estimate the maximum amount of loan that any user can take with their stakings
    /// @param _userAddress - address of user
    /// @param _stakingIds - array of staking ids which should be used to estimate max loan amount
    /// @param _loanPlanId - the loan plan user wishes to take loan.
    /// @return max loaning amount
    function seeMaxLoaningAmountOnUserStakings(address _userAddress, uint256[] memory _stakingIds, uint256 _loanPlanId) public view returns (uint256) {
        uint256 _currentMonth = getCurrentMonth();
        //require(_currentMonth >= _atMonth, 'cannot see future stakings');

        uint256 userStakingsExaEsAmount;

        for(uint256 i = 0; i < _stakingIds.length; i++) {

            if(isStakingActive(_userAddress, _stakingIds[i], _currentMonth)
                && (
                  // @dev if urgent loan is not allowed then loan can be taken only after staking period is completed 75%
                  stakingPlans[ stakings[_userAddress][_stakingIds[i]].stakingPlanId ].isUrgentLoanAllowed
                  || now > stakings[_userAddress][_stakingIds[i]].timestamp + stakingPlans[ stakings[_userAddress][_stakingIds[i]].stakingPlanId ].months.mul(earthSecondsInMonth).mul(75).div(100)
                )
            ) {
                userStakingsExaEsAmount = userStakingsExaEsAmount
                    .add(stakings[_userAddress][_stakingIds[i]].exaEsAmount
                      .mul(loanPlans[_loanPlanId].maxLoanAmountPercent)
                      .div(100)
                      // .mul(stakingPlans[ stakings[_userAddress][_stakingIds[i]].stakingPlanId ].fractionFrom15)
                      // .div(15)
                    );
            }
        }

        return userStakingsExaEsAmount;
            //.mul( uint256(100).sub(loanPlans[_loanPlanId].loanRate) ).div(100);
    }

    /// @notice this function is used to take loan on multiple stakings
    /// @param _loanPlanId - user can select this plan which defines loan duration and loan interest
    /// @param _exaEsAmount - loan amount, this will also be the loan repay amount, the interest will first be deducted from this and then amount will be credited
    /// @param _stakingIds - staking ids user wishes to encash for taking the loan
    function takeLoanOnSelfStaking(uint256 _loanPlanId, uint256 _exaEsAmount, uint256[] memory _stakingIds) public {
        // @dev when loan is to be taken, first calculate active stakings from given stakings array. this way we can get how much loan user can take and simultaneously mark stakings as claimed for next months number loan period
        uint256 _currentMonth = getCurrentMonth();
        uint256 _userStakingsExaEsAmount;

        for(uint256 i = 0; i < _stakingIds.length; i++) {

            if( isStakingActive(msg.sender, _stakingIds[i], _currentMonth)
                && (
                  // @dev if urgent loan is not allowed then loan can be taken only after staking period is completed 75%
                  stakingPlans[ stakings[msg.sender][_stakingIds[i]].stakingPlanId ].isUrgentLoanAllowed
                  || now > stakings[msg.sender][_stakingIds[i]].timestamp + stakingPlans[ stakings[msg.sender][_stakingIds[i]].stakingPlanId ].months.mul(earthSecondsInMonth).mul(75).div(100)
                )
            ) {

                // @dev store sum in a number
                _userStakingsExaEsAmount = _userStakingsExaEsAmount
                    .add(
                        stakings[msg.sender][ _stakingIds[i] ].exaEsAmount
                          .mul(loanPlans[_loanPlanId].maxLoanAmountPercent)
                          .div(100)
                );

                // @dev subtract total active stakings
                uint256 stakingStartMonth = stakings[msg.sender][_stakingIds[i]].stakingMonth;

                uint256 stakeEndMonth = stakingStartMonth + stakingPlans[stakings[msg.sender][_stakingIds[i]].stakingPlanId].months;

                for(uint256 j = _currentMonth + 1; j <= stakeEndMonth; j++) {
                    totalActiveStakings[j] = totalActiveStakings[j].sub(_userStakingsExaEsAmount);
                }

                // @dev make stakings inactive
                for(uint256 j = 1; j <= loanPlans[_loanPlanId].loanMonths; j++) {
                    stakings[msg.sender][ _stakingIds[i] ].isMonthClaimed[ _currentMonth + j ] = true;
                    stakings[msg.sender][ _stakingIds[i] ].status = 2; // means in loan
                }
            }
        }

        uint256 _maxLoaningAmount = _userStakingsExaEsAmount;

        if(_exaEsAmount > _maxLoaningAmount) {
            require(false
              // , 'cannot loan more than maxLoaningAmount'
            );
        }


        uint256 _loanInterest = _exaEsAmount.mul(loanPlans[_loanPlanId].loanRate).div(100);
        uint256 _loanAmountToTransfer = _exaEsAmount.sub(_loanInterest);

        require( token.transfer(address(nrtManager), _loanInterest) );
        require( nrtManager.UpdateLuckpool(_loanInterest) );

        loans[msg.sender].push(Loan({
            exaEsAmount: _exaEsAmount,
            timestamp: now,
            loanPlanId: _loanPlanId,
            status: 1,
            stakingIds: _stakingIds
        }));

        // @dev send user amount
        require( token.transfer(msg.sender, _loanAmountToTransfer) );

        emit NewLoan(msg.sender, _loanPlanId, _exaEsAmount, _loanInterest, loans[msg.sender].length - 1);
    }

    /// @notice repay loan functionality
    /// @dev need to give allowance before this
    /// @param _loanId - select loan to repay
    function repayLoanSelf(uint256 _loanId) public {
        require(loans[msg.sender][_loanId].status == 1
          // , 'can only repay pending loans'
        );

        require(loans[msg.sender][_loanId].timestamp + loanPlans[ loans[msg.sender][_loanId].loanPlanId ].loanMonths.mul(earthSecondsInMonth) > now
          // , 'cannot repay expired loan'
        );

        require(token.transferFrom(msg.sender, address(this), loans[msg.sender][_loanId].exaEsAmount)
          // , 'cannot receive enough tokens, please check if allowance is there'
        );

        loans[msg.sender][_loanId].status = 2;

        // @dev get all stakings associated with this loan. and set next unclaimed months. then set status to 1 and also add to totalActiveStakings
        for(uint256 i = 0; i < loans[msg.sender][_loanId].stakingIds.length; i++) {
            uint256 _stakingId = loans[msg.sender][_loanId].stakingIds[i];

            stakings[msg.sender][_stakingId].status = 1;

            uint256 stakingStartMonth = stakings[msg.sender][_stakingId].timestamp.sub(deployedTimestamp).div(earthSecondsInMonth);

            uint256 stakeEndMonth = stakingStartMonth + stakingPlans[stakings[msg.sender][_stakingId].stakingPlanId].months;

            for(uint256 j = getCurrentMonth() + 1; j <= stakeEndMonth; j++) {
                stakings[msg.sender][_stakingId].isMonthClaimed[i] = false;

                totalActiveStakings[j] = totalActiveStakings[j].add(stakings[msg.sender][_stakingId].exaEsAmount);
            }
        }
        // add repay event
        emit RepayLoan(msg.sender, _loanId);
    }

    function burnDefaultedLoans(address[] memory _addressArray, uint256[] memory _loanIdArray) public {
        uint256 _amountToBurn;
        for(uint256 i = 0; i < _addressArray.length; i++) {
            require(
                loans[ _addressArray[i] ][ _loanIdArray[i] ].status == 1
                // , 'loan should not be repayed'
            );
            require(
                now >
                loans[ _addressArray[i] ][ _loanIdArray[i] ].timestamp
                + loanPlans[ loans[ _addressArray[i] ][ _loanIdArray[i] ].loanPlanId ].loanMonths.mul(earthSecondsInMonth)
                // , 'loan should have crossed its loan period'
            );
            uint256[] storage _stakingIdsOfLoan = loans[ _addressArray[i] ][ _loanIdArray[i] ].stakingIds;

            /// @dev add staking amounts of all stakings on which loan is taken
            for(uint256 j = 0; j < _stakingIdsOfLoan.length; j++) {
                _amountToBurn = _amountToBurn.add(
                    stakings[ _addressArray[i] ][ _stakingIdsOfLoan[j] ].exaEsAmount
                );
            }
            /// @dev sub loan amount
            _amountToBurn = _amountToBurn.sub(
                loans[ _addressArray[i] ][ _loanIdArray[i] ].exaEsAmount
            );
        }
        require(token.transfer(address(nrtManager), _amountToBurn));
        require(nrtManager.UpdateBurnBal(_amountToBurn));

        // emit event
    }

    /// @notice this function is used to add nominee to a staking
    /// @param _stakingId - staking id
    /// @param _nomineeAddress - address of nominee to be added to staking
    /// @param _shares - amount of shares of the staking to the nominee
    /// @dev shares is compared with total shares issued in a staking to see the percent nominee can withdraw. Nominee can withdraw only after one year past the end of tenure of staking. Upto 1 year past the end of tenure of staking, owner can withdraw principle amount of staking as well as can CRUD nominees. Owner of staking is has this time to withdraw their staking, if they fail to do so, after that nominees are allowed to withdraw. Withdrawl by first nominee will trigger staking into nomination mode and owner of staking cannot withdraw the principle amount as it will be distributed with only nominees and only they can withdraw it.
    function addNominee(uint256 _stakingId, address _nomineeAddress, uint256 _shares) public {
        require(stakings[msg.sender][_stakingId].status == 1
          // , 'staking should active'
        );
        require(stakings[msg.sender][_stakingId].nomination[_nomineeAddress] == 0
          // , 'should not be nominee already'
        );
        stakings[msg.sender][_stakingId].totalNominationShares = stakings[msg.sender][_stakingId].totalNominationShares.add(_shares);
        stakings[msg.sender][_stakingId].nomination[_nomineeAddress] = _shares;
        emit NomineeNew(msg.sender, _stakingId, _nomineeAddress);
    }

    /// @notice this function is used to read the nomination of a nominee address of a staking of a user
    /// @param _userAddress - address of staking owner
    /// @param _stakingId - staking id
    /// @param _nomineeAddress - address of nominee
    /// @return nomination of the nominee
    function viewNomination(address _userAddress, uint256 _stakingId, address _nomineeAddress) public view returns (uint256) {
        return stakings[_userAddress][_stakingId].nomination[_nomineeAddress];
    }

    // /// @notice this function is used to update nomination of a nominee of sender's staking
    // /// @param _stakingId - staking id
    // /// @param _nomineeAddress - address of nominee
    // /// @param _shares - shares to be updated for the nominee
    // function updateNominee(uint256 _stakingId, address _nomineeAddress, uint256 _shares) public {
    //     require(stakings[msg.sender][_stakingId].status == 1
    //       // , 'staking should active'
    //     );
    //     uint256 _oldShares = stakings[msg.sender][_stakingId].nomination[_nomineeAddress];
    //     if(_shares > _oldShares) {
    //         uint256 _diff = _shares.sub(_oldShares);
    //         stakings[msg.sender][_stakingId].totalNominationShares = stakings[msg.sender][_stakingId].totalNominationShares.add(_diff);
    //         stakings[msg.sender][_stakingId].nomination[_nomineeAddress] = stakings[msg.sender][_stakingId].nomination[_nomineeAddress].add(_diff);
    //     } else if(_shares < _oldShares) {
    //       uint256 _diff = _oldShares.sub(_shares);
    //         stakings[msg.sender][_stakingId].nomination[_nomineeAddress] = stakings[msg.sender][_stakingId].nomination[_nomineeAddress].sub(_diff);
    //         stakings[msg.sender][_stakingId].totalNominationShares = stakings[msg.sender][_stakingId].totalNominationShares.sub(_diff);
    //     }
    // }

    /// @notice this function is used to remove nomination of a address
    /// @param _stakingId - staking id
    /// @param _nomineeAddress - address of nominee
    function removeNominee(uint256 _stakingId, address _nomineeAddress) public {
        require(stakings[msg.sender][_stakingId].status == 1, 'staking should active');
        uint256 _oldShares = stakings[msg.sender][_stakingId].nomination[msg.sender];
        stakings[msg.sender][_stakingId].nomination[_nomineeAddress] = 0;
        stakings[msg.sender][_stakingId].totalNominationShares = stakings[msg.sender][_stakingId].totalNominationShares.sub(_oldShares);
    }

    /// @notice this function is used by nominee to withdraw their share of a staking after 1 year of the end of tenure of staking
    /// @param _userAddress - address of user
    /// @param _stakingId - staking id
    function nomineeWithdraw(address _userAddress, uint256 _stakingId) public {
        // end time stamp > 0
        uint256 currentTime = now;
        require( currentTime > (stakings[_userAddress][_stakingId].timestamp
                    + stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].months * earthSecondsInMonth
                    + 12 * earthSecondsInMonth )
                    // , 'cannot nominee withdraw before '
            );

        uint256 _nomineeShares = stakings[_userAddress][_stakingId].nomination[msg.sender];
        require(_nomineeShares > 0
          // , 'Not a nominee of this staking'
        );

        //uint256 _totalShares = ;

        // set staking to nomination mode if it isn't.
        if(stakings[_userAddress][_stakingId].status != 5) {
            stakings[_userAddress][_stakingId].status = 5;
        }

        // adding principal account
        uint256 _pendingLiquidAmountInStaking = stakings[_userAddress][_stakingId].exaEsAmount;
        uint256 _pendingAccruedAmountInStaking;

        // uint256 _stakingStartMonth = stakings[_userAddress][_stakingId].timestamp.sub(deployedTimestamp).div(earthSecondsInMonth);
        uint256 _stakeEndMonth = stakings[_userAddress][_stakingId].stakingMonth + stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].months;

        // adding monthly benefits which are not claimed
        for(
          uint256 i = stakings[_userAddress][_stakingId].stakingMonth; //_stakingStartMonth;
          i < _stakeEndMonth;
          i++
        ) {
            if( stakings[_userAddress][_stakingId].isMonthClaimed[i] ) {
                uint256 _effectiveAmount = stakings[_userAddress][_stakingId].exaEsAmount
                  .mul(stakingPlans[stakings[_userAddress][_stakingId].stakingPlanId].fractionFrom15)
                  .div(15);
                uint256 _monthlyBenefit = _effectiveAmount
                                          .mul(timeAllyMonthlyNRT[i])
                                          .div(totalActiveStakings[i]);
                _pendingLiquidAmountInStaking = _pendingLiquidAmountInStaking.add(_monthlyBenefit.div(2));
                _pendingAccruedAmountInStaking = _pendingAccruedAmountInStaking.add(_monthlyBenefit.div(2));
            }
        }

        // now we have _pendingLiquidAmountInStaking && _pendingAccruedAmountInStaking
        // on which user's share will be calculated and sent

        // marking nominee as claimed by removing his shares
        stakings[_userAddress][_stakingId].nomination[msg.sender] = 0;

        uint256 _nomineeLiquidShare = _pendingLiquidAmountInStaking
                                        .mul(_nomineeShares)
                                        .div(stakings[_userAddress][_stakingId].totalNominationShares);
        token.transfer(msg.sender, _nomineeLiquidShare);

        uint256 _nomineeAccruedShare = _pendingAccruedAmountInStaking
                                          .mul(_nomineeShares)
                                          .div(stakings[_userAddress][_stakingId].totalNominationShares);
        launchReward[msg.sender] = launchReward[msg.sender].add(_nomineeAccruedShare);

        // emit a event
        emit NomineeWithdraw(_userAddress, _stakingId, msg.sender, _nomineeLiquidShare, _nomineeAccruedShare);
    }
}
