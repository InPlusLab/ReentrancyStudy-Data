/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

// File: ../common/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: contracts/SmokeSig.sol

pragma solidity ^0.6.0;


contract SmokeSig {
    IERC20 public token;

    constructor(IERC20 _token) public {
        token = _token;
    }

    mapping (bytes32 => uint) public amountBurnedForSignal;

    event SmokeSignalWithMessage(
        bytes32 indexed _hash,
        address indexed _from,
        uint _burnAmount,
        string _message
    );

    function smokeSignalWithMessage(string memory _message, uint _burnAmount)
        public
        returns(bytes32)
    {
        bytes32 hash = keccak256(abi.encode(_message));

        processSmokeSignal(hash, _burnAmount);

        emit SmokeSignalWithMessage(
            hash,
            msg.sender,
            _burnAmount,
            _message
        );

        return hash;
    }

    event SmokeSignalWithoutMessage(
        bytes32 indexed _hash,
        address indexed _from,
        uint _burnAmount
    );

    function smokeSignalWithHash(bytes32 _hash, uint _burnAmount)
        public
    {
        processSmokeSignal(_hash, _burnAmount);

        emit SmokeSignalWithoutMessage(
            _hash,
            msg.sender,
            _burnAmount
        );
    }

    function processSmokeSignal(bytes32 _hash, uint _burnAmount)
        internal
    {
        require(_burnAmount > 0, "Gotta burn something!");
        bool burnTransferSuccess = burnFrom(msg.sender, _burnAmount);
        require(burnTransferSuccess, "The burn did not complete!");

        amountBurnedForSignal[_hash] += _burnAmount;
    }

    function burnFrom(address _who, uint _burnAmount)
        internal
        returns(bool)
    {
        return token.transferFrom(_who, address(0), _burnAmount);
    }
}