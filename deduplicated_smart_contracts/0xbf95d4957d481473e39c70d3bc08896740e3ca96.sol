/**

 *Submitted for verification at Etherscan.io on 2018-10-11

*/



pragma solidity ^0.4.24;



// File: contracts/upgradeability/ImplementationStorage.sol



/**

 * @title ImplementationStorage

 * @dev This contract stores proxy implementation address.

 */

contract ImplementationStorage {



    /**

     * @dev Storage slot with the address of the current implementation.

     * This is the keccak-256 hash of "cvc.proxy.implementation", and is validated in the constructor.

     */

    bytes32 internal constant IMPLEMENTATION_SLOT = 0xa490aab0d89837371982f93f57ffd20c47991f88066ef92475bc8233036969bb;



    /**

    * @dev Constructor

    */

    constructor() public {

        assert(IMPLEMENTATION_SLOT == keccak256("cvc.proxy.implementation"));

    }



    /**

     * @dev Returns the current implementation.

     * @return Address of the current implementation

     */

    function implementation() public view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {

            impl := sload(slot)

        }

    }

}



// File: openzeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */

library AddressUtils {



  /**

   * Returns whether the target address is a contract

   * @dev This function will return false if invoked during the constructor of a contract,

   *  as the code is not actually created until after the constructor finishes.

   * @param addr address to check

   * @return whether the target address is a contract

   */

  function isContract(address addr) internal view returns (bool) {

    uint256 size;

    // XXX Currently there is no better way to check if there is a contract in an address

    // than to check the size of the code at that address.

    // See https://ethereum.stackexchange.com/a/14016/36603

    // for more details about how this works.

    // TODO Check this again before the Serenity release, because all addresses will be

    // contracts then.

    // solium-disable-next-line security/no-inline-assembly

    assembly { size := extcodesize(addr) }

    return size > 0;

  }



}



// File: contracts/upgradeability/CvcProxy.sol



/**

 * @title CvcProxy

 * @dev Transparent proxy with upgradeability functions and authorization control.

 */

contract CvcProxy is ImplementationStorage {



    /**

     * @dev Emitted when the implementation is upgraded.

     * @param implementation Address of the new implementation.

     */

    event Upgraded(address implementation);



    /**

     * @dev Emitted when the administration has been transferred.

     * @param previousAdmin Address of the previous admin.

     * @param newAdmin Address of the new admin.

     */

    event AdminChanged(address previousAdmin, address newAdmin);



    /**

     * @dev Storage slot with the admin of the contract.

     * This is the keccak-256 hash of "cvc.proxy.admin", and is validated in the constructor.

     */

    bytes32 private constant ADMIN_SLOT = 0x2bbac3e52eee27be250d682577104e2abe776c40160cd3167b24633933100433;



    /**

     * @dev Modifier to check whether the `msg.sender` is the admin.

     * It executes the function if called by admin. Otherwise, it will delegate the call to the implementation.

     */

    modifier ifAdmin() {

        if (msg.sender == currentAdmin()) {

            _;

        } else {

            delegate(implementation());

        }

    }



    /**

     * Contract constructor.

     * It sets the `msg.sender` as the proxy admin.

     */

    constructor() public {

        assert(ADMIN_SLOT == keccak256("cvc.proxy.admin"));

        setAdmin(msg.sender);

    }



    /**

     * @dev Fallback function.

     */

    function() external payable {

        require(msg.sender != currentAdmin(), "Message sender is not contract admin");

        delegate(implementation());

    }



    /**

     * @dev Changes the admin of the proxy.

     * Only the current admin can call this function.

     * @param _newAdmin Address to transfer proxy administration to.

     */

    function changeAdmin(address _newAdmin) external ifAdmin {

        require(_newAdmin != address(0), "Cannot change contract admin to zero address");

        emit AdminChanged(currentAdmin(), _newAdmin);

        setAdmin(_newAdmin);

    }



    /**

     * @dev Allows the proxy owner to upgrade the current version of the proxy.

     * @param _implementation the address of the new implementation to be set.

     */

    function upgradeTo(address _implementation) external ifAdmin {

        upgradeImplementation(_implementation);

    }



    /**

     * @dev Allows the proxy owner to upgrade and call the new implementation

     * to initialize whatever is needed through a low level call.

     * @param _implementation the address of the new implementation to be set.

     * @param _data the msg.data to bet sent in the low level call. This parameter may include the function

     * signature of the implementation to be called with the needed payload.

     */

    function upgradeToAndCall(address _implementation, bytes _data) external payable ifAdmin {

        upgradeImplementation(_implementation);

        //solium-disable-next-line security/no-call-value

        require(address(this).call.value(msg.value)(_data), "Upgrade error: initialization method call failed");

    }



    /**

     * @dev Returns the Address of the proxy admin.

     * @return address

     */

    function admin() external view ifAdmin returns (address) {

        return currentAdmin();

    }



    /**

     * @dev Upgrades the implementation address.

     * @param _newImplementation the address of the new implementation to be set

     */

    function upgradeImplementation(address _newImplementation) private {

        address currentImplementation = implementation();

        require(currentImplementation != _newImplementation, "Upgrade error: proxy contract already uses specified implementation");

        setImplementation(_newImplementation);

        emit Upgraded(_newImplementation);

    }



    /**

     * @dev Delegates execution to an implementation contract.

     * This is a low level function that doesn't return to its internal call site.

     * It will return to the external caller whatever the implementation returns.

     * @param _implementation Address to delegate.

     */

    function delegate(address _implementation) private {

        assembly {

            // Copy msg.data.

            calldatacopy(0, 0, calldatasize)



            // Call current implementation passing proxy calldata.

            let result := delegatecall(gas, _implementation, 0, calldatasize, 0, 0)



            // Copy the returned data.

            returndatacopy(0, 0, returndatasize)



            // Propagate result (delegatecall returns 0 on error).

            switch result

            case 0 {revert(0, returndatasize)}

            default {return (0, returndatasize)}

        }

    }



    /**

     * @return The admin slot.

     */

    function currentAdmin() private view returns (address proxyAdmin) {

        bytes32 slot = ADMIN_SLOT;

        assembly {

            proxyAdmin := sload(slot)

        }

    }



    /**

     * @dev Sets the address of the proxy admin.

     * @param _newAdmin Address of the new proxy admin.

     */

    function setAdmin(address _newAdmin) private {

        bytes32 slot = ADMIN_SLOT;

        assembly {

            sstore(slot, _newAdmin)

        }

    }



    /**

     * @dev Sets the implementation address of the proxy.

     * @param _newImplementation Address of the new implementation.

     */

    function setImplementation(address _newImplementation) private {

        require(

            AddressUtils.isContract(_newImplementation),

            "Cannot set new implementation: no contract code at contract address"

        );

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {

            sstore(slot, _newImplementation)

        }

    }



}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



