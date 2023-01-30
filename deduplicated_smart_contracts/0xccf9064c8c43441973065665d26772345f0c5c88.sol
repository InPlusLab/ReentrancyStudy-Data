/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

pragma solidity 0.5.2;

/***************
**            **
** INTERFACES **
**            **
***************/

/**
 * @title  Interface for Kong ERC20 Token Contract.
 */
interface KongERC20Interface {

  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function mint(uint256 mintedAmount, address recipient) external;
  function getMintingLimit() external returns(uint256);

}

/**
 * @title Interface for EllipticCurve contract.
 */
interface EllipticCurveInterface {

    function validateSignature(bytes32 message, uint[2] calldata rs, uint[2] calldata Q) external view returns (bool);

}

/**
 * @title Kong escrow contract.
 *
 * @dev   This contract escrows Kong tokens until the timestamp specified in `unlockTime`.
 *        Afterwards, `transferTokens()` can be called to transfer the escrowed tokens to a
 *        destination address of choice. The function has to be provided with a valid SECP256R1
 *        signature of a specifically-formatted sha256 hash for the public key stored in the
 *        variables `publicKeyX` and `publicKeyY`. The signature is verified by a separately-
 *        deployed contract capable of verifying SECP256R1 signatures.
 */
contract Escrow
{

  uint256 _publicKeyX;
  uint256 _publicKeyY;
  uint256 _unlockTime;
  address _eccAddress;
  address _tokAddress;

  uint256 constant BLOCK_DELAY = 240;

  /**
   * @dev All of the variables set in the constructor are immutable.
   *
   * @param publicKeyX         X coordinate of public key.
   * @param publicKeyY         Y coordinate of public key.
   * @param eccAddress         Address of elliptic curve contract.
   * @param tokAddress         Address of Kong ERC20 contract.
   * @param unlockTime         Timestamp at which transfers become possible.
   */
  constructor(
    uint256 publicKeyX,
    uint256 publicKeyY,
    address eccAddress,
    address tokAddress,
    uint256 unlockTime
  )
    public
  {
    _publicKeyX = publicKeyX;
    _publicKeyY = publicKeyY;
    _eccAddress = eccAddress;
    _tokAddress = tokAddress;
    _unlockTime = unlockTime;
  }

  /**
   * @dev Function to transfer Kong tokens.
   *
   * @param to                 Recipient.
   * @param blockNumber        Number of the block(hash) included in the signature.
   * @param rs                 R+S value of the signature.
   */
  function transferTokens(
    address to,
    uint256 blockNumber,
    uint256[2] calldata rs
  )
    external
  {
    // Verify that timelock has expired.
    require(block.timestamp >= _unlockTime, 'Cannot unlock yet.');

    // Verify blockhash is from recent past.
    require(block.number >= blockNumber, 'Invalid block.');
    require(block.number <= blockNumber + BLOCK_DELAY, 'Outdated block.');

    // Verify signature.
    require(_validateSignature(sha256(abi.encodePacked(to, blockhash(blockNumber))), rs), 'Invalid signature.');

    // Transfer current balance from token contract to `to`.
    KongERC20Interface(_tokAddress).transfer(to, KongERC20Interface(_tokAddress).balanceOf(address(this)));
  }

  /**
   * @dev Function to validate SECP256R1 signatures.
   *
   * @param message            The hash of the signed message.
   * @param rs                 R+S value of the signature.
   */
  function _validateSignature(
    bytes32 message,
    uint256[2] memory rs
  )
    internal view returns (bool)
  {
    return EllipticCurveInterface(_eccAddress).validateSignature(message, rs, [_publicKeyX, _publicKeyY]);
  }

  /**
   * @dev Helper function to return state variables.
   */
  function getContractState() external view returns (
    uint256, uint256, address, uint256, address
  ) {
    return (_publicKeyX, _publicKeyY, _eccAddress, _unlockTime, _tokAddress);
  }

}