/**

 *Submitted for verification at Etherscan.io on 2019-04-12

*/



pragma solidity ^0.5.1;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {

    /**

    * @dev Multiplies two numbers, reverts on overflow.

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

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */

library Roles {

    struct Role {

        mapping (address => bool) bearer;

    }



    /**

     * @dev give an account access to this role

     */

    function add(Role storage role, address account) internal {

        require(account != address(0));

        require(!has(role, account));



        role.bearer[account] = true;

    }



    /**

     * @dev remove an account's access to this role

     */

    function remove(Role storage role, address account) internal {

        require(account != address(0));

        require(has(role, account));



        role.bearer[account] = false;

    }



    /**

     * @dev check if an account has this role

     * @return bool

     */

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));

        return role.bearer[account];

    }

}



contract AdminRole {

    using Roles for Roles.Role;



    event AdminAdded(address indexed account);

    event AdminRemoved(address indexed account);



    Roles.Role private _admins;



    constructor () internal {

        _addAdmin(msg.sender);

    }



    modifier onlyAdmin() {

        require(isAdmin(msg.sender));

        _;

    }



    function isAdmin(address account) public view returns (bool) {

        return _admins.has(account);

    }



    function addAdmin(address account) public onlyAdmin {

        _addAdmin(account);

    }



    function renounceAdmin() public {

        _removeAdmin(msg.sender);

    }



    function _addAdmin(address account) internal {

        _admins.add(account);

        emit AdminAdded(account);

    }



    function _removeAdmin(address account) internal {

        _admins.remove(account);

        emit AdminRemoved(account);

    }

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

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



/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is ERC20 {

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



contract ERC20Traceable is ERC20Detailed {

    address[] internal holdersSet;

    mapping(address => uint256) internal holdersIndices;



    function _traceRecipient(address to) internal {

        if(holdersIndices[to] == 0) {

            holdersSet.push(to);

            holdersIndices[to] = holdersSet.length;

        }

    }



    function _traceSender(address from, uint256 value) internal {

        if(balanceOf(from) == value) {

            if(holdersIndices[from] != 0) {

                uint256 senderIndex = holdersIndices[from];

                if(senderIndex < holdersSet.length) {

                    address lastHolder = holdersSet[holdersSet.length - 1];

                    uint256 lastHolderIndex = holdersIndices[lastHolder];

                    holdersSet[senderIndex - 1] = holdersSet[lastHolderIndex - 1];

                }

                delete holdersSet[holdersSet.length - 1];

                holdersSet.length = holdersSet.length - 1;

                holdersIndices[from] = 0;

            }



        }

    }



    function _trace(address from, address to, uint256 value) internal {

        _traceRecipient(to);

        if(from != address(0) && from != to) {

            _traceSender(from, value);

        }

    }



    function _mint(address account, uint256 value) internal {

        _traceRecipient(account);

        super._mint(account, value);

    }



    function _burn(address account, uint256 value) internal {

        _traceSender(account, value);

        super._burn(account, value);

    }



    function _burnFrom(address account, uint256 value) internal {

        _traceSender(account, value);

        super._burn(account, value);

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _trace(from, to, value);

        return super.transferFrom(from, to, value);

    }



    function transfer(address to, uint256 value) public returns (bool) {

        _trace(msg.sender, to, value);

        return super.transfer(to, value);

    }



    function getHolders() public view returns (address[] memory) {

        return holdersSet;

    }

}



/**

 * @title Whitelist ERC20 token

 *

 * @dev Whitelisted-only token holders.

 */

contract WhitelistToken is ERC20Traceable, AdminRole {

    mapping(address => bool) public whitelisted;



    function _mint(address account, uint256 value) internal {

        require(whitelisted[account]);

        super._mint(account, value);

    }



    function _burn(address account, uint256 value) internal {

        require(whitelisted[account]);

        super._burn(account, value);

    }



    function _burnFrom(address account, uint256 value) internal {

        require(whitelisted[account]);

        super._burn(account, value);

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        require(whitelisted[to]);

        return super.transferFrom(from, to, value);

    }



    function transfer(address to, uint256 value) public returns (bool) {

        require(whitelisted[to]);

        return super.transfer(to, value);

    }



    function setWhitelisted(address _address, bool _whitelisted) public onlyAdmin {

        whitelisted[_address] = _whitelisted;

    }

}



/**

 * @title Blacklist ERC20 token

 *

 * @dev Any address can be a token holder, unless blacklisted.

 */

contract BlacklistToken is ERC20Traceable, AdminRole {

    mapping(address => bool) public blacklisted;



    function _mint(address account, uint256 value) internal {

        require(!blacklisted[account]);

        super._mint(account, value);

    }



    function _burn(address account, uint256 value) internal {

        require(!blacklisted[account]);

        super._burn(account, value);

    }



    function _burnFrom(address account, uint256 value) internal {

        require(!blacklisted[account]);

        super._burn(account, value);

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        require(!blacklisted[to]);

        return super.transferFrom(from, to, value);

    }



    function transfer(address to, uint256 value) public returns (bool) {

        require(!blacklisted[to]);

        return super.transfer(to, value);

    }



    function setBlacklisted(address _address, bool _blacklisted) public onlyAdmin {

        blacklisted[_address] = _blacklisted;

    }

}





contract DicToken is WhitelistToken {

    /// initial supply 35 million DIC

    uint256 public INITIAL_SUPPLY;



    address public saleTokensAddress;

    address public marketingTokensAddress;

    address public managementTokensAddress;

    address public affiliateTokensAddress;

    address public foundersTokensAddress;



    bool public tradingEnabled;



    constructor(address _saleTokensAddress,

                address _marketingTokensAddress, address _managementTokensAddress, address _affiliateTokensAddress, address _foundersTokensAddress)

                public ERC20Detailed("DIC Token", "DIC", 18) {

        require(_saleTokensAddress != address(0));

        require(_marketingTokensAddress != address(0));

        require(_managementTokensAddress != address(0));

        require(_affiliateTokensAddress != address(0));

        require(_foundersTokensAddress != address(0));



        INITIAL_SUPPLY = 35000000 * 10**uint256(decimals());



        saleTokensAddress = _saleTokensAddress;

        marketingTokensAddress = _marketingTokensAddress;

        managementTokensAddress = _managementTokensAddress;

        affiliateTokensAddress = _affiliateTokensAddress;

        foundersTokensAddress = _foundersTokensAddress;



        setWhitelisted(saleTokensAddress, true);

        setWhitelisted(marketingTokensAddress, true);

        setWhitelisted(managementTokensAddress, true);

        setWhitelisted(affiliateTokensAddress, true);

        setWhitelisted(foundersTokensAddress, true);



        /*

        Token Distribution	            %	    DIC Tokens

        Pre PTO Pre-Sale	            31%	    10,850,000

        Private Token Offering	        52%	    18,200,000

        Marketing & Bounty Programme	1%	    350,000

        Advisors & Partners	            0%	    0

        Management	                    5%	    1,750,000

        Affiliate Programme	            1%	    350,000

        Airdrop Programme	            0%	    0

        Founders / Shareholders	        10%	    3,500,000

        Total	                        100%	35,000,000

        */



        _mint(saleTokensAddress, 10850000 * (10 ** uint256(decimals()))); // Pre PTO Pre-Sale - 10,850,000 DIC

        _mint(saleTokensAddress, 18200000 * (10 ** uint256(decimals()))); // Private Token Offering - 18,200,000 DIC

        _mint(marketingTokensAddress, 350000 * (10 ** uint256(decimals()))); // Marketing & Bounty Programme - 350,000 DIC

        _mint(managementTokensAddress, 1750000 * (10 ** uint256(decimals()))); // Management - 1,750,000 DIC

        _mint(affiliateTokensAddress, 350000 * (10 ** uint256(decimals()))); // Affiliate Programme - 350,000 DIC

        _mint(foundersTokensAddress, 3500000 * (10 ** uint256(decimals()))); // Founders / Shareholders - 3,500,000 DIC



        require(totalSupply() == INITIAL_SUPPLY);

    }



    function setTradingEnabled(bool _enabled) external onlyAdmin {

        tradingEnabled = _enabled;

    }



    function distribute(address to, uint256 value) external returns (bool) {

        require(msg.sender == saleTokensAddress || msg.sender == marketingTokensAddress);

        setWhitelisted(to, true);

        return super.transfer(to, value);

    }



    function transfer(address to, uint256 value) public returns (bool) {

        if(!tradingEnabled && !isAdmin(msg.sender)) return false;

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        if(!tradingEnabled) return false;

        return super.transferFrom(from, to, value);

    }



    function transferBatch(address[] calldata _recipients, uint256[] calldata _amounts) external {

        require(_recipients.length > 0);

        require(_recipients.length == _amounts.length);



        for(uint8 i = 0; i < _recipients.length; i++) {

            require(transfer(_recipients[i], _amounts[i]));

        }

    }



    function mint(address account, uint256 amount) external onlyAdmin {

        super._mint(account, amount);

    }



    function burn(address account, uint256 amount) public {

        super._burn(account, amount);

    }



    /// @dev Admin-only function to recover any tokens mistakenly sent to this contract

    function recoverERC20Tokens(address _contractAddress) onlyAdmin external {

        IERC20 erc20Token = IERC20(_contractAddress);

        if(erc20Token.balanceOf(address(this)) > 0) {

            require(erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this))));

        }

    }

}