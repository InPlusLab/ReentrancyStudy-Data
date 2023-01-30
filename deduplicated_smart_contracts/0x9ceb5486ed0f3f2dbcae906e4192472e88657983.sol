/**
 *Submitted for verification at Etherscan.io on 2020-07-24
*/

pragma solidity 0.5.2;


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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must equal true).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.

        require(address(token).isContract());

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2¦Ð.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

/*
    Copyright 2017-2019 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/// @title Math function library with overflow protection inspired by Open Zeppelin
library MathLib {
    int256 constant INT256_MIN = int256((uint256(1) << 255));
    int256 constant INT256_MAX = int256(~((uint256(1) << 255)));

    function multiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MathLib: multiplication overflow");

        return c;
    }

    function divideFractional(
        uint256 a,
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (uint256) {
        return multiply(a, numerator) / denominator;
    }

    function subtract(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "MathLib: subtraction overflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "MathLib: addition overflow");
        return c;
    }

    /// @notice determines the amount of needed collateral for a given position (qty and price)
    /// @param priceFloor lowest price the contract is allowed to trade before expiration
    /// @param priceCap highest price the contract is allowed to trade before expiration
    /// @param qtyMultiplier multiplier for qty from base units
    /// @param longQty qty to redeem
    /// @param shortQty qty to redeem
    /// @param price of the trade
    function calculateCollateralToReturn(
        uint256 priceFloor,
        uint256 priceCap,
        uint256 qtyMultiplier,
        uint256 longQty,
        uint256 shortQty,
        uint256 price
    ) internal pure returns (uint256) {
        uint256 neededCollateral = 0;
        uint256 maxLoss;
        if (longQty > 0) {
            // calculate max loss from entry price to floor
            if (price <= priceFloor) {
                maxLoss = 0;
            } else {
                maxLoss = subtract(price, priceFloor);
            }
            neededCollateral = multiply(multiply(maxLoss, longQty), qtyMultiplier);
        }

        if (shortQty > 0) {
            // calculate max loss from entry price to ceiling;
            if (price >= priceCap) {
                maxLoss = 0;
            } else {
                maxLoss = subtract(priceCap, price);
            }
            neededCollateral = add(
                neededCollateral,
                multiply(multiply(maxLoss, shortQty), qtyMultiplier)
            );
        }
        return neededCollateral;
    }

    /// @notice determines the amount of needed collateral for minting a long and short position token
    function calculateTotalCollateral(
        uint256 priceFloor,
        uint256 priceCap,
        uint256 qtyMultiplier
    ) internal pure returns (uint256) {
        return multiply(subtract(priceCap, priceFloor), qtyMultiplier);
    }

    /// @notice calculates the fee in terms of base units of the collateral token per unit pair minted.
    function calculateFeePerUnit(
        uint256 priceFloor,
        uint256 priceCap,
        uint256 qtyMultiplier,
        uint256 feeInBasisPoints
    ) internal pure returns (uint256) {
        uint256 midPrice = add(priceCap, priceFloor) / 2;
        return multiply(multiply(midPrice, qtyMultiplier), feeInBasisPoints) / 10000;
    }
}

library StringLib {
    /// @notice converts bytes32 into a string.
    /// @param bytesToConvert bytes32 array to convert
    function bytes32ToString(bytes32 bytesToConvert)
        internal
        pure
        returns (string memory)
    {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = bytesToConvert[i];
        }
        return string(bytesArray);
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
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
     * @return A uint256 representing the amount owned by the passed address.
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
     * @dev Transfer token to a specified address
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
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
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
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

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
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

/*
    Copyright 2017-2019 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/// @title Position Token
/// @notice A token that represents a claim to a collateral pool and a short or long position.
/// The collateral pool acts as the owner of this contract and controls minting and redemption of these
/// tokens based on locked collateral in the pool.
/// NOTE: We eventually can move all of this logic into a library to avoid deploying all of the logic
/// every time a new market contract is deployed.
/// @author Phil Elsasser <phil@marketprotocol.io>
contract PositionToken is ERC20, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;

    MarketSide public MARKET_SIDE; // 0 = Long, 1 = Short
    enum MarketSide { Long, Short }

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 marketSide
    ) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = 0;
        MARKET_SIDE = MarketSide(marketSide);
    }

    /// @dev Called by our MarketContract (owner) to create a long or short position token. These tokens are minted,
    /// and then transferred to our recipient who is the party who is minting these tokens.  The collateral pool
    /// is the only caller (acts as the owner) because collateral must be deposited / locked prior to minting of new
    /// position tokens
    /// @param qtyToMint quantity of position tokens to mint (in base units)
    /// @param recipient the person minting and receiving these position tokens.
    function mintAndSendToken(uint256 qtyToMint, address recipient) external onlyOwner {
        _mint(recipient, qtyToMint);
    }

    /// @dev Called by our MarketContract (owner) when redemption occurs.  This means that either a single user is redeeming
    /// both short and long tokens in order to claim their collateral, or the contract has settled, and only a single
    /// side of the tokens are needed to redeem (handled by the collateral pool)
    /// @param qtyToRedeem quantity of tokens to burn (remove from supply / circulation)
    /// @param redeemer the person redeeming these tokens (who are we taking the balance from)
    function redeemToken(uint256 qtyToRedeem, address redeemer) external onlyOwner {
        _burn(redeemer, qtyToRedeem);
    }
}

/*
    Copyright 2017-2019 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/// @title MarketContract base contract implement all needed functionality for trading.
/// @notice this is the abstract base contract that all contracts should inherit from to
/// implement different oracle solutions.
/// @author Phil Elsasser <phil@marketprotocol.io>
contract MarketContract is Ownable {
    using StringLib for *;

    string public CONTRACT_NAME;
    address public COLLATERAL_TOKEN_ADDRESS;
    address public COLLATERAL_POOL_ADDRESS;
    uint256 public PRICE_CAP;
    uint256 public PRICE_FLOOR;
    uint256 public PRICE_DECIMAL_PLACES; // how to convert the pricing from decimal format (if valid) to integer
    uint256 public QTY_MULTIPLIER; // multiplier corresponding to the value of 1 increment in price to token base units
    uint256 public COLLATERAL_PER_UNIT; // required collateral amount for the full range of outcome tokens
    uint256 public COLLATERAL_TOKEN_FEE_PER_UNIT;
    uint256 public MKT_TOKEN_FEE_PER_UNIT;
    uint256 public EXPIRATION;
    uint256 public SETTLEMENT_DELAY = 1 days;
    address public LONG_POSITION_TOKEN;
    address public SHORT_POSITION_TOKEN;

    // state variables
    uint256 public lastPrice;
    uint256 public settlementPrice;
    uint256 public settlementTimeStamp;
    bool public isSettled = false;

    // events
    event UpdatedLastPrice(uint256 price);
    event ContractSettled(uint256 settlePrice);

    /// @param contractNames bytes32 array of names
    ///     contractName            name of the market contract
    ///     longTokenSymbol         symbol for the long token
    ///     shortTokenSymbol        symbol for the short token
    /// @param baseAddresses array of 2 addresses needed for our contract including:
    ///     ownerAddress                    address of the owner of these contracts.
    ///     collateralTokenAddress          address of the ERC20 token that will be used for collateral and pricing
    ///     collateralPoolAddress           address of our collateral pool contract
    /// @param contractSpecs array of unsigned integers including:
    ///     floorPrice          minimum tradeable price of this contract, contract enters settlement if breached
    ///     capPrice            maximum tradeable price of this contract, contract enters settlement if breached
    ///     priceDecimalPlaces  number of decimal places to convert our queried price from a floating point to
    ///                         an integer
    ///     qtyMultiplier       multiply traded qty by this value from base units of collateral token.
    ///     feeInBasisPoints    fee amount in basis points (Collateral token denominated) for minting.
    ///     mktFeeInBasisPoints fee amount in basis points (MKT denominated) for minting.
    ///     expirationTimeStamp seconds from epoch that this contract expires and enters settlement
    constructor(
        bytes32[3] memory contractNames,
        address[3] memory baseAddresses,
        uint256[7] memory contractSpecs
    ) public {
        PRICE_FLOOR = contractSpecs[0];
        PRICE_CAP = contractSpecs[1];
        require(PRICE_CAP > PRICE_FLOOR, "PRICE_CAP must be greater than PRICE_FLOOR");

        PRICE_DECIMAL_PLACES = contractSpecs[2];
        QTY_MULTIPLIER = contractSpecs[3];
        EXPIRATION = contractSpecs[6];
        require(EXPIRATION > now, "EXPIRATION must be in the future");
        require(QTY_MULTIPLIER != 0, "QTY_MULTIPLIER cannot be 0");

        COLLATERAL_TOKEN_ADDRESS = baseAddresses[1];
        COLLATERAL_POOL_ADDRESS = baseAddresses[2];
        COLLATERAL_PER_UNIT = MathLib.calculateTotalCollateral(
            PRICE_FLOOR,
            PRICE_CAP,
            QTY_MULTIPLIER
        );
        COLLATERAL_TOKEN_FEE_PER_UNIT = MathLib.calculateFeePerUnit(
            PRICE_FLOOR,
            PRICE_CAP,
            QTY_MULTIPLIER,
            contractSpecs[4]
        );
        MKT_TOKEN_FEE_PER_UNIT = MathLib.calculateFeePerUnit(
            PRICE_FLOOR,
            PRICE_CAP,
            QTY_MULTIPLIER,
            contractSpecs[5]
        );

        // create long and short tokens
        CONTRACT_NAME = contractNames[0].bytes32ToString();
        PositionToken longPosToken = new PositionToken(
            "MARKET Protocol Long Position Token",
            contractNames[1].bytes32ToString(),
            uint8(PositionToken.MarketSide.Long)
        );
        PositionToken shortPosToken = new PositionToken(
            "MARKET Protocol Short Position Token",
            contractNames[2].bytes32ToString(),
            uint8(PositionToken.MarketSide.Short)
        );

        LONG_POSITION_TOKEN = address(longPosToken);
        SHORT_POSITION_TOKEN = address(shortPosToken);

        transferOwnership(baseAddresses[0]);
    }

    /*
    // EXTERNAL - onlyCollateralPool METHODS
    */

    /// @notice called only by our collateral pool to create long and short position tokens
    /// @param qtyToMint    qty in base units of how many short and long tokens to mint
    /// @param minter       address of minter to receive tokens
    function mintPositionTokens(uint256 qtyToMint, address minter)
        external
        onlyCollateralPool
    {
        // mint and distribute short and long position tokens to our caller
        PositionToken(LONG_POSITION_TOKEN).mintAndSendToken(qtyToMint, minter);
        PositionToken(SHORT_POSITION_TOKEN).mintAndSendToken(qtyToMint, minter);
    }

    /// @notice called only by our collateral pool to redeem long position tokens
    /// @param qtyToRedeem  qty in base units of how many tokens to redeem
    /// @param redeemer     address of person redeeming tokens
    function redeemLongToken(uint256 qtyToRedeem, address redeemer)
        external
        onlyCollateralPool
    {
        // mint and distribute short and long position tokens to our caller
        PositionToken(LONG_POSITION_TOKEN).redeemToken(qtyToRedeem, redeemer);
    }

    /// @notice called only by our collateral pool to redeem short position tokens
    /// @param qtyToRedeem  qty in base units of how many tokens to redeem
    /// @param redeemer     address of person redeeming tokens
    function redeemShortToken(uint256 qtyToRedeem, address redeemer)
        external
        onlyCollateralPool
    {
        // mint and distribute short and long position tokens to our caller
        PositionToken(SHORT_POSITION_TOKEN).redeemToken(qtyToRedeem, redeemer);
    }

    /*
    // Public METHODS
    */

    /// @notice checks to see if a contract is settled, and that the settlement delay has passed
    function isPostSettlementDelay() public view returns (bool) {
        return isSettled && (now >= (settlementTimeStamp + SETTLEMENT_DELAY));
    }

    /*
    // PRIVATE METHODS
    */

    /// @dev checks our last query price to see if our contract should enter settlement due to it being past our
    //  expiration date or outside of our tradeable ranges.
    function checkSettlement() internal {
        require(!isSettled, "Contract is already settled"); // already settled.

        uint256 newSettlementPrice;
        if (now > EXPIRATION) {
            // note: miners can cheat this by small increments of time (minutes, not hours)
            isSettled = true; // time based expiration has occurred.
            newSettlementPrice = lastPrice;
        } else if (lastPrice >= PRICE_CAP) {
            // price is greater or equal to our cap, settle to CAP price
            isSettled = true;
            newSettlementPrice = PRICE_CAP;
        } else if (lastPrice <= PRICE_FLOOR) {
            // price is lesser or equal to our floor, settle to FLOOR price
            isSettled = true;
            newSettlementPrice = PRICE_FLOOR;
        }

        if (isSettled) {
            settleContract(newSettlementPrice);
        }
    }

    /// @dev records our final settlement price and fires needed events.
    /// @param finalSettlementPrice final query price at time of settlement
    function settleContract(uint256 finalSettlementPrice) internal {
        settlementTimeStamp = now;
        settlementPrice = finalSettlementPrice;
        emit ContractSettled(finalSettlementPrice);
    }

    /// @notice only able to be called directly by our collateral pool which controls the position tokens
    /// for this contract!
    modifier onlyCollateralPool {
        require(
            msg.sender == COLLATERAL_POOL_ADDRESS,
            "Only callable from the collateral pool"
        );
        _;
    }
}

