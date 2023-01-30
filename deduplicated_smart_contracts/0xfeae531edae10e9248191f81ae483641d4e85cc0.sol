/**

 *Submitted for verification at Etherscan.io on 2019-04-19

*/



pragma solidity ^0.4.25;



/*******************************************************************************

 *

 * Copyright (c) 2019 Decentralization Authority MDAO.

 * Released under the MIT License.

 *

 * InfinityPool - A multi-tenant mining quarry for ANY ZeroCache token provider

 *                that wishes to offer their users a Proof-of-Work (PoW) reward 

 *                system.

 *

 * 

 *                Why InfinityPool Mining?

 *                ------------------------

 * 

 *                A better model than ICOs and Airdrops, PoW mining is accepted as 

 *                the MOST democratic distribution system available in crypto today.

 * 

 *                To learn more, please visit:

 *                https://infinitypool.info

 * 

 * Version 19.4.19

 *

 * https://d14na.org

 * [email protected]

 */





/*******************************************************************************

 *

 * SafeMath

 */

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}





/*******************************************************************************

 *

 * ERC Token Standard #20 Interface

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

 */

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}





/*******************************************************************************

 *

 * ApproveAndCallFallBack

 *

 * Contract function to receive approval and execute function in one call

 * (borrowed from MiniMeToken)

 */

contract ApproveAndCallFallBack {

    function approveAndCall(address spender, uint tokens, bytes data) public;

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}





/*******************************************************************************

 *

 * Owned contract

 */

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }



    function acceptOwnership() public {

        require(msg.sender == newOwner);



        emit OwnershipTransferred(owner, newOwner);



        owner = newOwner;



        newOwner = address(0);

    }

}





/*******************************************************************************

 * 

 * Zer0netDb Interface

 */

