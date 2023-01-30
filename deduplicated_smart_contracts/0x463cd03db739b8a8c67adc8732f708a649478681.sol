/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

// File: contracts/common/Validating.sol

pragma solidity 0.5.12;


interface Validating {
  modifier notZero(uint number) { require(number > 0, "invalid 0 value"); _; }
  modifier notEmpty(string memory text) { require(bytes(text).length > 0, "invalid empty string"); _; }
  modifier validAddress(address value) { require(value != address(0x0), "invalid address"); _; }
}

// File: contracts/external/MerkleProof.sol

pragma solidity 0.5.12;


/// @notice can use a deployed https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/cryptography/MerkleProof.sol
contract MerkleProof {

  /**
   * Verifies the inclusion of a leaf in a Merkle tree using a Merkle proof.
   * Based on https://github.com/ameensol/merkle-tree-solidity/src/MerkleProof.sol
   */
  function checkProof(bytes memory proof, bytes32 root, bytes32 leaf) public pure returns (bool) {
    if (proof.length % 32 != 0) return false; // Check if proof is made of bytes32 slices

    bytes memory elements = proof;
    bytes32 element;
    bytes32 hash = leaf;
    for (uint i = 32; i <= proof.length; i += 32) {
      assembly {
      // Load the current element of the proofOfInclusion (optimal way to get a bytes32 slice)
        element := mload(add(elements, i))
      }
      hash = keccak256(abi.encodePacked(hash < element ? abi.encodePacked(hash, element) : abi.encodePacked(element, hash)));
    }
    return hash == root;
  }

  // from StorJ -- https://github.com/nginnever/storj-audit-verifier/contracts/MerkleVerifyv3.sol
  function checkProofOrdered(bytes memory proof, bytes32 root, bytes32 leaf, uint index) public pure returns (bool) {
    if (proof.length % 32 != 0) return false; // Check if proof is made of bytes32 slices

    // use the index to determine the node ordering (index ranges 1 to n)
    bytes32 element;
    bytes32 hash = leaf;
    uint remaining;
    for (uint j = 32; j <= proof.length; j += 32) {
      assembly {
        element := mload(add(proof, j))
      }

      // calculate remaining elements in proof
      remaining = (proof.length - j + 32) / 32;

      // we don't assume that the tree is padded to a power of 2
      // if the index is odd then the proof will start with a hash at a higher layer,
      // so we have to adjust the index to be the index at that layer
      while (remaining > 0 && index % 2 == 1 && index > 2 ** remaining) {
        index = uint(index) / 2 + 1;
      }

      if (index % 2 == 0) {
        hash = keccak256(abi.encodePacked(abi.encodePacked(element, hash)));
        index = index / 2;
      } else {
        hash = keccak256(abi.encodePacked(abi.encodePacked(hash, element)));
        index = uint(index) / 2 + 1;
      }
    }
    return hash == root;
  }

  /** Verifies the inclusion of a leaf in a Merkle tree using a Merkle proof */
  function verifyIncluded(bytes memory proof, bytes32 root, bytes32 leaf) public pure returns (bool) {
    return checkProof(proof, root, leaf);
  }

  /** Verifies the inclusion of a leaf is at a specific place in an ordered Merkle tree using a Merkle proof */
  function verifyIncludedAtIndex(bytes memory proof, bytes32 root, bytes32 leaf, uint index) public pure returns (bool) {
    return checkProofOrdered(proof, root, leaf, index);
  }
}

// File: contracts/external/Token.sol

pragma solidity 0.5.12;


/*
 * Abstract contract for the full ERC 20 Token standard
 * https://github.com/ethereum/EIPs/issues/20
 */
contract Token {
  /** This is a slight change to the ERC20 base standard.
  function totalSupply() view returns (uint supply);
  is replaced map:
  uint public totalSupply;
  This automatically creates a getter function for the totalSupply.
  This is moved to the base contract since public getter functions are not
  currently recognised as an implementation of the matching abstract
  function by the compiler.
  */
  /// total amount of tokens
  uint public totalSupply;

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public view returns (uint balance);

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint _value) public returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);

  /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of tokens to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint _value) public returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public view returns (uint remaining);

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// File: contracts/gluon/AppGovernance.sol

