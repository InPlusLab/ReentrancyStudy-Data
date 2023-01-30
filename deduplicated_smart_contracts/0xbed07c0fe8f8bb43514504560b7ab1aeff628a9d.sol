/**

 *Submitted for verification at Etherscan.io on 2019-06-24

*/



// File: openzeppelin-solidity\contracts\math\SafeMath.sol



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



// File: contracts\TaxLib.sol



/**

 * This smart contract code is Copyright 2018 WiBX. For more information see https://wibx.io

 *

 * Licensed under the Apache License, version 2.0: https://github.com/wibxcoin/Contracts/LICENSE.txt

 */



pragma solidity 0.5.0;





/**

 * @title Taxation Library

 *

 * @dev Helpers for taxation

 */

library TaxLib

{

    using SafeMath for uint256;



    /**

     * Modifiable tax container

     */

    struct DynamicTax

    {

        /**

         * Tax amount per each transaction (in %).

         */

        uint256 amount;



        /**

         * The shift value.

         * Represents: 100 * 10 ** shift

         */

        uint256 shift;

    }



    /**

     * @dev Apply percentage to the value.

     *

     * @param taxAmount The amount of tax

     * @param shift The shift division amount

     * @param value The total amount

     * @return The tax amount to be payed (in WEI)

     */

    function applyTax(uint256 taxAmount, uint256 shift, uint256 value) internal pure returns (uint256)

    {

        uint256 temp = value.mul(taxAmount);



        return temp.div(shift);

    }



    /**

     * @dev Normalize the shift value

     *

     * @param shift The power chosen

     */

    function normalizeShiftAmount(uint256 shift) internal pure returns (uint256)

    {

        require(shift >= 0 && shift <= 2, "You can't set more than 2 decimal places");



        uint256 value = 100;



        return value.mul(10 ** shift);

    }

}



// File: contracts\VestingLib.sol



/**

 * This smart contract code is Copyright 2019 WiBX. For more information see https://wibx.io

 *

 * Licensed under the Apache License, version 2.0: https://github.com/wibxcoin/Contracts/LICENSE.txt

 */



pragma solidity 0.5.0;







/**

 * @title Vesting Library

 *

 * @dev Helpers for vesting

 */

library VestingLib

{

    using SafeMath for uint256;



    /**

     * Period to get tokens (bimester).

     */

    uint256 private constant _timeShiftPeriod = 60 days;



    struct TeamMember

    {

        /**

         * User's next token withdrawal

         */

        uint256 nextWithdrawal;



        /**

         * Remaining tokens to be released

         */

        uint256 totalRemainingAmount;



        /**

         * GAS Optimization.

         * Calculates the transfer value for the first time (20%)

         */

        uint256 firstTransferValue;



        /**

         * GAS Optimization.

         * Calculates the transfer value for each month (10%)

         */

        uint256 eachTransferValue;



        /**

         * Check if this member is active

         */

        bool active;

    }



    /**

     * @dev Calculate the member earnings according to the rules of the board.

     *

     * @param tokenAmount The total user token amount

     * @return The first transfer amount and the other months amount.

     */

    function _calculateMemberEarnings(uint256 tokenAmount) internal pure returns (uint256, uint256)

    {

        // 20% on the first transfer (act)

        uint256 firstTransfer = TaxLib.applyTax(20, 100, tokenAmount);



        // 10% for the other months

        uint256 eachMonthTransfer = TaxLib.applyTax(10, 100, tokenAmount.sub(firstTransfer));



        return (firstTransfer, eachMonthTransfer);

    }



    /**

     * @dev Updates the date to the next user's withdrawal.

     *

     * @param oldWithdrawal The last user's withdrawal

     */

    function _updateNextWithdrawalTime(uint256 oldWithdrawal) internal view returns (uint256)

    {

        uint currentTimestamp = block.timestamp;



        require(oldWithdrawal <= currentTimestamp, "You need to wait the next withdrawal period");



        /**

         * If is the user's first withdrawal, get the time of the first transfer

         * and adds plus the time shift period.

         */

        if (oldWithdrawal == 0)

        {

            return _timeShiftPeriod.add(currentTimestamp);

        }



        /**

         * Otherwise adds the time shift period to the previous withdrawal date to avoid

         * unnecessary waitings.

         */

        return oldWithdrawal.add(_timeShiftPeriod);

    }



    /**

     * @dev Calculates the amount to pay taking into account the first transfer rule.

     *

     * @param member The team member container

     * @return The amount for pay

     */

    function _checkAmountForPay(TeamMember memory member) internal pure returns (uint256)

    {

        /**

         * First user transference. It should be 20%.

         */

        if (member.nextWithdrawal == 0)

        {

            return member.firstTransferValue;

        }



        /**

         * Check for avoid rounding errors.

         */

        return member.eachTransferValue >= member.totalRemainingAmount

            ? member.totalRemainingAmount

            : member.eachTransferValue;

    }

}



// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\IERC20.sol



pragma solidity ^0.5.0;



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



// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20.sol



pragma solidity ^0.5.0;







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



// File: node_modules\openzeppelin-solidity\contracts\access\Roles.sol



pragma solidity ^0.5.0;



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



// File: node_modules\openzeppelin-solidity\contracts\access\roles\PauserRole.sol



pragma solidity ^0.5.0;





contract PauserRole {

    using Roles for Roles.Role;



    event PauserAdded(address indexed account);

    event PauserRemoved(address indexed account);



    Roles.Role private _pausers;



    constructor () internal {

        _addPauser(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender));

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);

    }



    function addPauser(address account) public onlyPauser {

        _addPauser(account);

    }



    function renouncePauser() public {

        _removePauser(msg.sender);

    }



    function _addPauser(address account) internal {

        _pausers.add(account);

        emit PauserAdded(account);

    }



    function _removePauser(address account) internal {

        _pausers.remove(account);

        emit PauserRemoved(account);

    }

}



// File: node_modules\openzeppelin-solidity\contracts\lifecycle\Pausable.sol



pragma solidity ^0.5.0;





/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

    event Paused(address account);

    event Unpaused(address account);



    bool private _paused;



    constructor () internal {

        _paused = false;

    }



    /**

     * @return true if the contract is paused, false otherwise.

     */

    function paused() public view returns (bool) {

        return _paused;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!_paused);

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(_paused);

        _;

    }



    /**

     * @dev called by the owner to pause, triggers stopped state

     */

    function pause() public onlyPauser whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() public onlyPauser whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}



// File: openzeppelin-solidity\contracts\token\ERC20\ERC20Pausable.sol



pragma solidity ^0.5.0;







/**

 * @title Pausable token

 * @dev ERC20 modified with pausable transfers.

 **/

contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);

    }



    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);

    }



    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);

    }



    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {

        return super.increaseAllowance(spender, addedValue);

    }



    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {

        return super.decreaseAllowance(spender, subtractedValue);

    }

}



// File: openzeppelin-solidity\contracts\token\ERC20\ERC20Detailed.sol



pragma solidity ^0.5.0;





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



// File: openzeppelin-solidity\contracts\token\ERC20\ERC20Burnable.sol



pragma solidity ^0.5.0;





/**

 * @title Burnable Token

 * @dev Token that can be irreversibly burned (destroyed).

 */

contract ERC20Burnable is ERC20 {

    /**

     * @dev Burns a specific amount of tokens.

     * @param value The amount of token to be burned.

     */

    function burn(uint256 value) public {

        _burn(msg.sender, value);

    }



    /**

     * @dev Burns a specific amount of tokens from the target address and decrements allowance

     * @param from address The address which you want to send tokens from

     * @param value uint256 The amount of token to be burned

     */

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);

    }

}



// File: openzeppelin-solidity\contracts\ownership\Ownable.sol



pragma solidity ^0.5.0;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * @notice Renouncing to ownership will leave the contract without an owner.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



// File: contracts\Taxable.sol



/**

 * This smart contract code is Copyright 2018 WiBX. For more information see https://wibx.io

 *

 * Licensed under the Apache License, version 2.0: https://github.com/wibxcoin/Contracts/LICENSE.txt

 */



pragma solidity 0.5.0;







/**

 * @title Taxable token

 *

 * @dev Manages dynamic taxes

 */

contract Taxable is Ownable

