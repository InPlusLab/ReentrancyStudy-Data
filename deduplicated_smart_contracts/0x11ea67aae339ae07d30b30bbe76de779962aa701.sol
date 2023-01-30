/**

 *Submitted for verification at Etherscan.io on 2018-09-25

*/



pragma solidity ^0.4.19;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}



/**

 * @title Math

 * @dev Assorted math operations

 */



library Math {

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {

    return a >= b ? a : b;

  }



  function min64(uint64 a, uint64 b) internal pure returns (uint64) {

    return a < b ? a : b;

  }



  function max256(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;

  }



  function min256(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;

  }

}





// Slightly modified Zeppelin's Vested Token deriving MiniMeToken



/*

    Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

    Copyright 2017, Jorge Izquierdo (Aragon Foundation)

    Copyright 2017, Jordi Baylina (Giveth)



    Based on MiniMeToken.sol from https://github.com/Giveth/minime

*/



contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);

}



/*

    Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

    Copyright 2017, Jorge Izquierdo (Aragon Foundation)

    Copyright 2017, Jordi Baylina (Giveth)



    Based on MiniMeToken.sol from https://github.com/Giveth/minime

 */



contract Controlled {

    address public controller;



    function Controlled() {

         controller = msg.sender;

    }



    /// @notice The address of the controller is the only address that can call

    ///    a function with this modifier

    modifier onlyController {

        require(msg.sender == controller);

        _;

    }



    /// @notice Changes the controller of the contract

    /// @param _newController The new controller of the contract

    function changeController(address _newController) onlyController {

        controller = _newController;

    }

}



/*

    Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

    Copyright 2017, Jorge Izquierdo (Aragon Foundation)

    Copyright 2017, Jordi Baylina (Giveth)



    Based on MiniMeToken.sol from https://github.com/Giveth/minime

 */



/// @dev The token controller contract must implement these functions

contract TokenController {

    /// @notice Called when `_owner` sends ether to the MiniMe Token contract

    /// @param _owner The address that sent the ether to create tokens

    /// @return True if the ether is accepted, false if it throws

    function proxyPayment(address _owner) payable returns(bool);



    /// @notice Notifies the controller about a token transfer allowing the

    ///    controller to react if desired

    /// @param _from The origin of the transfer

    /// @param _to The destination of the transfer

    /// @param _amount The amount of the transfer

    /// @return False if the controller does not authorize the transfer

    function onTransfer(address _from, address _to, uint _amount) returns(bool);



    /// @notice Notifies the controller about an approval allowing the

    ///    controller to react if desired

    /// @param _owner The address that calls `approve()`

    /// @param _spender The spender in the `approve()` call

    /// @param _amount The amount in the `approve()` call

    /// @return False if the controller does not authorize the approval

    function onApprove(address _owner, address _spender, uint _amount) returns(bool);

}



/*

    Copyright 2016, Jordi Baylina



    This program is free software: you can redistribute it and/or modify

    it under the terms of the GNU General Public License as published by

    the Free Software Foundation, either version 3 of the License, or

    (at your option) any later version.



    This program is distributed in the hope that it will be useful,

    but WITHOUT ANY WARRANTY; without even the implied warranty of

    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the

    GNU General Public License for more details.



    You should have received a copy of the GNU General Public License

    along with this program.    If not, see <http://www.gnu.org/licenses/>.

 */



/// @title MiniMeToken Contract

/// @author Jordi Baylina

/// @dev This token contract's goal is to make it easy for anyone to clone this

///    token using the token distribution at a given block, this will allow DAO's

///    and DApps to upgrade their features in a decentralized manner without

///    affecting the original token

/// @dev It is ERC20 compliant, but still needs to under go further testing.



/// @dev The actual token contract, the default controller is the msg.sender

///    that deploys the contract, so usually this token will be deployed by a

///    token controller contract, which Giveth will call a "Campaign"

