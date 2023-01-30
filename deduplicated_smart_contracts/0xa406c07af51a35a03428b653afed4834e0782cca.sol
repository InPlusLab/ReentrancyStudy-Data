/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



contract EthicHubBase {



    uint8 public version;



    EthicHubStorageInterface public ethicHubStorage = EthicHubStorageInterface(0);



    constructor(address _storageAddress) public {

        require(_storageAddress != address(0));

        ethicHubStorage = EthicHubStorageInterface(_storageAddress);

    }



}



contract EthicHubStorageInterface {



    //modifier for access in sets and deletes

    modifier onlyEthicHubContracts() {_;}



    // Setters

    function setAddress(bytes32 _key, address _value) external;

    function setUint(bytes32 _key, uint _value) external;

    function setString(bytes32 _key, string _value) external;

    function setBytes(bytes32 _key, bytes _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setInt(bytes32 _key, int _value) external;

    // Deleters

    function deleteAddress(bytes32 _key) external;

    function deleteUint(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;



    // Getters

    function getAddress(bytes32 _key) external view returns (address);

    function getUint(bytes32 _key) external view returns (uint);

    function getString(bytes32 _key) external view returns (string);

    function getBytes(bytes32 _key) external view returns (bytes);

    function getBool(bytes32 _key) external view returns (bool);

    function getInt(bytes32 _key) external view returns (int);

}