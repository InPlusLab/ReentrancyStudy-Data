/**
 *Submitted for verification at Etherscan.io on 2021-03-21
*/

// SPDX-License-Identifier: GPL-3.0-only

// File: @openzeppelin/contracts/GSN/Context.sol


pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/utils/Create2.sol


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        // solhint-disable-next-line no-inline-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint256(_data));
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// File: @openzeppelin/contracts/math/SafeMath.sol


pragma solidity >=0.6.0 <0.8.0;

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
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


pragma solidity >=0.6.0 <0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// File: contracts/PegToken.sol

pragma solidity ^0.6.0;



contract PegToken is Ownable, ERC20
{
	constructor (string memory _name, string memory _symbol, uint8 _decimals, uint256 _supply)
		ERC20(_name, _symbol) public
	{
		address _sender = msg.sender;
		_setupDecimals(_decimals);
		_mint(_sender, _supply);
	}
}

contract GRO is PegToken("Growth-Peg Token", "GRO", 18, 1000000e18)
{
}

// File: @openzeppelin/contracts/cryptography/ECDSA.sol


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/SignatureValidator.sol

pragma solidity ^0.6.0;


contract SignatureValidator
{
	function calcSignatureHash(uint256 _transferId, bytes32 _txId) public pure returns (bytes32 _hash)
	{
		return keccak256(abi.encodePacked(_transferId, _txId));
	}

	function validateSignature(address _agent, uint256 _transferId, bytes32 _txId, bytes memory _signature) public pure returns (bool _valid)
	{
		bytes32 _hash = calcSignatureHash(_transferId, _txId);
		return ECDSA.recover(ECDSA.toEthSignedMessageHash(_hash), _signature) == _agent;
	}

	function requireValidSignature(address _agent, uint256 _transferId, bytes32 _txId, bytes memory _signature) internal
	{
		require(validateSignature(_agent, _transferId, _txId, _signature), "invalid signature");
		emit ValidSignature(_agent, _transferId, _txId, _signature);
	}

	event ValidSignature(address indexed _agent, uint256 indexed _transferId, bytes32 indexed _txId, bytes _signature);
}

// File: @openzeppelin/contracts/utils/Address.sol


pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


pragma solidity >=0.6.0 <0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/modules/Transfers.sol

pragma solidity ^0.6.0;



/**
 * @dev This library abstracts ERC-20 operations in the context of the current
 * contract.
 */
library Transfers
{
	using SafeERC20 for IERC20;

	/**
	 * @dev Retrieves a given ERC-20 token balance for the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @return _balance The current contract balance of the given ERC-20 token.
	 */
	function _getBalance(address _token) internal view returns (uint256 _balance)
	{
		return IERC20(_token).balanceOf(address(this));
	}

	/**
	 * @dev Allows a spender to access a given ERC-20 balance for the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @param _to The spender address.
	 * @param _amount The exact spending allowance amount.
	 */
	function _approveFunds(address _token, address _to, uint256 _amount) internal
	{
		uint256 _allowance = IERC20(_token).allowance(address(this), _to);
		if (_allowance > _amount) {
			IERC20(_token).safeDecreaseAllowance(_to, _allowance - _amount);
		}
		else
		if (_allowance < _amount) {
			IERC20(_token).safeIncreaseAllowance(_to, _amount - _allowance);
		}
	}

	/**
	 * @dev Transfer a given ERC-20 token amount into the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @param _from The source address.
	 * @param _amount The amount to be transferred.
	 */
	function _pullFunds(address _token, address _from, uint256 _amount) internal
	{
		if (_amount == 0) return;
		IERC20(_token).safeTransferFrom(_from, address(this), _amount);
	}

	/**
	 * @dev Transfer a given ERC-20 token amount from the current contract.
	 * @param _token An ERC-20 compatible token address.
	 * @param _to The target address.
	 * @param _amount The amount to be transferred.
	 */
	function _pushFunds(address _token, address _to, uint256 _amount) internal
	{
		if (_amount == 0) return;
		IERC20(_token).safeTransfer(_to, _amount);
	}
}

// File: contracts/TrustedBridge.sol

pragma solidity ^0.6.0;




