/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity ^0.5.0;


// import SafeMath for safety checks
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

// import abstract token contract
contract ERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address tokenlender) external view returns (uint balance);
	function allowance(address tokenlender, address spender) external view returns (uint remaining);
	function transfer(address to, uint tokens) external returns (bool success);
	function approve(address spender, uint tokens) external returns (bool success);
	function transferFrom(address from, address to, uint tokens) public returns (bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenlender, address indexed spender, uint tokens);
}

contract ApprovalHolder {

	using SafeMath for uint256;

// Declare public parameters

address payable public owner;
address public admin;
address public taxRecipient;
uint256 public taxFee;
ERC20 public token;
mapping(address => bool) public isInvoker;

// Declare events
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event AdminTransferred(address indexed previousOwner, address indexed newOwner);
event InvokerAdded(address indexed newInvoker);
event InvokerRemoved(address indexed previousInvoker);
event RecipientChanged(address indexed previousRecipient, address indexed newRecipient);
event TaxFeeChanged(uint256 indexed previousFee, uint256 indexed newFee);
event TransferOnBehalf(address indexed from, address indexed to, uint256 value, uint256 tax, address taxRecipient, address tokenAddress);
event TokenTransferred(address indexed to, uint256 amount);  
event EtherTransferred(address indexed to, uint256 amount);  

    /**
     * Constructor function
  	 * @param _admin The address which is responsible for management.
  	 * @param _taxRecipient The address receiving funds such as tax.
  	 * @param _taxFee The tax fee applied
     * Initializes contract.
     */
     constructor(address _admin, address _taxRecipient, uint256 _taxFee, address _tokenAddress) public {
     	owner = msg.sender;
     	admin = _admin;
     	taxRecipient = _taxRecipient; 	
     	taxFee = _taxFee;
     	token = ERC20(_tokenAddress);
     }

	// functions for the owner

/**
* @dev destruct the contract, remaining ETH will be sent to the owner
*/
function selfDestruct() public {
	require(msg.sender == owner);
	selfdestruct(owner);
}

/**
* @dev transfer ownership
* @param _newOwner The address of the new owner
*/
function transferOwnership(address payable _newOwner) public {
	require(msg.sender == owner);
	owner = _newOwner;
	emit OwnershipTransferred(msg.sender, owner);
}

	// functions for the admin

/**
* @dev transfer administration right
* @param _newAdmin The address of the new admin
*/
function transferAdmin(address _newAdmin) public {
	require(msg.sender == admin);
	admin = _newAdmin;
	emit AdminTransferred(msg.sender, admin);
}

/**
* @dev admin invoker
* @param _newInvoker The address of the new invoker
*/
function addInvoker(address _newInvoker) public {
	require(msg.sender == admin);
	isInvoker[_newInvoker] = true;
	emit InvokerAdded(_newInvoker);
}

/**
* @dev remove invoker
* @param _previousInvoker The invoker address to be removed
*/
function removeInvoker(address _previousInvoker) public {
	require(msg.sender == admin);
	require(isInvoker[_previousInvoker] == true);
	isInvoker[_previousInvoker] = false;
	emit InvokerRemoved(_previousInvoker);
}

/**
* @dev change tax recipient address
* @param _newRecipient new recipient address to receive tax tokens
*/
function changeRecipient(address _newRecipient) public {
	require(msg.sender == admin);
	address _previousRecipient = taxRecipient;
	taxRecipient = _newRecipient;
	emit RecipientChanged(_previousRecipient, _newRecipient);
}

/**
* @dev change tax fee 
* @param _newFee new tax fee
*/
function changeTaxFee(uint256 _newFee) public {
	require(msg.sender == admin);
	uint256 _previousFee = taxFee;
	taxFee = _newFee;
	emit TaxFeeChanged(_previousFee, _newFee);
}

/**
* @dev transfer tokens which are wrongly sent to this contract address to a given address
* @param _tokenRecipient address to receive tokens
* @param _amount  amount of tokens to be sent
*/
function transferToken(address _tokenRecipient, uint256 _amount) public {
    require(msg.sender == admin);
    require(token.transfer(_tokenRecipient, _amount));
    emit TokenTransferred(_tokenRecipient, _amount);
}

/**
* @dev transfer ethers which are wrongly sent to this contract address to a given address
* @param _etherRecipient address to receive tokens
* @param _amount  amount of tokens to be sent
*/
function transferEther(address payable _etherRecipient, uint256 _amount) public {
    require(msg.sender == admin);
    _etherRecipient.transfer(_amount);
    emit EtherTransferred(_etherRecipient, _amount);
}



	// functions for invokers

/**
* @dev transfer on behalf of clients
* @param from the address tokens are transferred from
* @param to the address tokens are transferred to
* @param amount the amount of tokens are being transferred
*/
function transferOnBehalf(address from, address to, uint256 amount) public {
    require(isInvoker[msg.sender] == true);
         // avoid dual transactions when tax fee is set to be 0
         if(taxFee == 0) {
            require(token.transferFrom(from, to, amount));
            } else {
                require(token.transferFrom(from, to, amount));
                require(token.transferFrom(from, taxRecipient, taxFee));
            }
            emit TransferOnBehalf(from, to, amount, taxFee, taxRecipient, address(token));
        }
    }