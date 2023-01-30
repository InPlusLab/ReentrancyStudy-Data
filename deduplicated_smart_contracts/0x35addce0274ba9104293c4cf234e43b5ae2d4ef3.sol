/**
 *Submitted for verification at Etherscan.io on 2020-04-05
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

// File: @digix/solidity-collections/contracts/lib/DoublyLinkedList.sol

pragma solidity ^0.4.19;

library DoublyLinkedList {

  struct Item {
    bytes32 item;
    uint256 previous_index;
    uint256 next_index;
  }

  struct Data {
    uint256 first_index;
    uint256 last_index;
    uint256 count;
    mapping(bytes32 => uint256) item_index;
    mapping(uint256 => bool) valid_indexes;
    Item[] collection;
  }

  struct IndexedUint {
    mapping(bytes32 => Data) data;
  }

  struct IndexedAddress {
    mapping(bytes32 => Data) data;
  }

  struct IndexedBytes {
    mapping(bytes32 => Data) data;
  }

  struct Address {
    Data data;
  }

  struct Bytes {
    Data data;
  }

  struct Uint {
    Data data;
  }

  uint256 constant NONE = uint256(0);
  bytes32 constant EMPTY_BYTES = bytes32(0x0);
  address constant NULL_ADDRESS = address(0x0);

  function find(Data storage self, bytes32 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    if ((self.item_index[_item] == NONE) && (self.count == NONE)) {
      _item_index = NONE;
    } else {
      _item_index = self.item_index[_item];
    }
  }

  function get(Data storage self, uint256 _item_index)
           public
           constant
           returns (bytes32 _item)
  {
    if (self.valid_indexes[_item_index] == true) {
      _item = self.collection[_item_index - 1].item;
    } else {
      _item = EMPTY_BYTES;
    }
  }

  function append(Data storage self, bytes32 _data)
           internal
           returns (bool _success)
  {
    if (find(self, _data) != NONE || _data == bytes32("")) { // rejects addition of empty values
      _success = false;
    } else {
      uint256 _index = uint256(self.collection.push(Item({item: _data, previous_index: self.last_index, next_index: NONE})));
      if (self.last_index == NONE) {
        if ((self.first_index != NONE) || (self.count != NONE)) {
          revert();
        } else {
          self.first_index = self.last_index = _index;
          self.count = 1;
        }
      } else {
        self.collection[self.last_index - 1].next_index = _index;
        self.last_index = _index;
        self.count++;
      }
      self.valid_indexes[_index] = true;
      self.item_index[_data] = _index;
      _success = true;
    }
  }

  function remove(Data storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    if (self.valid_indexes[_index] == true) {
      Item memory item = self.collection[_index - 1];
      if (item.previous_index == NONE) {
        self.first_index = item.next_index;
      } else {
        self.collection[item.previous_index - 1].next_index = item.next_index;
      }

      if (item.next_index == NONE) {
        self.last_index = item.previous_index;
      } else {
        self.collection[item.next_index - 1].previous_index = item.previous_index;
      }
      delete self.collection[_index - 1];
      self.valid_indexes[_index] = false;
      delete self.item_index[item.item];
      self.count--;
      _success = true;
    } else {
      _success = false;
    }
  }

  function remove_item(Data storage self, bytes32 _item)
           internal
           returns (bool _success)
  {
    uint256 _item_index = find(self, _item);
    if (_item_index != NONE) {
      require(remove(self, _item_index));
      _success = true;
    } else {
      _success = false;
    }
    return _success;
  }

  function total(Data storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = self.count;
  }

  function start(Data storage self)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = self.first_index;
    return _item_index;
  }

  function start_item(Data storage self)
           public
           constant
           returns (bytes32 _item)
  {
    uint256 _item_index = start(self);
    if (_item_index != NONE) {
      _item = get(self, _item_index);
    } else {
      _item = EMPTY_BYTES;
    }
  }

  function end(Data storage self)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = self.last_index;
    return _item_index;
  }

  function end_item(Data storage self)
           public
           constant
           returns (bytes32 _item)
  {
    uint256 _item_index = end(self);
    if (_item_index != NONE) {
      _item = get(self, _item_index);
    } else {
      _item = EMPTY_BYTES;
    }
  }

  function valid(Data storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = self.valid_indexes[_item_index];
    //_yes = ((_item_index - 1) < self.collection.length);
  }

  function valid_item(Data storage self, bytes32 _item)
           public
           constant
           returns (bool _yes)
  {
    uint256 _item_index = self.item_index[_item];
    _yes = self.valid_indexes[_item_index];
  }

  function previous(Data storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    if (self.valid_indexes[_current_index] == true) {
      _previous_index = self.collection[_current_index - 1].previous_index;
    } else {
      _previous_index = NONE;
    }
  }

  function previous_item(Data storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _previous_item)
  {
    uint256 _current_index = find(self, _current_item);
    if (_current_index != NONE) {
      uint256 _previous_index = previous(self, _current_index);
      _previous_item = get(self, _previous_index);
    } else {
      _previous_item = EMPTY_BYTES;
    }
  }

  function next(Data storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    if (self.valid_indexes[_current_index] == true) {
      _next_index = self.collection[_current_index - 1].next_index;
    } else {
      _next_index = NONE;
    }
  }

  function next_item(Data storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _next_item)
  {
    uint256 _current_index = find(self, _current_item);
    if (_current_index != NONE) {
      uint256 _next_index = next(self, _current_index);
      _next_item = get(self, _next_index);
    } else {
      _next_item = EMPTY_BYTES;
    }
  }

  function find(Uint storage self, uint256 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data, bytes32(_item));
  }

  function get(Uint storage self, uint256 _item_index)
           public
           constant
           returns (uint256 _item)
  {
    _item = uint256(get(self.data, _item_index));
  }


  function append(Uint storage self, uint256 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data, bytes32(_data));
  }

  function remove(Uint storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data, _index);
  }

  function remove_item(Uint storage self, uint256 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data, bytes32(_item));
  }

  function total(Uint storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data);
  }

  function start(Uint storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data);
  }

  function start_item(Uint storage self)
           public
           constant
           returns (uint256 _start_item)
  {
    _start_item = uint256(start_item(self.data));
  }


  function end(Uint storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data);
  }

  function end_item(Uint storage self)
           public
           constant
           returns (uint256 _end_item)
  {
    _end_item = uint256(end_item(self.data));
  }

  function valid(Uint storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data, _item_index);
  }

  function valid_item(Uint storage self, uint256 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data, bytes32(_item));
  }

  function previous(Uint storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data, _current_index);
  }

  function previous_item(Uint storage self, uint256 _current_item)
           public
           constant
           returns (uint256 _previous_item)
  {
    _previous_item = uint256(previous_item(self.data, bytes32(_current_item)));
  }

  function next(Uint storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data, _current_index);
  }

  function next_item(Uint storage self, uint256 _current_item)
           public
           constant
           returns (uint256 _next_item)
  {
    _next_item = uint256(next_item(self.data, bytes32(_current_item)));
  }

  function find(Address storage self, address _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data, bytes32(_item));
  }

  function get(Address storage self, uint256 _item_index)
           public
           constant
           returns (address _item)
  {
    _item = address(get(self.data, _item_index));
  }


  function find(IndexedUint storage self, bytes32 _collection_index, uint256 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data[_collection_index], bytes32(_item));
  }

  function get(IndexedUint storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (uint256 _item)
  {
    _item = uint256(get(self.data[_collection_index], _item_index));
  }


  function append(IndexedUint storage self, bytes32 _collection_index, uint256 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data[_collection_index], bytes32(_data));
  }

  function remove(IndexedUint storage self, bytes32 _collection_index, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data[_collection_index], _index);
  }

  function remove_item(IndexedUint storage self, bytes32 _collection_index, uint256 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data[_collection_index], bytes32(_item));
  }

  function total(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data[_collection_index]);
  }

  function start(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data[_collection_index]);
  }

  function start_item(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _start_item)
  {
    _start_item = uint256(start_item(self.data[_collection_index]));
  }


  function end(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data[_collection_index]);
  }

  function end_item(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _end_item)
  {
    _end_item = uint256(end_item(self.data[_collection_index]));
  }

  function valid(IndexedUint storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data[_collection_index], _item_index);
  }

  function valid_item(IndexedUint storage self, bytes32 _collection_index, uint256 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data[_collection_index], bytes32(_item));
  }

  function previous(IndexedUint storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data[_collection_index], _current_index);
  }

  function previous_item(IndexedUint storage self, bytes32 _collection_index, uint256 _current_item)
           public
           constant
           returns (uint256 _previous_item)
  {
    _previous_item = uint256(previous_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function next(IndexedUint storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data[_collection_index], _current_index);
  }

  function next_item(IndexedUint storage self, bytes32 _collection_index, uint256 _current_item)
           public
           constant
           returns (uint256 _next_item)
  {
    _next_item = uint256(next_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function append(Address storage self, address _data)
           public
           returns (bool _success)
  {
    _success = append(self.data, bytes32(_data));
  }

  function remove(Address storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data, _index);
  }


  function remove_item(Address storage self, address _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data, bytes32(_item));
  }

  function total(Address storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data);
  }

  function start(Address storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data);
  }

  function start_item(Address storage self)
           public
           constant
           returns (address _start_item)
  {
    _start_item = address(start_item(self.data));
  }


  function end(Address storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data);
  }

  function end_item(Address storage self)
           public
           constant
           returns (address _end_item)
  {
    _end_item = address(end_item(self.data));
  }

  function valid(Address storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data, _item_index);
  }

  function valid_item(Address storage self, address _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data, bytes32(_item));
  }

  function previous(Address storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data, _current_index);
  }

  function previous_item(Address storage self, address _current_item)
           public
           constant
           returns (address _previous_item)
  {
    _previous_item = address(previous_item(self.data, bytes32(_current_item)));
  }

  function next(Address storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data, _current_index);
  }

  function next_item(Address storage self, address _current_item)
           public
           constant
           returns (address _next_item)
  {
    _next_item = address(next_item(self.data, bytes32(_current_item)));
  }

  function append(IndexedAddress storage self, bytes32 _collection_index, address _data)
           public
           returns (bool _success)
  {
    _success = append(self.data[_collection_index], bytes32(_data));
  }

  function remove(IndexedAddress storage self, bytes32 _collection_index, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data[_collection_index], _index);
  }


  function remove_item(IndexedAddress storage self, bytes32 _collection_index, address _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data[_collection_index], bytes32(_item));
  }

  function total(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data[_collection_index]);
  }

  function start(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data[_collection_index]);
  }

  function start_item(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (address _start_item)
  {
    _start_item = address(start_item(self.data[_collection_index]));
  }


  function end(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data[_collection_index]);
  }

  function end_item(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (address _end_item)
  {
    _end_item = address(end_item(self.data[_collection_index]));
  }

  function valid(IndexedAddress storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data[_collection_index], _item_index);
  }

  function valid_item(IndexedAddress storage self, bytes32 _collection_index, address _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data[_collection_index], bytes32(_item));
  }

  function previous(IndexedAddress storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data[_collection_index], _current_index);
  }

  function previous_item(IndexedAddress storage self, bytes32 _collection_index, address _current_item)
           public
           constant
           returns (address _previous_item)
  {
    _previous_item = address(previous_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function next(IndexedAddress storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data[_collection_index], _current_index);
  }

  function next_item(IndexedAddress storage self, bytes32 _collection_index, address _current_item)
           public
           constant
           returns (address _next_item)
  {
    _next_item = address(next_item(self.data[_collection_index], bytes32(_current_item)));
  }


  function find(Bytes storage self, bytes32 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data, _item);
  }

  function get(Bytes storage self, uint256 _item_index)
           public
           constant
           returns (bytes32 _item)
  {
    _item = get(self.data, _item_index);
  }


  function append(Bytes storage self, bytes32 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data, _data);
  }

  function remove(Bytes storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data, _index);
  }


  function remove_item(Bytes storage self, bytes32 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data, _item);
  }

  function total(Bytes storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data);
  }

  function start(Bytes storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data);
  }

  function start_item(Bytes storage self)
           public
           constant
           returns (bytes32 _start_item)
  {
    _start_item = start_item(self.data);
  }


  function end(Bytes storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data);
  }

  function end_item(Bytes storage self)
           public
           constant
           returns (bytes32 _end_item)
  {
    _end_item = end_item(self.data);
  }

  function valid(Bytes storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data, _item_index);
  }

  function valid_item(Bytes storage self, bytes32 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data, _item);
  }

  function previous(Bytes storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data, _current_index);
  }

  function previous_item(Bytes storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _previous_item)
  {
    _previous_item = previous_item(self.data, _current_item);
  }

  function next(Bytes storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data, _current_index);
  }

  function next_item(Bytes storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _next_item)
  {
    _next_item = next_item(self.data, _current_item);
  }

  function append(IndexedBytes storage self, bytes32 _collection_index, bytes32 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data[_collection_index], bytes32(_data));
  }

  function remove(IndexedBytes storage self, bytes32 _collection_index, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data[_collection_index], _index);
  }


  function remove_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data[_collection_index], bytes32(_item));
  }

  function total(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data[_collection_index]);
  }

  function start(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data[_collection_index]);
  }

  function start_item(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (bytes32 _start_item)
  {
    _start_item = bytes32(start_item(self.data[_collection_index]));
  }


  function end(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data[_collection_index]);
  }

  function end_item(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (bytes32 _end_item)
  {
    _end_item = bytes32(end_item(self.data[_collection_index]));
  }

  function valid(IndexedBytes storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data[_collection_index], _item_index);
  }

  function valid_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data[_collection_index], bytes32(_item));
  }

  function previous(IndexedBytes storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data[_collection_index], _current_index);
  }

  function previous_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _current_item)
           public
           constant
           returns (bytes32 _previous_item)
  {
    _previous_item = bytes32(previous_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function next(IndexedBytes storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data[_collection_index], _current_index);
  }

  function next_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _current_item)
           public
           constant
           returns (bytes32 _next_item)
  {
    _next_item = bytes32(next_item(self.data[_collection_index], bytes32(_current_item)));
  }


}

// File: contracts/lib/DaoStructs.sol

pragma solidity ^0.4.25;



library DaoStructs {
    using DoublyLinkedList for DoublyLinkedList.Bytes;
    using SafeMath for uint256;
    bytes32 constant EMPTY_BYTES = bytes32(0x0);

    struct PrlAction {
        // UTC timestamp at which the PRL action was done
        uint256 at;

        // IPFS hash of the document summarizing the action
        bytes32 doc;

        // Type of action
        // check PRL_ACTION_* in "./../common/DaoConstants.sol"
        uint256 actionId;
    }

    struct Voting {
        // UTC timestamp at which the voting round starts
        uint256 startTime;

        // Mapping of whether a commit was used in this voting round
        mapping (bytes32 => bool) usedCommits;

        // Mapping of commits by address. These are the commits during the commit phase in a voting round
        // This only stores the most recent commit in the voting round
        // In case a vote is edited, the previous commit is overwritten by the new commit
        // Only this new commit is verified at the reveal phase
        mapping (address => bytes32) commits;

        // This mapping is updated after the reveal phase, when votes are revealed
        // It is a mapping of address to weight of vote
        // Weight implies the lockedDGDStake of the address, at the time of revealing
        // If the address voted "NO", or didn't vote, this would be 0
        mapping (address => uint256) yesVotes;

        // This mapping is updated after the reveal phase, when votes are revealed
        // It is a mapping of address to weight of vote
        // Weight implies the lockedDGDStake of the address, at the time of revealing
        // If the address voted "YES", or didn't vote, this would be 0
        mapping (address => uint256) noVotes;

        // Boolean whether the voting round passed or not
        bool passed;

        // Boolean whether the voting round results were claimed or not
        // refer the claimProposalVotingResult function in "./../interative/DaoVotingClaims.sol"
        bool claimed;

        // Boolean whether the milestone following this voting round was funded or not
        // The milestone is funded when the proposer calls claimFunding in "./../interactive/DaoFundingManager.sol"
        bool funded;
    }

    struct ProposalVersion {
        // IPFS doc hash of this version of the proposal
        bytes32 docIpfsHash;

        // UTC timestamp at which this version was created
        uint256 created;

        // The number of milestones in the proposal as per this version
        uint256 milestoneCount;

        // The final reward asked by the proposer for completion of the entire proposal
        uint256 finalReward;

        // List of fundings required by the proposal as per this version
        // The numbers are in wei
        uint256[] milestoneFundings;

        // When a proposal is finalized (calling Dao.finalizeProposal), the proposer can no longer add proposal versions
        // However, they can still add more details to this final proposal version, in the form of IPFS docs.
        // These IPFS docs are stored in this array
        bytes32[] moreDocs;
    }

    struct Proposal {
        // ID of the proposal. Also the IPFS hash of the first ProposalVersion
        bytes32 proposalId;

        // current state of the proposal
        // refer PROPOSAL_STATE_* in "./../common/DaoConstants.sol"
        bytes32 currentState;

        // UTC timestamp at which the proposal was created
        uint256 timeCreated;

        // DoublyLinkedList of IPFS doc hashes of the various versions of the proposal
        DoublyLinkedList.Bytes proposalVersionDocs;

        // Mapping of version (IPFS doc hash) to ProposalVersion struct
        mapping (bytes32 => ProposalVersion) proposalVersions;

        // Voting struct for the draft voting round
        Voting draftVoting;

        // Mapping of voting round index (starts from 0) to Voting struct
        // votingRounds[0] is the Voting round of the proposal, which lasts for get_uint_config(CONFIG_VOTING_PHASE_TOTAL)
        // votingRounds[i] for i>0 are the Interim Voting rounds of the proposal, which lasts for get_uint_config(CONFIG_INTERIM_PHASE_TOTAL)
        mapping (uint256 => Voting) votingRounds;

        // Every proposal has a collateral tied to it with a value of
        // get_uint_config(CONFIG_PREPROPOSAL_COLLATERAL) (refer "./../storage/DaoConfigsStorage.sol")
        // Collateral can be in different states
        // refer COLLATERAL_STATUS_* in "./../common/DaoConstants.sol"
        uint256 collateralStatus;
        uint256 collateralAmount;

        // The final version of the proposal
        // Every proposal needs to be finalized before it can be voted on
        // This is the IPFS doc hash of the final version
        bytes32 finalVersion;

        // List of PrlAction structs
        // These are all the actions done by the PRL on the proposal
        PrlAction[] prlActions;

        // Address of the user who created the proposal
        address proposer;

        // Address of the moderator who endorsed the proposal
        address endorser;

        // Boolean whether the proposal is paused/stopped at the moment
        bool isPausedOrStopped;

        // Boolean whether the proposal was created by a founder role
        bool isDigix;
    }

    function countVotes(Voting storage _voting, address[] _allUsers)
        external
        view
        returns (uint256 _for, uint256 _against)
    {
        uint256 _n = _allUsers.length;
        for (uint256 i = 0; i < _n; i++) {
            if (_voting.yesVotes[_allUsers[i]] > 0) {
                _for = _for.add(_voting.yesVotes[_allUsers[i]]);
            } else if (_voting.noVotes[_allUsers[i]] > 0) {
                _against = _against.add(_voting.noVotes[_allUsers[i]]);
            }
        }
    }

    // get the list of voters who voted _vote (true-yes/false-no)
    function listVotes(Voting storage _voting, address[] _allUsers, bool _vote)
        external
        view
        returns (address[] memory _voters, uint256 _length)
    {
        uint256 _n = _allUsers.length;
        uint256 i;
        _length = 0;
        _voters = new address[](_n);
        if (_vote == true) {
            for (i = 0; i < _n; i++) {
                if (_voting.yesVotes[_allUsers[i]] > 0) {
                    _voters[_length] = _allUsers[i];
                    _length++;
                }
            }
        } else {
            for (i = 0; i < _n; i++) {
                if (_voting.noVotes[_allUsers[i]] > 0) {
                    _voters[_length] = _allUsers[i];
                    _length++;
                }
            }
        }
    }

    function readVote(Voting storage _voting, address _voter)
        public
        view
        returns (bool _vote, uint256 _weight)
    {
        if (_voting.yesVotes[_voter] > 0) {
            _weight = _voting.yesVotes[_voter];
            _vote = true;
        } else {
            _weight = _voting.noVotes[_voter]; // if _voter didnt vote at all, the weight will be 0 anyway
            _vote = false;
        }
    }

    function revealVote(
        Voting storage _voting,
        address _voter,
        bool _vote,
        uint256 _weight
    )
        public
    {
        if (_vote) {
            _voting.yesVotes[_voter] = _weight;
        } else {
            _voting.noVotes[_voter] = _weight;
        }
    }

    function readVersion(ProposalVersion storage _version)
        public
        view
        returns (
            bytes32 _doc,
            uint256 _created,
            uint256[] _milestoneFundings,
            uint256 _finalReward
        )
    {
        _doc = _version.docIpfsHash;
        _created = _version.created;
        _milestoneFundings = _version.milestoneFundings;
        _finalReward = _version.finalReward;
    }

    // read the funding for a particular milestone of a finalized proposal
    // if _milestoneId is the same as _milestoneCount, it returns the final reward
    function readProposalMilestone(Proposal storage _proposal, uint256 _milestoneIndex)
        public
        view
        returns (uint256 _funding)
    {
        bytes32 _finalVersion = _proposal.finalVersion;
        uint256 _milestoneCount = _proposal.proposalVersions[_finalVersion].milestoneFundings.length;
        require(_milestoneIndex <= _milestoneCount);
        require(_finalVersion != EMPTY_BYTES); // the proposal must have been finalized

        if (_milestoneIndex < _milestoneCount) {
            _funding = _proposal.proposalVersions[_finalVersion].milestoneFundings[_milestoneIndex];
        } else {
            _funding = _proposal.proposalVersions[_finalVersion].finalReward;
        }
    }

    function addProposalVersion(
        Proposal storage _proposal,
        bytes32 _newDoc,
        uint256[] _newMilestoneFundings,
        uint256 _finalReward
    )
        public
    {
        _proposal.proposalVersionDocs.append(_newDoc);
        _proposal.proposalVersions[_newDoc].docIpfsHash = _newDoc;
        _proposal.proposalVersions[_newDoc].created = now;
        _proposal.proposalVersions[_newDoc].milestoneCount = _newMilestoneFundings.length;
        _proposal.proposalVersions[_newDoc].milestoneFundings = _newMilestoneFundings;
        _proposal.proposalVersions[_newDoc].finalReward = _finalReward;
    }

    struct SpecialProposal {
        // ID of the special proposal
        // This is the IPFS doc hash of the proposal
        bytes32 proposalId;

        // UTC timestamp at which the proposal was created
        uint256 timeCreated;

        // Voting struct for the special proposal
        Voting voting;

        // List of the new uint256 configs as per the special proposal
        uint256[] uintConfigs;

        // List of the new address configs as per the special proposal
        address[] addressConfigs;

        // List of the new bytes32 configs as per the special proposal
        bytes32[] bytesConfigs;

        // Address of the user who created the special proposal
        // This address should also be in the ROLES_FOUNDERS group
        // refer "./../storage/DaoIdentityStorage.sol"
        address proposer;
    }

    // All configs are as per the DaoConfigsStorage values at the time when
    // calculateGlobalRewardsBeforeNewQuarter is called by founder in that quarter
    struct DaoQuarterInfo {
        // The minimum quarter points required
        // below this, reputation will be deducted
        uint256 minimalParticipationPoint;

        // The scaling factor for quarter point
        uint256 quarterPointScalingFactor;

        // The scaling factor for reputation point
        uint256 reputationPointScalingFactor;

        // The summation of effectiveDGDs in the previous quarter
        // The effectiveDGDs represents the effective participation in DigixDAO in a quarter
        // Which depends on lockedDGDStake, quarter point and reputation point
        // This value is the summation of all participant effectiveDGDs
        // It will be used to calculate the fraction of effectiveDGD a user has,
        // which will determine his portion of DGX rewards for that quarter
        uint256 totalEffectiveDGDPreviousQuarter;

        // The minimum moderator quarter point required
        // below this, reputation will be deducted for moderators
        uint256 moderatorMinimalParticipationPoint;

        // the scaling factor for moderator quarter point
        uint256 moderatorQuarterPointScalingFactor;

        // the scaling factor for moderator reputation point
        uint256 moderatorReputationPointScalingFactor;

        // The summation of effectiveDGDs (only specific to moderators)
        uint256 totalEffectiveModeratorDGDLastQuarter;

        // UTC timestamp from which the DGX rewards for the previous quarter are distributable to Holders
        uint256 dgxDistributionDay;

        // This is the rewards pool for the previous quarter. This is the sum of the DGX fees coming in from the collector, and the demurrage that has incurred
        // when user call claimRewards() in the previous quarter.
        // more graphical explanation: https://ipfs.io/ipfs/QmZDgFFMbyF3dvuuDfoXv5F6orq4kaDPo7m3QvnseUguzo
        uint256 dgxRewardsPoolLastQuarter;

        // The summation of all dgxRewardsPoolLastQuarter up until this quarter
        uint256 sumRewardsFromBeginning;
    }

    // There are many function calls where all calculations/summations cannot be done in one transaction
    // and require multiple transactions.
    // This struct stores the intermediate results in between the calculating transactions
    // These intermediate results are stored in IntermediateResultsStorage
    struct IntermediateResults {
        // weight of "FOR" votes counted up until the current calculation step
        uint256 currentForCount;

        // weight of "AGAINST" votes counted up until the current calculation step
        uint256 currentAgainstCount;

        // summation of effectiveDGDs up until the iteration of calculation
        uint256 currentSumOfEffectiveBalance;

        // Address of user until which the calculation has been done
        address countedUntil;
    }
}

// File: contracts/storage/DaoRewardsStorage.sol

pragma solidity ^0.4.25;




// this contract will receive DGXs fees from the DGX fees distributors
contract DaoRewardsStorage is ResolverClient, DaoConstants {
    using DaoStructs for DaoStructs.DaoQuarterInfo;

    // DaoQuarterInfo is a struct that stores the quarter specific information
    // regarding totalEffectiveDGDs, DGX distribution day, etc. pls check
    // docs in lib/DaoStructs
    mapping(uint256 => DaoStructs.DaoQuarterInfo) public allQuartersInfo;

    // Mapping that stores the DGX that can be claimed as rewards by
    // an address (a participant of DigixDAO)
    mapping(address => uint256) public claimableDGXs;

    // This stores the total DGX value that has been claimed by participants
    // this can be done by calling the DaoRewardsManager.claimRewards method
    // Note that this value is the only outgoing DGX from DaoRewardsManager contract
    // Note that this value also takes into account the demurrage that has been paid
    // by participants for simply holding their DGXs in the DaoRewardsManager contract
    uint256 public totalDGXsClaimed;

    // The Quarter ID in which the user last participated in
    // To participate means they had locked more than CONFIG_MINIMUM_LOCKED_DGD
    // DGD tokens. In addition, they should not have withdrawn those tokens in the same
    // quarter. Basically, in the main phase of the quarter, if DaoCommon.isParticipant(_user)
    // was true, they were participants. And that quarter was their lastParticipatedQuarter
    mapping (address => uint256) public lastParticipatedQuarter;

    // This mapping is only used to update the lastParticipatedQuarter to the
    // previousLastParticipatedQuarter in case users lock and withdraw DGDs
    // within the same quarter's locking phase
    mapping (address => uint256) public previousLastParticipatedQuarter;

    // This number marks the Quarter in which the rewards were last updated for that user
    // Since the rewards calculation for a specific quarter is only done once that
    // quarter is completed, we need this value to note the last quarter when the rewards were updated
    // We then start adding the rewards for all quarters after that quarter, until the current quarter
    mapping (address => uint256) public lastQuarterThatRewardsWasUpdated;

    // Similar as the lastQuarterThatRewardsWasUpdated, but this is for reputation updates
    // Note that reputation can also be deducted for no participation (not locking DGDs)
    // This value is used to update the reputation based on all quarters from the lastQuarterThatReputationWasUpdated
    // to the current quarter
    mapping (address => uint256) public lastQuarterThatReputationWasUpdated;

    constructor(address _resolver)
           public
    {
        require(init(CONTRACT_STORAGE_DAO_REWARDS, _resolver));
    }

    function updateQuarterInfo(
        uint256 _quarterNumber,
        uint256 _minimalParticipationPoint,
        uint256 _quarterPointScalingFactor,
        uint256 _reputationPointScalingFactor,
        uint256 _totalEffectiveDGDPreviousQuarter,

        uint256 _moderatorMinimalQuarterPoint,
        uint256 _moderatorQuarterPointScalingFactor,
        uint256 _moderatorReputationPointScalingFactor,
        uint256 _totalEffectiveModeratorDGDLastQuarter,

        uint256 _dgxDistributionDay,
        uint256 _dgxRewardsPoolLastQuarter,
        uint256 _sumRewardsFromBeginning
    )
        public
    {
        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));
        allQuartersInfo[_quarterNumber].minimalParticipationPoint = _minimalParticipationPoint;
        allQuartersInfo[_quarterNumber].quarterPointScalingFactor = _quarterPointScalingFactor;
        allQuartersInfo[_quarterNumber].reputationPointScalingFactor = _reputationPointScalingFactor;
        allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter = _totalEffectiveDGDPreviousQuarter;

        allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint = _moderatorMinimalQuarterPoint;
        allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor = _moderatorQuarterPointScalingFactor;
        allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor = _moderatorReputationPointScalingFactor;
        allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter = _totalEffectiveModeratorDGDLastQuarter;

        allQuartersInfo[_quarterNumber].dgxDistributionDay = _dgxDistributionDay;
        allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter = _dgxRewardsPoolLastQuarter;
        allQuartersInfo[_quarterNumber].sumRewardsFromBeginning = _sumRewardsFromBeginning;
    }

    function updateClaimableDGX(address _user, uint256 _newClaimableDGX)
        public
    {
        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));
        claimableDGXs[_user] = _newClaimableDGX;
    }

    function updateLastParticipatedQuarter(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        lastParticipatedQuarter[_user] = _lastQuarter;
    }

    function updatePreviousLastParticipatedQuarter(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        previousLastParticipatedQuarter[_user] = _lastQuarter;
    }

    function updateLastQuarterThatRewardsWasUpdated(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING, EMPTY_BYTES]));
        lastQuarterThatRewardsWasUpdated[_user] = _lastQuarter;
    }

    function updateLastQuarterThatReputationWasUpdated(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING, EMPTY_BYTES]));
        lastQuarterThatReputationWasUpdated[_user] = _lastQuarter;
    }

    function addToTotalDgxClaimed(uint256 _dgxClaimed)
        public
    {
        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));
        totalDGXsClaimed = totalDGXsClaimed.add(_dgxClaimed);
    }

    function readQuarterInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _minimalParticipationPoint,
            uint256 _quarterPointScalingFactor,
            uint256 _reputationPointScalingFactor,
            uint256 _totalEffectiveDGDPreviousQuarter,

            uint256 _moderatorMinimalQuarterPoint,
            uint256 _moderatorQuarterPointScalingFactor,
            uint256 _moderatorReputationPointScalingFactor,
            uint256 _totalEffectiveModeratorDGDLastQuarter,

            uint256 _dgxDistributionDay,
            uint256 _dgxRewardsPoolLastQuarter,
            uint256 _sumRewardsFromBeginning
        )
    {
        _minimalParticipationPoint = allQuartersInfo[_quarterNumber].minimalParticipationPoint;
        _quarterPointScalingFactor = allQuartersInfo[_quarterNumber].quarterPointScalingFactor;
        _reputationPointScalingFactor = allQuartersInfo[_quarterNumber].reputationPointScalingFactor;
        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;
        _moderatorMinimalQuarterPoint = allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint;
        _moderatorQuarterPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor;
        _moderatorReputationPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor;
        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;
        _dgxDistributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;
        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;
        _sumRewardsFromBeginning = allQuartersInfo[_quarterNumber].sumRewardsFromBeginning;
    }

    function readQuarterGeneralInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _dgxDistributionDay,
            uint256 _dgxRewardsPoolLastQuarter,
            uint256 _sumRewardsFromBeginning
        )
    {
        _dgxDistributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;
        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;
        _sumRewardsFromBeginning = allQuartersInfo[_quarterNumber].sumRewardsFromBeginning;
    }

    function readQuarterModeratorInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _moderatorMinimalQuarterPoint,
            uint256 _moderatorQuarterPointScalingFactor,
            uint256 _moderatorReputationPointScalingFactor,
            uint256 _totalEffectiveModeratorDGDLastQuarter
        )
    {
        _moderatorMinimalQuarterPoint = allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint;
        _moderatorQuarterPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor;
        _moderatorReputationPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor;
        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;
    }

    function readQuarterParticipantInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _minimalParticipationPoint,
            uint256 _quarterPointScalingFactor,
            uint256 _reputationPointScalingFactor,
            uint256 _totalEffectiveDGDPreviousQuarter
        )
    {
        _minimalParticipationPoint = allQuartersInfo[_quarterNumber].minimalParticipationPoint;
        _quarterPointScalingFactor = allQuartersInfo[_quarterNumber].quarterPointScalingFactor;
        _reputationPointScalingFactor = allQuartersInfo[_quarterNumber].reputationPointScalingFactor;
        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;
    }

    function readDgxDistributionDay(uint256 _quarterNumber)
        public
        view
        returns (uint256 _distributionDay)
    {
        _distributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;
    }

    function readTotalEffectiveDGDLastQuarter(uint256 _quarterNumber)
        public
        view
        returns (uint256 _totalEffectiveDGDPreviousQuarter)
    {
        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;
    }

    function readTotalEffectiveModeratorDGDLastQuarter(uint256 _quarterNumber)
        public
        view
        returns (uint256 _totalEffectiveModeratorDGDLastQuarter)
    {
        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;
    }

    function readRewardsPoolOfLastQuarter(uint256 _quarterNumber)
        public
        view
        returns (uint256 _rewardsPool)
    {
        _rewardsPool = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;
    }
}