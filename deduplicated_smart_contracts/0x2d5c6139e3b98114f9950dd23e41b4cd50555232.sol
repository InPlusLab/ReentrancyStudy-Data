/**
 *Submitted for verification at Etherscan.io on 2019-12-25
*/

// File: contracts/bancorx/interfaces/IBancorXUpgrader.sol

pragma solidity 0.4.26;

/*
    Bancor X Upgrader interface
*/
contract IBancorXUpgrader {
    function upgrade(uint16 _version, address[] _reporters) public;
}

// File: contracts/bancorx/interfaces/IBancorX.sol

pragma solidity 0.4.26;

contract IBancorX {
    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;
    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);
}

// File: contracts/ContractIds.sol

pragma solidity 0.4.26;

/**
  * @dev Id definitions for bancor contracts
  * 
  * Can be used in conjunction with the contract registry to get contract addresses
*/
contract ContractIds {
    // generic
    bytes32 public constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 public constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 public constant NON_STANDARD_TOKEN_REGISTRY = "NonStandardTokenRegistry";

    // bancor logic
    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 public constant BANCOR_FORMULA = "BancorFormula";
    bytes32 public constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 public constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 public constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";

    // BNT core
    bytes32 public constant BNT_TOKEN = "BNTToken";
    bytes32 public constant BNT_CONVERTER = "BNTConverter";

    // BancorX
    bytes32 public constant BANCOR_X = "BancorX";
    bytes32 public constant BANCOR_X_UPGRADER = "BancorXUpgrader";
}

// File: contracts/token/interfaces/IERC20Token.sol

pragma solidity 0.4.26;

/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {this;}
    function symbol() public view returns (string) {this;}
    function decimals() public view returns (uint8) {this;}
    function totalSupply() public view returns (uint256) {this;}
    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}
    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

// File: contracts/utility/interfaces/IOwned.sol

pragma solidity 0.4.26;

/*
    Owned contract interface
*/
contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function owner() public view returns (address) {this;}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

// File: contracts/token/interfaces/ISmartToken.sol

pragma solidity 0.4.26;



/*
    Smart Token interface
*/
contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}

// File: contracts/token/interfaces/ISmartTokenController.sol

pragma solidity 0.4.26;


/*
    Smart Token Controller interface
*/
contract ISmartTokenController {
    function claimTokens(address _from, uint256 _amount) public;
    function token() public view returns (ISmartToken) {this;}
}

// File: contracts/utility/interfaces/IContractRegistry.sol

pragma solidity 0.4.26;

/*
    Contract Registry interface
*/
contract IContractRegistry {
    function addressOf(bytes32 _contractName) public view returns (address);

    // deprecated, backward compatibility
    function getAddress(bytes32 _contractName) public view returns (address);
}

// File: contracts/utility/Owned.sol

pragma solidity 0.4.26;


/**
  * @dev Provides support and utilities for contract ownership
*/
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    /**
      * @dev triggered when the owner is updated
      * 
      * @param _prevOwner previous owner
      * @param _newOwner  new owner
    */
    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
      * @dev initializes a new Owned instance
    */
    constructor() public {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    /**
      * @dev allows transferring the contract ownership
      * the new owner still needs to accept the transfer
      * can only be called by the contract owner
      * 
      * @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
      * @dev used by a new owner to accept an ownership transfer
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function setOwner(address _newOwner) public ownerOnly {
        require(_newOwner != owner && _newOwner != address(0));
        emit OwnerUpdate(owner, _newOwner);
        owner = _newOwner;
        newOwner = address(0);
    }
}

// File: contracts/utility/SafeMath.sol

pragma solidity 0.4.26;

/**
  * @dev Library for basic math operations with overflow/underflow protection
*/
library SafeMath {
    /**
      * @dev returns the sum of _x and _y, reverts if the calculation overflows
      * 
      * @param _x   value 1
      * @param _y   value 2
      * 
      * @return sum
    */
    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        require(z >= _x);
        return z;
    }

    /**
      * @dev returns the difference of _x minus _y, reverts if the calculation underflows
      * 
      * @param _x   minuend
      * @param _y   subtrahend
      * 
      * @return difference
    */
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_x >= _y);
        return _x - _y;
    }

    /**
      * @dev returns the product of multiplying _x by _y, reverts if the calculation overflows
      * 
      * @param _x   factor 1
      * @param _y   factor 2
      * 
      * @return product
    */
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        // gas optimization
        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y);
        return z;
    }

      /**
        * ev Integer division of two numbers truncating the quotient, reverts on division by zero.
        * 
        * aram _x   dividend
        * aram _y   divisor
        * 
        * eturn quotient
    */
    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_y > 0);
        uint256 c = _x / _y;

        return c;
    }
}