{

    /**

     * Tax recipient.

     */

    address internal _taxRecipientAddr;



    /**

     * Modifiable tax container.

     */

    TaxLib.DynamicTax private _taxContainer;



    constructor(address taxRecipientAddr) public

    {

        _taxRecipientAddr = taxRecipientAddr;



        /**

         * Tax: Starting at 0.9%

         */

        changeTax(9, 1);

    }



    /**

     * Returns the tax recipient account

     */

    function taxRecipientAddr() public view returns (address)

    {

        return _taxRecipientAddr;

    }



    /**

     * @dev Get the current tax amount.

     */

    function currentTaxAmount() public view returns (uint256)

    {

        return _taxContainer.amount;

    }



    /**

     * @dev Get the current tax shift.

     */

    function currentTaxShift() public view returns (uint256)

    {

        return _taxContainer.shift;

    }



    /**

     * @dev Change the dynamic tax.

     *

     * Just the contract admin can change the taxes.

     * The possible tax range is 0% ~ 3% and cannot exceed it.

     *

     * Reference table:

     * 3, 0 (3 / 100)   = 3%

     * 3, 1 (3 / 1000)  = 0.3%

     * 3, 2 (3 / 10000) = 0.03%

     *

     * @param amount The new tax amount chosen

     */

    function changeTax(uint256 amount, uint256 shift) public onlyOwner

    {

        if (shift == 0)

        {

            require(amount <= 3, "You can't set a tax greater than 3%");

        }



        _taxContainer = TaxLib.DynamicTax(

            amount,



            // The maximum decimal places value is checked here

            TaxLib.normalizeShiftAmount(shift)

        );

    }



    /**

     * @dev Apply the tax based on the dynamic tax container

     *

     * @param value The value of transaction

     */

    function _applyTax(uint256 value) internal view returns (uint256)

    {

        return TaxLib.applyTax(

            _taxContainer.amount,

            _taxContainer.shift,

            value

        );

    }

}



// File: contracts\BCHHandled.sol



/**

 * This smart contract code is Copyright 2018 WiBX. For more information see https://wibx.io

 *

 * Licensed under the Apache License, version 2.0: https://github.com/wibxcoin/Contracts/LICENSE.txt

 */



pragma solidity 0.5.0;



/**

 * @title BCH Handled tokens contract

 *

 * @dev Addresses owned by BCH

 */

contract BCHHandled

{

    /**

     * The BCH module address.

     */

    address private _bchAddress;



    /**

     * Accounts managed by BCH.

     */

    mapping (address => bool) private _bchAllowed;



    /**

     * BCH Approval event

     */

    event BchApproval(address indexed to, bool state);



    constructor(address bchAddress) public

    {

        _bchAddress = bchAddress;

    }



    /**

     * @dev Check if the address is handled by BCH.

     *

     * @param wallet The address to check

     */

    function isBchHandled(address wallet) public view returns (bool)

    {

        return _bchAllowed[wallet];

    }



    /**

     * @dev Authorize the full control of BCH.

     */

    function bchAuthorize() public returns (bool)

    {

        return _changeState(true);

    }



    /**

     * @dev Revoke the BCH access.

     */

    function bchRevoke() public returns (bool)

    {

        return _changeState(false);

    }



    /**

     * @dev Check if the transaction can be handled by BCH and its authenticity.

     *

     * @param from The spender address

     */

    function canBchHandle(address from) internal view returns (bool)

    {

        return isBchHandled(from) && msg.sender == _bchAddress;

    }



    /**

     * @dev Change the BCH ownership state

     *

     * @param state The new state

     */

    function _changeState(bool state) private returns (bool)

    {

        emit BchApproval(msg.sender, _bchAllowed[msg.sender] = state);



        return true;

    }

}



// File: contracts\WibxToken.sol



/**

 * This smart contract code is Copyright 2018 WiBX. For more information see https://wibx.io

 *

 * Licensed under the Apache License, version 2.0: https://github.com/wibxcoin/Contracts/LICENSE.txt

 */



pragma solidity 0.5.0;

















/**

 * @title WiBX Utility Token

 *

 * @dev Implementation of the main WiBX token smart contract.

 */

contract WibxToken is ERC20Pausable, ERC20Burnable, ERC20Detailed, Taxable, BCHHandled