/*
    Copyright 2017-2019 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
contract MarketContractRegistryInterface {
    function addAddressToWhiteList(address contractAddress) external;

    function isAddressWhiteListed(address contractAddress) external view returns (bool);
}

/*
    Copyright 2017-2019 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/// @title MarketCollateralPool
/// @notice This collateral pool houses all of the collateral for all market contracts currently in circulation.
/// This pool facilitates locking of collateral and minting / redemption of position tokens for that collateral.
/// @author Phil Elsasser <phil@marketprotocol.io>
contract MarketCollateralPool is ReentrancyGuard, Ownable {
    using MathLib for uint256;
    using MathLib for int256;
    using SafeERC20 for ERC20;

    address public marketContractRegistry;
    address public mktToken;

    mapping(address => uint256) public contractAddressToCollateralPoolBalance; // current balance of all collateral committed
    mapping(address => uint256) public feesCollectedByTokenAddress;

    event TokensMinted(
        address indexed marketContract,
        address indexed user,
        address indexed feeToken,
        uint256 qtyMinted,
        uint256 collateralLocked,
        uint256 feesPaid
    );

    event TokensRedeemed(
        address indexed marketContract,
        address indexed user,
        uint256 longQtyRedeemed,
        uint256 shortQtyRedeemed,
        uint256 collateralUnlocked
    );

    constructor(address marketContractRegistryAddress, address mktTokenAddress)
        public
        ReentrancyGuard()
    {
        marketContractRegistry = marketContractRegistryAddress;
        mktToken = mktTokenAddress;
    }

    /*
    // EXTERNAL METHODS
    */

    /// @notice Called by a user that would like to mint a new set of long and short token for a specified
    /// market contract.  This will transfer and lock the correct amount of collateral into the pool
    /// and issue them the requested qty of long and short tokens
    /// @param marketContractAddress            address of the market contract to redeem tokens for
    /// @param qtyToMint                      quantity of long / short tokens to mint.
    /// @param isAttemptToPayInMKT            if possible, attempt to pay fee's in MKT rather than collateral tokens
    function mintPositionTokens(
        address marketContractAddress,
        uint256 qtyToMint,
        bool isAttemptToPayInMKT
    ) external onlyWhiteListedAddress(marketContractAddress) nonReentrant {
        MarketContract marketContract = MarketContract(marketContractAddress);
        require(!marketContract.isSettled(), "Contract is already settled");

        address collateralTokenAddress = marketContract.COLLATERAL_TOKEN_ADDRESS();
        uint256 neededCollateral = MathLib.multiply(
            qtyToMint,
            marketContract.COLLATERAL_PER_UNIT()
        );
        // the user has selected to pay fees in MKT and those fees are non zero (allowed) OR
        // the user has selected not to pay fees in MKT, BUT the collateral token fees are disabled (0) AND the
        // MKT fees are enabled (non zero).  (If both are zero, no fee exists)
        bool isPayFeesInMKT = (isAttemptToPayInMKT &&
            marketContract.MKT_TOKEN_FEE_PER_UNIT() != 0) ||
            (!isAttemptToPayInMKT &&
                marketContract.MKT_TOKEN_FEE_PER_UNIT() != 0 &&
                marketContract.COLLATERAL_TOKEN_FEE_PER_UNIT() == 0);

        uint256 feeAmount;
        uint256 totalCollateralTokenTransferAmount;
        address feeToken;
        if (isPayFeesInMKT) {
            // fees are able to be paid in MKT
            feeAmount = MathLib.multiply(
                qtyToMint,
                marketContract.MKT_TOKEN_FEE_PER_UNIT()
            );
            totalCollateralTokenTransferAmount = neededCollateral;
            feeToken = mktToken;

            // EXTERNAL CALL - transferring ERC20 tokens from sender to this contract.  User must have called
            // ERC20.approve in order for this call to succeed.
            ERC20(mktToken).safeTransferFrom(msg.sender, address(this), feeAmount);
        } else {
            // fee are either zero, or being paid in the collateral token
            feeAmount = MathLib.multiply(
                qtyToMint,
                marketContract.COLLATERAL_TOKEN_FEE_PER_UNIT()
            );
            totalCollateralTokenTransferAmount = neededCollateral.add(feeAmount);
            feeToken = collateralTokenAddress;
            // we will transfer collateral and fees all at once below.
        }

        // EXTERNAL CALL - transferring ERC20 tokens from sender to this contract.  User must have called
        // ERC20.approve in order for this call to succeed.
        ERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransferFrom(
            msg.sender,
            address(this),
            totalCollateralTokenTransferAmount
        );

        if (feeAmount != 0) {
            // update the fee's collected balance
            feesCollectedByTokenAddress[feeToken] = feesCollectedByTokenAddress[feeToken]
                .add(feeAmount);
        }

        // Update the collateral pool locked balance.
        contractAddressToCollateralPoolBalance[marketContractAddress] = contractAddressToCollateralPoolBalance[marketContractAddress]
            .add(neededCollateral);

        // mint and distribute short and long position tokens to our caller
        marketContract.mintPositionTokens(qtyToMint, msg.sender);

        emit TokensMinted(
            marketContractAddress,
            msg.sender,
            feeToken,
            qtyToMint,
            neededCollateral,
            feeAmount
        );
    }

    /// @notice Called by a user that currently holds both short and long position tokens and would like to redeem them
    /// for their collateral.
    /// @param marketContractAddress            address of the market contract to redeem tokens for
    /// @param qtyToRedeem                      quantity of long / short tokens to redeem.
    function redeemPositionTokens(address marketContractAddress, uint256 qtyToRedeem)
        external
        onlyWhiteListedAddress(marketContractAddress)
    {
        MarketContract marketContract = MarketContract(marketContractAddress);

        marketContract.redeemLongToken(qtyToRedeem, msg.sender);
        marketContract.redeemShortToken(qtyToRedeem, msg.sender);

        // calculate collateral to return and update pool balance
        uint256 collateralToReturn = MathLib.multiply(
            qtyToRedeem,
            marketContract.COLLATERAL_PER_UNIT()
        );
        contractAddressToCollateralPoolBalance[marketContractAddress] = contractAddressToCollateralPoolBalance[marketContractAddress]
            .subtract(collateralToReturn);

        // EXTERNAL CALL
        // transfer collateral back to user
        ERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransfer(
            msg.sender,
            collateralToReturn
        );

        emit TokensRedeemed(
            marketContractAddress,
            msg.sender,
            qtyToRedeem,
            qtyToRedeem,
            collateralToReturn
        );
    }

    // @notice called by a user after settlement has occurred.  This function will finalize all accounting around any
    // outstanding positions and return all remaining collateral to the caller. This should only be called after
    // settlement has occurred.
    /// @param marketContractAddress address of the MARKET Contract being traded.
    /// @param longQtyToRedeem qty to redeem of long tokens
    /// @param shortQtyToRedeem qty to redeem of short tokens
    function settleAndClose(
        address marketContractAddress,
        uint256 longQtyToRedeem,
        uint256 shortQtyToRedeem
    ) external onlyWhiteListedAddress(marketContractAddress) {
        MarketContract marketContract = MarketContract(marketContractAddress);
        require(
            marketContract.isPostSettlementDelay(),
            "Contract is not past settlement delay"
        );

        // burn tokens being redeemed.
        if (longQtyToRedeem > 0) {
            marketContract.redeemLongToken(longQtyToRedeem, msg.sender);
        }

        if (shortQtyToRedeem > 0) {
            marketContract.redeemShortToken(shortQtyToRedeem, msg.sender);
        }

        // calculate amount of collateral to return and update pool balances
        uint256 collateralToReturn = MathLib.calculateCollateralToReturn(
            marketContract.PRICE_FLOOR(),
            marketContract.PRICE_CAP(),
            marketContract.QTY_MULTIPLIER(),
            longQtyToRedeem,
            shortQtyToRedeem,
            marketContract.settlementPrice()
        );

        contractAddressToCollateralPoolBalance[marketContractAddress] = contractAddressToCollateralPoolBalance[marketContractAddress]
            .subtract(collateralToReturn);

        // return collateral tokens
        ERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransfer(
            msg.sender,
            collateralToReturn
        );

        emit TokensRedeemed(
            marketContractAddress,
            msg.sender,
            longQtyToRedeem,
            shortQtyToRedeem,
            collateralToReturn
        );
    }

    /// @dev allows the owner to remove the fees paid into this contract for minting
    /// @param feeTokenAddress - address of the erc20 token fees have been paid in
    /// @param feeRecipient - Recipient address of fees
    function withdrawFees(address feeTokenAddress, address feeRecipient)
        public
        onlyOwner
    {
        uint256 feesAvailableForWithdrawal = feesCollectedByTokenAddress[feeTokenAddress];
        require(feesAvailableForWithdrawal != 0, "No fees available for withdrawal");
        require(feeRecipient != address(0), "Cannot send fees to null address");
        feesCollectedByTokenAddress[feeTokenAddress] = 0;
        // EXTERNAL CALL
        ERC20(feeTokenAddress).safeTransfer(feeRecipient, feesAvailableForWithdrawal);
    }

    /// @dev allows the owner to update the mkt token address in use for fees
    /// @param mktTokenAddress address of new MKT token
    function setMKTTokenAddress(address mktTokenAddress) public onlyOwner {
        require(mktTokenAddress != address(0), "Cannot set MKT Token Address To Null");
        mktToken = mktTokenAddress;
    }

    /// @dev allows the owner to update the mkt token address in use for fees
    /// @param marketContractRegistryAddress address of new contract registry
    function setMarketContractRegistryAddress(address marketContractRegistryAddress)
        public
        onlyOwner
    {
        require(
            marketContractRegistryAddress != address(0),
            "Cannot set Market Contract Registry Address To Null"
        );
        marketContractRegistry = marketContractRegistryAddress;
    }

    /*
    // MODIFIERS
    */

    /// @notice only can be called with a market contract address that currently exists in our whitelist
    /// this ensure's it is a market contract that has been created by us and therefore has a uniquely created
    /// long and short token address.  If it didn't we could have spoofed contracts minting tokens with a
    /// collateral token that wasn't the same as the intended token.
    modifier onlyWhiteListedAddress(address marketContractAddress) {
        require(
            MarketContractRegistryInterface(marketContractRegistry).isAddressWhiteListed(
                marketContractAddress
            ),
            "Contract is not whitelisted"
        );
        _;
    }
}

