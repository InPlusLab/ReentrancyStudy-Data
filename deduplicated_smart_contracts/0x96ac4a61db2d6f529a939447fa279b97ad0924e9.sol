/**

 *Submitted for verification at Etherscan.io on 2019-02-07

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

 *                from ANY ERC-20 tokens / collectibles available in the pool.

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

 * ERC-721 Non-Fungible Token Interface

 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Interface {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

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

 *            by the Zero(Cache) Price Index (0PI).

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

    Zer0netDbInterface public zer0netDb;



    /**

     * ERC-20 Interface Initialization

     */

    string public symbol;

    string public name;

    uint8 public decimals;

    uint public _totalSupply;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    /* ERC-721 Interface Signature. */

    // `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    

    event Destroy(

        address indexed minado, 

        uint tokens

    );



    event Forge(

        address indexed minado, 

        uint tokens

    );



    event Received(

        address operator, 

        address from, 

        uint256 tokenId, 

        bytes data

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

        symbol          = '0STONE';

        name            = 'InfinityStone';

        decimals        = 18; // NOTE: Same amount as Ethereum (ETH).

        _totalSupply    = 0;



        // balances[owner] = _totalSupply;

        // emit Transfer(address(0), owner, _totalSupply);

        

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

            abi.encodePacked(msg.sender, '.has.auth.for.infinitywell'))) == true);



        _;      // function code is inserted here

    }



    /***************************************************************************

     *

     * Total supply

     */

    function totalSupply() public constant returns (uint) {

        return _totalSupply - balances[address(0)];

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

    

    /**

     * Forge NEW InfinityStone(s)

     * 

     * NOTE: Can ONLY be called by an authorized account.

     */

    function forgeStones(

        address _owner,

        uint _tokens

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Add newly forged 0STONE to its owner's balance. */

        balances[_owner] = balances[_owner].add(_tokens);

        

        /* Increase the total 0STONE supply. */

        _totalSupply = _totalSupply.add(_tokens);

        

        /* Broadcast event. */

        emit Forge(_owner, _tokens);



        /* Return success. */

        return true;

    }

    

    /**

     * Destroy InfinityStone(s)

     * 

     * NOTE: Can ONLY be called by an authorized account.

     */

    function destroyStones(

        address _owner,

        uint _tokens

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Validate owner balance. */

        require(balances[_owner].sub(_tokens) > 0, 

            'Oops! You DO NOT have enough to do that!');

        

        /* Reduce stone supply of owner. */

        balances[_owner] = balances[_owner].sub(_tokens);

        

        /* Decrease the total InfinityStone supply. */

        _totalSupply = _totalSupply.sub(_tokens);

        

        /* Broadcast event. */

        emit Destroy(_owner, _tokens);



        /* Return success. */

        return true;

    }

    

    /**

     * Transfer ERC-20 Token(s)

     * 

     * NOTE: Can ONLY be called by an authorized account.

     */

    function transferERC20(

        address _token,

        address _to,

        uint _tokens

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Transfer tokens. */

        ERC20Interface(_token).transfer(_to, _tokens);

        

        /* Broadcast event. */

        emit Transfer(address(this), _to, _tokens);



        /* Return success. */

        return true;

    }



    /**

     * Transfer an ERC-721 Collectible

     * 

     * NOTE: Can ONLY be called by an authorized account.

     * 

     * Legacy Support

     * --------------

     * 

     * This function provides legacy support for pre-`safeTransferFrom` 

     * NFTs, eg. CryptoKitties, by using the deprecated 

     * `approve/transferFrom` procedure, no longer recommended by 

     * the updated NFT protocol. (see here: http://erc721.org/)

     */

    function transferERC721(

        address _token,

        address _to,

        uint256 _tokenId

    ) external onlyAuthBy0Admin returns (bool success) {

        /* Execute token transfer (from). */

        // NOTE: `transferFrom` is supported universally by ERC-721 contracts.

        ERC721Interface(_token).transferFrom(address(this), _to, _tokenId);

        

        /* Broadcast event. */

        // NOTE: This is re-used from ERC20Interface.

        emit Transfer(address(this), _to, uint(_tokenId));



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



    /**

     * ERC-721 (Collectible) Received (Confirmation)

     * 

     * This provides support for ERC-721 tokens transferred using the

     * recommended `safeTransferFrom` function. (http://erc721.org/)

     */

    function onERC721Received(

        address _operator, 

        address _from, 

        uint256 _tokenId, 

        bytes _data

    ) public returns (bytes4) {

        /* Broadcast event. */

        emit Received(

            _operator, 

            _from, 

            _tokenId, 

            _data

        );



        /* Return received signature. */

        return _ERC721_RECEIVED;

    }

}