/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.5.10;

// ====== Libraries

/**
 * @dev SafeMath
 *
 * source: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * version: 2f9ae97 (2019-05-24)
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

// ====== Interfaces

/**
* @title Contract that will work with ERC-677 tokens
* see:
* https://github.com/ethereum/EIPs/issues/677
* https://github.com/smartcontractkit/LinkToken/blob/master/contracts/ERC677Token.sol
*/
contract ERC677Receiver {
    /**
    * The function is added to contracts enabling them to react to receiving tokens within a single transaction.
    * The from parameter is the account which just transferred amount from the token contract. data is available to pass
    * additional parameters, i.e. to indicate what the intention of the transfer is if a contract allows transfers for multiple reasons.
    * @param from address sending tokens
    * @param amount of tokens
    * @param data to send to another contract
    */
    function onTokenTransfer(address from, uint256 amount, bytes calldata data) external returns (bool success);
}

/**
* @title Contract that will work with overloaded 'transfer' function
* see: https://github.com/ethereum/EIPs/issues/223
*/
contract ERC223ReceivingContract {
    /**
     * @dev Standard ERC223 function that will handle incoming token transfers.
     * @param _from  Token sender address.
     * @param _value Amount of tokens.
     * @param _data  Transaction metadata.
     */
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}

// ====== Main contract

/**
 * @title Contract that implements:
 * ERC20  (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)
 * overloaded 'transfer' function like in ERC223 https://github.com/ethereum/EIPs/issues/223
 * (but it's not fully ERC223 compliant)
 * ERC677 (https://github.com/ethereum/EIPs/issues/677)
 * overloaded 'approve' function (https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/)
*/
contract Token {

    using SafeMath for uint256;

    /* --- ERC-20 variables */

    string public name;

    string public symbol;

    uint8 public constant decimals = 0;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*
    * stored address that deployed this smart contract to blockchain
    */
    address public creator;

    /**
    * Constructor
    * no args constructor make possible to create contracts with code pre-verified on etherscan.io
    * (once we verify one contract, all next contracts with the same code and constructor args will be verified by etherscan)
    */
    constructor() public {
        creator = msg.sender;
    }

    /*
    * initializes token: set initial values for erc20 variables
    * assigns all tokens ('totalSupply') to one address ('tokenOwner')
    * @param _name Name of the token
    * @param _symbol Symbol of the token
    * @param _totalSupply Amount of tokens to create
    * @param _tokenOwner Address that will initially hold all created tokens
    */
    function initToken(
        string calldata _name,
        string calldata _symbol,
        uint256 _totalSupply,
        address tokenOwner
    ) external {

        require(msg.sender == creator, "Only creator can initialize token contract");
        require(totalSupply == 0, "This token contract already initialized");

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        balanceOf[tokenOwner] = totalSupply;

        emit Transfer(address(0), tokenOwner, totalSupply);

    }

    /* --- ERC-20 events */

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed spender, uint256 value);

    /* --- Events for interaction with other smart contracts */

    /**
    * @param _from Address that sent transaction
    * @param _toContract Receiver (smart contract)
    * @param _extraData Data sent
    */
    event DataSentToAnotherContract(address indexed _from, address indexed _toContract, bytes indexed _extraData);

    /* --- ERC-20 Functions */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){

        // Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event (ERC-20)
        // Variables of uint type cannot be negative. Thus, comparing uint variable with zero (greater than or equal) is redundant
        // require(_value >= 0);

        require(_to != address(0), "_to was 0x0 address");

        // The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism
        require(msg.sender == _from || _value <= allowance[_from][msg.sender], "Sender not authorized");

        // check if _from account have required amount
        require(_value <= balanceOf[_from], "Account doesn't have required amount");

        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);

        // If allowance used, change allowances correspondingly
        if (_from != msg.sender) {
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        }

        emit Transfer(_from, _to, _value);

        return true;
    } // end of transferFrom

    function transfer(address _to, uint256 _value) public returns (bool success){
        return transferFrom(msg.sender, _to, _value);
    }

    /**
    * overloaded transfer like in ERC223 (but it's not fully ERC223 compliant)
    * see: https://github.com/ethereum/EIPs/issues/223
    * https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol
    */
    function transfer(address _to, uint _value, bytes calldata _data) external returns (bool success){
        if (transfer(_to, _value)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
            emit DataSentToAnotherContract(msg.sender, _to, _data);
            return true;
        }
        return false;
    }

    /**
    * ERC-677
    * https://github.com/ethereum/EIPs/issues/677
    * transfer tokens with additional info to another smart contract, and calls its correspondent function
    * @param _to Another smart contract address (receiver)
    * @param _value Number of tokens to transfer
    * @param _extraData Data to send to another contract
    *
    * This function is a recommended method to send tokens to smart contracts.
    */
    function transferAndCall(address _to, uint256 _value, bytes memory _extraData) public returns (bool success){
        if (transferFrom(msg.sender, _to, _value)) {
            ERC677Receiver receiver = ERC677Receiver(_to);
            if (receiver.onTokenTransfer(msg.sender, _value, _extraData)) {
                emit DataSentToAnotherContract(msg.sender, _to, _extraData);
                return true;
            }
        }
        return false;
    }

    /**
    * the same as above ('transferAndCall'), but for all tokens on user account
    * for example for converting ALL tokens on user account to another tokens
    */
    function transferAllAndCall(address _to, bytes calldata _extraData) external returns (bool){
        return transferAndCall(_to, balanceOf[msg.sender], _extraData);
    }

    /*
    * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#approve
    * there is an attack:
    * https://github.com/CORIONplatform/solidity/issues/6,
    * https://drive.google.com/file/d/0ByMtMw2hul0EN3NCaVFHSFdxRzA/view
    * but this function is required by ERC-20:
    * To prevent attack vectors like the one described on https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/
    * and discussed on https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 ,
    * clients SHOULD make sure to create user interfaces in such a way that they set the allowance first to 0 before
    * setting it to another value for the same spender.
    * THOUGH The contract itself shouldn¡¯t enforce it, to allow backwards compatibility with contracts deployed before
    *
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * Overloaded approve function
    * see https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/
    * @param _spender The address which will spend the funds.
    * @param _currentValue The current value of allowance for spender
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _currentValue, uint256 _value) external returns (bool success){
        require(
            allowance[msg.sender][_spender] == _currentValue,
            "Current value in contract is different than provided current value"
        );
        return approve(_spender, _value);
    }

}