/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: contracts/IEscrow.sol

pragma solidity ^0.5.0;


interface IEscrow {
    function balance() external returns (uint);
    function send(address payable addr, uint amt) external returns (bool);
}

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

pragma solidity ^0.5.0;

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
     * (.note) This call _does not revert_ if the signature is invalid, or
     * if the signer is otherwise unable to be retrieved. In those scenarios,
     * the zero address is returned.
     *
     * (.warning) `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise)
     * be too long), and then calling `toEthSignedMessageHash` on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
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
        // the valid range for s in (281): 0 < s < secp256k1n ¡Â 2 + 1, and for v in (282): v ¡Ê {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * [`eth_sign`](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign)
     * JSON-RPC method.
     *
     * See `recover`.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts/EscrowLibrary.sol

pragma solidity ^0.5.0;





/**
* Central contract containing the business logic for interacting with and
* managing the state of Arwen unidirectional payment channels
* @dev Escrows contracts are created and linked to this library from the
* EscrowFactory contract
*/
contract EscrowLibrary {

    using SafeMath for uint;

    string constant SIGNATURE_PREFIX = '\x19Ethereum Signed Message:\n';
    uint constant FORCE_REFUND_TIME = 2 days;

    /**
    * Escrow State Machine
    * @param None Preliminary state of an escrow before it has been created.
    * @param Unfunded Initial state of the escrow once created. The escrow can only
    * transition to the Open state once it has been funded with required escrow
    * amount and openEscrow method is called.
    * @param Open From this state the escrow can transition to Closed state
    * via the cashout or refund methods or it can transition to PuzzlePosted state
    * via the postPuzzle method.
    * @param PuzzlePosted From this state the escrow can only transition to
    * closed via the solve or puzzleRefund methods
    * @param Closed The final sink state of the escrow
    */
    enum EscrowState {
        None,
        Unfunded,
        Open,
        PuzzlePosted,
        Closed
    }

    /**
    * Unique ID for each different type of signed message in the protocol
    */
    enum MessageTypeId {
        None,
        Cashout,
        Puzzle,
        Refund
    }

    /**
    * Possible reasons the escrow can become closed
    */
    enum EscrowCloseReason {
        Refund,
        PuzzleRefund,
        PuzzleSolve,
        Cashout,
        ForceRefund
    }

    event EscrowOpened(address indexed escrow);
    event EscrowFunded(address indexed escrow, uint amountFunded);
    event PuzzlePosted(address indexed escrow, bytes32 puzzleSighash);
    event Preimage(address indexed escrow, bytes32 preimage, bytes32 puzzleSighash);
    event EscrowClosed(address indexed escrow, EscrowCloseReason reason, bytes32 closingSighash);
    event FundsTransferred(address indexed escrow, address reserveAddress);

    struct EscrowParams {
        // The amount expected to be funded by the escrower to open the payment channel
        uint escrowAmount;

        // Expiration time of the escrow when it can refunded by the escrower
        uint escrowTimelock;

        // Escrower's pub keys
        address payable escrowerReserve;
        address escrowerTrade;
        address escrowerRefund;

        // Payee's pub keys
        address payable payeeReserve;
        address payeeTrade;

        // Current state of the escrow
        EscrowState escrowState;

        // Internal payee/escrower balances within the payment channel
        uint escrowerBalance;
        uint payeeBalance;
    }

    /**
    * Represents a trade in the payment channel that can be executed
    * on-chain by the payee by revealing a hash preimage
    */
    struct PuzzleParams {
        // The amount of coins in this trade
        uint tradeAmount;

        // A hash output or "puzzle" which can be "solved" by revealing the preimage
        bytes32 puzzle;

        // The expiration time of the puzzle when the trade can be refunded by the escrower
        uint puzzleTimelock;

        // The signature hash of the `postPuzzle` message
        bytes32 puzzleSighash;
    }

    // The EscrowFactory contract that deployed this library
    address public escrowFactory;

    // Mapping of escrow address to EscrowParams
    mapping(address => EscrowParams) public escrows;

    // Mapping of escrow address to PuzzleParams
    // Only a single puzzle can be posted for a given escrow
    mapping(address => PuzzleParams) public puzzles;

    constructor() public {
        escrowFactory = msg.sender;
    }

    modifier onlyFactory() {
        require(msg.sender == escrowFactory, "Can only be called by escrow factory");
        _;
    }

    /**
    * Add a new escrow that is controlled by the library
    * @dev Only callable by the factory which should have already deployed the
    * escrow at the provided address
    */
    function newEscrow(
        address escrow,
        uint escrowAmount,
        uint timelock,
        address payable escrowerReserve,
        address escrowerTrade,
        address escrowerRefund,
        address payable payeeReserve,
        address payeeTrade
    )
        public
        onlyFactory
    {
        require(escrows[escrow].escrowState == EscrowState.None, "Escrow already exists");
        require(escrowAmount > 0, "Escrow amount too low");

        uint escrowerStartingBalance = 0;
        uint payeeStartingBalance = 0;

        escrows[escrow] = EscrowParams(
            escrowAmount,
            timelock,
            escrowerReserve,
            escrowerTrade,
            escrowerRefund,
            payeeReserve,
            payeeTrade,
            EscrowState.Unfunded,
            escrowerStartingBalance,
            payeeStartingBalance
        );
    }

    /**
    * Emits an event with the current balance of the escrow
    * @dev Can be used by the EthEscrow contract's payable fallback to
    * automatically emit an event when an escrow is funded
    */
    function checkFunded(address escrowAddress) public {
        EscrowParams storage escrowParams = escrows[escrowAddress];

        require(msg.sender == escrowAddress, "Only callable by the Escrow contract");
        require(escrowParams.escrowState == EscrowState.Unfunded, "Escrow must be in state Unfunded");

        emit EscrowFunded(escrowAddress, IEscrow(escrowAddress).balance());
    }

    /**
    * Moves the escrow to the open state if it has been funded
    * @dev Will send back any additional collateral above the `escrowAmount`
    * back to the escrower before opening
    */
    function openEscrow(address escrowAddress) public {
        EscrowParams storage escrowParams = escrows[escrowAddress];
        require(escrowParams.escrowState == EscrowState.Unfunded, "Escrow must be in state Unfunded");
        
        IEscrow escrow = IEscrow(escrowAddress);
        uint escrowAmount = escrowParams.escrowAmount;
        uint escrowBalance = escrow.balance();

        // Check the escrow is funded for at least escrowAmount
        require(escrowBalance >= escrowAmount, "Escrow not funded");

        escrowParams.escrowState = EscrowState.Open;
        emit EscrowOpened(escrowAddress);

        // If over-funded return any excess funds back to the escrower
        if(escrowBalance > escrowAmount) {
           escrow.send(escrowParams.escrowerReserve, escrowBalance.sub(escrowAmount));
        }
    }

    /**
    * Cashout the escrow with the final balances after trading
    * @dev Must be signed by both the escrower and payee trade keys
    * @dev Must be in Open state
    * @param amountTraded The total amount traded to the payee
    */
    function cashout(
        address escrowAddress,
        uint amountTraded,
        bytes memory eSig,
        bytes memory pSig
    )
        public
    {
        EscrowParams storage escrowParams = escrows[escrowAddress];
        require(escrowParams.escrowState == EscrowState.Open, "Escrow must be in state Open");

        // Length of the actual message: 20 + 1 + 32
        string memory messageLength = '53';
        bytes32 sighash = keccak256(abi.encodePacked(
            SIGNATURE_PREFIX,
            messageLength,
            escrowAddress,
            uint8(MessageTypeId.Cashout),
            amountTraded
        ));

        // Check signatures
        require(verify(sighash, eSig) == escrowParams.escrowerTrade, "Invalid escrower cashout sig");
        require(verify(sighash, pSig) == escrowParams.payeeTrade, "Invalid payee cashout sig");

        escrowParams.payeeBalance = amountTraded;
        escrowParams.escrowerBalance = escrowParams.escrowAmount.sub(amountTraded);
        escrowParams.escrowState = EscrowState.Closed;

        if(escrowParams.escrowerBalance > 0) sendEscrower(escrowAddress, escrowParams);
        if(escrowParams.payeeBalance > 0) sendPayee(escrowAddress, escrowParams);

        emit EscrowClosed(escrowAddress, EscrowCloseReason.Cashout, sighash);
    }

    /**
    * Allows the escrower to refund the escrow after the escrow expires
    * @dev This is a signed refund because it allows the refunder to
    * specify the amount traded in the escrow. This is useful for the escrower to
    * benevolently close the escrow with the final balances despite the other
    * party being offline
    * @dev Must be signed by the escrower refund key
    * @dev Must be in Open state
    * @param amountTraded The total amount traded to the payee
    */
    function refund(address escrowAddress, uint amountTraded, bytes memory eSig) public {
        EscrowParams storage escrowParams = escrows[escrowAddress];
        require(escrowParams.escrowState == EscrowState.Open, "Escrow must be in state Open");
        require(now >= escrowParams.escrowTimelock, "Escrow timelock not reached");
        
        // Length of the actual message: 20 + 1 + 32
        string memory messageLength = '53';
        bytes32 sighash = keccak256(abi.encodePacked(
            SIGNATURE_PREFIX,
            messageLength,
            escrowAddress,
            uint8(MessageTypeId.Refund),
            amountTraded
        ));

        // Check signature
        require(verify(sighash, eSig) == escrowParams.escrowerRefund, "Invalid escrower sig");

        escrowParams.payeeBalance = amountTraded;
        escrowParams.escrowerBalance = escrowParams.escrowAmount.sub(amountTraded);
        escrowParams.escrowState = EscrowState.Closed;

        if(escrowParams.escrowerBalance > 0) sendEscrower(escrowAddress, escrowParams);
        if(escrowParams.payeeBalance > 0) sendPayee(escrowAddress, escrowParams);

        emit EscrowClosed(escrowAddress, EscrowCloseReason.Refund, sighash);
    }

    /**
    * Allows anyone to refund the escrow back to the escrower without a
    * signature after escrowTimelock + FORCE_REFUND_TIME
    * @dev This method can be used in the event the escrower's keys are lost
    * or if the escrower remains offline for an extended period of time
    */
    function forceRefund(address escrowAddress) public {
        EscrowParams storage escrowParams = escrows[escrowAddress];
        require(escrowParams.escrowState == EscrowState.Open, "Escrow must be in state Open");
        require(now >= escrowParams.escrowTimelock + FORCE_REFUND_TIME, "Escrow force refund timelock not reached");

        escrowParams.escrowerBalance = IEscrow(escrowAddress).balance();
        escrowParams.escrowState = EscrowState.Closed;

        if(escrowParams.escrowerBalance > 0) sendEscrower(escrowAddress, escrowParams);

        // Use 0x0 as the closing sighash because there is no signature required
        emit EscrowClosed(escrowAddress, EscrowCloseReason.ForceRefund, 0x0);
    }

    /**
    * Post a hash puzzle unlocks lastest trade in the escrow
    * @dev Must be signed by both the escrower and payee trade keys
    * @dev Must be in Open state
    * @param prevAmountTraded The total amount traded to the payee in the
    * payment channel before the last trade
    * @param tradeAmount The last trade amount
    * @param puzzle A hash puzzle where the solution (preimage) releases the
    * `tradeAmount` to the payee
    * @param  puzzleTimelock The time at which the `tradeAmount` can be
    * refunded back to the escrower if the puzzle solution is not posted
    */
    function postPuzzle(
        address escrowAddress,
        uint prevAmountTraded,
        uint tradeAmount,
        bytes32 puzzle,
        uint puzzleTimelock,
        bytes memory eSig,
        bytes memory pSig
    )
        public
    {
        EscrowParams storage escrowParams = escrows[escrowAddress];
        require(escrowParams.escrowState == EscrowState.Open, "Escrow must be in state Open");

        // Length of the actual message: 20 + 1 + 32 + 32 + 32 + 32
        string memory messageLength = '149';
        bytes32 sighash = keccak256(abi.encodePacked(
            SIGNATURE_PREFIX,
            messageLength,
            escrowAddress,
            uint8(MessageTypeId.Puzzle),
            prevAmountTraded,
            tradeAmount,
            puzzle,
            puzzleTimelock
        ));

        require(verify(sighash, eSig) == escrowParams.escrowerTrade, "Invalid escrower sig");
        require(verify(sighash, pSig) == escrowParams.payeeTrade, "Invalid payee sig");

        puzzles[escrowAddress] = PuzzleParams(
            tradeAmount,
            puzzle,
            puzzleTimelock,
            sighash
        );

        escrowParams.escrowState = EscrowState.PuzzlePosted;
        escrowParams.payeeBalance = prevAmountTraded;
        escrowParams.escrowerBalance = escrowParams.escrowAmount.sub(prevAmountTraded).sub(tradeAmount);

        emit PuzzlePosted(escrowAddress, sighash);
    }

    /**
    * Payee solves the hash puzzle redeeming the last trade amount of funds in the escrow
    * @dev Must be in PuzzlePosted state
    * @param preimage The preimage x such that H(x) == puzzle
    */
    function solvePuzzle(address escrowAddress, bytes32 preimage) public {
        EscrowParams storage escrowParams = escrows[escrowAddress];
        require(escrowParams.escrowState == EscrowState.PuzzlePosted, "Escrow must be in state PuzzlePosted");

        PuzzleParams memory puzzleParams = puzzles[escrowAddress];
        bytes32 h = sha256(abi.encodePacked(preimage));
        require(h == puzzleParams.puzzle, "Invalid preimage");
        emit Preimage(escrowAddress, preimage, puzzleParams.puzzleSighash);

        escrowParams.payeeBalance = escrowParams.payeeBalance.add(puzzleParams.tradeAmount);
        escrowParams.escrowState = EscrowState.Closed;

        emit EscrowClosed(escrowAddress, EscrowCloseReason.PuzzleSolve, puzzleParams.puzzleSighash);
    }

    /**
    * Escrower refunds the last trade amount after `puzzleTimelock` has been reached
    * @dev Must be in PuzzlePosted state
    */
    function refundPuzzle(address escrowAddress) public {
        EscrowParams storage escrowParams = escrows[escrowAddress];
        require(escrowParams.escrowState == EscrowState.PuzzlePosted, "Escrow must be in state PuzzlePosted");

        PuzzleParams memory puzzleParams = puzzles[escrowAddress];
        require(now >= puzzleParams.puzzleTimelock, "Puzzle timelock not reached");
        
        escrowParams.escrowerBalance = escrowParams.escrowerBalance.add(puzzleParams.tradeAmount);
        escrowParams.escrowState = EscrowState.Closed;

        emit EscrowClosed(escrowAddress, EscrowCloseReason.PuzzleRefund, puzzleParams.puzzleSighash);
    }

    function withdraw(address escrowAddress, bool escrower) public {
        EscrowParams storage escrowParams = escrows[escrowAddress];

        require(escrowParams.escrowState == EscrowState.Closed, "Withdraw attempted before escrow is closed");

        if(escrower) {
            require(escrowParams.escrowerBalance > 0, "escrower balance is 0");
            sendEscrower(escrowAddress, escrowParams);
        } else {
            require(escrowParams.payeeBalance > 0, "payee balance is 0");
            sendPayee(escrowAddress, escrowParams);
        }
    }

    function sendEscrower(address escrowAddress, EscrowParams storage escrowParams) internal {
        IEscrow escrow = IEscrow(escrowAddress);

        uint amountToSend = escrowParams.escrowerBalance;
        escrowParams.escrowerBalance = 0;
        require(escrow.send(escrowParams.escrowerReserve, amountToSend), "escrower send failure");

        emit FundsTransferred(escrowAddress, escrowParams.escrowerReserve);
    }

    function sendPayee(address escrowAddress, EscrowParams storage escrowParams) internal {
        IEscrow escrow = IEscrow(escrowAddress);

        uint amountToSend = escrowParams.payeeBalance;
        escrowParams.payeeBalance = 0;
        require(escrow.send(escrowParams.payeeReserve, amountToSend), "payee send failure");

        emit FundsTransferred(escrowAddress, escrowParams.payeeReserve);
    }

    /**
    * Verify a EC signature (v,r,s) on a message digest h
    * @return retAddr The recovered address from the signature or 0 if signature is invalid
    */
    function verify(bytes32 sighash, bytes memory sig) internal pure returns(address retAddr) {
        retAddr = ECDSA.recover(sighash, sig);
    }
}

// File: contracts/Escrow.sol

pragma solidity ^0.5.0;





/**
* Thin wrapper around a ETH/ERC20 payment channel deposit that is controlled
* by a library contract for the purpose of trading with atomic swaps using the
* Arwen protocol.
* @dev Abstract contract with `balance` and `send` methods that must be implemented
* for either ETH or ERC20 tokens in derived contracts. The `send` method should only
* callable by the library contract that controls this escrow
*/
contract Escrow is IEscrow {

    address public escrowLibrary;

    modifier onlyLibrary() {
        require(msg.sender == escrowLibrary, "Only callable by library contract");
        _;
    }

    constructor(address _escrowLibrary) internal {
        escrowLibrary = _escrowLibrary;
    }
}


/**
* Escrow Contract backed by ETH
*/
contract EthEscrow is Escrow {

    constructor(address escrowLibrary) public Escrow(escrowLibrary) { }

    /**
    * Payable fallback method that allows the escrow to be funded and triggers
    * a `checkFunded` call on the library contract to emit an event when the
    * escrow becomes fully funded
    */
    function () external payable {
       EscrowLibrary(escrowLibrary).checkFunded(address(this));
    }

    function send(address payable addr, uint amt) public onlyLibrary returns (bool) {
        return addr.send(amt);
    }

    function balance() public returns (uint) {
        return address(this).balance;
    }
}


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/EscrowFactory.sol

pragma solidity ^0.5.0;





/**
* Creates an EscrowLibrary contract and allows for creating new escrows linked
* to that library
* @dev The factory  contract can be self-destructed by the owner to prevent
* new escrows from being created without affecting the library and the ability
* to close already existing escrows
*/
contract EscrowFactory is Ownable {

    EscrowLibrary public escrowLibrary;
    mapping(bytes32 => bool) internal escrowsCreated;

    constructor () public {
        escrowLibrary = new EscrowLibrary();
    }

    event EscrowCreated(
        bytes32 indexed escrowParams,
        address escrowAddress
    );

    function createEthEscrow(
        uint escrowAmount,
        uint timelock,
        address payable escrowerReserve,
        address escrowerTrade,
        address escrowerRefund,
        address payable payeeReserve,
        address payeeTrade
    )
    public
    {
        bytes32 escrowParamsHash = keccak256(abi.encodePacked(
            address(this),
            escrowAmount,
            timelock,
            escrowerReserve,
            escrowerTrade,
            escrowerRefund,
            payeeReserve,
            payeeTrade
        ));

        require(! escrowsCreated[escrowParamsHash], "escrow already exists");
        
        EthEscrow escrow = new EthEscrow(
            address(escrowLibrary)
        );

        escrowLibrary.newEscrow(
            address(escrow),
            escrowAmount,
            timelock,
            escrowerReserve,
            escrowerTrade,
            escrowerRefund,
            payeeReserve,
            payeeTrade
        );

        escrowsCreated[escrowParamsHash] = true;

        emit EscrowCreated(escrowParamsHash, address(escrow));
    }

    function selfDestruct() public onlyOwner {
        selfdestruct(msg.sender);
    }
}