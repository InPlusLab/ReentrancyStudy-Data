/**
 *Submitted for verification at Etherscan.io on 2019-07-18
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
 * @dev ERC20 Token Escrow legible as Bill of Sale with Arbitration logic.
 * @author R. Ross Campbell
 */
contract BillofSaleERC20 {
    using SafeMath for uint256;
    
    string public descr;
    uint256 public price;
    address public tokenContract;
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public createdAt;
    
    uint256 private arbiterFee;
    
    enum State { Created, Confirmed, Disputed, Resolved }
    State public state;
    
    event Confirmed(address indexed this, address indexed seller);
    event Disputed();
    event Resolved(address indexed this, address indexed buyer, address indexed seller);
/**
 * @dev Sets the BOS transaction values for `descr`, `price`, 'tokenContract', `buyer`, `seller`, 'arbiter', 'arbiterFee'. All seven of
 * these values are immutable: they can only be set once during construction and reflect essential deal terms.
 */    
   constructor(
        string memory _descr,
        uint256 _price,
        address _tokenContract,
        address _buyer,
        address _seller,
        address _arbiter,
        uint256 _arbiterFee)
        public {
                descr = _descr;
                price = _price;
                tokenContract = _tokenContract;
                buyer = _buyer;
                seller = _seller;
                arbiter = _arbiter;
                arbiterFee = _arbiterFee;
                createdAt = now;
                require(price > arbiterFee, "arbiter fee cannot exceed price");
               }
                /**
                 * @dev Throws if called by any account other than buyer.
                 */
                  modifier onlyBuyer() {
                        require(msg.sender == buyer);
                         _;
                        }
                /**
                 * @dev Throws if called by any account other than buyer or seller.
                 */
                  modifier onlyBuyerOrSeller() {
                        require(
                        msg.sender == buyer ||
                        msg.sender == seller);
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
        /** 
         * @dev Buyer confirms receipt from seller;
         * token 'price' is transferred to seller.
         * (presuming buyer deposits to BOS escrow to motivate seller delivery)
         */
           function confirmReceipt() public onlyBuyer inState(State.Created) {
                state = State.Confirmed;
                ERC20 token = ERC20(tokenContract);
                uint256 tokenBalance = token.balanceOf(this);
                token.transfer(seller, tokenBalance);
                emit Confirmed(address(this), seller);
                }
        /**
         * @dev Buyer or seller can initiate dispute related to BOS transaction,
         * placing 'price' transfer and split of value into arbiter control.
         * For example, buyer might refuse or unduly delay to confirm receipt after seller delivery, 
         * or, on other hand,
         * despite buyer's dissatisfaction with seller delivery, 
         * seller might demand buyer confirm receipt and release 'price'.
         */
           function initiateDispute() public onlyBuyerOrSeller inState(State.Created) {
                state = State.Disputed;
                emit Disputed();
                }
        /**
         * @dev Arbiter can resolve dispute and claim token reward by entering in split of 'price' value,
         * minus 'arbiter fee' set at construction.
         */
           function resolveDispute(uint256 buyerAward, uint256 sellerAward) public onlyArbiter inState(State.Disputed) {
                state = State.Resolved;
                ERC20 token = ERC20(tokenContract);
                token.transfer(buyer, buyerAward);
                token.transfer(seller, sellerAward);
                token.transfer(arbiter, arbiterFee);
                emit Resolved(address(this), buyer, seller);
                }
}

contract BillofSaleERC20Factory {

  // index of created contracts

  mapping (address => bool) public validContracts; 
  address[] public contracts;

  // useful to know the row count in contracts index

  function getContractCount() 
    public
    view
    returns(uint contractCount)
  {
    return contracts.length;
  }

  // get all contracts

  function getDeployedContracts() public view returns (address[] memory)
  {
    return contracts;
  }

  // deploy a new contract

  function newBillofSaleERC20(
      string memory _descr, 
      uint256 _price,
      address _tokenContract,
      address _buyer,
      address _seller, 
      address _arbiter,
      uint256 _arbiterFee)
          public
          returns(address)
   {
    BillofSaleERC20 c = new BillofSaleERC20(
        _descr, 
        _price,
        _tokenContract,
        _buyer, 
        _seller,
        _arbiter,
        _arbiterFee);
            validContracts[c] = true;
            contracts.push(c);
            return c;
    }
}