contract TrustedBridge is Ownable, ReentrancyGuard
{
	uint256 constant BLOCK_TIME_TOLERANCE = 15 minutes;

	uint256 constant WITHDRAW_GRACE_PERIOD = 30 minutes;

	uint256 public chainId;
	address public operator;
	address public token;

	mapping (uint256 => Transfer) public transfers;

	struct Transfer {
		uint256 timestamp;
	}

	modifier onlyEOA()
	{
		require(tx.origin == msg.sender, "not an externally owned account");
		_;
	}

	function construct(uint256 _chainId, address _operator, address _token) external
	{
		assert(chainId == 0);
		chainId = _chainId;
		operator = _operator;
		token = _token;
	}

	function calcTransferId(address _sourceBridge, address _targetBridge, uint256 _sourceChainId, uint256 _targetChainId, address _client, address _server, uint256 _sourceAmount, uint256 _targetAmount, uint256 _timestamp) public pure returns (uint256 _transferId)
	{
		return uint256(keccak256(abi.encode(_sourceBridge, _targetBridge, _sourceChainId, _targetChainId, _client, _server, _sourceAmount, _targetAmount, _timestamp)));
	}

	function deposit(address _targetBridge, uint256 _targetChainId, address _server, uint256 _sourceAmount, uint256 _targetAmount, uint256 _timestamp, uint256 _transferId) external onlyEOA nonReentrant
	{
		address _sourceBridge = address(this);
		uint256 _sourceChainId = chainId;
		address _client = msg.sender;
		require(_server != address(0), "invalid server");
		require(_targetBridge != address(0), "invalid bridge");
		require(_sourceChainId != _targetChainId, "invalid chain");
		require(transfers[_transferId].timestamp == 0, "access denied");
		require(_sourceAmount >= _targetAmount, "invalid amount");
		require(now - BLOCK_TIME_TOLERANCE <= _timestamp && _timestamp <= now + BLOCK_TIME_TOLERANCE, "not available");
		require(_transferId == calcTransferId(_sourceBridge, _targetBridge, _sourceChainId, _targetChainId, _client, _server, _sourceAmount, _targetAmount, _timestamp), "invalid transfer id");
		Transfers._pullFunds(token, _client, _sourceAmount);
		Transfers._pushFunds(token, operator, _sourceAmount);
		transfers[_transferId].timestamp = now;
		emit Deposit(_targetBridge, _targetChainId, _client, _server, _sourceAmount, _targetAmount, _timestamp, _transferId);
	}

	function withdraw(address _sourceBridge, uint256 _sourceChainId, address _client, uint256 _sourceAmount, uint256 _targetAmount, uint256 _timestamp, uint256 _transferId) external nonReentrant
	{
		address _targetBridge = address(this);
		uint256 _targetChainId = chainId;
		address _server = msg.sender;
		require(_client != address(0), "invalid client");
		require(_sourceBridge != address(0), "invalid bridge");
		require(_sourceChainId != _targetChainId, "invalid chain");
		require(transfers[_transferId].timestamp == 0, "access denied");
		require(_sourceAmount >= _targetAmount, "invalid amount");
		require(now >= _timestamp + WITHDRAW_GRACE_PERIOD, "not available");
		require(_transferId == calcTransferId(_sourceBridge, _targetBridge, _sourceChainId, _targetChainId, _client, _server, _sourceAmount, _targetAmount, _timestamp), "invalid transfer id");
		Transfers._pullFunds(token, _server, _targetAmount);
		Transfers._pushFunds(token, _client, _targetAmount);
		transfers[_transferId].timestamp = now;
		emit Withdraw(_sourceBridge, _sourceChainId, _client, _server, _sourceAmount, _targetAmount, _timestamp, _transferId);
	}

	function setOperator(address _newOperator) external onlyOwner
	{
		require(_newOperator != address(0), "invalid bridge");
		address _oldOperator = operator;
		operator = _newOperator;
		emit OperatorChange(_oldOperator, _newOperator);
	}

	event Deposit(address _targetBridge, uint256 _targetChainId, address indexed _client, address indexed _server, uint256 _sourceAmount, uint256 _targetAmount, uint256 _timestamp, uint256 indexed _transferId);
	event Withdraw(address _sourceBridge, uint256 _sourceChainId, address indexed _client, address indexed _server, uint256 _sourceAmount, uint256 _targetAmount, uint256 _timestamp, uint256 indexed _transferId);
	event OperatorChange(address _oldOperator, address _newOperator);
}