/*
    Copyright 2017-2019 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/// @title MarketContractMPX - a MarketContract designed to be used with our internal oracle service
/// @author Phil Elsasser <phil@marketprotocol.io>
contract MarketContractMPX is MarketContract {
    address public ORACLE_HUB_ADDRESS;
    string public ORACLE_URL;
    string public ORACLE_STATISTIC;

    /// @param contractNames bytes32 array of names
    ///     contractName            name of the market contract
    ///     longTokenSymbol         symbol for the long token
    ///     shortTokenSymbol        symbol for the short token
    /// @param baseAddresses array of 2 addresses needed for our contract including:
    ///     ownerAddress                    address of the owner of these contracts.
    ///     collateralTokenAddress          address of the ERC20 token that will be used for collateral and pricing
    ///     collateralPoolAddress           address of our collateral pool contract
    /// @param oracleHubAddress     address of our oracle hub providing the callbacks
    /// @param contractSpecs array of unsigned integers including:
    ///     floorPrice              minimum tradeable price of this contract, contract enters settlement if breached
    ///     capPrice                maximum tradeable price of this contract, contract enters settlement if breached
    ///     priceDecimalPlaces      number of decimal places to convert our queried price from a floating point to
    ///                             an integer
    ///     qtyMultiplier           multiply traded qty by this value from base units of collateral token.
    ///     feeInBasisPoints    fee amount in basis points (Collateral token denominated) for minting.
    ///     mktFeeInBasisPoints fee amount in basis points (MKT denominated) for minting.
    ///     expirationTimeStamp     seconds from epoch that this contract expires and enters settlement
    /// @param oracleURL url of data
    /// @param oracleStatistic statistic type (lastPrice, vwap, etc)
    constructor(
        bytes32[3] memory contractNames,
        address[3] memory baseAddresses,
        address oracleHubAddress,
        uint256[7] memory contractSpecs,
        string memory oracleURL,
        string memory oracleStatistic
    ) public MarketContract(contractNames, baseAddresses, contractSpecs) {
        ORACLE_URL = oracleURL;
        ORACLE_STATISTIC = oracleStatistic;
        ORACLE_HUB_ADDRESS = oracleHubAddress;
    }

    /*
    // PUBLIC METHODS
    */

    /// @dev called only by our oracle hub when a new price is available provided by our oracle.
    /// @param price lastPrice provided by the oracle.
    function oracleCallBack(uint256 price) public onlyOracleHub {
        require(!isSettled);
        lastPrice = price;
        emit UpdatedLastPrice(price);
        checkSettlement(); // Verify settlement at expiration or requested early settlement.
    }

    /// @dev allows us to arbitrate a settlement price by updating the settlement value, and resetting the
    /// delay for funds to be released. Could also be used to allow us to force a contract into early settlement
    /// if a dispute arises that we believe is best resolved by early settlement.
    /// @param price settlement price
    function arbitrateSettlement(uint256 price) public onlyOwner {
        require(
            price >= PRICE_FLOOR && price <= PRICE_CAP,
            "arbitration price must be within contract bounds"
        );
        lastPrice = price;
        emit UpdatedLastPrice(price);
        settleContract(price);
        isSettled = true;
    }

    /// @dev allows calls only from the oracle hub.
    modifier onlyOracleHub() {
        require(msg.sender == ORACLE_HUB_ADDRESS, "only callable by the oracle hub");
        _;
    }

    /// @dev allows for the owner of the contract to change the oracle hub address if needed
    function setOracleHubAddress(address oracleHubAddress) public onlyOwner {
        require(
            oracleHubAddress != address(0),
            "cannot set oracleHubAddress to null address"
        );
        ORACLE_HUB_ADDRESS = oracleHubAddress;
    }
}

