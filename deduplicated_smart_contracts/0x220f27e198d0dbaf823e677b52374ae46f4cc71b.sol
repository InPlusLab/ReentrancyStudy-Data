/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity ^0.4.24;



// File: contracts/modules/PermissionManager/IPermissionManager.sol



/**

 * @title Interface to be implemented by all permission manager modules

 */

interface IPermissionManager {



    /**

    * @notice Used to check the permission on delegate corresponds to module contract address

    * @param _delegate Ethereum address of the delegate

    * @param _module Ethereum contract address of the module

    * @param _perm Permission flag

    * @return bool

    */

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool);



    /**

    * @notice Used to add a delegate

    * @param _delegate Ethereum address of the delegate

    * @param _details Details about the delegate i.e `Belongs to financial firm`

    */

    function addDelegate(address _delegate, bytes32 _details) external;



    /**

    * @notice Used to delete a delegate

    * @param _delegate Ethereum address of the delegate

    */

    function deleteDelegate(address _delegate) external;



    /**

    * @notice Used to check if an address is a delegate or not

    * @param _potentialDelegate the address of potential delegate

    * @return bool

    */

    function checkDelegate(address _potentialDelegate) external view returns(bool);



    /**

    * @notice Used to provide/change the permission to the delegate corresponds to the module contract

    * @param _delegate Ethereum address of the delegate

    * @param _module Ethereum contract address of the module

    * @param _perm Permission flag

    * @param _valid Bool flag use to switch on/off the permission

    * @return bool

    */

    function changePermission(

        address _delegate,

        address _module,

        bytes32 _perm,

        bool _valid

    )

    external;



    /**

    * @notice Used to change one or more permissions for a single delegate at once

    * @param _delegate Ethereum address of the delegate

    * @param _modules Multiple module matching the multiperms, needs to be same length

    * @param _perms Multiple permission flag needs to be changed

    * @param _valids Bool array consist the flag to switch on/off the permission

    * @return nothing

    */

    function changePermissionMulti(

        address _delegate,

        address[] _modules,

        bytes32[] _perms,

        bool[] _valids

    )

    external;



    /**

    * @notice Used to return all delegates with a given permission and module

    * @param _module Ethereum contract address of the module

    * @param _perm Permission flag

    * @return address[]

    */

    function getAllDelegatesWithPerm(address _module, bytes32 _perm) external view returns(address[]);



     /**

    * @notice Used to return all permission of a single or multiple module

    * @dev possible that function get out of gas is there are lot of modules and perm related to them

    * @param _delegate Ethereum address of the delegate

    * @param _types uint8[] of types

    * @return address[] the address array of Modules this delegate has permission

    * @return bytes32[] the permission array of the corresponding Modules

    */

    function getAllModulesAndPermsFromTypes(address _delegate, uint8[] _types) external view returns(address[], bytes32[]);



    /**

    * @notice Used to get the Permission flag related the `this` contract

    * @return Array of permission flags

    */

    function getPermissions() external view returns(bytes32[]);



    /**

    * @notice Used to get all delegates

    * @return address[]

    */

    function getAllDelegates() external view returns(address[]);



}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



// File: contracts/libraries/TokenLib.sol