// File: contracts/Operator.sol

pragma solidity ^0.6.0;







contract Operator is Ownable, ReentrancyGuard, SignatureValidator
{
	uint256 public chainId;
	address public bridge;
	address public vault;
	address public token;

	mapping (uint256 => bytes32) public transactions;

	address[] public agents;

	function construct(uint256 _chainId, address _bridge, address _vault, address _token) external
	{
		assert(chainId == 0);
		chainId = _chainId;
		bridge = _bridge;
		vault = _vault;
		token = _token;
	}

	function processWithdraw(address _sourceBridge, uint256 _sourceChainId, address _client, uint256 _sourceAmount, uint256 _targetAmount, uint256 _timestamp, uint256 _transferId, bytes32 _txId, bytes memory _signatures) external nonReentrant
	{
		require(agents.length >= 2, "invalid agents");
		require(_sourceAmount >= _targetAmount, "invalid amount");
		require(_signatures.length == 65 * agents.length, "invalid length");
		for (uint256 _i = 0; _i < agents.length; _i++) {
			address _agent = agents[_i];
			bytes memory _signature = new bytes(65);
			for (uint256 _j = 0; _j < 65; _j++) {
				_signature[_j] = _signatures[65 * _i + _j];
			}
			requireValidSignature(_agent, _transferId, _txId, _signature);
		}
		Transfers._approveFunds(token, bridge, _targetAmount);
		TrustedBridge(bridge).withdraw(_sourceBridge, _sourceChainId, _client, _sourceAmount, _targetAmount, _timestamp, _transferId);
		assert(transactions[_transferId] == bytes32(0));
		transactions[_transferId] = _txId;
	}

	function transferToVault(uint256 _amount) external onlyOwner nonReentrant
	{
		Transfers._pushFunds(token, vault, _amount);
	}

	function setBridge(address _newBridge) external onlyOwner
	{
		require(_newBridge != address(0), "invalid bridge");
		address _oldBridge = bridge;
		bridge = _newBridge;
		emit BridgeChange(_oldBridge, _newBridge);
	}

	function addAgent(address _agent) external onlyOwner
	{
		require(_agent != address(0), "invalid agent");
		agents.push(_agent);
		emit AddAgent(_agent);
	}

	function removeAgent(uint256 _index) external onlyOwner
	{
		require(_index < agents.length, "invalid index");
		address _agent = agents[_index];
		agents[_index] = agents[agents.length - 1];
		agents.pop();
		emit RemoveAgent(_agent);
	}

	event ValidSignature(address indexed _agent, uint256 indexed _transferId, bytes32 indexed _txId, bytes _signature);
	event BridgeChange(address _oldBridge, address _newBridge);
	event AddAgent(address _agent);
	event RemoveAgent(address _agent);
}

// File: contracts/Panel.sol

pragma solidity ^0.6.0;





