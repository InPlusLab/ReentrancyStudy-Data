/**

 *Submitted for verification at Etherscan.io on 2019-04-19

*/



pragma solidity ^0.4.25;



/*******************************************************************************

 *

 * Copyright (c) 2019 Decentralization Authority MDAO.

 * Released under the MIT License.

 *

 * InfinityWell - An ERC Gift Box, encouraging the democratic distribution

 *                of value using transparent game theory.

 * 

 *                Miners collect InfinityStones, redemable towards a share 

 *                from ANY ERC-20 tokens / collectibles available in the well.

 *

 *                To learn more, please visit:

 *                https://infinitywell.info

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

    function deposit(address _token, address _from, uint _tokens, bytes _data) external returns (bool success);

    function transfer(address _token, address _to, uint _tokens) external returns (bool success);

    function transfer(address _token, address _from, address _to, uint _tokens, address _staekholder, uint _staek, uint _expires, uint _nonce, bytes _signature) external returns (bool success);

    function withdraw(address _token, uint _tokens) public returns (bool success);

}





/*******************************************************************************

 *

 * @notice InfinityWell

 * 

 *         An eternal laborinth of ERC tokens and collectibles PERMANENTLY

 *         trapped in this bottomless well, until released by the good fortune 

 *         of an InfinityStone HODLer.

 *

 * @dev This is a non-discriminatory, public ERC gift box.

 * 

 *      InfinityStone

 *      -------------

 * 

 *      A precious stone minted exclusively by the InfinityWell for the sole

 *      purpose of gifting "random" ERC tokens & collectibles to its HODLers. 

 * 

 *      When redeeming a FULL InfinityStone, a FULL 5% of a random token 

 *      is awarded; partial redemptions will be awarded pro-rata, based the

 *      amount of stone submitted to the forge.

 * 

 *      NOTE: TOP100 token & collectible values are reported (in real-time) 

 *            by the Zero(Cache) Price Index (ZPI).

 * 

 *          <1 0STONE => up to 5% of a random TOP100 token

 *                       NO COLLECTIBLE BONUS

 * 

 *           1 0STONE => 5% balance of a random TOP100 token

 *                       Bonus: 1 random TOP100 collectible

 * 

 *           3 0STONE => 5% balance of a random TOP30 token

 *                       Bonus: 1 random TOP30 collectible

 * 

 *          10 0STONE => 5% balance of a random TOP10 token

 *                       Bonus: 1 random TOP10 collectible

 * 

 *      Bonuses DO NOT apply to "partial" InfinityStone redemptions.

 *      (eg. 1/2 a 0STONE will award 2.5% in an ERC-20's tokens, but NO collectible)

 * 

 */

