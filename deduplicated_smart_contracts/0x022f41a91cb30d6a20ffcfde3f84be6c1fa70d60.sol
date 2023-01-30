contract UportRegistry {
  event AttributesSet(address indexed _sender, uint _timestamp);

  uint public version;
  address public previousPublishedVersion;

  mapping(address => bytes) public ipfsAttributeLookup;

  function UportRegistry(address _previousPublishedVersion) {
    version = 1;
    previousPublishedVersion = _previousPublishedVersion;
  }

  function setAttributes(bytes ipfsHash) {
    ipfsAttributeLookup[msg.sender] = ipfsHash;
    AttributesSet(msg.sender, now);
  }

  function getAttributes(address personaAddress) constant returns(bytes) {
    return ipfsAttributeLookup[personaAddress];
  }
}