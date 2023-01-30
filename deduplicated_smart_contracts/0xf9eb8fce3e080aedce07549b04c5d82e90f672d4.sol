/**

 *Submitted for verification at Etherscan.io on 2018-11-02

*/



pragma solidity 0.4.25;





contract MultiSigWallet {                                                       //Multisignature wallet - Based on GNOSIS mock,

                                                                                //without any replaced functionality  &/or significant changes

                                                                                //Reference link: https://github.com/Gnosis/MultiSigWallet

    event Confirmation(address indexed sender, uint indexed transactionId);     //MSWFactory mock:

    event Revocation(address indexed sender, uint indexed transactionId);       //https://etherscan.io/address/0x6e95c8e8557abc08b46f3c347ba06f8dc012763f

    event Submission(uint indexed transactionId);                               //Allows multiple parties to agree on transactions before execution

    event Execution(uint indexed transactionId);                                //Stefan George - <[email protected]> @Georgi87

    event ExecutionFailure(uint indexed transactionId);

    event Deposit(address indexed sender, uint value);

    event OwnerAddition(address indexed owner);

    event OwnerRemoval(address indexed owner);

    event RequirementChange(uint required);





    uint public MAX_OWNER_COUNT = 50;





    mapping (uint => Transaction) public transactions;

    mapping (uint => mapping (address => bool)) public confirmations;

    mapping (address => bool) public isOwner;

    address[] public owners;

    uint public required;

    uint public transactionCount;



    struct Transaction {

        address destination;

        uint value;

        bytes data;

        bool executed;

    }





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



    modifier validRequirement(uint ownerCount, uint _required) {

        require(ownerCount <= MAX_OWNER_COUNT

            && _required <= ownerCount

            && _required != 0

            && ownerCount != 0);

        _;

    }



    function()

        payable

        external

    {

        if (msg.value > 0)

            emit Deposit(msg.sender, msg.value);

    }





    constructor(address[3] _owners, uint _required)

        public

        validRequirement(_owners.length, _required)

    {

        for (uint i=0; i<_owners.length; i++) {

            require(!isOwner[_owners[i]] && _owners[i] != 0);

            isOwner[_owners[i]] = true;

        }

        owners = _owners;

        required = _required;

    }



    function addOwner(address owner)

        onlyWallet

        ownerDoesNotExist(owner)

        notNull(owner)

        validRequirement(owners.length + 1, required)

        public

    {

        isOwner[owner] = true;

        owners.push(owner);

        emit OwnerAddition(owner);

    }



    function removeOwner(address owner)

        onlyWallet

        ownerExists(owner)

        public

    {

        isOwner[owner] = false;

        for (uint i=0; i<owners.length - 1; i++)

            if (owners[i] == owner) {

                owners[i] = owners[owners.length - 1];

                break;

            }

        owners.length -= 1;

        if (required > owners.length)

            changeRequirement(owners.length);

        emit OwnerRemoval(owner);

    }



    function replaceOwner(address owner, address newOwner)

        onlyWallet

        ownerExists(owner)

        ownerDoesNotExist(newOwner)

        public

    {

        for (uint i=0; i<owners.length; i++)

            if (owners[i] == owner) {

                owners[i] = newOwner;

                break;

            }

        isOwner[owner] = false;

        isOwner[newOwner] = true;

        emit OwnerRemoval(owner);

        emit OwnerAddition(newOwner);

    }





    function changeRequirement(uint _required)

        onlyWallet

        validRequirement(owners.length, _required)

        public

    {

        required = _required;

        emit RequirementChange(_required);

    }





    function submitTransaction(address destination, uint value, bytes data)

        public

        returns (uint transactionId)

    {

        transactionId = addTransaction(destination, value, data);

        confirmTransaction(transactionId);

    }





    function confirmTransaction(uint transactionId)

        ownerExists(msg.sender)

        transactionExists(transactionId)

        notConfirmed(transactionId, msg.sender)

        public

    {

        confirmations[transactionId][msg.sender] = true;

        emit Confirmation(msg.sender, transactionId);

        executeTransaction(transactionId);

    }





    function revokeConfirmation(uint transactionId)

        ownerExists(msg.sender)

        confirmed(transactionId, msg.sender)

        notExecuted(transactionId)

        public

    {

        confirmations[transactionId][msg.sender] = false;

        emit Revocation(msg.sender, transactionId);

    }





    function executeTransaction(uint transactionId)

        ownerExists(msg.sender)

        confirmed(transactionId, msg.sender)

        notExecuted(transactionId)

        public

    {

        if (isConfirmed(transactionId)) {

            Transaction storage txn = transactions[transactionId];

            txn.executed = true;

            if (txn.destination.call.value(txn.value)(txn.data))

                emit Execution(transactionId);

            else {

                emit ExecutionFailure(transactionId);

                txn.executed = false;

            }

        }

    }





    function isConfirmed(uint transactionId)

        view

        public

        returns (bool)

    {

        uint count = 0;

        for (uint i=0; i<owners.length; i++) {

            if (confirmations[transactionId][owners[i]])

                count += 1;

            if (count == required)

                return true;

        }

    }





    function addTransaction(address destination, uint value, bytes data)

        notNull(destination)

        internal

        returns (uint transactionId)

    {

        transactionId = transactionCount;

        transactions[transactionId] = Transaction({

            destination: destination,

            value: value,

            data: data,

            executed: false

        });

        transactionCount += 1;

        emit Submission(transactionId);

    }





    function getConfirmationCount(uint transactionId)

        view

        public

        returns (uint count)

    {

        for (uint i=0; i<owners.length; i++)

            if (confirmations[transactionId][owners[i]])

                count += 1;

    }





    function getTransactionCount(bool pending, bool executed)

        view

        public

        returns (uint count)

    {

        for (uint i=0; i<transactionCount; i++)

            if (   pending && !transactions[i].executed

                || executed && transactions[i].executed)

                count += 1;

    }





    function getOwners()

        view

        public

        returns (address[])

    {

        return owners;

    }





    function getConfirmations(uint transactionId)

        view

        public

        returns (address[] _confirmations)

    {

        address[] memory confirmationsTemp = new address[](owners.length);

        uint count = 0;

        uint i;

        for (i=0; i<owners.length; i++)

            if (confirmations[transactionId][owners[i]]) {

                confirmationsTemp[count] = owners[i];

                count += 1;

            }

        _confirmations = new address[](count);

        for (i=0; i<count; i++)

            _confirmations[i] = confirmationsTemp[i];

    }





    function getTransactionIds(uint from, uint to, bool pending, bool executed)

        view

        public

        returns (uint[] _transactionIds)

    {

        uint[] memory transactionIdsTemp = new uint[](transactionCount);

        uint count = 0;

        uint i;

        for (i=0; i<transactionCount; i++)

            if (   pending && !transactions[i].executed

                || executed && transactions[i].executed)

            {

                transactionIdsTemp[count] = i;

                count += 1;

            }

        _transactionIds = new uint[](to - from);

        for (i=from; i<to; i++)

            _transactionIds[i - from] = transactionIdsTemp[i];

    }



}





