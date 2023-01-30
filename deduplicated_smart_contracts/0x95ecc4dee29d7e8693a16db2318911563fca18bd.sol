/**

 *Submitted for verification at Etherscan.io on 2019-05-28

*/



// File: contracts/AssetInterface.sol



pragma solidity 0.5.8;





contract AssetInterface {

    function _performTransferWithReference(

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    public returns(bool);



    function _performTransferToICAPWithReference(

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    public returns(bool);



    function _performApprove(address _spender, uint _value, address _sender)

    public returns(bool);



    function _performTransferFromWithReference(

        address _from,

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    public returns(bool);



    function _performTransferFromToICAPWithReference(

        address _from,

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    public returns(bool);



    function _performGeneric(bytes memory, address) public payable {

        revert();

    }

}



// File: contracts/ERC20Interface.sol



pragma solidity 0.5.8;





contract ERC20Interface {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed from, address indexed spender, uint256 value);



    function totalSupply() public view returns(uint256 supply);

    function balanceOf(address _owner) public view returns(uint256 balance);

    // solhint-disable-next-line no-simple-event-func-name

    function transfer(address _to, uint256 _value) public returns(bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);

    function approve(address _spender, uint256 _value) public returns(bool success);

    function allowance(address _owner, address _spender) public view returns(uint256 remaining);



    // function symbol() constant returns(string);

    function decimals() public view returns(uint8);

    // function name() constant returns(string);

}



// File: contracts/AssetProxyInterface.sol



pragma solidity 0.5.8;







contract AssetProxyInterface is ERC20Interface {

    function _forwardApprove(address _spender, uint _value, address _sender)

    public returns(bool);



    function _forwardTransferFromWithReference(

        address _from,

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    public returns(bool);



    function _forwardTransferFromToICAPWithReference(

        address _from,

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    public returns(bool);



    function recoverTokens(ERC20Interface _asset, address _receiver, uint _value)

    public returns(bool);



    function etoken2() external view returns(address); // To be replaced by the implicit getter;



    // To be replaced by the implicit getter;

    function etoken2Symbol() external view returns(bytes32);

}



// File: smart-contracts-common/contracts/Bytes32.sol



pragma solidity 0.5.8;





contract Bytes32 {

    function _bytes32(string memory _input) internal pure returns(bytes32 result) {

        assembly {

            result := mload(add(_input, 32))

        }

    }

}



// File: smart-contracts-common/contracts/ReturnData.sol



pragma solidity 0.5.8;





contract ReturnData {

    function _returnReturnData(bool _success) internal pure {

        assembly {

            let returndatastart := 0

            returndatacopy(returndatastart, 0, returndatasize)

            switch _success case 0 { revert(returndatastart, returndatasize) }

                default { return(returndatastart, returndatasize) }

        }

    }



    function _assemblyCall(address _destination, uint _value, bytes memory _data)

    internal returns(bool success) {

        assembly {

            success := call(gas, _destination, _value, add(_data, 32), mload(_data), 0, 0)

        }

    }

}



// File: contracts/Asset.sol



pragma solidity 0.5.8;













/**

 * @title EToken2 Asset implementation contract.

 *

 * Basic asset implementation contract, without any additional logic.

 * Every other asset implementation contracts should derive from this one.

 * Receives calls from the proxy, and calls back immediately without arguments modification.

 *

 * Note: all the non constant functions return false instead of throwing in case if state change

 * didn't happen yet.

 */

contract Asset is AssetInterface, Bytes32, ReturnData {

    // Assigned asset proxy contract, immutable.

    AssetProxyInterface public proxy;



    /**

     * Only assigned proxy is allowed to call.

     */

    modifier onlyProxy() {

        if (address(proxy) == msg.sender) {

            _;

        }

    }



    /**

     * Sets asset proxy address.

     *

     * Can be set only once.

     *

     * @param _proxy asset proxy contract address.

     *

     * @return success.

     * @dev function is final, and must not be overridden.

     */

    function init(AssetProxyInterface _proxy) public returns(bool) {

        if (address(proxy) != address(0)) {

            return false;

        }

        proxy = _proxy;

        return true;

    }



    /**

     * Passes execution into virtual function.

     *

     * Can only be called by assigned asset proxy.

     *

     * @return success.

     * @dev function is final, and must not be overridden.

     */

    function _performTransferWithReference(

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    public onlyProxy() returns(bool) {

        if (isICAP(_to)) {

            return _transferToICAPWithReference(

                bytes20(_to), _value, _reference, _sender);

        }

        return _transferWithReference(_to, _value, _reference, _sender);

    }



    /**

     * Calls back without modifications.

     *

     * @return success.

     * @dev function is virtual, and meant to be overridden.

     */

    function _transferWithReference(

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        return proxy._forwardTransferFromWithReference(

            _sender, _to, _value, _reference, _sender);

    }



    /**

     * Passes execution into virtual function.

     *

     * Can only be called by assigned asset proxy.

     *

     * @return success.

     * @dev function is final, and must not be overridden.

     */

    function _performTransferToICAPWithReference(

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    public onlyProxy() returns(bool) {

        return _transferToICAPWithReference(_icap, _value, _reference, _sender);

    }



    /**

     * Calls back without modifications.

     *

     * @return success.

     * @dev function is virtual, and meant to be overridden.

     */

    function _transferToICAPWithReference(

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        return proxy._forwardTransferFromToICAPWithReference(

            _sender, _icap, _value, _reference, _sender);

    }



    /**

     * Passes execution into virtual function.

     *

     * Can only be called by assigned asset proxy.

     *

     * @return success.

     * @dev function is final, and must not be overridden.

     */

    function _performTransferFromWithReference(

        address _from,

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    public onlyProxy() returns(bool) {

        if (isICAP(_to)) {

            return _transferFromToICAPWithReference(

                _from, bytes20(_to), _value, _reference, _sender);

        }

        return _transferFromWithReference(_from, _to, _value, _reference, _sender);

    }



    /**

     * Calls back without modifications.

     *

     * @return success.

     * @dev function is virtual, and meant to be overridden.

     */

    function _transferFromWithReference(

        address _from,

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        return proxy._forwardTransferFromWithReference(

            _from, _to, _value, _reference, _sender);

    }



    /**

     * Passes execution into virtual function.

     *

     * Can only be called by assigned asset proxy.

     *

     * @return success.

     * @dev function is final, and must not be overridden.

     */

    function _performTransferFromToICAPWithReference(

        address _from,

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    public onlyProxy() returns(bool) {

        return _transferFromToICAPWithReference(

            _from, _icap, _value, _reference, _sender);

    }



    /**

     * Calls back without modifications.

     *

     * @return success.

     * @dev function is virtual, and meant to be overridden.

     */

    function _transferFromToICAPWithReference(

        address _from,

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        return proxy._forwardTransferFromToICAPWithReference(

            _from, _icap, _value, _reference, _sender);

    }



    /**

     * Passes execution into virtual function.

     *

     * Can only be called by assigned asset proxy.

     *

     * @return success.

     * @dev function is final, and must not be overridden.

     */

    function _performApprove(address _spender, uint _value, address _sender)

    public onlyProxy() returns(bool) {

        return _approve(_spender, _value, _sender);

    }



    /**

     * Calls back without modifications.

     *

     * @return success.

     * @dev function is virtual, and meant to be overridden.

     */

    function _approve(address _spender, uint _value, address _sender)

    internal returns(bool) {

        return proxy._forwardApprove(_spender, _value, _sender);

    }



    /**

     * Passes execution into virtual function.

     *

     * Can only be called by assigned asset proxy.

     *

     * @return bytes32 result.

     * @dev function is final, and must not be overridden.

     */

    function _performGeneric(bytes memory _data, address _sender)

    public payable onlyProxy() {

        _generic(_data, msg.value, _sender);

    }



    modifier onlyMe() {

        if (address(this) == msg.sender) {

            _;

        }

    }



    // Most probably the following should never be redefined in child contracts.

    address public genericSender;



    function _generic(bytes memory _data, uint _value, address _msgSender) internal {

        // Restrict reentrancy.

        require(genericSender == address(0));

        genericSender = _msgSender;

        bool success = _assemblyCall(address(this), _value, _data);

        delete genericSender;

        _returnReturnData(success);

    }



    // Decsendants should use _sender() instead of msg.sender to properly process proxied calls.

    function _sender() internal view returns(address) {

        return address(this) == msg.sender ? genericSender : msg.sender;

    }



    // Interface functions to allow specifying ICAP addresses as strings.

    function transferToICAP(string memory _icap, uint _value) public returns(bool) {

        return transferToICAPWithReference(_icap, _value, '');

    }



    function transferToICAPWithReference(string memory _icap, uint _value, string memory _reference)

    public returns(bool) {

        return _transferToICAPWithReference(

            _bytes32(_icap), _value, _reference, _sender());

    }



    function transferFromToICAP(address _from, string memory _icap, uint _value)

    public returns(bool) {

        return transferFromToICAPWithReference(_from, _icap, _value, '');

    }



    function transferFromToICAPWithReference(

        address _from,

        string memory _icap,

        uint _value,

        string memory _reference)

    public returns(bool) {

        return _transferFromToICAPWithReference(

            _from, _bytes32(_icap), _value, _reference, _sender());

    }



    function isICAP(address _address) public pure returns(bool) {

        bytes20 a = bytes20(_address);

        if (a[0] != 'X' || a[1] != 'E') {

            return false;

        }

        if (uint8(a[2]) < 48 || uint8(a[2]) > 57 || uint8(a[3]) < 48 || uint8(a[3]) > 57) {

            return false;

        }

        for (uint i = 4; i < 20; i++) {

            uint char = uint8(a[i]);

            if (char < 48 || char > 90 || (char > 57 && char < 65)) {

                return false;

            }

        }

        return true;

    }

}



// File: contracts/Ambi2Enabled.sol



pragma solidity 0.5.8;





contract Ambi2 {

    function claimFor(address _address, address _owner) public returns(bool);

    function hasRole(address _from, bytes32 _role, address _to) public view returns(bool);

    function isOwner(address _node, address _owner) public view returns(bool);

}





contract Ambi2Enabled {

    Ambi2 public ambi2;



    modifier onlyRole(bytes32 _role) {

        if (address(ambi2) != address(0) && ambi2.hasRole(address(this), _role, msg.sender)) {

            _;

        }

    }



    // Perform only after claiming the node, or claim in the same tx.

    function setupAmbi2(Ambi2 _ambi2) public returns(bool) {

        if (address(ambi2) != address(0)) {

            return false;

        }



        ambi2 = _ambi2;

        return true;

    }

}



// File: contracts/Ambi2EnabledFull.sol



pragma solidity 0.5.8;







contract Ambi2EnabledFull is Ambi2Enabled {

    // Setup and claim atomically.

    function setupAmbi2(Ambi2 _ambi2) public returns(bool) {

        if (address(ambi2) != address(0)) {

            return false;

        }

        if (!_ambi2.claimFor(address(this), msg.sender) &&

            !_ambi2.isOwner(address(this), msg.sender)) {

            return false;

        }



        ambi2 = _ambi2;

        return true;

    }

}



// File: contracts/AssetWithAmbi.sol



pragma solidity 0.5.8;









contract AssetWithAmbi is Asset, Ambi2EnabledFull {

    modifier onlyRole(bytes32 _role) {

        if (address(ambi2) != address(0) && (ambi2.hasRole(address(this), _role, _sender()))) {

            _;

        }

    }

}



// File: contracts/AssetWithWhitelist.sol



pragma solidity 0.5.8;







/**

 * @title EToken2 Asset with manager implementation contract.

 *

 * Manager[s] should be a contract which will implement token movement logic.

 * In case normal users transfers should be restricted, so that only manager

 * can move balances, isTransferAllowed should be set to false.

 */

contract AssetWithManager is AssetWithAmbi {

    bool public isTransferAllowed = true;



    event TransferAllowedSet(bool isAllowed);



    function isManager(address _caller) public view returns(bool) {

        return address(ambi2) != address(0) &&

            ambi2.hasRole(address(this), 'manager', _caller);

    }



    function setTransferAllowed(bool _value)

    public onlyRole('admin') returns(bool) {

        isTransferAllowed = _value;

        emit TransferAllowedSet(_value);

        return true;

    }



    function _transferWithReference(

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        if (isManager(_sender) || isTransferAllowed) {

            return super._transferWithReference(

                _to, _value, _reference, _sender);

        }

        return false;

    }



    function _transferFromWithReference(

        address _from,

        address _to,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        if (isManager(_sender)) {

            return super._transferWithReference(

                _to, _value, _reference, _from);

        }

        if (isTransferAllowed) {

            return super._transferFromWithReference(

                _from, _to, _value, _reference, _sender);

        }

        return false;

    }



    function _transferToICAPWithReference(

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        if (isManager(_sender) || isTransferAllowed) {

            return super._transferToICAPWithReference(

                _icap, _value, _reference, _sender);

        }

        return false;

    }



    function _transferFromToICAPWithReference(

        address _from,

        bytes32 _icap,

        uint _value,

        string memory _reference,

        address _sender)

    internal returns(bool) {

        if (isManager(_sender)) {

            return super._transferToICAPWithReference(

                _icap, _value, _reference, _from);

        }

        if (isTransferAllowed) {

            return super._transferFromToICAPWithReference(

                _from, _icap, _value, _reference, _sender);

        }

        return false;

    }

}