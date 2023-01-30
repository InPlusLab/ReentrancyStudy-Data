/**

 *Submitted for verification at Etherscan.io on 2019-05-15

*/



pragma solidity ^0.4.25;



// File: @digix/cacp-contracts-dao/contracts/ACOwned.sol

/// @title Owner based access control

/// @author DigixGlobal

contract ACOwned {



  address public owner;

  address public new_owner;

  bool is_ac_owned_init;



  /// @dev Modifier to check if msg.sender is the contract owner

  modifier if_owner() {

    require(is_owner());

    _;

  }



  function init_ac_owned()

           internal

           returns (bool _success)

  {

    if (is_ac_owned_init == false) {

      owner = msg.sender;

      is_ac_owned_init = true;

    }

    _success = true;

  }



  function is_owner()

           private

           constant

           returns (bool _is_owner)

  {

    _is_owner = (msg.sender == owner);

  }



  function change_owner(address _new_owner)

           if_owner()

           public

           returns (bool _success)

  {

    new_owner = _new_owner;

    _success = true;

  }



  function claim_ownership()

           public

           returns (bool _success)

  {

    require(msg.sender == new_owner);

    owner = new_owner;

    _success = true;

  }

}



// File: @digix/cacp-contracts-dao/contracts/Constants.sol

/// @title Some useful constants

/// @author DigixGlobal

contract Constants {

  address constant NULL_ADDRESS = address(0x0);

  uint256 constant ZERO = uint256(0);

  bytes32 constant EMPTY = bytes32(0x0);

}



// File: @digix/cacp-contracts-dao/contracts/ContractResolver.sol

/// @title Contract Name Registry

/// @author DigixGlobal

contract ContractResolver is ACOwned, Constants {



  mapping (bytes32 => address) contracts;

  bool public locked_forever;



  modifier unless_registered(bytes32 _key) {

    require(contracts[_key] == NULL_ADDRESS);

    _;

  }



  modifier if_owner_origin() {

    require(tx.origin == owner);

    _;

  }



  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key

  /// @param _contract The resolver key

  modifier if_sender_is(bytes32 _contract) {

    require(msg.sender == get_contract(_contract));

    _;

  }



  modifier if_not_locked() {

    require(locked_forever == false);

    _;

  }



  /// @dev ContractResolver constructor will perform the following: 1. Set msg.sender as the contract owner.

  constructor() public

  {

    require(init_ac_owned());

    locked_forever = false;

  }



  /// @dev Called at contract initialization

  /// @param _key bytestring for CACP name

  /// @param _contract_address The address of the contract to be registered

  /// @return _success if the operation is successful

  function init_register_contract(bytes32 _key, address _contract_address)

           if_owner_origin()

           if_not_locked()

           unless_registered(_key)

           public

           returns (bool _success)

  {

    require(_contract_address != NULL_ADDRESS);

    contracts[_key] = _contract_address;

    _success = true;

  }



  /// @dev Lock the resolver from any further modifications.  This can only be called from the owner

  /// @return _success if the operation is successful

  function lock_resolver_forever()

           if_owner

           public

           returns (bool _success)

  {

    locked_forever = true;

    _success = true;

  }



  /// @dev Get address of a contract

  /// @param _key the bytestring name of the contract to look up

  /// @return _contract the address of the contract

  function get_contract(bytes32 _key)

           public

           view

           returns (address _contract)

  {

    require(contracts[_key] != NULL_ADDRESS);

    _contract = contracts[_key];

  }

}



// File: @digix/cacp-contracts-dao/contracts/ResolverClient.sol

/// @title Contract Resolver Interface

/// @author DigixGlobal

