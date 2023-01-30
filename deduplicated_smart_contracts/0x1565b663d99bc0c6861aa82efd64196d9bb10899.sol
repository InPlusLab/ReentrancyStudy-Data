/**

 *Submitted for verification at Etherscan.io on 2019-02-07

*/



pragma solidity ^0.4.25;



/*******************************************************************************

 *

 * Copyright (c) 2019 Decentralization Authority MDAO.

 * Released under the MIT License.

 *

 * InfinityPool - A multi-tenant mining quarry for ANY compatible ERC-20 token

 *                to utilize a Proof-of-Work (PoW) reward system for a more

 *                democratic distribution of their pre-mined token.

 *

 * Version 19.2.5

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

 *      the InfinityWell for community award.

 */

contract InfinityPool is Owned {

    using SafeMath for uint;



    /* Initialize Zer0net Db contract. */

    Zer0netDbInterface public zer0netDb;

    

    event Deposit(

        address indexed token, 

        address owner, 

        uint tokens,

        bytes data

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

        zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);

    }



    /**

     * @dev Only allow access to an authorized Zer0net administrator.

     */

    modifier onlyAuthBy0Admin() {

        /* Verify write access is only permitted to authorized accounts. */

        require(zer0netDb.getBool(keccak256(

            abi.encodePacked(msg.sender, '.has.auth.for.infinitypool'))) == true);



        _;      // function code is inserted here

    }



    /**

     * Deposit

     * 

     * Provides support for "manual" token deposits.

     * 

     * NOTE: Required pre-allowance/approval is required in order

     *       to successfully complete the transfer.

     */

    function deposit(

        address _token, 

        uint _tokens, 

        bytes _data

    ) external returns (bool success) {

        return _deposit(_token, msg.sender, _tokens, _data);

    }



    /**

     * Receive Approval

     * 

     * Will typically be called from `approveAndCall`.

     * 

     * NOTE: In this case, we have no use for data, as

     *       deposits are credited anonymously and only

     *       accessible to the token owner(s).

     */

    function receiveApproval(

        address _from, 

        uint _tokens, 

        address _token, 

        bytes _data

    ) public returns (bool success) {

        return _deposit(_token, _from, _tokens, _data);

    }



    /**

     * Deposit (private)

     * 

     * NOTE: This function requires pre-approval from the token

     *       contract for the amount requested.

     */

    function _deposit(

        address _token,

        address _from, 

        uint _tokens,

        bytes _data

    ) private returns (bool success) {

        /* Set hash. */

        bytes32 hash = keccak256('infinitywell');

            

        /* Retrieve value from Zer0net Db. */

        address infinityWell = zer0netDb.getAddress(hash);



        /* Calculate Inifinity Well contribution. */

        // NOTE: This is fixed at 1% of token (deposit) amount.

        uint wellContribution = uint(_tokens.div(100));

        

        /* Calculate deposit amount. */

        uint depositAmount = _tokens.sub(wellContribution);



        /* Transfer the ERC-20 tokens into Pool. */

        ERC20Interface(_token).transferFrom(

            _from, address(this), depositAmount);

        

        /* Transfer the ERC-20 tokens into Well. */

        // NOTE: This transfer is irreversible.

        ERC20Interface(_token).transferFrom(

            _from, infinityWell, wellContribution);

        

        /* Broadcast event. */

        emit Deposit(_token, _from, _tokens, _data);



        /* Return success. */

        return true;

    }

    

    /**

     * Administrative Transfer

     * 

     * NOTE: This will typically be called from an authorized,

     *       open-source Zer0net contract.

     */

    function transfer(

        address _token,

        address _to, 

        uint _tokens

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Make transfer. */

        ERC20Interface(_token).transfer(_to, _tokens);

        

        /* Broadcast event. */

        emit Transfer(_token, _to, _tokens);



        /* Return success. */

        return true;

    }



    /**

     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER

     */

    function () public payable {

        /* Cancel this transaction. */

        revert('Oops! Direct payments are NOT permitted here.');

    }

}