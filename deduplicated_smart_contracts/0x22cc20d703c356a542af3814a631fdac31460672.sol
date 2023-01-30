/**
 *Submitted for verification at Etherscan.io on 2020-10-23
*/

// SPDX-License-Identifier: MIT
// COPYRIGHT cVault.finance TEAM
// NO COPY
// COPY = BAD
// This code is provided with no assurances or guarantees of any kind. Use at your own responsibility.
//  _____ ___________ _____   _____ _       _           _     
// /  __ \  _  | ___ \  ___| |  __ \ |     | |         | |    
// | /  \/ | | | |_/ / |__   | |  \/ | ___ | |__   __ _| |___ 
// | |   | | | |    /|  __|  | | __| |/ _ \| '_ \ / _` | / __|
// | \__/\ \_/ / |\ \| |___  | |_\ \ | (_) | |_) | (_| | \__ \
//  \____/\___/\_| \_\____/   \____/_|\___/|_.__/ \__,_|_|___/                                                         
//                                                          
// This contract stores all different CORE contract addreses 
// and is responsible for contract authentification in the CORE smart contract mesh
//
// BBBBBBBBBBBBBBBBBBBBBBBBBBB
// BMB---------------------B B
// BBB---------------------BBB
// BBB---------------------BBB
// BBB------CORE.exe-------BBB
// BBB---------------------BBB
// BBB---------------------BBB
// BBBBBBBBBBBBBBBBBBBBBBBBBBB
// BBBBB++++++++++++++++BBBBBB
// BBBBB++BBBBB+++++++++BBBBBB
// BBBBB++BBBBB+++++++++BBBBBB
// BBBBB++BBBBB+++++++++BBBBBB
// BBBBB++++++++++++++++BBBBBB


// File: @openzeppelin/contracts-ethereum-package/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.6.0;


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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol

pragma solidity ^0.6.0;


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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    uint256[49] private __gap;
}

// File: contracts/v612/COREGlobals.sol

contract COREGlobals is OwnableUpgradeSafe {

    address public CORETokenAddress;
    address public COREGlobalsAddress;
    address public COREDelegatorAddress;
    address public COREVaultAddress;
    address public COREWETHUniPair;
    address public UniswapFactory;
    address public TransferHandler;

    function initialize(address _COREWETHUniPair, address _COREToken, address _COREDelegator, address _COREVault, address _uniFactory, address _transferHandler) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        CORETokenAddress = _COREToken;
        COREGlobalsAddress = address(this);
        COREDelegatorAddress = _COREDelegator;
        COREVaultAddress = _COREVault;
        UniswapFactory = _uniFactory;
        TransferHandler = _transferHandler;
        COREWETHUniPair = _COREWETHUniPair;
    }

    function setCoreToken(address _COREToken) public onlyOwner {
        CORETokenAddress = _COREToken;
    }

    function setCoreDelegator(address _COREDelegator) public onlyOwner {
        COREDelegatorAddress = _COREDelegator;
    }

    function setCoreVaultAddress(address _COREVault) public onlyOwner {
        COREVaultAddress = _COREVault;
    }

    function setTransferHandler(address _transferHandler) public onlyOwner {
        TransferHandler = _transferHandler;
    }

    mapping (address => bool) private delegatorStateChangeApproved;

    function addDelegatorStateChangePermission(address that, bool status) public onlyOwner {
        return _addDelegatorStateChangePermission(that, status);
    }

    function _addDelegatorStateChangePermission(address that, bool status) internal {
        require(isContract(that), "Only contracts");
        delegatorStateChangeApproved[that] = status;
    }

    // Only contracts.
    function isStateChangeApprovedContract(address that)  public view returns (bool) {
        return _isStateChangeApprovedContract(that);
    }

    function _isStateChangeApprovedContract(address that) internal view returns (bool) {
        return delegatorStateChangeApproved[that];
    }

    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}