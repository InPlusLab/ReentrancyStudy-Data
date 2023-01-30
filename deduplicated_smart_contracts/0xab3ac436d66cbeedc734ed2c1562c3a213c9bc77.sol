/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

// File: contracts/external/SafeMath.sol

pragma solidity 0.5.12;


/**
 * @title Math provides arithmetic functions for uint type pairs.
 * You can safely `plus`, `minus`, `times`, and `divide` uint numbers without fear of integer overflow.
 * You can also find the `min` and `max` of two numbers.
 */
library SafeMath {

  function min(uint x, uint y) internal pure returns (uint) { return x <= y ? x : y; }
  function max(uint x, uint y) internal pure returns (uint) { return x >= y ? x : y; }


  /** @dev adds two numbers, reverts on overflow */
  function plus(uint x, uint y) internal pure returns (uint z) { require((z = x + y) >= x, "bad addition"); }

  /** @dev subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend) */
  function minus(uint x, uint y) internal pure returns (uint z) { require((z = x - y) <= x, "bad subtraction"); }


  /** @dev multiplies two numbers, reverts on overflow */
  function times(uint x, uint y) internal pure returns (uint z) { require(y == 0 || (z = x * y) / y == x, "bad multiplication"); }

  /** @dev divides two numbers and returns the remainder (unsigned integer modulo), reverts when dividing by zero */
  function mod(uint x, uint y) internal pure returns (uint z) {
    require(y != 0, "bad modulo; using 0 as divisor");
    z = x % y;
  }

  /** @dev Integer division of two numbers truncating the quotient, reverts on division by zero */
  function div(uint a, uint b) internal pure returns (uint c) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
  }

}

// File: contracts/gluon/GluonView.sol

pragma solidity 0.5.12;


interface GluonView {
  function app(uint32 id) external view returns (address current, address proposal, uint activationBlock);
  function current(uint32 id) external view returns (address);
  function history(uint32 id) external view returns (address[] memory);
  function getBalance(uint32 id, address asset) external view returns (uint);
  function isAnyLogic(uint32 id, address logic) external view returns (bool);
  function isAppOwner(uint32 id, address appOwner) external view returns (bool);
  function proposals(address logic) external view returns (bool);
  function totalAppsCount() external view returns(uint32);
}

// File: contracts/gluon/GluonCentric.sol

pragma solidity 0.5.12;



contract GluonCentric {
  uint32 internal constant REGISTRY_INDEX = 0;
  uint32 internal constant STAKE_INDEX = 1;

  uint32 public id;
  address public gluon;

  constructor(uint32 id_, address gluon_) public {
    id = id_;
    gluon = gluon_;
  }

  modifier onlyCurrentLogic { require(currentLogic() == msg.sender, "invalid sender; must be current logic contract"); _; }
  modifier onlyGluon { require(gluon == msg.sender, "invalid sender; must be gluon contract"); _; }
  modifier onlyOwner { require(GluonView(gluon).isAppOwner(id, msg.sender), "invalid sender; must be app owner"); _; }

  function currentLogic() public view returns (address) { return GluonView(gluon).current(id); }
}

// File: contracts/apps/stake/StakeData.sol

pragma solidity 0.5.12;




contract StakeData is GluonCentric {
  using SafeMath for uint;

  mapping(address => address[]) public accountToProposals;
  mapping(address => bool[]) public accountToSides;
  mapping(address => mapping(bool => uint)) public voteTally; // proposal => side(true/false) => totalVotes
  mapping(address => address) public accountLocation; // account => logic
  mapping(address => uint) public balance;

  constructor(address gluon) GluonCentric(STAKE_INDEX, gluon) public { }

  function updateAccountLocation(address account, address logic) external onlyCurrentLogic { accountLocation[account] = logic; }

  function updateBalance(address account, uint quantity) external onlyCurrentLogic { balance[account] = quantity; }

  function voteAppUpgrade(address proposal, address account, bool side, uint quantity) external onlyCurrentLogic returns (uint, uint) {
    uint index = getVoteIndex(account, proposal);
    bool firstVote = index == accountToProposals[account].length;
    require(firstVote || accountToSides[account][index] != side, "cannot vote same side again");
    if (firstVote) {
      accountToProposals[account].push(proposal);
      accountToSides[account].push(side);
    } else {
      voteTally[proposal][!side] = voteTally[proposal][!side].minus(quantity);
      accountToSides[account][index] = side;
    }
    voteTally[proposal][side] = voteTally[proposal][side].plus(quantity);
    return getVoteTally(proposal);
  }

  function deleteVoteTally(address proposal) external onlyCurrentLogic {
    voteTally[proposal][true] = voteTally[proposal][false] = 0;
  }

  function getVoteIndex(address account, address proposal) public view returns (uint) {
    address[] memory proposals = accountToProposals[account];
    for (uint i = 0; i < proposals.length; i++) {
      if (proposals[i] == proposal) return i;
    }
    return proposals.length;
  }

  function getAllProposals(address account) external view returns (address[] memory proposals, bool[] memory sides) {
    proposals = accountToProposals[account];
    sides = accountToSides[account];
  }

  function removeResolvedProposals(address account) external onlyCurrentLogic {
    if (accountToProposals[account].length == 0) return;
    address[] storage allProposed = accountToProposals[account];
    bool[] storage sides = accountToSides[account];
    for (uint i = allProposed.length; i > 0; i--) {
      if (!GluonView(gluon).proposals(allProposed[i - 1])) {
        allProposed[i - 1] = allProposed[allProposed.length - 1];
        allProposed.pop();
        sides[i - 1] = sides[sides.length - 1];
        sides.pop();
      }
    }
  }

  function updateVotes(address proposal, bool side, uint quantity, bool increased) external onlyCurrentLogic returns (uint approvals, uint disapprovals) {
    uint tally = voteTally[proposal][side];
    voteTally[proposal][side] = increased ? tally.plus(quantity) : tally.minus(quantity);
    return getVoteTally(proposal);
  }

  function getVoteTally(address proposal) public view returns (uint approvals, uint disapprovals) {
    approvals = voteTally[proposal][true];
    disapprovals = voteTally[proposal][false];
  }

}