contract MSigWalletWithDL is MultiSigWallet {





    event DailyLimitChange(uint dailyLimit);





    uint public dailyLimit;

    uint public lastDay;

    uint public spentToday;





    constructor()

        public

        MultiSigWallet(

            [

            0x1b2EEF435649Bb4Ac1a56325580942991D1B086B,

            0xc5E74DE4b7213bdAd3C45C15A2064d810bD7966a,

            0x0C3aEe3D2D7Cd108d1bd8C88299f6F1b32e09Cd7

            ], 

            3

            )

    {

        dailyLimit = 0;

    }





    function changeDailyLimit(uint _dailyLimit)

        onlyWallet

        public

    {

        dailyLimit = _dailyLimit;

        emit DailyLimitChange(_dailyLimit);

    }





    function executeTransaction(uint transactionId)

        ownerExists(msg.sender)

        confirmed(transactionId, msg.sender)

        notExecuted(transactionId)

        public

    {

        Transaction storage txn = transactions[transactionId];

        bool _confirmed = isConfirmed(transactionId);

        if (_confirmed || txn.data.length == 0 && isUnderLimit(txn.value)) {

            txn.executed = true;

            if (!_confirmed)

                spentToday += txn.value;

            if (txn.destination.call.value(txn.value)(txn.data))

                emit Execution(transactionId);

            else {

                emit ExecutionFailure(transactionId);

                txn.executed = false;

                if (!_confirmed)

                    spentToday -= txn.value;

            }

        }

    }





    function isUnderLimit(uint amount)

        internal

        returns (bool)

    {

        if (now > lastDay + 24 hours) {

            lastDay = now;

            spentToday = 0;

        }

        if (spentToday + amount > dailyLimit || spentToday + amount < spentToday)

            return false;

        return true;

    }





    function calcMaxWithdraw()

        view

        public

        returns (uint)

    {

        if (now > lastDay + 24 hours)

            return dailyLimit;

        if (dailyLimit < spentToday)

            return 0;

        return dailyLimit - spentToday;

    }



}