contract Panel is Ownable, ReentrancyGuard
{
	using SafeMath for uint256;

	uint256 constant DEFAULT_NETWORK_CONFIRMATIONS = 16;
	uint256 constant MINIMUM_NETWORK_CONFIRMATIONS = 8;

	uint256 public chainId;
	address public bridge;

	uint256 public networkConfirmations = DEFAULT_NETWORK_CONFIRMATIONS;
	mapping (uint256 => Fee) public fees;
	mapping (uint256 => Remote) public remotes;

	struct Fee {
		uint256 variableFeeRate;
		uint256 fixedFeeAmount;
	}

	struct Remote {
		address bridge;
		address operator;
	}

	function construct(uint256 _chainId, address _bridge) external
	{
		assert(chainId == 0);
		chainId = _chainId;
		bridge = _bridge;
	}

	function calcNetAmount(uint256 _amount, uint256 _chainId) public view returns (uint256 _netAmount)
	{
		uint256 _feeAmount = _amount.mul(fees[_chainId].variableFeeRate).div(1e18).add(fees[_chainId].fixedFeeAmount);
		require(_amount >= _feeAmount, "insufficient amount");
		return _amount.sub(_feeAmount);
	}

	function calcDepositParams(address _account, uint256 _amount, uint256 _chainId) external view returns (address _targetBridge, uint256 _targetChainId, address _server, uint256 _sourceAmount, uint256 _targetAmount, uint256 _timestamp, uint256 _transferId)
	{
		require(chainId != _chainId, "invalid chain");
		address _sourceBridge = bridge;
		_targetBridge = remotes[_chainId].bridge;
		uint256 _sourceChainId = chainId;
		_targetChainId = _chainId;
		address _client = _account;
		_server = remotes[_chainId].operator;
		_sourceAmount = _amount;
		_targetAmount = calcNetAmount(_amount, _chainId);
		_timestamp = now;
		_transferId = TrustedBridge(bridge).calcTransferId(_sourceBridge, _targetBridge, _sourceChainId, _targetChainId, _client, _server, _sourceAmount, _targetAmount, _timestamp);
		return (_targetBridge, _targetChainId, _server, _sourceAmount, _targetAmount, _timestamp, _transferId);
	}

	function setNetworkConfirmations(uint256 _newNetworkConfirmations) external onlyOwner
	{
		require(_newNetworkConfirmations < MINIMUM_NETWORK_CONFIRMATIONS, "invalid network confirmations");
		uint256 _oldNetworkConfirmations = networkConfirmations;
		networkConfirmations = _newNetworkConfirmations;
		emit NetworkConfirmationsChange(_oldNetworkConfirmations, _newNetworkConfirmations);
	}

	function setFee(uint256 _chainId, uint256 _newVariableFeeRate, uint256 _newFixedFeeAmount) external onlyOwner
	{
		require(chainId != _chainId, "invalid chain");
		require(_newVariableFeeRate <= 1e18, "invalid fee rate");
		uint256 _oldVariableFeeRate = fees[_chainId].variableFeeRate;
		uint256 _oldFixedFeeAmount = fees[_chainId].fixedFeeAmount;
		fees[_chainId].variableFeeRate = _newVariableFeeRate;
		fees[_chainId].fixedFeeAmount = _newFixedFeeAmount;
		emit FeeChange(_chainId, _oldVariableFeeRate, _oldFixedFeeAmount, _newVariableFeeRate, _newFixedFeeAmount);
	}

	function setBridge(address _newBridge) external onlyOwner
	{
		require(_newBridge != address(0), "invalid bridge");
		address _oldBridge = bridge;
		bridge = _newBridge;
		emit BridgeChange(_oldBridge, _newBridge);
	}

	function setRemoteBridge(uint256 _chainId, address _newRemoteBridge) external onlyOwner
	{
		require(chainId != _chainId, "invalid chain");
		require(_newRemoteBridge != address(0), "invalid bridge");
		address _oldRemoteBridge = remotes[_chainId].bridge;
		remotes[_chainId].bridge = _newRemoteBridge;
		emit RemoteBridgeChange(_chainId, _oldRemoteBridge, _newRemoteBridge);
	}

	function setRemoteOperator(uint256 _chainId, address _newRemoteOperator) external onlyOwner
	{
		require(_newRemoteOperator != address(0), "invalid operator");
		address _oldRemoteOperator = remotes[_chainId].operator;
		remotes[_chainId].operator = _newRemoteOperator;
		emit RemoteOperatorChange(_chainId, _oldRemoteOperator, _newRemoteOperator);
	}

	event NetworkConfirmationsChange(uint256 _oldNetworkConfirmations, uint256 _newNetworkConfirmations);
	event FeeChange(uint256 indexed _chainId, uint256 _oldVariableFeeRate, uint256 _oldFixedFeeAmount, uint256 _newVariableFeeRate, uint256 _newFixedFeeAmount);
	event BridgeChange(address _oldBridge, address _newBridge);
	event RemoteBridgeChange(uint256 indexed _chainId, address _oldRemoteBridge, address _newRemoteBridge);
	event RemoteOperatorChange(uint256 indexed _chainId, address _oldRemoteOperator, address _newRemoteOperator);
}

// File: contracts/SignatureRegistry.sol

pragma solidity ^0.6.0;



