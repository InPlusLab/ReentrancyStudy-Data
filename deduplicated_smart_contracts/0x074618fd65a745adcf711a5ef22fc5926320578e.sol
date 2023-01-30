/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.4.24;





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}







/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    assert(token.transfer(to, value));

  }



  function safeTransferFrom(

    ERC20 token,

    address from,

    address to,

    uint256 value

  )

    internal

  {

    assert(token.transferFrom(from, to, value));

  }



  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    assert(token.approve(spender, value));

  }

}





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



/**

 * @dev Pulled from OpenZeppelin: https://git.io/vbaRf

 *   When this is in a public release we will switch to not vendoring this file

 *

 * @title Eliptic curve signature operations

 *

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 */



library ECRecovery {



  /**

   * @dev Recover signer address from a message by using his signature

   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.

   * @param sig bytes signature, the signature is generated using web3.eth.sign()

   */

  function recover(bytes32 hash, bytes sig) public pure returns (address) {

    bytes32 r;

    bytes32 s;

    uint8 v;



    //Check the signature length

    if (sig.length != 65) {

      return (address(0));

    }



    // Extracting these values isn't possible without assembly

    // solhint-disable no-inline-assembly

    // Divide the signature in r, s and v variables

    assembly {

      r := mload(add(sig, 32))

      s := mload(add(sig, 64))

      v := byte(0, mload(add(sig, 96)))

    }



    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions

    if (v < 27) {

      v += 27;

    }



    // If the version is correct return the signer address

    if (v != 27 && v != 28) {

      return (address(0));

    } else {

      return ecrecover(hash, v, r, s);

    }

  }



}





/**

 * @title SigningLogic is contract implementing signature recovery from typed data signatures

 * @notice Recovers signatures based on the SignTypedData implementation provided by ethSigUtil

 * @dev This contract is inherited by other contracts.

 */

