/**

 *Submitted for verification at Etherscan.io on 2019-02-13

*/



/*



 Copyright 2017-2018 RigoBlock, Rigo Investment Sagl.



 Licensed under the Apache License, Version 2.0 (the "License");

 you may not use this file except in compliance with the License.

 You may obtain a copy of the License at



     http://www.apache.org/licenses/LICENSE-2.0



 Unless required by applicable law or agreed to in writing, software

 distributed under the License is distributed on an "AS IS" BASIS,

 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

 See the License for the specific language governing permissions and

 limitations under the License.



*/



pragma solidity 0.4.25;

pragma experimental "v0.5.0";



contract Owned {



    address public owner;



    event NewOwner(address indexed old, address indexed current);



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    constructor() public {

        owner = msg.sender;

    }



    function setOwner(address _new)

        public

        onlyOwner

    {

        require(_new != address(0));

        owner = _new;

        emit NewOwner(owner, _new);

    }

}



/// @title Drago Registry Interface - Allows external interaction with Drago Registry.

/// @author Gabriele Rigo - <[email protected]>

// solhint-disable-next-line

interface DragoRegistryFace {



    //EVENTS



    event Registered(string name, string symbol, uint256 id, address indexed drago, address indexed owner, address indexed group);

    event Unregistered(string indexed name, string indexed symbol, uint256 indexed id);

    event MetaChanged(uint256 indexed id, bytes32 indexed key, bytes32 value);



    /*

     * CORE FUNCTIONS

     */

    function register(address _drago, string _name, string _symbol, uint256 _dragoId, address _owner) external payable returns (bool);

    function unregister(uint256 _id) external;

    function setMeta(uint256 _id, bytes32 _key, bytes32 _value) external;

    function addGroup(address _group) external;

    function setFee(uint256 _fee) external;

    function updateOwner(uint256 _id) external;

    function updateOwners(uint256[] _id) external;

    function upgrade(address _newAddress) external payable; //payable as there is a transfer of value, otherwise opcode might throw an error

    function setUpgraded(uint256 _version) external;

    function drain() external;



    /*

     * CONSTANT PUBLIC FUNCTIONS

     */

    function dragoCount() external view returns (uint256);

    function fromId(uint256 _id) external view returns (address drago, string name, string symbol, uint256 dragoId, address owner, address group);

    function fromAddress(address _drago) external view returns (uint256 id, string name, string symbol, uint256 dragoId, address owner, address group);

    function fromName(string _name) external view returns (uint256 id, address drago, string symbol, uint256 dragoId, address owner, address group);

    function getNameFromAddress(address _pool) external view returns (string);

    function getSymbolFromAddress(address _pool) external view returns (string);

    function meta(uint256 _id, bytes32 _key) external view returns (bytes32);

    function getGroups() external view returns (address[]);

    function getFee() external view returns (uint256);

}



/// @title Authority Interface - Allows interaction with the Authority contract.

/// @author Gabriele Rigo - <[email protected]>

// solhint-disable-next-line

interface Authority {



    /*

     * EVENTS

     */

    event AuthoritySet(address indexed authority);

    event WhitelisterSet(address indexed whitelister);

    event WhitelistedUser(address indexed target, bool approved);

    event WhitelistedRegistry(address indexed registry, bool approved);

    event WhitelistedFactory(address indexed factory, bool approved);

    event WhitelistedVault(address indexed vault, bool approved);

    event WhitelistedDrago(address indexed drago, bool isWhitelisted);

    event NewDragoEventful(address indexed dragoEventful);

    event NewVaultEventful(address indexed vaultEventful);

    event NewNavVerifier(address indexed navVerifier);

    event NewExchangesAuthority(address indexed exchangesAuthority);



    /*

     * CORE FUNCTIONS

     */

    function setAuthority(address _authority, bool _isWhitelisted) external;

    function setWhitelister(address _whitelister, bool _isWhitelisted) external;

    function whitelistUser(address _target, bool _isWhitelisted) external;

    function whitelistDrago(address _drago, bool _isWhitelisted) external;

    function whitelistVault(address _vault, bool _isWhitelisted) external;

    function whitelistRegistry(address _registry, bool _isWhitelisted) external;

    function whitelistFactory(address _factory, bool _isWhitelisted) external;

