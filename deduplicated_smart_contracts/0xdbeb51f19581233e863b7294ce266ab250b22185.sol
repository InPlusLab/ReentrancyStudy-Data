/**

 *Submitted for verification at Etherscan.io on 2019-07-29

*/



// File: @digix/cacp-contracts-dao/contracts/ACOwned.sol



pragma solidity ^0.4.25;



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



pragma solidity ^0.4.25;



/// @title Some useful constants

/// @author DigixGlobal



contract Constants {

  address constant NULL_ADDRESS = address(0x0);

  uint256 constant ZERO = uint256(0);

  bytes32 constant EMPTY = bytes32(0x0);

}



// File: @digix/cacp-contracts-dao/contracts/ContractResolver.sol



pragma solidity ^0.4.25;







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



pragma solidity ^0.4.25;







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



pragma solidity ^0.4.24;





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



pragma solidity ^0.4.25;





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



// File: contracts/storage/DaoPointsStorage.sol



pragma solidity ^0.4.25;







contract DaoPointsStorage is ResolverClient, DaoConstants {



    // struct for a non-transferrable token

    struct Token {

        uint256 totalSupply;

        mapping (address => uint256) balance;

    }



    // the reputation point token

    // since reputation is cumulative, we only need to store one value

    Token reputationPoint;



    // since quarter points are specific to quarters, we need a mapping from

    // quarter number to the quarter point token for that quarter

    mapping (uint256 => Token) quarterPoint;



    // the same is the case with quarter moderator points

    // these are specific to quarters

    mapping (uint256 => Token) quarterModeratorPoint;



    constructor(address _resolver)

        public

    {

        require(init(CONTRACT_STORAGE_DAO_POINTS, _resolver));

    }



    /// @notice add quarter points for a _participant for a _quarterNumber

    function addQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)

        public

        returns (uint256 _newPoint, uint256 _newTotalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));

        quarterPoint[_quarterNumber].totalSupply = quarterPoint[_quarterNumber].totalSupply.add(_point);

        quarterPoint[_quarterNumber].balance[_participant] = quarterPoint[_quarterNumber].balance[_participant].add(_point);



        _newPoint = quarterPoint[_quarterNumber].balance[_participant];

        _newTotalPoint = quarterPoint[_quarterNumber].totalSupply;

    }



    function addModeratorQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)

        public

        returns (uint256 _newPoint, uint256 _newTotalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));

        quarterModeratorPoint[_quarterNumber].totalSupply = quarterModeratorPoint[_quarterNumber].totalSupply.add(_point);

        quarterModeratorPoint[_quarterNumber].balance[_participant] = quarterModeratorPoint[_quarterNumber].balance[_participant].add(_point);



        _newPoint = quarterModeratorPoint[_quarterNumber].balance[_participant];

        _newTotalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;

    }



    /// @notice get quarter points for a _participant in a _quarterNumber

    function getQuarterPoint(address _participant, uint256 _quarterNumber)

        public

        view

        returns (uint256 _point)

    {

        _point = quarterPoint[_quarterNumber].balance[_participant];

    }



    function getQuarterModeratorPoint(address _participant, uint256 _quarterNumber)

        public

        view

        returns (uint256 _point)

    {

        _point = quarterModeratorPoint[_quarterNumber].balance[_participant];

    }



    /// @notice get total quarter points for a particular _quarterNumber

    function getTotalQuarterPoint(uint256 _quarterNumber)

        public

        view

        returns (uint256 _totalPoint)

    {

        _totalPoint = quarterPoint[_quarterNumber].totalSupply;

    }



    function getTotalQuarterModeratorPoint(uint256 _quarterNumber)

        public

        view

        returns (uint256 _totalPoint)

    {

        _totalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;

    }



    /// @notice add reputation points for a _participant

    function increaseReputation(address _participant, uint256 _point)

        public

        returns (uint256 _newPoint, uint256 _totalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING]));

        reputationPoint.totalSupply = reputationPoint.totalSupply.add(_point);

        reputationPoint.balance[_participant] = reputationPoint.balance[_participant].add(_point);



        _newPoint = reputationPoint.balance[_participant];

        _totalPoint = reputationPoint.totalSupply;

    }



    /// @notice subtract reputation points for a _participant

    function reduceReputation(address _participant, uint256 _point)

        public

        returns (uint256 _newPoint, uint256 _totalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));

        uint256 _toDeduct = _point;

        if (reputationPoint.balance[_participant] > _point) {

            reputationPoint.balance[_participant] = reputationPoint.balance[_participant].sub(_point);

        } else {

            _toDeduct = reputationPoint.balance[_participant];

            reputationPoint.balance[_participant] = 0;

        }



        reputationPoint.totalSupply = reputationPoint.totalSupply.sub(_toDeduct);



        _newPoint = reputationPoint.balance[_participant];

        _totalPoint = reputationPoint.totalSupply;

    }



  /// @notice get reputation points for a _participant

  function getReputation(address _participant)

      public

      view

      returns (uint256 _point)

  {

      _point = reputationPoint.balance[_participant];

  }



  /// @notice get total reputation points distributed in the dao

  function getTotalReputation()

      public

      view

      returns (uint256 _totalPoint)

  {

      _totalPoint = reputationPoint.totalSupply;

  }

}