// File: contracts/utility/Utils.sol

pragma solidity 0.4.26;

/**
  * @dev Utilities & Common Modifiers
*/
contract Utils {
    /**
      * constructor
    */
    constructor() public {
    }

    // verifies that an amount is greater than zero
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

}

// File: contracts/utility/interfaces/ITokenHolder.sol

pragma solidity 0.4.26;



/*
    Token Holder interface
*/
contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}

// File: contracts/token/interfaces/INonStandardERC20.sol

pragma solidity 0.4.26;

/*
    ERC20 Standard Token interface which doesn't return true/false for transfer, transferFrom and approve
*/
contract INonStandardERC20 {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {this;}
    function symbol() public view returns (string) {this;}
    function decimals() public view returns (uint8) {this;}
    function totalSupply() public view returns (uint256) {this;}
    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}
    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}

    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public;
    function approve(address _spender, uint256 _value) public;
}

// File: contracts/utility/TokenHolder.sol

pragma solidity 0.4.26;






/**
  * @dev We consider every contract to be a 'token holder' since it's currently not possible
  * for a contract to deny receiving tokens.
  * 
  * The TokenHolder's contract sole purpose is to provide a safety mechanism that allows
  * the owner to send tokens that were sent to the contract by mistake back to their sender.
  * 
  * Note that we use the non standard ERC-20 interface which has no return value for transfer
  * in order to support both non standard as well as standard token contracts.
  * see https://github.com/ethereum/solidity/issues/4116
*/
contract TokenHolder is ITokenHolder, Owned, Utils {
    /**
      * @dev initializes a new TokenHolder instance
    */
    constructor() public {
    }

    /**
      * @dev withdraws tokens held by the contract and sends them to an account
      * can only be called by the owner
      * 
      * @param _token   ERC20 token contract address
      * @param _to      account to receive the new amount
      * @param _amount  amount to withdraw
    */
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        INonStandardERC20(_token).transfer(_to, _amount);
    }
}

// File: contracts/bancorx/BancorX.sol

pragma solidity 0.4.26;










