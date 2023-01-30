pragma solidity 0.5.16;

import './SafeMath.sol';


/// @title Fund Bucket of TimeAlly Personal EraSwap Teller
/// @author The EraSwap Team
/// @notice The returns for PET Smart Contract are transparently stored in advance in this contract
contract FundsBucketPET {

  /// @notice address of the maintainer
  address public deployer;

  /// @notice address of Era Swap ERC20 Smart Contract
  ERC20 public token;

  /// @notice address of PET Smart Contract
  address public petContract;

  /// @notice event schema for monitoring funds added by donors
  event FundsDeposited(
    address _depositer,
    uint256 _depositAmount
  );

  /// @notice event schema for monitoring unallocated fund withdrawn by deployer
  event FundsWithdrawn(
    address _withdrawer,
    uint256 _withdrawAmount
  );

  /// @notice restricting access to some functionalities to deployer
  modifier onlyDeployer() {
    require(msg.sender == deployer, 'only deployer can call');
    _;
  }

  /// @notice this function is used to deploy FundsBucket Smart Contract
  ///   the same time while deploying PET Smart Contract
  /// @dev this smart contract is deployed by PET Smart Contract while being set up
  /// @param _token: is EraSwap ERC20 Smart Contract Address
  /// @param _deployer: is address of the deployer of PET Smart Contract
  constructor(ERC20 _token, address _deployer) public {
    token = _token;
    deployer = _deployer;
    petContract = msg.sender;
  }

  /// @notice this function is used by well wishers to add funds to the fund bucket of PET
  /// @dev ERC20 approve is required to be done for this contract earlier
  /// @param _depositAmount: amount in exaES to deposit
  function addFunds(uint256 _depositAmount) public {
    token.transferFrom(msg.sender, address(this), _depositAmount);

    /// @dev approving the PET Smart Contract in advance
    token.approve(petContract, _depositAmount);

    emit FundsDeposited(msg.sender, _depositAmount);
  }

  /// @notice this function makes it possible for deployer to withdraw unallocated ES
  function withdrawFunds(bool _withdrawEverything, uint256 _withdrawlAmount) public onlyDeployer {
    if(_withdrawEverything) {
      _withdrawlAmount = token.balanceOf(address(this));
    }

    token.transfer(msg.sender, _withdrawlAmount);

    emit FundsWithdrawn(msg.sender, _withdrawlAmount);
  }
}


