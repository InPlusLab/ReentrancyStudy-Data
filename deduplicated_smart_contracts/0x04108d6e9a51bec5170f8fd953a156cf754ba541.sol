// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.7.6;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {TransferHelper} from "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import {Powered} from "./Powered.sol";

interface IRewardPool {
    function sendERC20(
        address token,
        address to,
        uint256 value
    ) external;

    function rescueERC20(address[] calldata tokens, address recipient) external;
}

/// @title Reward Pool
/// @notice Vault for isolated storage of reward tokens
contract RewardPool is IRewardPool, Powered, Ownable {
    /* initializer */

    constructor(address powerSwitch) {
        Powered._setPowerSwitch(powerSwitch);
    }

    /* user functions */

    /// @notice Send an ERC20 token
    /// access control: only owner
    /// state machine:
    ///   - can be called multiple times
    ///   - only online
    /// state scope: none
    /// token transfer: transfer tokens from self to recipient
    /// @param token address The token to send
    /// @param to address The recipient to send to
    /// @param value uint256 Amount of tokens to send
    function sendERC20(
        address token,
        address to,
        uint256 value
    ) external override onlyOwner onlyOnline {
        TransferHelper.safeTransfer(token, to, value);
    }

    /* emergency functions */

    /// @notice Rescue multiple ERC20 tokens
    /// access control: only power controller
    /// state machine:
    ///   - can be called multiple times
    ///   - only shutdown
    /// state scope: none
    /// token transfer: transfer tokens from self to recipient
    /// @param tokens address[] The tokens to rescue
    /// @param recipient address The recipient to rescue to
    function rescueERC20(address[] calldata tokens, address recipient)
        external
        override
        onlyShutdown
    {
        // only callable by controller
        require(
            msg.sender == Powered.getPowerController(),
            "RewardPool: only controller can withdraw after shutdown"
        );

        // assert recipient is defined
        require(recipient != address(0), "RewardPool: recipient not defined");

        // transfer tokens
        for (uint256 index = 0; index < tokens.length; index++) {
            // get token
            address token = tokens[index];
            // get balance
            uint256 balance = IERC20(token).balanceOf(address(this));
            // transfer token
            TransferHelper.safeTransfer(token, recipient, balance);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.7.6;

import {IPowerSwitch} from "./PowerSwitch.sol";

interface IPowered {
    function isOnline() external view returns (bool status);

    function isOffline() external view returns (bool status);

    function isShutdown() external view returns (bool status);

    function getPowerSwitch() external view returns (address powerSwitch);

    function getPowerController() external view returns (address controller);
}

/// @title Powered
/// @notice Helper for calling external PowerSwitch
contract Powered is IPowered {
    /* storage */

    address private _powerSwitch;

    /* modifiers */

    modifier onlyOnline() {
        _onlyOnline();
        _;
    }

    modifier onlyOffline() {
        _onlyOffline();
        _;
    }

    modifier notShutdown() {
        _notShutdown();
        _;
    }

    modifier onlyShutdown() {
        _onlyShutdown();
        _;
    }

    /* initializer */

    function _setPowerSwitch(address powerSwitch) internal {
        _powerSwitch = powerSwitch;
    }

    /* getter functions */

    function isOnline() public view override returns (bool status) {
        return IPowerSwitch(_powerSwitch).isOnline();
    }

    function isOffline() public view override returns (bool status) {
        return IPowerSwitch(_powerSwitch).isOffline();
    }

    function isShutdown() public view override returns (bool status) {
        return IPowerSwitch(_powerSwitch).isShutdown();
    }

    function getPowerSwitch() public view override returns (address powerSwitch) {
        return _powerSwitch;
    }

    function getPowerController() public view override returns (address controller) {
        return IPowerSwitch(_powerSwitch).getPowerController();
    }

    /* convenience functions */

    function _onlyOnline() private view {
        require(isOnline(), "Powered: is not online");
    }

    function _onlyOffline() private view {
        require(isOffline(), "Powered: is not offline");
    }

    function _notShutdown() private view {
        require(!isShutdown(), "Powered: is shutdown");
    }

    function _onlyShutdown() private view {
        require(isShutdown(), "Powered: is not shutdown");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.7.6;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IPowerSwitch {
    /* admin events */

    event PowerOn();
    event PowerOff();
    event EmergencyShutdown();

    /* data types */

    enum State {Online, Offline, Shutdown}

    /* admin functions */

    function powerOn() external;

    function powerOff() external;

    function emergencyShutdown() external;

    /* view functions */

    function isOnline() external view returns (bool status);

    function isOffline() external view returns (bool status);

    function isShutdown() external view returns (bool status);

    function getStatus() external view returns (State status);

    function getPowerController() external view returns (address controller);
}

/// @title PowerSwitch
/// @notice Standalone pausing and emergency stop functionality
contract PowerSwitch is IPowerSwitch, Ownable {
    /* storage */

    IPowerSwitch.State private _status;

    /* initializer */

    constructor(address owner) {
        // sanity check owner
        require(owner != address(0), "PowerSwitch: invalid owner");
        // transfer ownership
        Ownable.transferOwnership(owner);
    }

    /* admin functions */

    /// @notice Turn Power On
    /// access control: only admin
    /// state machine: only when offline
    /// state scope: only modify _status
    /// token transfer: none
    function powerOn() external override onlyOwner {
        require(_status == IPowerSwitch.State.Offline, "PowerSwitch: cannot power on");
        _status = IPowerSwitch.State.Online;
        emit PowerOn();
    }

    /// @notice Turn Power Off
    /// access control: only admin
    /// state machine: only when online
    /// state scope: only modify _status
    /// token transfer: none
    function powerOff() external override onlyOwner {
        require(_status == IPowerSwitch.State.Online, "PowerSwitch: cannot power off");
        _status = IPowerSwitch.State.Offline;
        emit PowerOff();
    }

    /// @notice Shutdown Permanently
    /// access control: only admin
    /// state machine:
    /// - when online or offline
    /// - can only be called once
    /// state scope: only modify _status
    /// token transfer: none
    function emergencyShutdown() external override onlyOwner {
        require(_status != IPowerSwitch.State.Shutdown, "PowerSwitch: cannot shutdown");
        _status = IPowerSwitch.State.Shutdown;
        emit EmergencyShutdown();
    }

    /* getter functions */

    function isOnline() external view override returns (bool status) {
        return _status == State.Online;
    }

    function isOffline() external view override returns (bool status) {
        return _status == State.Offline;
    }

    function isShutdown() external view override returns (bool status) {
        return _status == State.Shutdown;
    }

    function getStatus() external view override returns (IPowerSwitch.State status) {
        return _status;
    }

    function getPowerController() external view override returns (address controller) {
        return Ownable.owner();
    }
}