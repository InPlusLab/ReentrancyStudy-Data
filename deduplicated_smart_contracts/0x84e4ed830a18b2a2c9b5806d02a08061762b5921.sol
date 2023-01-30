/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.4.24;





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

 * @title IPFS hash handler

 *

 * @dev IPFS multihash handler. Does a small check to validate that a multihash is

 *   correct by validating the digest size byte of the hash. For example, the IPFS

 *   Multihash "QmPtkU87jX1SnyhjAgUwnirmabAmeASQ4wGfwxviJSA4wf" is the base58

 *   encoded form of the following data:

 *

 *     ©°©¤©¤©¤©¤©Ð©¤©¤©¤©¤©Ð©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©´

 *     ©¦byte©¦byte©¦             variable length hash based on digest size             ©¦

 *     ©À©¤©¤©¤©¤©à©¤©¤©¤©¤©à©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©È

 *     ©¦0x12©¦0x20©¦0x1714c8d0fa5dbe9e6c04059ddac50c3860fb0370d67af53f2bd51a4def656526 ©¦

 *     ©¸©¤©¤©¤©¤©Ø©¤©¤©¤©¤©Ø©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¼

 *       ¡ø    ¡ø                                   ¡ø

 *       ©¦    ©¸©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©´                       ©¦

 *   hash function    digest size             hash value

 *

 * we still store the data as `bytes` since it is inherently a variable length structure.

 *

 * @dev See multihash format: https://git.io/vbooc

 */

contract DependentOnIPFS {

  /**

   * @dev Validate a multihash bytes value

   */

  function isValidIPFSMultihash(bytes _multihashBytes) internal pure returns (bool) {

    require(_multihashBytes.length > 2);



    uint8 _size;



    // There isn't another way to extract only this byte into a uint8

    // solhint-disable no-inline-assembly

    assembly {

      // Seek forward 33 bytes beyond the solidity length value and the hash function byte

      _size := byte(0, mload(add(_multihashBytes, 33)))

    }



    return (_multihashBytes.length == _size + 2);

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

 * @title Voteable poll with associated IPFS data

 *

 * A poll records votes on a variable number of choices. A poll specifies

 * a window during which users can vote. Information like the poll title and

 * the descriptions for each option are stored on IPFS.

 */

contract Poll is DependentOnIPFS, SigningLogic {

  // There isn't a way around using time to determine when votes can be cast

  // solhint-disable not-rely-on-time



  bytes public pollDataMultihash;

  uint16 public numChoices;

  uint256 public startTime;

  uint256 public endTime;

  address public author;



  event VoteCast(address indexed voter, uint16 indexed choice);



  constructor(

    string _name,

    uint256 _chainId,

    bytes _ipfsHash,

    uint16 _numChoices,

    uint256 _startTime,

    uint256 _endTime,

    address _author

  ) public SigningLogic(_name, "2", _chainId) {

    require(_startTime >= now && _endTime > _startTime);

    require(isValidIPFSMultihash(_ipfsHash));



    numChoices = _numChoices;

    startTime = _startTime;

    endTime = _endTime;

    pollDataMultihash = _ipfsHash;

    author = _author;

  }



  function vote(uint16 _choice) external {

    voteForUser(_choice, msg.sender);

  }



  function voteFor(uint16 _choice, address _voter, bytes32 _nonce, bytes _delegationSig) external {

    validateVoteForSig(_choice, _voter, _nonce, _delegationSig);

    voteForUser(_choice, _voter);

  }



  function validateVoteForSig(

    uint16 _choice,

    address _voter,

    bytes32 _nonce,

    bytes _delegationSig

  ) private {

    bytes32 _signatureDigest = generateVoteForDelegationSchemaHash(_choice, _voter, _nonce, this);

    require(_voter == recoverSigner(_signatureDigest, _delegationSig),

      "Invalid signer"

      );

    burnSignatureDigest(_signatureDigest, _voter);

  }



  /**

   * @dev Cast or change your vote

   * @param _choice The index of the option in the corresponding IPFS document.

   */

  function voteForUser(uint16 _choice, address _voter) private duringPoll {

    // Choices are indexed from 1 since the mapping returns 0 for "no vote cast"

    require(_choice <= numChoices && _choice > 0);

    emit VoteCast(_voter, _choice);

  }



  modifier duringPoll {

    require(now >= startTime && now <= endTime);

    _;

  }



}





/*

 * @title Bloom voting center

 * @dev The voting center is the home of all polls conducted within the Bloom network.

 *   Anyone can create a new poll and there is no "owner" of the network. The Bloom dApp

 *   assumes that all polls are in the `polls` field so any Bloom poll should be created

 *   through the `createPoll` function.

 */

contract VotingCenter {

  Poll[] public polls;



  event PollCreated(address indexed poll, address indexed author);



  /**

   * @dev create a poll and store the address of the poll in this contract

   * @param _ipfsHash Multihash for IPFS file containing poll information

   * @param _numOptions Number of choices in this poll

   * @param _startTime Time after which a user can cast a vote in the poll

   * @param _endTime Time after which the poll no longer accepts new votes

   * @return The address of the new Poll

   */

  function createPoll(

    string _name,

    uint256 _chainId,

    bytes _ipfsHash,

    uint16 _numOptions,

    uint256 _startTime,

    uint256 _endTime

  ) external returns (address) {

    Poll newPoll = new Poll(

      _name,

      _chainId,

      _ipfsHash,

      _numOptions,

      _startTime,

      _endTime,

      msg.sender

      );

    polls.push(newPoll);



    emit PollCreated(newPoll, msg.sender);



    return newPoll;

  }



  function allPolls() external view returns (Poll[]) {

    return polls;

  }



  function numPolls() external view returns (uint256) {

    return polls.length;

  }

}