contract SigningLogic {



  // Signatures contain a nonce to make them unique. usedSignatures tracks which signatures

  //  have been used so they can't be replayed

  mapping (bytes32 => bool) public usedSignatures;



  function burnSignatureDigest(bytes32 _signatureDigest, address _sender) internal {

    bytes32 _txDataHash = keccak256(abi.encode(_signatureDigest, _sender));

    require(!usedSignatures[_txDataHash], "Signature not unique");

    usedSignatures[_txDataHash] = true;

  }



  bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(

    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"

  );



  bytes32 constant ATTESTATION_REQUEST_TYPEHASH = keccak256(

    "AttestationRequest(bytes32 dataHash,bytes32 nonce)"

  );



  bytes32 constant ADD_ADDRESS_TYPEHASH = keccak256(

    "AddAddress(address addressToAdd,bytes32 nonce)"

  );



  bytes32 constant REMOVE_ADDRESS_TYPEHASH = keccak256(

    "RemoveAddress(address addressToRemove,bytes32 nonce)"

  );



  bytes32 constant PAY_TOKENS_TYPEHASH = keccak256(

    "PayTokens(address sender,address receiver,uint256 amount,bytes32 nonce)"

  );



  bytes32 constant RELEASE_TOKENS_FOR_TYPEHASH = keccak256(

    "ReleaseTokensFor(address sender,uint256 amount,bytes32 nonce)"

  );



  bytes32 constant ATTEST_FOR_TYPEHASH = keccak256(

    "AttestFor(address subject,address requester,uint256 reward,bytes32 dataHash,bytes32 requestNonce)"

  );



  bytes32 constant CONTEST_FOR_TYPEHASH = keccak256(

    "ContestFor(address requester,uint256 reward,bytes32 requestNonce)"

  );



  bytes32 constant REVOKE_ATTESTATION_FOR_TYPEHASH = keccak256(

    "RevokeAttestationFor(bytes32 link,bytes32 nonce)"

  );



  bytes32 constant VOTE_FOR_TYPEHASH = keccak256(

    "VoteFor(uint16 choice,address voter,bytes32 nonce,address poll)"

  );



  bytes32 constant LOCKUP_TOKENS_FOR_TYPEHASH = keccak256(

    "LockupTokensFor(address sender,uint256 amount,bytes32 nonce)"

  );



  bytes32 DOMAIN_SEPARATOR;



  constructor (string name, string version, uint256 chainId) public {

    DOMAIN_SEPARATOR = hash(EIP712Domain({

      name: name,

      version: version,

      chainId: chainId,

      verifyingContract: this

    }));

  }



  struct EIP712Domain {

      string  name;

      string  version;

      uint256 chainId;

      address verifyingContract;

  }



  function hash(EIP712Domain eip712Domain) private pure returns (bytes32) {

    return keccak256(abi.encode(

      EIP712DOMAIN_TYPEHASH,

      keccak256(bytes(eip712Domain.name)),

      keccak256(bytes(eip712Domain.version)),

      eip712Domain.chainId,

      eip712Domain.verifyingContract

    ));

  }



  struct AttestationRequest {

      bytes32 dataHash;

      bytes32 nonce;

  }



  function hash(AttestationRequest request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      ATTESTATION_REQUEST_TYPEHASH,

      request.dataHash,

      request.nonce

    ));

  }



  struct AddAddress {

      address addressToAdd;

      bytes32 nonce;

  }



  function hash(AddAddress request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      ADD_ADDRESS_TYPEHASH,

      request.addressToAdd,

      request.nonce

    ));

  }



  struct RemoveAddress {

      address addressToRemove;

      bytes32 nonce;

  }



  function hash(RemoveAddress request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      REMOVE_ADDRESS_TYPEHASH,

      request.addressToRemove,

      request.nonce

    ));

  }



  struct PayTokens {

      address sender;

      address receiver;

      uint256 amount;

      bytes32 nonce;

  }



  function hash(PayTokens request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      PAY_TOKENS_TYPEHASH,

      request.sender,

      request.receiver,

      request.amount,

      request.nonce

    ));

  }



  struct AttestFor {

      address subject;

      address requester;

      uint256 reward;

      bytes32 dataHash;

      bytes32 requestNonce;

  }



  function hash(AttestFor request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      ATTEST_FOR_TYPEHASH,

      request.subject,

      request.requester,

      request.reward,

      request.dataHash,

      request.requestNonce

    ));

  }



  struct ContestFor {

      address requester;

      uint256 reward;

      bytes32 requestNonce;

  }



  function hash(ContestFor request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      CONTEST_FOR_TYPEHASH,

      request.requester,

      request.reward,

      request.requestNonce

    ));

  }



  struct RevokeAttestationFor {

      bytes32 link;

      bytes32 nonce;

  }



  function hash(RevokeAttestationFor request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      REVOKE_ATTESTATION_FOR_TYPEHASH,

      request.link,

      request.nonce

    ));

  }



  struct VoteFor {

      uint16 choice;

      address voter;

      bytes32 nonce;

      address poll;

  }



  function hash(VoteFor request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      VOTE_FOR_TYPEHASH,

      request.choice,

      request.voter,

      request.nonce,

      request.poll

    ));

  }



  struct LockupTokensFor {

    address sender;

    uint256 amount;

    bytes32 nonce;

  }



  function hash(LockupTokensFor request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      LOCKUP_TOKENS_FOR_TYPEHASH,

      request.sender,

      request.amount,

      request.nonce

    ));

  }



  struct ReleaseTokensFor {

    address sender;

    uint256 amount;

    bytes32 nonce;

  }



  function hash(ReleaseTokensFor request) private pure returns (bytes32) {

    return keccak256(abi.encode(

      RELEASE_TOKENS_FOR_TYPEHASH,

      request.sender,

      request.amount,

      request.nonce

    ));

  }



  function generateRequestAttestationSchemaHash(

    bytes32 _dataHash,

    bytes32 _nonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(AttestationRequest(

          _dataHash,

          _nonce

        ))

      )

      );

  }



  function generateAddAddressSchemaHash(

    address _addressToAdd,

    bytes32 _nonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(AddAddress(

          _addressToAdd,

          _nonce

        ))

      )

      );

  }



  function generateRemoveAddressSchemaHash(

    address _addressToRemove,

    bytes32 _nonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(RemoveAddress(

          _addressToRemove,

          _nonce

        ))

      )

      );

  }



  function generatePayTokensSchemaHash(

    address _sender,

    address _receiver,

    uint256 _amount,

    bytes32 _nonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(PayTokens(

          _sender,

          _receiver,

          _amount,

          _nonce

        ))

      )

      );

  }



  function generateAttestForDelegationSchemaHash(

    address _subject,

    address _requester,

    uint256 _reward,

    bytes32 _dataHash,

    bytes32 _requestNonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(AttestFor(

          _subject,

          _requester,

          _reward,

          _dataHash,

          _requestNonce

        ))

      )

      );

  }



  function generateContestForDelegationSchemaHash(

    address _requester,

    uint256 _reward,

    bytes32 _requestNonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(ContestFor(

          _requester,

          _reward,

          _requestNonce

        ))

      )

      );

  }



  function generateRevokeAttestationForDelegationSchemaHash(

    bytes32 _link,

    bytes32 _nonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(RevokeAttestationFor(

          _link,

          _nonce

        ))

      )

      );

  }



  function generateVoteForDelegationSchemaHash(

    uint16 _choice,

    address _voter,

    bytes32 _nonce,

    address _poll

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(VoteFor(

          _choice,

          _voter,

          _nonce,

          _poll

        ))

      )

      );

  }



  function generateLockupTokensDelegationSchemaHash(

    address _sender,

    uint256 _amount,

    bytes32 _nonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(LockupTokensFor(

          _sender,

          _amount,

          _nonce

        ))

      )

      );

  }



  function generateReleaseTokensDelegationSchemaHash(

    address _sender,

    uint256 _amount,

    bytes32 _nonce

  ) internal view returns (bytes32) {

    return keccak256(

      abi.encodePacked(

        "\x19\x01",

        DOMAIN_SEPARATOR,

        hash(ReleaseTokensFor(

          _sender,

          _amount,

          _nonce

        ))

      )

      );

  }



  function recoverSigner(bytes32 _hash, bytes _sig) internal pure returns (address) {

    address signer = ECRecovery.recover(_hash, _sig);

    require(signer != address(0));



    return signer;

  }

}