/// @title TimeAlly Personal EraSwap Teller Smart Contract
/// @author The EraSwap Team
/// @notice Stakes EraSwap tokens with staker
contract TimeAllyPET {
  using SafeMath for uint256;

  /// @notice data structure of a PET Plan
  struct PETPlan {
    bool isPlanActive;
    uint256 minimumMonthlyCommitmentAmount;
    uint256 monthlyBenefitFactorPerThousand;
  }

  /// @notice data structure of a PET Plan
  struct PET {
    uint256 planId;
    uint256 monthlyCommitmentAmount;
    uint256 initTimestamp;
    uint256 lastAnnuityWithdrawlMonthId;
    uint256 appointeeVotes;
    uint256 numberOfAppointees;
    mapping(uint256 => uint256) monthlyDepositAmount;
    mapping(uint256 => bool) isPowerBoosterWithdrawn;
    mapping(address => bool) nominees;
    mapping(address => bool) appointees;
  }

  /// @notice address storage of the deployer
  address public deployer;

  /// @notice address storage of fundsBucket from which tokens to be pulled for giving benefits
  address public fundsBucket;

  /// @notice address storage of Era Swap Token ERC20 Smart Contract
  ERC20 public token;

  /// @dev selected for taking care of leap years such that 1 Year = 365.242 days holds
  uint256 constant EARTH_SECONDS_IN_MONTH = 2629744;

  /// @notice storage for multiple PET plans
  PETPlan[] public petPlans;

  /// @notice storage for PETs deployed by stakers
  mapping(address => PET[]) public pets;

  /// @notice storage for prepaid Era Swaps available for any wallet address
  mapping(address => uint256) public prepaidES;

  /// @notice event schema for monitoring new pet plans
  event NewPETPlan (
    uint256 _minimumMonthlyCommitmentAmount,
    uint256 _monthlyBenefitFactorPerThousand,
    uint256 _petPlanId
  );

  /// @notice event schema for monitoring new pets by stakers
  event NewPET (
    address indexed _staker,
    uint256 _petId,
    uint256 _monthlyCommitmentAmount
  );

  /// @notice event schema for monitoring deposits made by stakers to their pets
  event NewDeposit (
    address indexed _staker,
    uint256 indexed _petId,
    uint256 _monthId,
    uint256 _depositAmount,
    // uint256 _benefitAllocated,
    address _depositedBy,
    bool _usingPrepaidES
  );

  /// @notice event schema for monitoring pet annuity withdrawn by stakers
  event AnnuityWithdrawl (
    address indexed _staker,
    uint256 indexed _petId,
    uint256 _fromMonthId,
    uint256 _toMonthId,
    uint256 _withdrawlAmount,
    address _withdrawnBy
  );

  /// @notice event schema for monitoring power booster withdrawn by stakers
  event PowerBoosterWithdrawl (
    address indexed _staker,
    uint256 indexed _petId,
    uint256 _powerBoosterId,
    uint256 _withdrawlAmount,
    address _withdrawnBy
  );

  /// @notice event schema for monitoring penalised power booster burning
  event BoosterBurn (
    address _staker,
    uint256 _petId,
    uint256 _burningAmount
  );

  /// @notice event schema for monitoring power booster withdrawn by stakers
  event NomineeUpdated (
    address indexed _staker,
    uint256 indexed _petId,
    address indexed _nomineeAddress,
    bool _nomineeStatus
  );

  /// @notice event schema for monitoring power booster withdrawls by stakers
  event AppointeeUpdated (
    address indexed _staker,
    uint256 indexed _petId,
    address indexed _appointeeAddress,
    bool _appointeeStatus
  );

  /// @notice event schema for monitoring power booster withdrawls by stakers
  event AppointeeVoted (
    address indexed _staker,
    uint256 indexed _petId,
    address indexed _appointeeAddress
  );

  /// @notice restricting access to some functionalities to deployer
  modifier onlyDeployer() {
    require(msg.sender == deployer, 'only deployer can call');
    _;
  }

  /// @notice restricting access of staker's PET to them and their pet nominees
  modifier meOrNominee(address _stakerAddress, uint256 _petId) {
    PET storage _pet = pets[_stakerAddress][_petId];

    /// @notice if transacter is not staker, then transacter should be nominee
    if(msg.sender != _stakerAddress) {
      require(_pet.nominees[msg.sender], 'nomination should be there');
    }
    _;
  }

  /// @notice sets up TimeAllyPET contract when deployed and also deploys FundsBucket
  /// @param _token: is EraSwap ERC20 Smart Contract Address
  constructor(ERC20 _token) public {
    deployer = msg.sender;
    token = _token;
    fundsBucket = address(new FundsBucketPET(_token, msg.sender));
  }

  /// @notice this function is used to add ES as prepaid for PET
  /// @dev ERC20 approve needs to be done
  /// @param _amount: ES to deposit
  function addToPrepaid(uint256 _amount) public {
    /// @notice transfering the tokens from user
    token.transferFrom(msg.sender, address(this), _amount);

    /// @notice then adding tokens to prepaidES
    prepaidES[msg.sender] = prepaidES[msg.sender].add(_amount);
  }

  /// @notice this function is used to send ES as prepaid for PET
  /// @dev some ES already in prepaid required
  /// @param _addresses: address array to send prepaid ES for PET
  /// @param _amounts: prepaid ES for PET amounts to send to corresponding addresses
  function sendPrepaidESDifferent(
    address[] memory _addresses,
    uint256[] memory _amounts
  ) public {
    for(uint256 i = 0; i < _addresses.length; i++) {
      /// @notice subtracting amount from sender prepaidES
      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_amounts[i]);

      /// @notice then incrementing the amount into receiver's prepaidES
      prepaidES[_addresses[i]] = prepaidES[_addresses[i]].add(_amounts[i]);
    }
  }

  /// @notice this function is used by anyone to create a new PET
  /// @param _planId: id of PET in staker portfolio
  /// @param _monthlyCommitmentAmount: PET monthly commitment amount in exaES
  function newPET(
    uint256 _planId,
    uint256 _monthlyCommitmentAmount
  ) public {
    /// @notice enforcing that the plan should be active
    require(
      petPlans[_planId].isPlanActive
      , 'PET plan is not active'
    );

    /// @notice enforcing that monthly commitment by the staker should be more than
    ///   minimum monthly commitment in the selected plan
    require(
      _monthlyCommitmentAmount >= petPlans[_planId].minimumMonthlyCommitmentAmount
      , 'low monthlyCommitmentAmount'
    );

    /// @notice adding the PET to staker's pets storage
    pets[msg.sender].push(PET({
      planId: _planId,
      monthlyCommitmentAmount: _monthlyCommitmentAmount,
      initTimestamp: now,
      lastAnnuityWithdrawlMonthId: 0,
      appointeeVotes: 0,
      numberOfAppointees: 0
    }));

    /// @notice emiting an event
    emit NewPET(
      msg.sender,
      pets[msg.sender].length - 1,
      _monthlyCommitmentAmount
    );
  }

  /// @notice this function is used by deployer to create plans for new PETs
  /// @param _minimumMonthlyCommitmentAmount: minimum PET monthly amount in exaES
  /// @param _monthlyBenefitFactorPerThousand: this is per 1000; i.e 200 for 20%
  function createPETPlan(
    uint256 _minimumMonthlyCommitmentAmount,
    uint256 _monthlyBenefitFactorPerThousand
  ) public onlyDeployer {

    /// @notice adding the petPlan to storage
    petPlans.push(PETPlan({
      isPlanActive: true,
      minimumMonthlyCommitmentAmount: _minimumMonthlyCommitmentAmount,
      monthlyBenefitFactorPerThousand: _monthlyBenefitFactorPerThousand
    }));

    /// @notice emitting an event
    emit NewPETPlan(
      _minimumMonthlyCommitmentAmount,
      _monthlyBenefitFactorPerThousand,
      petPlans.length - 1
    );
  }

  /// @notice this function is used by deployer to disable or re-enable a pet plan
  /// @dev pets already initiated by a plan will continue only new will be restricted
  /// @param _planId: select a plan to make it inactive
  /// @param _newStatus: true or false.
  function updatePlanStatus(uint256 _planId, bool _newStatus) public onlyDeployer {
    petPlans[_planId].isPlanActive = _newStatus;
  }

  /// @notice this function is used to update nominee status of a wallet address in PET
  /// @param _petId: id of PET in staker portfolio.
  /// @param _nomineeAddress: eth wallet address of nominee.
  /// @param _newNomineeStatus: true or false, whether this should be a nominee or not.
  function toogleNominee(
    uint256 _petId,
    address _nomineeAddress,
    bool _newNomineeStatus
  ) public {
    /// @notice updating nominee status
    pets[msg.sender][_petId].nominees[_nomineeAddress] = _newNomineeStatus;

    /// @notice emiting event for UI and other applications
    emit NomineeUpdated(msg.sender, _petId, _nomineeAddress, _newNomineeStatus);
  }

  /// @notice this function is used to update appointee status of a wallet address in PET
  /// @param _petId: id of PET in staker portfolio.
  /// @param _appointeeAddress: eth wallet address of appointee.
  /// @param _newAppointeeStatus: true or false, should this have appointee rights or not.
  function toogleAppointee(
    uint256 _petId,
    address _appointeeAddress,
    bool _newAppointeeStatus
  ) public {
    PET storage _pet = pets[msg.sender][_petId];

    /// @notice if not an appointee already and _newAppointeeStatus is true, adding appointee
    if(!_pet.appointees[_appointeeAddress] && _newAppointeeStatus) {
      _pet.numberOfAppointees = _pet.numberOfAppointees.add(1);
      _pet.appointees[_appointeeAddress] = true;
    }

    /// @notice if already an appointee and _newAppointeeStatus is false, removing appointee
    else if(_pet.appointees[_appointeeAddress] && !_newAppointeeStatus) {
      _pet.appointees[_appointeeAddress] = false;
      _pet.numberOfAppointees = _pet.numberOfAppointees.sub(1);
    }

    emit AppointeeUpdated(msg.sender, _petId, _appointeeAddress, _newAppointeeStatus);
  }

  /// @notice this function is used by appointee to vote that nominees can withdraw early
  /// @dev need to be appointee, set by staker themselves
  /// @param _stakerAddress: address of initiater of this PET.
  /// @param _petId: id of PET in staker portfolio.
  function appointeeVote(
    address _stakerAddress,
    uint256 _petId
  ) public {
    PET storage _pet = pets[_stakerAddress][_petId];

    /// @notice checking if appointee has rights to cast a vote
    require(_pet.appointees[msg.sender]
      , 'should be appointee to cast vote'
    );

    /// @notice removing appointee's rights to vote again
    _pet.appointees[msg.sender] = false;

    /// @notice adding a vote to PET
    _pet.appointeeVotes = _pet.appointeeVotes.add(1);

    /// @notice emit that appointee has voted
    emit AppointeeVoted(_stakerAddress, _petId, msg.sender);
  }

  /// @notice this function is used by stakers to make deposits to their PETs
  /// @dev ERC20 approve is required to be done for this contract earlier if prepaidES
  ///   is not selected, enough funds must be there in the funds bucket contract
  ///   and also deposit can be done by nominee
  /// @param _stakerAddress: address of staker who has a PET
  /// @param _petId: id of PET in staker address portfolio
  /// @param _depositAmount: amount to deposit
  /// @param _usePrepaidES: should prepaidES be used
  function makeDeposit(
    address _stakerAddress,
    uint256 _petId,
    uint256 _depositAmount,
    bool _usePrepaidES
  ) public meOrNominee(_stakerAddress, _petId) {
    /// @notice check if non zero deposit
    require(_depositAmount > 0, 'deposit amount should be non zero');

    /// @notice get the storage reference of staker's PET
    PET storage _pet = pets[_stakerAddress][_petId];

    /// @notice calculate the deposit month based on time
    uint256 _depositMonth = getDepositMonth(_stakerAddress, _petId);

    /// @notice enforce no deposits after 12 months
    require(_depositMonth <= 12, 'cannot deposit after accumulation period');

    if(_usePrepaidES) {
      /// @notice subtracting prepaidES from staker
      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_depositAmount);
    } else {
      /// @notice transfering staker tokens to PET contract
      token.transferFrom(msg.sender, address(this), _depositAmount);
    }

    /// @notice calculate new deposit amount for the storage
    uint256 _updatedDepositAmount = _pet.monthlyDepositAmount[_depositMonth].add(_depositAmount);

    /// @notice carryforward small deposits in previous months
    uint256 _previousMonth = _depositMonth - 1;
    while(_previousMonth > 0) {
      if(0 < _pet.monthlyDepositAmount[_previousMonth]
      && _pet.monthlyDepositAmount[_previousMonth] < _pet.monthlyCommitmentAmount.div(2)) {
        _updatedDepositAmount = _updatedDepositAmount.add(
          _pet.monthlyDepositAmount[_previousMonth]
        );
        _pet.monthlyDepositAmount[_previousMonth] = 0;
      }
      _previousMonth -= 1;
    }

    /// @notice calculate old allocation, to adjust it in new allocation
    uint256 _oldBenefitAllocation = _getBenefitAllocationByDepositAmount(
      _pet,
      0,
      _depositMonth
    );
    uint256 _extraBenefitAllocation = _getBenefitAllocationByDepositAmount(
      _pet,
      _updatedDepositAmount,
      _depositMonth
    ).sub(_oldBenefitAllocation);

    /// @notice pull funds from funds bucket
    token.transferFrom(fundsBucket, address(this), _extraBenefitAllocation);

    /// @notice recording the deposit by updating the value
    _pet.monthlyDepositAmount[_depositMonth] = _updatedDepositAmount;

    /// @notice emitting an event
    emit NewDeposit(
      _stakerAddress,
      _petId,
      _depositMonth,
      _depositAmount,
      // _extraBenefitAllocation,
      msg.sender,
      _usePrepaidES
    );
  }

  /// @notice this function is used by stakers to make lum sum deposit
  /// @dev lum sum deposit is possible in the first month in a fresh PET
  /// @param _stakerAddress: address of staker who has a PET
  /// @param _petId: id of PET in staker address portfolio
  /// @param _totalDepositAmount: total amount to deposit for 12 months
  /// @param _frequencyMode: can be 3, 6 or 12
  /// @param _usePrepaidES: should prepaidES be used
  // deposit frequency mode
  function makeFrequencyModeDeposit(
    address _stakerAddress,
    uint256 _petId,
    uint256 _totalDepositAmount,
    uint256 _frequencyMode,
    bool _usePrepaidES
  ) public {
    uint256 _fees;
    /// @dev using ether because ES also has 18 decimals like ETH
    if(_frequencyMode == 3) _fees = _totalDepositAmount.mul(1).div(100);
    else if(_frequencyMode == 6) _fees = _totalDepositAmount.mul(2).div(100);
    else if(_frequencyMode == 12) _fees = _totalDepositAmount.mul(3).div(100);
    else require(false, 'unsupported frequency');

    /// @notice check if non zero deposit
    require(_totalDepositAmount > 0, 'deposit amount should be non zero');

    /// @notice get the reference of staker's PET
    PET storage _pet = pets[_stakerAddress][_petId];

    /// @notice calculate deposit month based on time and enforce first month
    uint256 _depositMonth = getDepositMonth(_stakerAddress, _petId);
    // require(_depositMonth == 1, 'allowed only in first month');

    uint256 _uptoMonth = _depositMonth.add(_frequencyMode).sub(1);
    require(_uptoMonth <= 12, 'cannot deposit after accumulation period');

    /// @notice enforce only fresh pets
    require(_pet.monthlyDepositAmount[_depositMonth] == 0, 'allowed only in fresh month deposit');

    /// @notice calculate monthly deposit amount
    uint256 _monthlyDepositAmount = _totalDepositAmount.div(_frequencyMode);

    /// @notice check if single monthly deposit amount is at least commitment
    require(
      _monthlyDepositAmount >= _pet.monthlyCommitmentAmount
      , 'deposit not crossing commitment'
    );

    /// @notice calculate benefit for a single month
    uint256 _benefitAllocationForSingleMonth = _getBenefitAllocationByDepositAmount(
      _pet,
      _monthlyDepositAmount,
      1
    );

    if(_usePrepaidES) {
      /// @notice subtracting prepaidES from staker
      prepaidES[msg.sender] = prepaidES[msg.sender].sub(_totalDepositAmount.add(_fees));
    } else {
      /// @notice transfering staker tokens to PET contract
      token.transferFrom(msg.sender, address(this), _totalDepositAmount.add(_fees));
    }

    prepaidES[deployer] = prepaidES[deployer].add(_fees);
    // token.transfer(deployer, _fees);

    /// @notice pull funds from funds bucket
    token.transferFrom(fundsBucket, address(this), _benefitAllocationForSingleMonth.mul(_frequencyMode));

    for(uint256 _monthId = _depositMonth; _monthId <= _uptoMonth; _monthId++) {
      /// @notice mark deposits in all the months
      _pet.monthlyDepositAmount[_monthId] = _monthlyDepositAmount;

      /// @notice emit events
      emit NewDeposit(
        _stakerAddress,
        _petId,
        _monthId,
        _monthlyDepositAmount,
        // _benefitAllocationForSingleMonth,
        msg.sender,
        _usePrepaidES
      );
    }
  }

  /// @notice this function is used to withdraw annuity benefits
  /// @param _stakerAddress: address of staker who has a PET
  /// @param _petId: id of PET in staker address portfolio
  /// @param _endAnnuityMonthId: this is the month upto which benefits to be withdrawn
  function withdrawAnnuity(
    address _stakerAddress,
    uint256 _petId,
    uint256 _endAnnuityMonthId
  ) public meOrNominee(_stakerAddress, _petId) {
    PET storage _pet = pets[_stakerAddress][_petId];
    uint256 _lastAnnuityWithdrawlMonthId = _pet.lastAnnuityWithdrawlMonthId;

    /// @notice enforcing withdrawls only once
    require(
      _lastAnnuityWithdrawlMonthId < _endAnnuityMonthId
      , 'start should be before end'
    );

    /// @notice enforcing only 60 withdrawls
    require(
      _endAnnuityMonthId <= 60
      , 'only 60 Annuity withdrawls'
    );

    /// @notice calculating allowed timestamp
    uint256 _allowedTimestamp = getNomineeAllowedTimestamp(
      _stakerAddress,
      _petId,
      _endAnnuityMonthId
    );

    /// @notice enforcing withdrawls only after allowed timestamp
    require(
      now >= _allowedTimestamp
      , 'cannot withdraw early'
    );

    /// @notice calculating sum of annuity of the months
    uint256 _annuityBenefit = getSumOfMonthlyAnnuity(
      _stakerAddress,
      _petId,
      _lastAnnuityWithdrawlMonthId+1,
      _endAnnuityMonthId
    );

    /// @notice updating last withdrawl month
    _pet.lastAnnuityWithdrawlMonthId = _endAnnuityMonthId;

    /// @notice burning penalised power booster tokens in the first annuity withdrawl
    if(_lastAnnuityWithdrawlMonthId == 0) {
      _burnPenalisedPowerBoosterTokens(_stakerAddress, _petId);
    }

    /// @notice transfering the annuity to withdrawer (staker or nominee)
    if(_annuityBenefit != 0) {
      token.transfer(msg.sender, _annuityBenefit);
    }

    // @notice emitting an event
    emit AnnuityWithdrawl(
      _stakerAddress,
      _petId,
      _lastAnnuityWithdrawlMonthId+1,
      _endAnnuityMonthId,
      _annuityBenefit,
      msg.sender
    );
  }

  /// @notice this function is used by staker to withdraw power booster
  /// @param _stakerAddress: address of staker who has a PET
  /// @param _petId: id of PET in staker address portfolio
  /// @param _powerBoosterId: this is serial of power booster
  function withdrawPowerBooster(
    address _stakerAddress,
    uint256 _petId,
    uint256 _powerBoosterId
  ) public meOrNominee(_stakerAddress, _petId) {
    PET storage _pet = pets[_stakerAddress][_petId];

    /// @notice enforcing 12 power booster withdrawls
    require(
      1 <= _powerBoosterId && _powerBoosterId <= 12
      , 'id should be in range'
    );

    /// @notice enforcing power booster withdrawl once
    require(
      !_pet.isPowerBoosterWithdrawn[_powerBoosterId]
      , 'booster already withdrawn'
    );

    /// @notice enforcing target to be acheived
    require(
      _pet.monthlyDepositAmount[13 - _powerBoosterId] >= _pet.monthlyCommitmentAmount
      , 'target not achieved'
    );

    /// @notice calculating allowed timestamp based on time and nominee
    uint256 _allowedTimestamp = getNomineeAllowedTimestamp(
      _stakerAddress,
      _petId,
      _powerBoosterId*5+1
    );

    /// @notice enforcing withdrawl after _allowedTimestamp
    require(
      now >= _allowedTimestamp
      , 'cannot withdraw early'
    );

    /// @notice calculating power booster amount
    uint256 _powerBoosterAmount = calculatePowerBoosterAmount(_stakerAddress, _petId);

    /// @notice marking power booster as withdrawn
    _pet.isPowerBoosterWithdrawn[_powerBoosterId] = true;

    if(_powerBoosterAmount > 0) {
      /// @notice sending the power booster amount to withdrawer (staker or nominee)
      token.transfer(msg.sender, _powerBoosterAmount);
    }

    /// @notice emitting an event
    emit PowerBoosterWithdrawl(
      _stakerAddress,
      _petId,
      _powerBoosterId,
      _powerBoosterAmount,
      msg.sender
    );
  }

  /// @notice this function is used to view nomination
  /// @param _stakerAddress: address of initiater of this PET.
  /// @param _petId: id of PET in staker portfolio.
  /// @param _nomineeAddress: eth wallet address of nominee.
  /// @return tells whether this address is a nominee or not
  function viewNomination(
    address _stakerAddress,
    uint256 _petId,
    address _nomineeAddress
  ) public view returns (bool) {
    return pets[_stakerAddress][_petId].nominees[_nomineeAddress];
  }

  /// @notice this function is used to view appointation
  /// @param _stakerAddress: address of initiater of this PET.
  /// @param _petId: id of PET in staker portfolio.
  /// @param _appointeeAddress: eth wallet address of apointee.
  /// @return tells whether this address is a appointee or not
  function viewAppointation(
    address _stakerAddress,
    uint256 _petId,
    address _appointeeAddress
  ) public view returns (bool) {
    return pets[_stakerAddress][_petId].appointees[_appointeeAddress];
  }

  /// @notice this function is used by contract to get nominee's allowed timestamp
  /// @param _stakerAddress: address of staker who has a PET
  /// @param _petId: id of PET in staker address portfolio
  /// @param _annuityMonthId: this is the month for which timestamp to find
  /// @return nominee allowed timestamp
  function getNomineeAllowedTimestamp(
    address _stakerAddress,
    uint256 _petId,
    uint256 _annuityMonthId
  ) public view returns (uint256) {
    PET storage _pet = pets[_stakerAddress][_petId];
    uint256 _allowedTimestamp = _pet.initTimestamp
      + (12 + _annuityMonthId - 1) * EARTH_SECONDS_IN_MONTH;

    /// @notice if tranasction sender is not the staker, then more delay to _allowedTimestamp
    if(msg.sender != _stakerAddress) {
      if(_pet.appointeeVotes > _pet.numberOfAppointees.div(2)) {
        _allowedTimestamp += EARTH_SECONDS_IN_MONTH * 6;
      } else {
        _allowedTimestamp += EARTH_SECONDS_IN_MONTH * 12;
      }
    }

    return _allowedTimestamp;
  }

  /// @notice this function is used to retrive monthly deposit in a PET
  /// @param _stakerAddress: address of staker who has PET
  /// @param _petId: id of PET in staket address portfolio
  /// @param _monthId: specify the month to deposit
  /// @return deposit in a particular month
  function getMonthlyDepositedAmount(
    address _stakerAddress,
    uint256 _petId,
    uint256 _monthId
  ) public view returns (uint256) {
    return pets[_stakerAddress][_petId].monthlyDepositAmount[_monthId];
  }

  /// @notice this function is used to get the current month of a PET
  /// @param _stakerAddress: address of staker who has PET
  /// @param _petId: id of PET in staket address portfolio
  /// @return current month of a particular PET
  function getDepositMonth(
    address _stakerAddress,
    uint256 _petId
  ) public view returns (uint256) {
    return (now - pets[_stakerAddress][_petId].initTimestamp)/EARTH_SECONDS_IN_MONTH + 1;
  }

  /// @notice this function is used to get total annuity benefits between two months
  /// @param _stakerAddress: address of staker who has a PET
  /// @param _petId: id of PET in staker address portfolio
  /// @param _startAnnuityMonthId: this is the month (inclusive) to start from
  /// @param _endAnnuityMonthId: this is the month (inclusive) to stop at
  function getSumOfMonthlyAnnuity(
    address _stakerAddress,
    uint256 _petId,
    uint256 _startAnnuityMonthId,
    uint256 _endAnnuityMonthId
  ) public view returns (uint256) {
    /// @notice get the storage references of staker's PET and Plan
    PET storage _pet = pets[_stakerAddress][_petId];
    PETPlan storage _petPlan = petPlans[_pet.planId];

    uint256 _totalDeposits;

    /// @notice calculating both deposits for every month and adding it
    for(uint256 _i = _startAnnuityMonthId; _i <= _endAnnuityMonthId; _i++) {
      uint256 _modulo = _i%12;
      uint256 _depositAmountIncludingPET = _getTotalDepositedIncludingPET(_pet.monthlyDepositAmount[_modulo==0?12:_modulo], _pet.monthlyCommitmentAmount);

      _totalDeposits = _totalDeposits.add(_depositAmountIncludingPET);
    }

    /// @notice calculating annuity from total both deposits done
    return _totalDeposits.mul(_petPlan.monthlyBenefitFactorPerThousand).div(1000);
  }

  /// @notice calculating power booster amount
  /// @param _stakerAddress: address of staker who has PET
  /// @param _petId: id of PET in staket address portfolio
  /// @return single power booster amount
  function calculatePowerBoosterAmount(
    address _stakerAddress,
    uint256 _petId
  ) public view returns (uint256) {
    /// @notice get the storage reference of staker's PET
    PET storage _pet = pets[_stakerAddress][_petId];

    uint256 _totalDepositedIncludingPET;

    /// @notice calculating total deposited by staker and pet in all 12 months
    for(uint256 _i = 1; _i <= 12; _i++) {
      uint256 _depositAmountIncludingPET = _getTotalDepositedIncludingPET(
        _pet.monthlyDepositAmount[_i],
        _pet.monthlyCommitmentAmount
      );

      _totalDepositedIncludingPET = _totalDepositedIncludingPET.add(_depositAmountIncludingPET);
    }

    return _totalDepositedIncludingPET.div(12);
  }

  /// @notice this function is used internally to burn penalised booster tokens
  /// @param _stakerAddress: address of staker who has a PET
  /// @param _petId: id of PET in staker address portfolio
  function _burnPenalisedPowerBoosterTokens(
    address _stakerAddress,
    uint256 _petId
  ) private {
    /// @notice get the storage references of staker's PET
    PET storage _pet = pets[_stakerAddress][_petId];

    uint256 _unachieveTargetCount;

    /// @notice calculating number of unacheived targets
    for(uint256 _i = 1; _i <= 12; _i++) {
      if(_pet.monthlyDepositAmount[_i] < _pet.monthlyCommitmentAmount) {
        _unachieveTargetCount++;
      }
    }

    uint256 _powerBoosterAmount = calculatePowerBoosterAmount(_stakerAddress, _petId);

    /// @notice burning the unacheived power boosters
    uint256 _burningAmount = _powerBoosterAmount.mul(_unachieveTargetCount);
    token.burn(_burningAmount);

    // @notice emitting an event
    emit BoosterBurn(_stakerAddress, _petId, _burningAmount);
  }

  /// @notice this function is used by contract to calculate benefit allocation when
  ///   a staker makes a deposit
  /// @param _pet: this is a reference to staker's pet storage
  /// @param _depositAmount: this is amount deposited by staker
  /// @param _depositMonth: this is month at which deposit takes place
  /// @return benefit amount to be allocated due to the deposit
  function _getBenefitAllocationByDepositAmount(
    PET storage _pet,
    uint256 _depositAmount,
    uint256 _depositMonth
  ) private view returns (uint256) {
    uint256 _planId = _pet.planId;
    uint256 _amount = _depositAmount != 0
      ? _depositAmount : _pet.monthlyDepositAmount[_depositMonth];
    uint256 _monthlyCommitmentAmount = _pet.monthlyCommitmentAmount;
    PETPlan storage _petPlan = petPlans[_planId];

    uint256 _petAmount;

    /// @notice if amount is above commitment then amount + commitment + amount / 2
    if(_amount > _monthlyCommitmentAmount) {
      uint256 _topupAmount = _amount.sub(_monthlyCommitmentAmount);
      _petAmount = _monthlyCommitmentAmount.add(_topupAmount.div(2));
    }
    /// @notice otherwise if amount is atleast half of commitment and at most commitment
    ///   then take staker amount as the pet amount
    else if(_amount >= _monthlyCommitmentAmount.div(2)) {
      _petAmount = _amount;
    }

    /// @notice getting total deposit for the month including pet
    uint256 _depositAmountIncludingPET = _getTotalDepositedIncludingPET(
      _amount,
      _monthlyCommitmentAmount
    );

    /// @dev starting with allocating power booster amount due to this deposit amount
    uint256 _benefitAllocation = _petAmount;

    /// @notice calculating the benefits in 5 years due to this deposit
    if(_amount >= _monthlyCommitmentAmount.div(2) || _depositMonth == 12) {
      _benefitAllocation = _benefitAllocation.add(
        _depositAmountIncludingPET.mul(_petPlan.monthlyBenefitFactorPerThousand).mul(5).div(1000)
      );
    }

    return _benefitAllocation;
  }

  /// @notice this function is used by contract to get total deposited amount including PET
  /// @param _amount: amount of ES which is deposited
  /// @param _monthlyCommitmentAmount: commitment amount of staker
  /// @return staker plus pet deposit amount based on acheivement of commitment
  function _getTotalDepositedIncludingPET(
    uint256 _amount,
    uint256 _monthlyCommitmentAmount
  ) private pure returns (uint256) {
    uint256 _petAmount;

    /// @notice if there is topup then add half of topup to pet
    if(_amount > _monthlyCommitmentAmount) {
      uint256 _topupAmount = _amount.sub(_monthlyCommitmentAmount);
      _petAmount = _monthlyCommitmentAmount.add(_topupAmount.div(2));
    }
    /// @notice otherwise if amount is atleast half of commitment and at most commitment
    ///   then take staker amount as the pet amount
    else if(_amount >= _monthlyCommitmentAmount.div(2)) {
      _petAmount = _amount;
    }

    /// @notice finally sum staker amount and pet amount and return it
    return _amount.add(_petAmount);
  }
}


/// @dev For interface requirement
contract ERC20 {
  function balanceOf(address tokenDeployer) public view returns (uint);
  function approve(address delegate, uint numTokens) public returns (bool);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function burn(uint256 value) public;
  function mou() public view returns (uint256);
}