/*
    Copyright 2017-2019 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
/// @title MarketContractFactoryMPX
/// @author Phil Elsasser <phil@marketprotocol.io>
contract MarketContractFactoryMPX is Ownable {
    address public marketContractRegistry;
    address public oracleHub;
    address public MARKET_COLLATERAL_POOL;

    event MarketContractCreated(address indexed creator, address indexed contractAddress);

    /// @dev deploys our factory and ties it to the supplied registry address
    /// @param registryAddress - address of our MARKET registry
    /// @param collateralPoolAddress - address of our MARKET Collateral pool
    /// @param oracleHubAddress - address of the MPX oracle
    constructor(
        address registryAddress,
        address collateralPoolAddress,
        address oracleHubAddress
    ) public {
        require(registryAddress != address(0), "registryAddress can not be null");
        require(
            collateralPoolAddress != address(0),
            "collateralPoolAddress can not be null"
        );
        require(oracleHubAddress != address(0), "oracleHubAddress can not be null");

        marketContractRegistry = registryAddress;
        MARKET_COLLATERAL_POOL = collateralPoolAddress;
        oracleHub = oracleHubAddress;
    }

    /// @dev Deploys a new instance of a market contract and adds it to the whitelist.
    /// @param contractNames bytes32 array of names
    ///     contractName            name of the market contract
    ///     longTokenSymbol         symbol for the long token
    ///     shortTokenSymbol        symbol for the short token
    /// @param collateralTokenAddress address of the ERC20 token that will be used for collateral and pricing
    /// @param contractSpecs array of unsigned integers including:
    ///     floorPrice              minimum tradeable price of this contract, contract enters settlement if breached
    ///     capPrice                maximum tradeable price of this contract, contract enters settlement if breached
    ///     priceDecimalPlaces      number of decimal places to convert our queried price from a floating point to
    ///                             an integer
    ///     qtyMultiplier           multiply traded qty by this value from base units of collateral token.
    ///     feeInBasisPoints    fee amount in basis points (Collateral token denominated) for minting.
    ///     mktFeeInBasisPoints fee amount in basis points (MKT denominated) for minting.
    ///     expirationTimeStamp     seconds from epoch that this contract expires and enters settlement
    /// @param oracleURL url of data
    /// @param oracleStatistic statistic type (lastPrice, vwap, etc)
    function deployMarketContractMPX(
        bytes32[3] calldata contractNames,
        address collateralTokenAddress,
        uint256[7] calldata contractSpecs,
        string calldata oracleURL,
        string calldata oracleStatistic
    ) external onlyOwner returns (address) {
        MarketContractMPX mktContract = new MarketContractMPX(
            contractNames,
            [owner(), collateralTokenAddress, MARKET_COLLATERAL_POOL],
            oracleHub, /*  */
            contractSpecs,
            oracleURL,
            oracleStatistic
        );

        MarketContractRegistryInterface(marketContractRegistry).addAddressToWhiteList(
            address(mktContract)
        );
        emit MarketContractCreated(msg.sender, address(mktContract));
        return address(mktContract);
    }

    /// @dev allows for the owner to set the desired registry for contract creation.
    /// @param registryAddress desired registry address.
    function setRegistryAddress(address registryAddress) external onlyOwner {
        require(registryAddress != address(0), "registryAddress can not be null");
        marketContractRegistry = registryAddress;
    }

    /// @dev allows for the owner to set a new oracle hub address which is responsible for providing data to our
    /// contracts
    /// @param oracleHubAddress   address of the oracle hub, cannot be null address
    function setOracleHubAddress(address oracleHubAddress) external onlyOwner {
        require(oracleHubAddress != address(0), "oracleHubAddress can not be null");
        oracleHub = oracleHubAddress;
    }
}

