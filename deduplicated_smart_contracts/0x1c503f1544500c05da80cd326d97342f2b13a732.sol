/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

/**
 * @title InstaIndex
 * @dev Main Contract For Smart Account Layer. This is also a factory contract, Which deploys new Smart Accounts.
 * Also Registry for Smart Account Layer.
 */

interface AccountInterface {
    function version() external view returns (uint);
    function enable(address authority) external;
    function cast(address[] calldata _targets, bytes[] calldata _datas, address _origin) external payable returns (bytes32[] memory responses);
}

interface ListInterface {
    function init(address _account) external;
}

contract AddressIndex {

    event LogNewMaster(address master);
    event LogNewCheck(uint accountVersion, address check);
    event LogNewAccount(address _newAccount, address _connectors, address _check);

    // The Master Address.
    address public master;
    // The List Registry Address.
    address public list;

    // Connectors Modules(Account Module Version => Connectors Registry Module Address).
    mapping (uint => address) public connectors;
    // Check Modules(Account Module Version => Check Module Address).
    mapping (uint => address) public check;
    // Account Modules(Account Module Version => Account Module Address).
    mapping (uint => address) public account;
    // Version Count of Account Modules.
    uint public versionCount;

    /**
    * @dev Throws if the sender not is Master Address.
    */
    modifier isMaster() {
        require(msg.sender == master, "not-master");
        _;
    }

    /**
     * @dev Change the Master Address.
     * @param _newMaster New Master Address.
     */
    function changeMaster(address _newMaster) external isMaster {
        require(_newMaster != master, "already-a-master");
        require(_newMaster != address(0), "not-valid-address");
        master = _newMaster;
        emit LogNewMaster(_newMaster);
    }

    /**
     * @dev Change the Check Address of a specfic Account Module version.
     * @param accountVersion Account Module version.
     * @param _newCheck The New Check Address.
     */
    function changeCheck(uint accountVersion, address _newCheck) external isMaster {
        require(_newCheck != check[accountVersion], "already-a-check");
        require(_newCheck != address(0), "not-valid-address");
        check[accountVersion] = _newCheck;
        emit LogNewCheck(accountVersion, _newCheck);
    }

    /**
     * @dev Add New Account Module.
     * @param _newAccount The New Account Module Address.
     * @param _connectors Connectors Registry Module Address.
     * @param _check Check Module Address.
     */
    function addNewAccount(address _newAccount, address _connectors, address _check) external isMaster {
        require(_newAccount != address(0), "not-valid-address");
        versionCount++;
        require(AccountInterface(_newAccount).version() == versionCount, "not-valid-version");
        account[versionCount] = _newAccount;
        if (_connectors != address(0)) connectors[versionCount] = _connectors;
        if (_check != address(0)) check[versionCount] = _check;
        emit LogNewAccount(_newAccount, _connectors, _check);
    }

}

contract CloneFactory is AddressIndex {
    /**
     * @dev Clone a new Account Module.
     * @param version Account Module version to clone.
     */
    function createClone(uint version) internal returns (address result) {
        bytes20 targetBytes = bytes20(account[version]);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    /**
     * @dev Check if Account Module is a clone.
     * @param version Account Module version.
     * @param query Account Module Address.
     */
    function isClone(uint version, address query) external view returns (bool result) {
        bytes20 targetBytes = bytes20(account[version]);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}

contract InstaIndex is CloneFactory {

    event AccountCreated(address sender, address indexed owner, address account, address indexed origin);

    /**
     * @dev Create a new Smart Account for a user and run cast function in the new Smart Account.
     * @param _owner Owner of the Smart Account.
     * @param accountVersion Account Module version.
     * @param _targets Array of Target to run cast function.
     * @param _datas Array of Data(callData) to run cast function.
     * @param _origin Where Smart Account is created.
     */
    function buildWithCast(
        address _owner,
        uint accountVersion,
        address[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (address _account) {
        _account = build(_owner, accountVersion, _origin);
        if (_targets.length > 0) AccountInterface(_account).cast.value(msg.value)(_targets, _datas, _origin);
    }

    /**
     * @dev Create a new Smart Account for a user.
     * @param _owner Owner of the Smart Account.
     * @param accountVersion Account Module version.
     * @param _origin Where Smart Account is created.
     */
    function build(
        address _owner,
        uint accountVersion,
        address _origin
    ) public returns (address _account) {
        require(accountVersion != 0 && accountVersion <= versionCount, "not-valid-account");
        _account = createClone(accountVersion);
        ListInterface(list).init(_account);
        AccountInterface(_account).enable(_owner);
        emit AccountCreated(msg.sender, _owner, _account, _origin);
    }

    /**
     * @dev Setup Initial things for InstaIndex, after its been deployed and can be only run once.
     * @param _master The Master Address.
     * @param _list The List Address.
     * @param _account The Account Module Address.
     * @param _connectors The Connectors Registry Module Address.
     */
    function setBasics(
        address _master,
        address _list,
        address _account,
        address _connectors
    ) external {
        require(
            master == address(0) &&
            list == address(0) &&
            account[1] == address(0) &&
            connectors[1] == address(0) &&
            versionCount == 0,
            "already-defined"
        );
        master = _master;
        list = _list;
        versionCount++;
        account[versionCount] = _account;
        connectors[versionCount] = _connectors;
    }

}