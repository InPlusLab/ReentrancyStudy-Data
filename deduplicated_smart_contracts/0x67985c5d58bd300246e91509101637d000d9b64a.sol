/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity 0.4.26;

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
/**
 * @title ERC20
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @dev ERC20 Escrow legible as Bounty Board with arbitration logic.
 * @author R. Ross Campbell
 */
contract BountyBoard {
    using SafeMath for uint256;
    
    string public bounty;
    uint256 public bountyID;
    uint256 public bountyPrice;
    address public bountyToken;
    address public bountyMaker;
    address public bountyHunter;
    address public arbiter;
    
    uint256 public arbiterFee;
    
    enum State { Blank, Posted, Claimed, Disputed }
    State public state;
    
    event bountyPosted(string indexed bounty, uint256 price, address indexed bountyToken);
    event bountyClaimed(address indexed bountyHunter);
    event bountyWithdrawn();
    event Disputed();
    event Resolved(address indexed this, address indexed bountyMaker, address indexed bountyHunter);
/**
 * @dev Sets the Bounty Board stable values for `bounty`, `price`, 'tokenContract', `buyer`, `seller`, 'arbiter', 'arbiterFee'. All seven of
 * these values are immutable: they can only be set once during construction and reflect essential deal terms.
 */    
   constructor(address _bountyMaker)
        public {
                bountyMaker = _bountyMaker;
               }
                /**
                 * @dev Throws if called by any account other than buyer.
                 */
                  modifier onlyBountyMaker() {
                        require(msg.sender == bountyMaker);
                         _;
                        }
                /**
                 * @dev Throws if called by any account other than buyer or seller.
                 */
                  modifier onlyBountyMakerOrBountyHunter() {
                        require(
                        msg.sender == bountyMaker ||
                        msg.sender == bountyHunter);
                         _;
                        }
                /**
                 * @dev Throws if called by any account other than arbiter.
                 */
                  modifier onlyArbiter() {
                        require(msg.sender == arbiter);
                         _;
                        }
                /**
                 * @dev Throws if contract called in State other than one associated for function.
                 */
                  modifier inState(State _state) {
                        require(state == _state);
                         _;
                        }
           function postBounty(string memory _bounty, uint256 _bountyPrice, address _bountyToken, address _arbiter, uint256 _arbiterFee) public onlyBountyMaker inState(State.Blank) {
                state = State.Posted;
                bounty = _bounty;
                bountyPrice = _bountyPrice;
                bountyToken = _bountyToken;
                arbiter = _arbiter;
                arbiterFee = _arbiterFee;
                bountyID = now;
                emit bountyPosted(bounty, bountyPrice, bountyToken);
                }
            function withdrawBounty() public onlyBountyMaker inState(State.Posted) {
                state = State.Blank;
                ERC20 token = ERC20(bountyToken);
                uint256 tokenBalance = token.balanceOf(this);
                token.transfer(bountyMaker, tokenBalance);
                emit bountyWithdrawn();
                }
            function assignBounty(address _bountyHunter) public onlyBountyMaker inState(State.Posted) {
                state = State.Claimed;
                bountyHunter = _bountyHunter;
                emit bountyClaimed(bountyHunter);
                }
        /**
         * @dev bountyMaker confirms receipt of bounty service from bountyHunter;
         * bounty 'Price' is transferred to bountyHunter.
         * (presuming bountyMaker deposits to escrow to motivate bountyHunter delivery)
         */
           function confirmReceipt() public onlyBountyMaker inState(State.Claimed) {
                state = State.Blank;
                ERC20 token = ERC20(bountyToken);
                uint256 tokenBalance = token.balanceOf(this);
                token.transfer(bountyHunter, tokenBalance);
                }
        /**
         * @dev bountyMaker or bountyHunter can initiate dispute related to bounty transaction,
         * placing bounty 'Price' transfer and split of value into arbiter control.
         */
           function initiateDispute() public onlyBountyMakerOrBountyHunter inState(State.Claimed) {
                state = State.Disputed;
                emit Disputed();
                }
        /**
         * @dev Arbiter can resolve dispute and claim token reward by entering in split of 'price' value,
         * minus 5% 'arbiter fee'.
         */
           function resolveDispute(uint256 MakerAward, uint256 HunterAward) public onlyArbiter inState(State.Disputed) {
                state = State.Blank;
                ERC20 token = ERC20(bountyToken);
                token.transfer(bountyMaker, MakerAward);
                token.transfer(bountyHunter, HunterAward);
                token.transfer(arbiter, arbiterFee);
                emit Resolved(address(this), bountyMaker, bountyHunter);
                }
}