// This is the DS proxy implementation taken from: https://github.com/dapphub/ds-proxy
// This contract and it's deployment along with the HoneyLemon Market Contract Proxy
// enable bulk redemption of long or short tokens by traders. At position creation
// the miner and investor's tokens are sent to the DSProxy. This proxy acts as a wallet
// for the miner and investor which only they can access (think smart contract wallet).
// At redemption time the user can use the DSProxy to execute batch transaction on their
// behalf by calling a `script` within the `MarketContractProxy`. DSProxy uses delegate
// call and as such this function execution can modify state within the DSProxy, without
// the DSProxy needing to story the logic for unwinding. This implementation is mostly
// the same as the stock dapphub version except for one new modifier.
contract DSNote {
    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 bar,
        uint256 wad,
        bytes fax
    );

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }
        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority public authority;
    address public owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

// DSProxy
// Allows code execution using a persistant identity This can be very
// useful to execute a sequence of atomic actions. Since the owner of
// the proxy can be changed, this allows for dynamic ownership models
// i.e. a multisig
contract DSProxy is DSAuth, DSNote {
    function() external payable {}

    function execute(address _target, bytes memory _data)
        public
        payable
        auth
        note
        returns (bytes memory response)
    {
        require(_target != address(0), "ds-proxy-target-address-required");

        // call contract in current context
        assembly {
            let succeeded := delegatecall(
                sub(gas, 5000),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    // throw if delegatecall failed
                    revert(add(response, 0x20), size)
                }
        }
    }
}

// DSProxyFactory
// This factory deploys new proxy instances through build()
// Deployed proxy addresses are logged
contract DSProxyFactory {
    event Created(address indexed sender, address indexed owner, address proxy);
    mapping(address => bool) public isProxy;
    address marketContractProxy;

    constructor() public {
        marketContractProxy = msg.sender;
    }

    modifier onlyMarketContractProxy() {
        require(
            msg.sender == marketContractProxy,
            "Only callable by MarketContractProxy"
        );
        _;
    }

    // deploys a new proxy instance
    // sets custom owner of proxy
    function build(address owner)
        public
        onlyMarketContractProxy()
        returns (address payable proxy)
    {
        proxy = address(new DSProxy());
        emit Created(msg.sender, owner, address(proxy));
        DSProxy(proxy).setOwner(owner);
        isProxy[proxy] = true;
    }

    // deploys a new proxy instance
    // sets owner of proxy to caller
    function build() internal returns (address payable proxy) {
        proxy = build(msg.sender);
    }
}

