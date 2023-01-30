// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./@openzeppelin/contracts/access/Ownable.sol";
import "./ILimiter.sol";

contract LimiterDaily is ILimiter, Ownable {
    // IBridge address => timestamp (day) => usage
    mapping (address => mapping (uint256 => uint256)) private _usages;
    mapping (address => uint256) private _limiter;

    uint256 constant private TIME_BLOCK = 86400;

    // limit = 0 is unlimited
    function setLimit(address bridge, uint256 limit) external onlyOwner {
        _limiter[bridge] = limit;
    }

    function getLimit(address bridge) override public view returns (uint256) {
        return _limiter[bridge];
    }

    function getUsage(address bridge) override public view returns (uint256) {
        uint256 ts = block.timestamp / TIME_BLOCK;
        uint256 usage = _usages[bridge][ts];
        return usage;
    }

    function isLimited(address bridge, uint256 amount) override public view returns (bool) {
        if (_limiter[bridge] == 0) {
            return false;
        }

        return getUsage(bridge) + amount > getLimit(bridge);
    }

    function increaseUsage(uint256 amount) override external {
        address bridge = _msgSender();

        // this prevent unknown contract to change usage value
        if (_limiter[bridge] == 0) {
            return;
        }

        uint256 ts = block.timestamp / TIME_BLOCK;
        _usages[bridge][ts] += amount;
        require(_usages[bridge][ts] <= _limiter[bridge], "LimiterDaily: limit exceeded");
    }
}

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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface ILimiter {
    function getLimit(address bridge) external view returns (uint256);

    function getUsage(address bridge) external view returns (uint256);

    function isLimited(address bridge, uint256 amount) external view returns (bool);

    function increaseUsage(uint256 amount) external;
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
  "libraries": {}
}