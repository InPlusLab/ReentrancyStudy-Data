/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface AccountInterface {
    function isAuth(address user) external view returns (bool);
    function sheild(address user) external view returns (bool);
    function version() external view returns (uint);
}

interface ListInterface {
    struct UserLink {
        uint64 first;
        uint64 last;
        uint64 count;
    }

    struct UserList {
        uint64 prev;
        uint64 next;
    }

    struct AccountLink {
        address first;
        address last;
        uint64 count;
    }

    struct AccountList {
        address prev;
        address next;
    }

    function accounts() external view returns (uint);
    function accountID(address) external view returns (uint64);
    function accountAddr(uint64) external view returns (address);
    function userLink(address) external view returns (UserLink memory);
    function userList(address, uint64) external view returns (UserList memory);
    function accountLink(uint64) external view returns (AccountLink memory);
    function accountList(uint64, address) external view returns (AccountList memory);

}

interface IndexInterface {
    function master() external view returns (address);
    function list() external view returns (address);
    function connectors(uint) external view returns (address);
    function account(uint) external view returns (address);
    function check(uint) external view returns (address);
    function versionCount() external view returns (uint);

}

interface ConnectorsInterface {
    struct List {
        address prev;
        address next;
    }
    function chief(address) external view returns (bool);
    function connectors(address) external view returns (bool);
    function staticConnectors(address) external view returns (bool);

    function count() external view returns (uint);
    function first() external view returns (address);
    function last() external view returns (address);
    function list(address) external view returns (List memory);
    function staticCount() external view returns (uint);
    function staticList(uint) external view returns (address);

    function isConnector(address[] calldata _connectors) external view returns (bool isOk);
    function isStaticConnector(address[] calldata _connectors) external view returns (bool isOk);

}

contract Helpers {
    address public index = 0x1c503F1544500C05da80cd326D97342f2B13a732;
    address public list;
    address public connectors;
    IndexInterface indexContract;
    ListInterface listContract;
    ConnectorsInterface connectorsContract;
}

contract SmartAccountResolver is Helpers {

    function getID(address account) public view returns(uint id){
        return listContract.accountID(account);
    }

    function getAccount(uint64 id) public view returns(address account){
        return listContract.accountAddr(uint64(id));
    }

    function getOwnerIDs(address owner) public view returns(uint64[] memory){
        ListInterface.UserLink memory userLink = listContract.userLink(owner);
        uint64[] memory IDs = new uint64[](userLink.count);
        uint64 id = userLink.first;
        for (uint i = 0; i < userLink.count; i++) {
            IDs[i] = id;
            ListInterface.UserList memory userList = listContract.userList(owner, id);
            id = userList.next;
        }
        return IDs;
    }

    function getOwnerAccounts(address owner) public view returns(address[] memory){
        uint64[] memory IDs = getOwnerIDs(owner);
        address[] memory accounts = new address[](IDs.length);
        for (uint i = 0; i < IDs.length; i++) {
            accounts[i] = getAccount(IDs[i]);
        }
        return accounts;
    }

    function getIDOwners(uint id) public view returns(address[] memory){
        ListInterface.AccountLink memory accountLink = listContract.accountLink(uint64(id));
        address[] memory owners = new address[](accountLink.count);
        address owner = accountLink.first;
        for (uint i = 0; i < accountLink.count; i++) {
            owners[i] = owner;
            ListInterface.AccountList memory accountList = listContract.accountList(uint64(id), owner);
            owner = accountList.next;
        }
        return owners;
    }

    function getAccountOwners(address account) public view returns(address[] memory){
        return getIDOwners(getID(account));
    }

    function getAccountVersions(address[] memory accounts) public view returns(uint[] memory) {
        uint[] memory versions = new uint[](accounts.length);
        for (uint i = 0; i < accounts.length; i++) {
            versions[i] = AccountInterface(accounts[i]).version();
        }
        return versions;
    }

    struct OwnerData {
        uint64[] IDs;
        address[] accounts;
        uint[] versions;
    }
    function getOwnerDetails(address owner) public view returns(OwnerData memory){
        address[] memory accounts = getOwnerAccounts(owner);
        return OwnerData(
            getOwnerIDs(owner),
            accounts,
            getAccountVersions(accounts)
        );
    }
}


contract ConnectorsResolver is SmartAccountResolver {
    string public constant name = "v1";
    uint public constant version = 1;

    constructor() public{
        indexContract = IndexInterface(index);
        list = indexContract.list();
        listContract = ListInterface(list);
        connectors = indexContract.connectors(version);
        connectorsContract = ConnectorsInterface(connectors);
    }

    function getEnabledConnectores() public view returns(uint, address[] memory){
        uint count = connectorsContract.count();
        address enabledAddr = connectorsContract.first();
        address[] memory addressess = new address[](count);
        addressess[0] = enabledAddr;
        for (uint i = 1; i < count; i++) {
            ConnectorsInterface.List memory list = connectorsContract.list(enabledAddr);
            addressess[i] = list.next;
        }
        return (count, addressess);
    }

    function getStaticConnectores() public view returns(address[] memory){
        uint count = connectorsContract.staticCount();
        address[] memory addressess = new address[](count);
        for (uint i = 0; i < count; i++) {
            addressess[i] = connectorsContract.staticList(i);
        }
        return addressess;
    }
}