/**
  * @dev The BancorX contract allows cross chain token transfers.
  * 
  * There are two processes that take place in the contract -
  * - Initiate a cross chain transfer to a target blockchain (locks tokens from the caller account on Ethereum)
  * - Report a cross chain transfer initiated on a source blockchain (releases tokens to an account on Ethereum)
  * 
  * Reporting cross chain transfers works similar to standard multisig contracts, meaning that multiple
  * callers are required to report a transfer before tokens are released to the target account.
*/
contract BancorX is IBancorX, Owned, TokenHolder, ContractIds {
    using SafeMath for uint256;

    // represents a transaction on another blockchain where tokens were destroyed/locked
    struct Transaction {
        uint256 amount;
        bytes32 fromBlockchain;
        address to;
        uint8 numOfReports;
        bool completed;
    }

    uint16 public version = 3;

    uint256 public maxLockLimit;            // the maximum amount of tokens that can be locked in one transaction
    uint256 public maxReleaseLimit;         // the maximum amount of tokens that can be released in one transaction
    uint256 public minLimit;                // the minimum amount of tokens that can be transferred in one transaction
    uint256 public prevLockLimit;           // the lock limit *after* the last transaction
    uint256 public prevReleaseLimit;        // the release limit *after* the last transaction
    uint256 public limitIncPerBlock;        // how much the limit increases per block
    uint256 public prevLockBlockNumber;     // the block number of the last lock transaction
    uint256 public prevReleaseBlockNumber;  // the block number of the last release transaction
    uint256 public minRequiredReports;      // minimum number of required reports to release tokens
    
    IContractRegistry public registry;      // contract registry
    IContractRegistry public prevRegistry;  // address of previous registry as security mechanism

    IERC20Token public token;               // erc20 token or smart token
    bool public isSmartToken;               // false - erc20 token; true - smart token

    bool public xTransfersEnabled = true;   // true if x transfers are enabled, false if not
    bool public reportingEnabled = true;    // true if reporting is enabled, false if not
    bool public allowRegistryUpdate = true; // allows the owner to prevent/allow the registry to be updated

    // txId -> Transaction
    mapping (uint256 => Transaction) public transactions;

    // xTransferId -> txId
    mapping (uint256 => uint256) public transactionIds;

    // txId -> reporter -> true if reporter already reported txId
    mapping (uint256 => mapping (address => bool)) public reportedTxs;

    // address -> true if address is reporter
    mapping (address => bool) public reporters;

    /**
      * @dev triggered when tokens are locked in smart contract
      * 
      * @param _from    wallet address that the tokens are locked from
      * @param _amount  amount locked
    */
    event TokensLock(
        address indexed _from,
        uint256 _amount
    );

    /**
      * @dev triggered when tokens are released by the smart contract
      * 
      * @param _to      wallet address that the tokens are released to
      * @param _amount  amount released
    */
    event TokensRelease(
        address indexed _to,
        uint256 _amount
    );

    /**
      * @dev triggered when xTransfer is successfully called
      * 
      * @param _from            wallet address that initiated the xtransfer
      * @param _toBlockchain    target blockchain
      * @param _to              target wallet
      * @param _amount          transfer amount
      * @param _id              xtransfer id
    */
    event XTransfer(
        address indexed _from,
        bytes32 _toBlockchain,
        bytes32 indexed _to,
        uint256 _amount,
        uint256 _id
    );

    /**
      * @dev triggered when report is successfully submitted
      * 
      * @param _reporter        reporter wallet
      * @param _fromBlockchain  source blockchain
      * @param _txId            tx id on the source blockchain
      * @param _to              target wallet
      * @param _amount          transfer amount
      * @param _xTransferId     xtransfer id
    */
    event TxReport(
        address indexed _reporter,
        bytes32 _fromBlockchain,
        uint256 _txId,
        address _to,
        uint256 _amount,
        uint256 _xTransferId
    );

    /**
      * @dev triggered when final report is successfully submitted
      * 
      * @param _to  target wallet
      * @param _id  xtransfer id
    */
    event XTransferComplete(
        address _to,
        uint256 _id
    );

    /**
      * @dev initializes a new BancorX instance
      * 
      * @param _maxLockLimit          maximum amount of tokens that can be locked in one transaction
      * @param _maxReleaseLimit       maximum amount of tokens that can be released in one transaction
      * @param _minLimit              minimum amount of tokens that can be transferred in one transaction
      * @param _limitIncPerBlock      how much the limit increases per block
      * @param _minRequiredReports    minimum number of reporters to report transaction before tokens can be released
      * @param _registry              address of contract registry
      * @param _token                 erc20 token or smart token
      * @param _isSmartToken          false - erc20 token; true - smart token
     */
    constructor(
        uint256 _maxLockLimit,
        uint256 _maxReleaseLimit,
        uint256 _minLimit,
        uint256 _limitIncPerBlock,
        uint256 _minRequiredReports,
        address _registry,
        IERC20Token _token,
        bool _isSmartToken
    )
        public
    {
        // the maximum limits, minimum limit, and limit increase per block
        maxLockLimit = _maxLockLimit;
        maxReleaseLimit = _maxReleaseLimit;
        minLimit = _minLimit;
        limitIncPerBlock = _limitIncPerBlock;
        minRequiredReports = _minRequiredReports;

        // previous limit is _maxLimit, and previous block number is current block number
        prevLockLimit = _maxLockLimit;
        prevReleaseLimit = _maxReleaseLimit;
        prevLockBlockNumber = block.number;
        prevReleaseBlockNumber = block.number;

        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);

        token = _token;
        isSmartToken = _isSmartToken;
    }

    // validates that the caller is a reporter
    modifier isReporter {
        require(reporters[msg.sender]);
        _;
    }

    // allows execution only when x transfers are enabled
    modifier whenXTransfersEnabled {
        require(xTransfersEnabled);
        _;
    }

    // allows execution only when reporting is enabled
    modifier whenReportingEnabled {
        require(reportingEnabled);
        _;
    }

    /**
      * @dev setter
      * 
      * @param _maxLockLimit    new maxLockLimit
     */
    function setMaxLockLimit(uint256 _maxLockLimit) public ownerOnly {
        maxLockLimit = _maxLockLimit;
    }
    
    /**
      * @dev setter
      * 
      * @param _maxReleaseLimit    new maxReleaseLimit
     */
    function setMaxReleaseLimit(uint256 _maxReleaseLimit) public ownerOnly {
        maxReleaseLimit = _maxReleaseLimit;
    }
    
    /**
      * @dev setter
      * 
      * @param _minLimit    new minLimit
     */
    function setMinLimit(uint256 _minLimit) public ownerOnly {
        minLimit = _minLimit;
    }

    /**
      * @dev setter
      * 
      * @param _limitIncPerBlock    new limitIncPerBlock
     */
    function setLimitIncPerBlock(uint256 _limitIncPerBlock) public ownerOnly {
        limitIncPerBlock = _limitIncPerBlock;
    }

    /**
      * @dev setter
      * 
      * @param _minRequiredReports    new minRequiredReports
     */
    function setMinRequiredReports(uint256 _minRequiredReports) public ownerOnly {
        minRequiredReports = _minRequiredReports;
    }

    /**
      * @dev allows the owner to set/remove reporters
      * 
      * @param _reporter    reporter whos status is to be set
      * @param _active      true if the reporter is approved, false otherwise
     */
    function setReporter(address _reporter, bool _active) public ownerOnly {
        reporters[_reporter] = _active;
    }

    /**
      * @dev allows the owner enable/disable the xTransfer method
      * 
      * @param _enable     true to enable, false to disable
     */
    function enableXTransfers(bool _enable) public ownerOnly {
        xTransfersEnabled = _enable;
    }

    /**
      * @dev allows the owner enable/disable the reportTransaction method
      * 
      * @param _enable     true to enable, false to disable
     */
    function enableReporting(bool _enable) public ownerOnly {
        reportingEnabled = _enable;
    }

    /**
      * @dev disables the registry update functionality
      * this is a safety mechanism in case of a emergency
      * can only be called by the manager or owner
      * 
      * @param _disable    true to disable registry updates, false to re-enable them
    */
    function disableRegistryUpdate(bool _disable) public ownerOnly {
        allowRegistryUpdate = !_disable;
    }

    /**
      * @dev sets the contract registry to whichever address the current registry is pointing to
     */
    function updateRegistry() public {
        // require that upgrading is allowed or that the caller is the owner
        require(allowRegistryUpdate || msg.sender == owner);

        // get the address of whichever registry the current registry is pointing to
        address newRegistry = registry.addressOf(ContractIds.CONTRACT_REGISTRY);

        // if the new registry hasn't changed or is the zero address, revert
        require(newRegistry != address(registry) && newRegistry != address(0));

        // set the previous registry as current registry and current registry as newRegistry
        prevRegistry = registry;
        registry = IContractRegistry(newRegistry);
    }

    /**
      * @dev security mechanism allowing the converter owner to revert to the previous registry,
      * to be used in emergency scenario
    */
    function restoreRegistry() public ownerOnly {
        // set the registry as previous registry
        registry = prevRegistry;

        // after a previous registry is restored, only the owner can allow future updates
        allowRegistryUpdate = false;
    }

    /**
      * @dev upgrades the contract to the latest version
      * can only be called by the owner
      * note that the owner needs to call acceptOwnership on the new contract after the upgrade
      * 
      * @param _reporters    new list of reporters
    */
    function upgrade(address[] _reporters) public ownerOnly {
        IBancorXUpgrader bancorXUpgrader = IBancorXUpgrader(registry.addressOf(ContractIds.BANCOR_X_UPGRADER));

        transferOwnership(bancorXUpgrader);
        bancorXUpgrader.upgrade(version, _reporters);
        acceptOwnership();
    }

    /**
      * @dev claims tokens from msg.sender to be converted to tokens on another blockchain
      * 
      * @param _toBlockchain    blockchain on which tokens will be issued
      * @param _to              address to send the tokens to
      * @param _amount          the amount of tokens to transfer
     */
    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount) public whenXTransfersEnabled {
        // get the current lock limit
        uint256 currentLockLimit = getCurrentLockLimit();

        // require that; minLimit <= _amount <= currentLockLimit
        require(_amount >= minLimit && _amount <= currentLockLimit);
        
        lockTokens(_amount);

        // set the previous lock limit and block number
        prevLockLimit = currentLockLimit.sub(_amount);
        prevLockBlockNumber = block.number;

        // emit XTransfer event with id of 0
        emit XTransfer(msg.sender, _toBlockchain, _to, _amount, 0);
    }

    /**
      * @dev claims tokens from msg.sender to be converted to tokens on another blockchain
      * 
      * @param _toBlockchain    blockchain on which tokens will be issued
      * @param _to              address to send the tokens to
      * @param _amount          the amount of tokens to transfer
      * @param _id              pre-determined unique (if non zero) id which refers to this transaction 
     */
    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public whenXTransfersEnabled {
        // get the current lock limit
        uint256 currentLockLimit = getCurrentLockLimit();

        // require that; minLimit <= _amount <= currentLockLimit
        require(_amount >= minLimit && _amount <= currentLockLimit);
        
        lockTokens(_amount);

        // set the previous lock limit and block number
        prevLockLimit = currentLockLimit.sub(_amount);
        prevLockBlockNumber = block.number;

        // emit XTransfer event
        emit XTransfer(msg.sender, _toBlockchain, _to, _amount, _id);
    }

    /**
      * @dev allows reporter to report transaction which occured on another blockchain
      * 
      * @param _fromBlockchain  blockchain in which tokens were destroyed
      * @param _txId            transactionId of transaction thats being reported
      * @param _to              address to receive tokens
      * @param _amount          amount of tokens destroyed on another blockchain
      * @param _xTransferId     unique (if non zero) pre-determined id (unlike _txId which is determined after the transactions been mined)
     */
    function reportTx(
        bytes32 _fromBlockchain,
        uint256 _txId,
        address _to,
        uint256 _amount,
        uint256 _xTransferId 
    )
        public
        isReporter
        whenReportingEnabled
    {
        // require that the transaction has not been reported yet by the reporter
        require(!reportedTxs[_txId][msg.sender]);

        // set reported as true
        reportedTxs[_txId][msg.sender] = true;

        Transaction storage txn = transactions[_txId];

        // If the caller is the first reporter, set the transaction details
        if (txn.numOfReports == 0) {
            txn.to = _to;
            txn.amount = _amount;
            txn.fromBlockchain = _fromBlockchain;

            if (_xTransferId != 0) {
                // verify uniqueness of xTransfer id to prevent overwriting
                require(transactionIds[_xTransferId] == 0);
                transactionIds[_xTransferId] = _txId;
            }
        } else {
            // otherwise, verify transaction details
            require(txn.to == _to && txn.amount == _amount && txn.fromBlockchain == _fromBlockchain);
            
            if (_xTransferId != 0) {
                require(transactionIds[_xTransferId] == _txId);
            }
        }
        
        // increment the number of reports
        txn.numOfReports++;

        emit TxReport(msg.sender, _fromBlockchain, _txId, _to, _amount, _xTransferId);

        // if theres enough reports, try to release tokens
        if (txn.numOfReports >= minRequiredReports) {
            require(!transactions[_txId].completed);

            // set the transaction as completed
            transactions[_txId].completed = true;

            emit XTransferComplete(_to, _xTransferId);

            releaseTokens(_to, _amount);
        }
    }

    /**
      * @dev gets x transfer amount by xTransferId (not txId)
      * 
      * @param _xTransferId    unique (if non zero) pre-determined id (unlike _txId which is determined after the transactions been broadcasted)
      * @param _for            address corresponding to xTransferId
      * 
      * @return amount that was sent in xTransfer corresponding to _xTransferId
    */
    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256) {
        // xTransferId -> txId -> Transaction
        Transaction storage transaction = transactions[transactionIds[_xTransferId]];

        // verify that the xTransferId is for _for
        require(transaction.to == _for);

        return transaction.amount;
    }

    /**
      * @dev method for calculating current lock limit
      * 
      * @return the current maximum limit of tokens that can be locked
     */
    function getCurrentLockLimit() public view returns (uint256) {
        // prevLockLimit + ((currBlockNumber - prevLockBlockNumber) * limitIncPerBlock)
        uint256 currentLockLimit = prevLockLimit.add(((block.number).sub(prevLockBlockNumber)).mul(limitIncPerBlock));
        if (currentLockLimit > maxLockLimit)
            return maxLockLimit;
        return currentLockLimit;
    }
 
    /**
      * @dev method for calculating current release limit
      * 
      * @return the current maximum limit of tokens that can be released
     */
    function getCurrentReleaseLimit() public view returns (uint256) {
        // prevReleaseLimit + ((currBlockNumber - prevReleaseBlockNumber) * limitIncPerBlock)
        uint256 currentReleaseLimit = prevReleaseLimit.add(((block.number).sub(prevReleaseBlockNumber)).mul(limitIncPerBlock));
        if (currentReleaseLimit > maxReleaseLimit)
            return maxReleaseLimit;
        return currentReleaseLimit;
    }

    /**
      * @dev claims and locks tokens from msg.sender to be converted to tokens on another blockchain
      * 
      * @param _amount  the amount of tokens to lock
     */
    function lockTokens(uint256 _amount) private {
        if (isSmartToken)
            ISmartTokenController(ISmartToken(token).owner()).claimTokens(msg.sender, _amount);
        else
            token.transferFrom(msg.sender, address(this), _amount);
        emit TokensLock(msg.sender, _amount);
    }

    /**
      * @dev private method to release tokens held by the contract
      * 
      * @param _to      the address to release tokens to
      * @param _amount  the amount of tokens to release
     */
    function releaseTokens(address _to, uint256 _amount) private {
        // get the current release limit
        uint256 currentReleaseLimit = getCurrentReleaseLimit();

        require(_amount >= minLimit && _amount <= currentReleaseLimit);
        
        // update the previous release limit and block number
        prevReleaseLimit = currentReleaseLimit.sub(_amount);
        prevReleaseBlockNumber = block.number;

        // no need to require, reverts on failure
        token.transfer(_to, _amount);

        emit TokensRelease(_to, _amount);
    }
}