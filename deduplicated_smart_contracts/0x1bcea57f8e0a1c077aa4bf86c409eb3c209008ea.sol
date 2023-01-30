/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File: localhost/packages/contracts/contracts/TokenSaver.sol

pragma solidity ^0.5.0;



contract TokenSaver is Ownable {

    function saveEther() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function saveTokens(address _token) external onlyOwner {
        IERC20 token = IERC20(_token);
        // Some tokens do not allow a balance to drop to zero so we leave 1 wei to be save
        token.transfer(msg.sender, token.balanceOf(msg.sender) - 1);
    }

}
// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: localhost/packages/contracts/contracts/partials/PartialPush.sol

pragma solidity ^0.5.0;





library PartialPush {
    using Math for uint256;
    using Address for address;

    function push(IERC20 _token, address _receiver, uint256 _amount) internal {
        uint256 amount = Utils.balanceOrAmount(_token, _amount);
        if(address(_token) == address(0)) {
            _receiver.toPayable().transfer(amount);
        }
        _token.transfer(_receiver, amount);
    }
}
// File: localhost/packages/contracts/contracts/partials/PartialPull.sol

    pragma solidity ^0.5.0;



library PartialPull {
    using Math for uint256;

    function pull(IERC20 _token, uint256 _amount) internal {
        if(address(_token) == address(0)) {
            require(msg.value == _amount, "PartialPull.pull: MSG_VALUE_INCORRECT");
        }
        // uint256 amount = Utils.balanceOrAmount(_token, _amount);
        // Either pull the balance, allowance or _amount, whichever is the smallest number
        uint256 amount = _token.balanceOf(msg.sender).min(_amount).min(_token.allowance(msg.sender, address(this)));
        require(_token.transferFrom(msg.sender, address(this), amount), "PartialPull.pull: TRANSFER_FAILED");
    }
}


// File: localhost/packages/contracts/contracts/Registry.sol

pragma solidity ^0.5.0;


contract Registry is Ownable {
    mapping(bytes32 => address) internal contracts;

    function lookup(bytes32 _hashedName) external view returns(address) {
        return contracts[_hashedName];
    }

    function lookup(string memory _name) public view returns(address){
        return contracts[keccak256(abi.encodePacked(_name))];
    }

    function setContract(string memory _name, address _contractAddress) public {
        setContract(keccak256(abi.encodePacked(_name)), _contractAddress);
    }

    function setContract(bytes32 _hashedName, address _contractAddress) public onlyOwner {
        contracts[_hashedName] = _contractAddress;
    }
}
// File: localhost/packages/contracts/contracts/libraries/RL.sol

pragma solidity ^0.5.0;


library RL {
    Registry constant internal registry = Registry(0xDc7eB6c5d66e4816E5CC69a70AA22f4584167333);

    // keccakc256(abi.encodePacked("sai"));
    bytes32 public constant _sai = 0x121766960ca66154cf52cc7f62663f2342706e7901d35f1d93fb4a7c321fa14a;
    bytes32 public constant _dai = 0x9f08c71555a1be56230b2e2579fafe4777867e0a1b947f01073e934471de15c1;
    bytes32 public constant _daiMigrationContract = 0x42d07b69ad62387b020b27e811fc060bc382308c513cb96f08ea805c77a04f9b;

    bytes32 public constant _cache = 0x422c51ed3da5a7658c50a3684c705b5f1e3d2d1673c5e16aaf93ea6271bb54cf;
    bytes32 public constant _gateKeeper = 0xcfa0d7a8bc1be8e2b981746eace0929cdd2721f615b63382540820f02696577b;
    bytes32 public constant _treasury = 0xcbd818ad4dd6f1ff9338c2bb62480241424dd9a65f9f3284101a01cd099ad8ac;
    
    bytes32 public constant _kyber = 0x758760f431d5bf0c2e6f8c11dbc38ddba93c5ba4e9b5425f4730333b3ecaf21b;
    bytes32 public constant _synthetix = 0x52da455363ee608ccf172b43cb25e66cd1734a315508cf1dae3e995e8106011a;
    bytes32 public constant _synthetixDepot = 0xcfead29a36d4ab9b4a23124bdd16cdd5acfdf5334caa9b0df48b01a0b6d68b20;


    function lookup(bytes32 _hashedName) internal view returns(address) {
        return registry.lookup(_hashedName);
    }

    function dai() internal pure returns(bytes32) {
        return _dai;
    }
    function sai() internal pure returns(bytes32) {
        return _sai;
    }
    function daiMigrationContract() internal pure returns(bytes32) {
        return _daiMigrationContract;
    }
    function cache() internal pure returns(bytes32) {
        return _cache;
    }
    function gateKeeper() internal pure returns(bytes32) {
        return _gateKeeper;
    }
    function treasury() internal pure returns(bytes32) {
        return _treasury;
    }

    function kyber() internal pure returns(bytes32) {
        return _kyber;
    }
    function synthetix() internal pure returns(bytes32) {
        return _synthetix;
    }
    function synthetixDepot() internal pure returns(bytes32) {
        return _synthetixDepot;
    }
}
// File: localhost/packages/contracts/contracts/interfaces/IScdMcdMigration.sol

