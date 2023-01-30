/**

 *Submitted for verification at Etherscan.io on 2018-11-27

*/



pragma solidity ^0.4.13;



library CertsLib {

  struct SignatureData {

    /* 

     * status == 0x0 => UNKNOWN

     * status == 0x1 => PENDING

     * status == 0x2 => SIGNED

     * Otherwise     => Purpose (sha-256 of data)

     */

    bytes32 status;

    uint exp; // Expiration Date

  }



  struct TransferData {

    address newOwner;

    uint newEntityId;

  }



  struct CertData {

    /*

     * owner == 0 => POE_CERTIFICATE

     * owner != 0 => PROPIETARY_CERTIFICATE

     */

    address owner; // owner of the certificate (in case of being a peer)

    uint entityId; // owner of the certificate (in case of being an entity)

    bytes32 certHash; // sha256 checksum of the certificate JSON data

    string ipfsCertHash; // ipfs multihash address of certificate in json format

    bytes32 dataHash; // sha256 hash of certified data

    string ipfsDataHash; // ipfs multihash address of certified data

    mapping(uint => SignatureData) entities; // signatures from signing entities and their expiration date

    uint[] entitiesArr;

    mapping(address => SignatureData) signatures; // signatures from peers and their expiration date

    address[] signaturesArr;

  }



  struct Data {

    mapping(uint => CertData) certificates;

    mapping(uint => TransferData) transferRequests;

    uint nCerts;

  }



  // METHODS



  /**

   * Creates a new POE certificate

   * @param self {object} - The data containing the certificate mappings

   * @param dataHash {bytes32} - The hash of the certified data

   * @param certHash {bytes32} - The sha256 hash of the json certificate

   * @param ipfsDataHash {string} - The ipfs multihash address of the data (0x00 means unkwon)

   * @param ipfsCertHash {string} - The ipfs multihash address of the certificate in json format (0x00 means unkwon)

   * @return The id of the created certificate     

   */

  function createPOECertificate(Data storage self, bytes32 dataHash, bytes32 certHash, string ipfsDataHash, string ipfsCertHash) public returns (uint) {

    require (hasData(dataHash, certHash, ipfsDataHash, ipfsCertHash));



    uint certId = ++self.nCerts;

    self.certificates[certId] = CertData({

      owner: 0,

      entityId: 0,

      certHash: certHash,

      ipfsCertHash: ipfsCertHash,

      dataHash: dataHash,

      ipfsDataHash: ipfsDataHash,

      entitiesArr: new uint[](0),

      signaturesArr: new address[](0)

    });



    POECertificate(certId);

    return certId;

  }



  /**

   * Creates a new certificate (with known owner). The owner will be the sender unless the entityId (issuer) is supplied.

   * @param self {object} - The data containing the certificate mappings

   * @param ed {object} - The data containing the entity mappings

   * @param dataHash {bytes32} - The hash of the certified data

   * @param certHash {bytes32} - The sha256 hash of the json certificate

   * @param ipfsDataHash {string} - The ipfs multihash address of the data (0x00 means unkwon)

   * @param ipfsCertHash {string} - The ipfs multihash address of the certificate in json format (0x00 means unkwon)

   * @param entityId {uint} - The entity id which issues the certificate (0 if not issued by an entity)

   * @return {uint} The id of the created certificate     

   */

  function createCertificate(Data storage self, EntityLib.Data storage ed, bytes32 dataHash, bytes32 certHash, string ipfsDataHash, string ipfsCertHash, uint entityId) senderCanIssueEntityCerts(ed, entityId) public returns (uint) {

    require (hasData(dataHash, certHash, ipfsDataHash, ipfsCertHash));



    uint certId = ++self.nCerts;

    self.certificates[certId] = CertData({

      owner: entityId == 0 ? msg.sender : 0,

      entityId: entityId,

      certHash: certHash,

      ipfsCertHash: ipfsCertHash,

      dataHash: dataHash,

      ipfsDataHash: ipfsDataHash,

      entitiesArr: new uint[](0),

      signaturesArr: new address[](0)

    });



    Certificate(certId);

    return certId;

  }



  /**

   * Transfers a certificate owner. The owner can be a peer or an entity (never both), so only one of newOwner or newEntity must be different than 0.

   * If the specified certificateId belongs to an entity, the msg.sender must be a valid signer for the entity. Otherwise the msg.sender must be the current owner.

   * @param self {object} - The data containing the certificate mappings

   * @param ed {object} - The data containing the entity mappings

   * @param certificateId {uint} - The id of the certificate to transfer

   * @param newOwner {address} - The address of the new owner

   */

  function requestCertificateTransferToPeer(Data storage self, EntityLib.Data storage ed, uint certificateId, address newOwner) canTransferCertificate(self, ed, certificateId) public {

    self.transferRequests[certificateId] = TransferData({

      newOwner: newOwner,

      newEntityId: 0

    });



    CertificateTransferRequestedToPeer(certificateId, newOwner);

  }



  /**

   * Transfers a certificate owner. The owner can be a peer or an entity (never both), so only one of newOwner or newEntity must be different than 0.

   * If the specified certificateId belongs to an entity, the msg.sender must be a valid signer for the entity. Otherwise the msg.sender must be the current owner.

   * @param self {object} - The data containing the certificate mappings

   * @param ed {object} - The data containing the entity mappings

   * @param certificateId {uint} - The id of the certificate to transfer

   * @param newEntityId {uint} - The id of the new entity

   */

  function requestCertificateTransferToEntity(Data storage self, EntityLib.Data storage ed, uint certificateId, uint newEntityId) entityExists(ed, newEntityId) canTransferCertificate(self, ed, certificateId) public {

    self.transferRequests[certificateId] = TransferData({

      newOwner: 0,

      newEntityId: newEntityId

    });



    CertificateTransferRequestedToEntity(certificateId, newEntityId);

  }



  /**

   * Accept the certificate transfer

   * @param self {object} - The data containing the certificate mappings

   * @param ed {object} - The data containing the entity mappings

   * @param certificateId {uint} - The id of the certificate to transfer

   */

  function acceptCertificateTransfer(Data storage self, EntityLib.Data storage ed, uint certificateId) canAcceptTransfer(self, ed, certificateId) public {

    TransferData storage reqData = self.transferRequests[certificateId];

    self.certificates[certificateId].owner = reqData.newOwner;

    self.certificates[certificateId].entityId = reqData.newEntityId;    

    CertificateTransferAccepted(certificateId, reqData.newOwner, reqData.newEntityId);

    delete self.transferRequests[certificateId];

  }



  /**

   * Cancel any certificate transfer request

   * @param self {object} - The data containing the certificate mappings

   * @param ed {object} - The data containing the entity mappings

   * @param certificateId {uint} - The id of the certificate to transfer

   */

  function cancelCertificateTransfer(Data storage self, EntityLib.Data storage ed, uint certificateId) canTransferCertificate(self, ed, certificateId) public {

    self.transferRequests[certificateId] = TransferData({

      newOwner: 0,

      newEntityId: 0

    });



    CertificateTransferCancelled(certificateId);

  }



  /**

   * Updates ipfs multihashes of a particular certificate

   * @param self {object} - The data containing the certificate mappings

   * @param certId {uint} - The id of the certificate

   * @param ipfsDataHash {string} - The ipfs multihash address of the data (0x00 means unkwon)

   * @param ipfsCertHash {string} - The ipfs multihash address of the certificate in json format (0x00 means unkwon)

   */

  function setIPFSData(Data storage self, uint certId, string ipfsDataHash, string ipfsCertHash) ownsCertificate(self, certId) public {

      self.certificates[certId].ipfsDataHash = ipfsDataHash;

      self.certificates[certId].ipfsCertHash = ipfsCertHash;

      UpdatedIPFSData(certId);

  }



  // HELPERS



  /**

   * Returns true if the certificate has valid data

   * @param dataHash {bytes32} - The hash of the certified data

   * @param certHash {bytes32} - The sha256 hash of the json certificate

   * @param ipfsDataHash {string} - The ipfs multihash address of the data (0x00 means unkwon)

   * @param ipfsCertHash {string} - The ipfs multihash address of the certificate in json format (0x00 means unkwon)   * @return {bool} - True if the certificate contains valid data

   */

  function hasData(bytes32 dataHash, bytes32 certHash, string ipfsDataHash, string ipfsCertHash) pure public returns (bool) {

    return certHash != 0

    || dataHash != 0

    || bytes(ipfsDataHash).length != 0

    || bytes(ipfsCertHash).length != 0;

  }



  // MODIFIERS

  

 /**

   * Returns True if msg.sender is the owner of the specified certificate. False otherwise.

   * @param self {object} - The data containing the certificate mappings

   * @param id {uint} - The id of the certificate 

   */

  modifier ownsCertificate(Data storage self, uint id) {

    require (self.certificates[id].owner == msg.sender);

    _;

  }





  /**

   * Returns TRUE if the specified entity is valid and the sender is a valid signer from the entity.

   * If the entityId is 0 (not provided), it also returns TRUE

   * @param ed {object} - The data containing the entity mappings

   * @param entityId {uint} - The entityId which will issue the certificate

   */

  modifier senderCanIssueEntityCerts(EntityLib.Data storage ed, uint entityId) {

    require (entityId == 0 

     || (EntityLib.isValid(ed, entityId) && ed.entities[entityId].signers[msg.sender].status == 2));

    _;    

  }



  /**

   * Returns TRUE if the certificate has data and can be transfered to the new owner:

   * - When the certificate is owned by a peer: the sender must be the owner of the certificate

   * - When the certificate belongs to an entity: the entity must be valid 

   *   AND the signer must be a valid signer of the entity

   * @param self {object} - The data containing the certificate mappings

   * @param ed {object} - The data containing the entity mappings

   * @param certificateId {uint} - The certificateId which transfer is required

   */

  modifier canTransferCertificate(Data storage self, EntityLib.Data storage ed, uint certificateId) {

    CertData storage cert = self.certificates[certificateId];

    require (hasData(cert.dataHash, cert.certHash, cert.ipfsDataHash, cert.ipfsCertHash));



    if (cert.owner != 0) {

      require (cert.owner == msg.sender);

      _;

    } else if (cert.entityId != 0) {

      EntityLib.EntityData storage entity = ed.entities[cert.entityId];

      require (EntityLib.isValid(ed, cert.entityId) && entity.signers[msg.sender].status == 2);

      _;

    }

  }



  /**

   * Returns TRUE if the entity exists

   */

  modifier entityExists(EntityLib.Data storage ed, uint entityId) {

    require (EntityLib.exists(ed, entityId));

    _;

  }



  /**

   * Returns TRUE if the msg.sender can accept the certificate transfer

   * @param self {object} - The data containing the certificate mappings

   * @param ed {object} - The data containing the entity mappings

   * @param certificateId {uint} - The certificateId which transfer is required

   */

  modifier canAcceptTransfer(Data storage self, EntityLib.Data storage ed, uint certificateId) {

    CertData storage cert = self.certificates[certificateId];

    require (hasData(cert.dataHash, cert.certHash, cert.ipfsDataHash, cert.ipfsCertHash));



    TransferData storage reqData = self.transferRequests[certificateId];

    require(reqData.newEntityId != 0 || reqData.newOwner != 0);



    if (reqData.newOwner == msg.sender) {

      _;

    } else if (reqData.newEntityId != 0) {      

      EntityLib.EntityData storage newEntity = ed.entities[reqData.newEntityId];

      require (EntityLib.isValid(ed, reqData.newEntityId) && newEntity.signers[msg.sender].status == 2);

       _;

    }

  }



  // EVENTS



  event POECertificate(uint indexed certificateId);

  event Certificate(uint indexed certificateId);

  event CertificateTransferRequestedToPeer(uint indexed certificateId, address newOwner);

  event CertificateTransferRequestedToEntity(uint indexed certificateId, uint newEntityId);

  event CertificateTransferAccepted(uint indexed certificateId, address newOwner, uint newEntityId);

  event CertificateTransferCancelled(uint indexed certificateId);

  event UpdatedIPFSData(uint indexed certificateId);

}



