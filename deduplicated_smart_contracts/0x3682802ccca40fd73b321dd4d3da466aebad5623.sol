pragma solidity ^0.5.2;

import "./IERC20.sol";
import "./MerkleProof.sol";

contract TownOfSalem
{
	constructor() public {}

  IERC20 CereneumContract = IERC20(0xd9D4A7CA154fe137c808F7EEDBe24b639B7AF5a6);
  bytes32 public m_hMerkleTreeRoot = 0x7804aa8223f9eff3d1df195fe18d13b2191a7a3ac890aa970a34ccb42520038a;
  mapping(bytes32 => bool) public m_claimedMap;
  uint256 m_nAirdropAmount = 1000000000;  //10 CER
  address m_contractOwner = 0xe0d53E9fd7A9E0251641cB9CC7F70aff579bfbbE;
  address m_returnAddress = 0x8eAf4Fec503da352EB66Ef1E2f75C63e5bC635e1;

  function ClaimAirdrop(
    bytes32 a_hMerkleLeaf,
    bytes32[] memory a_hMerkleTreeBranches
  ) public returns (bool)
  {
    require(m_claimedMap[a_hMerkleLeaf] == false, "Duplicate claim");

    require(MerkleProof.verify(a_hMerkleTreeBranches, m_hMerkleTreeRoot, a_hMerkleLeaf), "Merkle Proof Failed");

    CereneumContract.transfer(msg.sender, m_nAirdropAmount);

    m_claimedMap[a_hMerkleLeaf] = true;
  }

  modifier restricted()
	{
    if (msg.sender == m_contractOwner) _;
  }

  function UpdateMerkleRoot(bytes32 a_hMerkleTreeRoot) public restricted()
  {
    m_hMerkleTreeRoot = a_hMerkleTreeRoot;
  }

  function ReturnCereneum() public restricted()
  {
    CereneumContract.transfer(m_returnAddress, CereneumContract.balanceOf(address(this)));
  }

	function AdjustAirdropAmount(uint256 a_nAirdropAmount) public restricted()
  {
    m_nAirdropAmount = a_nAirdropAmount;
  }
}
