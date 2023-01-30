/**

 *Submitted for verification at Etherscan.io on 2019-02-09

*/



/**

 * Copyright (c) 2018-present, Leap DAO (leapdao.org)

 *

 * This source code is licensed under the Mozilla Public License, version 2,

 * found in the LICENSE file in the root directory of this source tree.

 */



pragma solidity 0.5.2;





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



    bool wasInitializing = initializing;

    initializing = true;

    initialized = true;



    _;



    initializing = wasInitializing;

  }



  /// @dev Returns true if and only if the function is running in the constructor

  function isConstructor() private view returns (bool) {

    // extcodesize checks the size of the code stored in an address, and

    // address returns the current address. Since the code is still not

    // deployed when running a constructor, any checks on its code size will

    // yield zero, making it an effective way to detect if a contract is

    // under construction or not.

    uint256 cs;

    assembly { cs := extcodesize(address) }

    return cs == 0;

  }



  // Reserved storage space to allow for layout changes in the future.

  uint256[50] private ______gap;

}



/**

 * @title Adminable

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

contract Adminable is Initializable {



  /**

   * @dev Storage slot with the admin of the contract.

   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is

   * validated in the constructor.

   */

  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;



  /**

   * @dev Modifier to check whether the `msg.sender` is the admin.

   * If it is, it will run the function. Otherwise, fails.

   */

  modifier ifAdmin() {

    require(msg.sender == _admin());

    _;

  }



  function admin() external view returns (address) {

    return _admin();

  }



    /**

   * @return The admin slot.

   */

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;

    assembly {

      adm := sload(slot)

    }

  }

}



contract Vault {}

contract Bridge {

    function submitPeriod(

    bytes32 _prevHash, 

    bytes32 _root) 

  public  returns (uint256 newHeight) {}

}



contract PoaOperator is Adminable {



  event Epoch(uint256 epoch);

  event EpochLength(uint256 epochLength);



  event ValidatorJoin(

    address indexed signerAddr,

    uint256 indexed slotId,

    bytes32 indexed tenderAddr,

    uint256 eventCounter,

    uint256 epoch

  );



  event ValidatorLogout(

    address indexed signerAddr,

    uint256 indexed slotId,

    bytes32 indexed tenderAddr,

    address newSigner,

    uint256 eventCounter,

    uint256 epoch

  );



  event ValidatorLeave(

    address indexed signerAddr,

    uint256 indexed slotId,

    bytes32 indexed tenderAddr,

    uint256 epoch

  );



  event ValidatorUpdate(

    address indexed signerAddr,

    uint256 indexed slotId,

    bytes32 indexed tenderAddr,

    uint256 eventCounter

  );



  struct Slot {

    uint32 eventCounter;

    address owner;

    uint64 stake;

    address signer;

    bytes32 tendermint;

    uint32 activationEpoch;

    address newOwner;

    uint64 newStake;

    address newSigner;

    bytes32 newTendermint;

  }



  Vault public vault;

  Bridge public bridge;



  uint256 public epochLength; // length of epoch in periods (32 blocks)

  uint256 public lastCompleteEpoch; // height at which last epoch was completed

  uint256 public lastEpochBlockHeight;



  mapping(uint256 => Slot) public slots;





  function initialize(Bridge _bridge, Vault _vault, uint256 _epochLength) public initializer {

    vault = _vault;

    bridge = _bridge;

    epochLength = _epochLength;

    emit EpochLength(epochLength);

  }



  function setEpochLength(uint256 _epochLength) public ifAdmin {

    epochLength = _epochLength;

    emit EpochLength(epochLength);

  }



  function setSlot(uint256 _slotId, address _signerAddr, bytes32 _tenderAddr) public ifAdmin {

    require(_slotId < epochLength, "out of range slotId");

    Slot storage slot = slots[_slotId];



    // taking empty slot

    if (slot.signer == address(0)) {

      slot.owner = _signerAddr;

      slot.signer = _signerAddr;

      slot.tendermint = _tenderAddr;

      slot.activationEpoch = 0;

      slot.eventCounter++;

      emit ValidatorJoin(

        slot.signer,

        _slotId,

        _tenderAddr,

        slot.eventCounter,

        lastCompleteEpoch + 1

      );

      return;

    }

    // emptying slot

    if (_signerAddr == address(0) && _tenderAddr == 0) {

      slot.activationEpoch = uint32(lastCompleteEpoch + 3);

      slot.eventCounter++;

      emit ValidatorLogout(

        slot.signer,

        _slotId,

        _tenderAddr,

        address(0),

        slot.eventCounter,

        lastCompleteEpoch + 3

      );

      return;

    }

  }



  function activate(uint256 _slotId) public {

    require(_slotId < epochLength, "out of range slotId");

    Slot storage slot = slots[_slotId];

    require(lastCompleteEpoch + 1 >= slot.activationEpoch, "activation epoch not reached yet");

    if (slot.signer != address(0)) {

      emit ValidatorLeave(

        slot.signer,

        _slotId,

        slot.tendermint,

        lastCompleteEpoch + 1

      );

    }

    slot.owner = slot.newOwner;

    slot.signer = slot.newSigner;

    slot.tendermint = slot.newTendermint;

    slot.activationEpoch = 0;

    slot.newSigner = address(0);

    slot.newTendermint = 0x0;

    slot.eventCounter++;

    if (slot.signer != address(0)) {

      emit ValidatorJoin(

        slot.signer,

        _slotId,

        slot.tendermint,

        slot.eventCounter,

        lastCompleteEpoch + 1

      );

    }

  }



  event Submission(

    bytes32 indexed blocksRoot,

    uint256 indexed slotId,

    address owner,

    bytes32 periodRoot

  );



  function submitPeriod(uint256 _slotId, bytes32 _prevHash, bytes32 _blocksRoot) public {

    require(_slotId < epochLength, "Incorrect slotId");

    Slot storage slot = slots[_slotId];

    require(slot.signer == msg.sender, "not submitted by signerAddr");

    // This is here so that I can submit in the same epoch I auction/logout but not after

    if (slot.activationEpoch > 0) {

      // if slot not active, prevent submission

      require(lastCompleteEpoch + 2 < slot.activationEpoch, "slot not active");

    }



    // validator root

    bytes32 hashRoot = bytes32(_slotId << 160 | uint160(slot.owner));

    assembly {

      mstore(0, hashRoot)

      mstore(0x20, 0x0000000000000000000000000000000000000000)

      hashRoot := keccak256(0, 0x40)

    }

    // cas root

    assembly {

      mstore(0, 0x0000000000000000000000000000000000000000)

      mstore(0x20, hashRoot)

      hashRoot := keccak256(0, 0x40)

    }



    // consensus root

    bytes32 consensusRoot;

    assembly {

      mstore(0, _blocksRoot)

      mstore(0x20, 0x0000000000000000000000000000000000000000)

      consensusRoot := keccak256(0, 0x40)

    }



    // period root

    assembly {

      mstore(0, consensusRoot)

      mstore(0x20, hashRoot)

      hashRoot := keccak256(0, 0x40)

    }



    uint256 newHeight = bridge.submitPeriod(_prevHash, hashRoot);

    // check if epoch completed

    if (newHeight >= lastEpochBlockHeight + epochLength) {

      lastCompleteEpoch++;

      lastEpochBlockHeight = newHeight;

      emit Epoch(lastCompleteEpoch);

    }

    emit Submission(_blocksRoot, _slotId, slot.owner, hashRoot);

  }

}