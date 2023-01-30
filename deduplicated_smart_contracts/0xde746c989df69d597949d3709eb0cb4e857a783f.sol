/**
 *Submitted for verification at Etherscan.io on 2020-04-01
*/

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

struct StoredMessageData {
    address firstAuthor;
    uint totalBurned;
    uint totalTipped;
}

contract SmokeSignal {
    IERC20 public token;
    address donationAddress;

    constructor(IERC20 _token, address _donationAddress) public {
        token = _token;
        donationAddress = _donationAddress;
    }

    mapping (bytes32 => StoredMessageData) public storedMessageData;

    event MessageBurn(
        bytes32 indexed _hash,
        address indexed _from,
        uint _burnAmount,
        string _message
    );

    function burnMessage(string calldata _message, uint _burnAmount, uint _donateAmount)
        external
        returns(bytes32)
    {
        internalDonateIfNonzero(_donateAmount);

        bytes32 hash = keccak256(abi.encode(_message));

        internalBurnForMessageHash(hash, _burnAmount);

        if (storedMessageData[hash].firstAuthor == address(0)) {
            storedMessageData[hash].firstAuthor = msg.sender;
        }

        emit MessageBurn(
            hash,
            msg.sender,
            _burnAmount,
            _message
        );

        return hash;
    }

    event HashBurn(
        bytes32 indexed _hash,
        address indexed _from,
        uint _burnAmount
    );

    function burnHash(bytes32 _hash, uint _burnAmount, uint _donateAmount)
        external
    {
        internalDonateIfNonzero(_donateAmount);

        internalBurnForMessageHash(_hash, _burnAmount);

        emit HashBurn(
            _hash,
            msg.sender,
            _burnAmount
        );
    }

    event HashTip(
        bytes32 indexed _hash,
        address indexed _from,
        uint _tipAmount
    );

    function tipHashOrBurnIfNoAuthor(bytes32 _hash, uint _amount, uint _donateAmount)
        external
    {
        internalDonateIfNonzero(_donateAmount);

        address author = storedMessageData[_hash].firstAuthor;
        if (author == address(0)) {
            internalBurnForMessageHash(_hash, _amount);

            emit HashBurn(
                _hash,
                msg.sender,
                _amount
            );
        }
        else {
            internalTipForMessageHash(_hash, author, _amount);

            emit HashTip(
                _hash,
                msg.sender,
                _amount
            );
        }
    }

    function internalBurnForMessageHash(bytes32 _hash, uint _burnAmount)
        internal
    {
        require(_burnAmount > 0, "burnAmount must be greater than 0");
        bool burnSuccess = burnFrom(msg.sender, _burnAmount);
        require(burnSuccess, "Burn failed");

        storedMessageData[_hash].totalBurned += _burnAmount;
    }

    function burnFrom(address _who, uint _burnAmount)
        internal
        returns(bool)
    {
        return token.transferFrom(_who, address(0), _burnAmount);
    }

    function internalTipForMessageHash(bytes32 _hash, address author, uint _tipAmount)
        internal
    {
        require(_tipAmount > 0, "tipAmount must be greater than 0");
        bool transferSuccess = token.transferFrom(msg.sender, author, _tipAmount);
        require(transferSuccess, "Tip transfer failed");

        storedMessageData[_hash].totalTipped += _tipAmount;
    }

    function internalDonateIfNonzero(uint _donateAmount)
        internal
    {
        if (_donateAmount > 0) {
            bool transferSuccess = token.transferFrom(msg.sender, donationAddress, _donateAmount);
            require(transferSuccess, "Donation transfer failed");
        }
    }
}