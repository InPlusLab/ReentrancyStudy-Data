/*

 Copyright 2018 RigoBlock, Rigo Investment Sagl.

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

pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

/// @title Drago Interface - Allows interaction with the Drago contract.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line
interface DragoFace {

    struct Transaction {
        bytes assembledData;
    }

    /*
     * CORE FUNCTIONS
     */
    //function() external payable;
    function buyDrago() external payable returns (bool success);
    function buyDragoOnBehalf(address _hodler) external payable returns (bool success);
    function sellDrago(uint256 _amount) external returns (bool success);
    function setPrices(uint256 _newSellPrice, uint256 _newBuyPrice, uint256 _signaturevaliduntilBlock, bytes32 _hash, bytes calldata _signedData) external;
    function changeMinPeriod(uint32 _minPeriod) external;
    function changeRatio(uint256 _ratio) external;
    function setTransactionFee(uint256 _transactionFee) external;
    function changeFeeCollector(address _feeCollector) external;
    function changeDragoDao(address _dragoDao) external;
    function enforceKyc(bool _enforced, address _kycProvider) external;
    function setAllowance(address _tokenTransferProxy, address _token, uint256 _amount) external;
    function setMultipleAllowances(address _tokenTransferProxy, address[] calldata _tokens, uint256[] calldata _amounts) external;
    function operateOnExchange(address _exchange, Transaction calldata transaction) external returns (bool success);
    function batchOperateOnExchange(address _exchange, Transaction[] calldata transactions) external;

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    function balanceOf(address _who) external view returns (uint256);
    function getEventful() external view returns (address);
    function getData() external view returns (string memory name, string memory symbol, uint256 sellPrice, uint256 buyPrice);
    function calcSharePrice() external view returns (uint256);
    function getAdminData() external view returns (address, address feeCollector, address dragoDao, uint256 ratio, uint256 transactionFee, uint32 minPeriod);
    function getKycProvider() external view returns (address);
    function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bool isValid);
    function totalSupply() external view returns (uint256);
}

/// @title Drago Registry Interface - Allows external interaction with Drago Registry.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line
interface DragoRegistryFace {

    /*
     * CORE FUNCTIONS
     */
    function register(address _drago, string calldata _name, string calldata _symbol, uint256 _dragoId, address _owner) external payable returns (bool);
    function unregister(uint256 _id) external;
    function setMeta(uint256 _id, bytes32 _key, bytes32 _value) external;
    function addGroup(address _group) external;
    function setFee(uint256 _fee) external;
    function updateOwner(uint256 _id) external;
    function updateOwners(uint256[] calldata _id) external;
    function upgrade(address _newAddress) external payable; //payable as there is a transfer of value, otherwise opcode might throw an error
    function setUpgraded(uint256 _version) external;
    function drain() external;

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    function dragoCount() external view returns (uint256);
    function fromId(uint256 _id) external view returns (address drago, string memory name, string memory symbol, uint256 dragoId, address owner, address group);
    function fromAddress(address _drago) external view returns (uint256 id, string memory name, string memory symbol, uint256 dragoId, address owner, address group);
    function fromName(string calldata _name) external view returns (uint256 id, address drago, string memory symbol, uint256 dragoId, address owner, address group);
    function getNameFromAddress(address _pool) external view returns (string memory);
    function getSymbolFromAddress(address _pool) external view returns (string memory);
    function meta(uint256 _id, bytes32 _key) external view returns (bytes32);
    function getGroups() external view returns (address[] memory);
    function getFee() external view returns (uint256);
}