contract Zer0netDbInterface {

    /* Interface getters. */

    function getAddress(bytes32 _key) external view returns (address);

    function getBool(bytes32 _key)    external view returns (bool);

    function getBytes(bytes32 _key)   external view returns (bytes);

    function getInt(bytes32 _key)     external view returns (int);

    function getString(bytes32 _key)  external view returns (string);

    function getUint(bytes32 _key)    external view returns (uint);



    /* Interface setters. */

    function setAddress(bytes32 _key, address _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setBytes(bytes32 _key, bytes _value) external;

    function setInt(bytes32 _key, int _value) external;

    function setString(bytes32 _key, string _value) external;

    function setUint(bytes32 _key, uint _value) external;



    /* Interface deletes. */

    function deleteAddress(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteUint(bytes32 _key) external;

}





/*******************************************************************************

 *

 * ZeroCache Interface

 */

contract ZeroCacheInterface {

    function balanceOf(address _token, address _owner) public constant returns (uint balance);

    function transfer(address _token, address _to, uint _tokens) external returns (bool success);

    function transfer(address _token, address _from, address _to, uint _tokens, address _staekholder, uint _staek, uint _expires, uint _nonce, bytes _signature) external returns (bool success);

}





/*******************************************************************************

 *

 * @notice InfinityPool is a public storage for Mineable Crypto.

 *

 * @dev This is a multi-tenant quarry for "Mineable" ERC-918 tokens.

 *      https://eips.ethereum.org/EIPS/eip-918

 * 

 *      Token Supply

 *      ------------

 *

 *      Owner will maintain 100% control over the token supply by using

 *      the `deposit` and `withdraw` functions to add / reduce the token supply.

 *      (NOTE: withdrawals are managed/transferred via the Minado.sol contract)

 * 

 *      Pool Fees

 *      ---------

 * 

 *      Upon deposit of an ERC-20 token, 1% is automatically transferred to 

 *      the InfinityWell for community reward.

 */

contract InfinityPool is Owned {

    using SafeMath for uint;



    /* Initialize predecessor contract. */

    address private _predecessor;



    /* Initialize successor contract. */

    address private _successor;

    

    /* Initialize revision number. */

    uint private _revision;



    /* Initialize Zer0net Db contract. */

    Zer0netDbInterface private _zer0netDb;

    

    /**

     * Set Namespace

     * 

     * Provides a "unique" name for generating "unique" data identifiers,

     * most commonly used as database "key-value" keys.

     * 

     * NOTE: Use of `namespace` is REQUIRED when generating ANY & ALL

     *       Zer0netDb keys; in order to prevent ANY accidental or

     *       malicious SQL-injection vulnerabilities / attacks.

     */

    string private _namespace = 'infinitypool';



    event Deposit(

        address indexed token, 

        address owner, 

        uint tokens

    );



    event Transfer(

        address indexed token, 

        address receiver, 

        uint tokens

    );



    /***************************************************************************

     *

     * Constructor

     */

    constructor() public {

        /* Initialize Zer0netDb (eternal) storage database contract. */

        // NOTE We hard-code the address here, since it should never change.

        _zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);



        /* Initialize (aname) hash. */

        bytes32 hash = keccak256(abi.encodePacked('aname.', _namespace));



        /* Set predecessor address. */

        _predecessor = _zer0netDb.getAddress(hash);



        /* Verify predecessor address. */

        if (_predecessor != 0x0) {

            /* Retrieve the last revision number (if available). */

            uint lastRevision = InfinityPool(_predecessor).getRevision();

            

            /* Set (current) revision number. */

            _revision = lastRevision + 1;

        }

    }



    /**

     * @dev Only allow access to an authorized Zer0net administrator.

     */

    modifier onlyAuthBy0Admin() {

        /* Verify write access is only permitted to authorized accounts. */

        require(_zer0netDb.getBool(keccak256(

            abi.encodePacked(msg.sender, '.has.auth.for.', _namespace))) == true);



        _;      // function code is inserted here

    }



    /**

     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER

     */

    function () public payable {

        /* Cancel this transaction. */

        revert('Oops! Direct payments are NOT permitted here.');

    }





    /***************************************************************************

     * 

     * ACTIONS

     * 

     */



    /**

     * Deposit

     * 

     * Provides support for "manual" token deposits.

     * 

     * NOTE: This function requires ZeroCache transfer authorization.

     */

    function deposit(

        address _token,

        address _from, 

        uint _tokens,

        address _staekholder, 

        uint _staek, 

        uint _expires, 

        uint _nonce, 

        bytes _signature

    ) external returns (bool success) {

        /* Transfer the ERC-20 tokens into Pool. */

        _zeroCache().transfer(

            _token, 

            _from, 

            address(this), 

            _tokens, 

            _staekholder, 

            _staek, 

            _expires, 

            _nonce, 

            _signature

        );



        /* InfinityWell 1% token drop. */        

        _wellDrop(_token, _tokens);



        /* Broadcast event. */

        emit Deposit(_token, _from, _tokens);



        /* Return success. */

        return true;

    }

    

    /**

     * (Irreversible) Well Drop

     * 

     * A 1% contribution will be automatically "dropped" into the InfinityWell

     * during each deposit into the InfinityPool.

     */

    function _wellDrop(

        address _token,

        uint _tokens

    ) private returns (bool success) {

        /* Set hash. */

        bytes32 hash = keccak256('aname.infinitywell');

            

        /* Retrieve value from Zer0net Db. */

        address infinityWell = _zer0netDb.getAddress(hash);



        /* Calculate InifinityWell drop amount. */

        // NOTE: This is fixed at 1% of token (deposit) amount.

        uint dropAmount = uint(_tokens.div(100));

        

        /* Transfer the ERC-20 tokens into the InfinityWell. */

        // NOTE: This transfer is irreversible.

        _zeroCache().transfer(

            _token, 

            infinityWell, 

            dropAmount

        );



        /* Return success. */

        return true;

    }

    

    /**

     * Administrative Transfer

     * 

     * NOTE: This will typically be called from an authorized,

     *       open-source Zer0net contract.

     * 

     * WARNING: This contract DOES NOT / WILL NOT have the ability to 

     *          transfer out non-ZeroCache tokens sent in erroneously.

     */

    function transfer(

        address _token,

        address _to, 

        uint _tokens

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Make transfer. */

        _zeroCache().transfer(_token, _to, _tokens);

        

        /* Broadcast event. */

        emit Transfer(_token, _to, _tokens);



        /* Return success. */

        return true;

    }





    /***************************************************************************

     * 

     * GETTERS

     * 

     */



    /**

     * Get Revision (Number)

     */

    function getRevision() public view returns (uint) {

        return _revision;

    }



    /**

     * Get Predecessor (Address)

     */

    function getPredecessor() public view returns (address) {

        return _predecessor;

    }

    

    /**

     * Get Successor (Address)

     */

    function getSuccessor() public view returns (address) {

        return _successor;

    }

    



    /***************************************************************************

     * 

     * SETTERS

     * 

     */



    /**

     * Set Successor

     * 

     * This is the contract address that replaced this current instnace.

     */

    function setSuccessor(

        address _newSuccessor

    ) onlyAuthBy0Admin external returns (bool success) {

        /* Set successor contract. */

        _successor = _newSuccessor;

        

        /* Return success. */

        return true;

    }





    /***************************************************************************

     * 

     * INTERFACES

     * 

     */



    /**

     * Supports Interface (EIP-165)

     * 

     * (see: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)

     * 

     * NOTE: Must support the following conditions:

     *       1. (true) when interfaceID is 0x01ffc9a7 (EIP165 interface)

     *       2. (false) when interfaceID is 0xffffffff

     *       3. (true) for any other interfaceID this contract implements

     *       4. (false) for any other interfaceID

     */

    function supportsInterface(

        bytes4 _interfaceID

    ) external pure returns (bool) {

        /* Initialize constants. */

        bytes4 InvalidId = 0xffffffff;

        bytes4 ERC165Id = 0x01ffc9a7;



        /* Validate condition #2. */

        if (_interfaceID == InvalidId) {

            return false;

        }



        /* Validate condition #1. */

        if (_interfaceID == ERC165Id) {

            return true;

        }

        

        // TODO Add additional interfaces here.

        

        /* Return false (for condition #4). */

        return false;

    }



    /**

     * ZeroCache Interface

     *

     * Retrieves the current ZeroCache interface,

     * using the aname record from Zer0netDb.

     */

    function _zeroCache() private view returns (

        ZeroCacheInterface zeroCache

    ) {

        /* Initialize hash. */

        bytes32 hash = keccak256('aname.zerocache');



        /* Retrieve value from Zer0net Db. */

        address aname = _zer0netDb.getAddress(hash);



        /* Initialize interface. */

        zeroCache = ZeroCacheInterface(aname);

    }

}