contract SignatureRegistry is SignatureValidator
{
	mapping (uint256 => mapping (address => Signature)) public signatures;

	struct Signature {
		bytes32 txId;
		bytes signature;
	}

	function registerSignature(uint256 _transferId, bytes32 _txId, bytes memory _signature) external
	{
		address _agent = msg.sender;
		requireValidSignature(_agent, _transferId, _txId, _signature);
		signatures[_transferId][_agent].txId = _txId;
		signatures[_transferId][_agent].signature = _signature;
	}
}

// File: contracts/TimeLockedVault.sol

pragma solidity ^0.6.0;




contract TimeLockedVault is Ownable, ReentrancyGuard
{
	uint256 constant WITHDRAWAL_WAIT_INTERVAL = 1 days;
	uint256 constant WITHDRAWAL_OPEN_INTERVAL = 1 days;

	mapping (address => Withdrawal) public withdrawals;

	struct Withdrawal {
		uint256 timestamp;
		address to;
		uint256 amount;
	}

	function announceWithdrawal(address _token, address _to, uint256 _amount) external onlyOwner nonReentrant
	{
		require(withdrawals[_token].timestamp == 0, "existing withdrawal");
		require(Transfers._getBalance(_token) >= _amount, "insufficient balance");
		uint256 _timestamp = now;
		withdrawals[_token].timestamp = _timestamp;
		withdrawals[_token].to = _to;
		withdrawals[_token].amount = _amount;
		emit AnnounceWithdrawal(_token, _to, _amount, _timestamp);
	}

	function cancelWithdrawal(address _token) external onlyOwner nonReentrant
	{
		uint256 _timestamp = withdrawals[_token].timestamp;
		require(_timestamp != 0, "unknown withdrawal");
		address _to = withdrawals[_token].to;
		uint256 _amount = withdrawals[_token].amount;
		withdrawals[_token].timestamp = 0;
		withdrawals[_token].to = address(0);
		withdrawals[_token].amount = 0;
		emit CancelWithdrawal(_token, _to, _amount, _timestamp);
	}

	function withdraw(address _token, address _to, uint256 _amount) external onlyOwner nonReentrant
	{
		uint256 _timestamp = withdrawals[_token].timestamp;
		require(_timestamp != 0, "unknown withdrawal");
		require(_to == withdrawals[_token].to, "to mismatch");
		require(_amount == withdrawals[_token].amount, "amount mismatch");
		uint256 _start = _timestamp + WITHDRAWAL_WAIT_INTERVAL;
		uint256 _end = _start + WITHDRAWAL_OPEN_INTERVAL;
		require(_start <= now && now < _end, "not available");
		Transfers._pushFunds(_token, _to, _amount);
		withdrawals[_token].timestamp = 0;
		withdrawals[_token].to = address(0);
		withdrawals[_token].amount = 0;
		emit Withdraw(_token, _to, _amount, _timestamp);
	}

	event AnnounceWithdrawal(address indexed _token, address indexed _to, uint256 _amount, uint256 indexed _timestamp);
	event CancelWithdrawal(address indexed _token, address indexed _to, uint256 _amount, uint256 indexed _timestamp);
	event Withdraw(address indexed _token, address indexed _to, uint256 _amount, uint256 indexed _timestamp);
}

// File: contracts/network/$.sol

pragma solidity ^0.6.0;

/**
 * @dev This library is provided for convenience. It is the single source for
 *      the current network and all related hardcoded contract addresses.
 */