{

    /**

     * 12 billion tokens raised by 18 decimal places.

     */

    uint256 public constant INITIAL_SUPPLY = 12000000000 * (10 ** 18);



    constructor(address bchAddress, address taxRecipientAddr) public ERC20Detailed("WiBX Utility Token", "WBX", 18)

                                                                     BCHHandled(bchAddress)

                                                                     Taxable(taxRecipientAddr)

    {

        _mint(msg.sender, INITIAL_SUPPLY);

    }



    /**

     * @dev Overrides the OpenZeppelin default transfer

     *

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     * @return If the operation was successful

     */

    function transfer(address to, uint256 value) public returns (bool)

    {

        return _fullTransfer(msg.sender, to, value);

    }



    /**

     * @dev Special WBX transfer tokens from one address to another checking the access for BCH

     *

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     * @return If the operation was successful

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool)

    {

        if (canBchHandle(from))

        {

            return _fullTransfer(from, to, value);

        }



        /*

         * Exempting the tax account to avoid an infinite loop in transferring values from this wallet.

         */

        if (from == taxRecipientAddr() || to == taxRecipientAddr())

        {

            super.transferFrom(from, to, value);



            return true;

        }



        uint256 taxValue = _applyTax(value);



        // Transfer the tax to the recipient

        super.transferFrom(from, taxRecipientAddr(), taxValue);



        // Transfer user's tokens

        super.transferFrom(from, to, value);



        return true;

    }



    /**

     * @dev Batch token transfer (maxium 100 transfers)

     *

     * @param recipients The recipients for transfer to

     * @param values The values

     * @param from Spender address

     * @return If the operation was successful

     */

    function sendBatch(address[] memory recipients, uint256[] memory values, address from) public returns (bool)

    {

        /*

         * The maximum batch send should be 100 transactions.

         * Each transaction we recommend 65000 of GAS limit and the maximum block size is 6700000.

         * 6700000 / 65000 = ~103.0769 �� 100 transacitons (safe rounded).

         */

        uint maxTransactionCount = 100;

        uint transactionCount = recipients.length;



        require(transactionCount <= maxTransactionCount, "Max transaction count violated");

        require(transactionCount == values.length, "Wrong data");



        if (msg.sender == from)

        {

            return _sendBatchSelf(recipients, values, transactionCount);

        }



        return _sendBatchFrom(recipients, values, from, transactionCount);

    }



    /**

     * @dev Batch token transfer from MSG sender

     *

     * @param recipients The recipients for transfer to

     * @param values The values

     * @param transactionCount Total transaction count

     * @return If the operation was successful

     */

    function _sendBatchSelf(address[] memory recipients, uint256[] memory values, uint transactionCount) private returns (bool)

    {

        for (uint i = 0; i < transactionCount; i++)

        {

            _fullTransfer(msg.sender, recipients[i], values[i]);

        }



        return true;

    }



    /**

     * @dev Batch token transfer from other sender

     *

     * @param recipients The recipients for transfer to

     * @param values The values

     * @param from Spender address

     * @param transactionCount Total transaction count

     * @return If the operation was successful

     */

    function _sendBatchFrom(address[] memory recipients, uint256[] memory values, address from, uint transactionCount) private returns (bool)

    {

        for (uint i = 0; i < transactionCount; i++)

        {

            transferFrom(from, recipients[i], values[i]);

        }



        return true;

    }



    /**

     * @dev Special WBX transfer token for a specified address.

     *

     * @param from The address of the spender

     * @param to The address to transfer to.

     * @param value The amount to be transferred.

     * @return If the operation was successful

     */

    function _fullTransfer(address from, address to, uint256 value) private returns (bool)

    {

        /*

         * Exempting the tax account to avoid an infinite loop in transferring values from this wallet.

         */

        if (from == taxRecipientAddr() || to == taxRecipientAddr())

        {

            _transfer(from, to, value);



            return true;

        }



        uint256 taxValue = _applyTax(value);



        // Transfer the tax to the recipient

        _transfer(from, taxRecipientAddr(), taxValue);



        // Transfer user's tokens

        _transfer(from, to, value);



        return true;

    }

}



// File: contracts\WibxTokenVesting.sol



