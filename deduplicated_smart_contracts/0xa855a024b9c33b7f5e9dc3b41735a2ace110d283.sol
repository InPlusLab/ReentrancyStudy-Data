/**
 *Submitted for verification at Etherscan.io on 2020-07-19
*/

// File: contracts/interfaces/IERC20.sol

pragma solidity ^0.5.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    // optional
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/interfaces/IGasToken.sol

pragma solidity ^0.5.0;


contract IGasToken is IERC20 {
    function freeUpTo(uint256 value) external returns (uint256 freed);

    function freeFromUpTo(address from, uint256 value)
        external
        returns (uint256 freed);

    function balanceOf(address who) external view returns (uint256);

    function mint(uint256 value) external;
}

// File: contracts/utils/Context.sol

pragma solidity ^0.5.0;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/utils/Ownable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Protocol.sol

pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

// Deployed to 0xA855A024b9C33B7F5e9dC3B41735a2aCe110D283

contract Protocol is Ownable {
    mapping(address => bool) public allowed;

    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IGasToken public gasToken = IGasToken(
        0x0000000000004946c0e9F43F4Dee607b0eF1fA1c
    );

    modifier authorized {
        require(msg.sender == owner() || allowed[msg.sender], "Unauthorized");
        _;
    }

    function getBalance(address token) public view returns (uint256) {
        if (token == ETH_ADDRESS) return address(this).balance;
        return IERC20(token).balanceOf(address(this));
    }

    function burnGasTokens(uint256 initialGas) internal {
        uint256 tokenToBurn = (21000 +
            initialGas -
            gasleft() +
            16 *
            msg.data.length +
            14154) / 41947;

        if (gasToken.balanceOf(address(this)) >= tokenToBurn)
            gasToken.freeUpTo(tokenToBurn);
    }

    /**
     * @notice Execute a transaction from wallet
     * @dev delegate call to the logic contracts
     */
    function execute(address _target, bytes memory _data) internal {
        require(_target != address(0), "target-invalid");

        assembly {
            let succeeded := delegatecall(
                sub(gas, 5000),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                32
            )
            switch iszero(succeeded)
                case 1 {
                    revert(0, 0)
                }
        }
    }

    /**
     * @notice Execute multiple transactions
     * @dev Will call execute function which handles the auth logic
     */
    function executeMany(
        address[] calldata targets,
        bytes[] calldata datas,
        bool burnCHI
    ) external payable authorized {
        uint256 gasStart = gasleft();

        // Perform Actions
        for (uint256 i = 0; i < targets.length; i++) {
            execute(targets[i], datas[i]);
        }

        if (burnCHI) burnGasTokens(gasStart);
    }

    // ADMIN

    function updateGasToken(address newGasToken) external onlyOwner {
        gasToken = IGasToken(newGasToken);
    }

    function addAuthority(address newAuthority) external onlyOwner {
        allowed[newAuthority] = true;
    }

    function removeAuthority(address authority) external onlyOwner {
        allowed[authority] = false;
    }

    function destroy() external onlyOwner {
        selfdestruct(address(uint160(owner())));
    }

    /**
     * @dev fallback function to receive ETH
     */
    function() external payable {}
}

// E1 => Balance error
// E2 => Invalid params