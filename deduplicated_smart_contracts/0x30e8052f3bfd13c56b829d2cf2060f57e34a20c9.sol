/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

// File: contracts\interfaces\proxy\IProxyManager.sol

pragma solidity 0.5.17;

interface IProxyManager {
    function proxyActions() external view returns (address);
    function proxyActionsStorage() external view returns (address);
}

// File: contracts\interfaces\proxy\IProxyActions.sol

pragma solidity 0.5.17;

interface IProxyActions {
    function setup() external;
}

// File: contracts\interfaces\dss\IVat.sol

pragma solidity 0.5.17;

interface IVat {
    function hope(address usr) external;
    function gem(bytes32, address) external view returns (uint);
    function dai(address) external view returns (uint);
}

// File: contracts\interfaces\dss\IETHJoin.sol

pragma solidity 0.5.17;

interface IETHJoin {
    function join(address usr) external payable;
    function exit(address payable usr, uint wad) external;
}

// File: contracts\interfaces\dss\ITokenJoin.sol

pragma solidity 0.5.17;

interface ITokenJoin {
    function join(address usr, uint wad) external;
    function exit(address usr, uint wad) external;
}

// File: contracts\interfaces\dss\IFlip.sol

pragma solidity 0.5.17;

contract IFlip {
    function tick(uint id) external;
    function tend(uint id, uint lot, uint bid) external;
    function dent(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}

// File: contracts\interfaces\dss\IFlap.sol

pragma solidity 0.5.17;

contract IFlap {
    function tick(uint id) external;
    function tend(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}

// File: contracts\interfaces\dss\IFlop.sol

pragma solidity 0.5.17;

contract IFlop {
    function tick(uint id) external;
    function dent(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}

// File: contracts\interfaces\token\IERC20.sol

pragma solidity 0.5.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\interfaces\proxy\IProxyActionsStorage.sol

pragma solidity 0.5.17;

interface IProxyActionsStorage  {

    function vat() external view returns (IVat);
    function flap() external view returns (IFlap);
    function flop() external view returns (IFlop);

    function tokens(bytes32) external view returns (IERC20);
    function decimals(bytes32) external view returns (uint);
    function ilks(bytes32) external view returns (bytes32);
    function tokenJoins(bytes32) external view returns (ITokenJoin);
    function flips(bytes32) external view returns (IFlip);
}

// File: contracts\proxy\Proxy.sol

pragma solidity 0.5.17;




/*
    A per-user delegatecall proxy.
    When called with data it delegatecalls into ProxyActions.
    Authentication checks are performed in ProxyActions.
 */
contract Proxy {

    IProxyManager private manager;
    IProxyActionsStorage private store;
    address private owner;

    /*
        Constructor is called by ProxyManager.
        After the constructor is done, ProxyManager will call setup()
        which delegatecalls into the actions contract
    */
    constructor(address _owner) public {
        manager = IProxyManager(msg.sender);
        store = IProxyActionsStorage(manager.proxyActionsStorage());
        owner = _owner;
    }

    /*
        When called with data the current addresses for actions and storage
        are requested from ProxyManager. Afterwards a delegatecall is performed
        into the actions contract. In case the delegatecall fails the contract reverts.
    */
    function() external payable {
        if(msg.data.length != 0) {
            address target = manager.proxyActions();
            store = IProxyActionsStorage(manager.proxyActionsStorage());

            // solium-disable-next-line security/no-inline-assembly
            assembly {
                calldatacopy(0, 0, calldatasize())
                let result := delegatecall(gas, target, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 { revert(0, returndatasize()) }
                default { return (0, returndatasize()) }
            }
        }
    }
}

// File: contracts\proxy\ProxyManager.sol

pragma solidity 0.5.17;


/*
    Manages and deploys user's proxies.
    Stores actions and storage contracts.

    Storage and actions can be upgraded
    but have to go through a timelock first.
*/
contract ProxyManager {

    address public owner;
    address public proxyActions;
    address public proxyActionsStorage;

    uint public timelockDuration;
    uint public currentTimelock;

    uint public pendingTimelockDuration;
    address public pendingProxyActions;
    address public pendingProxyActionsStorage;

    mapping(address => address) public proxies;

    event ValuesSubmittedForTimelock(uint pendingTimelockDuration, address pendingProxyActions, address pendingProxyActionsStorage);
    event NewTimelockDuration(uint old, uint updated);
    event NewProxyActions(address old, address updated);
    event NewProxyActionsStorage(address old, address updated);


    modifier onlyOwner {
        require(msg.sender == owner, "ProxyManager / onlyOwner: not allowed");
        _;
    }

    constructor(address _proxyActions, address _proxyActionsStorage) public {
        owner = msg.sender;
        proxyActions = _proxyActions;
        proxyActionsStorage = _proxyActionsStorage;
        timelockDuration = 3 days;

        emit NewTimelockDuration(0, timelockDuration);
        emit NewProxyActions(address(0), _proxyActions);
        emit NewProxyActionsStorage(address(0), _proxyActionsStorage);
    }

    /*
        Submit new values for the timelock.
    */
    function submitTimelockValues(
        uint _pendingTimelockDuration,
        address _pendingProxyActions,
        address _pendingProxyActionsStorage
    ) external onlyOwner {
        require(_pendingTimelockDuration <= 7 days, "ProxyManager / submitTimelockValues: duration too high");

        pendingTimelockDuration = _pendingTimelockDuration;
        pendingProxyActions = _pendingProxyActions;
        pendingProxyActionsStorage = _pendingProxyActionsStorage;

        // solium-disable-next-line security/no-block-members
        currentTimelock = now + timelockDuration;

        emit ValuesSubmittedForTimelock(_pendingTimelockDuration, _pendingProxyActions, _pendingProxyActionsStorage);
    }

    /*
        Implement the values which have
        gone through the timelock.
    */
    function implementTimelockValues() external onlyOwner {
        // solium-disable-next-line security/no-block-members
        require(now > currentTimelock, "ProxyManager / implementTimelockValues: timelock not over");

        if(pendingTimelockDuration != 0) {
            emit NewTimelockDuration(timelockDuration, pendingTimelockDuration);
            timelockDuration = pendingTimelockDuration;
            pendingTimelockDuration = 0;
        }

        if(pendingProxyActions != address(0)) {
            emit NewProxyActions(proxyActions, pendingProxyActions);
            proxyActions = pendingProxyActions;
            pendingProxyActions = address(0);
        }

        if(pendingProxyActionsStorage != address(0)) {
            emit NewProxyActionsStorage(proxyActionsStorage, pendingProxyActionsStorage);
            proxyActionsStorage = pendingProxyActionsStorage;
            pendingProxyActionsStorage = address(0);
        }

        currentTimelock = 0;
    }

    /*
        Deploy a proxy for a user
        and initialize it.
    */
    function deploy() external {
        require(proxies[msg.sender] == address(0), "ProxyManager / deploy: already deployed");
        address newProxy = address(new Proxy(msg.sender));
        proxies[msg.sender] = newProxy;
        IProxyActions(newProxy).setup();
    }
}