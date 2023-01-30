// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
    * @dev Returns the address of the pending owner.
    */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Throws if called by any account other than the pending owner.
    */
    modifier onlyPendingOwner() {
        require(pendingOwner() == _msgSender(), "Ownable: caller is not the pending owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _pendingOwner = newOwner;
    }

    function claimOwnership() external onlyPendingOwner {
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit OwnershipTransferred(_owner, _pendingOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./access/Ownable.sol";

contract TokenManager is Ownable {
    event TokenAdded(address indexed _tokenAddress);
    event TokenRemoved(address indexed _tokenAddress);

    struct Token {
        address tokenAddress;
        string name;
        string symbol;
        uint256 decimals;
        address usdPriceContract;
        bool isStable;
    }

    address[] public tokenAddresses;
    mapping(address => Token) public tokens;

    function addToken(
        address _tokenAddress,
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        address _usdPriceContract,
        bool _isStable
    ) public onlyOwner {
        (bool found,) = indexOfToken(_tokenAddress);
        require(!found, 'Token already added');
        tokens[_tokenAddress] = Token(_tokenAddress, _name, _symbol, _decimals, _usdPriceContract, _isStable);
        tokenAddresses.push(_tokenAddress);
        emit TokenAdded(_tokenAddress);
    }

    function removeToken(
        address _tokenAddress
    ) public onlyOwner {
        (bool found, uint256 index) = indexOfToken(_tokenAddress);
        require(found, 'Erc20 token not found');
        if (tokenAddresses.length > 1) {
            tokenAddresses[index] = tokenAddresses[tokenAddresses.length - 1];
        }
        tokenAddresses.pop();
        delete tokens[_tokenAddress];
        emit TokenRemoved(_tokenAddress);
    }

    function indexOfToken(address _address) public view returns (bool found, uint256 index) {
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            if (tokenAddresses[i] == _address) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function getListTokenAddresses() public view returns (address[] memory)
    {
        return tokenAddresses;
    }

    function getLengthTokenAddresses() public view returns (uint256)
    {
        return tokenAddresses.length;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/AggregatorV3Interface.sol";
import "./utils/ECDSA.sol";
import './access/Ownable.sol';
import './utils/SafeERC20.sol';
import './interfaces/IERC20.sol';
import './interfaces/IWETH.sol';
import "./TokenManager.sol";

contract LaborXContract is Ownable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    enum State {NULL, CREATED, BLOCKED, PAYED_TO_FREELANCER, RETURNED_FUNDS_TO_CUSTOMER, DISTRIBUTED_FUNDS_BY_ARBITER}

    event ContractCreated(bytes32 indexed contractId, address token, uint256 amount, address disputer, uint256 deadline);
    event ContractBlocked(bytes32 indexed contractId);
    event PayedToFreelancer(bytes32 indexed contractId, uint256 freelancerFee, uint256 freelancerAmount);
    event RefundedToCustomer(bytes32 indexed contractId, uint256 customerPayAmount);
    event DistributedForPartials(bytes32 indexed contractId, uint256 freelancerFee, uint256 customerPayAmount, uint256 freelancerPayAmount);
    event ServiceFeesChanged(uint256 customerFee, uint256 freelancerFee);

    uint256 public constant FEE_PRECISION = 1000;

    bool private initialized;
    uint256 public customerFee = 0;
    uint256 public freelancerFee = 100;
    uint256 public extraDuration = 172800;
    uint256 public precision = 10000000000;
    uint256 public priceOutdateDelay = 14400;
    uint256 public priceOutdateDelayStable = 172800;
    bool public convertAvailable = true;

    address public weth;
    address public tokenManager;
    address public serviceFeesRecipient;
    address public disputer;

    struct Contract {
        bytes32 contractId;
        address customer;
        address freelancer;
        address disputer;
        address token;
        uint256 amount;
        uint256 customerFee;
        uint256 deadline;
        uint256 percentToBaseConvert;
        State state;
    }

    struct ServiceFeeAccum {
        address token;
        uint256 amount;
    }

    mapping(bytes32 => Contract) public contracts;
    mapping(address => uint256) public serviceFeesAccum;

    function init(address _weth, address _tokenManager, address _disputer, address _serviceFeesRecipient) external onlyOwner {
        require(!initialized, "Initialized");
        weth = _weth;
        tokenManager = _tokenManager;
        disputer = _disputer;
        serviceFeesRecipient = _serviceFeesRecipient;
        initialized = true;
    }

    function createContract(
        bytes32 _contractId,
        address _freelancer,
        address _disputer,
        address _token,
        uint256 _amount,
        uint64 _duration,
        uint256 _percentToBaseConvert
    ) external payable {
        require(contracts[_contractId].state == State.NULL, "Contract already exist");
        (bool found,) = TokenManager(tokenManager).indexOfToken(_token);
        require(found, "Only allowed currency");
        require((_percentToBaseConvert >= 0 && _percentToBaseConvert <= 1000), "Percent to base convert goes beyond the limits from 0 to 1000");
        require(_duration > 0, "Duration must be greater than zero");
        uint256 _deadline = _duration + block.timestamp;
        uint256 feeAmount = customerFee * _amount / FEE_PRECISION;
        uint256 amountWithFee = _amount + feeAmount;
        if (_token == weth) {
            require(msg.value == amountWithFee, 'Incorrect passed msg.value');
            IWETH(weth).deposit{value : amountWithFee}();
        } else {
            IERC20(_token).safeTransferFrom(_msgSender(), address(this), amountWithFee);
        }
        Contract storage jobContract = contracts[_contractId];
        jobContract.state = State.CREATED;
        jobContract.customer = _msgSender();
        jobContract.freelancer = _freelancer;
        if (_disputer != address(0)) jobContract.disputer = _disputer;
        jobContract.token = _token;
        jobContract.amount = _amount;
        if (customerFee != 0) jobContract.customerFee = customerFee;
        jobContract.deadline = _deadline;
        if (_percentToBaseConvert != 0) jobContract.percentToBaseConvert = _percentToBaseConvert;
        emit ContractCreated(_contractId, _token, _amount, _disputer, _deadline);
    }

    function blockContract(bytes32 _contractId) external onlyCreatedState(_contractId) {
        require(
            ((contracts[_contractId].disputer == address(0) && _msgSender() == disputer) || _msgSender() == contracts[_contractId].disputer) ||
            _msgSender() == contracts[_contractId].freelancer,
            "Only disputer or freelancer can block contract"
        );
        contracts[_contractId].state = State.BLOCKED;
        emit ContractBlocked(_contractId);
    }

    function payToFreelancer(
        bytes32 _contractId
    ) external onlyCustomer(_contractId) onlyCreatedState(_contractId) {
        uint256 freelancerFeeAmount = freelancerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 freelancerAmount = contracts[_contractId].amount - freelancerFeeAmount;
        contracts[_contractId].state = State.PAYED_TO_FREELANCER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(freelancerAmount);
            payable(contracts[_contractId].freelancer).transfer(freelancerAmount);
        } else {
            if (contracts[_contractId].percentToBaseConvert > 0) {
                uint256 freelancerAmountToBase = freelancerAmount * contracts[_contractId].percentToBaseConvert / FEE_PRECISION;
                bool success = _payInBase(contracts[_contractId].freelancer, contracts[_contractId].token, freelancerAmountToBase);
                if (success) {
                    IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerAmount - freelancerAmountToBase);
                } else {
                    IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerAmount);
                }
            } else {
                IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerAmount);
            }
        }
        serviceFeesAccum[contracts[_contractId].token] += freelancerFeeAmount + customerFeeAmount;
        emit PayedToFreelancer(_contractId, freelancerFee, freelancerAmount);
    }

    function refundToCustomerByFreelancer(
        bytes32 _contractId
    ) external onlyFreelancer(_contractId) onlyCreatedState(_contractId) {
        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerAmount = contracts[_contractId].amount + customerFeeAmount;
        contracts[_contractId].state = State.RETURNED_FUNDS_TO_CUSTOMER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerAmount);
            payable(contracts[_contractId].customer).transfer(customerAmount);
        } else {
            IERC20(contracts[_contractId].token).safeTransfer(
                contracts[_contractId].customer,
                customerAmount
            );
        }
        emit RefundedToCustomer(_contractId, customerAmount);
    }

    function refundToCustomerByCustomer(
        bytes32 _contractId
    ) external onlyCustomer(_contractId) onlyCreatedState(_contractId) {
        require(contracts[_contractId].deadline + extraDuration < block.timestamp, "You cannot refund the funds, deadline plus extra hours");
        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerAmount = contracts[_contractId].amount + customerFeeAmount;
        contracts[_contractId].state = State.RETURNED_FUNDS_TO_CUSTOMER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerAmount);
            payable(contracts[_contractId].customer).transfer(customerAmount);
        } else {
            IERC20(contracts[_contractId].token).safeTransfer(
                contracts[_contractId].customer,
                customerAmount
            );
        }
        emit RefundedToCustomer(_contractId, customerAmount);
    }

    function refundToCustomerWithFreelancerSignature(
        bytes32 _contractId,
        bytes memory signature
    ) public onlyCustomer(_contractId) onlyCreatedState(_contractId) {
        address signerAddress = _contractId.toEthSignedMessageHash().recover(signature);
        require(signerAddress == contracts[_contractId].freelancer, "Freelancer signature is incorrect");
        uint256 customerFeeAmount = contracts[_contractId].customerFee * contracts[_contractId].amount / FEE_PRECISION;
        uint256 customerAmount = contracts[_contractId].amount + customerFeeAmount;
        contracts[_contractId].state = State.RETURNED_FUNDS_TO_CUSTOMER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerAmount);
            payable(contracts[_contractId].customer).transfer(customerAmount);
        } else {
            IERC20(contracts[_contractId].token).safeTransfer(
                contracts[_contractId].customer,
                customerAmount
            );
        }
        emit RefundedToCustomer(_contractId, customerAmount);
    }

    function distributionForPartials(
        bytes32 _contractId,
        uint256 _customerAmount
    ) external onlyDisputer(_contractId) onlyBlockedState(_contractId) {
        require(contracts[_contractId].amount >= _customerAmount, "High value of the customer amount");
        uint256 customerBeginFee = contracts[_contractId].amount * contracts[_contractId].customerFee / FEE_PRECISION;
        uint256 freelancerAmount = contracts[_contractId].amount - _customerAmount;
        uint256 freelancerFeeAmount = freelancerAmount * freelancerFee / FEE_PRECISION;
        uint256 freelancerPayAmount = freelancerAmount - freelancerFeeAmount;
        uint256 customerFeeAmount = freelancerAmount * precision * customerBeginFee / contracts[_contractId].amount / precision;
        uint256 customerPayAmount = _customerAmount + (customerBeginFee - customerFeeAmount);
        contracts[_contractId].state = State.DISTRIBUTED_FUNDS_BY_ARBITER;
        if (contracts[_contractId].token == weth) {
            IWETH(weth).withdraw(customerPayAmount + freelancerPayAmount);
            if (customerPayAmount != 0) {
                payable(contracts[_contractId].customer).transfer(customerPayAmount);
            }
            if (freelancerPayAmount != 0) {
                payable(contracts[_contractId].freelancer).transfer(freelancerPayAmount);
            }
        } else {
            if (customerPayAmount != 0) {
                IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].customer, customerPayAmount);
            }
            if (freelancerPayAmount != 0) {
                IERC20(contracts[_contractId].token).safeTransfer(contracts[_contractId].freelancer, freelancerPayAmount);
            }
        }
        serviceFeesAccum[contracts[_contractId].token] += customerFeeAmount + freelancerFeeAmount;
        emit DistributedForPartials(_contractId, freelancerFee, customerPayAmount, freelancerPayAmount);
    }

    function withdrawServiceFee(address token) external onlyServiceFeesRecipient {
        require(serviceFeesRecipient != address(0), "Not specified service fee address");
        require(serviceFeesAccum[token] > 0, "You have no accumulated commissions");
        uint256 amount = serviceFeesAccum[token];
        serviceFeesAccum[token] = 0;
        if (token == weth) {
            IWETH(weth).withdraw(amount);
            payable(serviceFeesRecipient).transfer(amount);
        } else {
            IERC20(token).safeTransfer(serviceFeesRecipient, amount);
        }
    }

    function withdrawServiceFees() external onlyServiceFeesRecipient {
        address[] memory addresses = TokenManager(tokenManager).getListTokenAddresses();
        for (uint256 i = 0; i < addresses.length; i++) {
            if (serviceFeesAccum[addresses[i]] > 0) {
                uint256 amount = serviceFeesAccum[addresses[i]];
                serviceFeesAccum[addresses[i]] = 0;
                if (addresses[i] == weth) {
                    IWETH(weth).withdraw(amount);
                    payable(serviceFeesRecipient).transfer(amount);
                } else {
                    IERC20(addresses[i]).safeTransfer(serviceFeesRecipient, amount);
                }
            }
        }
    }

    function checkAbilityConvertToBase(address fromToken, uint256 amount) public view returns (bool success, uint256 amountInBase) {
        if (!convertAvailable) return (false, 0);
        if (address(0) == weth) return (false, 1);
        if (fromToken == weth) return (false, 2);
        (bool found,) = TokenManager(tokenManager).indexOfToken(weth);
        if (!found) return (false, 3);
        (,,,,address priceContractToUSD, bool isStable) = TokenManager(tokenManager).tokens(fromToken);
        if (priceContractToUSD == address(0)) return (false, 4);
        (,int256 answerToUSD,,uint256 updatedAtToUSD,) = AggregatorV3Interface(priceContractToUSD).latestRoundData();
        if ((updatedAtToUSD + (isStable ? priceOutdateDelayStable : priceOutdateDelay )) < block.timestamp) return (false, 5);
        if (answerToUSD <= 0) return (false, 6);
        (,,,,address priceContractToBase,) = TokenManager(tokenManager).tokens(weth);
        (,int256 answerToBase,,uint256 updatedAtToBase,) = AggregatorV3Interface(priceContractToBase).latestRoundData();
        if ((updatedAtToBase + priceOutdateDelay) < block.timestamp) return (false, 7);
        if (answerToBase <= 0) return (false, 8);
        uint256 amountInUSD = amount * uint(answerToUSD) / (10 ** AggregatorV3Interface(priceContractToUSD).decimals());
        amountInBase = amountInUSD * (10 ** 18) / uint(answerToBase);
        if (amountInBase > serviceFeesAccum[weth]) return (false, 9);
        return (true, amountInBase);
    }

    function addToServiceFeeAccumBase() external payable onlyServiceFeesRecipient {
        IWETH(weth).deposit{value : msg.value}();
        serviceFeesAccum[weth] += msg.value;
    }

    function setPrecision(uint256 _precision) external onlyOwner {
        precision = _precision;
    }

    function setServiceFeesRecipient(address _address) external onlyOwner {
        serviceFeesRecipient = _address;
    }

    function setDisputer(address _address) external onlyOwner {
        disputer = _address;
    }

    function setTokenManager(address _address) external onlyOwner {
        tokenManager = _address;
    }

    function setServiceFees(uint256 _customerFee, uint256 _freelancerFee) external onlyOwner {
        customerFee = _customerFee;
        freelancerFee = _freelancerFee;
        emit ServiceFeesChanged(customerFee, freelancerFee);
    }

    function setExtraDuration(uint256 _extraDuration) external onlyOwner {
        extraDuration = _extraDuration;
    }

    function setPriceOutdateDelay(uint256 _priceOutdateDelay, uint256 _priceOutdateDelayStable) external onlyOwner {
        priceOutdateDelay = _priceOutdateDelay;
        priceOutdateDelayStable = _priceOutdateDelayStable;
    }

    function setConvertAvailable(bool _convertAvailable) external onlyOwner {
        convertAvailable = _convertAvailable;
    }

    function _payInBase(address to, address fromToken, uint256 amount) internal returns (bool) {
        (bool success, uint256 amountInBase) = checkAbilityConvertToBase(fromToken, amount);
        if (!success) return false;
        IWETH(weth).withdraw(amountInBase);
        payable(to).transfer(amountInBase);
        serviceFeesAccum[weth] -= amountInBase;
        serviceFeesAccum[fromToken] += amount;
        return true;
    }

    receive() external payable {
        assert(msg.sender == weth);
    }

    // -------- Getters ----------
    function getAccumulatedFees() public view returns (ServiceFeeAccum[] memory _fees) {
        uint256 length = TokenManager(tokenManager).getLengthTokenAddresses();
        ServiceFeeAccum[] memory fees = new ServiceFeeAccum[](length);
        for (uint256 i = 0; i < length; i++) {
            address token = TokenManager(tokenManager).tokenAddresses(i);
            fees[i].token = token;
            fees[i].amount = serviceFeesAccum[token];
        }
        return fees;
    }

    function getServiceFees() public view returns (uint256 _customerFee, uint256 _freelancerFee) {
        _customerFee = customerFee;
        _freelancerFee = freelancerFee;
    }

    // -------- Modifiers ----------
    modifier onlyCreatedState (bytes32 _contractId) {
        require(contracts[_contractId].state == State.CREATED, "Contract allowed only created state");
        _;
    }

    modifier onlyBlockedState (bytes32 _contractId) {
        require(contracts[_contractId].state == State.BLOCKED, "Contract allowed only blocked state");
        _;
    }

    modifier onlyServiceFeesRecipient () {
        require(_msgSender() == serviceFeesRecipient, "Only service fees recipient can call this function");
        _;
    }

    modifier onlyFreelancer (bytes32 _contractId) {
        require(_msgSender() == contracts[_contractId].freelancer, "Only freelancer can call this function");
        _;
    }

    modifier onlyCustomer (bytes32 _contractId) {
        require(_msgSender() == contracts[_contractId].customer, "Only customer can call this function");
        _;
    }

    modifier onlyTxSender (bytes32 _contractId) {
        require(msg.sender == tx.origin, "Only tx sender can call this function");
        _;
    }

    modifier onlyDisputer (bytes32 _contractId) {
        require((contracts[_contractId].disputer == address(0) && _msgSender() == disputer) || _msgSender() == contracts[_contractId].disputer, "Only disputer can call this function");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

    function decimals()
    external
    view
    returns (
        uint8
    );

    function description()
    external
    view
    returns (
        string memory
    );

    function version()
    external
    view
    returns (
        uint256
    );

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(
        uint80 _roundId
    )
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );

    function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
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
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "./Address.sol";

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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
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
if (returndata.length > 0) {// Return data is optional
// solhint-disable-next-line max-line-length
require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
}
}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint wad) external;
    function balanceOf(address user) external returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IUniRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Factory {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function getPair(IERC20 tokenA, IERC20 tokenB)
        external
        view
        returns (IUniswapV2Exchange pair);
}

interface IUniswapV2Exchange {
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function transfer(address to, uint256 value) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./utils/Context.sol";

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
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 public decimals;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

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
    function mint(address account, uint256 amount) external virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
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
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

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
}

{
  "optimizer": {
    "enabled": true,
    "runs": 1000
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "metadata": {
    "useLiteralContent": true
  }
}