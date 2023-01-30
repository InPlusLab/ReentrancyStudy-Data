/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

library Address {   
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

   
    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Storage {
    address internal ZERO_ADDRESS = address(0);
    string internal comma = ', ';

    string public website = "https://www.artcertificate.eu/";
    string public constant name = "Artcertificate";
    string public constant symbol = "ART";

    uint256 public nextId = 1;
    mapping(uint => address) internal _owners;
    mapping(uint => uint) internal _numbers;
    mapping(uint => uint) internal _years;
    mapping(uint => bytes32) internal _depositors;
    mapping(uint => bytes32) internal _artists;
    mapping(uint => bytes32) internal _artworks;
    mapping(uint => bytes32) internal _supports;
    mapping(uint => bytes32) internal _dimensions;
    mapping(uint => bytes32) internal _signatures;
    mapping(uint => bytes32) internal _serials;
    mapping(uint => bytes32) internal _photos;
    mapping(uint => bytes32) internal _documents;
    mapping(uint => string) internal _mentions;
    
    mapping(uint => string) internal _artistsStrings;
    mapping(uint => string) internal _artworksStrings;
    mapping(uint => string) internal _photosStrings;
    mapping(uint => string) internal _documentsStrings;

    mapping(address => uint256[]) internal _ownedCertificates;

    uint[] internal _certificateIds;
}

contract StringEncoding {
    function bytes32ToBytes(bytes32 _bytes32) internal pure returns (bytes memory){
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return bytesArray;
    }

    function strLength(string memory s) internal pure returns (uint256) {
        return bytes(s).length;
    }

    function strConcat5(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i;
        for (i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat4(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {
        return strConcat5(_a, _b, _c, _d, "");
    }

    function strConcat3(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        return strConcat5(_a, _b, _c, "", "");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function fromAddress(address addr) internal pure returns(string memory) {
        bytes20 addrBytes = bytes20(addr);
        bytes16 hexAlphabet = "0123456789abcdef";
        bytes memory result = new bytes(42);
        result[0] = "0";
        result[1] = "x";
        for (uint i = 0; i < 20; i++) {
            result[i * 2 + 2] = hexAlphabet[uint8(addrBytes[i] >> 4)];
            result[i * 2 + 3] = hexAlphabet[uint8(addrBytes[i] & 0x0f)];
        }
        return string(result);
    }

    function bytes32Storable(string memory str) internal pure returns(bool) {
        return strLength(str) <= 32;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        assembly {
        result := mload(add(source, 32))
        }
    }
   
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory){
        bytes memory bytesArray = bytes32ToBytes(_bytes32);
        return string(bytesArray);
    }
   
}

/**
 * @author Mathieu Lecoq 
 * https://proapps.fr
 * november 22nd 2020 
 *
 * @dev Property
 * all rights are reserved to ArtCertificate
 */
contract ArtCertificate is Ownable, Storage, StringEncoding {
    using SafeMath for uint256;
    using Address for address;

    event CertificateTransferred(uint certificateId, address indexed _from, address indexed _to);

    modifier onlyCertificateOrContractOwner(uint _id) {
        require(
            (
                isOwner()
                || certificateOwner(_id) == msg.sender
            ),
            "denied : caller must be certificate or contract owner"
        );
        _;
    }

    modifier exists(uint _id) {
        require(
            certificateOwner(_id) != ZERO_ADDRESS,
            "denied : certificate cant be found"
        );
        _;
    }

    modifier noZeroAddress(address _testAddress) {
        require(_testAddress != ZERO_ADDRESS, "denied : zero-address forbidden");
        _;
    }

    function _setDocumentHash(uint tokenId, string memory document) internal {
         if (bytes32Storable(document)) 
            _documents[tokenId] = stringToBytes32(document);
        else _documentsStrings[tokenId] = document;
    }

    function _setPhotoHash(uint tokenId, string memory photo) internal {
        if (bytes32Storable(photo)) 
            _photos[tokenId] = stringToBytes32(photo);
        else _photosStrings[tokenId] = photo;
    }

    function setDocumentHash(uint tokenId, string memory document) public onlyOwner exists(tokenId) {
        _setDocumentHash(tokenId, document);
    }

    function setPhotoHash(uint tokenId, string memory photo) public onlyOwner exists(tokenId) {
        _setPhotoHash(tokenId, photo);
    }

    function setMentions(uint tokenId, string memory mentions) public onlyOwner exists(tokenId) {
        _mentions[tokenId] = mentions;
    }

    function printFull(
        uint year,
        uint number,          
        string memory depositor,
        string memory artist,
        string memory artwork,
        string memory support,
        string memory dimension,
        string memory signature,
        string memory serial,
        string memory photo,
        string memory document,
        string memory mentions
    ) public onlyOwner returns (uint){
        _owners[nextId] = owner();
        _years[nextId] = year;
        _numbers[nextId] = number;
        _depositors[nextId] = stringToBytes32(depositor);
        _supports[nextId] = stringToBytes32(support);
        _dimensions[nextId] = stringToBytes32(dimension);
        _signatures[nextId] = stringToBytes32(signature);
        _serials[nextId] = stringToBytes32(serial);
        _mentions[nextId] = mentions;

        if (bytes32Storable(artist)) 
            _artists[nextId] = stringToBytes32(artist);
        else _artistsStrings[nextId] = artist;

        if (bytes32Storable(artwork)) 
            _artworks[nextId] = stringToBytes32(artwork);
        else _artworksStrings[nextId] = artwork;

        _setPhotoHash(nextId, photo);
        _setDocumentHash(nextId, document);

        _certificateIds.push(nextId);

        _ownedCertificates[owner()].push(nextId);
        
        uint used = nextId;
        nextId = nextId.add(1);

        return used;
    }

    function printMinimal(
        uint number,          
        string memory photo,
        string memory document
    ) public onlyOwner returns(uint) { 
        _setPhotoHash(nextId, photo);
        _setDocumentHash(nextId, document);

        _owners[nextId] = owner();

        _certificateIds.push(nextId);

        _ownedCertificates[owner()].push(nextId);

        _numbers[nextId] = number;
        
        uint used = nextId;
        nextId = nextId.add(1);

        return used;
    }


    /**
    * @dev Website url setter
    * @dev access restricted to contract owner only
    * @param _url the new url to set as the url of the website
    */
    function setWebsiteUrl(string memory _url) public onlyOwner {
        website = _url;
    }

    /**
    * @dev Transfer a certificate to a new owner
    * @dev access restricted to the owner of certificate with `_id` or to the contract owner only
    * @param _id the id of the certificate to transfer ownership of (will be denied if there is no certificate with `_id`)
    * @param _newOwner the ethereum public address of the new certificate owner (will be denied if _newOwner is a contract or the zero-address)
    * @dev emits event CertificateTransferred
    */
    function transfer(uint _id, address _newOwner) public onlyCertificateOrContractOwner(_id) noZeroAddress(_newOwner) exists(_id) {
        require(!Address.isContract(_newOwner), "denied : token ownership cant be transfered to a contract address");
        address oldOwner = certificateOwner(_id);
        _owners[_id] = _newOwner;
        _ownedCertificates[_newOwner].push(_id);
        for (uint i = 0; i < _ownedCertificates[oldOwner].length; i++) {
            if (_ownedCertificates[oldOwner][i] == _id) {
                delete _ownedCertificates[oldOwner][i];
            }
        }
        emit CertificateTransferred(_id, oldOwner, _newOwner);
    }

    function readStackRest(uint _id) internal view returns(string memory) {
        string memory photo = strConcat3(
            'photo: ', 
            (
                (_photos[_id] != bytes32(0)) 
                ? bytes32ToString(_photos[_id]) 
                : _photosStrings[_id]
            ),
            comma
        ); 

        string memory document = strConcat3(
            'document: ', 
            (
                (_documents[_id] != bytes32(0)) 
                ? bytes32ToString(_documents[_id]) 
                : _documentsStrings[_id]
            ),
            comma
        ); 
        // uint : number, year
        string memory number = strConcat3(
            'number: ',
            uint2str(_numbers[_id]),
            comma
        );

        string memory year = strConcat3(
            'year: ',
            uint2str(_years[_id]),
            comma
        );

        // address: owner
        string memory owner = strConcat3(
            'owner: ',
            fromAddress(_owners[_id]),
            comma
        );
        
        string memory part1 = strConcat5(photo, document, number, year, owner);
        
        return strConcat3(part1, 'mentions: ', _mentions[_id]);
    }

    /**
    * @dev Read certificate data
    * @param _id certificate/token id
    * @return certificate string
    */
    function read(uint _id) public view returns(string memory certificate) {
        string memory depositor = strConcat3('depositor: ', bytes32ToString(_depositors[_id]), comma); 
        string memory support = strConcat3('support: ', bytes32ToString(_supports[_id]), comma); 
        string memory dimension = strConcat3('dimension: ', bytes32ToString(_dimensions[_id]), comma); 
        string memory signature = strConcat3('signature: ', bytes32ToString(_signatures[_id]), comma); 
        string memory serial = strConcat3('serial: ', bytes32ToString(_serials[_id]), comma); 
        string memory artist = strConcat3(
            'artist: ', 
            (
                (_artists[_id] != bytes32(0)) 
                ? bytes32ToString(_artists[_id]) 
                : _artistsStrings[_id]
            ),
            comma
        ); 
        string memory artwork = strConcat3(
            'artwork: ', 
            (
                (_artworks[_id] != bytes32(0)) 
                ? bytes32ToString(_artworks[_id]) 
                : _artworksStrings[_id]
            ),
            comma
        );  
        string memory part1 = strConcat5(depositor, support, dimension, signature, serial);
        certificate = strConcat4(part1, artist, artwork, readStackRest(_id));
    }

    /**
    * @dev Returns certificate's owner by id
    * @param _id the id of the certificate to retrieve owner of
    * @return certificate_owner : the owner of certificate with `_id`
    */
    function certificateOwner(uint _id) public view returns(address certificate_owner) {
        return _owners[_id];
    }

    /**
    * @dev Returns owner's certificates
    * @param _owner ethereum public address of the certificate owner
    * @return owner_certificates : list of certificates belonging to `_owner` address
    */
    function ownerCertificates(address _owner) public view returns(uint[] memory owner_certificates) {
        owner_certificates = _ownedCertificates[_owner];
    }

    /**
    * @dev Returns caller's certificates
    * @return my_certificates : list of certificates belonging to caller
    */
    function myCertificates() public view returns(uint[] memory my_certificates) {
        my_certificates = ownerCertificates(msg.sender);
    }

    /**
    * @dev Returns all existing certificates
    * @return uint[] array of unintegers representing the certificates ids
    */
    function certificatesList() public view returns(uint[] memory) {
        return _certificateIds;
    }

}