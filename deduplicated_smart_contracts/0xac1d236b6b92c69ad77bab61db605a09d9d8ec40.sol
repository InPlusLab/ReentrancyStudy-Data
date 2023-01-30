/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

// Bytes library to concat and transform
// bytes arrays
library Bytes {
    // Concadenates two bytes array
    // Author: Gonçalo Sá <goncalo.sa@consensys.net>
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(_preBytes, _postBytes);
    }

    // Concatenates a bytes array and a bytes1
    function concat(bytes memory _a, bytes1 _b) internal pure returns (bytes memory _out) {
        return concat(_a, abi.encodePacked(_b));
    }

    // Concatenates 6 bytes arrays
    function concat(
        bytes memory _a,
        bytes memory _b,
        bytes memory _c,
        bytes memory _d,
        bytes memory _e,
        bytes memory _f
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            _a,
            _b,
            _c,
            _d,
            _e,
            _f
        );
    }

    // Transforms a bytes1 into bytes
    function toBytes(bytes1 _a) internal pure returns (bytes memory) {
        return abi.encodePacked(_a);
    }

    // Transform a uint256 into bytes (last 8 bits)
    function toBytes1(uint256 _a) internal pure returns (bytes1 c) {
        assembly { c := shl(248, _a) }
    }

    // Adds a bytes1 and the last 8 bits of a uint256
    function plus(bytes1 _a, uint256 _b) internal pure returns (bytes1 c) {
        c = toBytes1(_b);
        assembly { c := add(_a, c) }
    }

    // Transforms a bytes into an array
    // it fails if _a has more than 20 bytes
    function toAddress(bytes memory _a) internal pure returns (address payable b) {
        require(_a.length <= 20);
        assembly {
            b := shr(mul(sub(32, mload(_a)), 8), mload(add(_a, 32)))
        }
    }

    // Returns the most significant bit of a given uint256
    function mostSignificantBit(uint256 x) internal pure returns (uint256) {        
        uint8 o = 0;
        uint8 h = 255;
        
        while (h > o) {
            uint8 m = uint8 ((uint16 (o) + uint16 (h)) >> 1);
            uint256 t = x >> m;
            if (t == 0) h = m - 1;
            else if (t > 1) o = m + 1;
            else return m;
        }
        
        return h;
    }

    // Shrinks a given address to the minimal representation in a bytes array
    function shrink(address _a) internal pure returns (bytes memory b) {
        uint256 abits = mostSignificantBit(uint256(_a)) + 1;
        uint256 abytes = abits / 8 + (abits % 8 == 0 ? 0 : 1);

        assembly {
            b := 0x0
            mstore(0x0, abytes)
            mstore(0x20, shl(mul(sub(32, abytes), 8), _a))
        }
    }
}



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



library MinimalProxy {
    using Bytes for bytes1;
    using Bytes for bytes;

    // Minimal proxy contract
    // by Agusx1211
    bytes constant CODE1 = hex"60"; // + <size>                                   // Copy code to memory
    bytes constant CODE2 = hex"80600b6000396000f3";                               // Return and deploy contract
    bytes constant CODE3 = hex"3660008037600080366000";   // + <pushx> + <source> // Proxy, copy calldata and start delegatecall
    bytes constant CODE4 = hex"5af43d6000803e60003d9160"; // + <return jump>      // Do delegatecall and return jump
    bytes constant CODE5 = hex"57fd5bf3";                                         // Return proxy

    bytes1 constant BASE_SIZE = 0x1d;
    bytes1 constant PUSH_1 = 0x60;
    bytes1 constant BASE_RETURN_JUMP = 0x1b;

    // Returns the Init code to create a
    // Minimal proxy pointing to a given address
    function build(address _address) internal pure returns (bytes memory initCode) {
        return build(Bytes.shrink(_address));
    }

    function build(bytes memory _address) private pure returns (bytes memory initCode) {
        require(_address.length <= 20, "Address too long");
        initCode = Bytes.concat(
            CODE1,
            BASE_SIZE.plus(_address.length).toBytes(),
            CODE2,
            CODE3.concat(PUSH_1.plus(_address.length - 1)).concat(_address),
            CODE4.concat(BASE_RETURN_JUMP.plus(_address.length)),
            CODE5
        );
    }
}

contract SCOTT {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event NewSCOTT(address _scott);

    uint256 private _totalSupply;

    string constant public symbol = "SCOTT";
    string constant public name = "Stop SCOTT";
    uint256 constant public decimals = 18;
    
    bytes public proxyCode;

    constructor(
        address _to,
        uint256 _amount
    ) public {
        require(_totalSupply == 0, "already inited");
        _mint(_to, _amount);
        proxyCode = MinimalProxy.build(address(this));
    }

    function init(
        address _to,
        uint256 _amount
    ) external {
        require(_totalSupply == 0, "already inited");
        _mint(_to, _amount);
        proxyCode = SCOTT(msg.sender).proxyCode();
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        bytes memory pcode = proxyCode;
        SCOTT p;
        assembly { p := create(0, add(pcode, 0x20), mload(pcode)) }

        p.init(sender, amount);
        emit NewSCOTT(address(p));

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}