pragma solidity 0.5.12;


interface AppGovernance {
  function approve(uint32 id) external;
  function disapprove(uint32 id) external;
  function activate(uint32 id) external;
}

// File: contracts/gluon/AppLogic.sol

pragma solidity 0.5.12;


interface AppLogic {
  function upgrade() external;
  function credit(address account, address asset, uint quantity) external;
  function debit(address account, bytes calldata parameters) external returns (address asset, uint quantity);
}

// File: contracts/gluon/AppState.sol

pragma solidity 0.5.12;


contract AppState {

  enum State { OFF, ON, RETIRED }
  State public state = State.ON;
  event Off();
  event Retired();

  modifier whenOn() { require(state == State.ON, "must be on"); _; }
  modifier whenOff() { require(state == State.OFF, "must be off"); _; }
  modifier whenRetired() { require(state == State.RETIRED, "must be retired"); _; }

  function retire_() internal whenOn {
    state = State.RETIRED;
    emit Retired();
  }

  function switchOff_() internal whenOn {
    state = State.OFF;
    emit Off();
  }

  function isOn() external view returns (bool) { return state == State.ON; }
}

// File: contracts/gluon/GluonView.sol

pragma solidity 0.5.12;


interface GluonView {
  function app(uint32 id) external view returns (address current, address proposal, uint activationBlock);
  function current(uint32 id) external view returns (address);
  function history(uint32 id) external view returns (address[] memory);
  function getBalance(uint32 id, address asset) external view returns (uint);
  function isAnyLogic(uint32 id, address logic) external view returns (bool);
  function isAppOwner(uint32 id, address appOwner) external view returns (bool);
  function proposals(address logic) external view returns (bool);
  function totalAppsCount() external view returns(uint32);
}

// File: contracts/gluon/GluonCentric.sol

pragma solidity 0.5.12;



contract GluonCentric {
  uint32 internal constant REGISTRY_INDEX = 0;
  uint32 internal constant STAKE_INDEX = 1;

  uint32 public id;
  address public gluon;

  constructor(uint32 id_, address gluon_) public {
    id = id_;
    gluon = gluon_;
  }

  modifier onlyCurrentLogic { require(currentLogic() == msg.sender, "invalid sender; must be current logic contract"); _; }
  modifier onlyGluon { require(gluon == msg.sender, "invalid sender; must be gluon contract"); _; }
  modifier onlyOwner { require(GluonView(gluon).isAppOwner(id, msg.sender), "invalid sender; must be app owner"); _; }

  function currentLogic() public view returns (address) { return GluonView(gluon).current(id); }
}

// File: contracts/apps/registry/RegistryData.sol

pragma solidity 0.5.12;



contract RegistryData is GluonCentric {

  mapping(address => address) public accounts;

  constructor(address gluon) GluonCentric(REGISTRY_INDEX, gluon) public { }

  function addKey(address apiKey, address account) external onlyCurrentLogic {
    accounts[apiKey] = account;
  }

}

// File: contracts/gluon/Upgrading.sol

pragma solidity 0.5.12;




contract Upgrading {
  address public upgradeOperator;

  modifier onlyOwner { require(false, "modifier onlyOwner must be implemented"); _; }
  modifier onlyUpgradeOperator { require(upgradeOperator == msg.sender, "invalid sender; must be upgrade operator"); _; }
  function setUpgradeOperator(address upgradeOperator_) external onlyOwner { upgradeOperator = upgradeOperator_; }
  function upgrade_(AppGovernance appGovernance, uint32 id) internal {
    appGovernance.activate(id);
    delete upgradeOperator;
  }
}

// File: contracts/apps/registry/RegistryLogic.sol

pragma solidity 0.5.12;