pragma solidity ^0.5.0;

interface IScdMcdMigration {
    function swapSaiToDai(uint256 _amount) external;
    function swapDaiToSai(uint256 _amount) external;
}
// File: localhost/packages/contracts/contracts/partials/PartialMcdMigration.sol

pragma solidity ^0.5.0;





library PartialMcdMigration {

    function swapSaiToDai(uint256 _amount) internal {
        IERC20 sai = IERC20(RL.lookup(RL.sai()));
        IScdMcdMigration daiMigrationContract = IScdMcdMigration(RL.lookup(RL.daiMigrationContract()));
        uint256 amount = Utils.balanceOrAmount(sai, _amount);
        sai.approve(address(daiMigrationContract), amount);
        daiMigrationContract.swapSaiToDai(amount);
    }

    function swapDaiToSai(uint256 _amount) internal {
        IERC20 dai = IERC20(RL.lookup(RL.dai()));
        IScdMcdMigration daiMigrationContract = IScdMcdMigration(RL.lookup(RL.daiMigrationContract()));
        uint256 amount = Utils.balanceOrAmount(dai, _amount);
        dai.approve(address(daiMigrationContract), amount);
        daiMigrationContract.swapDaiToSai(amount);
    }
}
// File: @openzeppelin/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: localhost/packages/contracts/contracts/libraries/Utils.sol

pragma solidity ^0.5.0;



// Should not forget to linkx
library Utils {
    using Math for uint256;

    function balanceOrAmount(IERC20 _token, uint256 _amount) internal view returns(uint256) {
        if(address(_token) == address(0)) {
            return address(this).balance;
        }
        return _token.balanceOf(address(this)).min(_amount);
        // return 1 ether;
    }
}
// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: localhost/packages/contracts/contracts/interfaces/IIToken.sol

pragma solidity ^0.5.0;

interface IIToken {
    function mint(
        address _receiver,
        uint256 _depositAmount)
        external
        returns (uint256 _mintAmount);

    function burn(
        address receiver,
        uint256 burnAmount)
        external
        returns (uint256 loanAmountPaid);
    function loanTokenAddress() external view returns (address);
    function tokenPrice() external view returns (uint256);
}
// File: localhost/packages/contracts/contracts/partials/PartialFulcrum.sol

pragma solidity ^0.5.0;





library PartialFulcrum {
    using SafeMath for uint256;

    function mint(IIToken _iToken, address _receiver, uint256 _amount) internal {
        IERC20 underlying = IERC20(_iToken.loanTokenAddress());
        uint256 amount = Utils.balanceOrAmount(underlying, _amount);
        underlying.approve(address(_iToken), amount);
        _iToken.mint(_receiver, amount);
    }

    function burn(IIToken _iToken, address _receiver, uint256 _amount) internal {
        uint256 amount = Utils.balanceOrAmount(IERC20(address(_iToken)), _amount);
        uint256 amountPaid = _iToken.burn(_receiver, amount);
        require(amountPaid >= amount.mul(10**18).div(_iToken.tokenPrice()) - 1, "FULCRUM_NOT_LIQUID");
    }

}
// File: localhost/packages/contracts/contracts/static-recipes/FulcrumMcdBridge.sol

pragma solidity ^0.5.0;








contract FulcrumMcdBridge is TokenSaver {

    uint256 constant MAX = uint256(-1);

    address iSAI;
    address iDAI;

    constructor(address _iSAI, address _iDAI) public {
        iSAI = _iSAI;
        iDAI = _iDAI;
    }

    function bridgeISaiToIDai(uint256 _amount) external {
        PartialPull.pull(IERC20(iSAI), _amount);
        PartialFulcrum.burn(IIToken(iSAI), address(this), _amount);
        PartialMcdMigration.swapSaiToDai(MAX);
        PartialFulcrum.mint(IIToken(iDAI), msg.sender, MAX);
    }

    function bridgeIDaiToISai(uint256 _amount) external {
        PartialPull.pull(IERC20(iDAI), _amount);
        PartialFulcrum.burn(IIToken(iDAI), address(this), _amount);
        PartialMcdMigration.swapDaiToSai(MAX);
        PartialFulcrum.mint(IIToken(iSAI), msg.sender, MAX);
    }
}