// File: contracts/upgradeability/CvcMigrator.sol



/**

* @title CvcMigrator

* @dev This is a system contract which provides transactional upgrade functionality.

* It allows the ability to add 'upgrade transactions' for multiple proxy contracts and execute all of them in single transaction.

*/

contract CvcMigrator is Ownable {



    /**

    * @dev The ProxyCreated event is emitted when new instance of CvcProxy contract is deployed.

    * @param proxyAddress New proxy contract instance address.

    */

    event ProxyCreated(address indexed proxyAddress);



    struct Migration {

        address proxy;

        address implementation;

        bytes data;

    }



    /// List of registered upgrades.

    Migration[] public migrations;



    /**

    * @dev Store migration record for the next migration

    * @param _proxy Proxy address

    * @param _implementation Implementation address

    * @param _data Pass-through to proxy's updateToAndCall

    */

    function addUpgrade(address _proxy, address _implementation, bytes _data) external onlyOwner {

        require(AddressUtils.isContract(_implementation), "Migrator error: no contract code at new implementation address");

        require(CvcProxy(_proxy).implementation() != _implementation, "Migrator error: proxy contract already uses specified implementation");

        migrations.push(Migration(_proxy, _implementation, _data));

    }



    /**

    * @dev Applies stored upgrades to proxies. Flushes the list of migration records

    */

    function migrate() external onlyOwner {

        for (uint256 i = 0; i < migrations.length; i++) {

            Migration storage migration = migrations[i];

            if (migration.data.length > 0) {

                CvcProxy(migration.proxy).upgradeToAndCall(migration.implementation, migration.data);

            } else {

                CvcProxy(migration.proxy).upgradeTo(migration.implementation);

            }

        }

        delete migrations;

    }



    /**

    * @dev Flushes the migration list without applying them. Can be used in case wrong migration added to the list.

    */

    function reset() external onlyOwner {

        delete migrations;

    }



    /**

    * @dev Transfers ownership from the migrator to a new address

    * @param _target Proxy address

    * @param _newOwner New proxy owner address

    */

    function changeProxyAdmin(address _target, address _newOwner) external onlyOwner {

        CvcProxy(_target).changeAdmin(_newOwner);

    }



    /**

    * @dev Proxy factory

    * @return CvcProxy

    */

    function createProxy() external onlyOwner returns (CvcProxy) {

        CvcProxy proxy = new CvcProxy();

        // We emit event here to retrieve contract address later in the tx receipt

        emit ProxyCreated(address(proxy));

        return proxy;

    }



    /**

    * @dev Returns migration record by index. Will become obsolete as soon as migrations() will be usable via web3.js

    * @param _index 0-based index

    * @return address Proxy address

    * @return address Implementation address

    * @return bytes Pass-through to proxy's updateToAndCall

    */

    function getMigration(uint256 _index) external view returns (address, address, bytes) {

        return (migrations[_index].proxy, migrations[_index].implementation, migrations[_index].data);

    }



    /**

    * @dev Returns current stored migration count

    * @return uint256 Count

    */

    function getMigrationCount() external view returns (uint256) {

        return migrations.length;

    }



}