/// @title Market Contract Proxy.
/// @notice Handles the interconnection of the Market Protocol with 0x to
/// facilitate issuance of long and short tokens at order execution.
/// @dev This contract is responsible for 1) daily deployment of new market
/// contracts 2) settling old contracts 3) minting of long and short tokens 4)
/// storage of DSProxy info 5) enabling batch token redemption.
contract MarketContractProxy is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    MarketContractFactoryMPX public marketContractFactoryMPX;

    address public HONEY_LEMON_ORACLE_ADDRESS;
    address public MINTER_BRIDGE_ADDRESS;
    address public COLLATERAL_TOKEN_ADDRESS; //wBTC

    uint256 public CONTRACT_DURATION_DAYS = 28;
    // uint public CONTRACT_DURATION_DAYS = 2; // for kovan deployment
    uint256 public CONTRACT_DURATION = CONTRACT_DURATION_DAYS * 24 * 60 * 60; // 28 days in seconds
    uint256 public CONTRACT_COLLATERAL_RATIO = 125000000; //1.25e8; 1.25, with 8 decimal places

    uint256[7] public marketContractSpecs = [
        0, // floorPrice - the lower bound price for the CFD [constant]
        0, // capPrice - the upper bound price for the CFD [updated before deployment]
        8, // priceDecimalPlaces - number of decimals used to convert prices [constant]
        1, // qtyMultiplier - multiply traded qty by this value from base units of collateral token. [constant]
        0, // feeInBasisPoints - fee for minting tokens [constant]
        0, // mktFeeInBasisPoints - fees charged by the market in MKT [constant]
        0 // expirationTimeStamp [updated before deployment]
    ];

    ///@notice Array of all market contracts deployed
    address[] public marketContracts;

    ///@notice Mapping of each market contract address to the associated array index
    mapping(address => uint256) addressToMarketId;

    ///@notice Stores the most recent MRI value
    uint256 internal latestMri = 0;

    ///@notice DSProxy factory to create smart contract wallets for users to enable bulk redemption.
    DSProxyFactory dSProxyFactory;

    ///@notice Mapping to link each trader address to their DSProxy address.
    mapping(address => address) public addressToDSProxy;

    ///@notice Mapping to link each DSProxy address to their traders address.
    mapping(address => address) public dSProxyToAddress;

    /**
     * @notice constructor
     * @dev will deloy a new DSProxy Factory
     * @param _marketContractFactoryMPX market contract factory address
     * @param _honeyLemonOracle honeylemon oracle address
     * @param _minterBridge 0x minter bridge address
     * @param _wBTCTokenAddress wBTC token address
     */
    constructor(
        address _marketContractFactoryMPX,
        address _honeyLemonOracle,
        address _minterBridge,
        address _wBTCTokenAddress
    ) public ReentrancyGuard() {
        require(
            _marketContractFactoryMPX != address(0),
            "invalid MarketContractFactoryMPX address"
        );
        require(_honeyLemonOracle != address(0), "invalid HoneyLemonOracle address");
        require(_minterBridge != address(0), "invalid MinterBridge address");
        require(_wBTCTokenAddress != address(0), "invalid wBTC address");

        marketContractFactoryMPX = MarketContractFactoryMPX(_marketContractFactoryMPX);
        HONEY_LEMON_ORACLE_ADDRESS = _honeyLemonOracle;
        MINTER_BRIDGE_ADDRESS = _minterBridge;
        COLLATERAL_TOKEN_ADDRESS = _wBTCTokenAddress;

        //Deploy a new DSProxyFactory instance to faciliate hot wallet creation
        dSProxyFactory = new DSProxyFactory();
    }

    ////////////////
    //// EVENTS ////
    ////////////////
    event PositionTokensMinted(
        uint256 qtyToMint,
        uint256 indexed marketId,
        string contractName,
        address indexed longTokenRecipient,
        address longTokenDSProxy,
        address indexed shortTokenRecipient,
        address shortTokenDSProxy,
        address latestMarketContract,
        address longTokenAddress,
        address shortTokenAddress,
        uint256 time
    );

    event MarketContractSettled(
        address indexed contractAddress,
        uint256 revenuePerUnit,
        uint256 index
    );

    event MarketContractDeployed(
        uint256 currentMRI,
        bytes32 contractName,
        uint256 expiration,
        uint256 indexed index,
        address contractAddress,
        uint256 collateralPerUnit
    );

    event dSProxyCreated(address owner, address DSProxy);

    ///////////////////
    //// MODIFIERS ////
    ///////////////////

    /**
     * @notice modifier to check that the caller is honeylemon oracle address
     */
    modifier onlyHoneyLemonOracle() {
        require(msg.sender == HONEY_LEMON_ORACLE_ADDRESS, "Only Honey Lemon Oracle");
        _;
    }

    /**
     * @notice modifier to check that the caller is minter bridge address
     */
    modifier onlyMinterBridge() {
        require(msg.sender == MINTER_BRIDGE_ADDRESS, "Only Minter Bridge");
        _;
    }

    /**
     * @notice modifier to check that a fresh daily contract has been deployed
     */
    modifier onlyIfFreshDailyContract() {
        require(isDailyContractDeployed(), "No contract has been deployed yet today");
        _;
    }

    /////////////////////////
    //// OWNER FUNCTIONS ////
    /////////////////////////

    /**
     * @notice Set oracle address
     * @dev can only be called by owner
     * @param _honeyLemonOracleAddress oracle address
     */
    function setOracleAddress(address _honeyLemonOracleAddress) external onlyOwner {
        require(
            _honeyLemonOracleAddress != address(0),
            "invalid HoneyLemonOracle address"
        );

        HONEY_LEMON_ORACLE_ADDRESS = _honeyLemonOracleAddress;
    }

    /**
     * @notice Set minter bridge address
     * @dev can only be called by owner
     * @param _minterBridgeAddress 0x minter bridge address
     */
    function setMinterBridgeAddress(address _minterBridgeAddress) external onlyOwner {
        require(_minterBridgeAddress != address(0), "invalid MinterBridge address");

        MINTER_BRIDGE_ADDRESS = _minterBridgeAddress;
    }

    ////////////////////////
    //// PUBLIC GETTERS ////
    ////////////////////////

    /**
     * @notice get amounts of TH that can be filled
     * @param makerAddresses list of makers addresses
     * @return array of fillable amounts
     */
    function getFillableAmounts(address[] calldata makerAddresses)
        external
        view
        returns (uint256[] memory fillableAmounts)
    {
        uint256 length = makerAddresses.length;
        fillableAmounts = new uint256[](length);

        for (uint256 i = 0; i != length; i++) {
            fillableAmounts[i] = getFillableAmount(makerAddresses[i]);
        }

        return fillableAmounts;
    }

    /**
     * @notice get latest MRI value
     * @return latestMri
     */
    function getLatestMri() external view returns (uint256) {
        return latestMri;
    }

    /**
     * @notice get all market contarcts
     * @return array of market contracts
     */
    function getAllMarketContracts() public view returns (address[] memory) {
        return marketContracts;
    }

    /**
     * @notice calculate the TH amount that can be filled based on owner¡¯s BTC balance and allowance
     * @param makerAddress address or BTC(wBTC) owner
     * @return TH amount
     */
    function getFillableAmount(address makerAddress) public view returns (uint256) {
        ERC20 collateralToken = ERC20(COLLATERAL_TOKEN_ADDRESS);

        uint256 minerBalance = collateralToken.balanceOf(makerAddress);
        uint256 minerAllowance = collateralToken.allowance(
            makerAddress,
            MINTER_BRIDGE_ADDRESS
        );

        uint256 uintMinAllowanceBalance = minerBalance < minerAllowance
            ? minerBalance
            : minerAllowance;

        MarketContract latestMarketContract = getLatestMarketContract();

        return
            MathLib.divideFractional(
                1,
                uintMinAllowanceBalance,
                latestMarketContract.COLLATERAL_PER_UNIT()
            );
    }

    /**
     * @notice get latest market contract
     * @return market contract address
     */
    function getLatestMarketContract() public view returns (MarketContractMPX) {
        uint256 lastIndex = marketContracts.length.sub(1);
        return MarketContractMPX(marketContracts[lastIndex]);
    }

    /**
     * @notice get expiring market contract
     * @dev return address(0) if there is no expired contract
     * @return expired market contract address
     */
    function getExpiringMarketContract() public view returns (MarketContractMPX) {
        uint256 contractsAdded = marketContracts.length;

        // If the marketContracts array has not had enough markets pushed into it to settle an old one then return 0x0.
        if (contractsAdded < CONTRACT_DURATION_DAYS) {
            return MarketContractMPX(address(0x0));
        }
        uint256 expiringIndex = contractsAdded.sub(CONTRACT_DURATION_DAYS);
        return MarketContractMPX(marketContracts[expiringIndex]);
    }

    /**
     * @notice get market collateral pool address
     * @param market market contract
     * @return collateral pool address
     */
    function getCollateralPool(MarketContractMPX market)
        public
        view
        returns (MarketCollateralPool)
    {
        return MarketCollateralPool(market.COLLATERAL_POOL_ADDRESS());
    }

    /**
     * @notice get latest market collateral pool address
     * @return collateral pool address
     */
    function getLatestMarketCollateralPool() public view returns (MarketCollateralPool) {
        MarketContractMPX latestMarketContract = getLatestMarketContract();
        return getCollateralPool(latestMarketContract);
    }

    /**
     * @notice calculate collateral needed to mint Long/Short tokens
     * @param amount deposited amount
     * @return needed collateral
     */
    function calculateRequiredCollateral(uint256 amount) public view returns (uint256) {
        MarketContractMPX latestMarketContract = getLatestMarketContract();
        return MathLib.multiply(amount, latestMarketContract.COLLATERAL_PER_UNIT());
    }

    /**
     * @notice get user long token blanace for the current day
     * @dev used to prove to 0x that the wallet balance was correctly transferred.
     * @param owner address
     * @return long token balance
     */
    function balanceOf(address owner) public view returns (uint256) {
        address addressToCheck = getUserAddressOrDSProxy(owner);
        MarketContract latestMarketContract = getLatestMarketContract();
        ERC20 longToken = ERC20(latestMarketContract.LONG_POSITION_TOKEN());
        return longToken.balanceOf(addressToCheck);
    }

    /**
     * @notice get current timestamp
     */
    function getTime() public view returns (uint256) {
        return now;
    }

    /**
     * @notice generate market contract specs (cap price, expiration timestamp)
     * @param currentMRI current MRI value
     * @param expiration market expiration timestamp
     * @return market specs
     */
    function generateContractSpecs(uint256 currentMRI, uint256 expiration)
        public
        view
        returns (uint256[7] memory)
    {
        uint256[7] memory dailySpecs = marketContractSpecs;
        // capPrice. div by 1e8 for correct scaling
        // dailySpecs[1] =
        //     (CONTRACT_DURATION_DAYS * currentMRI * (CONTRACT_COLLATERAL_RATIO)) /
        //     1e8;
        dailySpecs[1] = (
            CONTRACT_DURATION_DAYS.mul(currentMRI).mul(CONTRACT_COLLATERAL_RATIO)
        )
            .div(1e8);
        // expirationTimeStamp. Fed in directly from oracle to ensure timing is exact, irrespective of block mining times
        dailySpecs[6] = expiration;
        return dailySpecs;
    }

    /**
     * @notice get user address
     * @dev get user own address or DSProxy address if user have one
     * @param inputAddress user address
     * @return address
     */
    function getUserAddressOrDSProxy(address inputAddress) public view returns (address) {
        // If the user has a DSProxy wallet, return that address. Else, return their wallet address
        return
            addressToDSProxy[inputAddress] == address(0)
                ? inputAddress
                : addressToDSProxy[inputAddress];
    }

    /**
     * @notice checks if a new contract has been deployed in the last 24 hours
     * @dev this prevents position tokens from being minted if the Honeylemon oracle has not deployed
     * a new contract in the last 24 hours to prevent a trader from getting a stale price.
     * @return bool true if there is a fresh contract, false if there is not a fresh contract
     */
    function isDailyContractDeployed() public view returns (bool) {
        uint256 settlementTimestamp = MarketContractMPX(getLatestMarketContract())
            .EXPIRATION();
        uint256 oneDayFromLatestDeployment = settlementTimestamp -
            CONTRACT_DURATION +
            60 *
            60 *
            24;
        return getTime() < oneDayFromLatestDeployment;
    }

    ///////////////////////////
    //// DSPROXY FUNCTIONS ////
    ///////////////////////////

    /**
     * @notice create DSProxy wallet
     * @return address of created DSProxy
     */
    function createDSProxyWallet() public returns (address) {
        // Create a new DSProxy for the caller.
        address payable dsProxyWallet = dSProxyFactory.build(msg.sender);
        addressToDSProxy[msg.sender] = dsProxyWallet;
        dSProxyToAddress[dsProxyWallet] = msg.sender;

        emit dSProxyCreated(msg.sender, dsProxyWallet);

        return dsProxyWallet;
    }

    /**
     * @notice batch redeem long or short tokens for different markets
     * @dev called by a DsProxy wallet which passes control from the caller using delegatecal
     * to enable the caller to redeem bulk tokens in one tx. Parameters are parallel arrays.
     * Only one side can be redeemed at a time. This is to simplify redemption as the same caller
     * will likely never be both long and short in the same contract.
     * @param tokenAddresses long/short token addresses
     * @param tokensToRedeem amount of token to redeem
     */
    function batchRedeem(
        address[] memory tokenAddresses, // Address of the long or short token to redeem
        uint256[] memory tokensToRedeem // the number of tokens to redeem
    ) public nonReentrant {
        require(tokenAddresses.length == tokensToRedeem.length, "Invalid input params");
        require(this.owner() == msg.sender, "You don't own this DSProxy GTFO");

        MarketContractMPX marketInstance;
        MarketCollateralPool marketCollateralPool;
        PositionToken tokenInstance;

        // Loop through all tokens and preform redemption
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            tokenInstance = PositionToken(tokenAddresses[i]);

            require(
                tokenInstance.balanceOf(address(this)) >= tokensToRedeem[i],
                "Insufficient position token balance"
            );

            marketInstance = MarketContractMPX(tokenInstance.owner());
            marketCollateralPool = getCollateralPool(marketInstance);

            tokenInstance.approve(address(marketInstance), tokensToRedeem[i]);

            if (uint8(tokenInstance.MARKET_SIDE()) == 0) {
                // redeem n long tokens and 0 short tokens
                marketCollateralPool.settleAndClose(
                    address(marketInstance),
                    tokensToRedeem[i],
                    0
                );
            } else {
                // redeem 0 long tokens and n short tokens
                marketCollateralPool.settleAndClose(
                    address(marketInstance),
                    0,
                    tokensToRedeem[i]
                );
            }
        }
        // Finally redeem collateral back to user.
        ERC20 collateralToken = ERC20(marketInstance.COLLATERAL_TOKEN_ADDRESS());

        // DSProxy balance. address(this) is the DSProxy contract address that will redeem the tokens.
        uint256 dSProxyBalance = collateralToken.balanceOf(address(this));

        // Move all redeemed tokens from DSProxy back to users wallet. msg.sender is the owner of the DSProxy.
        collateralToken.transfer(msg.sender, dSProxyBalance);
    }

    /////////////////////////////////////
    //// HONEYLEMON ORACLE FUNCTIONS ////
    /////////////////////////////////////

    /**
     * @notice deploy new market and settle last one (if met settlement requirements)
     * @dev can only be called by hinelemon oracle
     * @param lookbackIndexValue  last index value
     * @param currentIndexValue current index value
     * @param marketAndsTokenNames bytes array of market, long and short token names
     * @param newMarketExpiration new market expiration timestamp
     */
    function dailySettlement(
        uint256 lookbackIndexValue,
        uint256 currentIndexValue,
        bytes32[3] memory marketAndsTokenNames,
        uint256 newMarketExpiration
    ) public onlyHoneyLemonOracle {
        require(currentIndexValue != 0, "Current MRI value cant be zero");

        // 1. Settle the past contract, if there is a price and contract exists.
        MarketContractMPX expiringMarketContract = getExpiringMarketContract();
        if (address(expiringMarketContract) != address(0x0)) {
            settleMarketContract(lookbackIndexValue, address(expiringMarketContract));
        }

        // 2. Deploy daily contract for the next 28 days.
        deployContract(currentIndexValue, marketAndsTokenNames, newMarketExpiration);

        // 3. Store the latest MRI value
        latestMri = currentIndexValue;
    }

    /**
     * @notice settle specific market
     * @dev can only be called from honeylemon oracle.
     * Can be called directly to settle expiring market without deploying new one
     * @dev mri MRI value
     * @dev marketContractAddress market contract
     */
    function settleMarketContract(uint256 mri, address marketContractAddress)
        public
        onlyHoneyLemonOracle
    {
        require(mri != 0, "The mri loockback value can not be 0");
        require(marketContractAddress != address(0x0), "Invalid market contract address");

        MarketContractMPX marketContract = MarketContractMPX(marketContractAddress);
        marketContract.oracleCallBack(mri);

        // Store the most recent mri value to use in fillable amount
        latestMri = mri;

        emit MarketContractSettled(marketContractAddress, mri, marketContracts.length);
    }

    ///////////////////////////////////////////////
    //// 0X-MINTER-BRIDGE PRIVILEGED FUNCTIONS ////
    ///////////////////////////////////////////////
    /**
     * @notice mint long and short tokens
     * @dev can only be called from 0x minter bridge
     * @param qtyToMint long/short quantity to mint
     * @param longTokenRecipient address of long token recipient (will receive token at this address unless address have deployed DSProxy)
     * @param shortTokenRecipient address of short token recipient (will receive token at this address unless address have deployed DSProxy)
     */
    function mintPositionTokens(
        uint256 qtyToMint,
        address longTokenRecipient,
        address shortTokenRecipient
    ) public onlyMinterBridge onlyIfFreshDailyContract nonReentrant {
        uint256 collateralNeeded = calculateRequiredCollateral(qtyToMint);

        // Create instance of the latest market contract for today
        MarketContractMPX latestMarketContract = getLatestMarketContract();
        // Create instance of the market collateral pool
        MarketCollateralPool marketCollateralPool = getLatestMarketCollateralPool();

        // Long token sent to the investor
        ERC20 longToken = ERC20(latestMarketContract.LONG_POSITION_TOKEN());
        // Short token sent to the miner
        ERC20 shortToken = ERC20(latestMarketContract.SHORT_POSITION_TOKEN());
        // Collateral token (wBTC)
        ERC20 collateralToken = ERC20(COLLATERAL_TOKEN_ADDRESS);

        // Move tokens from the MinterBridge to this proxy address
        collateralToken.transferFrom(
            MINTER_BRIDGE_ADDRESS,
            address(this),
            collateralNeeded
        );

        // Permission market contract to spent collateral token
        collateralToken.approve(address(marketCollateralPool), collateralNeeded);

        // Generate long and short tokens to sent to invester and miner
        marketCollateralPool.mintPositionTokens(
            address(latestMarketContract),
            qtyToMint,
            false
        );

        // Send the tokens. If the user has a DSProxy wallet then send it to there, else
        // send it to their normal wallet address.
        longToken.transfer(getUserAddressOrDSProxy(longTokenRecipient), qtyToMint);
        shortToken.transfer(getUserAddressOrDSProxy(shortTokenRecipient), qtyToMint);

        emit PositionTokensMinted(
            qtyToMint,
            addressToMarketId[address(latestMarketContract)], // MarketID
            latestMarketContract.CONTRACT_NAME(),
            longTokenRecipient,
            getUserAddressOrDSProxy(longTokenRecipient),
            shortTokenRecipient,
            getUserAddressOrDSProxy(shortTokenRecipient),
            address(latestMarketContract),
            address(longToken),
            address(shortToken),
            getTime()
        );
    }

    ////////////////////////////
    //// INTERNAL FUNCTIONS ////
    ////////////////////////////

    // Deploys the current day Market contract. `indexValue` is used to initialize collateral
    // requirement in its constructor. Stores the new contract address, block it was deployed in,
    // as well as the value of the index we¡¯ll need easy access to the latest values of contract
    // address and index. collateral requirement = indexValue * 28 * overcollateralization_factor
    // returns the address of the new contract
    /**
     * @notice deploy the current Market contract
     * @param currentMRI current MRI value
     * @param marketAndsTokenNames bytes array of market, long and short token names
     * @param expiration expiration timestamp
     */
    function deployContract(
        uint256 currentMRI,
        bytes32[3] memory marketAndsTokenNames,
        uint256 expiration
    ) internal returns (address) {
        address contractAddress = marketContractFactoryMPX.deployMarketContractMPX(
            marketAndsTokenNames,
            COLLATERAL_TOKEN_ADDRESS,
            generateContractSpecs(currentMRI, expiration),
            "null", //ORACLE_URL
            "null" // ORACLE_STATISTIC
        );

        // Add new market to storage
        uint256 index = marketContracts.push(contractAddress) - 1;
        addressToMarketId[contractAddress] = index;
        MarketContractMPX marketContract = MarketContractMPX(contractAddress);
        marketContract.transferOwnership(owner());
        emit MarketContractDeployed(
            currentMRI,
            marketAndsTokenNames[0],
            expiration,
            index,
            contractAddress,
            marketContract.COLLATERAL_PER_UNIT()
        );
        return (contractAddress);
    }
}