/**

 * This smart contract code is Copyright 2019 WiBX. For more information see https://wibx.io

 *

 * Licensed under the Apache License, version 2.0: https://github.com/wibxcoin/Contracts/LICENSE.txt

 */



pragma solidity 0.5.0;











/**

 * @title WiBX Token Vesting

 *

 * @dev Implementation of the team token vesting

 */

contract WibxTokenVesting is Ownable

{

    using SafeMath for uint256;



    /**

     * Wibx Token Instance

     */

    WibxToken private _wibxToken;



    /**

     * All team members

     */

    mapping (address => VestingLib.TeamMember) private _members;



    /**

     * Total Wibx tokens allocated in this vesting contract

     */

    uint256 private _alocatedWibxVestingTokens = 0;



    constructor(address wibxTokenAddress) public

    {

        _wibxToken = WibxToken(wibxTokenAddress);

    }



    /**

     * @dev Add a new team member to withdrawal tokens.

     *

     * @param wallet The member wallet address

     * @param tokenAmount The token amount desired by the team member

     * @return If the transaction was successful

     */

    function addTeamMember(address wallet, uint256 tokenAmount) public onlyOwner returns (bool)

    {

        require(!_members[wallet].active, "Member already added");



        uint256 firstTransfer;

        uint256 eachMonthTransfer;



        _alocatedWibxVestingTokens = _alocatedWibxVestingTokens.add(tokenAmount);

        (firstTransfer, eachMonthTransfer) = VestingLib._calculateMemberEarnings(tokenAmount);



        _members[wallet] = VestingLib.TeamMember({

            totalRemainingAmount: tokenAmount,

            firstTransferValue: firstTransfer,

            eachTransferValue: eachMonthTransfer,

            nextWithdrawal: 0,

            active: true

        });



        return _members[wallet].active;

    }



    /**

     * @dev Withdrawal team tokens to the selected wallet

     *

     * @param wallet The team member wallet

     * @return If the transaction was successful

     */

    function withdrawal(address wallet) public returns (bool)

    {

        VestingLib.TeamMember storage member = _members[wallet];



        require(member.active, "The team member is not found");

        require(member.totalRemainingAmount > 0, "There is no more tokens to transfer to this wallet");



        uint256 amountToTransfer = VestingLib._checkAmountForPay(member);

        require(totalWibxVestingSupply() >= amountToTransfer, "The contract doesnt have founds to pay");



        uint256 nextWithdrawalTime = VestingLib._updateNextWithdrawalTime(member.nextWithdrawal);



        _wibxToken.transfer(wallet, amountToTransfer);



        member.nextWithdrawal = nextWithdrawalTime;

        member.totalRemainingAmount = member.totalRemainingAmount.sub(amountToTransfer);

        _alocatedWibxVestingTokens = _alocatedWibxVestingTokens.sub(amountToTransfer);



        return true;

    }



    /**

     * @dev Clean everything and terminate this token vesting

     */

    function terminateTokenVesting() public onlyOwner

    {

        require(_alocatedWibxVestingTokens == 0, "All withdrawals have yet to take place");



        if (totalWibxVestingSupply() > 0)

        {

            _wibxToken.transfer(_wibxToken.taxRecipientAddr(), totalWibxVestingSupply());

        }



        /**

         * Due to the Owner's Ownable (from OpenZeppelin) is not flagged as payable,

         * we need to cast it here.

         */

        selfdestruct(address(uint160(owner())));

    }



    /**

     * @dev Get the token supply in this contract to be delivered to team members.

     */

    function totalWibxVestingSupply() public view returns (uint256)

    {

        return _wibxToken.balanceOf(address(this));

    }



    /**

     * @dev Returns all tokens allocated to users.

     */

    function totalAlocatedWibxVestingTokens() public view returns (uint256)

    {

        return _alocatedWibxVestingTokens;

    }



    /**

     * @dev Get the remaining token for some member.

     *

     * @param wallet The member's wallet address.

     */

    function remainingTokenAmount(address wallet) public view returns (uint256)

    {

        return _members[wallet].totalRemainingAmount;

    }



    /**

     * @dev Get the next withdrawal day of the user.

     *

     * @param wallet The member's wallet address.

     */

    function nextWithdrawalTime(address wallet) public view returns (uint256)

    {

        return _members[wallet].nextWithdrawal;

    }

}