    function setDragoEventful(address _dragoEventful) external;

    function setVaultEventful(address _vaultEventful) external;

    function setNavVerifier(address _navVerifier) external;

    function setExchangesAuthority(address _exchangesAuthority) external;



    /*

     * CONSTANT PUBLIC FUNCTIONS

     */

    function isWhitelistedUser(address _target) external view returns (bool);

    function isAuthority(address _authority) external view returns (bool);

    function isWhitelistedRegistry(address _registry) external view returns (bool);

    function isWhitelistedDrago(address _drago) external view returns (bool);

    function isWhitelistedVault(address _vault) external view returns (bool);

    function isWhitelistedFactory(address _factory) external view returns (bool);

    function getDragoEventful() external view returns (address);

    function getVaultEventful() external view returns (address);

    function getNavVerifier() external view returns (address);

    function getExchangesAuthority() external view returns (address);

}



/// @title Lib Sanitize - Sanitize strings in smart contracts.

/// @author Gabriele Rigo - <[email protected]>

library LibSanitize {



    function isValidCheck(string str)

        internal

        pure

        returns (bool)

    {

        bytes memory bStr = bytes(str);

        uint arrayLength = bStr.length;

        require(bStr[0] != 32);

        require(bStr[arrayLength - 1] != 32);

        for (uint i =0; i < arrayLength; i++) {

            if (

                (

                    bStr[i] < 48 ||

                    bStr[i] > 122 ||

                    (bStr[i] > 57 && bStr[i] < 65) ||

                    (bStr[i] > 90 && bStr[i] < 97 )

                ) && (bStr[i] != 32)

            ) return false;

        } return true;

    }



    function isLowercase(string str)

        internal

        pure

        returns (bool)

    {

        bytes memory bStr = bytes(str);

        uint arrayLength = bStr.length;

		    for (uint i = 0; i < arrayLength; i++) {

			     if ((bStr[i] >= 65) && (bStr[i] <= 90)) return false;

		    } return true;

    }



    function isUppercase(string str)

        internal

        pure

        returns (bool)

    {

        bytes memory bStr = bytes(str);

        uint arrayLength = bStr.length;

        for (uint i = 0; i < arrayLength; i++) {

            if ((bStr[i] >= 97) && (bStr[i] <= 122)) return false;

        } return true;

    }

}



/// @title Drago Registry - Allows registration of pools.

/// @author Gabriele Rigo - <[email protected]>

// solhint-disable-next-line

