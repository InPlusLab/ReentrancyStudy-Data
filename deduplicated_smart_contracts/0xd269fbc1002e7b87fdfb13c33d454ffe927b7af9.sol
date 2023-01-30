/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

/**
 *Submitted for verification at Etherscan.io on 12-10-2020
*/
/*
    Copyright 2020 Charge Factory.
    SPDX-License-Identifier: Apache-2.0
*/
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

// lib/Ownable.sol
/**
 * @title Ownable
 * @author Charge Breeder
 *
 * @notice Ownership related functions
 */
contract Ownable {
    address public _OWNER_;
    address public _NEW_OWNER_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    constructor() internal {
        _OWNER_ = msg.sender;
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// intf/ICharge.sol
interface ICharge {
    function init(
        address owner,
        address supervisor,
        address maintainer,
        address baseToken,
        address quoteToken,
        address oracle,
        uint256 lpFeeRate,
        uint256 mtFeeRate,
        uint256 k,
        uint256 gasPriceLimit
    ) external;

    function transferOwnership(address newOwner) external;

    function claimOwnership() external;

    function sellBaseToken(
        uint256 amount,
        uint256 minReceiveQuote,
        bytes calldata data
    ) external returns (uint256);

    function buyBaseToken(
        uint256 amount,
        uint256 maxPayQuote,
        bytes calldata data
    ) external returns (uint256);

    function querySellBaseToken(uint256 amount) external view returns (uint256 receiveQuote);

    function queryBuyBaseToken(uint256 amount) external view returns (uint256 payQuote);

    function getExpectedTarget() external view returns (uint256 baseTarget, uint256 quoteTarget);

    function depositBaseTo(address to, uint256 amount) external returns (uint256);

    function withdrawBase(uint256 amount) external returns (uint256);

    function withdrawAllBase() external returns (uint256);

    function depositQuoteTo(address to, uint256 amount) external returns (uint256);

    function withdrawQuote(uint256 amount) external returns (uint256);

    function withdrawAllQuote() external returns (uint256);

    function _BASE_CAPITAL_TOKEN_() external view returns (address);

    function _QUOTE_CAPITAL_TOKEN_() external view returns (address);

    function _BASE_TOKEN_() external returns (address);

    function _QUOTE_TOKEN_() external returns (address);
}

// helper/CloneFactory
interface ICloneFactory {
    function clone(address prototype) external returns (address proxy);
}

// introduction of proxy mode design: https://docs.openzeppelin.com/upgrades/2.8/
// minimum implementation of transparent proxy: https://eips.ethereum.org/EIPS/eip-1167

contract CloneFactory is ICloneFactory {
    function clone(address prototype) external override returns (address proxy) {
        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }
}

// ChargeFactory.sol
/**
 * @title ChargeFactory
 * @author Charge Breeder
 *
 * @notice Register of All Charge
 */
contract ChargeFactory is Ownable {
    address public _Charge_LOGIC_;
    address public _CLONE_FACTORY_;

    address public _DEFAULT_SUPERVISOR_;

    mapping(address => mapping(address => address)) internal _Charge_REGISTER_;
    address[] public _Charges;

    // ============ Events ============

    event ChargeBirth(address newBorn, address baseToken, address quoteToken);

    // ============ Constructor Function ============

    constructor(
        address _ChargeLogic,
        address _cloneFactory,
        address _defaultSupervisor
    ) public {
        _Charge_LOGIC_ = _ChargeLogic;
        _CLONE_FACTORY_ = _cloneFactory;
        _DEFAULT_SUPERVISOR_ = _defaultSupervisor;
    }

    // ============ Admin Function ============

    function setChargeLogic(address _ChargeLogic) external onlyOwner {
        _Charge_LOGIC_ = _ChargeLogic;
    }

    function setCloneFactory(address _cloneFactory) external onlyOwner {
        _CLONE_FACTORY_ = _cloneFactory;
    }

    function setDefaultSupervisor(address _defaultSupervisor) external onlyOwner {
        _DEFAULT_SUPERVISOR_ = _defaultSupervisor;
    }

    function removeCharge(address Charge) external onlyOwner {
        address baseToken = ICharge(Charge)._BASE_TOKEN_();
        address quoteToken = ICharge(Charge)._QUOTE_TOKEN_();
        require(isChargeRegistered(baseToken, quoteToken), "Charge_NOT_REGISTERED");
        _Charge_REGISTER_[baseToken][quoteToken] = address(0);
        for (uint256 i = 0; i <= _Charges.length - 1; i++) {
            if (_Charges[i] == Charge) {
                _Charges[i] = _Charges[_Charges.length - 1];
                _Charges.pop();
                break;
            }
        }
    }

    function addCharge(address Charge) public onlyOwner {
        address baseToken = ICharge(Charge)._BASE_TOKEN_();
        address quoteToken = ICharge(Charge)._QUOTE_TOKEN_();
        require(!isChargeRegistered(baseToken, quoteToken), "Charge_REGISTERED");
        _Charge_REGISTER_[baseToken][quoteToken] = Charge;
        _Charges.push(Charge);
    }

    // ============ Breed Charge Function ============

    function breedCharge(
        address maintainer,
        address baseToken,
        address quoteToken,
        address oracle,
        uint256 lpFeeRate,
        uint256 mtFeeRate,
        uint256 k,
        uint256 gasPriceLimit
    ) external onlyOwner returns (address newBornCharge) {
        require(!isChargeRegistered(baseToken, quoteToken), "Charge_REGISTERED");
        newBornCharge = ICloneFactory(_CLONE_FACTORY_).clone(_Charge_LOGIC_);
        ICharge(newBornCharge).init(
            _OWNER_,
            _DEFAULT_SUPERVISOR_,
            maintainer,
            baseToken,
            quoteToken,
            oracle,
            lpFeeRate,
            mtFeeRate,
            k,
            gasPriceLimit
        );
        addCharge(newBornCharge);
        emit ChargeBirth(newBornCharge, baseToken, quoteToken);
        return newBornCharge;
    }

    // ============ View Functions ============

    function isChargeRegistered(address baseToken, address quoteToken) public view returns (bool) {
        if (
            _Charge_REGISTER_[baseToken][quoteToken] == address(0) &&
            _Charge_REGISTER_[quoteToken][baseToken] == address(0)
        ) {
            return false;
        } else {
            return true;
        }
    }

    function getCharge(address baseToken, address quoteToken) external view returns (address) {
        return _Charge_REGISTER_[baseToken][quoteToken];
    }

    function getCharges() external view returns (address[] memory) {
        return _Charges;
    }
}