/// @title Drago Data Helper - Allows to query multiple data of a drago at once.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line
contract HGetDragoData {

    struct DragoData {
        string name;
        string symbol;
        uint256 sellPrice;
        uint256 buyPrice;
        address owner;
        address feeCollector;
        address dragoDao;
        uint256 ratio;
        uint256 transactionFee;
        uint256 totalSupply;
        uint256 ethBalance;
        uint32 minPeriod;
        uint256 id;
        address drago;
    }

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    /// @dev Returns structs of infos on a drago from its ID.
    /// @param _dragoRegistry Address of the pools registry.
    /// @param _dragoId Number of the target drago ID.
    /// @return dragoData Structs of data.
    function queryDataFromId(
        address _dragoRegistry,
        uint256 _dragoId)
        external
        view
        returns (
            DragoData memory dragoData
        )
    {
        address drago;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(_dragoRegistry);
        (drago, , , , , ) = dragoRegistryInstance.fromId(_dragoId);
        (
            dragoData
        ) = queryDataInternal(drago);
        dragoData.id = _dragoId;
        dragoData.drago = drago;
    }

    /// @dev Returns structs of infos on a drago from its address.
    /// @param _dragoRegistry Address of the pools registry.
    /// @param _dragoAddress Array of addresses of the target drago.
    /// @return dragoData Arrays of structs of data.
    function queryDataFromAddress(
        address _dragoRegistry,
        address _dragoAddress)
        external
        view
        returns (
            DragoData memory dragoData
        )
    {
        uint256 dragoId;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(_dragoRegistry);
        (dragoId, , , , , ) = dragoRegistryInstance.fromAddress(_dragoAddress);
        (
            dragoData
        ) = queryDataInternal(_dragoAddress);
        dragoData.id = dragoId;
        dragoData.drago = _dragoAddress;
    }

    /// @dev Returns structs of infos on a drago from its ID.
    /// @param _dragoRegistry Address of the drago registry.
    /// @param _dragoIds Array of IDs of the target dragos.
    /// @return Arrays of structs of data and related address of a drago.
    function queryMultiDataFromId(
        address _dragoRegistry,
        uint256[] calldata _dragoIds)
        external
        view
        returns (
            DragoData[] memory
        )
    {
        uint256 length = _dragoIds.length;
        DragoData[] memory dragoData = new DragoData[](length);
        address[] memory dragos = new address[](length);
        address dragoRegistry = _dragoRegistry;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(dragoRegistry);
        for (uint256 i = 0; i < length; i++) {
            uint256 dragoId = _dragoIds[i];
            (dragos[i], , , , , ) = dragoRegistryInstance.fromId(dragoId);
            (
                dragoData[i]
            ) = queryDataInternal(dragos[i]);
            dragoData[i].id = dragoId;
            dragoData[i].drago = dragos[i];
        }
        return(dragoData);
    }

    /// @dev Returns structs of infos on a drago from its address.
    /// @param _dragoRegistry Address of the pools registry.
    /// @param _dragoAddresses Array of addresses of the target dragos.
    /// @return Arrays of structs of data and related address of a drago.
    function queryMultiDataFromAddress(
        address _dragoRegistry,
        address[] calldata _dragoAddresses)
        external
        view
        returns (
            DragoData[] memory
        )
    {
        uint256 length = _dragoAddresses.length;
        DragoData[] memory dragoData = new DragoData[](length);
        uint256[] memory dragoIds = new uint256[](length);
        address[] memory dragos = _dragoAddresses;
        address dragoRegistry = _dragoRegistry;
        DragoRegistryFace dragoRegistryInstance = DragoRegistryFace(dragoRegistry);
        for (uint256 i = 0; i < length; i++) {
            address dragoAddress = dragos[i];
            (dragoIds[i], , , , , ) = dragoRegistryInstance.fromAddress(dragoAddress);
            (
                dragoData[i]
            ) = queryDataInternal(dragos[i]);
            dragoData[i].id = dragoIds[i];
            dragoData[i].drago = dragos[i];
        }
        return(dragoData);
    }

    /*
     * INTERNAL FUNCTIONS
     */
    /// @dev Returns structs of infos on a drago.
    /// @param _drago Array of addresses of the target dragos.
    /// @return dragoData Structs of data.
    function queryDataInternal(
        address _drago)
        internal
        view
        returns (
            DragoData memory dragoData
        )
    {
        DragoFace dragoInstance = DragoFace(_drago);
        (
            dragoData.name,
            dragoData.symbol,
            dragoData.sellPrice,
            dragoData.buyPrice
        ) = dragoInstance.getData();
        (
            dragoData.owner,
            dragoData.feeCollector,
            dragoData.dragoDao,
            dragoData.ratio,
            dragoData.transactionFee,
            dragoData.minPeriod
        ) = dragoInstance.getAdminData();
        dragoData.totalSupply = dragoInstance.totalSupply();
        dragoData.ethBalance = address(_drago).balance;
    }
}