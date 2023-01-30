/**

 *Submitted for verification at Etherscan.io on 2019-08-04

*/



// https://tornado.cash

/*

* d888888P                                           dP              a88888b.                   dP

*    88                                              88             d8'   `88                   88

*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.

*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88

*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88

*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP

* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

*/



// File: contracts/MerkleTreeWithHistory.sol



pragma solidity ^0.5.8;



library MiMC {

  function MiMCSponge(uint256 in_xL, uint256 in_xR, uint256 in_k) public pure returns (uint256 xL, uint256 xR);

}



contract MerkleTreeWithHistory {

  uint256 public levels;



  uint8 constant ROOT_HISTORY_SIZE = 100;

  uint256[] private _roots;

  uint256 public current_root = 0;



  uint256[] private _filled_subtrees;

  uint256[] private _zeros;



  uint32 public next_index = 0;



  constructor(uint256 tree_levels, uint256 zero_value) public {

    levels = tree_levels;



    _zeros.push(zero_value);

    _filled_subtrees.push(_zeros[0]);



    for (uint8 i = 1; i < levels; i++) {

      _zeros.push(hashLeftRight(_zeros[i-1], _zeros[i-1]));

      _filled_subtrees.push(_zeros[i]);

    }



    _roots = new uint256[](ROOT_HISTORY_SIZE);

    _roots[0] = hashLeftRight(_zeros[levels - 1], _zeros[levels - 1]);

  }



  function hashLeftRight(uint256 left, uint256 right) public pure returns (uint256 mimc_hash) {

    uint256 k = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    uint256 R = 0;

    uint256 C = 0;



    R = addmod(R, left, k);

    (R, C) = MiMC.MiMCSponge(R, C, 0);



    R = addmod(R, right, k);

    (R, C) = MiMC.MiMCSponge(R, C, 0);



    mimc_hash = R;

  }



  function _insert(uint256 leaf) internal {

    uint32 current_index = next_index;

    require(current_index != 2**(levels - 1), "Merkle tree is full");

    next_index += 1;

    uint256 current_level_hash = leaf;

    uint256 left;

    uint256 right;



    for (uint256 i = 0; i < levels; i++) {

      if (current_index % 2 == 0) {

        left = current_level_hash;

        right = _zeros[i];



        _filled_subtrees[i] = current_level_hash;

      } else {

        left = _filled_subtrees[i];

        right = current_level_hash;

      }



      current_level_hash = hashLeftRight(left, right);



      current_index /= 2;

    }



    current_root = (current_root + 1) % ROOT_HISTORY_SIZE;

    _roots[current_root] = current_level_hash;

  }



  function isKnownRoot(uint256 root) public view returns(bool) {

    if (root == 0) {

      return false;

    }

    // search most recent first

    uint256 i;

    for(i = current_root; i < 2**256 - 1; i--) {

      if (root == _roots[i]) {

        return true;

      }

    }



    // process the rest of roots

    for(i = ROOT_HISTORY_SIZE - 1; i > current_root; i--) {

      if (root == _roots[i]) {

        return true;

      }

    }

    return false;



    // or we can do that in other way

    //   uint256 i = _current_root;

    //   do {

    //       if (root == _roots[i]) {

    //           return true;

    //       }

    //       if (i == 0) {

    //           i = ROOT_HISTORY_SIZE;

    //       }

    //       i--;

    //   } while (i != _current_root);

  }



  function getLastRoot() public view returns(uint256) {

    return _roots[current_root];

  }



  function roots() public view returns(uint256[] memory) {

    return _roots;

  }



  function filled_subtrees() public view returns(uint256[] memory) {

    return _filled_subtrees;

  }



  function zeros() public view returns(uint256[] memory) {

    return _zeros;

  }

}



// File: contracts/Mixer.sol



pragma solidity ^0.5.8;





contract IVerifier {

  function verifyProof(uint256[2] memory a, uint256[2][2] memory b, uint256[2] memory c, uint256[4] memory input) public returns(bool);

}



contract Mixer is MerkleTreeWithHistory {

  uint256 public transferValue;

  bool public isDepositsEnabled = true;

  // operator can disable new deposits in case of emergency

  // it also receives a relayer fee

  address payable public operator;

  mapping(uint256 => bool) public nullifierHashes;

  // we store all commitments just to prevent accidental deposits with the same commitment

  mapping(uint256 => bool) public commitments;

  IVerifier verifier;



  event Deposit(uint256 indexed commitment, uint256 leafIndex, uint256 timestamp);

  event Withdraw(address to, uint256 nullifierHash, uint256 fee);



  /**

    @dev The constructor

    @param _verifier the address of SNARK verifier for this contract

    @param _transferValue the value for all deposits in this contract in wei

  */

  constructor(

    address _verifier,

    uint256 _transferValue,

    uint8 _merkleTreeHeight,

    uint256 _emptyElement,

    address payable _operator

  ) MerkleTreeWithHistory(_merkleTreeHeight, _emptyElement) public {

    verifier = IVerifier(_verifier);

    transferValue = _transferValue;

    operator = _operator;

  }



  /**

    @dev Deposit funds into mixer. The caller must send value equal to `transferValue` of this mixer.

    @param commitment the note commitment, which is PedersenHash(nullifier + secret)

  */

  function deposit(uint256 commitment) public payable {

    require(isDepositsEnabled, "deposits disabled");

    require(msg.value == transferValue, "Please send `transferValue` ETH along with transaction");

    require(!commitments[commitment], "The commitment has been submitted");

    _insert(commitment);

    commitments[commitment] = true;

    emit Deposit(commitment, next_index - 1, block.timestamp);

  }



  /**

    @dev Withdraw deposit from the mixer. `a`, `b`, and `c` are zkSNARK proof data, and input is an array of circuit public inputs

    `input` array consists of:

      - merkle root of all deposits in the mixer

      - hash of unique deposit nullifier to prevent double spends

      - the receiver of funds

      - optional fee that goes to the transaction sender (usually a relay)

  */

  function withdraw(uint256[2] memory a, uint256[2][2] memory b, uint256[2] memory c, uint256[4] memory input) public {

    uint256 root = input[0];

    uint256 nullifierHash = input[1];

    address payable receiver = address(input[2]);

    uint256 fee = input[3];



    require(!nullifierHashes[nullifierHash], "The note has been already spent");

    require(fee < transferValue, "Fee exceeds transfer value");

    require(isKnownRoot(root), "Cannot find your merkle root"); // Make sure to use a recent one

    require(verifier.verifyProof(a, b, c, input), "Invalid withdraw proof");



    nullifierHashes[nullifierHash] = true;

    receiver.transfer(transferValue - fee);

    if (fee > 0) {

      operator.transfer(fee);

    }

    emit Withdraw(receiver, nullifierHash, fee);

  }



  function toggleDeposits() external {

    require(msg.sender == operator, "unauthorized");

    isDepositsEnabled = !isDepositsEnabled;

  }



  function changeOperator(address payable _newAccount) external {

    require(msg.sender == operator, "unauthorized");

    operator = _newAccount;

  }



  function isSpent(uint256 nullifier) public view returns(bool) {

    return nullifierHashes[nullifier];

  }

}