pragma solidity ^0.4.24;

contract Audit {

  struct Proof {
    uint level;         // Audit level
    uint insertedBlock; // Audit's block
    bytes32 ipfsHash;   // IPFS dag-cbor proof
    address auditedBy;  // Audited by address
  }

  event AttachedEvidence(address indexed auditorAddr, bytes32 indexed codeHash, bytes32 ipfsHash);
  event NewAudit(address indexed auditorAddr, bytes32 indexed codeHash);

  // Maps auditor address and code's keccak256 to Audit
  mapping (address => mapping (bytes32 => Proof)) public auditedContracts;
  // Maps auditor address to a list of audit code hashes
  mapping (address => bytes32[]) public auditorContracts;
  
  // Returns code audit level, 0 if not present
  function isVerifiedAddress(address _auditorAddr, address _contractAddr) public view returns(uint) {
    bytes32 codeHash = getCodeHash(_contractAddr);
    return auditedContracts[_auditorAddr][codeHash].level;
  }

  function isVerifiedCode(address _auditorAddr, bytes32 _codeHash) public view returns(uint) {
    return auditedContracts[_auditorAddr][_codeHash].level;
  }

  function getCodeHash(address _contractAddr) public view returns(bytes32) {
      return keccak256(codeAt(_contractAddr));
  }
  
  // Add audit information
  function addAudit(bytes32 _codeHash, uint _level, bytes32 _ipfsHash) public {
    address auditor = msg.sender;
    require(auditedContracts[auditor][_codeHash].insertedBlock == 0);
    auditedContracts[auditor][_codeHash] = Proof({ 
        level: _level,
        auditedBy: auditor,
        insertedBlock: block.number,
        ipfsHash: _ipfsHash
    });
    auditorContracts[auditor].push(_codeHash);
    emit NewAudit(auditor, _codeHash);
  }
  
  // Add evidence to audited code, only author, if _newLevel is different from original
  // updates the contract's level
  function addEvidence(bytes32 _codeHash, uint _newLevel, bytes32 _ipfsHash) public {
    address auditor = msg.sender;
    require(auditedContracts[auditor][_codeHash].insertedBlock != 0);
    if (auditedContracts[auditor][_codeHash].level != _newLevel)
      auditedContracts[auditor][_codeHash].level = _newLevel;
    emit AttachedEvidence(auditor, _codeHash, _ipfsHash);
  }

  function codeAt(address _addr) public view returns (bytes code) {
    assembly {
      // retrieve the size of the code, this needs assembly
      let size := extcodesize(_addr)
      // allocate output byte array - this could also be done without assembly
      // by using o_code = new bytes(size)
      code := mload(0x40)
      // new "memory end" including padding
      mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
      // store length in memory
      mstore(code, size)
      // actually retrieve the code, this needs assembly
      extcodecopy(_addr, add(code, 0x20), 0, size)
    }
  }
}