contract InfinityWell is ERC20Interface, Owned {

    using SafeMath for uint;



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

    string private _namespace = 'infinitywell';



    /**

     * ERC-20 Interface Initialization

     */

    string public symbol;

    string public name;

    uint8 public decimals;

    uint private _totalForged;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    event Destroy(

        address indexed minado, 

        uint tokens

    );



    event Forge(

        address indexed minado, 

        uint tokens

    );



    /***************************************************************************

     *

     * Constructor

     * 

     * STAEK ONLY TOKEN

     * ----------------

     * 

     * NEW InfinityStones can only be forged from STAEKing ZeroGold.

     */

    constructor() public {

        /* Ininitialize ERC-20 token values. */

        symbol   = '0STONE';

        name     = 'InfinityStone';

        decimals = 18; // NOTE: Same amount as Ethereum (ETH).



        // *********************************************************************

        // *** NO PRE-MINE ***

        // *********************************************************************

        _totalForged = 0;

        // balances[owner] = _totalForged;

        // emit Transfer(address(0x0), owner, _totalForged);

        

        /* Initialize Zer0netDb (eternal) storage database contract. */

        // NOTE We hard-code the address here, since it should never change.

        _zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);

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

     * Total supply

     */

    function totalSupply() public constant returns (uint) {

        /* Retrieve burn balance. */

        uint burnAmount = balances[address(0x0)];



        /* Retrieve burn balance from ZeroCache. */

        uint cacheBurnAmount = _zeroCache().balanceOf(

            address(this), 

            address(0x0)

        );



        // NOTE: Destroyed stones are "burned" (sent to 0x0).

        return _totalForged - burnAmount - cacheBurnAmount;

    }



    /***************************************************************************

     *

     * Get the token balance for account `tokenOwner`

     */

    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }



    /***************************************************************************

     *

     * Transfer the balance from token owner's account to `to` account

     * - Owner's account must have sufficient balance to transfer

     * - 0 value transfers are allowed

     */

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to]         = balances[to].add(tokens);



        emit Transfer(msg.sender, to, tokens);



        return true;

    }



    /***************************************************************************

     *

     * Token owner can approve for `spender` to transferFrom(...) `tokens`

     * from the token owner's account

     *

     * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

     * recommends that there are no checks for the approval double-spend attack

     * as this should be implemented in user interfaces

     */

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;



        emit Approval(msg.sender, spender, tokens);



        return true;

    }



    /***************************************************************************

     *

     * Transfer `tokens` from the `from` account to the `to` account.

     *

     * The calling account must already have sufficient tokens approve(...)-d

     * for spending from the `from` account and:

     *     - From account must have sufficient balance to transfer

     *     - Spender must have sufficient allowance to transfer

     *     - 0 value transfers are allowed

     */

    function transferFrom(

        address from, address to, uint tokens) public returns (

        bool success) {

        balances[from]            = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to]              = balances[to].add(tokens);



        emit Transfer(from, to, tokens);



        return true;

    }



    /***************************************************************************

     *

     * Returns the amount of tokens approved by the owner that can be

     * transferred to the spender's account

     */

    function allowance(

        address tokenOwner, address spender) public constant returns (

        uint remaining) {

        return allowed[tokenOwner][spender];

    }



    /***************************************************************************

     *

     * Token owner can approve for `spender` to transferFrom(...) `tokens`

     * from the token owner's account. The `spender` contract function

     * `receiveApproval(...)` is then executed

     */

    function approveAndCall(

        address spender, uint tokens, bytes data) public returns (

        bool success) {

        allowed[msg.sender][spender] = tokens;



        emit Approval(msg.sender, spender, tokens);



        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);



        return true;

    }





    /***************************************************************************

     * 

     * ACTIONS

     * 

     */



    /**

     * Forge NEW InfinityStone(s)

     * 

     * NOTE: Can ONLY be called by an authorized administrator.

     */

    function forgeStones(

        address _owner,

        uint _tokens

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Increase the total 0STONE forge count. */

        _totalForged = _totalForged.add(_tokens);

        

        /* Add tokens to InfinityWell balance. */

        balances[address(this)] = _tokens;

        

        /* Allow ZeroCache to transfer full tokens. */

        allowed[address(this)][address(_zeroCache())] = _tokens;

        

        /* Request deposit to owner's ZeroCache. */

        _zeroCache().deposit(

            address(this), // token 

            address(this), // from

            _tokens, 

            abi.encodePacked(_owner)

        );

        

        /* Broadcast event. */

        emit Forge(_owner, _tokens);



        /* Return success. */

        return true;

    }

    

    /**

     * Destroy InfinityStone(s)

     * 

     * NOTE: Can ONLY be called by an authorized administrator.

     */

    function destroyStones(

        address _owner,

        uint _tokens,

        address _staekholder, 

        uint _staek, 

        uint _expires, 

        uint _nonce, 

        bytes _signature

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Retrieve owner balance from ZeroCache. */

        uint balance = _zeroCache().balanceOf(

            address(this), 

            _owner

        );

        

        /* Validate owner balance. */

        if (balance < _tokens) {

            revert('Oops! You DO NOT have enough InfinityStone.');

        }

        

        /* Transfer "approved" tokens to InfinityWell. */

        _zeroCache().transfer(

            address(this), 

            _owner, 

            address(0x0), // NOTE: This is our ZeroCache burn address.

            _tokens, 

            _staekholder, 

            _staek, 

            _expires, 

            _nonce, 

            _signature

        );



        /* Broadcast event. */

        emit Destroy(_owner, _tokens);



        /* Return success. */

        return true;

    }

    

    /**

     * Transfer ERC-20/721 Token(s)

     * 

     * ZeroCache will auto-detect the interface (either ERC-20 or ERC-721), 

     * then perform the token or collectible transfer.

     * 

     * NOTE: Can ONLY be called by an authorized administrator.

     */

    function transfer(

        address _token,

        address _to,

        uint _tokensOrId

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Transfer tokens. */

        _zeroCache().transfer(_token, _to, _tokensOrId);



        /* Broadcast event. */

        emit Transfer(address(this), _to, _tokensOrId);



        /* Return success. */

        return true;

    }





    /***************************************************************************

     * 

     * INTERFACES

     * 

     */



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