contract RegistryLogic is Upgrading, Validating, AppLogic, AppState, GluonCentric {

  RegistryData public data;
  OldRegistry public old;

  event Registered(address apiKey, address indexed account);

  constructor(address gluon, address old_, address data_) GluonCentric(REGISTRY_INDEX, gluon) public {
    data = RegistryData(data_);
    old = OldRegistry(old_);
  }

  modifier isAbsent(address apiKey) { require(translate(apiKey) == address (0x0), "api key already in use"); _; }

  function register(address apiKey) external whenOn validAddress(apiKey) isAbsent(apiKey) {
    data.addKey(apiKey, msg.sender);
    emit Registered(apiKey, msg.sender);
  }

  function translate(address apiKey) public view returns (address) {
    address account = data.accounts(apiKey);
    if (account == address(0x0)) account = old.translate(apiKey);
    return account;
  }

  /**************************************************** AppLogic ****************************************************/

  function upgrade() external onlyUpgradeOperator {
    retire_();
    upgrade_(AppGovernance(gluon), id);
  }

  function credit(address, address, uint) external { revert("not supported"); }

  function debit(address, bytes calldata) external returns (address, uint) { revert("not supported"); }

  function switchOff() external onlyOwner {
    uint32 totalAppsCount = GluonView(gluon).totalAppsCount();
    for (uint32 i = 2; i < totalAppsCount; i++) {
      AppState appState = AppState(GluonView(gluon).current(i));
      require(!appState.isOn(), "One of the apps is still ON");
    }
    switchOff_();
  }
}


contract OldRegistry {
  function translate(address) public view returns (address);
}

// File: contracts/common/EvmTypes.sol

pragma solidity 0.5.12;


contract EvmTypes {

  uint constant internal ADDRESS = 20;
  uint constant internal UINT8 = 1;
  uint constant internal UINT32 = 4;
  uint constant internal UINT64 = 8;
  uint constant internal UINT128 = 16;
  uint constant internal UINT256 = 32;
  uint constant internal BYTES32 = 32;
  uint constant internal SIGNATURE_BYTES = 65;

}

// File: contracts/external/BytesLib.sol

/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */

pragma solidity 0.5.12;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes_slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes_slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes_slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    ) internal pure returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
                tempBytes := mload(0x40)

            // The first word of the slice result is potentially a partial
            // word read from the original array. To read it, we calculate
            // the length of that partial word and start copying that many
            // bytes into the array. The first word we copy will start with
            // data we don't care about, but the last `lengthmod` bytes will
            // land at the beginning of the contents of the new array. When
            // we're done copying, we overwrite the full first word with
            // the actual length of the slice.
                let lengthmod := and(_length, 31)

            // The multiplication in the next line is necessary
            // because when slicing multiples of 32 bytes (lengthmod == 0)
            // the following copy loop was copying the origin's length
            // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                // The multiplication in the next line has the same exact purpose
                // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

            // update free-memory pointer
            // allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            // if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;
        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }
        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {
        require(_bytes.length >= (_start + 1));
        uint8 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }
        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {
        require(_bytes.length >= (_start + 2));
        uint16 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }
        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {
        require(_bytes.length >= (_start + 4));
        uint32 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }
        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {
        require(_bytes.length >= (_start + 8));
        uint64 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }
        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {
        require(_bytes.length >= (_start + 12));
        uint96 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }
        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {
        require(_bytes.length >= (_start + 16));
        uint128 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }
        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {
        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;
        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }
        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes_slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}

// File: contracts/apps/spot/WithDepositCommitmentRecord.sol

pragma solidity 0.5.12;




