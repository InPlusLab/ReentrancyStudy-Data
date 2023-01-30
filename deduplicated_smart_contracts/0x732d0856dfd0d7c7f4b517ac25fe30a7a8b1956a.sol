// "SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

// solhint-disable

enum Operation {Call, Delegatecall}

enum DataFlow {None, In, Out, InAndOut}

interface IGelatoCondition {
    /// @notice GelatoCore calls this to verify securely the specified Condition securely
    /// @dev Be careful only to encode a Task's condition.data as is and not with the
    ///  "ok" selector or _taskReceiptId, since those two things are handled by GelatoCore.
    /// @param _taskReceiptId This is passed by GelatoCore so we can rely on it as a secure
    ///  source of Task identification.
    /// @param _conditionData This is the Condition.data field developers must encode their
    ///  Condition's specific parameters in.
    /// @param _cycleId For Tasks that are executed as part of a cycle.
    function ok(
        uint256 _taskReceiptId,
        bytes calldata _conditionData,
        uint256 _cycleId
    ) external view returns (string memory);
}

struct Condition {
    IGelatoCondition inst; // can be AddressZero for self-conditional Actions
    bytes data; // can be bytes32(0) for self-conditional Actions
}

struct Action {
    address addr;
    bytes data;
    Operation operation;
    DataFlow dataFlow;
    uint256 value;
    bool termsOkCheck;
}

struct Task {
    Condition[] conditions; // optional
    Action[] actions;
    uint256 selfProviderGasLimit; // optional: 0 defaults to gelatoMaxGas
    uint256 selfProviderGasPriceCeil; // optional: 0 defaults to NO_CEIL
}

interface IGelatoProviderModule {
    /// @notice Check if provider agrees to pay for inputted task receipt
    /// @dev Enables arbitrary checks by provider
    /// @param _userProxy The smart contract account of the user who submitted the Task.
    /// @param _provider The account of the Provider who uses the ProviderModule.
    /// @param _task Gelato Task to be executed.
    /// @return "OK" if provider agrees
    function isProvided(
        address _userProxy,
        address _provider,
        Task calldata _task
    ) external view returns (string memory);

    /// @notice Convert action specific payload into proxy specific payload
    /// @dev Encoded multiple actions into a multisend
    /// @param _taskReceiptId Unique ID of Gelato Task to be executed.
    /// @param _userProxy The smart contract account of the user who submitted the Task.
    /// @param _provider The account of the Provider who uses the ProviderModule.
    /// @param _task Gelato Task to be executed.
    /// @param _cycleId For Tasks that form part of a cycle/chain.
    /// @return Encoded payload that will be used for low-level .call on user proxy
    /// @return checkReturndata if true, fwd returndata from userProxy.call to ProviderModule
    function execPayload(
        uint256 _taskReceiptId,
        address _userProxy,
        address _provider,
        Task calldata _task,
        uint256 _cycleId
    ) external view returns (bytes memory, bool checkReturndata);

    /// @notice Called by GelatoCore.exec to verifiy that no revert happend on userProxy
    /// @dev If a caught revert is detected, this fn should revert with the detected error
    /// @param _proxyReturndata Data from GelatoCore._exec.userProxy.call(execPayload)
    function execRevertCheck(bytes calldata _proxyReturndata) external pure;
}

abstract contract GelatoProviderModuleStandard is IGelatoProviderModule {
    string internal constant OK = "OK";

    function isProvided(
        address,
        address,
        Task calldata
    ) external view virtual override returns (string memory) {
        return OK;
    }

    /// @dev Overriding fns should revert with the revertMsg they detected on the userProxy
    function execRevertCheck(bytes calldata) external pure virtual override {
        // By default no reverts detected => do nothing
    }
}

/// @dev InstaDapp Index
interface IndexInterface {
    function connectors(uint256 version) external view returns (address);

    function list() external view returns (address);
}

/// @dev InstaDapp List
interface ListInterface {
    function accountID(address _account) external view returns (uint64);
}

/// @dev InstaDapp Connectors
interface ConnectorsInterface {
    function isConnector(address[] calldata logicAddr)
        external
        view
        returns (bool);

    function isStaticConnector(address[] calldata logicAddr)
        external
        view
        returns (bool);
}

/// @dev InstaDapp Defi Smart Account wallet
interface AccountInterface {
    function version() external view returns (uint256);

    function isAuth(address user) external view returns (bool);

    function shield() external view returns (bool);

    function cast(
        address[] calldata _targets,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32[] memory responses);
}

contract ProviderModuleDSA is GelatoProviderModuleStandard {
    IndexInterface public immutable index;
    address public immutable gelatoCore;

    constructor(IndexInterface _index, address _gelatoCore) {
        index = _index;
        gelatoCore = _gelatoCore;
    }

    // ================= GELATO PROVIDER MODULE STANDARD ================
    function isProvided(
        address _userProxy,
        address,
        Task calldata
    ) external view override returns (string memory) {
        // Verify InstaDapp account identity
        if (ListInterface(index.list()).accountID(_userProxy) == 0)
            return "ProviderModuleDSA.isProvided:InvalidUserProxy";

        // Is GelatoCore authorized
        if (!AccountInterface(_userProxy).isAuth(gelatoCore))
            return "ProviderModuleDSA.isProvided:GelatoCoreNotAuth";

        // @dev commented out for gas savings

        // // Is connector valid
        // ConnectorsInterface connectors = ConnectorsInterface(index.connectors(
        //     AccountInterface(_userProxy).version()
        // ));

        // address[] memory targets = new address[](_task.actions.length);
        // for (uint i = 0; i < _task.actions.length; i++)
        //     targets[i] = _task.actions[i].addr;

        // bool isShield = AccountInterface(_userProxy).shield();
        // if (isShield)
        //     if (!connectors.isStaticConnector(targets))
        //         return "ProviderModuleDSA.isProvided:not-static-connector";
        // else
        //     if (!connectors.isConnector(targets))
        //         return "ProviderModuleDSA.isProvided:not-connector";

        return OK;
    }

    /// @dev DS PROXY ONLY ALLOWS DELEGATE CALL for single actions, that's why we also use multisend
    function execPayload(
        uint256,
        address,
        address,
        Task calldata _task,
        uint256
    ) external view override returns (bytes memory payload, bool) {
        address[] memory targets = new address[](_task.actions.length);
        for (uint256 i = 0; i < _task.actions.length; i++)
            targets[i] = _task.actions[i].addr;

        bytes[] memory datas = new bytes[](_task.actions.length);
        for (uint256 i = 0; i < _task.actions.length; i++)
            datas[i] = _task.actions[i].data;

        payload = abi.encodeWithSelector(
            AccountInterface.cast.selector,
            targets,
            datas,
            gelatoCore
        );
    }
}