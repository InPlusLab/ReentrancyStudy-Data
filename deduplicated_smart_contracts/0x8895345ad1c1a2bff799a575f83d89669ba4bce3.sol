/**
 *Submitted for verification at Etherscan.io on 2019-10-23
*/

pragma solidity ^0.5.0;

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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

     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Bridge is Ownable {

    using SafeMath for uint256;

    enum Stage { Deployed, Claim, Pause, Swap, Finished }

    Stage public currentStage;

    uint256 public minTransferAmount;
    uint256 constant public border = 10**14;

    struct Transfer {
        string accountName;
        string accountOpenkey;
        uint256 amount;
    }

    mapping(address => Transfer) public claims;
    mapping(address => Transfer[]) public swaps;
    mapping(string => string) public nameToOpenkey;
    address[] public claimParticipants;
    address[] public swapParticipants;

    IERC20 public token;

    event NextStage(address _sender, Stage _currentStage, uint256 _timestamp);
    event Swap(address _from, string accountName, string accountOpenkey, uint256 amount, uint256 timestamp);
    event Claim(address _from, string accountName, string accountOpenkey, uint256 amount, uint256 timestamp);

    /// @dev modifier that allow to call function if current stage is bigger than specified
    modifier stageAfter(Stage _stage) {
        require(uint256(currentStage) > uint256(_stage));
        _;
    }

    /// @dev modifier that allow to call function if current stage is less than specified
    modifier stageBefore(Stage _stage) {
        require(uint256(currentStage) < uint256(_stage));
        _;
    }

    constructor(IERC20 _token, uint256 _minTransferAmount) public {
        require(_minTransferAmount >= border, 'invalid _minTransferAmount');
        minTransferAmount = _minTransferAmount;
        token = _token;
        currentStage = Stage.Deployed;
    }

    /// @dev function that call specified convert strategy to convert tokens
    function convert(string memory _accountName, string memory _accountOpenkey, uint256 _amount)
    stageAfter(Stage.Deployed)
    stageBefore(Stage.Finished)
    public {

        require(currentStage != Stage.Pause, "You can't convert tokens during a pause");        
        // openkey and account name validation check 
        require(isValidAccountName(_accountName), "invalid account name");
        require(isValidOpenkey(_accountOpenkey), "invalid openkey");
        // can not convert less that minimum amount
        require(_amount >= minTransferAmount, "too few tokens");

        string memory openkey = nameToOpenkey[_accountName];
        
        require(
                keccak256(abi.encodePacked(openkey)) == keccak256(abi.encodePacked(_accountOpenkey)) || 
                bytes(openkey).length == 0,
                "account already exist with another openkey"
            );
    
        // round tokens amount to 4 decimals
        uint256 intValue = _amount.div(border);
        uint256 roundedValue = intValue.mul(border);
        
        // transfer tokens
        require(token.transferFrom(msg.sender, address(this), roundedValue), "transferFrom failed");

        if (currentStage == Stage.Claim) {
            
            string memory registeredAccountName = claims[msg.sender].accountName;
            require(
                keccak256(abi.encodePacked(registeredAccountName)) == keccak256(abi.encodePacked(_accountName)) || 
                bytes(registeredAccountName).length == 0,
                "you have already registered an account"
            );

            // Claim stage            
            addNewClaimParticipant(msg.sender);
            uint256 previousAmount = claims[msg.sender].amount;
            claims[msg.sender] = Transfer(_accountName, _accountOpenkey, roundedValue.add(previousAmount));
            emit Claim(msg.sender, _accountName, _accountOpenkey, roundedValue, now);
        
        } else if(currentStage == Stage.Swap) {
            // Swap stage
            addNewSwapParticipant(msg.sender);
            swaps[msg.sender].push(Transfer(_accountName, _accountOpenkey, roundedValue));
            emit Swap(msg.sender, _accountName, _accountOpenkey, roundedValue, now);
        }
        
        if(bytes(openkey).length == 0) {
            nameToOpenkey[_accountName] = _accountOpenkey;
        }
    }

    function nextStage() onlyOwner stageBefore(Stage.Finished) public {
        // move to next stage
        uint256 next = uint256(currentStage) + 1;
        currentStage = Stage(next);

        emit NextStage(msg.sender, currentStage, now);
    }
    
    function setMinTransferAmount(uint256 _minTransferAmount) onlyOwner public {
        require(_minTransferAmount >= border, 'invalid _minTransferAmount');
        minTransferAmount = _minTransferAmount;
    }

    function addNewClaimParticipant(address _addr) private {
        if (claims[_addr].amount == uint256(0)) {
            claimParticipants.push(_addr);
        }
    }

        
    function addNewSwapParticipant(address _addr) private {
        if (swaps[_addr].length == uint256(0)) {
            swapParticipants.push(_addr);
        }
    }
    
    function isValidOpenkey(string memory str) public pure returns (bool) {
        bytes memory b = bytes(str);
        if(b.length != 53) return false;

        // EOS
        if (bytes1(b[0]) != 0x45 || bytes1(b[1]) != 0x4F || bytes1(b[2]) != 0x53)
            return false;

        for(uint i = 3; i<b.length; i++){
            bytes1 char = b[i];

            // base58
            if(!(char >= 0x31 && char <= 0x39) &&
               !(char >= 0x41 && char <= 0x48) &&
               !(char >= 0x4A && char <= 0x4E) &&
               !(char >= 0x50 && char <= 0x5A) &&
               !(char >= 0x61 && char <= 0x6B) &&
               !(char >= 0x6D && char <= 0x7A)) 
            return false;
        }

        return true;
    }

    function isValidAccountName(string memory account) public pure returns (bool) {
        bytes memory b = bytes(account);
        if (b.length != 12) return false;

        for(uint i = 0; i<b.length; i++){
            bytes1 char = b[i];

            // a-z && 1-5 && .
            if(!(char >= 0x61 && char <= 0x7A) && 
               !(char >= 0x31 && char <= 0x35) && 
               !(char == 0x2E)) 
            return  false;
        }
        
        return true;
    }

    function isValidAccount(string memory _accountName, string memory _accountOpenkey) public pure returns (bool) {
            return(isValidAccountName(_accountName) && isValidOpenkey(_accountOpenkey));
        }
        
}