/**

 * @notice TokenEscrowMarketplace is an ERC20 payment channel that enables users to send BLT by exchanging signatures off-chain

 *  Users approve the contract address to transfer BLT on their behalf using the standard ERC20.approve function

 *  After approval, either the user or the contract admin initiates the transfer of BLT into the contract

 *  Once in the contract, users can send payments via a signed message to another user. 

 *  The signature transfers BLT from lockup to the recipient's balance

 *  Users can withdraw funds at any time. Or the admin can release them on the user's behalf

 *  

 *  BLT is stored in the contract by address

 *  

 *  Only the AttestationLogic contract is authorized to release funds once a jobs is complete

 */

contract TokenEscrowMarketplace is SigningLogic {

  using SafeERC20 for ERC20;

  using SafeMath for uint256;



  address public attestationLogic;



  mapping(address => uint256) public tokenEscrow;

  ERC20 public token;



  event TokenMarketplaceWithdrawal(address escrowPayer, uint256 amount);

  event TokenMarketplaceEscrowPayment(address escrowPayer, address escrowPayee, uint256 amount);

  event TokenMarketplaceDeposit(address escrowPayer, uint256 amount);



  /**

   * @notice The TokenEscrowMarketplace constructor initializes the interfaces to the other contracts

   * @dev Some actions are restricted to be performed by the attestationLogic contract.

   *  Signing logic is upgradeable in case the signTypedData spec changes

   * @param _token Address of BLT

   * @param _attestationLogic Address of current attestation logic contract

   */

  constructor(

    ERC20 _token,

    address _attestationLogic

    ) public SigningLogic("Bloom Token Escrow Marketplace", "2", 1) {

    token = _token;

    attestationLogic = _attestationLogic;

  }



  modifier onlyAttestationLogic() {

    require(msg.sender == attestationLogic);

    _;

  }



  /**

   * @notice Lockup tokens for set time period on behalf of user. Must be preceeded by approve

   * @dev Authorized by a signTypedData signature by sender

   *  Sigs can only be used once. They contain a unique nonce

   *  So an action can be repeated, with a different signature

   * @param _sender User locking up their tokens

   * @param _amount Tokens to lock up

   * @param _nonce Unique Id so signatures can't be replayed

   * @param _delegationSig Signed hash of these input parameters so an admin can submit this on behalf of a user

   */

  function moveTokensToEscrowLockupFor(

    address _sender,

    uint256 _amount,

    bytes32 _nonce,

    bytes _delegationSig

    ) external {

      validateLockupTokensSig(

        _sender,

        _amount,

        _nonce,

        _delegationSig

      );

      moveTokensToEscrowLockupForUser(_sender, _amount);

  }



  /**

   * @notice Verify lockup signature is valid

   * @param _sender User locking up their tokens

   * @param _amount Tokens to lock up

   * @param _nonce Unique Id so signatures can't be replayed

   * @param _delegationSig Signed hash of these input parameters so an admin can submit this on behalf of a user

   */

  function validateLockupTokensSig(

    address _sender,

    uint256 _amount,

    bytes32 _nonce,

    bytes _delegationSig

  ) private {

    bytes32 _signatureDigest = generateLockupTokensDelegationSchemaHash(_sender, _amount, _nonce);

    require(_sender == recoverSigner(_signatureDigest, _delegationSig), 'Invalid LockupTokens Signature');

    burnSignatureDigest(_signatureDigest, _sender);

  }



  /**

   * @notice Lockup tokens by user. Must be preceeded by approve

   * @param _amount Tokens to lock up

   */

  function moveTokensToEscrowLockup(uint256 _amount) external {

    moveTokensToEscrowLockupForUser(msg.sender, _amount);

  }



  /**

   * @notice Lockup tokens for set time. Must be preceeded by approve

   * @dev Private function called by appropriate public function

   * @param _sender User locking up their tokens

   * @param _amount Tokens to lock up

   */

  function moveTokensToEscrowLockupForUser(

    address _sender,

    uint256 _amount

    ) private {

    token.safeTransferFrom(_sender, this, _amount);

    addToEscrow(_sender, _amount);

  }



  /**

   * @notice Withdraw tokens from escrow back to requester

   * @dev Authorized by a signTypedData signature by sender

   *  Sigs can only be used once. They contain a unique nonce

   *  So an action can be repeated, with a different signature

   * @param _sender User withdrawing their tokens

   * @param _amount Tokens to withdraw

   * @param _nonce Unique Id so signatures can't be replayed

   * @param _delegationSig Signed hash of these input parameters so an admin can submit this on behalf of a user

   */

  function releaseTokensFromEscrowFor(

    address _sender,

    uint256 _amount,

    bytes32 _nonce,

    bytes _delegationSig

    ) external {

      validateReleaseTokensSig(

        _sender,

        _amount,

        _nonce,

        _delegationSig

      );

      releaseTokensFromEscrowForUser(_sender, _amount);

  }



  /**

   * @notice Verify lockup signature is valid

   * @param _sender User withdrawing their tokens

   * @param _amount Tokens to lock up

   * @param _nonce Unique Id so signatures can't be replayed

   * @param _delegationSig Signed hash of these input parameters so an admin can submit this on behalf of a user

   */

  function validateReleaseTokensSig(

    address _sender,

    uint256 _amount,

    bytes32 _nonce,

    bytes _delegationSig



  ) private {

    bytes32 _signatureDigest = generateReleaseTokensDelegationSchemaHash(_sender, _amount, _nonce);

    require(_sender == recoverSigner(_signatureDigest, _delegationSig), 'Invalid ReleaseTokens Signature');

    burnSignatureDigest(_signatureDigest, _sender);

  }



  /**

   * @notice Release tokens back to payer's available balance if lockup expires

   * @dev Token balance retreived by accountId. Can be different address from the one that deposited tokens

   * @param _amount Tokens to retreive from escrow

   */

  function releaseTokensFromEscrow(uint256 _amount) external {

    releaseTokensFromEscrowForUser(msg.sender, _amount);

  }



  /**

   * @notice Release tokens back to payer's available balance

   * @param _payer User retreiving tokens from escrow

   * @param _amount Tokens to retreive from escrow

   */

  function releaseTokensFromEscrowForUser(

    address _payer,

    uint256 _amount

    ) private {

      subFromEscrow(_payer, _amount);

      token.safeTransfer(_payer, _amount);

      emit TokenMarketplaceWithdrawal(_payer, _amount);

  }



  /**

   * @notice Pay from escrow of payer to available balance of receiever

   * @dev Private function to modify balances on payment

   * @param _payer User with tokens in escrow

   * @param _receiver User receiving tokens

   * @param _amount Tokens being sent

   */

  function payTokensFromEscrow(address _payer, address _receiver, uint256 _amount) private {

    subFromEscrow(_payer, _amount);

    token.safeTransfer(_receiver, _amount);

  }



  /**

   * @notice Pay tokens to receiver from payer's escrow given a valid signature

   * @dev Execution restricted to attestationLogic contract

   * @param _payer User paying tokens from escrow

   * @param _receiver User receiving payment

   * @param _amount Tokens being paid

   * @param _nonce Unique Id for sig to make it one-time-use

   * @param _paymentSig Signed parameters by payer authorizing payment

   */

  function requestTokenPayment(

    address _payer,

    address _receiver,

    uint256 _amount,

    bytes32 _nonce,

    bytes _paymentSig

    ) external onlyAttestationLogic {



    validatePaymentSig(

      _payer,

      _receiver,

      _amount,

      _nonce,

      _paymentSig

    );

    payTokensFromEscrow(_payer, _receiver, _amount);

    emit TokenMarketplaceEscrowPayment(_payer, _receiver, _amount);

  }



  /**

   * @notice Verify payment signature is valid

   * @param _payer User paying tokens from escrow

   * @param _receiver User receiving payment

   * @param _amount Tokens being paid

   * @param _nonce Unique Id for sig to make it one-time-use

   * @param _paymentSig Signed parameters by payer authorizing payment

   */

  function validatePaymentSig(

    address _payer,

    address _receiver,

    uint256 _amount,

    bytes32 _nonce,

    bytes _paymentSig



  ) private {

    bytes32 _signatureDigest = generatePayTokensSchemaHash(_payer, _receiver, _amount, _nonce);

    require(_payer == recoverSigner(_signatureDigest, _paymentSig), 'Invalid Payment Signature');

    burnSignatureDigest(_signatureDigest, _payer);

  }



  /**

   * @notice Helper function to add to escrow balance 

   * @param _from Account address for escrow mapping

   * @param _amount Tokens to lock up

   */

  function addToEscrow(address _from, uint256 _amount) private {

    tokenEscrow[_from] = tokenEscrow[_from].add(_amount);

    emit TokenMarketplaceDeposit(_from, _amount);

  }



  /**

   * Helper function to reduce escrow token balance of user

   */

  function subFromEscrow(address _from, uint256 _amount) private {

    require(tokenEscrow[_from] >= _amount);

    tokenEscrow[_from] = tokenEscrow[_from].sub(_amount);

  }

}