contract WithDepositCommitmentRecord is EvmTypes {
  using BytesLib for bytes;

  struct DepositCommitmentRecord {
    uint32 ledgerId;
    address account;
    address asset;
    uint quantity;
    uint32 nonce;
    uint32 designatedGblock;
    bytes32 hash;
  }

  uint constant private LEDGER_ID = 0;
  uint constant private ACCOUNT = LEDGER_ID + UINT32;
  uint constant private ASSET = ACCOUNT + ADDRESS;
  uint constant private QUANTITY = ASSET + ADDRESS;
  uint constant private NONCE = QUANTITY + UINT256;
  uint constant private DESIGNATED_GBLOCK = NONCE + UINT32;

  function parseDepositCommitmentRecord(bytes memory parameters) internal pure returns (DepositCommitmentRecord memory result) {
    result.ledgerId = parameters.toUint32(LEDGER_ID);
    result.account = parameters.toAddress(ACCOUNT);
    result.asset = parameters.toAddress(ASSET);
    result.quantity = parameters.toUint(QUANTITY);
    result.nonce = parameters.toUint32(NONCE);
    result.designatedGblock = parameters.toUint32(DESIGNATED_GBLOCK);
    result.hash = keccak256(encodePackedDeposit(result.ledgerId, result.account, result.asset, result.quantity, result.nonce, result.designatedGblock));
  }

  function encodePackedDeposit(uint32 ledgerId, address account, address asset, uint quantity, uint32 nonce, uint32 designatedGblock) public pure returns(bytes memory) {
    return abi.encodePacked(ledgerId, account, asset, quantity, nonce, designatedGblock);
  }
}

// File: contracts/external/Cryptography.sol

pragma solidity 0.5.12;