library $
{
	enum Network {
		Mainnet, Ropsten, Rinkeby, Kovan, Goerli,
		Bscmain, Bsctest,
		Ftmmain, Ftmtest
	}

	Network constant NETWORK = Network.Mainnet;

	function chainId() internal pure returns (uint256 _chainid)
	{
		assembly { _chainid := chainid() }
		return _chainid;
	}

	function network() internal pure returns (Network _network)
	{
		uint256 _chainid = chainId();
		if (_chainid == 1) return Network.Mainnet;
		if (_chainid == 3) return Network.Ropsten;
		if (_chainid == 4) return Network.Rinkeby;
		if (_chainid == 42) return Network.Kovan;
		if (_chainid == 5) return Network.Goerli;
		if (_chainid == 56) return Network.Bscmain;
		if (_chainid == 97) return Network.Bsctest;
		if (_chainid == 250) return Network.Ftmmain;
		if (_chainid == 4002) return Network.Ftmtest;
		require(false, "unsupported network");
	}

	address constant GRO =
		NETWORK == Network.Mainnet ? 0x09e64c2B61a5f1690Ee6fbeD9baf5D6990F8dFd0 :
		NETWORK == Network.Ropsten ? 0x5BaF82B5Eddd5d64E03509F0a7dBa4Cbf88CF455 :
		NETWORK == Network.Rinkeby ? 0x020e317e70B406E23dF059F3656F6fc419411401 :
		NETWORK == Network.Kovan ? 0xFcB74f30d8949650AA524d8bF496218a20ce2db4 :
		NETWORK == Network.Goerli ? 0x464DF14dB50f46290CeDA1A8f7F0C6716c3c999D :
		// NETWORK == Network.Bscmain ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Bsctest ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Ftmmain ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Ftmtest ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;

	address constant UniswapV2_Compatible_ROUTER02 =
		// Ethereum / UniswapV2
		NETWORK == Network.Mainnet ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Ropsten ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Rinkeby ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Kovan ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		NETWORK == Network.Goerli ? 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D :
		// Binance Smart Chain / PancakeSwap
		NETWORK == Network.Bscmain ? 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F :
		// NETWORK == Network.Bsctest ? 0x0000000000000000000000000000000000000000 :
		// Fantom Opera / fUNI
		// NETWORK == Network.Bscmain ? 0x0000000000000000000000000000000000000000 :
		// NETWORK == Network.Bsctest ? 0x0000000000000000000000000000000000000000 :
		0x0000000000000000000000000000000000000000;
}

// File: contracts/Deployer.sol

pragma solidity ^0.6.0;











