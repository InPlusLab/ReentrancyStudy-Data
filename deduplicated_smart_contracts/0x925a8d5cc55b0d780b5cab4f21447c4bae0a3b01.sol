pragma solidity 0.4.15;

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract Ownable {

  // EVENTS

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // PUBLIC FUNCTIONS

  /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
  function Ownable() {
    owner = msg.sender;
  }

  /// @dev Allows the current owner to transfer control of the contract to a newOwner.
  /// @param newOwner The address to transfer ownership to.
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  // MODIFIERS

  /// @dev Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // FIELDS

  address public owner;
}


contract DaoOwnable is Ownable{

    address public dao = address(0);

    event DaoOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the dao.
     */
    modifier onlyDao() {
        require(msg.sender == dao);
        _;
    }

    modifier onlyDaoOrOwner() {
        require(msg.sender == dao || msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newDao.
     * @param newDao The address to transfer ownership to.
     */
    function transferDao(address newDao) onlyOwner {
        require(newDao != address(0));
        dao = newDao;
        DaoOwnershipTransferred(owner, newDao);
    }

}

contract SSPTypeAware {
    enum SSPType { Gate, Direct }
}

contract SSPRegistry is SSPTypeAware{
    // This is the function that actually insert a record.
    function register(address key, SSPType sspType, uint16 publisherFee, address recordOwner);

    // Updates the values of the given record.
    function updatePublisherFee(address key, uint16 newFee, address sender);

    function applyKarmaDiff(address key, uint256[2] diff);

    // Unregister a given record
    function unregister(address key, address sender);

    //Transfer ownership of record
    function transfer(address key, address newOwner, address sender);

    function getOwner(address key) constant returns(address);

    // Tells whether a given key is registered.
    function isRegistered(address key) constant returns(bool);

    function getSSP(address key) constant returns(address sspAddress, SSPType sspType, uint16 publisherFee, uint256[2] karma, address recordOwner);

    function getAllSSP() constant returns(address[] addresses, SSPType[] sspTypes, uint16[] publisherFees, uint256[2][] karmas, address[] recordOwners);

    function kill();
}


contract SSPRegistryImpl is SSPRegistry, DaoOwnable {

    uint public creationTime = now;

    // This struct keeps all data for a SSP.
    struct SSP {
        // Keeps the address of this record creator.
        address owner;
        // Keeps the time when this record was created.
        uint time;
        // Keeps the index of the keys array for fast lookup
        uint keysIndex;
        // SSP Address
        address sspAddress;

        SSPType sspType;

        uint16 publisherFee;

        uint256[2] karma;
    }

    // This mapping keeps the records of this Registry.
    mapping(address => SSP) records;

    // Keeps the total numbers of records in this Registry.
    uint public numRecords;

    // Keeps a list of all keys to interate the records.
    address[] public keys;

    // This is the function that actually insert a record.
    function register(address key, SSPType sspType, uint16 publisherFee, address recordOwner) onlyDaoOrOwner {
        require(records[key].time == 0);
        records[key].time = now;
        records[key].owner = recordOwner;
        records[key].keysIndex = keys.length;
        records[key].sspAddress = key;
        records[key].sspType = sspType;
        records[key].publisherFee = publisherFee;
        keys.length++;
        keys[keys.length - 1] = key;
        numRecords++;
    }

    // Updates the values of the given record.
    function updatePublisherFee(address key, uint16 newFee, address sender) onlyDaoOrOwner {
        // Only the owner can update his record.
        require(records[key].owner == sender);
        records[key].publisherFee = newFee;
    }

    function applyKarmaDiff(address key, uint256[2] diff) onlyDaoOrOwner {
        SSP storage ssp = records[key];
        ssp.karma[0] += diff[0];
        ssp.karma[1] += diff[1];
    }

    // Unregister a given record
    function unregister(address key, address sender) onlyDaoOrOwner {
        require(records[key].owner == sender);
        uint keysIndex = records[key].keysIndex;
        delete records[key];
        numRecords--;
        keys[keysIndex] = keys[keys.length - 1];
        records[keys[keysIndex]].keysIndex = keysIndex;
        keys.length--;
    }

    // Transfer ownership of a given record.
    function transfer(address key, address newOwner, address sender) onlyDaoOrOwner {
        require(records[key].owner == sender);
        records[key].owner = newOwner;
    }

    // Tells whether a given key is registered.
    function isRegistered(address key) constant returns(bool) {
        return records[key].time != 0;
    }

    function getSSP(address key) constant returns(address sspAddress, SSPType sspType, uint16 publisherFee, uint256[2] karma, address recordOwner) {
        SSP storage record = records[key];
        sspAddress = record.sspAddress;
        sspType = record.sspType;
        publisherFee = record.publisherFee;
        karma = record.karma;
        recordOwner = owner;
    }

    // Returns the owner of the given record. The owner could also be get
    // by using the function getSSP but in that case all record attributes
    // are returned.
    function getOwner(address key) constant returns(address) {
        return records[key].owner;
    }

    function getAllSSP() constant returns(address[] addresses, SSPType[] sspTypes, uint16[] publisherFees, uint256[2][] karmas, address[] recordOwners) {
        addresses = new address[](numRecords);
        sspTypes = new SSPType[](numRecords);
        publisherFees = new uint16[](numRecords);
        karmas = new uint256[2][](numRecords);
        recordOwners = new address[](numRecords);
        uint i;
        for(i = 0; i < numRecords; i++) {
            SSP storage ssp = records[keys[i]];
            addresses[i] = ssp.sspAddress;
            sspTypes[i] = ssp.sspType;
            publisherFees[i] = ssp.publisherFee;
            karmas[i] = ssp.karma;
            recordOwners[i] = ssp.owner;
        }
    }

    // Returns the registration time of the given record. The time could also
    // be get by using the function getSSP but in that case all record attributes
    // are returned.
    function getTime(address key) constant returns(uint) {
        return records[key].time;
    }

    function kill() onlyOwner {
        selfdestruct(owner);
    }
}