contract DragoRegistry is DragoRegistryFace, Owned {



    using LibSanitize for bool;



    address public AUTHORITY;

    uint256 public VERSION;



    uint256 public fee = 0;



    address[] groups;



    Drago[] dragos;



    mapping (bytes32 => address) mapFromKey;

    mapping (address => uint256) mapFromAddress;

    mapping (string => uint256) mapFromName;



    struct Drago {

        address drago;

        string name;

        string symbol;

        uint256 dragoId;

        address owner;

        address group;

        mapping (bytes32 => bytes32) meta;

    }



    /*

     * EVENTS

     */

    event Registered(string name, string symbol, uint256 id, address indexed drago, address indexed owner, address indexed group);

    event Unregistered(string indexed name, string indexed symbol, uint256 indexed id);

    event MetaChanged(uint256 indexed id, bytes32 indexed key, bytes32 value);



    /*

     * MODIFIERS

     */

    modifier whenFeePaid {

        require(msg.value >= fee);

        _;

    }



    modifier whenAddressFree(address _drago) {

        require(mapFromAddress[_drago] == 0);

        _;

    }



    modifier onlyDragoOwner(uint256 _id) {

        require(dragos[_id].owner == msg.sender);

        _;

    }



    modifier whenNameFree(string _name) {

        require(mapFromName[_name] == 0);

        _;

    }



    modifier whenNameSanitized(string _input) {

        require(bytes(_input).length >= 4 && bytes(_input).length <= 50);

        require(LibSanitize.isValidCheck(_input));

        _;

    }



    modifier whenSymbolSanitized(string _input) {

        require(bytes(_input).length >= 3 && bytes(_input).length <= 5);

        require(LibSanitize.isValidCheck(_input));

        require(LibSanitize.isUppercase(_input));

        _;

    }



    modifier whenHasName(string _name) {

        require(mapFromName[_name] != 0);

        _;

    }



    modifier onlyAuthority {

        Authority auth = Authority(AUTHORITY);

        require(auth.isAuthority(msg.sender) == true);

        _;

    }



    constructor(address _authority) public {

        AUTHORITY = _authority;

    }



    /*

     * CORE FUNCTIONS

     */

    /// @dev Allows a factory which is an authority to register a pool

    /// @param _drago Address of the pool

    /// @param _name Name of the pool

    /// @param _symbol Symbol of the pool

    /// @param _dragoId Id number of the pool

    /// @param _owner Address of the pool owner

    function register(

        address _drago,

        string _name,

        string _symbol,

        uint256 _dragoId,

        address _owner)

        external

        payable

        onlyAuthority

        whenFeePaid

        whenAddressFree(_drago)

        whenNameSanitized(_name)

        whenSymbolSanitized(_symbol)

        whenNameFree(_name)

        returns (bool)

    {

        return registerAs(_drago, _name, _symbol, _dragoId, _owner, msg.sender);

    }



    /// @dev Allows owner to unregister a pool

    /// @param _id Number of the pool

    function unregister(uint256 _id)

        external

        onlyOwner

    {

        emit Unregistered(dragos[_id].name, dragos[_id].symbol, _id);

        delete mapFromAddress[dragos[_id].drago];

        delete mapFromName[dragos[_id].name];

        delete dragos[_id];

    }



    /// @dev Allows pool owner to set metadata for a pool

    /// @param _id Number corresponding to pool id

    /// @param _key Bytes32 of the key

    /// @param _value Bytes32 of the value

    function setMeta(uint256 _id, bytes32 _key, bytes32 _value)

        external

        onlyDragoOwner(_id)

    {

        dragos[_id].meta[_key] = _value;

        emit MetaChanged(_id, _key, _value);

    }



    /// @dev Allows owner to add a group of pools (a factory)

    /// @param _group Address of the new group

    function addGroup(address _group)

        external

        onlyOwner

    {

        groups.push(_group);

    }



    /// @dev Allows owner to set a fee to register pools

    /// @param _fee Value of the fee in wei

    function setFee(uint256 _fee)

        external

        onlyOwner

    {

        fee = _fee;

    }



    /// @dev Allows anyone to update the owner in the registry

    /// @notice pool owner can change; gets written in registry only when needed

    /// @param _id uint256 of the target pool

    function updateOwner(uint256 _id)

        external

    {

        updateOwnerInternal(_id);

    }



    /// @dev Allows anyone to update many owners if they differ from registered

    /// @param _id uint256 of the target pool

    function updateOwners(uint256[] _id)

        external

    {

        for (uint256 i = 0; i < _id.length; ++i) {

            if (!updateOwnerInternal(_id[i])) continue;

        }

    }



    /// @dev Allows owner to create a new registry.

    /// @dev When the registry gets upgraded, a migration of all funds is required

    /// @param _newAddress Address of new registry.

    function upgrade(address _newAddress)

        external

        payable

        onlyOwner

    {

        DragoRegistry registry = DragoRegistry(_newAddress);

        ++VERSION;

        registry.setUpgraded(VERSION);

        address(registry).transfer(address(this).balance);

    }



    /// @dev Allows owner to update version on registry upgrade

    /// @param _version Number of the new version

    function setUpgraded(uint256 _version)

        external

        onlyOwner

    {

        VERSION = _version;

    }



    /// @dev Allows owner to collect fees by draining the balance

    function drain()

        external

        onlyOwner

    {

        msg.sender.transfer(address(this).balance);

    }



    /*

     * CONSTANT PUBLIC FUNCTIONS

     */

    /// @dev Provides the total number of registered pools

    /// @return Number of pools

    function dragoCount()

        external view

        returns (uint256)

    {

        return dragos.length;

    }



    /// @dev Provides a pool's struct data

    /// @param _id Registration number of the pool

    /// @return Pool struct data

    function fromId(uint256 _id)

        public view //prev external

        returns (

            address drago,

            string name,

            string symbol,

            uint256 dragoId,

            address owner,

            address group

        )

    {

        Drago memory pool = dragos[_id];

        return (

            drago = pool.drago,

            name = pool.name,

            symbol = pool.symbol,

            dragoId = pool.dragoId,

            owner = getPoolOwner(drago),

            group = pool.group

        );

    }



    /// @dev Provides a pool's struct data

    /// @param _drago Address of the pool

    /// @return Pool struct data

    function fromAddress(address _drago)

        external view

        returns (

            uint256 id,

            string name,

            string symbol,

            uint256 dragoId,

            address owner,

            address group

        )

    {

        id = mapFromAddress[_drago] - 1;

        Drago memory pool = dragos[id];

        return (

            id,

            name = pool.name,

            symbol = pool.symbol,

            dragoId = pool.dragoId,

            owner = getPoolOwner(_drago),

            group = pool.group

        );

    }



    /// @dev Provides a pool's struct data

    /// @param _name Name of the pool

    /// @return Pool struct data

    function fromName(string _name)

        external view

        returns (

            uint256 id,

            address drago,

            string symbol,

            uint256 dragoId,

            address owner,

            address group

        )

    {

        id = mapFromName[_name] - 1;

        Drago memory pool = dragos[id];

        return (

            id,

            drago = pool.drago,

            symbol = pool.symbol,

            dragoId = pool.dragoId,

            owner = getPoolOwner(drago),

            group = pool.group

        );

    }



    /// @dev Provides a pool's name from its address

    /// @param _pool Address of the pool

    /// @return Name of the pool

    function getNameFromAddress(address _pool)

        external view

        returns (string)

    {

        uint256 id = mapFromAddress[_pool] - 1;

        Drago memory pool = dragos[id];

        return pool.name;

    }



    /// @dev Provides a pool's symbol from its address

    /// @param _pool Address of the pool

    /// @return Symbol of the pool

    function getSymbolFromAddress(address _pool)

        external view

        returns (string)

    {

        uint256 id = mapFromAddress[_pool] - 1;

        Drago memory pool = dragos[id];

        return pool.symbol;

    }



    /// @dev Provides a pool's metadata

    /// @param _id Id number of the pool

    /// @param _key Bytes32 key

    /// @return Pool metadata

    function meta(uint256 _id, bytes32 _key)

        external view

        returns (bytes32)

    {

        return dragos[_id].meta[_key];

    }



    /// @dev Provides the addresses of the groups/factories

    /// @return Array of addresses of the groups

    function getGroups()

        external view

        returns (address[])

    {

        return groups;

    }



    /// @dev Provides the fee required to register a pool

    /// @return Number of the fee in wei

    function getFee()

        external view

        returns (uint256)

    {

        return fee;

    }



    /*

     * INTERNAL FUNCTIONS

     */

    /// @dev Allows authority to register a pool for a certain group

    /// @param _drago Address of the pool

    /// @param _name Name of the pool

    /// @param _symbol Symbol of the pool

    /// @param _dragoId Id number of the pool

    /// @param _owner Address of the pool owner

    /// @param _group Address of the group/factory

    function registerAs(

        address _drago,

        string _name,

        string _symbol,

        uint256 _dragoId,

        address _owner,

        address _group)

        internal

        returns (bool)

    {

        dragos.push(Drago(_drago, _name, _symbol, _dragoId, _owner, _group));

        mapFromAddress[_drago] = dragos.length;

        mapFromName[_name] = dragos.length;

        emit Registered(_name, _symbol, dragos.length - 1, _drago, _owner, _group);

        return true;

    }



    /// @dev Allows anyone to update the owner in the registry

    /// @notice pool owner can change, but gets written in registry only when needed

    /// @param _id uint256 of the target pool

    /// @return Bollean the transaction was successful

    function updateOwnerInternal(uint256 _id)

        internal

        returns (bool)

    {

        Drago storage pool = dragos[_id];

        address targetPool;

        ( targetPool, , , , , ) = fromId(_id);

        require(getPoolOwner(targetPool) != pool.owner);

        pool.owner = getPoolOwner(targetPool);

        return true;

    }



    /// @dev Returns the actual owner of a pool

    /// @notice queries from the target pool contract itself

    /// @param pool Address of the target pool

    /// @return Address of the pool owner

    function getPoolOwner(address pool)

        internal view

        returns (address)

    {

        return Owned(pool).owner();

    }

}