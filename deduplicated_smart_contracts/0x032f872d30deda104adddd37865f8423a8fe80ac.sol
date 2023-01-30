// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./ERC20/IERC20.sol";
import "./interfaces/IOracle.sol";
import "./utils/Ownable.sol";

contract TokenCall is Ownable {
    struct TokenData {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 price;
        uint256 balance;
    }

    IOracle public oracle;

    constructor (IOracle _oracle) {
        oracle = _oracle;
    }

    function getToken(IERC20 _asset, address _account) public view returns (TokenData memory) {
        string memory _name = _asset.name();
        string memory _symbol = _asset.symbol();
        uint8 _decimals = _asset.decimals();
        uint256 _totalSupply = _asset.totalSupply();
        uint256 _balance = _asset.balanceOf(_account);
        uint256 _price = oracle.getPriceUSD(address(_asset));
        return TokenData({
            name: _name,
            symbol: _symbol,
            decimals: _decimals,
            totalSupply: _totalSupply,
            price: _price,
            balance: _balance
        });
    }

    function getTokens(IERC20[] calldata _assets, address _account) external view returns (TokenData[] memory data) {
        data = new TokenData[](_assets.length);
        for (uint256 i = 0; i < _assets.length; i++) {
            data[i] = getToken(_assets[i], _account);
        }
    }

    function setOracle(IOracle _oracle) external onlyOwner {
        oracle = _oracle;
    }
}

// SPDX-License-Identifier: No License

pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: No License

pragma solidity ^0.8.0;

interface IOracle {
    function getPriceUSD(address _asset) external view returns (uint256 price);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";
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