contract MiniMeToken is Controlled {



    string public name;               //The Token's name: e.g. DigixDAO Tokens

    uint8 public decimals;             //Number of decimals of the smallest unit

    string public symbol;               //An identifier: e.g. REP

    string public version = "MMT_0.1"; //An arbitrary versioning scheme





    /// @dev `Checkpoint` is the structure that attaches a block number to a

    ///    given value, the block number attached is the one that last changed the

    ///    value

    struct    Checkpoint {



        // `fromBlock` is the block number that the value was generated from

        uint128 fromBlock;



        // `value` is the amount of tokens at a specific block number

        uint128 value;

    }



    // `parentToken` is the Token address that was cloned to produce this token;

    //    it will be 0x0 for a token that was not cloned

    MiniMeToken public parentToken;



    // `parentSnapShotBlock` is the block number from the Parent Token that was

    //    used to determine the initial distribution of the Clone Token

    uint public parentSnapShotBlock;



    // `creationBlock` is the block number that the Clone Token was created

    uint public creationBlock;



    // `balances` is the map that tracks the balance of each address, in this

    //    contract when the balance changes the block number that the change

    //    occurred is also included in the map

    mapping (address => Checkpoint[]) balances;



    // `allowed` tracks any extra transfer rights as in all ERC20 tokens

    mapping (address => mapping (address => uint256)) allowed;



    // Tracks the history of the `totalSupply` of the token

    Checkpoint[] totalSupplyHistory;



    // Flag that determines if the token is transferable or not.

    bool public transfersEnabled;



    // The factory used to create new clone tokens

    MiniMeTokenFactory public tokenFactory;



////////////////

// Constructor

////////////////



    /// @notice Constructor to create a MiniMeToken

    /// @param _tokenFactory The address of the MiniMeTokenFactory contract that

    ///    will create the Clone token contracts, the token factory needs to be

    ///    deployed first

    /// @param _parentToken Address of the parent token, set to 0x0 if it is a

    ///    new token

    /// @param _parentSnapShotBlock Block of the parent token that will

    ///    determine the initial distribution of the clone token, set to 0 if it

    ///    is a new token

    /// @param _tokenName Name of the new token

    /// @param _decimalUnits Number of decimals of the new token

    /// @param _tokenSymbol Token Symbol for the new token

    /// @param _transfersEnabled If true, tokens will be able to be transferred

    function MiniMeToken(

        address _tokenFactory,

        address _parentToken,

        uint _parentSnapShotBlock,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol,

        bool _transfersEnabled

    ) {

        tokenFactory = MiniMeTokenFactory(_tokenFactory);

        name = _tokenName;                                // Set the name

        decimals = _decimalUnits;                            // Set the decimals

        symbol = _tokenSymbol;                             // Set the symbol

        parentToken = MiniMeToken(_parentToken);

        parentSnapShotBlock = _parentSnapShotBlock;

        transfersEnabled = _transfersEnabled;

        creationBlock = block.number;

    }





///////////////////

// ERC20 Methods

///////////////////



    /// @notice Send `_amount` tokens to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _amount) returns (bool success) {

        require(transfersEnabled);

        doTransfer(msg.sender, _to, _amount);

        return true;

    }



    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it

    ///    is approved by `_from`

    /// @param _from The address holding the tokens being transferred

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return True if the transfer was successful

    function transferFrom(address _from, address _to, uint256 _amount

    ) returns (bool success) {



        // The controller of this contract can move tokens around at will,

        //    this is important to recognize! Confirm that you trust the

        //    controller of this contract, which in most situations should be

        //    another open source smart contract or 0x0

        if (msg.sender != controller) {

            require(transfersEnabled);



            // The standard ERC 20 transferFrom functionality

            require(allowed[_from][msg.sender] >= _amount);

            allowed[_from][msg.sender] -= _amount;

        }

        doTransfer(_from, _to, _amount);

        return true;

    }



    /// @dev This is the actual transfer function in the token contract, it can

    ///    only be called by other functions in this contract.

    /// @param _from The address holding the tokens being transferred

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return True if the transfer was successful

    function doTransfer(address _from, address _to, uint _amount

    ) internal {



             if (_amount == 0) {

             Transfer(_from, _to, _amount);    // Follow the spec to issue the event when transfer 0

             return;

             }



             require(parentSnapShotBlock < block.number);



             // Do not allow transfer to 0x0 or the token contract itself

             require((_to != 0) && (_to != address(this)));



             // If the amount being transfered is more than the balance of the

             //    account the transfer throws

             uint256 previousBalanceFrom = balanceOfAt(_from, block.number);

             require(previousBalanceFrom >= _amount);



             // Alerts the token controller of the transfer

             if (isContract(controller)) {

                 require(TokenController(controller).onTransfer(_from, _to, _amount));

             }



             // First update the balance array with the new value for the address

             //    sending the tokens

             updateValueAtNow(balances[_from], previousBalanceFrom - _amount);



             // Then update the balance array with the new value for the address

             //    receiving the tokens

             uint256 previousBalanceTo = balanceOfAt(_to, block.number);

             require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow

             updateValueAtNow(balances[_to], previousBalanceTo + _amount);



             // An event to make the transfer easy to find on the blockchain

             Transfer(_from, _to, _amount);



    }



    /// @param _owner The address that's balance is being requested

    /// @return The balance of `_owner` at the current block

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);

    }



    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on

    ///    its behalf. This is a modified version of the ERC20 approve function

    ///    to be a little bit safer

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _amount The amount of tokens to be approved for transfer

    /// @return True if the approval was successful

    function approve(address _spender, uint256 _amount) returns (bool success) {

        require(transfersEnabled);



        // To change the approve amount you first have to reduce the addresses`

        //    allowance to zero by calling `approve(_spender,0)` if it is not

        //    already 0 to mitigate the race condition described here:

        //    https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));



        // Alerts the token controller of the approve function call

        if (isContract(controller)) {

            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));

        }



        allowed[msg.sender][_spender] = _amount;

        Approval(msg.sender, _spender, _amount);

        return true;

    }



    /// @dev This function makes it easy to read the `allowed[]` map

    /// @param _owner The address of the account that owns the token

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens of _owner that _spender is allowed

    ///    to spend

    function allowance(address _owner, address _spender

    ) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on

    ///    its behalf, and then a function is triggered in the contract that is

    ///    being approved, `_spender`. This allows users to use their tokens to

    ///    interact with contracts in one function call instead of two

    /// @param _spender The address of the contract able to transfer the tokens

    /// @param _amount The amount of tokens to be approved for transfer

    /// @return True if the function call was successful

    function approveAndCall(address _spender, uint256 _amount, bytes _extraData

    ) public returns (bool success) {

        require(approve(_spender, _amount));



        ApproveAndCallFallBack(_spender).receiveApproval(

            msg.sender,

            _amount,

            this,

            _extraData

        );



        return true;

    }



    /// @dev This function makes it easy to get the total number of tokens

    /// @return The total number of tokens

    function totalSupply() constant returns (uint) {

        return totalSupplyAt(block.number);

    }





////////////////

// Query balance and totalSupply in History

