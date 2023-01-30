/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

pragma solidity ^0.5.2;
/**
* @title ERC20 interface 
* @dev see https://eips.ethereum.org/EIPS/eip-20 
*/
interface IERC20 { 
    function transfer(address to, uint256 value) external returns (bool); 
    
    function approve(address spender, uint256 value) external returns (bool); 
    
    function transferFrom(address from, address to, uint256 value) external returns (bool); 
    
    function totalSupply() external view returns (uint256); 
    
    function balanceOf(address who) external view returns (uint256); 
    
    function allowance(address owner, address spender) external view returns (uint256); 
    
    event Transfer(address indexed from, address indexed to, uint256 value); 
    
    event Approval(address indexed owner, address indexed spender, uint256 value); 
}

/**
* @title SafeMath 
* @dev Unsigned math operations with safety checks that revert on error
*/
library SafeMath { 
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow. 
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { 
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the 
        // benefit is lost if 'b' is also tested. 
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522 
        if (a == 0) { 
            return 0;
        }
        uint256 c = a * b; 
        require(c / a == b); 
        return c; 
    }
    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero. 
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        // Solidity only automatically asserts when dividing by 0 
        require(b > 0); 
        uint256 c = a / b; 
        //assert(a == b * c + a % b); //There is no case in which this doesn't hold 
        return c; 
    }
    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend). 
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    { 
        require(b <= a); 
        uint256 c = a - b; 
        return c; 
    }
    /**
    * @dev Adds two unsigned integers, reverts on overflow. 
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    { 
        uint256 c = a + b; 
        require(c >= a); 
        return c; 
    }
    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo), 
    * reverts when dividing by zero. 
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) 
    { 
        require(b != 0); 
        return a % b; 
    }
}

/**
* @title Standard ERC20 token *
* @dev Implementation of the basic standard token. 
* https://eips.ethereum.org/EIPS/eip-20 
* Originally based on code by FirstBlood: 
* https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol 
*
* This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for 
* all accounts just by listening to said events. Note that this isn't required by the specification, and other 
* compliant implementations may not do it. 
*/
contract TOKEN is IERC20 {
    using SafeMath for uint256;//ͨ�����ַ�ʽӦ�� SafeMath ������

    string private _name; 
    string private _symbol; 
    uint8 private _decimals; 

    mapping (address => uint256) private _balances; 
    mapping (address => mapping (address => uint256)) private _allowed; 
    uint256 private _totalSupply;

    //ʹ�ù��캯����ʼ������
    constructor( uint256 initialSupply, string memory tokenName, uint8 decimalUnits, string memory tokenSymbol ) public 
    { 
        _balances[msg.sender] = initialSupply; 
        // Give the creator all initial tokens 
        _totalSupply = initialSupply; 
        // Update total supply 
        _name = tokenName; 
        // Set the name for display purposes 
        _symbol = tokenSymbol; 
        // Set the symbol for display purposes 
        _decimals = decimalUnits; 
        // Amount of decimals for display purposes 
    }

    /**
    * @dev Name of tokens in existence 
    */
    function name() public view returns (string memory) 
    { 
        return _name; 
    }

    /**
    * @dev Symbol of tokens in existence 
    */
    function symbol() public view returns (string memory) 
    { 
        return _symbol; 
    }

    /**
    * @dev decimals of tokens in existence 
    */
    function decimals() public view returns (uint8) 
    { 
        return _decimals; 
    }

    /**
    * @dev Total number of tokens in existence 
    */
    function totalSupply() public view returns (uint256) 
    { 
        return _totalSupply; 
    }

    /**
    * @dev Gets the balance of the specified address. 
    * @param owner The address to query the balance of. 
    * @return A uint256 representing the amount owned by the passed address. 
    */
    function balanceOf(address owner) public view returns (uint256) 
    { 
        return _balances[owner]; 
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender. 
    * @param owner address The address which owns the funds. 
    * @param spender address The address which will spend the funds. 
    * @return A uint256 specifying the amount of tokens still available for the spender. 
    */
    function allowance(address owner, address spender) public view returns (uint256) 
    { 
        return _allowed[owner][spender]; 
    }

    /**
    * @dev Transfer token to a specified address 
    * @param to The address to transfer to. 
    * @param value The amount to be transferred. 
    */
    function transfer(address to, uint256 value) public returns (bool) 
    { 
        _transfer(msg.sender, to, value); 
        return true; 
    }

    /**
    * @dev Burns a specific amount of tokens. * @param value The amount of token to be burned. 
    */
    function burn(uint256 value) public 
    { 
        _burn(msg.sender, value); 
    }

    /**
    * @dev Burns a specific amount of tokens from the target address and decrements allowance 
    * @param from address The account whose tokens will be burned. 
    * @param value uint256 The amount of token to be burned. 
    */
    function burnFrom(address from, uint256 value) public 
    { 
        _burnFrom(from, value); 
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender. 
    * Beware that changing an allowance with this method brings the risk that someone may use both the old 
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this 
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards: 
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 
    * @param spender The address which will spend the funds. 
    * @param value The amount of tokens to be spent. 
    */
    function approve(address spender, uint256 value) public returns (bool) 
    { 
        _approve(msg.sender, spender, value); 
        return true; 
    }

    /**
    * @dev Transfer tokens from one address to another. 
    * Note that while this function emits an Approval event, this is not required as per the specification, 
    * and other compliant implementations may not emit the event. 
    * @param from address The address which you want to send tokens from 
    * @param to address The address which you want to transfer to 
    * @param value uint256 the amount of tokens to be transferred 
    */
    function transferFrom(address from, address to, uint256 value) public returns (bool) 
    { 
        _transfer(from, to, value); 
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value)); 
        return true; 
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender. 
    * approve should be called when _allowed[msg.sender][spender] == 0. To increment 
    * allowed value is better to use this function to avoid 2 calls (and wait until 
    * the first transaction is mined) 
    * From MonolithDAO Token.sol 
    * Emits an Approval event. 
    * @param spender The address which will spend the funds. 
    * @param addedValue The amount of tokens to increase the allowance by. 
    */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    { 
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue)); 
        return true; 
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender. 
    * approve should be called when _allowed[msg.sender][spender] == 0. To decrement 
    * allowed value is better to use this function to avoid 2 calls (and wait until 
    * the first transaction is mined) 
    * From MonolithDAO Token.sol * Emits an Approval event.
    * @param spender The address which will spend the funds. 
    * @param subtractedValue The amount of tokens to decrease the allowance by. 
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    { 
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue)); 
        return true; 
    }

    /**
    * @dev Transfer token for a specified addresses 
    * @param from The address to transfer from. 
    * @param to The address to transfer to. 
    * @param value The amount to be transferred. 
    */
    function _transfer(address from, address to, uint256 value) internal 
    { 
        require(to != address(0));
        //����ַ�Ƿ�Ϊ�� 
        _balances[from] = _balances[from].sub(value);
        //�ȼ���ӣ������Ƽ�������ʹ�� SafeMath ����������ֵ������������Ϲ淶
        _balances[to] = _balances[to].add(value); 
        emit Transfer(from, to, value); 
    }
    
    /**
    * @dev Internal function that burns an amount of the token of a given 
    * account. 
    * @param account The account whose tokens will be burnt. 
    * @param value The amount that will be burnt. 
    */
    function _burn(address account, uint256 value) internal 
    { 
        require(account != address(0));
        //����ַ�Ƿ�Ϊ��
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
    * @dev Approve an address to spend another addresses' tokens. 
    * @param owner The address that owns the tokens. 
    * @param spender The address that will spend the tokens. 
    * @param value The number of tokens that can be spent. 
    */
    function _approve(address owner, address spender, uint256 value) internal 
    { 
        require(spender != address(0));
        //����ַ�Ƿ�Ϊ�� 
        require(owner != address(0));
        //����ַ�Ƿ�Ϊ��
        //�˴���������˳���������գ�����������������ֹ
        require(value == 0 || (_allowed[owner][spender] == 0));
        _allowed[owner][spender] = value; 
        emit Approval(owner, spender, value); 
    }
    /**
    * @dev Internal function that burns an amount of the token of a given 
    * account, deducting from the sender's allowance for said account. Uses the 
    * internal burn function. 
    * Emits an Approval event (reflecting the reduced allowance). 
    * @param account The account whose tokens will be burnt. 
    * @param value The amount that will be burnt. 
    */
    function _burnFrom(address account, uint256 value) internal 
    { 
        _burn(account, value); 
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value)); 
    }
}