library EntityLib {

  struct SignerData {

    string signerDataHash;

    /*

     * status == 0 => NOT_VALID

     * status == 1 => VALIDATION_PENDING

     * status == 2 => VALID

     * status == 3 => DATA_UPDATED

     */

    uint status;

  }



  struct EntityData {

    address owner;

    string dataHash; // hash entity data

    /*

      * status == 0 => NOT_VALID

      * status == 1 => VALIDATION_PENDING

      * status == 2 => VALID

      * status == 4 => RENEWAL_REQUESTED

      * status == 8 => CLOSED

      * otherwise => UNKNOWN

      */

    uint status;

    bytes32 urlHash;         // hash url only

    uint expiration;         // Expiration date

    uint renewalPeriod;      // Renewal period to be used for 3rd party renewals (3rd party paying the validation expenses)

    bytes32 oraclizeQueryId; // Last query Id from oraclize. We will only process the last request



    /*

      * signers[a] == 0;

      * signers[a] = ipfs multihash address for signer data file in json format

      */

    mapping(address => SignerData) signers;

    address[] signersArr;

  }



  struct Data {

    mapping(uint => EntityData) entities;

    mapping(bytes32 => uint) entityIds;

    uint nEntities;

  }



  // METHODS



  /**

   * Creates a new entity

   * @param self {object} - The data containing the entity mappings

   * @param entitDatayHash {string} - The ipfs multihash address of the entity information in json format

   * @param urlHash {bytes32} - The sha256 hash of the URL of the entity

   * @param expirationDate {uint} - The expiration date of the current entity

   * @param renewalPeriod {uint} - The time period which will be added to the current date or expiration date when a renewal is requested

   * @return {uint} The id of the created entity

   */

  function create(Data storage self, uint entityId, string entitDatayHash, bytes32 urlHash, uint expirationDate, uint renewalPeriod) isExpirationDateValid(expirationDate) isRenewalPeriodValid(renewalPeriod) public {

    self.entities[entityId] = EntityData({

        owner: msg.sender,

        dataHash: entitDatayHash,

        urlHash: urlHash,

        status: 1,

        expiration: expirationDate,

        renewalPeriod: renewalPeriod,

        oraclizeQueryId: 0,

        signersArr: new address[](0)

    });

    EntityCreated(entityId);

  }



  /**

   * Process validation after the oraclize callback

   * @param self {object} - The data containing the entity mappings

   * @param queryId {bytes32} - The id of the oraclize query (returned by the call to oraclize_query method)

   * @param result {string} - The result of the query

   */

  function processValidation(Data storage self, bytes32 queryId, string result) public {

    uint entityId = self.entityIds[queryId];

    self.entityIds[queryId] = 0;

    

    EntityData storage entity = self.entities[entityId];



    require (queryId == entity.oraclizeQueryId);



    string memory entityIdStr = uintToString(entityId);

    string memory toCompare = strConcat(entityIdStr, ":", entity.dataHash); 



    if (stringsEqual(result, toCompare)) {

      if (entity.status == 4) { // if entity is waiting for renewal

        uint initDate = max(entity.expiration, now);

        entity.expiration = initDate + entity.renewalPeriod;

      }



      entity.status = 2; // set entity status to valid

      EntityValidated(entityId);

    } else {

      entity.status = 1;  // set entity status to validation pending

      EntityInvalid(entityId);

    }

  }



  /**

   * Sets a new expiration date for the entity. It will trigger an entity validation through the oracle, so it must be paid.

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param expirationDate {uint} - The new expiration date of the entity

   */

  function setExpiration (Data storage self, uint entityId, uint expirationDate) isNotClosed(self, entityId) onlyEntity(self, entityId) isExpirationDateValid(expirationDate) public {

    EntityData storage entity = self.entities[entityId];

    entity.status = 1;

    entity.expiration = expirationDate;

    EntityExpirationSet(entityId);

  }

  

  /**

   * Sets a new renewal interval

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param renewalPeriod {uint} - The new renewal interval (in seconds)

   */

  function setRenewalPeriod (Data storage self, uint entityId, uint renewalPeriod) isNotClosed(self, entityId) onlyEntity(self, entityId) isRenewalPeriodValid(renewalPeriod) public {

    EntityData storage entity = self.entities[entityId];

    entity.renewalPeriod = renewalPeriod;

    EntityRenewalSet(entityId);

  }



  /**

   * Close an entity. This status will not allow further operations on the entity.

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   */

  function closeEntity(Data storage self, uint entityId) isNotClosed(self, entityId) onlyEntity(self, entityId) public {

    self.entities[entityId].status = 8;

    EntityClosed(entityId);

  }



  /**

   * Registers a new signer in an entity

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param signerAddress {address} - The address of the signer to be registered

   * @param signerDataHash {uint} - The IPFS multihash address of signer information in json format

   */

  function registerSigner(Data storage self, uint entityId, address signerAddress, string signerDataHash) isValidEntity(self, entityId) onlyEntity(self, entityId) signerIsNotYetRegistered(self, entityId, signerAddress) public {

    self.entities[entityId].signersArr.push(signerAddress);

    self.entities[entityId].signers[signerAddress] = SignerData({

      signerDataHash: signerDataHash,

      status: 1

    });

    SignerAdded(entityId, signerAddress);

  }



  /**

   * Confirms signer registration

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param signerDataHash {string} - The ipfs data hash of the signer to confirm

   */

  function confirmSignerRegistration(Data storage self, uint entityId, string signerDataHash) isValidEntity(self, entityId) isWaitingConfirmation(self, entityId, signerDataHash) public {

    self.entities[entityId].signers[msg.sender].status = 2;

    SignerConfirmed(entityId, msg.sender);

  }



  /**

   * Removes a signer from an entity

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param signerAddress {address} - The address of the signer to be removed

   */

  function removeSigner(Data storage self, uint entityId, address signerAddress) isValidEntity(self, entityId) onlyEntity(self, entityId) public {

    internalRemoveSigner(self, entityId, signerAddress);

  }





  /**

   * Removes a signer from an entity (internal use, without modifiers)

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param signerAddress {address} - The address of the signer to be removed

   */

  function internalRemoveSigner(Data storage self, uint entityId, address signerAddress) private {

    EntityData storage entity = self.entities[entityId];

    address[] storage signersArr = entity.signersArr;

    SignerData storage signer = entity.signers[signerAddress];



    if (bytes(signer.signerDataHash).length != 0 || signer.status != 0) {

      signer.status = 0;

      signer.signerDataHash = '';

      delete entity.signers[signerAddress];



      // Update array for iterator

      uint i = 0;

      for (i; signerAddress != signersArr[i]; i++) {}

      signersArr[i] = signersArr[signersArr.length - 1];

      signersArr[signersArr.length - 1] = 0;

      signersArr.length = signersArr.length - 1;

      

      SignerRemoved(entityId, signerAddress);

    }

  }



  /**

   * Leave the specified entity (remove signer if found)

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   */

  function leaveEntity(Data storage self, uint entityId) signerBelongsToEntity(self, entityId) public {

    internalRemoveSigner(self, entityId, msg.sender);

  }



  /**

    * Checks if an entity can be validated

    * @param entityId {uint} - The id of the entity to validate

    * @param url {string} - The URL of the entity

    * @return {bytes32} - The id of the oraclize query

    */

  function canValidateSigningEntity(Data storage self, uint entityId, string url) isNotClosed(self, entityId) isRegisteredURL(self, entityId, url) view public returns (bool) {

    return true;

  }



  /**

   * Checks if an entity validity can be renewed

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity to validate

   * @param url {string} - The URL of the entity

   * @return {bool} - True if renewal is possible

   */

  function canRenew(Data storage self, uint entityId, string url) isValidatedEntity(self, entityId) isRenewalPeriod(self, entityId) isRegisteredURL(self, entityId, url) view public returns (bool) {

    return true;

  }



  /**

   * Checks if an entity can issue certificate (from its signers)

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity to check

   * @return {bool} - True if issuance is possible

   */

  function canIssueCertificates(Data storage self, uint entityId) isNotClosed(self, entityId) notExpired(self, entityId) signerBelongsToEntity(self, entityId) view public returns (bool) {

    return true;

  }



  /**

   * @dev Updates entity data

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param entityDataHash {string} - The ipfs multihash address of the entity information in json format

   * @param urlHash {bytes32} - The sha256 hash of the URL of the entity

   */

  function updateEntityData(Data storage self, uint entityId, string entityDataHash, bytes32 urlHash) isNotClosed(self, entityId) onlyEntity(self, entityId) public {

    EntityData storage entity = self.entities[entityId];

    entity.dataHash = entityDataHash;

    entity.urlHash = urlHash;

    entity.status = 1;

    EntityDataUpdated(entityId);

  }





  /**

   * Update the signer data in the requestes entities

   * @param self {object} - The data containing the entity mappings

   * @param entityIds {array} - The ids of the entities to update

   * @param signerDataHash {string} - The ipfs multihash of the new signer data

   */

  function updateSignerData(Data storage self, uint[] entityIds, string signerDataHash) signerBelongsToEntities(self, entityIds) public {

    uint[] memory updated = new uint[](entityIds.length);

    for (uint i = 0; i < entityIds.length; i++) {

      uint entityId = entityIds[i];

      SignerData storage signer = self.entities[entityId].signers[msg.sender];



      if (signer.status != 2) {

        continue;

      }

      signer.status = 3;

      signer.signerDataHash = signerDataHash;

      updated[i] = entityId;

    }

    SignerDataUpdated(updated, msg.sender);

  }



  /**

   * Accepts a new signer data update in the entity

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity

   * @param signerAddress {address} - The address of the signer update to be accepted

   * @param signerDataHash {uint} - The IPFS multihash address of signer information in json format to be accepted

   */

  function acceptSignerUpdate(Data storage self, uint entityId, address signerAddress, string signerDataHash) onlyEntity(self, entityId) notExpired(self, entityId) signerUpdateCanBeAccepted(self, entityId, signerAddress, signerDataHash) public {

    EntityData storage entity = self.entities[entityId];

    entity.signers[signerAddress].status = 2;

    SignerUpdateAccepted(entityId, signerAddress);

  }



  // HELPER METHODS



  /**

   * Returns the max of two numbers

   * @param a {uint} - Input number a

   * @param b {uint} - Input number b

   * @return {uint} - The maximum of the two inputs

   */

  function max(uint a, uint b) pure public returns(uint) {

    if (a > b) {

      return a;

    } else {

      return b;

    }

  }



  /**

   * @dev Compares two strings

   * @param _a {string} - One of the strings

   * @param _b {string} - The other string

   * @return {bool} True if the two strings are equal, false otherwise

   */

  function stringsEqual(string memory _a, string memory _b) pure internal returns (bool) {

    bytes memory a = bytes(_a);

    bytes memory b = bytes(_b);

    if (a.length != b.length)

      return false;

    for (uint i = 0; i < a.length; i ++) {

      if (a[i] != b[i])

        return false;

        }

    return true;

  }



  function strConcat(string _a, string _b, string _c, string _d, string _e) pure internal returns (string){

    bytes memory _ba = bytes(_a);

    bytes memory _bb = bytes(_b);

    bytes memory _bc = bytes(_c);

    bytes memory _bd = bytes(_d);

    bytes memory _be = bytes(_e);

    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

    bytes memory babcde = bytes(abcde);

    uint k = 0;

    for (uint i = 0; i < _ba.length; i++) {babcde[k++] = _ba[i];}

    for (i = 0; i < _bb.length; i++) {babcde[k++] = _bb[i];}

    for (i = 0; i < _bc.length; i++) {babcde[k++] = _bc[i];}

    for (i = 0; i < _bd.length; i++) {babcde[k++] = _bd[i];}

    for (i = 0; i < _be.length; i++) {babcde[k++] = _be[i];}

    return string(babcde);

  }



  function strConcat(string _a, string _b, string _c, string _d) pure internal returns (string) {

      return strConcat(_a, _b, _c, _d, "");

  }



  function strConcat(string _a, string _b, string _c) pure internal returns (string) {

      return strConcat(_a, _b, _c, "", "");

  }



  function strConcat(string _a, string _b) pure internal returns (string) {

      return strConcat(_a, _b, "", "", "");

  }



  // uint to string

  function uintToString(uint v) pure public returns (string) {

    uint maxlength = 100;

    bytes memory reversed = new bytes(maxlength);

    uint i = 0;

    while (v != 0) {

      uint remainder = v % 10;

      v = v / 10;

      reversed[i++] = byte(48 + remainder);

    }

    bytes memory s = new bytes(i); // i + 1 is inefficient

    for (uint j = 0; j < i; j++) {

        s[j] = reversed[i - j - 1]; // to avoid the off-by-one error

    }

    string memory str = string(s); // memory isn't implicitly convertible to storage

    return str;

  }



  /**

   * Set the oraclize query id of the last request

   * @param self {object} - The data containing the entity mappings

   * @param id {uint} - The id of the entity

   * @param queryId {bytes32} - The query id from the oraclize request

   */

  function setOraclizeQueryId(Data storage self, uint id, bytes32 queryId) public {

    self.entities[id].oraclizeQueryId = queryId;

  }



  // Helper functions



  /**

   * Returns True if specified entity is validated or waiting to be renewed. False otherwise.

   * @param self {object} - The data containing the entity mappings

   * @param id {uint} - The id of the entity to check 

   * @return {bool} - True if the entity is validated

   */

  function isValidated(Data storage self, uint id) view public returns (bool) {

    return (id > 0 && (self.entities[id].status == 2 || self.entities[id].status == 4));

  }



 /**

  * Returns True if specified entity is not expired. False otherwise.

  * @param self {object} - The data containing the entity mappings

  * @param id {uint} - The id of the entity to check 

  * @return {bool} - True if the entity is not expired

  */

  function isExpired(Data storage self, uint id) view public returns (bool) {

    return (id > 0 && (self.entities[id].expiration < now));

  }



  /**

  * Returns True if specified entity is closed.

  * @param self {object} - The data containing the entity mappings

  * @param id {uint} - The id of the entity to check 

  * @return {bool} - True if the entity is closed

  */

  function isClosed(Data storage self, uint id) view public returns (bool) {

    return self.entities[id].status == 8;

  }



 /**

   * Returns True if specified entity is validated and not expired

   * @param self {object} - The data containing the entity mappings

   * @param id {uint} - The id of the entity to check 

   * @return {bool} - True if the entity is validated

   */

  function isValid(Data storage self, uint id) view public returns (bool) {

    return isValidated(self, id) && !isExpired(self, id) && !isClosed(self, id);

  }



 /**

   * Returns True if specified entity exists

   * @param self {object} - The data containing the entity mappings

   * @param id {uint} - The id of the entity to check 

   * @return {bool} - True if the entity exists

   */

  function exists(Data storage self, uint id) view public returns(bool) {

    EntityData storage entity = self.entities[id];

    return entity.status > 0;

  }



  // MODIFIERS

  

  /**

   * Valid if the renewal period is less than 31 days

   * @param renewalPeriod {uint} - The renewal period to check (in seconds)

   */

  modifier isRenewalPeriodValid(uint renewalPeriod) {

    require(renewalPeriod >= 0 && renewalPeriod <= 32 * 24 * 60 * 60); // Renewal period less than 32 days

    _;

  }



  /**

   * Valid if the expiration date is in less than 31 days

   * @param expiration {uint} - The expiration date (in seconds)

   */

  modifier isExpirationDateValid(uint expiration) {

    require(expiration - now > 0 && expiration - now <= 32 * 24 * 60 * 60); // Expiration date is in less than 32 days in the future

    _;

  }

  

  /**

   * Returns True if specified entity is validated or waiting to be renewed. False otherwise.

   * @param self {object} - The data containing the entity mappings

   * @param id {uint} - The id of the entity to check 

   */

  modifier isValidatedEntity(Data storage self, uint id) {

    require (isValidated(self, id));

    _;

  }



  /**

   * Returns True if specified entity is validated or waiting to be renewed, not expired and not closed. False otherwise.

   * @param self {object} - The data containing the entity mappings

   * @param id {uint} - The id of the entity to check 

   */

  modifier isValidEntity(Data storage self, uint id) {

    require (isValid(self, id));

    _;

  }



  /**

  * Returns True if specified entity is validated. False otherwise.

  * @param self {object} - The data containing the entity mappings

  * @param id {uint} - The id of the entity to check 

  */

  modifier notExpired(Data storage self, uint id) {

    require (!isExpired(self, id));

    _;  

  }



  /**

    * Returns True if tansaction sent by owner of entity. False otherwise.

    * @param self {object} - The data containing the entity mappings

    * @param id {uint} - The id of the entity to check

    */

  modifier onlyEntity(Data storage self, uint id) {

    require (msg.sender == self.entities[id].owner);

    _;

  }



  /**

    * Returns True if an URL is the one associated to the entity. False otherwise.

    * @param self {object} - The data containing the entity mappings

    * @param entityId {uint} - The id of the entity

    * @param url {string} - The  URL

    */

  modifier isRegisteredURL(Data storage self, uint entityId, string url) {

    require (self.entities[entityId].urlHash == sha256(url));

    _;

  }



  /**

   * Returns True if current time is in renewal period for a valid entity. False otherwise.

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity to check 

   */

  modifier isRenewalPeriod(Data storage self, uint entityId) {

    EntityData storage entity = self.entities[entityId];

    require (entity.renewalPeriod > 0 && entityId > 0 && (entity.expiration - entity.renewalPeriod < now) && entity.status == 2);

    _;

  }



  /**

   * True if sender is registered in entity. False otherwise.

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity 

   */

  modifier signerBelongsToEntity(Data storage self, uint entityId) {

    EntityData storage entity = self.entities[entityId];

    require (entityId > 0 && (bytes(entity.signers[msg.sender].signerDataHash).length != 0) && (entity.signers[msg.sender].status == 2));

    _;

  }



  /**

   * True if sender is registered in all the entities. False otherwise.

   * @param self {object} - The data containing the entity mappings

   * @param entityIds {array} - The ids of the entities

   */

  modifier signerBelongsToEntities(Data storage self, uint[] entityIds) {

    for (uint i = 0; i < entityIds.length; i++) {

      uint entityId = entityIds[i];

      EntityData storage entity = self.entities[entityId];

      require (entityId > 0 && (entity.signers[msg.sender].status != 0));

    }

    _;

  }



  /**

   * True if the signer was not yet added to an entity.

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity 

   * @param signerAddress {address} - The signer to check

   */

  modifier signerIsNotYetRegistered(Data storage self, uint entityId, address signerAddress) {

    EntityData storage entity = self.entities[entityId];

    require (entity.signers[signerAddress].status == 0);

    _;

  }



  /**

   * True if the entity is validated AND the signer has a pending update with a matching IPFS data hash

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity 

   * @param signerAddress {address} - The signer to check

   * @param signerDataHash {string} - The signer IPFS data pending of confirmation

   */

  modifier signerUpdateCanBeAccepted(Data storage self, uint entityId, address signerAddress, string signerDataHash) {

    require (isValid(self, entityId));

    EntityData storage entity = self.entities[entityId];

    string memory oldSignerDatHash = entity.signers[signerAddress].signerDataHash;

    require (entity.signers[signerAddress].status == 3 && stringsEqual(oldSignerDatHash, signerDataHash));

    _;

  }



  /**

   * True if the sender is registered as a signer in entityId and the status is VALIDATION_PENDING. False otherwise.

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity to check

   */

  modifier isWaitingConfirmation(Data storage self, uint entityId, string signerDataHash) {

    EntityData storage entity = self.entities[entityId];

    SignerData storage signer = entity.signers[msg.sender];

    require ((bytes(signer.signerDataHash).length != 0) && (signer.status == 1) && stringsEqual(signer.signerDataHash, signerDataHash));

    _;

  }



  /**

   * True if the entity has not been closed

   * @param self {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity to check

   */

  modifier isNotClosed(Data storage self, uint entityId) {

    require(!isClosed(self, entityId));

    _;

  }



  // EVENTS



  event EntityCreated(uint indexed entityId);

  event EntityValidated(uint indexed entityId);

  event EntityDataUpdated(uint indexed entityId);

  event EntityInvalid(uint indexed entityId);

  event SignerAdded(uint indexed entityId, address indexed signerAddress);

  event SignerDataUpdated(uint[] entities, address indexed signerAddress);

  event SignerUpdateAccepted(uint indexed entityId, address indexed signerAddress);

  event SignerRemoved(uint indexed entityId, address signerAddress);

  event EntityClosed(uint indexed entityId);

  event SignerConfirmed(uint indexed entityId, address signerAddress);

  event EntityExpirationSet(uint indexed entityId);

  event EntityRenewalSet(uint indexed entityId);  

 }



