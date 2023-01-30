pragma solidity ^0.5.0;

import "./Root.sol";

import "./Offering.sol";
import "./OfferingRegistry.sol";
import "./MultiSigWallet.sol";

contract NameBazaarRescue is Ownable {
  bytes32 constant public ETH_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
  bytes32 constant public ETH_LABEL = 0x4f5b812789fc606be1b3b16908db13fc7a9adf7ca72641f84d75b47069d3d7f0;

  Root public root;
  OfferingRegistry public offeringRegistry;
  address public previousRegistrar;

  event ReclaimSuccess(address offering, uint transactionId);

  constructor(address _root, address _offeringRegistry, address _previousRegistrar) public {
    require(_root != address(0));
    require(_offeringRegistry != address(0));
    require(_previousRegistrar != address(0));

    root = Root(_root);
    offeringRegistry = OfferingRegistry(_offeringRegistry);
    previousRegistrar = _previousRegistrar;
  }

  function reclaimOwnerships(address[] memory offerings) public onlyOwner {
    address originalNodeOwner = root.ens().owner(ETH_NODE);
    MultiSigWallet emergencyMultisig = MultiSigWallet(offeringRegistry.emergencyMultisig());

    root.setSubnodeOwner(ETH_LABEL, previousRegistrar);

    for (uint i = 0; i < offerings.length; i++) {
      require(offeringRegistry.isOffering(offerings[i]));
      bool executed = false;
      uint txId = emergencyMultisig.submitTransaction(offerings[i], 0, abi.encodeWithSignature("reclaimOwnership()"));
      (,,,executed) = emergencyMultisig.transactions(txId);

      if (executed) {
        emit ReclaimSuccess(offerings[i], txId);
      } else {
        revert("reclaimOwnership transaction couldn't be executed");
      }
    }

    root.setSubnodeOwner(ETH_LABEL, originalNodeOwner);
  }

}
