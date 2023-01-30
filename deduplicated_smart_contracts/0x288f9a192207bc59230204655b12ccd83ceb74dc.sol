// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./EnumerableSet.sol";

/// @title Roleplay
///
/// @notice This contract covers most functions about
/// role and permission's managment
///
abstract contract Roleplay {
  using EnumerableSet for EnumerableSet.AddressSet;

  /// @dev Structure declaration of {RoleData} data model
  ///
  struct RoleData {
    EnumerableSet.AddressSet members;
    bytes32 ownerRole;
  }

  mapping (bytes32 => RoleData) private _roles;

  /// @dev Declare a public constant of type bytes32
  ///
  /// @return The bytes32 string of the role
  ///
  bytes32 public constant ROLE_OWNER = 0x00;

  /// @dev Declare a public constant of type bytes32
  ///
  /// @return The bytes32 string of the role
  ///
  bytes32 public constant ROLE_MANAGER = keccak256("MANAGER");

  /// @dev Declare two events to expose role
  /// modifications
  ///
  event RoleGranted(bytes32 indexed _role, address indexed _from, address indexed _sender);
  event RoleRevoked(bytes32 indexed role, address indexed _from, address indexed _sender);

  /// @dev Verify if the sender have Owner's role
  /// 
  /// Requirements:
  /// {_hasRole()} should be true
  ///
  modifier onlyOwner() {
    require(
      hasRole(ROLE_OWNER, msg.sender),
      "RPC:500"
    );
    _;
  }

  /// @notice This function verify is the {_account}
  /// has role {_role}
  ///
  /// @param _role - The bytes32 string of the role
  /// @param _account - The address to verify
  ///
  /// @return true/false depending the result 
  ///
  function hasRole(
    bytes32 _role,
    address _account
  ) public view returns (bool) {
    return _roles[_role].members.contains(_account);
  }

  /// @notice Expose the length of members[] for
  /// a given {_role}
  ///
  /// @param _role - The bytes32 string of the role
  ///
  /// @return - The length of members
  ///
  function getRoleMembersLength(
    bytes32 _role
  ) public view returns (uint256) {
    return _roles[_role].members.length();
  }


  /// @notice Expose the member address for
  /// a given {_role} at the {_id} index
  ///
  /// @param _id - Index to watch for
  /// @param _role - The bytes32 string of the role
  ///
  /// @return - The address of the member at {_id} index
  ///
  function exposeRoleMember(
    bytes32 _role,
    uint256 _id
  ) public view returns (address) {
    return _roles[_role].members.at(_id);
  }

  /// @notice This function allow the current Owner
  /// to transfer his ownership
  ///
  /// @dev Requirements:
  /// See {Roleplay::onlyOwner()}
  ///
  /// @param _to - Represent address of the receiver
  ///
  function transferOwnerRole(
    address _to
  ) public virtual onlyOwner() {
    _grantRole(ROLE_OWNER, _to);
    _revokeRole(ROLE_OWNER, msg.sender);
  }

  /// @notice This function allow the current Owner
  /// to give the Manager Role to {_to} address
  ///
  /// @dev Requirements:
  /// See {Roleplay::onlyOwner()}
  ///
  /// @param _to - Represent address of the receiver
  ///
  function grantManagerRole(
    address _to
  ) public virtual onlyOwner() {
    _grantRole(ROLE_MANAGER, _to);
  }

  /// @notice This function allow a Manager to grant
  /// role to a given address, it can't grant Owner role
  ///
  /// @dev Requirements:
  /// {_hasRole()} should be true
  /// {_role} should be different of ROLE_OWNER
  ///
  /// @param _role - The bytes32 string of the role
  /// @param _to - Represent address of the receiver
  ///
  function grantRole(
    bytes32 _role,
    address _to
  ) public virtual {
    require(
      hasRole(ROLE_MANAGER, msg.sender),
      "RPC:510"
    );

    require(
      _role != ROLE_OWNER,
      "RPC:520"
    );

    if (!hasRole(ROLE_OWNER, msg.sender)) {
      require(
        _role == keccak256("CHAIRPERSON"),
        "RPC:530"
      );
    }

    _grantRole(_role, _to);
  }

  /// @notice This function allow a Manager to revoke
  /// role to a given address, it can't revoke Owner role
  ///
  /// @dev Requirements:
  /// {_hasRole()} should be true
  /// {_role} should be different of ROLE_OWNER
  ///
  /// @param _role - The bytes32 string of the role
  /// @param _to - Represent address of the receiver
  ///
  function revokeRole(
    bytes32 _role,
    address _to
  ) public virtual {
    require(
      hasRole(ROLE_MANAGER, msg.sender),
      "RPC:550"
    );

    require(
      _role != ROLE_OWNER,
      "RPC:540"
    );

    if (!hasRole(ROLE_OWNER, msg.sender)) {
      require(
        _role == keccak256("CHAIRPERSON"),
        "RPC:530"
      );
    }

    _revokeRole(_role, _to);
  }

  /// @notice This function allow anyone to revoke his
  /// own role, even an Owner, use it carefully!
  ///
  /// @param _role - The bytes32 string of the role
  ///
  function renounceRole(
    bytes32 _role
  ) public virtual {
    require(
      _role != ROLE_OWNER,
      "RPC:540"
    );

    require(
      hasRole(_role, msg.sender),
      "RPC:570"
    );

    _revokeRole(_role, msg.sender);
  }

  function _setupRole(
    bytes32 _role,
    address _to
  ) internal virtual {
    _grantRole(_role, _to);
  }

  function _grantRole(
    bytes32 _role,
    address _to
  ) private {
    if (_roles[_role].members.add(_to)) {
      emit RoleGranted(_role, _to, msg.sender);
    }
  }

  function _revokeRole(
    bytes32 _role,
    address _to
  ) private {
    if (_roles[_role].members.remove(_to)) {
      emit RoleRevoked(_role, _to, msg.sender);
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import './Voteable.sol';
import './UnissouDApp.sol';

/// @title UnissouDAO
///
/// @notice This contract covers everything related
/// to the organization of Unissou
///
/// @dev Inehrit {Voteable} and {UnissouToken}
///
abstract contract UnissouDAO is Voteable, UnissouToken {
  
  /// @notice ROLE_CHAIRPERSON is granted to the
  /// original contract deployer
  ///
  /// @dev See {Roleplay::grantRole()}
  ///
  constructor() public {
    grantRole(ROLE_CHAIRPERSON, msg.sender);
  }

  /// @notice This function allows the sender to vote
  /// for a proposal, the vote can be positive or negative.
  /// The sender has to complete the requirements to be
  /// able to vote for a proposal.
  ///
  /// @dev Depending on the value of {_isPositiveVote}, add a
  /// *positive/negative* vote to the proposal, identified
  /// by its {_id}, then push the sender address into the
  /// voters pool of the proposal
  ///
  /// Requirements:
  /// See {Voteable::isValidVoter()} 
  /// See {Voteable::isVoteEnabled()} 
  ///
  /// @param _id - Represent the proposal id
  /// @param _isPositiveVote - Represent the vote type
  ///
  function voteForProposal(
    uint256 _id,
    bool _isPositiveVote
  ) public virtual isValidVoter(
    _id,
    balanceOf(msg.sender)
  ) isVoteEnabled(
    _id
  ) {
    if (_isPositiveVote) {
      proposals[_id].positiveVote += 1;
      proposals[_id].positiveVoters.push(msg.sender);
    }

    if (!_isPositiveVote) {
      proposals[_id].negativeVote += 1;
      proposals[_id].negativeVoters.push(msg.sender);
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/// Know more: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol

library SafeMath {
  function add(
    uint256 a,
    uint256 b
  ) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(
    uint256 a,
    uint256 b
  ) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(
    uint256 a,
    uint256 b
  ) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(
    uint256 a,
    uint256 b
  ) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(
    uint256 a,
    uint256 b
  ) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import './Roleplay.sol';

/// @title Voteable
///
/// @notice This contract covers most functions about
/// proposals and votings
///
/// @dev Inehrit {Roleplay}
///
abstract contract Voteable is Roleplay {
  /// @dev Declare an internal variable of type uint256
  ///
  uint256 internal _minVoteBalance;

  /// @dev Structure declaration of {Proposal} data model
  ///
  struct Proposal {
    address creator;
    string name;
    string metadataURI;
    bool votingEnabled;
    uint256 positiveVote;
    uint256 negativeVote;
    address[] positiveVoters;
    address[] negativeVoters;
  }

  /// @dev Declare a public constant of type bytes32
  ///
  /// @return The bytes32 string of the role
  ///
  bytes32 public constant ROLE_CHAIRPERSON = keccak256("CHAIRPERSON");

  /// @dev Declare an array of {Proposal}
  ///
  Proposal[] proposals;

  /// @dev Verify if the sender have the chairperson role
  /// 
  /// Requirements:
  /// {_hasRole} should be true
  ///
  modifier isChairperson() {
    require(
      hasRole(ROLE_CHAIRPERSON, msg.sender),
      "VC:500"
    );
    _;
  }

  /// @dev Verify if the sender is a valid voter
  ///
  /// Requirements:
  /// {_balance} should be superior to 1
  /// {_voter} should haven't already voted
  ///
  /// @param _id - Represent the proposal index
  /// @param _balance - Represent the sender balance
  ///
  modifier isValidVoter(
    uint256 _id,
    uint256 _balance
  ) {
    require(
      _balance >= (_minVoteBalance * (10**8)),
      "VC:1010"
    );

    bool positiveVote = _checkSenderHasVoted(proposals[_id].positiveVoters, msg.sender);
    bool negativeVote = _checkSenderHasVoted(proposals[_id].negativeVoters, msg.sender);

    require(
      !positiveVote && !negativeVote,
      "VC:1020"
    );
    _;
  }

  /// @dev Verify if the proposal have voting enabled
  ///
  /// Requirements:
  /// {proposals[_id]} should have voting enabled
  ///
  /// @param _id - Represent the proposal index
  ///
  modifier isVoteEnabled(
    uint256 _id
  ) {
    require(
      proposals[_id].votingEnabled,
      "VC:1030"
    );
    _;
  }

  constructor() public {
    _minVoteBalance = 100;
  }

  /// @notice Expose the min balance required to vote
  ///
  /// @return The uint256 value of {_minVoteBalance}
  ///
  function minVoteBalance()
  public view returns (uint256) {
    return _minVoteBalance;
  }

  /// @notice Set the {_minVoteBalance}
  ///
  /// @dev Only owner can use this function
  ///
  /// @param _amount - Represent the requested ratio
  ///
  function setMinVoteBalance(
    uint256 _amount
  ) public virtual onlyOwner() {
    _minVoteBalance = _amount;
  }

  /// @notice Allow a chairperson to create a new {Proposal}
  ///
  /// @dev Sender should be a chairperson
  ///
  /// Requirements:
  /// See {Voteable::isChairperson()}
  ///
  /// @param _name - Represent the Proposal name
  /// @param _uri - Represent the Proposal metadata uri
  /// @param _enable - Represent if vote is enable/disable
  ///
  function createProposal(
    string memory _name,
    string memory _uri,
    bool _enable
  ) public virtual isChairperson() {
    proposals.push(
      Proposal({
        creator: msg.sender,
        name: _name,
        metadataURI: _uri,
        votingEnabled: _enable,
        positiveVote: 0,
        negativeVote: 0,
        positiveVoters: new address[](0),
        negativeVoters: new address[](0)
      })
    );
  }
  
  /// @notice Allow a chairperson to enable/disable voting
  /// for a proposal
  ///
  /// @dev Sender should be a chairperson
  ///
  /// Requirements:
  /// See {Voteable::isChairperson()}
  ///
  /// @param _id - Represent a proposal index
  ///
  function enableProposal(
    uint256 _id
  ) public virtual isChairperson() {
    proposals[_id].votingEnabled ?
    proposals[_id].votingEnabled = false :
    proposals[_id].votingEnabled = true;
  }

  /// @notice Expose all proposals
  ///
  /// @return A tuple of Proposal
  ///
  function exposeProposals()
  public view returns (Proposal[] memory) {
    return proposals;
  }

  /// @notice Verify if the sender have already voted
  /// for a proposal
  ///
  /// @dev The function iterate hover the {_voters}
  /// to know if the sender have already voted
  ///
  /// @param _voters - Represent the positive/negative
  /// voters of a proposal
  ///
  function _checkSenderHasVoted(
    address[] memory _voters,
    address _voter
  ) private pure returns (bool) {
    uint256 i = 0;
    bool voted = false;
    uint256 len = _voters.length;
    while (i < len) {
      if (_voters[i] == _voter) {
        voted = true;
        break;
      }
      i++;
    }

    return voted;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import './Stakeable.sol';
import './Roleplay.sol';
import './UnissouToken.sol';

/// @title UnissouDApp
///
/// @notice This contract covers everything related
/// to the DApp of Unissou
///
/// @dev Inehrit {Stakeable} and {UnissouToken}
///
abstract contract UnissouDApp is Roleplay, Stakeable, UnissouToken {

  /// @notice This function allows the sender to stake
  /// an amount (maximum 10) of UnissouToken, when the
  /// token is staked, it is burned from the circulating
  /// supply and placed into the staking pool
  /// 
  /// @dev The function iterate through {stakeholders} to
  /// know if the sender is already a stakeholder. If the
  /// sender is already a stakeholder, then the requested amount
  /// is staked into the pool and then burned from the sender wallet.
  /// If the sender isn't a stakeholer, a new stakeholder is created,
  /// and then the function is recall to stake the requested amount
  ///
  /// Requirements:
  /// See {Stakeable::isAmountValid()}
  ///
  /// @param _amount - Represent the amount of token to be staked
  ///
  function stake(
    uint256 _amount
  ) public virtual isAmountValid(
    _amount,
    balanceOf(msg.sender)
  ) isAmountNotZero(
    _amount
  ) {
    uint256 i = 0;
    bool isStakeholder = false;
    uint256 len = stakeholders.length;
    while (i < len) {
      if (stakeholders[i].owner == msg.sender) {
        isStakeholder = true;
        break;
      }
      i++;
    }

    if (isStakeholder) {
      stakeholders[i].stake += _amount;
      _burn(msg.sender, (_amount * (10**8)));
      _totalStakedSupply += (_amount * (10**8));
      emit Staked(msg.sender, _amount);
    }

    if (!isStakeholder) {
      _createStakeholder(msg.sender);
      stake(_amount);
    }
  }
  
  /// @notice This function unstacks the sender staked
  /// balance depending on the requested {_amount}, if the
  /// {_amount} exceeded the staked supply of the sender,
  /// the whole staked supply of the sender will be unstacked
  /// and withdrawn to the sender wallet without exceeding it.
  ///
  /// @dev Like stake() function do, this function iterate
  /// over the stakeholders to identify if the sender is one 
  /// of them, in the case of the sender is identified as a
  /// stakeholder, then the {_amount} is minted to the sender
  /// wallet and sub from the staked supply.
  ///
  /// Requirements:
  /// See {Stakeable::isAmountNotZero}
  /// See {Stakeable::isAbleToUnstake}
  ///
  /// @param _amount - Represent the amount of token to be unstack
  ///
  function unstake(
    uint256 _amount
  ) public virtual isAmountNotZero(
    _amount
  ) isAbleToUnstake(
    _amount
  ) {
    uint256 i = 0;
    bool isStakeholder = false;
    uint256 len = stakeholders.length;
    while (i < len) {
      if (stakeholders[i].owner == msg.sender) {
        isStakeholder = true;
        break;
      }
      i++;
    }

    require(
      isStakeholder,
      "SC:650"
    );

    if (isStakeholder) {
      if (_amount <= stakeholders[i].stake) {
        stakeholders[i].stake -= _amount;
        _mint(msg.sender, (_amount * (10**8)));
        _totalStakedSupply -= (_amount * (10**8));
        emit Unstaked(msg.sender, _amount);
      }
    }
  }
  
  /// @notice This function allows the sender to compute
  /// his reward earned by staking {UnissouToken}. When you
  /// request a withdraw, the function updates the reward's
  /// value of the sender stakeholding onto the Ethereum
  /// blockchain, allowing him to spend the reward for NFTs.
  ///
  /// @dev The same principe as other functions is applied here,
  /// iteration over stakeholders, when found, execute the action.
  /// See {Stakeable::_computeReward()}
  ///
  function withdraw()
  public virtual {
    uint256 i = 0;
    bool isStakeholder = false;
    uint256 len = stakeholders.length;
    while (i < len) {
      if (stakeholders[i].owner == msg.sender) {
        isStakeholder = true;
        break;
      }
      i++;
    }

    require(
      isStakeholder,
      "SC:650"
    );

    if (isStakeholder) {
      _computeReward(i);
    }
  }

  /// @notice This function allows the owner to spend {_amount} 
  /// of the target rewards gained from his stake.
  ///
  /// @dev To reduce the potential numbers of transaction, the
  /// {_computeReward()} function is also executed into this function.
  ///
  /// @param _amount - Represent the amount of reward to spend
  /// @param _target - Represent the address of the stakeholder owner
  ///
  function spend(
    uint256 _amount,
    address _target
  ) public virtual onlyOwner() {
    uint256 i = 0;
    bool isStakeholder = false;
    uint256 len = stakeholders.length;
    while (i < len) {
      if (stakeholders[i].owner == _target) {
        isStakeholder = true;
        break;
      }
      i++;
    }

    require(
      isStakeholder,
      "SC:650"
    );

    if (isStakeholder) {
      _computeReward(i);
      require(
        _amount <= stakeholders[i].availableReward,
        "SC:660"
      );

      stakeholders[i].availableReward -= _amount;
      stakeholders[i].totalRewardSpent += _amount;
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/// Know more: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol

library EnumerableSet {
  struct Set {
    bytes32[] _values;
    mapping (bytes32 => uint256) _indexes;
  }

  function _add(
    Set storage set,
    bytes32 value
  ) private returns (bool) {
    if (!_contains(set, value)) {
      set._values.push(value);
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }

  function _remove(
    Set storage set,
    bytes32 value
  ) private returns (bool) {
    uint256 valueIndex = set._indexes[value];

    if (valueIndex != 0) {
      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;
      bytes32 lastvalue = set._values[lastIndex];
      set._values[toDeleteIndex] = lastvalue;
      set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
      set._values.pop();
      delete set._indexes[value];
      return true;
    } else {
      return false;
    }
  }

  function _contains(
    Set storage set,
    bytes32 value
  ) private view returns (bool) {
    return set._indexes[value] != 0;
  }

  function _length(
    Set storage set
  ) private view returns (uint256) {
    return set._values.length;
  }

  function _at(
    Set storage set,
    uint256 index
  ) private view returns (bytes32) {
    require(set._values.length > index, "EnumerableSet: index out of bounds");
    return set._values[index];
  }

  struct AddressSet {
    Set _inner;
  }

  function add(
    AddressSet storage set,
    address value
  ) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(value)));
  }

  function remove(
    AddressSet storage set,
    address value
  ) internal returns (bool) {
    return _remove(set._inner, bytes32(uint256(value)));
  }

  function contains(
    AddressSet storage set,
    address value
  ) internal view returns (bool) {
    return _contains(set._inner, bytes32(uint256(value)));
  }

  function length(
    AddressSet storage set
  ) internal view returns (uint256) {
    return _length(set._inner);
  }

  function at(
    AddressSet storage set,
    uint256 index
  ) internal view returns (address) {
    return address(uint256(_at(set._inner, index)));
  }

  struct UintSet {
    Set _inner;
  }

  function add(
    UintSet storage set,
    uint256 value
  ) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }

  function remove(
    UintSet storage set,
    uint256 value
  ) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }

  function contains(
    UintSet storage set,
    uint256 value
  ) internal view returns (bool) {
    return _contains(set._inner, bytes32(value));
  }

  function length(
    UintSet storage set
  ) internal view returns (uint256) {
    return _length(set._inner);
  }

  function at(
    UintSet storage set,
    uint256 index
  ) internal view returns (uint256) {
    return uint256(_at(set._inner, index));
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/// Know more: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol

abstract contract ERC20 is IERC20 {
  using SafeMath for uint256;
  using Address for address;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _initialSupply;
  uint256 private _totalSupply;
  uint256 private _totalSupplyCap;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor (
    string memory name,
    string memory symbol,
    uint256 totalSupplyCap,
    uint256 initialSupply
  ) public {
    _decimals = 8;

    _name = name;
    _symbol = symbol;
    _totalSupplyCap = totalSupplyCap;
    _initialSupply = initialSupply;
  }

  function name()
  public view returns (string memory) {
    return _name;
  }

  function symbol()
  public view returns (string memory) {
    return _symbol;
  }

  function decimals()
  public view returns (uint8) {
    return _decimals;
  }

  function initialSupply()
  public view override returns (uint256) {
    return _initialSupply;
  }

  function totalSupply()
  public view override returns (uint256) {
    return _totalSupply;
  }

  function totalSupplyCap()
  public view override returns (uint256) {
    return _totalSupplyCap;
  }

  function balanceOf(
    address account
  ) public view override returns (uint256) {
    return _balances[account];
  }

  function transfer(
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(
    address owner,
    address spender
  ) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(
    address spender,
    uint256 amount
  ) public virtual override returns (bool) {
    _approve(msg.sender, spender, (amount * (10**8)));
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub((amount * (10**8)), "ERC20:490"));
    return true;
  }

  function increaseAllowance(
    address spender,
    uint256 addedValue
  ) public virtual returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add((addedValue * (10**8))));
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  ) public virtual returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub((subtractedValue * (10**8)), "ERC20:495"));
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(
      sender != address(0),
      "ERC20:410"
    );

    require(
      recipient != address(0),
      "ERC20:420"
    );

    require(
      amount > 0,
      "ERC20:480"
    );

    _beforeTokenTransfer(sender, recipient, amount);

    _balances[sender] = _balances[sender].sub(amount, "ERC20:470");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(
    address account,
    uint256 amount
  ) internal virtual {
    require(
      account != address(0),
      "ERC20:120"
    );

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(
    address account,
    uint256 amount
  ) internal virtual {
    require(
      account != address(0),
      "ERC20:220"
    );

    _beforeTokenTransfer(account, address(0), amount);

    _balances[account] = _balances[account].sub(amount, "ERC20:230");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(
      owner != address(0),
      "ERC20:450"
    );
    require(
      spender != address(0),
      "ERC20:460"
    );

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _setupDecimals(
    uint8 decimals_
  ) internal {
    _decimals = decimals_;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import './Roleplay.sol';

/// @title Stakeable
///
/// @notice This contract covers most functions about
/// staking and rewards
///
abstract contract Stakeable is Roleplay {
  /// @dev Declare an internal variable of type uint256
  ///
  uint256 internal _totalStakedSupply;

  /// @dev Declare an internal variable of type uint256
  ///
  uint256 internal _maxRewardRatio;
  
  /// @dev Structure declaration of {Stakeholder} data model
  ///
  struct Stakeholder {
    address owner;
    uint256 stake;
    uint256 availableReward;
    uint256 totalRewardEarned;
    uint256 totalRewardSpent;
    uint256 createdAt;
    uint256 lastRewardCalculatedAt;
  }

  /// @dev Declare two events to expose when stake
  /// or unstake is requested, take the event's
  /// sender as argument and the requested amount
  ///
  event Staked(address indexed _from, uint256 _amount);
  event Unstaked(address indexed _from, uint256 _amount);

  /// @dev Declare an array of {Stakeholder}
  ///
  Stakeholder[] stakeholders;
  
  /// @dev Verify if the amount is superior to 0
  /// 
  /// Requirements:
  /// {_amount} should be superior to 0
  ///
  /// @param _amount - Represent the requested amount
  ///
  modifier isAmountNotZero(uint256 _amount) {
    require(
      _amount > 0,
      "SC:630"
    );
    _;
  }

  /// @dev Verify if the amount is a valid amount
  /// 
  /// Requirements:
  /// {_amount} should be inferior or equal to 10
  ///
  /// @param _amount - Represent the requested amount
  /// @param _balance - Represent the sender balance
  ///
  modifier isAmountValid(uint256 _amount, uint256 _balance) {
    require(
      (_amount * (10**8)) <= _balance,
      "SC:640"
    );
    _;
  }

  /// @dev Verify if the amount is a valid amount to unstake
  /// 
  /// Requirements:
  /// {_amount} should be inferior or equal to staked value
  ///
  /// @param _amount - Represent the requested amount
  ///
  modifier isAbleToUnstake(uint256 _amount) {
    Stakeholder memory stakeholder = exposeStakeholder(msg.sender); 
    require(
      _amount <= stakeholder.stake,
      "SC:640"
    );
    _;
  }

  constructor() public {
    _maxRewardRatio = 10;
  }

  /// @notice Expose the total staked supply
  ///
  /// @return The uint256 value of {_totalStakedSupply}
  ///
  function totalStakedSupply()
  public view returns (uint256) {
    return _totalStakedSupply;
  }

  /// @notice Expose the max reward ratio
  ///
  /// @return The uint256 value of {_maxRewardRatio}
  ///
  function maxRewardRatio()
  public view returns (uint256) {
    return _maxRewardRatio;
  }

  /// @notice Expose every Stakeholders
  ///
  /// @return A tuple of Stakeholders
  ///
  function exposeStakeholders()
  public view returns (Stakeholder[] memory) {
    return stakeholders;
  }

  /// @notice Expose a Stakeholder from the Owner address
  ///
  /// @param _owner - Represent the address of the stakeholder owner
  ///
  /// @return A tuple of Stakeholder
  ///
  function exposeStakeholder(
    address _owner
  ) public view returns (Stakeholder memory) {
    uint256 i = 0;
    uint256 len = stakeholders.length;
    while (i < len) {
      if (stakeholders[i].owner == _owner) {
        return stakeholders[i];
      }
      i++;
    }
  }

  /// @notice Set the {_maxRewardRatio}
  ///
  /// @dev Only owner can use this function
  ///
  /// @param _amount - Represent the requested ratio
  ///
  function setMaxRewardRatio(
    uint256 _amount
  ) public virtual onlyOwner() {
    _maxRewardRatio = _amount;
  }

  /// @notice Create a new {Stakeholder}
  ///
  /// @dev Owner is the sender
  ///
  /// @param _owner - Represent the owner of the Stakeholder
  ///
  function _createStakeholder(
    address _owner
  ) internal virtual {
    stakeholders.push(Stakeholder({
      owner: _owner,
      stake: 0,
      createdAt: now,
      availableReward: 0,
      totalRewardEarned: 0,
      totalRewardSpent: 0,
      lastRewardCalculatedAt: 0
    }));
  }

  /// @notice This function compute the reward gained from staking
  /// UnissouToken
  ///
  /// @dev The calculation is pretty simple, a {Stakeholder}
  /// holds the date of the {Stakeholder}'s creation. If the
  /// reward hasn't been computed since the creation, the
  /// algorithm will calculate them based on the number of
  /// days passed since the creation of the stakeholding.
  /// Then the calculation's date will be saved onto the
  /// {Stakeholder} and when {_computeReward} will be called
  /// again, the reward calculation will take this date in 
  /// consideration to compute the reward.
  /// 
  /// The actual ratio is 1 Stake = 1 Reward.
  /// With a maximum of 10 tokens per stake,
  /// you can obtain a total of 10 rewards per day
  ///
  /// @param _id - Represent the Stakeholder index
  ///
  function _computeReward(
    uint256 _id
  ) internal virtual {
    uint256 stake = stakeholders[_id].stake;
    uint256 lastCalculatedReward = stakeholders[_id].lastRewardCalculatedAt;
    uint256 createdAt = stakeholders[_id].createdAt;

    if (lastCalculatedReward == 0) {
      if (createdAt < now) {
        if ((now - createdAt) >= 1 days) {
          stakeholders[_id].availableReward += (((now - createdAt) / 1 days) * (
            stake <= _maxRewardRatio ?
            stake : _maxRewardRatio
          ));
          stakeholders[_id].totalRewardEarned += (((now - createdAt) / 1 days) * (
            stake <= _maxRewardRatio ?
            stake : _maxRewardRatio
          ));
          stakeholders[_id].lastRewardCalculatedAt = now;
          return;
        }
      }
    }

    if (lastCalculatedReward != 0) {
      if (lastCalculatedReward < now) {
        if ((now - lastCalculatedReward) >= 1 days) {
          stakeholders[_id].availableReward += (((now - lastCalculatedReward) / 1 days) * (
            stake <= _maxRewardRatio ?
            stake : _maxRewardRatio
          ));
          stakeholders[_id].totalRewardEarned += (((now - lastCalculatedReward) / 1 days) * (
            stake <= _maxRewardRatio ?
            stake : _maxRewardRatio
          ));
          stakeholders[_id].lastRewardCalculatedAt = now;
          return;
        }
      }
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/// Know more: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol

interface IERC20 {
  function initialSupply()
  external view returns (uint256);

  function totalSupply()
  external view returns (uint256);

  function totalSupplyCap()
  external view returns (uint256);

  function balanceOf(
    address account
  ) external view returns (uint256);

  function transfer(
    address recipient,
    uint256 amount
  ) external returns (bool);

  function allowance(
    address owner,
    address spender
  ) external view returns (uint256);

  function approve(
    address spender,
    uint256 amount
  ) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/// @title Minteable
///
/// @notice This contract covers everything related
/// to the mint functions
///
contract Minteable {
  /// @dev Declare a private bool {_mintingEnabled}
  ///
  bool private _mintingEnabled;

  /// @dev Declare a public constant of type bytes32
  ///
  /// @return The bytes32 string of the role
  ///
  bytes32 public constant ROLE_MINTER = keccak256("MINTER");

  /// @dev Declare two events to expose when minting
  /// is enabled or disabled, take the event's sender
  /// as argument
  ///
  event MintingEnabled(address indexed _from);
  event MintingDisabled(address indexed _from);

  /// @dev Verify if the sender can mint, if yes,
  /// enable minting
  /// 
  /// Requirements:
  /// {_hasRole} should be true
  /// {_amount} should be superior to 0
  /// {_mintingEnabled} should be true
  ///
  modifier isMinteable(
    uint256 _amount,
    bool _hasRole
  ) {
    require(
      _hasRole,
      "MC:500"
    );

    require(
      _amount > 0,
      "MC:30"
    );

    _enableMinting();

    require(
      mintingEnabled(),
      "MC:110"
    );
    _;
  }

  /// @dev By default, minting is disabled
  ///
  constructor()
  internal {
    _mintingEnabled = false;
  }

  /// @notice Expose the state of {_mintingEnabled}
  ///
  /// @return The state as a bool
  ///
  function mintingEnabled()
  public view returns (bool) {
    return _mintingEnabled;
  }

  /// @dev Enable minting by setting {_mintingEnabled}
  /// to true, then emit the related event
  ///
  function _enableMinting()
  internal virtual {
    _mintingEnabled = true;
    emit MintingEnabled(msg.sender);
  }

  /// @dev Disable minting by setting {_mintingEnabled}
  /// to false, then emit the related event
  ///
  function _disableMinting()
  internal virtual {
    _mintingEnabled = false;
    emit MintingDisabled(msg.sender);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import './UnissouDAO.sol';
import './UnissouDApp.sol';

/// @title Unissou
///
/// @notice This is the main contract
///
/// @dev Inehrit {UnissouDAO} and {UnissouDApp}
///
contract Unissou is UnissouDAO, UnissouDApp {

  /// @notice Declare a public constant of type string
  ///
  /// @return The smart contract author
  ///
  string public constant CREATOR = "unissou.com";
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/// @title Burneable
///
/// @notice This contract covers everything related
/// to the burn functions
///
contract Burneable {
  /// @dev Declare a private bool {_burningEnabled}
  ///
  bool private _burningEnabled;

  /// @dev Declare a public constant of type bytes32
  ///
  /// @return The bytes32 string of the role
  ///
  bytes32 public constant ROLE_BURNER = keccak256("BURNER");

  /// @dev Declare two events to expose when burning
  /// is enabled or disabled, take the event's sender
  /// as argument
  ///
  event BurningEnabled(address indexed _from);
  event BurningDisabled(address indexed _from);

  /// @dev Verify if the sender can burn, if yes,
  /// enable burning
  /// 
  /// Requirements:
  /// {_hasRole} should be true
  /// {_amount} should be superior to 0
  /// {_burningEnabled} should be true
  ///
  modifier isBurneable(
    uint256 _amount,
    bool _hasRole
  ) {
    require(
      _hasRole,
      "BC:500"
    );

    require(
      _amount > 0,
      "BC:30"
    );

    _enableBurning();

    require(
      burningEnabled(),
      "BC:210"
    );
    _;
  }

  /// @dev By default, burning is disabled
  ///
  constructor()
  internal {
    _burningEnabled = false;
  }

  /// @notice Expose the state of {_burningEnabled}
  ///
  /// @return The state as a bool
  ///
  function burningEnabled()
  public view returns (bool) {
    return _burningEnabled;
  }

  /// @dev Enable burning by setting {_burningEnabled}
  /// to true, then emit the related event
  ///
  function _enableBurning()
  internal virtual {
    _burningEnabled = true;
    emit BurningEnabled(msg.sender);
  }

  /// @dev Disable burning by setting {_burningEnabled}
  /// to false, then emit the related event
  ///
  function _disableBurning()
  internal virtual {
    _burningEnabled = false;
    emit BurningDisabled(msg.sender);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/// Know more: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol

library Address {
  function isContract(
    address account
  ) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }

  function sendValue(
    address payable recipient,
    uint256 amount
  ) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  function functionCall(
    address target,
    bytes memory data
  ) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    return _functionCallWithValue(target, data, 0, errorMessage);
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value
  ) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    return _functionCallWithValue(target, data, value, errorMessage);
  }

  function _functionCallWithValue(
    address target,
    bytes memory data,
    uint256 weiValue,
    string memory errorMessage
  ) private returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");

    (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert(errorMessage);
      }
    }
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import './Roleplay.sol';

/// @title Pauseable
///
/// @notice This contract covers everything related
/// to the pause functions
///
/// @dev Inehrit {Roleplay}
///
contract Pauseable is Roleplay {
  /// @dev Declare a private bool {_paused}
  ///
  bool private _paused;
  
  /// @dev Declare two events to expose when pause
  /// is enabled or disabled, take the event's sender
  /// as argument
  ///
  event Paused(address indexed _from);
  event Unpaused(address indexed _from);

  /// @dev Verify if the contract is not paused
  /// 
  /// Requirements:
  /// {_paused} should be false
  ///
  modifier whenNotPaused() {
    require(
      !_paused,
      "PC:300"
    );
    _;
  }

  /// @dev Verify if the contract is paused
  /// 
  /// Requirements:
  /// {_paused} should be true
  ///
  modifier whenPaused() {
    require(
      _paused,
      "PC:310"
    );
    _;
  }

  /// @dev By default, pause is disabled
  ///
  constructor ()
  internal {
    _paused = false;
  }

  /// @notice Expose the state of {_paused}
  ///
  /// @return The state as a bool
  ///
  function paused()
  public view returns (bool) {
    return _paused;
  }
  
  /// @dev Enable pause by setting {_paused}
  /// to true, then emit the related event
  ///
  function pause()
  public virtual whenNotPaused() onlyOwner() {
    _paused = true;
    emit Paused(msg.sender);
  }

  /// @dev Disable pause by setting {_paused}
  /// to false, then emit the related event
  ///
  function unpause()
  public virtual whenPaused() onlyOwner() {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import './ERC20.sol';
import './Roleplay.sol';
import './Pauseable.sol';
import './Minteable.sol';
import './Burneable.sol';

/// @title UnissouToken
///
/// @notice This contract covers everything related
/// to the Unissou ERC20
///
/// @dev Inehrit {ERC20}, {Roleplay}, {Pauseable},
/// {Minteable} and {Burneable}
///
abstract contract UnissouToken is 
ERC20, Roleplay, Pauseable, Minteable, Burneable {

  /// @notice Original contract's deployer are granted
  /// with Owner role and Manager role and the initial
  /// supply are minted onto his wallet.
  ///
  /// @dev See {ERC20}
  ///
  constructor()
  public ERC20(
    "Unissou",
    "YTG",
    384400 * (10**8),
    96100 * (10**8)
  ) {
    _setupRole(ROLE_OWNER, msg.sender);
    _setupRole(ROLE_MANAGER, msg.sender);
    _mint(msg.sender, initialSupply());
  }
  
  /// @notice This function allows to transfer tokens to multiple
  /// addresses in only one transaction, that help to reduce fees.
  /// The amount cannot be dynamic and is constant for all transfer
  ///
  /// @param _receivers - Represent an array of address
  /// @param _amount - Represent the amount of token to transfer
  ///
  function transferBatch(
    address[] memory _receivers,
    uint256 _amount
  ) public virtual {
    uint256 i = 0;
    uint256 len = _receivers.length;

    require(
      balanceOf(msg.sender) >= (_amount * len),
      "UT:470"
    );

    while (i < len) {
      transfer(_receivers[i], _amount);
      i++;
    }
  } 

  /// @notice This function allows the sender to mint
  /// an {_amount} of token unless the {_amount}
  /// exceed the total supply cap
  ///
  /// @dev Once the minting is down, minting is disabled
  ///
  /// Requirements:
  /// See {Minteable::isMinteable()}
  ///
  /// @param _amount - Represent the amount of token
  /// to be minted
  ///
  function mint(
    uint256 _amount
  ) public virtual isMinteable(
    _amount,
    hasRole(ROLE_MINTER, msg.sender)
  ) {
    _mint(msg.sender, _amount);
    _disableMinting();
  }

  /// @notice This function allows the sender to mint
  /// an {_amount} of token directly onto the address {_to}
  /// unless the {_amount} exceed the total supply cap
  ///
  /// @dev Once the minting is down, minting is disabled
  ///
  /// Requirements:
  /// See {Minteable::isMinteable()}
  ///
  /// @param _to - Represent the token's receiver
  /// @param _amount - Represent the amount of token
  /// to be minted
  ///
  function mintTo(
    address _to,
    uint256 _amount
  ) public virtual isMinteable(
    _amount,
    hasRole(ROLE_MINTER, msg.sender)
  ) {
    _mint(_to, _amount);
    _disableMinting();
  }

  /// @notice This function allows the sender to burn
  /// an {_amount} of token
  ///
  /// @dev Once the burning is down, burning is disabled
  ///
  /// Requirements:
  /// See {Burneable::isBurneable()}
  ///
  /// @param _amount - Represent the amount of token
  /// to be burned
  ///
  function burn(
    uint256 _amount
  ) public virtual isBurneable(
    _amount,
    hasRole(ROLE_BURNER, msg.sender)
  ) {
    _burn(msg.sender, _amount);
    _disableBurning();
  }

  /// @notice This function allows the sender to burn
  /// an {_amount} of token directly from the address {_from}
  /// only if the token allowance is superior or equal
  /// to the requested {_amount}
  ///
  /// @dev Once the burning is down, burning is disabled
  ///
  /// Requirements:
  /// See {Burneable::isBurneable()}
  ///
  /// @param _from - Represent the token's receiver
  /// @param _amount - Represent the amount of token
  /// to be burned
  ///
  function burnFrom(
    address _from,
    uint256 _amount
  ) public virtual isBurneable(
    _amount,
    hasRole(ROLE_BURNER, msg.sender)
  ) {
    uint256 decreasedAllowance = allowance(_from, msg.sender).sub(_amount);
    _approve(_from, msg.sender, decreasedAllowance);
    _burn(_from, _amount);
    _disableBurning();
  }

  /// @notice This function does verification before
  /// any token transfer. The actual verification are:
  /// - If the total supply don't exceed the total
  /// supply cap (for example, when token are minted),
  /// - If the token's transfer are not paused
  ///
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);

    if (from == address(0)) {
      require(
        totalSupply().add(amount) <= totalSupplyCap(),
        "UT:20"
      );
    }

    require(
      !paused(),
      "UT:400"
    );
  }
}
