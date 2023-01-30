/**

 *Submitted for verification at Etherscan.io on 2019-03-22

*/



pragma solidity ^0.5.0;



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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

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

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string memory) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string memory) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}





/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

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

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

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

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * Emits an Approval event (reflecting the reduced allowance).

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

        _burn(account, value);

        emit Approval(account, msg.sender, _allowed[account][msg.sender]);

    }

}





contract MYL is ERC20, ERC20Detailed {



    /* Address of the MARKETING account, allowed to mint coins */

    address public accMarketing = 0x7853A60bbc563F079F17e59Ab223146A42060858;

    /* Address of the OPERATIONAL account, allowed to mint coins */

    address public accOperational = 0x4da7279AFbb18750D5DC707095aE3325Aa03d56c;

    /* Address of the TRANSFER account, allowed to mint coins */

    address public accTransfer = 0x35065a71ff561f1275D0E8C971fa42A1F0054F49;



    uint public timestamp_last_marketing_mint = block.timestamp;

    uint public timestamp_last_operational_mint = block.timestamp;



    constructor()

        ERC20()

        ERC20Detailed("MYRILLION", "MYL", 4)

        public {

            /* Initial token allocation */

            

            // Marketing: 300 000 000 MYL

            _mint(accMarketing, 3000000000000);

            // Operational: 500 000 000 MYL

            _mint(accOperational, 5000000000000);

            // Team & Advisor: 500 000 000 MYL

            _mint(0xaf1D0E25908FB3616b1938e57cAC86A95857beBf, 5000000000000);



            // ICO's accounts

            _mint(0x3c6D321b5FA40038C0fC90a3a1Ef35BEFCAAdF4B, 1400000000);

            _mint(0x38eFcA7EbFedD1043573E46bFf86706DbAda330D, 14000000000);

            _mint(0x3F43cCf9Ae4594436BC498655075b8f83B98A8C2, 15000000000);

            _mint(0xD9Df8D29Df90F1852c8f8eE704ECA568fEd33545, 15000000000);

            _mint(0x88EFed88f4040A2F034F08bE8ac988f9D4DB93De, 14000000000);

            _mint(0xf51aF4d3445f9600476F7e79d2e0B351860C8575, 129063185);

            _mint(0x8dC482998a684F8aC9B64ec4e1FA469684169daE, 1600000000);

            _mint(0xcF1ab02060C4D497f2966a3a928a9AfBc35aa907, 16000000000);

        }



    /* PUBLIC ENTRY POINTS */



    /* mint a certain amount of tokens */

    function mint(uint256 value) public returns (bool) {

        // Validate msg.sender

        require(

            (msg.sender == accMarketing && marketingCanMint(value)) 

            ||

            (msg.sender == accOperational && operationalCanMint(value))

            ||

            msg.sender == accTransfer

        );



        // Update timestamp of last mint, if applicable

        if (msg.sender == accMarketing) {

            timestamp_last_marketing_mint = block.timestamp;

        } else if (msg.sender == accOperational) {

            timestamp_last_operational_mint = block.timestamp;

        }



        // Issue tokens to msg.sender

        _mint(msg.sender, value);



        return true;

    }



    /* Allow the current MARKETING account to change its address */

    function changeMarketingAccount(address _newAccount) public returns (bool) {

        require(msg.sender == accMarketing, "Invalid msg.sender");

        accMarketing = _newAccount;

        return true;

    }



    /* Allow the current OPERATIONAL account to change its address */

    function changeOperationalAccount(address _newAccount) public returns (bool) {

        require(msg.sender == accOperational, "Invalid msg.sender");

        accOperational = _newAccount;

        return true;

    }



    /* Allow the current TRANSFER account to change its address */

    function changeTransferAccount(address _newAccount) public returns (bool) {

        require(msg.sender == accTransfer, "Invalid msg.sender");

        accTransfer = _newAccount;

        return true;

    }



    /* PRIVATE FUNCTIONS */



    function marketingCanMint(uint value) internal view returns (bool) {

        // Marketing can mint if balance (after mint) is <= 0.75% of totalSupply (after mint)

        uint threshold = totalSupply().add(value).mul(75).div(10000);

        if (balanceOf(accMarketing).add(value) > threshold) return false;

        // Marketing can mint if last mint was issued more than 6 months ago

        if (block.timestamp < timestamp_last_marketing_mint + 24 weeks) return false;

        return true;

    }



    function operationalCanMint(uint value) internal view returns (bool) {

        // Operational can mint if balance (after mint) is <= 1.25% of totalSupply (after mint)

        uint threshold = totalSupply().add(value).mul(125).div(10000);

        if (balanceOf(accOperational).add(value) > threshold) return false;

        // Operational can mint if last mint was issued more than 6 months ago

        if (block.timestamp < timestamp_last_operational_mint + 24 weeks) return false;

        return true;

    }

}