contract Deployer is Ownable
{
	address constant NATIVE_TREASURY = 0x3E7Ff81efBbAdf5FCA2810086b7f4C17a4F3682f;
	address constant PEGGED_TREASURY = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // G

	address constant NATIVE_DEFAULT_ADMIN = 0x3E7Ff81efBbAdf5FCA2810086b7f4C17a4F3682f;
	address constant PEGGED_DEFAULT_ADMIN = 0xBf70B751BB1FC725bFbC4e68C4Ec4825708766c5; // S

	uint256 constant PEGGED_GRO_VAULT_ALLOCATION = 998000e18; // 998,000
	uint256 constant PEGGED_GRO_TREASURY_ALLOCATION = 1000e18; // 1,000
	uint256 constant PEGGED_GRO_OPERATOR_ALLOCATION = 1000e18; // 1,000

	$.Network constant NATIVE_NETWORK = $.Network.Mainnet;
	uint256 constant NATIVE_TARGET_CHAIN_ID = 56; // bscmain
	uint256 constant NATIVE_TARGET_VARIABLE_FEE_RATE = 3e16; // 3%
	uint256 constant NATIVE_TARGET_FIXED_FEE_AMOUNT = 0e18; // 0 GRO

	$.Network constant PEGGED_NETWORK = $.Network.Bscmain;
	uint256 constant PEGGED_TARGET_CHAIN_ID = 1; // mainnet
	uint256 constant PEGGED_TARGET_VARIABLE_FEE_RATE = 3e16; // 3%
	uint256 constant PEGGED_TARGET_FIXED_FEE_AMOUNT = 1e18; // 1 GRO

	address constant DEFAULT_OPERATOR1 = 0xfd692394625c66cE3cfd62802D098902c2e92281;
	address constant DEFAULT_OPERATOR2 = 0xfB468077695F7a2bAA0AdF394b5767Dd9eC140dB;

	address public treasury;
	address public admin;
	address public token;
	address public vault;
	address public bridge;
	address public operator;
	address public panel;
	address public registry;

	bool public deployed = false;

	constructor () public
	{
		require($.NETWORK == $.network(), "wrong network");
	}

	function deploy() external onlyOwner
	{
		require(!deployed, "deploy unavailable");

		bool _nativeNetwork = true
			&& $.NETWORK != $.Network.Bscmain
			&& $.NETWORK != $.Network.Bsctest
			&& $.NETWORK != $.Network.Ftmmain
			&& $.NETWORK != $.Network.Ftmtest;

		// publish contracts
		if (_nativeNetwork) {
			treasury = NATIVE_TREASURY;
			admin = NATIVE_DEFAULT_ADMIN;
			token = $.GRO;
		} else {
			treasury = PEGGED_TREASURY;
			admin = PEGGED_DEFAULT_ADMIN;
			token = LibDeployer1.publishGRO();
			registry = LibDeployer1.publishSignatureRegistry();
		}
		vault = LibDeployer2.publishTimeLockedVault();
		operator = LibDeployer1.publishOperator();
		bridge = LibDeployer2.publishTrustedBridge();
		panel = LibDeployer2.publishPanel();

		// setup contracts
		uint256 _chainId = $.chainId();
		assert(_chainId != 0);
		Operator(operator).construct(_chainId, bridge, vault, token);
		TrustedBridge(bridge).construct(_chainId, operator, token);
		Panel(panel).construct(_chainId, bridge);

		// configure panel
		if ($.NETWORK == NATIVE_NETWORK) {
			Panel(panel).setFee(NATIVE_TARGET_CHAIN_ID, NATIVE_TARGET_VARIABLE_FEE_RATE, NATIVE_TARGET_FIXED_FEE_AMOUNT);
			Panel(panel).setRemoteBridge(NATIVE_TARGET_CHAIN_ID, bridge);
			Panel(panel).setRemoteOperator(NATIVE_TARGET_CHAIN_ID, operator);
		}
		else
		if ($.NETWORK == PEGGED_NETWORK) {
			Panel(panel).setFee(PEGGED_TARGET_CHAIN_ID, PEGGED_TARGET_VARIABLE_FEE_RATE, PEGGED_TARGET_FIXED_FEE_AMOUNT);
			Panel(panel).setRemoteBridge(PEGGED_TARGET_CHAIN_ID, bridge);
			Panel(panel).setRemoteOperator(PEGGED_TARGET_CHAIN_ID, operator);
		}

		// configure operator
		Operator(operator).addAgent(DEFAULT_OPERATOR1);
		Operator(operator).addAgent(DEFAULT_OPERATOR2);

		// transfer total supply
		if (!_nativeNetwork) {
			Transfers._pushFunds(token, vault, PEGGED_GRO_VAULT_ALLOCATION);
			Transfers._pushFunds(token, treasury, PEGGED_GRO_TREASURY_ALLOCATION);
			Transfers._pushFunds(token, operator, PEGGED_GRO_OPERATOR_ALLOCATION);
		}

		// make sure all transfers occurred
		require(Transfers._getBalance(token) == 0, "GRO left over");

		// transfer ownerships
		Ownable(operator).transferOwnership(admin);
		Ownable(bridge).transferOwnership(admin);
		Ownable(panel).transferOwnership(admin);
		Ownable(vault).transferOwnership(admin);

		// wrap up the deployment
		renounceOwnership();
		deployed = true;
		emit DeployPerformed();
	}

	event DeployPerformed();
}

library LibDeployer1
{
	function publishGRO() public returns (address _address)
	{
		bytes memory _bytecode = abi.encodePacked(type(GRO).creationCode);
		return Create2.deploy(0, bytes32(0), _bytecode);
	}

	function publishSignatureRegistry() public returns (address _address)
	{
		bytes memory _bytecode = abi.encodePacked(type(SignatureRegistry).creationCode);
		return Create2.deploy(0, bytes32(0), _bytecode);
	}

	function publishOperator() public returns (address _address)
	{
		bytes memory _bytecode = abi.encodePacked(type(Operator).creationCode);
		return Create2.deploy(0, bytes32(0), _bytecode);
	}
}

library LibDeployer2
{
	function publishTrustedBridge() public returns (address _address)
	{
		bytes memory _bytecode = abi.encodePacked(type(TrustedBridge).creationCode);
		return Create2.deploy(0, bytes32(0), _bytecode);
	}

	function publishPanel() public returns (address _address)
	{
		bytes memory _bytecode = abi.encodePacked(type(Panel).creationCode);
		return Create2.deploy(0, bytes32(0), _bytecode);
	}

	function publishTimeLockedVault() public returns (address _address)
	{
		bytes memory _bytecode = abi.encodePacked(type(TimeLockedVault).creationCode);
		return Create2.deploy(0, bytes32(0), _bytecode);
	}
}