library TokenLib {



    using SafeMath for uint256;



    // Struct for module data

    struct ModuleData {

        bytes32 name;

        address module;

        address moduleFactory;

        bool isArchived;

        uint8[] moduleTypes;

        uint256[] moduleIndexes;

        uint256 nameIndex;

    }



    // Structures to maintain checkpoints of balances for governance / dividends

    struct Checkpoint {

        uint256 checkpointId;

        uint256 value;

    }



    struct InvestorDataStorage {

        // List of investors who have ever held a non-zero token balance

        mapping (address => bool) investorListed;

        // List of token holders

        address[] investors;

        // Total number of non-zero token holders

        uint256 investorCount;

    }



    // Emit when Module is archived from the SecurityToken

    event ModuleArchived(uint8[] _types, address _module, uint256 _timestamp);

    // Emit when Module is unarchived from the SecurityToken

    event ModuleUnarchived(uint8[] _types, address _module, uint256 _timestamp);



    /**

    * @notice Archives a module attached to the SecurityToken

    * @param _moduleData Storage data

    * @param _module Address of module to archive

    */

    function archiveModule(ModuleData storage _moduleData, address _module) public {

        require(!_moduleData.isArchived, "Module archived");

        require(_moduleData.module != address(0), "Module missing");

        /*solium-disable-next-line security/no-block-members*/

        emit ModuleArchived(_moduleData.moduleTypes, _module, now);

        _moduleData.isArchived = true;

    }



    /**

    * @notice Unarchives a module attached to the SecurityToken

    * @param _moduleData Storage data

    * @param _module Address of module to unarchive

    */

    function unarchiveModule(ModuleData storage _moduleData, address _module) public {

        require(_moduleData.isArchived, "Module unarchived");

        /*solium-disable-next-line security/no-block-members*/

        emit ModuleUnarchived(_moduleData.moduleTypes, _module, now);

        _moduleData.isArchived = false;

    }



    /**

     * @notice Validates permissions with PermissionManager if it exists. If there's no permission return false

     * @dev Note that IModule withPerm will allow ST owner all permissions by default

     * @dev this allows individual modules to override this logic if needed (to not allow ST owner all permissions)

     * @param _modules is the modules to check permissions on

     * @param _delegate is the address of the delegate

     * @param _module is the address of the PermissionManager module

     * @param _perm is the permissions data

     * @return success

     */

    function checkPermission(address[] storage _modules, address _delegate, address _module, bytes32 _perm) public view returns(bool) {

        if (_modules.length == 0) {

            return false;

        }



        for (uint8 i = 0; i < _modules.length; i++) {

            if (IPermissionManager(_modules[i]).checkPermission(_delegate, _module, _perm)) {

                return true;

            }

        }



        return false;

    }



    /**

     * @notice Queries a value at a defined checkpoint

     * @param _checkpoints is array of Checkpoint objects

     * @param _checkpointId is the Checkpoint ID to query

     * @param _currentValue is the Current value of checkpoint

     * @return uint256

     */

    function getValueAt(Checkpoint[] storage _checkpoints, uint256 _checkpointId, uint256 _currentValue) public view returns(uint256) {

        //Checkpoint id 0 is when the token is first created - everyone has a zero balance

        if (_checkpointId == 0) {

            return 0;

        }

        if (_checkpoints.length == 0) {

            return _currentValue;

        }

        if (_checkpoints[0].checkpointId >= _checkpointId) {

            return _checkpoints[0].value;

        }

        if (_checkpoints[_checkpoints.length - 1].checkpointId < _checkpointId) {

            return _currentValue;

        }

        if (_checkpoints[_checkpoints.length - 1].checkpointId == _checkpointId) {

            return _checkpoints[_checkpoints.length - 1].value;

        }

        uint256 min = 0;

        uint256 max = _checkpoints.length - 1;

        while (max > min) {

            uint256 mid = (max + min) / 2;

            if (_checkpoints[mid].checkpointId == _checkpointId) {

                max = mid;

                break;

            }

            if (_checkpoints[mid].checkpointId < _checkpointId) {

                min = mid + 1;

            } else {

                max = mid;

            }

        }

        return _checkpoints[max].value;

    }



    /**

     * @notice Stores the changes to the checkpoint objects

     * @param _checkpoints is the affected checkpoint object array

     * @param _newValue is the new value that needs to be stored

     */

    function adjustCheckpoints(TokenLib.Checkpoint[] storage _checkpoints, uint256 _newValue, uint256 _currentCheckpointId) public {

        //No checkpoints set yet

        if (_currentCheckpointId == 0) {

            return;

        }

        //No new checkpoints since last update

        if ((_checkpoints.length > 0) && (_checkpoints[_checkpoints.length - 1].checkpointId == _currentCheckpointId)) {

            return;

        }

        //New checkpoint, so record balance

        _checkpoints.push(

            TokenLib.Checkpoint({

                checkpointId: _currentCheckpointId,

                value: _newValue

            })

        );

    }



    /**

    * @notice Keeps track of the number of non-zero token holders

    * @param _investorData Date releated to investor metrics

    * @param _from Sender of transfer

    * @param _to Receiver of transfer

    * @param _value Value of transfer

    * @param _balanceTo Balance of the _to address

    * @param _balanceFrom Balance of the _from address

    */

    function adjustInvestorCount(

        InvestorDataStorage storage _investorData,

        address _from,

        address _to,

        uint256 _value,

        uint256 _balanceTo,

        uint256 _balanceFrom

        ) public  {

        if ((_value == 0) || (_from == _to)) {

            return;

        }

        // Check whether receiver is a new token holder

        if ((_balanceTo == 0) && (_to != address(0))) {

            _investorData.investorCount = (_investorData.investorCount).add(1);

        }

        // Check whether sender is moving all of their tokens

        if (_value == _balanceFrom) {

            _investorData.investorCount = (_investorData.investorCount).sub(1);

        }

        //Also adjust investor list

        if (!_investorData.investorListed[_to] && (_to != address(0))) {

            _investorData.investors.push(_to);

            _investorData.investorListed[_to] = true;

        }



    }



}