contract Cryptography {

  /**
  * @dev Recover signer address from a message by using their signature
  * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
  * @param signature bytes generated using web3.eth.account.sign().signature
  *
  * Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
  * TODO: Remove this library once solidity supports passing a signature to ecrecover.
  * See https://github.com/ethereum/solidity/issues/864
  */
  function recover(bytes32 hash, bytes memory signature) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;
    if (signature.length != 65) return (address(0x0));
    // Check the signature length

    // Divide the signature into r, s and v variables
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := byte(0, mload(add(signature, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) v += 27;

    // If the version is correct return the signer address
    return (v != 27 && v != 28) ? (address(0)) : ecrecover(hash, v, r, s);
  }

}

// File: contracts/apps/spot/WithEntry.sol

pragma solidity 0.5.12;





contract WithEntry is EvmTypes, Cryptography {
  using BytesLib for bytes;

  struct Entry {
    uint32 ledgerId;
    address account;
    address asset;
    EntryType entryType;
    uint8 action;
    uint timestamp;
    uint quantity;
    uint balance;
    uint previous;
    uint32 gblockNumber;
    bytes32 hash;
    bytes32 dataHash;
    bytes signature;
    address signer;
    bytes dataBytes;
  }

  uint constant private VERSION = 0;
  uint constant private LEDGER_ID = VERSION + UINT8;
  uint constant private ACCOUNT = LEDGER_ID + UINT32;
  uint constant private ASSET = ACCOUNT + ADDRESS;
  uint constant private ENTRY_TYPE = ASSET + ADDRESS;
  uint constant private ACTION = ENTRY_TYPE + UINT8;
  uint constant private TIMESTAMP = ACTION + UINT8;
  uint constant private QUANTITY = TIMESTAMP + UINT64;
  uint constant private BALANCE = QUANTITY + UINT256;
  uint constant private PREVIOUS = BALANCE + UINT256;
  uint constant private GBLOCK_NUMBER = PREVIOUS + UINT128;
  uint constant private DATA_HASH = GBLOCK_NUMBER + UINT32;
  uint constant private ENTRY_LENGTH = DATA_HASH + BYTES32;

  enum EntryType { Unknown, Origin, Deposit, Withdrawal, Exited, Trade, Fee }

  function parseEntry(bytes memory parameters, bytes memory signature) internal pure returns (Entry memory result) {
    result.ledgerId = parameters.toUint32(LEDGER_ID);
    result.account = parameters.toAddress(ACCOUNT);
    result.asset = parameters.toAddress(ASSET);
    result.entryType = EntryType(parameters.toUint8(ENTRY_TYPE));
    result.action = parameters.toUint8(ACTION);
    result.timestamp = parameters.toUint64(TIMESTAMP);
    result.quantity = parameters.toUint(QUANTITY);
    result.balance = parameters.toUint(BALANCE);
    result.previous = parameters.toUint128(PREVIOUS);
    result.gblockNumber = parameters.toUint32(GBLOCK_NUMBER);
    result.dataHash = parameters.toBytes32(DATA_HASH);
    bytes memory entryBytes = parameters;
    if (parameters.length > ENTRY_LENGTH) {
      result.dataBytes = parameters.slice(ENTRY_LENGTH, parameters.length - ENTRY_LENGTH);
      require(result.dataHash == keccak256(result.dataBytes), "data hash mismatch");
      entryBytes = parameters.slice(0, ENTRY_LENGTH);
    }
    result.hash = keccak256(entryBytes);
    result.signer = recover(result.hash, signature);
  }

}

// File: contracts/apps/spot/SpotData.sol

pragma solidity 0.5.12;



contract SpotData is GluonCentric {

  struct Gblock {
    bytes32 withdrawalsRoot;
    bytes32 depositsRoot;
    bytes32 balancesRoot;
  }

  uint32 public nonce = 0;
  uint32 public currentGblockNumber;
  uint public submissionBlock = block.number;
  mapping(uint32 => Gblock) public gblocksByNumber;
  mapping(bytes32 => bool) public deposits;
  mapping(bytes32 => bool) public withdrawn;
  mapping(bytes32 => uint) public exitClaims; // exit entry hash => confirmationThreshold
  mapping(address => mapping(address => bool)) public exited; // account => asset => has exited

  constructor(uint32 id, address gluon) GluonCentric(id, gluon) public { }

  function deposit(bytes32 hash) external onlyCurrentLogic { deposits[hash] = true; }

  function deleteDeposit(bytes32 hash) external onlyCurrentLogic {
    require(deposits[hash], "unknown deposit");
    delete deposits[hash];
  }

  function nextNonce() external onlyCurrentLogic returns (uint32) { return ++nonce; }

  function markExited(address account, address asset) external onlyCurrentLogic { exited[account][asset] = true; }

  function markWithdrawn(bytes32 hash) external onlyCurrentLogic {withdrawn[hash] = true;}

  function hasExited(address account, address asset) external view returns (bool) { return exited[account][asset]; }

  function hasWithdrawn(bytes32 hash) external view returns (bool) { return withdrawn[hash]; }

  function markExitClaim(bytes32 hash, uint confirmationThreshold) external onlyCurrentLogic { exitClaims[hash] = confirmationThreshold; }

  function deleteExitClaim(bytes32 hash) external onlyCurrentLogic { delete exitClaims[hash]; }

  function submit(uint32 gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot, uint submissionInterval) external onlyCurrentLogic {
    Gblock memory gblock = Gblock(withdrawalsRoot, depositsRoot, balancesRoot);
    gblocksByNumber[gblockNumber] = gblock;
    currentGblockNumber = gblockNumber;
    submissionBlock = block.number + submissionInterval;
  }

  function updateSubmissionBlock(uint submissionBlock_) external onlyCurrentLogic { submissionBlock = submissionBlock_; }

  function depositsRoot(uint32 gblockNumber) external view returns (bytes32) { return gblocksByNumber[gblockNumber].depositsRoot; }

  function withdrawalsRoot(uint32 gblockNumber) external view returns (bytes32) { return gblocksByNumber[gblockNumber].withdrawalsRoot; }

  function balancesRoot(uint32 gblockNumber) external view returns (bytes32) { return gblocksByNumber[gblockNumber].balancesRoot; }

  function isConfirmedGblock(uint32 gblockNumber) external view returns (bool) { return gblockNumber > 0 && gblockNumber < currentGblockNumber; }

}

// File: contracts/apps/spot/SpotLogic.sol

pragma solidity 0.5.12;














contract SpotLogic is Upgrading, Validating, MerkleProof, AppLogic, AppState, GluonCentric, WithDepositCommitmentRecord, WithEntry {

  struct ProofOfInclusionAtIndex {
    bytes32 leaf;
    uint index;
    bytes proof;
  }

  struct ProofOfExclusionOfDeposit {
    DepositCommitmentRecord excluded;
    ProofOfInclusionAtIndex predecessor;
    ProofOfInclusionAtIndex successor;
  }

  uint8 public constant confirmationDelay = 5;
  uint8 public constant visibilityDelay = 3;

  uint private constant ASSISTED_WITHDRAW = 1;
  uint private constant RECLAIM_DEPOSIT = 2;
  uint private constant CLAIM_EXIT = 3;
  uint private constant EXIT = 4;
  uint private constant EXIT_ON_HALT = 5;
  uint private constant RECLAIM_DEPOSIT_ON_HALT = 6;

  SpotData public data;
  address public operator;
  uint public submissionInterval;
  uint public abandonPoint;
  event Deposited(address indexed account, address indexed asset, uint quantity, uint32 nonce, uint32 designatedGblock);
  event DepositReclaimed(address indexed account, address indexed asset, uint quantity, uint32 nonce);
  event ExitClaimed(bytes32 hash, address indexed account, address indexed asset, uint quantity, uint timestamp, uint confirmationThreshold);
  event Exited(address indexed account, address indexed asset, uint quantity);
  event Withdrawn(bytes32 hash, address indexed account, address indexed asset, uint quantity);
  event Submitted(uint32 gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot);

  constructor(uint32 id, address gluon, address data_, address operator_, uint submissionInterval_, uint abandonPoint_) GluonCentric(id, gluon) public validAddress(gluon) validAddress(operator_) {
    operator = operator_;
    submissionInterval = submissionInterval_;
    data = SpotData(data_);
    abandonPoint = abandonPoint_;
  }

  /**************************************************** AppLogic ****************************************************/

  function upgrade() external whenOn onlyUpgradeOperator {
    require(canSubmit(), "cannot upgrade yet");
    retire_();
    upgrade_(AppGovernance(gluon), id);
  }

  function credit(address account, address asset, uint quantity) external whenOn onlyGluon {
    require(!data.hasExited(account, asset), "previously exited");
    uint32 nonce = data.nextNonce();
    uint32 designatedGblock = data.currentGblockNumber() + visibilityDelay;
    bytes32 hash = keccak256(abi.encodePacked(id, account, asset, quantity, nonce, designatedGblock));
    data.deposit(hash);
    emit Deposited(account, asset, quantity, nonce, designatedGblock);
  }

  function debit(address account, bytes calldata parameters) external onlyGluon returns (address asset, uint quantity) {
    uint action = parameters.toUint(0);
    if (action == ASSISTED_WITHDRAW) return assistedWithdraw(account, parameters);
    else if (action == RECLAIM_DEPOSIT) return reclaimDeposit(account, parameters);
    else if (action == CLAIM_EXIT) return claimExit(account, parameters);
    else if (action == EXIT) return exit(account, parameters);
    else if (action == EXIT_ON_HALT) return exitOnHalt(account, parameters);
    else if (action == RECLAIM_DEPOSIT_ON_HALT) return reclaimDepositOnHalt(account, parameters);
    else revert("invalid action");
  }

  /**************************************************** Depositing ****************************************************/

  function reclaimDeposit(address account, bytes memory parameters) private whenOn returns (address asset, uint quantity) {
    (, bytes memory entry_, bytes32[] memory leaves, uint[] memory indexes, bytes memory predecessor, bytes memory successor) = abi.decode(parameters, (uint, bytes, bytes32[], uint[], bytes, bytes));
    ProofOfExclusionOfDeposit memory proof = extractProofOfExclusionOfDeposit(entry_, leaves, indexes, predecessor, successor);
    DepositCommitmentRecord memory record = proof.excluded;
    require(record.account == account, "claimant must be the original depositor");
    require(data.currentGblockNumber() > record.designatedGblock && record.designatedGblock != 0, "designated gblock is unconfirmed or unknown");
    require(proveIsExcludedFromDeposits(data.depositsRoot(record.designatedGblock), proof), "failed to proof exclusion of deposit");
    return reclaimDeposit_(record);
  }

  function proveIsExcludedFromDeposits(bytes32 root, ProofOfExclusionOfDeposit memory proof) private pure returns (bool) {
    return proof.successor.index == proof.predecessor.index + 1 && // predecessor & successor must be consecutive
      proof.successor.leaf > proof.excluded.hash &&
      proof.predecessor.leaf < proof.excluded.hash &&
      verifyIncludedAtIndex(proof.predecessor.proof, root, proof.predecessor.leaf, proof.predecessor.index) &&
      verifyIncludedAtIndex(proof.successor.proof, root, proof.successor.leaf, proof.successor.index);
  }

  function reclaimDepositOnHalt(address account, bytes memory parameters) private whenOff returns (address asset, uint quantity) {
    (, bytes memory commitmentRecord) = abi.decode(parameters, (uint, bytes));
    DepositCommitmentRecord memory record = parseDepositCommitmentRecord(commitmentRecord);
    require(record.ledgerId == id, 'not from current ledger');
    require(record.account == account, "claimant must be the original depositor");
    require(record.designatedGblock >= data.currentGblockNumber(), "designated gblock is already confirmed; use exitOnHalt instead");
    return reclaimDeposit_(record);
  }

  function encodedDepositOnHaltParameters(address account, address asset, uint quantity, uint32 nonce, uint32 designatedGblock) external view returns (bytes memory) {
    bytes memory encodedPackedDeposit = encodePackedDeposit(id, account, asset, quantity, nonce, designatedGblock);
    return abi.encode(RECLAIM_DEPOSIT_ON_HALT, encodedPackedDeposit);
  }

  function reclaimDeposit_(DepositCommitmentRecord memory record) private returns (address asset, uint quantity) {
    data.deleteDeposit(record.hash);
    emit DepositReclaimed(record.account, record.asset, record.quantity, record.nonce);
    return (record.asset, record.quantity);
  }

  function extractProofOfExclusionOfDeposit(bytes memory recordParameters, bytes32[] memory leaves, uint[] memory indexes, bytes memory predecessor, bytes memory successor) private view returns (ProofOfExclusionOfDeposit memory result) {
    result.excluded = parseDepositCommitmentRecord(recordParameters);
    require(result.excluded.ledgerId == id, 'not from current ledger');
    result.predecessor = ProofOfInclusionAtIndex(leaves[0], indexes[0], predecessor);
    result.successor = ProofOfInclusionAtIndex(leaves[1], indexes[1], successor);
  }

  /**************************************************** Withdrawing ***************************************************/

  function assistedWithdraw(address account, bytes memory parameters) private returns (address asset, uint quantity) {
    (, bytes memory entryBytes, bytes memory signature, bytes memory proof) = abi.decode(parameters, (uint, bytes, bytes, bytes));
    Entry memory entry = parseAndValidateEntry(entryBytes, signature, account);
    require(entry.entryType == EntryType.Withdrawal, "entry must be of type Withdrawal");
    require(proveInConfirmedWithdrawals(proof, entry.gblockNumber, entry.hash), "invalid entry proof");
    require(!data.hasWithdrawn(entry.hash), "entry already withdrawn");
    data.markWithdrawn(entry.hash);
    emit Withdrawn(entry.hash, entry.account, entry.asset, entry.quantity);
    return (entry.asset, entry.quantity);
  }

  function claimExit(address account, bytes memory parameters) private whenOn returns (address asset, uint quantity) {
    (, bytes memory entry_, bytes memory signature, bytes memory proof) = abi.decode(parameters, (uint, bytes, bytes, bytes));
    Entry memory entry = parseAndValidateEntry(entry_, signature, account);
    require(!hasExited(entry.account, entry.asset), "previously exited");
    require(proveInConfirmedBalances(proof, entry.hash), "invalid balance proof");
    uint confirmationThreshold = data.currentGblockNumber() + confirmationDelay;
    data.markExitClaim(entry.hash, confirmationThreshold);
    emit ExitClaimed(entry.hash, entry.account, entry.asset, entry.balance, entry.timestamp, confirmationThreshold);
    return (entry.asset, 0);
  }

  function exit(address account, bytes memory parameters) private whenOn returns (address asset, uint quantity) {
    (, bytes memory entry_, bytes memory signature, bytes memory proof) = abi.decode(parameters, (uint, bytes, bytes, bytes));
    Entry memory entry = parseAndValidateEntry(entry_, signature, account);
    require(!hasExited(entry.account, entry.asset), "previously exited");
    require(canExit(entry.hash), "no prior claim found to withdraw OR balances are yet to be confirmed");
    require(proveInUnconfirmedBalances(proof, entry.hash), "invalid balance proof");
    data.deleteExitClaim(entry.hash);
    exit_(entry);
    return (entry.asset, entry.balance);
  }

  function exitOnHalt(address account, bytes memory parameters) private whenOff returns (address asset, uint quantity) {
    (, bytes memory entry_, bytes memory signature, bytes memory proof) = abi.decode(parameters, (uint, bytes, bytes, bytes));
    Entry memory entry = parseAndValidateEntry(entry_, signature, account);
    require(!hasExited(entry.account, entry.asset), "previously exited");
    require(proveInConfirmedBalances(proof, entry.hash), "invalid balance proof");
    exit_(entry);
    return (entry.asset, entry.balance);
  }

  function exit_(Entry memory entry) private {
    data.markExited(entry.account, entry.asset);
    emit Exited(entry.account, entry.asset, entry.balance);
  }

  function hasExited(address account, address asset) public view returns (bool) { return data.hasExited(account, asset); }

  function canExit(bytes32 entryHash) public view returns (bool) {
    uint confirmationThreshold = data.exitClaims(entryHash);
    return confirmationThreshold != 0 && data.currentGblockNumber() >= confirmationThreshold;
  }

  /**************************************************** FraudProof ****************************************************/

  function canSubmit() public view returns (bool) { return block.number > data.submissionBlock(); }

  function submit(uint32 gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot) public whenOn {
    require(canSubmit(), "cannot submit yet");
    require(msg.sender == operator, "submitter must be the operator");
    require(gblockNumber == data.currentGblockNumber() + 1, "gblock must be the next in sequence");
    data.submit(gblockNumber, withdrawalsRoot, depositsRoot, balancesRoot, submissionInterval);
    emit Submitted(gblockNumber, withdrawalsRoot, depositsRoot, balancesRoot);
  }

  function proveInConfirmedWithdrawals(bytes memory proof, uint32 gblockNumber, bytes32 entryHash) public view returns (bool) {
    return data.isConfirmedGblock(gblockNumber) && verifyIncluded(proof, data.withdrawalsRoot(gblockNumber), entryHash);
  }

  function proveInConfirmedBalances(bytes memory proof, bytes32 entryHash) public view returns (bool) {
    uint32 gblockNumber = data.currentGblockNumber() - 1;
    return verifyIncluded(proof, data.balancesRoot(gblockNumber), entryHash);
  }

  function proveInUnconfirmedBalances(bytes memory proof, bytes32 entryHash) public view returns (bool) {
    uint32 gblockNumber = data.currentGblockNumber();
    return verifyIncluded(proof, data.balancesRoot(gblockNumber), entryHash);
  }

  function parseAndValidateEntry(bytes memory entryBytes, bytes memory signature, address account) private view returns (Entry memory entry) {
    entry = parseEntry(entryBytes, signature);
    require(entry.ledgerId == id, 'entry is not from current ledger');
    require(entry.signer == operator, "failed to verify signature");
    require(entry.account == account, "entry account mismatch");
  }

  /****************************************************** halting ******************************************************/

  function hasBeenAbandoned() public view returns(bool) {
    return block.number > data.submissionBlock() + abandonPoint;
  }

  function abandon() external {
    require(hasBeenAbandoned(), "chain has not yet abandoned");
    switchOff_();
  }

  function switchOff() external onlyOwner {
    switchOff_();
  }
}