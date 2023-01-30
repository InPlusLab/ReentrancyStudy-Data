/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

pragma solidity ^0.4.26;


/// MVP locked wallet
/// @author Forest Wang - <forest@merculet.io>
/// 必须是owners发起取款，auditor进行确认
// MvpLockedWallet
contract MvpLockedWallet {

    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event TransactionNotAllowed(address indexed destination);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event BalanceNotEnough(address indexed owner, uint indexed withdrawValue, uint indexed balance);
    event BalanceAddition(address indexed owner, uint indexed changeValue, uint indexed balance);
    event BalanceSubtraction(address indexed owner, uint indexed changeValue, uint indexed balance);

    /*
     *  Storage
     */
    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    mapping(address => uint) public tokenBalance;
    address[] public owners;
    address public auditor;
    address public contractAddress;
    uint public transactionCount;

    /*
     *  Struct
     */
    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
        bool multiSig;
    }

    /*
     *  Modifiers
     */
    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    modifier validAuditor(address _address) {
        require(_address != 0);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
    public
    payable
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    /// Contract constructor sets initial owners.
    /// @param _auditor Auditor of this contract who confirms the transfer out transaction.
    /// @param _owners List of initial owners.
    /// @param _contractAddress Erc20 contract address.
    constructor(address _auditor, address[] _owners, address _contractAddress)
    public
    validAuditor(_auditor)
    {
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
            tokenBalance[_owners[i]] = 0;
        }
        owners = _owners;
        auditor = _auditor;
        contractAddress = _contractAddress;
    }

    /// Bytes to uint to check method
    function bytesToUint(bytes b)
    public
    pure
    returns (uint256)
    {
        uint256 number;
        for (uint i = 0; i < b.length; i++) {
            number = number + uint(b[i]) * (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }

    /// GET balance of owner
    /// @param owner Get balance of owner
    function getBalance(address owner)
    public
    view
    ownerExists(owner)
    returns (uint)
    {
        return tokenBalance[owner];
    }

    /// Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address, it must be the contract or Erc20 contract address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes data)
    public
    returns (uint transactionId)
    {
        if (destination != contractAddress && destination != address(this)) {
            emit TransactionNotAllowed(destination);
            return;
        }
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /// Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    /// Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (external_call(txn.destination, txn.value, txn.data.length, txn.data)) {
                // Erc20 contract transfer
                if (txn.destination == contractAddress) {
                    (bool isTransfer, address to, uint v) = decodeTransferData(txn.data);
                    if (isTransfer) {
                        // subtract balance if not to this contract address
                        if (address(this) != to) {
                            tokenBalance[to] = tokenBalance[to] - v;
                            emit BalanceSubtraction(to, v, tokenBalance[to]);
                        }
                    }
                    (bool isTransferFrom,  address from2, address to2, uint v2) = decodeTransferFromData(txn.data);
                    if (isTransferFrom && address(this) == to2) {
                        tokenBalance[from2] = tokenBalance[from2] + v2;
                        emit BalanceAddition(from2, v2, tokenBalance[from2]);
                        if (!isOwner[from2] && msg.sender == auditor) {
                            // Add from2 into owner if it is not in
                            isOwner[from2] = true;
                            owners.push(from2);
                            emit OwnerAddition(from2);
                        }
                    }
                }
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(address destination, uint value, uint dataLength, bytes data)
    internal
    returns (bool)
    {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
            sub(gas, 34710), // 34710 is the value that solidity is currently emitting
            // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
            // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
            destination,
            value,
            d,
            dataLength, // Size of the input (in bytes) - this is what fixes the padding problem
            x,
            0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    /// Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
    public
    returns (bool)
    {
        Transaction storage txn = transactions[transactionId];
        (bool isTransfer, address to, uint v) = decodeTransferData(txn.data);
        if (!transactions[transactionId].multiSig) {
            if (txn.destination == contractAddress) {
                if (isTransfer) {
                    to;
                    v;
                    return true;
                }
                (bool isTransferFrom,  address from2, address to2, uint v2) = decodeTransferFromData(txn.data);
                if (isTransferFrom) {
                    from2;
                    to2;
                    v2;
                    return true;
                }
            }
            if (msg.sender == auditor) {
                return true;
            } else {
                return false;
            }
        } else {
            if (txn.destination == contractAddress) {
                // withdraw check balance if transfer to other address from contract address
                if (isTransfer && to != address(this)) {
                    if (v > tokenBalance[to]) {
                        emit BalanceNotEnough(to, v, tokenBalance[to]);
                        return false;
                    }
                }
            }
            uint count = 0;
            for (uint i = 0; i < owners.length; i++) {
                if (confirmations[transactionId][owners[i]])
                    count += 1;
            }
            if (count >= 2 && msg.sender == auditor) {
                return true;
            } else {
                return false;
            }
        }
    }

    /*
     * Internal functions
     */
    /// Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes data)
    internal
    notNull(destination)
    returns (uint transactionId)
    {
        transactionId = transactionCount;
        Transaction memory txn = Transaction({
            destination : destination,
            value : value,
            data : data,
            executed : false,
            multiSig : true
            });

        // if the method is add remove replace and change daily not need multi sig
        uint256 iMethod = decodeMethod(data);
        // check method
        if (iMethod == 1885719368) {// add owner
            txn.multiSig = false;
        }
        if (destination == contractAddress) {
            (bool isTransfer, address to, uint v) = decodeTransferData(data);
            if (isTransfer) {
                // not need multiSig if to contract
                if (address(this) == to) {
                    txn.multiSig = false;
                    v;
                }
            }
            (bool isTransferFrom,  address from2, address to2, uint v2) = decodeTransferFromData(data);
            if (isTransferFrom) {
                // not need multiSig if to contract
                if (address(this) == to2) {
                    txn.multiSig = false;
                    from2;
                    v2;
                }
            }
        }
        transactions[transactionId] = txn;
        transactionCount += 1;
        emit Submission(transactionId);
    }

    /// Decode method from data
    /// @param data transaction data
    function decodeMethod(bytes data)
    internal
    pure
    returns (uint256)
    {
        if (data .length > 4) {
            bytes memory method = new bytes(4);
            for (uint j = 0; j < 4; j++)
                method[j] = data[j];
            return bytesToUint(method);
        }
        return 0;
    }

    /// Decode method transfer from data
    /// @param data transaction data
    function decodeTransferData(bytes data)
    internal
    pure
    returns (bool isTransfer, address to, uint v)
    {
        isTransfer = false;
        if (data.length >= 36) {
            uint256 iMethod = decodeMethod(data);
            // Transfer
            if (iMethod == 2835717307) {
                bytes memory toAddress = new bytes(20);
                for (uint k = 16; k < 36; k++)
                    toAddress[k - 16] = data[k];
                to = address(bytesToUint(toAddress));
                bytes memory value = new bytes(20);
                for (k = 48; k < 68; k++)
                    value[k - 48] = data[k];
                v = bytesToUint(value);
                isTransfer = true;
            }
        }
    }

    /// Decode method transferFrom from data
    /// @param data transaction data
    function decodeTransferFromData(bytes data)
    internal
    pure
    returns (bool isTransferFrom, address from, address to, uint v)
    {
        isTransferFrom = false;
        if (data.length >= 100) {
            uint256 iMethod = decodeMethod(data);
            // TransferFrom
            if (iMethod == 599290589) {
                bytes memory fromAddress = new bytes(20);
                for (uint k = 16; k < 36; k++)
                    fromAddress[k - 16] = data[k];
                from = address(bytesToUint(fromAddress));
                bytes memory toAddress = new bytes(20);
                for (k = 48; k < 68; k++)
                    toAddress[k - 48] = data[k];
                to = address(bytesToUint(toAddress));
                bytes memory value = new bytes(20);
                for (k = 80; k < 100; k++)
                    value[k - 80] = data[k];
                v = bytesToUint(value);
                isTransferFrom = true;
            }
        }
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
    public
    constant
    returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
    public
    constant
    returns (uint count)
    {
        for (uint i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed)
                count += 1;
    }

    /// Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
    public
    constant
    returns (address[])
    {
        return owners;
    }

    /// Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
    public
    constant
    returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
    public
    constant
    returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}