////////////////



    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`

    /// @param _owner The address from which the balance will be retrieved

    /// @param _blockNumber The block number when the balance is queried

    /// @return The balance at `_blockNumber`

    function balanceOfAt(address _owner, uint _blockNumber) public view

        returns (uint) {



        // These next few lines are used when the balance of the token is

        //    requested before a check point was ever created for this token, it

        //    requires that the `parentToken.balanceOfAt` be queried at the

        //    genesis block for that token as this contains initial balance of

        //    this token

        if ((balances[_owner].length == 0)

            || (balances[_owner][0].fromBlock > _blockNumber)) {

            if (address(parentToken) != 0) {

               return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));

            } else {

               // Has no parent

               return 0;

            }



        // This will return the expected balance during normal situations

        } else {

            return getValueAt(balances[_owner], _blockNumber);

        }

    }



    /// @notice Total amount of tokens at a specific `_blockNumber`.

    /// @param _blockNumber The block number when the totalSupply is queried

    /// @return The total amount of tokens at `_blockNumber`

    function totalSupplyAt(uint _blockNumber) public view returns(uint) {



        // These next few lines are used when the totalSupply of the token is

        //    requested before a check point was ever created for this token, it

        //    requires that the `parentToken.totalSupplyAt` be queried at the

        //    genesis block for this token as that contains totalSupply of this

        //    token at this block number.

        if ((totalSupplyHistory.length == 0)

            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {

            if (address(parentToken) != 0) {

               return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));

            } else {

               return 0;

            }



        // This will return the expected totalSupply during normal situations

        } else {

            return getValueAt(totalSupplyHistory, _blockNumber);

        }

    }



////////////////

// Clone Token Method

////////////////



    /// @notice Creates a new clone token with the initial distribution being

    ///    this token at `_snapshotBlock`

    /// @param _cloneTokenName Name of the clone token

    /// @param _cloneDecimalUnits Number of decimals of the smallest unit

    /// @param _cloneTokenSymbol Symbol of the clone token

    /// @param _snapshotBlock Block when the distribution of the parent token is

    ///    copied to set the initial distribution of the new clone token;

    ///    if the block is zero than the actual block, the current block is used

    /// @param _transfersEnabled True if transfers are allowed in the clone

    /// @return The address of the new MiniMeToken Contract

    function createCloneToken(

        string _cloneTokenName,

        uint8 _cloneDecimalUnits,

        string _cloneTokenSymbol,

        uint _snapshotBlock,

        bool _transfersEnabled

        ) returns(address) {

        if (_snapshotBlock == 0) _snapshotBlock = block.number;

        MiniMeToken cloneToken = tokenFactory.createCloneToken(

            this,

            _snapshotBlock,

            _cloneTokenName,

            _cloneDecimalUnits,

            _cloneTokenSymbol,

            _transfersEnabled

            );



        cloneToken.changeController(msg.sender);



        // An event to make the token easy to find on the blockchain

        NewCloneToken(address(cloneToken), _snapshotBlock);

        return address(cloneToken);

    }



////////////////

// Generate and destroy tokens

////////////////



    /// @notice Generates `_amount` tokens that are assigned to `_owner`

    /// @param _owner The address that will be assigned the new tokens

    /// @param _amount The quantity of tokens generated

    /// @return True if the tokens are generated correctly

    function generateTokens(address _owner, uint _amount

    ) onlyController returns (bool) {

        uint curTotalSupply = totalSupply();

        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow

        uint previousBalanceTo = balanceOf(_owner);

        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow

        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);

        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);

        Transfer(0, _owner, _amount);

        return true;

    }





    /// @notice Burns `_amount` tokens from `_owner`

    /// @param _owner The address that will lose the tokens

    /// @param _amount The quantity of tokens to burn

    /// @return True if the tokens are burned correctly

    function destroyTokens(address _owner, uint256 _amount

    ) onlyController returns (bool) {

        uint256 curTotalSupply = totalSupply();

        require(curTotalSupply >= _amount);

        uint256 previousBalanceFrom = balanceOf(_owner);

        require(previousBalanceFrom >= _amount);

        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);

        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);

        Transfer(_owner, 0, _amount);

        return true;

    }



////////////////

// Enable tokens transfers

////////////////





    /// @notice Enables token holders to transfer their tokens freely if true

    /// @param _transfersEnabled True if transfers are allowed in the clone

    function enableTransfers(bool _transfersEnabled) onlyController {

        transfersEnabled = _transfersEnabled;

    }



////////////////

// Internal helper functions to query and set a value in a snapshot array

////////////////



    /// @dev `getValueAt` retrieves the number of tokens at a given block number

    /// @param checkpoints The history of values being queried

    /// @param _block The block number to retrieve the value at

    /// @return The number of tokens being queried

    function getValueAt(Checkpoint[] storage checkpoints, uint _block

    ) internal view returns (uint) {

        if (checkpoints.length == 0) return 0;



        // Shortcut for the actual value

        if (_block >= checkpoints[checkpoints.length-1].fromBlock)

            return checkpoints[checkpoints.length-1].value;

        if (_block < checkpoints[0].fromBlock) return 0;



        // Binary search of the value in the array

        uint min = 0;

        uint max = checkpoints.length-1;

        while (max > min) {

            uint mid = (max + min + 1)/ 2;

            if (checkpoints[mid].fromBlock<=_block) {

               min = mid;

            } else {

               max = mid-1;

            }

        }

        return checkpoints[min].value;

    }



    /// @dev `updateValueAtNow` used to update the `balances` map and the

    ///    `totalSupplyHistory`

    /// @param checkpoints The history of data being updated

    /// @param _value The new number of tokens

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value

    ) internal    {

        if ((checkpoints.length == 0)

        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {

                 Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];

                 newCheckPoint.fromBlock =    uint128(block.number);

                 newCheckPoint.value = uint128(_value);

             } else {

                 Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];

                 oldCheckPoint.value = uint128(_value);

             }

    }



    /// @dev Internal function to determine if an address is a contract

    /// @param _addr The address being queried

    /// @return True if `_addr` is a contract

    function isContract(address _addr) internal view returns(bool) {

        uint size;

        if (_addr == 0) return false;

        assembly {

            size := extcodesize(_addr)

        }

        return size > 0;

    }



    /// @dev Helper function to return a min betwen the two uints

    function min(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;

    }



    /// @notice The fallback function: If the contract's controller has not been

    ///    set to 0, then the `proxyPayment` method is called which relays the

    ///    ether and creates tokens as described in the token controller contract

    function ()    payable {

        require(isContract(controller));

        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));

    }



//////////

// Safety Methods

//////////



    /// @notice This method can be used by the controller to extract mistakenly

    ///    sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///    set to 0 in case you want to extract ether.

    function claimTokens(address _token) onlyController {

        if (_token == 0x0) {

            controller.transfer(this.balance);

            return;

        }



        MiniMeToken token = MiniMeToken(_token);

        uint balance = token.balanceOf(this);

        token.transfer(controller, balance);

        ClaimedTokens(_token, controller, balance);

    }



////////////////

// Events

////////////////

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);

    event Approval(

        address indexed _owner,

        address indexed _spender,

        uint256 _amount

        );



}





////////////////

// MiniMeTokenFactory

////////////////



/// @dev This contract is used to generate clone contracts from a contract.

///    In solidity this is the way to create a contract from a contract of the

///    same class

contract MiniMeTokenFactory {



    /// @notice Update the DApp by creating a new token with new functionalities

    ///    the msg.sender becomes the controller of this clone token

    /// @param _parentToken Address of the token being cloned

    /// @param _snapshotBlock Block of the parent token that will

    ///    determine the initial distribution of the clone token

    /// @param _tokenName Name of the new token

    /// @param _decimalUnits Number of decimals of the new token

    /// @param _tokenSymbol Token Symbol for the new token

    /// @param _transfersEnabled If true, tokens will be able to be transferred

    /// @return The address of the new token contract

    function createCloneToken(

        address _parentToken,

        uint _snapshotBlock,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol,

        bool _transfersEnabled

    ) returns (MiniMeToken) {

        MiniMeToken newToken = new MiniMeToken(

            this,

            _parentToken,

            _snapshotBlock,

            _tokenName,

            _decimalUnits,

            _tokenSymbol,

            _transfersEnabled

            );



        newToken.changeController(msg.sender);

        return newToken;

    }

}



/**

    * Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

    * Copyright 2017, Jorge Izquierdo (Aragon Foundation)

    *

    * Based on VestedToken.sol from https://github.com/OpenZeppelin/zeppelin-solidity

    *

    * Math �C Copyright (c) 2016 Smart Contract Solutions, Inc.

    * SafeMath �C Copyright (c) 2016 Smart Contract Solutions, Inc.

    * MiniMeToken �C Copyright 2017, Jordi Baylina (Giveth)

    **/



// @dev MiniMeIrrevocableVestedToken is a derived version of MiniMeToken adding the

// ability to createTokenGrants which are basically a transfer that limits the

// receiver of the tokens how can he spend them over time.



// For simplicity, token grants are not saved in MiniMe type checkpoints.

// Vanilla cloning ESCBCoin will clone it into a MiniMeToken without vesting.

// More complex cloning could account for past vesting calendars.



contract MiniMeIrrevocableVestedToken is MiniMeToken {



    using SafeMath for uint256;



    uint256 MAX_GRANTS_PER_ADDRESS = 20;

    // Keep the struct at 2 stores (1 slot for value + 64 * 3 (dates) + 20 (address) = 2 slots

    // (2nd slot is 212 bytes, lower than 256))

    struct TokenGrant {

    address granter;    // 20 bytes

    uint256 value;         // 32 bytes

    uint64 cliff;

    uint64 vesting;

    uint64 start;        // 3 * 8 = 24 bytes

    bool revokable;

    bool burnsOnRevoke;    // 2 * 1 = 2 bits? or 2 bytes?

    } // total 78 bytes = 3 sstore per operation (32 per sstore)



    mapping (address => TokenGrant[]) public grants;



    event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint64 start, uint64 cliff, uint64 vesting, uint256 grantId);



    mapping (address => bool) canCreateGrants;

    address vestingWhitelister;



    modifier canTransfer(address _sender, uint _value) {

    require(_value <= spendableBalanceOf(_sender));

    _;

    }



    modifier onlyVestingWhitelister {

    require(msg.sender == vestingWhitelister);

    _;

    }



    function MiniMeIrrevocableVestedToken (

        address _tokenFactory,

        address _parentToken,

        uint _parentSnapShotBlock,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol,

        bool _transfersEnabled

    ) public MiniMeToken(_tokenFactory, _parentToken, _parentSnapShotBlock, _tokenName, _decimalUnits, _tokenSymbol, _transfersEnabled) {

    vestingWhitelister = msg.sender;

    doSetCanCreateGrants(vestingWhitelister, true);

    }



    // @dev Add canTransfer modifier before allowing transfer and transferFrom to go through

    function transfer(address _to, uint _value)

             canTransfer(msg.sender, _value)

             public

             returns (bool success) {

    return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint _value)

             canTransfer(_from, _value)

             public

             returns (bool success) {

    return super.transferFrom(_from, _to, _value);

    }



    function spendableBalanceOf(address _holder) constant public returns (uint) {

    return transferableTokens(_holder, uint64(now));

    }



    /**

    * @dev Grant tokens to a specified address

    * @param _to address The address which the tokens will be granted to.

    * @param _value uint256 The amount of tokens to be granted.

    * @param _start uint64 Time of the beginning of the grant.

    * @param _cliff uint64 Time of the cliff period.

    * @param _vesting uint64 The vesting period.

    * @param _revokable bool Token can be revoked with send amount to back.

    * @param _burnsOnRevoke bool Token can be revoked with send amount to back and destroyed.

    */

    function grantVestedTokens(

    address _to,

    uint256 _value,

    uint64 _start,

    uint64 _cliff,

    uint64 _vesting,

    bool _revokable,

    bool _burnsOnRevoke

    ) public {



    // Check for date inconsistencies that may cause unexpected behavior

    require(_cliff >= _start && _vesting >= _cliff);

    require(canCreateGrants[msg.sender]);



    require(tokenGrantsCount(_to) < MAX_GRANTS_PER_ADDRESS);    // To prevent a user being spammed and have his balance locked (out of gas attack when calculating vesting).



    uint256 count = grants[_to].push(

               TokenGrant(

                   _revokable ? msg.sender : 0, // avoid storing an extra 20 bytes when it is non-revokable

                   _value,

                   _cliff,

                   _vesting,

                   _start,

                   _revokable,

                   _burnsOnRevoke

               )

               );



    transfer(_to, _value);



    NewTokenGrant(msg.sender, _to, _value, _cliff, _vesting, _start, count - 1);

    }



    function setCanCreateGrants(address _addr, bool _allowed) onlyVestingWhitelister public {

    doSetCanCreateGrants(_addr, _allowed);

    }



    function doSetCanCreateGrants(address _addr, bool _allowed) internal {

    canCreateGrants[_addr] = _allowed;

    }



    function changeVestingWhitelister(address _newWhitelister) onlyVestingWhitelister public {

    doSetCanCreateGrants(vestingWhitelister, false);

    vestingWhitelister = _newWhitelister;

    doSetCanCreateGrants(vestingWhitelister, true);

    }



    /**

    * @dev Revoke the grant of tokens of a specifed address.

    * @param _holder The address which will have its tokens revoked.

    * @param _grantId The id of the token grant.

    */

    function revokeTokenGrant(address _holder, uint256 _grantId) public {

    TokenGrant storage grant = grants[_holder][_grantId];



    require(grant.revokable);

    require(grant.granter == msg.sender); // Only granter can revoke it



    address receiver = grant.burnsOnRevoke ? 0xdead : msg.sender;



    uint256 nonVested = nonVestedTokens(grant, uint64(now));



    // remove grant from array

    delete grants[_holder][_grantId];

    grants[_holder][_grantId] = grants[_holder][grants[_holder].length.sub(1)];

    grants[_holder].length -= 1;



    var previousBalanceReceiver = balanceOfAt(receiver, block.number);



    //balances[receiver] = balances[receiver].add(nonVested);

    updateValueAtNow(balances[receiver], previousBalanceReceiver + nonVested);



    var previousBalance_holder = balanceOfAt(_holder, block.number);



    //balances[_holder] = balances[_holder].sub(nonVested);

    updateValueAtNow(balances[_holder], previousBalance_holder - nonVested);



    Transfer(_holder, receiver, nonVested);

    }



    /**

    * @dev Calculate the total amount of transferable tokens of a holder at a given time

    * @param holder address The address of the holder

    * @param time uint64 The specific time.

    * @return An uint256 representing a holder's total amount of transferable tokens.

    */

    function transferableTokens(address holder, uint64 time) public view returns (uint256) {

    uint256 grantIndex = tokenGrantsCount(holder);



    if (grantIndex == 0) return balanceOf(holder); // shortcut for holder without grants



    // Iterate through all the grants the holder has, and add all non-vested tokens

    uint256 nonVested = 0;

    for (uint256 i = 0; i < grantIndex; i++) {

        nonVested = SafeMath.add(nonVested, nonVestedTokens(grants[holder][i], time));

    }



    // Balance - totalNonVested is the amount of tokens a holder can transfer at any given time

    uint256 vestedTransferable = SafeMath.sub(balanceOf(holder), nonVested);



    // Return the minimum of how many vested can transfer and other value

    // in case there are other limiting transferability factors (default is balanceOf)

    return Math.min256(vestedTransferable, balanceOf(holder));

    }



    /**

    * @dev Check the amount of grants that an address has.

    * @param _holder The holder of the grants.

    * @return A uint256 representing the total amount of grants.

    */

    function tokenGrantsCount(address _holder) public view returns (uint256 index) {

    return grants[_holder].length;

    }



    /**

    * @dev Calculate amount of vested tokens at a specifc time.

    * @param tokens uint256 The amount of tokens grantted.

    * @param time uint64 The time to be checked

    * @param start uint64 A time representing the begining of the grant

    * @param cliff uint64 The cliff period.

    * @param vesting uint64 The vesting period.

    * @return An uint256 representing the amount of vested tokensof a specif grant.

    *    transferableTokens

    *    |                        _/--------    vestedTokens rect

    *    |                        _/

    *    |                    _/

    *    |                    _/

    *    |                 _/

    *    |               /

    *    |               .|

    *    |            .    |

    *    |            .    |

    *    |        .        |

    *    |        .        |

    *    |    .            |

    *    +===+===========+---------+----------> time

    *        Start         Clift    Vesting

    */

    function calculateVestedTokens(

    uint256 tokens,

    uint256 time,

    uint256 start,

    uint256 cliff,

    uint256 vesting) internal view returns (uint256)

    {

        // Shortcuts for before cliff and after vesting cases.

        if (time < cliff) return 0;

        if (time >= vesting) return tokens;



        // Interpolate all vested tokens.

        // As before cliff the shortcut returns 0, we can use just calculate a value

        // in the vesting rect (as shown in above's figure)



        // vestedTokens = tokens * (time - start) / (vesting - start)

        uint256 vestedTokens = SafeMath.div(

                                    SafeMath.mul(

                                       tokens,

                                       SafeMath.sub(time, start)

                                       ),

                                    SafeMath.sub(vesting, start)

                                    );



        return vestedTokens;

    }



    /**

    * @dev Get all information about a specifc grant.

    * @param _holder The address which will have its tokens revoked.

    * @param _grantId The id of the token grant.

    * @return Returns all the values that represent a TokenGrant(address, value, start, cliff,

    * revokability, burnsOnRevoke, and vesting) plus the vested value at the current time.

    */

    function tokenGrant(address _holder, uint256 _grantId) public view returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting, bool revokable, bool burnsOnRevoke) {

    TokenGrant storage grant = grants[_holder][_grantId];



    granter = grant.granter;

    value = grant.value;

    start = grant.start;

    cliff = grant.cliff;

    vesting = grant.vesting;

    revokable = grant.revokable;

    burnsOnRevoke = grant.burnsOnRevoke;



    vested = vestedTokens(grant, uint64(now));

    }



    /**

    * @dev Get the amount of vested tokens at a specific time.

    * @param grant TokenGrant The grant to be checked.

    * @param time The time to be checked

    * @return An uint256 representing the amount of vested tokens of a specific grant at a specific time.

    */

    function vestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {

    return calculateVestedTokens(

        grant.value,

        uint256(time),

        uint256(grant.start),

        uint256(grant.cliff),

        uint256(grant.vesting)

    );

    }



    /**

    * @dev Calculate the amount of non vested tokens at a specific time.

    * @param grant TokenGrant The grant to be checked.

    * @param time uint64 The time to be checked

    * @return An uint256 representing the amount of non vested tokens of a specifc grant on the

    * passed time frame.

    */

    function nonVestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {

    // Of all the tokens of the grant, how many of them are not vested?

    // grantValue - vestedTokens

    return grant.value.sub(vestedTokens(grant, time));

    }



    /**

    * @dev Calculate the date when the holder can trasfer all its tokens

    * @param holder address The address of the holder

    * @return An uint256 representing the date of the last transferable tokens.

    */

    function lastTokenIsTransferableDate(address holder) constant public returns (uint64 date) {

    date = uint64(now);

    uint256 grantIndex = grants[holder].length;

    for (uint256 i = 0; i < grantIndex; i++) {

        date = Math.max64(grants[holder][i].vesting, date);

    }

    }



}



/**

 * Dividends

 * Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

 * Copyright 2017, Adam Dossa

 * Based on ProfitSharingContract.sol from https://github.com/adamdossa/ProfitSharingContract

 **/



contract MiniMeIrrVesDivToken is MiniMeIrrevocableVestedToken {



    event DividendDeposited(address indexed _depositor, uint256 _blockNumber, uint256 _timestamp, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);

    event DividendClaimed(address indexed _claimer, uint256 _dividendIndex, uint256 _claim);

    event DividendRecycled(address indexed _recycler, uint256 _blockNumber, uint256 _timestamp, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);



    uint256 public RECYCLE_TIME = 1 years;



    function MiniMeIrrVesDivToken (

         address _tokenFactory,

         address _parentToken,

         uint _parentSnapShotBlock,

         string _tokenName,

         uint8 _decimalUnits,

         string _tokenSymbol,

         bool _transfersEnabled

    ) public MiniMeIrrevocableVestedToken(_tokenFactory, _parentToken, _parentSnapShotBlock, _tokenName, _decimalUnits, _tokenSymbol, _transfersEnabled) {}



    struct Dividend {

    uint256 blockNumber;

    uint256 timestamp;

    uint256 amount;

    uint256 claimedAmount;

    uint256 totalSupply;

    bool recycled;

    mapping (address => bool) claimed;

    }



    Dividend[] public dividends;



    mapping (address => uint256) dividendsClaimed;



    modifier validDividendIndex(uint256 _dividendIndex) {

    require(_dividendIndex < dividends.length);

    _;

    }



    function depositDividend() public payable

    onlyController

    {

    uint256 currentSupply = super.totalSupplyAt(block.number);

    uint256 dividendIndex = dividends.length;

    uint256 blockNumber = SafeMath.sub(block.number, 1);

    dividends.push(

         Dividend(

         blockNumber,

         getNow(),

         msg.value,

         0,

         currentSupply,

         false

         )

    );

    DividendDeposited(msg.sender, blockNumber, getNow(), msg.value, currentSupply, dividendIndex);

    }



    function claimDividend(uint256 _dividendIndex) public

    validDividendIndex(_dividendIndex)

    {

    Dividend storage dividend = dividends[_dividendIndex];

    require(dividend.claimed[msg.sender] == false);

    require(dividend.recycled == false);

    uint256 balance = super.balanceOfAt(msg.sender, dividend.blockNumber);

    uint256 claim = balance.mul(dividend.amount).div(dividend.totalSupply);

    dividend.claimed[msg.sender] = true;

    dividend.claimedAmount = SafeMath.add(dividend.claimedAmount, claim);

    if (claim > 0) {

         msg.sender.transfer(claim);

         DividendClaimed(msg.sender, _dividendIndex, claim);

    }

    }



    function claimDividendAll() public {

    require(dividendsClaimed[msg.sender] < dividends.length);

    for (uint i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {

         if ((dividends[i].claimed[msg.sender] == false) && (dividends[i].recycled == false)) {

         dividendsClaimed[msg.sender] = SafeMath.add(i, 1);

         claimDividend(i);

         }

    }

    }



    function recycleDividend(uint256 _dividendIndex) public

    onlyController

    validDividendIndex(_dividendIndex)

    {

    Dividend storage dividend = dividends[_dividendIndex];

    require(dividend.recycled == false);

    require(dividend.timestamp < SafeMath.sub(getNow(), RECYCLE_TIME));

    dividends[_dividendIndex].recycled = true;

    uint256 currentSupply = super.totalSupplyAt(block.number);

    uint256 remainingAmount = SafeMath.sub(dividend.amount, dividend.claimedAmount);

    uint256 dividendIndex = dividends.length;

    uint256 blockNumber = SafeMath.sub(block.number, 1);

    dividends.push(

         Dividend(

         blockNumber,

         getNow(),

         remainingAmount,

         0,

         currentSupply,

         false

         )

    );

    DividendRecycled(msg.sender, blockNumber, getNow(), remainingAmount, currentSupply, dividendIndex);

    }



    function getNow() internal constant returns (uint256) {

    return now;

    }

}



/**

 * Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

 **/



contract ESCBCoin is MiniMeIrrVesDivToken {

    // @dev ESCBCoin constructor just parametrizes the MiniMeIrrVesDivToken constructor

    function ESCBCoin (

      address _tokenFactory

    ) public MiniMeIrrVesDivToken(

    _tokenFactory,

    0x0,            // no parent token

    0,               // no snapshot block number from parent

    "ESCB token",    // Token name

    18,             // Decimals

    "ESCB",         // Symbol

    true            // Enable transfers

    ) {}

}



/**

    *    Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

    *    Copyright 2017, Jorge Izquierdo (Aragon Foundation)

    **/



/*



@notice The ESCBCoinPlaceholder contract will take control over the ESCB coin after the sale

        is finalized and before the EscrowBlock Network is deployed.



        The contract allows for ESCBCoin transfers and transferFrom and implements the

        logic for transfering control of the token to the network when the sale

        asks it to do so.

*/



contract ESCBCoinPlaceholder is TokenController {

    address public tokenSale;

    ESCBCoin public token;



    function ESCBCoinPlaceholder(address _sale, address _ESCBCoin) public {

    tokenSale = _sale;

    token = ESCBCoin(_ESCBCoin);

    }



    function changeController(address network) public {

    assert(msg.sender == tokenSale);

    token.changeController(network);

    selfdestruct(network); // network gets all amount

    }



    // In between the sale and the network. Default settings for allowing token transfers.

    function proxyPayment(address _owner) public payable returns (bool) {

    revert();

    return false;

    }



    function onTransfer(address _from, address _to, uint _amount) public returns (bool) {

    return true;

    }



    function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {

    return true;

    }

}



// @dev Contract to hold sale raised funds during the sale period.

// Prevents attack in which the ESCB Multisig sends raised ether

// to the sale contract to mint tokens to itself, and getting the

// funds back immediately.



contract AbstractSale {

    function saleFinalized() public returns (bool);

    function minGoalReached() public returns (bool);

}



contract SaleWallet {

    using SafeMath for uint256;



    enum State { Active, Refunding }

    State public currentState;



    mapping (address => uint256) public deposited;



    //Events

    event Withdrawal();

    event RefundsEnabled();

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    event Deposit(address beneficiary, uint256 weiAmount);



    // Public variables

    address public multisig;

    AbstractSale public tokenSale;



    // @dev Constructor initializes public variables

    // @param _multisig The address of the multisig that will receive the funds

    // @param _tokenSale The address of the token sale

    function SaleWallet(address _multisig, address _tokenSale) {

    currentState = State.Active;

    multisig = _multisig;

    tokenSale = AbstractSale(_tokenSale);

    }



    // @dev Receive all sent funds and build the refund map

    function deposit(address investor, uint256 amount) public {

    require(currentState == State.Active);

    require(msg.sender == address(tokenSale));

    deposited[investor] = deposited[investor].add(amount);

    Deposit(investor, amount);

    }



    // @dev Withdraw function sends all the funds to the wallet if conditions are correct

    function withdraw() public {

    require(currentState == State.Active);

    assert(msg.sender == multisig);    // Only the multisig can request it

    if (tokenSale.minGoalReached()) {    // Allow when sale reached minimum goal

        return doWithdraw();

    }

    }



    function doWithdraw() internal {

    assert(multisig.send(this.balance));

    Withdrawal();

    }



    function enableRefunds() public {

    require(currentState == State.Active);

    assert(msg.sender == multisig);    // Only the multisig can request it

    require(!tokenSale.minGoalReached());    // Allow when minimum goal isn't reached

    require(tokenSale.saleFinalized()); // Allow when sale is finalized

    currentState = State.Refunding;

    RefundsEnabled();

    }



    function refund(address investor) public {

    require(currentState == State.Refunding);

    require(msg.sender == address(tokenSale));

    require(deposited[investor] != 0);

    uint256 depositedValue = deposited[investor];

    deposited[investor] = 0;

    assert(investor.send(depositedValue));

    Refunded(investor, depositedValue);

    }



    // @dev Receive all sent funds

    function () public payable {}

}





/**

 * Copyright 2018, Konstantin Viktorov (EscrowBlock Foundation)

 * Copyright 2017, Jorge Izquierdo (Aragon Foundation)

 * Copyright 2017, Jordi Baylina (Giveth)

 *

 * Based on SampleCampaign-TokenController.sol from https://github.com/Giveth/minime

 * This is the new token sale smart contract for conduction IITO and Airdrop together,

 * also it will allow having a stable price for some period after exchange listing.

 **/



 contract ESCBTokenSale is TokenController {

   uint256 public initialTime;           // Time in which the sale starts. Inclusive. sale will be opened at initial time.

   uint256 public controlTime;           // The Unix time in which the sale needs to check on the refunding start.

   uint256 public price;                 // Number of wei-ESCBCoin tokens for 1 ether

   address public ESCBDevMultisig;       // The address to hold the funds donated



   uint256 public affiliateBonusPercent = 2;     // Purpose in percentage of payment via referral

   uint256 public totalCollected = 0;            // In wei

   bool public saleStopped = false;              // Has ESCB Dev stopped the sale?

   bool public saleFinalized = false;            // Has ESCB Dev finalized the sale?



   mapping (address => bool) public activated;   // Address confirmates that wants to activate the sale



   ESCBCoin public token;                         // The token

   ESCBCoinPlaceholder public networkPlaceholder; // The network placeholder

   SaleWallet public saleWallet;                  // Wallet that receives all sale funds



   uint256 constant public dust = 1 finney; // Minimum investment

   uint256 public minGoal;                  // amount of minimum fund in wei

   uint256 public goal;                     // Goal for IITO in wei

   uint256 public currentStage = 1;         // Current stage

   uint256 public allocatedStage = 1;       // Current stage when was allocated tokens for ESCB

   uint256 public usedTotalSupply = 0;      // This uses for calculation ESCB allocation part



   event ActivatedSale();

   event FinalizedSale();

   event NewBuyer(address indexed holder, uint256 ESCBCoinAmount, uint256 etherAmount);

   event NewExternalFoundation(address indexed holder, uint256 ESCBCoinAmount, uint256 etherAmount, bytes32 externalId);

   event AllocationForESCBFund(address indexed holder, uint256 ESCBCoinAmount);

   event NewStage(uint64 numberStage);

   // @dev There are several checks to make sure the parameters are acceptable

   // @param _initialTime The Unix time in which the sale starts

   // @param _controlTime The Unix time in which the sale needs to check on the refunding start

   // @param _ESCBDevMultisig The address that will store the donated funds and manager for the sale

   // @param _price The price. Price in wei-ESCBCoin per wei

   function ESCBTokenSale (uint _initialTime, uint _controlTime, address _ESCBDevMultisig, uint256 _price)

            non_zero_address(_ESCBDevMultisig) {

     assert (_initialTime >= getNow());

     assert (_initialTime < _controlTime);



     // Save constructor arguments as global variables

     initialTime = _initialTime;

     controlTime = _controlTime;

     ESCBDevMultisig = _ESCBDevMultisig;

     price = _price;

   }



   modifier only(address x) {

     require(msg.sender == x);

     _;

   }



   modifier only_before_sale {

     require(getNow() < initialTime);

     _;

   }



   modifier only_during_sale_period {

     require(getNow() >= initialTime);



     // if minimum goal is reached, then infinite time to reach the main goal

     require(getNow() < controlTime || minGoalReached());

     _;

   }



   modifier only_after_sale {

     require(getNow() >= controlTime || goalReached());

     _;

   }



   modifier only_sale_stopped {

     require(saleStopped);

     _;

   }



   modifier only_sale_not_stopped {

     require(!saleStopped);

     _;

   }



   modifier only_before_sale_activation {

     require(!isActivated());

     _;

   }



   modifier only_sale_activated {

     require(isActivated());

     _;

   }



   modifier only_finalized_sale {

     require(getNow() >= controlTime || goalReached());

     require(saleFinalized);

     _;

   }



   modifier non_zero_address(address x) {

     require(x != 0);

     _;

   }



   modifier minimum_value(uint256 x) {

     require(msg.value >= x);

     _;

   }



   // @notice Deploy ESCBCoin is called only once to setup all the needed contracts.

   // @param _token: Address of an instance of the ESCBCoin token

   // @param _networkPlaceholder: Address of an instance of ESCBCoinPlaceholder

   // @param _saleWallet: Address of the wallet receiving the funds of the sale

   // @param _minGoal: Minimum fund for success

   // @param _goal: The end fund amount

   function setESCBCoin(address _token, address _networkPlaceholder, address _saleWallet, uint256 _minGoal, uint256 _goal)

            payable

            non_zero_address(_token)

            only(ESCBDevMultisig)

            public {



     // 3 times by non_zero_address is not working for current compiler version

     require(_networkPlaceholder != 0);

     require(_saleWallet != 0);



     // Assert that the function hasn't been called before, as activate will happen at the end

     assert(!activated[this]);



     token = ESCBCoin(_token);

     networkPlaceholder = ESCBCoinPlaceholder(_networkPlaceholder);

     saleWallet = SaleWallet(_saleWallet);



     assert(token.controller() == address(this));             // sale is controller

     assert(token.totalSupply() == 0);                        // token is empty



     assert(networkPlaceholder.tokenSale() == address(this)); // placeholder has reference to Sale

     assert(networkPlaceholder.token() == address(token));    // placeholder has reference to ESCBCoin



     assert(saleWallet.multisig() == ESCBDevMultisig);        // receiving wallet must match

     assert(saleWallet.tokenSale() == address(this));         // watched token sale must be self



     assert(_minGoal > 0);                                   // minimum goal is not empty

     assert(_goal > 0);                                      // the main goal is not empty

     assert(_minGoal < _goal);                               // minimum goal is less than the main goal



     minGoal = _minGoal;

     goal = _goal;



     // Contract activates sale as all requirements are ready

     doActivateSale(this);

   }



   function activateSale()

            public {

     doActivateSale(msg.sender);

     ActivatedSale();

   }



   function doActivateSale(address _entity)

     non_zero_address(token) // cannot activate before setting token

     only_before_sale

     private {

     activated[_entity] = true;

   }



   // @notice Whether the needed accounts have activated the sale.

   // @return Is sale activated

   function isActivated()

            constant

            public

            returns (bool) {

     return activated[this] && activated[ESCBDevMultisig];

   }



   // @notice Get the price for tokens for the current stage

   // @param _amount the amount for which the price is requested

   // @return Number of wei-ESCBToken

   function getPrice(uint256 _amount)

            only_during_sale_period

            only_sale_not_stopped

            only_sale_activated

            constant

            public

            returns (uint256) {

     return priceForStage(SafeMath.mul(_amount, price));

   }



   // @notice Get the bonus tokens for a stage

   // @param _amount the amount of tokens

   // @return Number of wei-ESCBCoin with bonus for 1 wei

   function priceForStage(uint256 _amount)

            internal

            returns (uint256) {



     if (totalCollected >= 0 && totalCollected <= 80 ether) { // 1 ETH = 500 USD, then 40 000 USD 1 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 20), 100));

     }



     if (totalCollected > 80 ether && totalCollected <= 200 ether) { // 1 ETH = 500 USD, then 100 000 USD 2 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 18), 100));

     }



     if (totalCollected > 200 ether && totalCollected <= 400 ether) { // 1 ETH = 500 USD, then 200 000 USD 3 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 16), 100));

     }



     if (totalCollected > 400 ether && totalCollected <= 1000 ether) { // 1 ETH = 500 USD, then 500 000 USD 4 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 14), 100));

     }



     if (totalCollected > 1000 ether && totalCollected <= 2000 ether) { // 1 ETH = 500 USD, then 1 000 000 USD 5 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 12), 100));

     }



     if (totalCollected > 2000 ether && totalCollected <= 4000 ether) { // 1 ETH = 500 USD, then 2 000 000 USD 6 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 10), 100));

     }



     if (totalCollected > 4000 ether && totalCollected <= 8000 ether) { // 1 ETH = 500 USD, then 4 000 000 USD 7 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 8), 100));

     }



     if (totalCollected > 8000 ether && totalCollected <= 12000 ether) { // 1 ETH = 500 USD, then 6 000 000 USD 8 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 6), 100));

     }



     if (totalCollected > 12000 ether && totalCollected <= 16000 ether) { // 1 ETH = 500 USD, then 8 000 000 USD 9 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 4), 100));

     }



     if (totalCollected > 16000 ether && totalCollected <= 20000 ether) { // 1 ETH = 500 USD, then 10 000 000 USD 10 stage

       return SafeMath.add(_amount, SafeMath.div(SafeMath.mul(_amount, 2), 100));

     }



     if (totalCollected > 20000 ether) { // without bonus

       return _amount;

     }

   }



   // ESCBDevMultisig can use this function for allocation tokens

   // for ESCB Foundation by each stage, start from 2nd

   // Amount of stages can not be more than MAX_GRANTS_PER_ADDRESS

   function allocationForESCBbyStage()

            only(ESCBDevMultisig)

            public {

      if (totalCollected >= 0 && totalCollected <= 80 ether) { // 1 ETH = 500 USD, then 40 000 USD 1 stage

        currentStage = 1;

      }



      if (totalCollected > 80 ether && totalCollected <= 200 ether) { // 1 ETH = 500 USD, then 100 000 USD 2 stage

        currentStage = 2;

      }



      if (totalCollected > 200 ether && totalCollected <= 400 ether) { // 1 ETH = 500 USD, then 200 000 USD 3 stage

        currentStage = 3;

      }



      if (totalCollected > 400 ether && totalCollected <= 1000 ether) { // 1 ETH = 500 USD, then 500 000 USD 4 stage

        currentStage = 4;

      }



      if (totalCollected > 1000 ether && totalCollected <= 2000 ether) { // 1 ETH = 500 USD, then 1 000 000 USD 5 stage

        currentStage = 5;

      }



      if (totalCollected > 2000 ether && totalCollected <= 4000 ether) { // 1 ETH = 500 USD, then 2 000 000 USD 6 stage

        currentStage = 6;

      }



      if (totalCollected > 4000 ether && totalCollected <= 8000 ether) { // 1 ETH = 500 USD, then 4 000 000 USD 7 stage

        currentStage = 7;

      }



      if (totalCollected > 8000 ether && totalCollected <= 12000 ether) { // 1 ETH = 500 USD, then 6 000 000 USD 8 stage

        currentStage = 8;

      }



      if (totalCollected > 12000 ether && totalCollected <= 16000 ether) { // 1 ETH = 500 USD, then 8 000 000 USD 9 stage

        currentStage = 9;

      }



      if (totalCollected > 16000 ether && totalCollected <= 20000 ether) { // 1 ETH = 500 USD, then 10 000 000 USD 10 stage

        currentStage = 10;

      }

     if(currentStage > allocatedStage) {

       // ESCB Foundation owns 30% of the total number of emitted tokens.

       // totalSupply here 66%, then we 30%/66% to get amount 30% of tokens

       uint256 ESCBTokens = SafeMath.div(SafeMath.mul(SafeMath.sub(uint256(token.totalSupply()), usedTotalSupply), 15), 33);

       uint256 prevTotalSupply = uint256(token.totalSupply());

       if(token.generateTokens(address(this), ESCBTokens)) {

         allocatedStage = currentStage;

         usedTotalSupply = prevTotalSupply;

         uint64 cliffDate = uint64(SafeMath.add(uint256(now), 365 days));

         uint64 vestingDate = uint64(SafeMath.add(uint256(now), 547 days));

         token.grantVestedTokens(ESCBDevMultisig, ESCBTokens, uint64(now), cliffDate, vestingDate, true, false);

         AllocationForESCBFund(ESCBDevMultisig, ESCBTokens);

       } else {

         revert();

       }

     }

   }



   // @notice Notifies the controller about a transfer, for this sale all

   //  transfers are allowed by default and no extra notifications are needed

   // @param _from The origin of the transfer

   // @param _to The destination of the transfer

   // @param _amount The amount of the transfer

   // @return False if the controller does not authorize the transfer

   function onTransfer(address _from, address _to, uint _amount)

            public

            returns (bool) {

     return true;

   }



   // @notice Notifies the controller about an approval, for this sale all

   //  approvals are allowed by default and no extra notifications are needed

   // @param _owner The address that calls `approve()`

   // @param _spender The spender in the `approve()` call

   // @param _amount The amount in the `approve()` call

   // @return False if the controller does not authorize the approval

   function onApprove(address _owner, address _spender, uint _amount)

            public

            returns (bool) {

     return true;

   }



   // @dev The fallback function is called when ether is sent to the contract, it

   // simply calls `doPayment()` with the address that sent the ether as the

   // `_owner`. Payable is a require solidity modifier for functions to receive

   // ether, without this modifier functions will throw if ether is sent to them

   function ()

            public

            payable {

     doPayment(msg.sender);

   }



 // @dev This function allow to get bonus tokens for a buyer and for referral

   function paymentAffiliate(address _referral)

            non_zero_address(_referral)

            payable

            public {

     uint256 boughtTokens = doPayment(msg.sender);

     uint256 affiliateBonus = SafeMath.div(

                                SafeMath.mul(boughtTokens, affiliateBonusPercent), 100

                              ); // Calculate how many bonus tokens need to add

     assert(token.generateTokens(_referral, affiliateBonus));

     assert(token.generateTokens(msg.sender, affiliateBonus));

   }



 ////////////

 // Controller interface

 ////////////



   // @notice `proxyPayment()` allows the caller to send ether to the Token directly and

   // have the tokens created in an address of their choosing

   // @param _owner The address that will hold the newly created tokens



   function proxyPayment(address _owner)

            payable

            public

            returns (bool) {

     doPayment(_owner);

     return true;

   }



   // @dev `doPayment()` is an internal function that sends the ether that this

   //  contract receives to the ESCBDevMultisig and creates tokens in the address of the sender

   // @param _owner The address that will hold the newly created tokens

   function doPayment(address _owner)

            only_during_sale_period

            only_sale_not_stopped

            only_sale_activated

            non_zero_address(_owner)

            minimum_value(dust)

            internal

            returns (uint256) {

     assert(totalCollected + msg.value <= goal); // If goal is reached, throw

     uint256 boughtTokens = priceForStage(SafeMath.mul(msg.value, price)); // Calculate how many tokens bought

     saleWallet.transfer(msg.value); // Send funds to multisig

     saleWallet.deposit(_owner, msg.value); // Send info about deposit to multisig

     assert(token.generateTokens(_owner, boughtTokens)); // Allocate tokens.

     totalCollected = SafeMath.add(totalCollected, msg.value); // Save total collected amount

     NewBuyer(_owner, boughtTokens, msg.value);



     return boughtTokens;

   }



   // @notice Function for issuing new tokens for address which made purchasing not in

   // ETH currency, for example via cards or wire transfer.

   // @dev Only ESCB Dev can do it with the publishing of transaction id in an external system.

   // Any audits will be able to confirm eligibility of issuing in such case.

   // @param _owner The address that will hold the newly created tokens

   // @param _amount Amount of purchasing in ETH

   function issueWithExternalFoundation(address _owner, uint256 _amount, bytes32 _extId)

            only_during_sale_period

            only_sale_not_stopped

            only_sale_activated

            non_zero_address(_owner)

            only(ESCBDevMultisig)

            public

            returns (uint256) {

     assert(totalCollected + _amount <= goal); // If goal is reached, throw

     uint256 boughtTokens = priceForStage(SafeMath.mul(_amount, price)); // Calculate how many tokens bought



     assert(token.generateTokens(_owner, boughtTokens)); // Allocate tokens.

     totalCollected = SafeMath.add(totalCollected, _amount); // Save total collected amount



     // Events

     NewBuyer(_owner, boughtTokens, _amount);

     NewExternalFoundation(_owner, boughtTokens, _amount, _extId);



     return boughtTokens;

   }



   // @notice Function to stop sale for an emergency.

   // @dev Only ESCB Dev can do it after it has been activated.

   function emergencyStopSale()

            only_sale_activated

            only_sale_not_stopped

            only(ESCBDevMultisig)

            public {

     saleStopped = true;

   }



   // @notice Function to restart stopped sale.

   // @dev Only ESCB Dev can do it after it has been disabled and sale is ongoing.

   function restartSale()

            only_during_sale_period

            only_sale_stopped

            only(ESCBDevMultisig)

            public {

     saleStopped = false;

   }



   // @notice Finalizes sale when main goal is reached or if for control time the minimum goal was not reached.

   // @dev Transfers the token controller power to the ESCBCoinPlaceholder.

   function finalizeSale()

            only_after_sale

            only(ESCBDevMultisig)

            public {

     token.changeController(networkPlaceholder); // Sale loses token controller power in favor of network placeholder

     saleFinalized = true;  // Set finalized flag as true, that will allow enabling network deployment

     saleStopped = true;

     FinalizedSale();

   }



   // @notice Deploy ESCB Network contract.

   // @param _networkAddress: The address the network was deployed at.

   function deployNetwork(address _networkAddress)

            only_finalized_sale

            non_zero_address(_networkAddress)

            only(ESCBDevMultisig)

            public {

     networkPlaceholder.changeController(_networkAddress);

   }



   // @notice Set up new ESCB Dev.

   // @param _newMultisig: The address new ESCB Dev.

   function setESCBDevMultisig(address _newMultisig)

            non_zero_address(_newMultisig)

            only(ESCBDevMultisig)

            public {

     ESCBDevMultisig = _newMultisig;

   }



   // @notice Get current unix time stamp

   function getNow()

            constant

            internal

            returns (uint) {

     return now;

   }



   // @notice If crowdsale is unsuccessful, investors can claim refunds here

   function claimRefund()

            only_finalized_sale

            public {

     require(!minGoalReached());

     saleWallet.refund(msg.sender);

   }



   // @notice Check minimum goal for 1st stage

   function minGoalReached()

            public

            view

            returns (bool) {

     return totalCollected >= minGoal;

   }



   // @notice Check the main goal for 10th stage

   function goalReached()

            public

            view

            returns (bool) {

     return totalCollected >= goal;

   }

 }