library SignLib {



  // METHODS



  /**

   * Requests the signature for a certificate to an entity.

   * Only one request possible (future ones are renewals)

   * @param ed {object} - The data containing the entity mappings

   * @param cd {object} - The data containing the certificate mappings

   * @param certificateId {uint} - The id of the certificate

   * @param entityId {uint} - The id of the entity

   */

  function requestSignatureToEntity(EntityLib.Data storage ed, CertsLib.Data storage cd, uint certificateId, uint entityId) canRequestSignature(ed, cd, certificateId) isValid(ed, entityId) notHasSigningRequest(cd, certificateId, entityId) public {

    CertsLib.CertData storage certificate = cd.certificates[certificateId];

    addMissingSignature(certificate, entityId, 0x1, 0);

    EntitySignatureRequested(certificateId, entityId);

  }



  /**

   * Requests the signature for a certificate to a peer

   * Only one request possible (future ones are renewals)

   * @param cd {object} - The data containing the certificate mappings

   * @param certificateId {uint} - The id of the certificate

   * @param peer {address} - The address of the peer

   */

  function requestSignatureToPeer(EntityLib.Data storage ed, CertsLib.Data storage cd, uint certificateId, address peer) canRequestSignature(ed, cd, certificateId) notHasPeerSignature(cd, certificateId, peer) public {

    CertsLib.CertData storage certificate = cd.certificates[certificateId];

    addMissingPeerSignature(certificate, peer, 0x1, 0);

    PeerSignatureRequested(certificateId, peer);

  }



    /**

    * Entity signs a certificate with pending request

    * @param ed {object} - The data containing the entity mappings

    * @param cd {object} - The data containing the certificate mappings

    * @param entityId {uint} - The id of the entity

    * @param certificateId {uint} - The id of the certificate

    * @param expiration {uint} - The expiration time of the signature (in seconds)

    * @param _purpose {bytes32} - The sha-256 hash of the purpose data

    */

  function signCertificateAsEntity(EntityLib.Data storage ed, CertsLib.Data storage cd, uint entityId, uint certificateId, uint expiration, bytes32 _purpose) isValid(ed, entityId) signerBelongsToEntity(ed, entityId) hasPendingSignatureOrIsOwner(ed, cd, certificateId, entityId) public {

    CertsLib.CertData storage certificate = cd.certificates[certificateId];

    bytes32 purpose = (_purpose == 0x0 || _purpose == 0x1) ? bytes32(0x2) : _purpose;

    addMissingSignature(certificate, entityId, purpose, expiration);

    CertificateSignedByEntity(certificateId, entityId, msg.sender);

  }



  /**

   * Peer signs a certificate with pending request

   * @param cd {object} - The data containing the certificate mappings

   * @param certificateId {uint} - The id of the certificate

   * @param expiration {uint} - The expiration time of the signature (in seconds)

   * @param _purpose {bytes32} - The sha-256 hash of the purpose data

   */

  function signCertificateAsPeer(CertsLib.Data storage cd, uint certificateId, uint expiration, bytes32 _purpose) hasPendingPeerSignatureOrIsOwner(cd, certificateId) public {

    CertsLib.CertData storage certificate = cd.certificates[certificateId];

    bytes32 purpose = (_purpose == 0x0 || _purpose == 0x1) ? bytes32(0x2) : _purpose;

    addMissingPeerSignature(certificate, msg.sender, purpose, expiration);

    CertificateSignedByPeer(certificateId, msg.sender);

  }



  // HELPER FUNCTIONS



  /**

   * Add an entity signature to the entity signatures array (if missing) and set the specified status and expiration

   * @param certificate {object} - The certificate to add the peer signature

   * @param entityId {uint} - The id of the entity signing the certificate

   * @param status {uint} - The status/purpose of the signature

   * @param expiration {uint} - The expiration time of the signature (in seconds)

   */

  function addMissingSignature(CertsLib.CertData storage certificate, uint entityId, bytes32 status, uint expiration) private {

    uint[] storage entitiesArr = certificate.entitiesArr;

    for (uint i = 0; i < entitiesArr.length && entitiesArr[i] != entityId; i++) {}

    if (i == entitiesArr.length) {

      entitiesArr.push(entityId);

    }

    certificate.entities[entityId].status = status;

    certificate.entities[entityId].exp = expiration;

  }



  /**

   * Add a peer signature to the signatures array (if missing) and set the specified status and expiration

   * @param certificate {object} - The certificate to add the peer signature

   * @param peer {address} - The address of the peer to add signature

   * @param status {uint} - The status/purpose of the signature

   * @param expiration {uint} - The expiration time of the signature (in seconds)

   */

  function addMissingPeerSignature(CertsLib.CertData storage certificate, address peer, bytes32 status, uint expiration) private {

    address[] storage signaturesArr = certificate.signaturesArr;

    for (uint i = 0; i < signaturesArr.length && signaturesArr[i] != peer; i++) {}

    if (i == signaturesArr.length) {

      signaturesArr.push(peer);

    }

    certificate.signatures[peer].status = status;

    certificate.signatures[peer].exp = expiration;

  }



  // MODIFIERS



  /**

   * Returns True if msg.sender is the owner of the specified certificate or the sender is a confirmed signer of certificate entity. False otherwise.

   * @param cd {object} - The data containing the certificate mappings

   * @param id {uint} - The id of the certificate

   */

  modifier canRequestSignature(EntityLib.Data storage ed, CertsLib.Data storage cd, uint id) {

    require (cd.certificates[id].owner == msg.sender ||

      (cd.certificates[id].entityId > 0 && EntityLib.isValid(ed, cd.certificates[id].entityId) && ed.entities[cd.certificates[id].entityId].signers[msg.sender].status == 0x2)

    );

    _;

  }



  /**

   * Returns True if specified entity is validated or waiting to be renewed, not expired and not closed. False otherwise.

   * @param ed {object} - The data containing the entity mappings

   * @param id {uint} - The id of the entity to check 

   */

  modifier isValid(EntityLib.Data storage ed, uint id) {

    require (EntityLib.isValid(ed, id));

    _;

  }



  /**

   * Returns True if specified certificate has not been validated yet by entity. False otherwise.

   * @param cd {object} - The data containing the certificate mappings

   * @param certificateId {uint} - The id of the certificate to check

   * @param entityId {uint} - The id of the entity to check

   */

  modifier notHasSigningRequest(CertsLib.Data storage cd, uint certificateId, uint entityId) {

    require (cd.certificates[certificateId].entities[entityId].status != 0x1);

    _;    

  }



  /**

   * Returns True if specified certificate has not been signed yet. False otherwise;   

   * @param cd {object} - The data containing the certificate mappings

   * @param certificateId {uint} - The id of the certificate to check

   * @param signerAddress {address} - The id of the certificate to check

   */

  modifier notHasPeerSignature(CertsLib.Data storage cd, uint certificateId, address signerAddress) {    

    require (cd.certificates[certificateId].signatures[signerAddress].status != 0x1);

    _;

  }



  /**

   * True if sender address is the owner of the entity or is a signer registered in entity. False otherwise.

   * @param ed {object} - The data containing the entity mappings

   * @param entityId {uint} - The id of the entity 

   */

  modifier signerBelongsToEntity(EntityLib.Data storage ed, uint entityId) {

    require (entityId > 0 && (bytes(ed.entities[entityId].signers[msg.sender].signerDataHash).length != 0) && (ed.entities[entityId].signers[msg.sender].status == 0x2));

    _;

  }



  /**

   * True if a signature request has been sent to entity or the issuer of the certificate is requested entity itself. False otherwise.

   * @param cd {object} - The data containing the certificate mappings

   * @param certificateId {uint} - The id of the certificate to check

   * @param entityId {uint} - The id of the entity to check

   */

  modifier hasPendingSignatureOrIsOwner(EntityLib.Data storage ed, CertsLib.Data storage cd, uint certificateId, uint entityId) {

    require (cd.certificates[certificateId].entities[entityId].status == 0x1 || cd.certificates[certificateId].entityId == entityId);

    _;

  }



  /**

   * True if a signature is pending for the sender or the sender is the owner. False otherwise.

   * @param cd {object} - The data containing the certificate mappings

   * @param certificateId {uint} - The id of the certificate to check

   */

  modifier hasPendingPeerSignatureOrIsOwner(CertsLib.Data storage cd, uint certificateId) {

    require (cd.certificates[certificateId].signatures[msg.sender].status == 0x1 || cd.certificates[certificateId].owner == msg.sender);

    _;

  }



  // EVENTS

  event EntitySignatureRequested(uint indexed certificateId, uint indexed entityId);

  event PeerSignatureRequested(uint indexed certificateId, address indexed signerAddress);

  event CertificateSignedByEntity(uint indexed certificateId, uint indexed entityId, address indexed signerAddress);

  event CertificateSignedByPeer(uint indexed certificateId, address indexed signerAddress);

}