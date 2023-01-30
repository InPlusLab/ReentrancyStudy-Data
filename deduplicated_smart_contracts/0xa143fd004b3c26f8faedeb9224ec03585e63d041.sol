/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 *
 * In order to transfer ownership, a recipient must be specified, at which point
 * the specified recipient can call `acceptOwnership` and take ownership.
 */
contract TwoStepOwnable {
  address private _owner;

  address private _newPotentialOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initialize contract by setting transaction submitter as initial owner.
   */
  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
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
    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }

  /**
   * @dev Returns true if the caller is the current owner.
   */
  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows a new account (`newOwner`) to accept ownership.
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  /**
   * @dev Cancel a transfer of ownership to a new account.
   * Can only be called by the current owner.
   */
  function cancelOwnershipTransfer() public onlyOwner {
    delete _newPotentialOwner;
  }

  /**
   * @dev Transfers ownership of the contract to the caller.
   * Can only be called by a new potential owner set by the current owner.
   */
  function acceptOwnership() public {
    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }
}

/**
 * @title DharmaSpreadRegistry (prototype, staging)
 * @author 0age
 * @notice The Dharma Spread Registry is an owned contract that holds the spread
 * over Compound cTokens that is applied to the interest earned by a respective
 * Dharma dToken.
 */
contract DharmaSpreadRegistryPrototypeStaging is TwoStepOwnable {
  uint256 internal _daiSpreadPerBlock;
  uint256 internal _usdcSpreadPerBlock;

  /**
   * @notice Set a new spread per block to be applied on top of the cDai supply
   * rate.
   * @param spreadPerBlock uint256 The new Dai spread.
   */
  function setDaiSpreadPerBlock(uint256 spreadPerBlock) external onlyOwner {
    _daiSpreadPerBlock = spreadPerBlock;
  }

  /**
   * @notice Set a new spread per block to be applied on top of the cUSDC supply
   * rate.
   * @param spreadPerBlock uint256 The new USDC spread.
   */
  function setUSDCSpreadPerBlock(uint256 spreadPerBlock) external onlyOwner {
    _usdcSpreadPerBlock = spreadPerBlock;
  }

  /**
   * @notice Get the current spread per block to be applied on top of the cDai
   * supply rate.
   * @return daiSpreadPerBlock uint256 The current Dai spread per block.
   */
  function getDaiSpreadPerBlock() external view returns (uint256 daiSpreadPerBlock) {
    daiSpreadPerBlock = _daiSpreadPerBlock;
  }

  /**
   * @notice Get the current spread per block to be applied on top of the cUSDC
   * supply rate.
   * @return usdcSpreadPerBlock uint256 The current USDC spread per block.
   */
  function getUSDCSpreadPerBlock() external view returns (uint256 usdcSpreadPerBlock) {
    usdcSpreadPerBlock = _usdcSpreadPerBlock;
  }
}