contract ResolverClient {



  /// The address of the resolver contract for this project

  address public resolver;

  bytes32 public key;



  /// Make our own address available to us as a constant

  address public CONTRACT_ADDRESS;



  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key

  /// @param _contract The resolver key

  modifier if_sender_is(bytes32 _contract) {

    require(sender_is(_contract));

    _;

  }



  function sender_is(bytes32 _contract) internal view returns (bool _isFrom) {

    _isFrom = msg.sender == ContractResolver(resolver).get_contract(_contract);

  }



  modifier if_sender_is_from(bytes32[3] _contracts) {

    require(sender_is_from(_contracts));

    _;

  }



  function sender_is_from(bytes32[3] _contracts) internal view returns (bool _isFrom) {

    uint256 _n = _contracts.length;

    for (uint256 i = 0; i < _n; i++) {

      if (_contracts[i] == bytes32(0x0)) continue;

      if (msg.sender == ContractResolver(resolver).get_contract(_contracts[i])) {

        _isFrom = true;

        break;

      }

    }

  }



  /// Function modifier to check resolver's locking status.

  modifier unless_resolver_is_locked() {

    require(is_locked() == false);

    _;

  }



  /// @dev Initialize new contract

  /// @param _key the resolver key for this contract

  /// @return _success if the initialization is successful

  function init(bytes32 _key, address _resolver)

           internal

           returns (bool _success)

  {

    bool _is_locked = ContractResolver(_resolver).locked_forever();

    if (_is_locked == false) {

      CONTRACT_ADDRESS = address(this);

      resolver = _resolver;

      key = _key;

      require(ContractResolver(resolver).init_register_contract(key, CONTRACT_ADDRESS));

      _success = true;

    }  else {

      _success = false;

    }

  }



  /// @dev Check if resolver is locked

  /// @return _locked if the resolver is currently locked

  function is_locked()

           private

           view

           returns (bool _locked)

  {

    _locked = ContractResolver(resolver).locked_forever();

  }



  /// @dev Get the address of a contract

  /// @param _key the resolver key to look up

  /// @return _contract the address of the contract

  function get_contract(bytes32 _key)

           public

           view

           returns (address _contract)

  {

    _contract = ContractResolver(resolver).get_contract(_key);

  }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: contracts/common/DaoConstants.sol

contract DaoConstants {

    using SafeMath for uint256;

    bytes32 EMPTY_BYTES = bytes32(0x0);

    address EMPTY_ADDRESS = address(0x0);





    bytes32 PROPOSAL_STATE_PREPROPOSAL = "proposal_state_preproposal";

    bytes32 PROPOSAL_STATE_DRAFT = "proposal_state_draft";

    bytes32 PROPOSAL_STATE_MODERATED = "proposal_state_moderated";

    bytes32 PROPOSAL_STATE_ONGOING = "proposal_state_ongoing";

    bytes32 PROPOSAL_STATE_CLOSED = "proposal_state_closed";

    bytes32 PROPOSAL_STATE_ARCHIVED = "proposal_state_archived";



    uint256 PRL_ACTION_STOP = 1;

    uint256 PRL_ACTION_PAUSE = 2;

    uint256 PRL_ACTION_UNPAUSE = 3;



    uint256 COLLATERAL_STATUS_UNLOCKED = 1;

    uint256 COLLATERAL_STATUS_LOCKED = 2;

    uint256 COLLATERAL_STATUS_CLAIMED = 3;



    bytes32 INTERMEDIATE_DGD_IDENTIFIER = "inter_dgd_id";

    bytes32 INTERMEDIATE_MODERATOR_DGD_IDENTIFIER = "inter_mod_dgd_id";

    bytes32 INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER = "inter_bonus_calculation_id";



    // interactive contracts

    bytes32 CONTRACT_DAO = "dao";

    bytes32 CONTRACT_DAO_SPECIAL_PROPOSAL = "dao:special:proposal";

    bytes32 CONTRACT_DAO_STAKE_LOCKING = "dao:stake-locking";

    bytes32 CONTRACT_DAO_VOTING = "dao:voting";

    bytes32 CONTRACT_DAO_VOTING_CLAIMS = "dao:voting:claims";

    bytes32 CONTRACT_DAO_SPECIAL_VOTING_CLAIMS = "dao:svoting:claims";

    bytes32 CONTRACT_DAO_IDENTITY = "dao:identity";

    bytes32 CONTRACT_DAO_REWARDS_MANAGER = "dao:rewards-manager";

    bytes32 CONTRACT_DAO_REWARDS_MANAGER_EXTRAS = "dao:rewards-extras";

    bytes32 CONTRACT_DAO_ROLES = "dao:roles";

    bytes32 CONTRACT_DAO_FUNDING_MANAGER = "dao:funding-manager";

    bytes32 CONTRACT_DAO_WHITELISTING = "dao:whitelisting";

    bytes32 CONTRACT_DAO_INFORMATION = "dao:information";



    // service contracts

    bytes32 CONTRACT_SERVICE_ROLE = "service:role";

    bytes32 CONTRACT_SERVICE_DAO_INFO = "service:dao:info";

    bytes32 CONTRACT_SERVICE_DAO_LISTING = "service:dao:listing";

    bytes32 CONTRACT_SERVICE_DAO_CALCULATOR = "service:dao:calculator";



    // storage contracts

    bytes32 CONTRACT_STORAGE_DAO = "storage:dao";

    bytes32 CONTRACT_STORAGE_DAO_COUNTER = "storage:dao:counter";

    bytes32 CONTRACT_STORAGE_DAO_UPGRADE = "storage:dao:upgrade";

    bytes32 CONTRACT_STORAGE_DAO_IDENTITY = "storage:dao:identity";

    bytes32 CONTRACT_STORAGE_DAO_POINTS = "storage:dao:points";

    bytes32 CONTRACT_STORAGE_DAO_SPECIAL = "storage:dao:special";

    bytes32 CONTRACT_STORAGE_DAO_CONFIG = "storage:dao:config";

    bytes32 CONTRACT_STORAGE_DAO_STAKE = "storage:dao:stake";

    bytes32 CONTRACT_STORAGE_DAO_REWARDS = "storage:dao:rewards";

    bytes32 CONTRACT_STORAGE_DAO_WHITELISTING = "storage:dao:whitelisting";

    bytes32 CONTRACT_STORAGE_INTERMEDIATE_RESULTS = "storage:intermediate:results";



    bytes32 CONTRACT_DGD_TOKEN = "t:dgd";

    bytes32 CONTRACT_DGX_TOKEN = "t:dgx";

    bytes32 CONTRACT_BADGE_TOKEN = "t:badge";



    uint8 ROLES_ROOT = 1;

    uint8 ROLES_FOUNDERS = 2;

    uint8 ROLES_PRLS = 3;

    uint8 ROLES_KYC_ADMINS = 4;



    uint256 QUARTER_DURATION = 90 days;



    bytes32 CONFIG_MINIMUM_LOCKED_DGD = "min_dgd_participant";

    bytes32 CONFIG_MINIMUM_DGD_FOR_MODERATOR = "min_dgd_moderator";

    bytes32 CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR = "min_reputation_moderator";



    bytes32 CONFIG_LOCKING_PHASE_DURATION = "locking_phase_duration";

    bytes32 CONFIG_QUARTER_DURATION = "quarter_duration";

    bytes32 CONFIG_VOTING_COMMIT_PHASE = "voting_commit_phase";

    bytes32 CONFIG_VOTING_PHASE_TOTAL = "voting_phase_total";

    bytes32 CONFIG_INTERIM_COMMIT_PHASE = "interim_voting_commit_phase";

    bytes32 CONFIG_INTERIM_PHASE_TOTAL = "interim_voting_phase_total";



    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR = "draft_quorum_fixed_numerator";

    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR = "draft_quorum_fixed_denominator";

    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR = "draft_quorum_sfactor_numerator";

    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR = "draft_quorum_sfactor_denominator";

    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR = "vote_quorum_fixed_numerator";

    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR = "vote_quorum_fixed_denominator";

    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR = "vote_quorum_sfactor_numerator";

    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR = "vote_quorum_sfactor_denominator";

    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR = "final_reward_sfactor_numerator";

    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR = "final_reward_sfactor_denominator";



    bytes32 CONFIG_DRAFT_QUOTA_NUMERATOR = "draft_quota_numerator";

    bytes32 CONFIG_DRAFT_QUOTA_DENOMINATOR = "draft_quota_denominator";

    bytes32 CONFIG_VOTING_QUOTA_NUMERATOR = "voting_quota_numerator";

    bytes32 CONFIG_VOTING_QUOTA_DENOMINATOR = "voting_quota_denominator";



    bytes32 CONFIG_MINIMAL_QUARTER_POINT = "minimal_qp";

    bytes32 CONFIG_QUARTER_POINT_SCALING_FACTOR = "quarter_point_scaling_factor";

    bytes32 CONFIG_REPUTATION_POINT_SCALING_FACTOR = "rep_point_scaling_factor";



    bytes32 CONFIG_MODERATOR_MINIMAL_QUARTER_POINT = "minimal_mod_qp";

    bytes32 CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR = "mod_qp_scaling_factor";

    bytes32 CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR = "mod_rep_point_scaling_factor";



    bytes32 CONFIG_QUARTER_POINT_DRAFT_VOTE = "quarter_point_draft_vote";

    bytes32 CONFIG_QUARTER_POINT_VOTE = "quarter_point_vote";

    bytes32 CONFIG_QUARTER_POINT_INTERIM_VOTE = "quarter_point_interim_vote";



    /// this is per 10000 ETHs

    bytes32 CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH = "q_p_milestone_completion";



    bytes32 CONFIG_BONUS_REPUTATION_NUMERATOR = "bonus_reputation_numerator";

    bytes32 CONFIG_BONUS_REPUTATION_DENOMINATOR = "bonus_reputation_denominator";



    bytes32 CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE = "special_proposal_commit_phase";

    bytes32 CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL = "special_proposal_phase_total";



    bytes32 CONFIG_SPECIAL_QUOTA_NUMERATOR = "config_special_quota_numerator";

    bytes32 CONFIG_SPECIAL_QUOTA_DENOMINATOR = "config_special_quota_denominator";



    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR = "special_quorum_numerator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR = "special_quorum_denominator";



    bytes32 CONFIG_MAXIMUM_REPUTATION_DEDUCTION = "config_max_reputation_deduction";

    bytes32 CONFIG_PUNISHMENT_FOR_NOT_LOCKING = "config_punishment_not_locking";



    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_NUM = "config_rep_per_extra_qp_num";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_DEN = "config_rep_per_extra_qp_den";



    bytes32 CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION = "config_max_m_rp_deduction";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM = "config_rep_per_extra_m_qp_num";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN = "config_rep_per_extra_m_qp_den";



    bytes32 CONFIG_PORTION_TO_MODERATORS_NUM = "config_mod_portion_num";

    bytes32 CONFIG_PORTION_TO_MODERATORS_DEN = "config_mod_portion_den";



    bytes32 CONFIG_DRAFT_VOTING_PHASE = "config_draft_voting_phase";



    bytes32 CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE = "config_rp_boost_per_badge";



    bytes32 CONFIG_VOTE_CLAIMING_DEADLINE = "config_claiming_deadline";



    bytes32 CONFIG_PREPROPOSAL_COLLATERAL = "config_preproposal_collateral";



    bytes32 CONFIG_MAX_FUNDING_FOR_NON_DIGIX = "config_max_funding_nonDigix";

    bytes32 CONFIG_MAX_MILESTONES_FOR_NON_DIGIX = "config_max_milestones_nonDigix";

    bytes32 CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER = "config_nonDigix_proposal_cap";



    bytes32 CONFIG_PROPOSAL_DEAD_DURATION = "config_dead_duration";

    bytes32 CONFIG_CARBON_VOTE_REPUTATION_BONUS = "config_cv_reputation";

}



// File: contracts/storage/DaoConfigsStorage.sol

contract DaoConfigsStorage is ResolverClient, DaoConstants {



    // mapping of config name to config value

    // config names can be found in DaoConstants contract

    mapping (bytes32 => uint256) public uintConfigs;



    // mapping of config name to config value

    // config names can be found in DaoConstants contract

    mapping (bytes32 => address) public addressConfigs;



    // mapping of config name to config value

    // config names can be found in DaoConstants contract

    mapping (bytes32 => bytes32) public bytesConfigs;



    uint256 ONE_BILLION = 1000000000;

    uint256 ONE_MILLION = 1000000;



    constructor(address _resolver)

        public

    {

        require(init(CONTRACT_STORAGE_DAO_CONFIG, _resolver));



        uintConfigs[CONFIG_LOCKING_PHASE_DURATION] = 10 days;

        uintConfigs[CONFIG_QUARTER_DURATION] = QUARTER_DURATION;

        uintConfigs[CONFIG_VOTING_COMMIT_PHASE] = 14 days;

        uintConfigs[CONFIG_VOTING_PHASE_TOTAL] = 21 days;

        uintConfigs[CONFIG_INTERIM_COMMIT_PHASE] = 7 days;

        uintConfigs[CONFIG_INTERIM_PHASE_TOTAL] = 14 days;







        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR] = 5; // 5%

        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR] = 100; // 5%

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR] = 35; // 35%

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR] = 100; // 35%





        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR] = 5; // 5%

        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR] = 100; // 5%

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR] = 25; // 25%

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR] = 100; // 25%



        uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR] = 1; // >50%

        uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR] = 2; // >50%

        uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR] = 1; // >50%

        uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR] = 2; // >50%





        uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE] = ONE_BILLION;

        uintConfigs[CONFIG_QUARTER_POINT_VOTE] = ONE_BILLION;

        uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE] = ONE_BILLION;



        uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH] = 20000 * ONE_BILLION;



        uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR] = 15; // 15% bonus for consistent votes

        uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR] = 100; // 15% bonus for consistent votes



        uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE] = 28 days;

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL] = 35 days;







        uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR] = 1; // >50%

        uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR] = 2; // >50%



        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR] = 40; // 40%

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR] = 100; // 40%



        uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION] = 8334 * ONE_MILLION;



        uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING] = 1666 * ONE_MILLION;

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM] = 1; // 1 extra QP gains 1/1 RP

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN] = 1;





        uintConfigs[CONFIG_MINIMAL_QUARTER_POINT] = 2 * ONE_BILLION;

        uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR] = 400 * ONE_BILLION;

        uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR] = 2000 * ONE_BILLION;



        uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT] = 4 * ONE_BILLION;

        uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR] = 400 * ONE_BILLION;

        uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR] = 2000 * ONE_BILLION;



        uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM] = 42; //4.2% of DGX to moderator voting activity

        uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN] = 1000;



        uintConfigs[CONFIG_DRAFT_VOTING_PHASE] = 10 days;



        uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE] = 412500 * ONE_MILLION;



        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR] = 7; // 7%

        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR] = 100; // 7%



        uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION] = 12500 * ONE_MILLION;

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM] = 1;

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN] = 1;



        uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE] = 10 days;



        uintConfigs[CONFIG_MINIMUM_LOCKED_DGD] = 10 * ONE_BILLION;

        uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR] = 842 * ONE_BILLION;

        uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR] = 400 * ONE_BILLION;



        uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL] = 2 ether;



        uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX] = 100 ether;

        uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX] = 5;

        uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER] = 80;



        uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION] = 90 days;

        uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS] = 10 * ONE_BILLION;

    }



    function updateUintConfigs(uint256[] _uintConfigs)

        external

    {

        require(sender_is(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS));

        uintConfigs[CONFIG_LOCKING_PHASE_DURATION] = _uintConfigs[0];

        /*

        This used to be a config that can be changed. Now, _uintConfigs[1] is just a dummy config that doesnt do anything

        uintConfigs[CONFIG_QUARTER_DURATION] = _uintConfigs[1];

        */

        uintConfigs[CONFIG_VOTING_COMMIT_PHASE] = _uintConfigs[2];

        uintConfigs[CONFIG_VOTING_PHASE_TOTAL] = _uintConfigs[3];

        uintConfigs[CONFIG_INTERIM_COMMIT_PHASE] = _uintConfigs[4];

        uintConfigs[CONFIG_INTERIM_PHASE_TOTAL] = _uintConfigs[5];

        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR] = _uintConfigs[6];

        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR] = _uintConfigs[7];

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR] = _uintConfigs[8];

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[9];

        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR] = _uintConfigs[10];

        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR] = _uintConfigs[11];

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR] = _uintConfigs[12];

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[13];

        uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR] = _uintConfigs[14];

        uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR] = _uintConfigs[15];

        uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR] = _uintConfigs[16];

        uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR] = _uintConfigs[17];

        uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE] = _uintConfigs[18];

        uintConfigs[CONFIG_QUARTER_POINT_VOTE] = _uintConfigs[19];

        uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE] = _uintConfigs[20];

        uintConfigs[CONFIG_MINIMAL_QUARTER_POINT] = _uintConfigs[21];

        uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH] = _uintConfigs[22];

        uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR] = _uintConfigs[23];

        uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR] = _uintConfigs[24];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE] = _uintConfigs[25];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL] = _uintConfigs[26];

        uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR] = _uintConfigs[27];

        uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR] = _uintConfigs[28];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR] = _uintConfigs[29];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR] = _uintConfigs[30];

        uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION] = _uintConfigs[31];

        uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING] = _uintConfigs[32];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM] = _uintConfigs[33];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN] = _uintConfigs[34];

        uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR] = _uintConfigs[35];

        uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR] = _uintConfigs[36];

        uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT] = _uintConfigs[37];

        uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR] = _uintConfigs[38];

        uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR] = _uintConfigs[39];

        uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM] = _uintConfigs[40];

        uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN] = _uintConfigs[41];

        uintConfigs[CONFIG_DRAFT_VOTING_PHASE] = _uintConfigs[42];

        uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE] = _uintConfigs[43];

        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR] = _uintConfigs[44];

        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[45];

        uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION] = _uintConfigs[46];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM] = _uintConfigs[47];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN] = _uintConfigs[48];

        uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE] = _uintConfigs[49];

        uintConfigs[CONFIG_MINIMUM_LOCKED_DGD] = _uintConfigs[50];

        uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR] = _uintConfigs[51];

        uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR] = _uintConfigs[52];

        uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL] = _uintConfigs[53];

        uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX] = _uintConfigs[54];

        uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX] = _uintConfigs[55];

        uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER] = _uintConfigs[56];

        uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION] = _uintConfigs[57];

        uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS] = _uintConfigs[58];

    }



    function readUintConfigs()

        public

        view

        returns (uint256[])

    {

        uint256[] memory _uintConfigs = new uint256[](59);

        _uintConfigs[0] = uintConfigs[CONFIG_LOCKING_PHASE_DURATION];

        _uintConfigs[1] = uintConfigs[CONFIG_QUARTER_DURATION];

        _uintConfigs[2] = uintConfigs[CONFIG_VOTING_COMMIT_PHASE];

        _uintConfigs[3] = uintConfigs[CONFIG_VOTING_PHASE_TOTAL];

        _uintConfigs[4] = uintConfigs[CONFIG_INTERIM_COMMIT_PHASE];

        _uintConfigs[5] = uintConfigs[CONFIG_INTERIM_PHASE_TOTAL];

        _uintConfigs[6] = uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR];

        _uintConfigs[7] = uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR];

        _uintConfigs[8] = uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR];

        _uintConfigs[9] = uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR];

        _uintConfigs[10] = uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR];

        _uintConfigs[11] = uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR];

        _uintConfigs[12] = uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR];

        _uintConfigs[13] = uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR];

        _uintConfigs[14] = uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR];

        _uintConfigs[15] = uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR];

        _uintConfigs[16] = uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR];

        _uintConfigs[17] = uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR];

        _uintConfigs[18] = uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE];

        _uintConfigs[19] = uintConfigs[CONFIG_QUARTER_POINT_VOTE];

        _uintConfigs[20] = uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE];

        _uintConfigs[21] = uintConfigs[CONFIG_MINIMAL_QUARTER_POINT];

        _uintConfigs[22] = uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH];

        _uintConfigs[23] = uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR];

        _uintConfigs[24] = uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR];

        _uintConfigs[25] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE];

        _uintConfigs[26] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL];

        _uintConfigs[27] = uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR];

        _uintConfigs[28] = uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR];

        _uintConfigs[29] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR];

        _uintConfigs[30] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR];

        _uintConfigs[31] = uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION];

        _uintConfigs[32] = uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING];

        _uintConfigs[33] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM];

        _uintConfigs[34] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN];

        _uintConfigs[35] = uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR];

        _uintConfigs[36] = uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR];

        _uintConfigs[37] = uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT];

        _uintConfigs[38] = uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR];

        _uintConfigs[39] = uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR];

        _uintConfigs[40] = uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM];

        _uintConfigs[41] = uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN];

        _uintConfigs[42] = uintConfigs[CONFIG_DRAFT_VOTING_PHASE];

        _uintConfigs[43] = uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE];

        _uintConfigs[44] = uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR];

        _uintConfigs[45] = uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR];

        _uintConfigs[46] = uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION];

        _uintConfigs[47] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM];

        _uintConfigs[48] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN];

        _uintConfigs[49] = uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE];

        _uintConfigs[50] = uintConfigs[CONFIG_MINIMUM_LOCKED_DGD];

        _uintConfigs[51] = uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR];

        _uintConfigs[52] = uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR];

        _uintConfigs[53] = uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL];

        _uintConfigs[54] = uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX];

        _uintConfigs[55] = uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX];

        _uintConfigs[56] = uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER];

        _uintConfigs[57] = uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION];

        _uintConfigs[58] = uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS];

        return _uintConfigs;

    }

}