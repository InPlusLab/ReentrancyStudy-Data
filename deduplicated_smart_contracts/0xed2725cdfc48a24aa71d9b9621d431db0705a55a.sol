pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
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
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract&#39;s goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO&#39;s
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.


/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint256 _amount) returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint256 _amount)
    returns(bool);
}

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}

/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token&#39;s name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = &#39;MMT_0.1&#39;; //An arbitrary versioning scheme


    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

    // `fromBlock` is the block number that the value was generated from
    uint128 fromBlock;

    // `value` is the amount of tokens at a specific block number
    uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint256 public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint256 public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
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
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    /// @param _parentToken Address of the parent token, set to 0x0 if it is a
    ///  new token
    /// @param _parentSnapShotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint256 _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
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
        return doTransfer(msg.sender, _to, _amount);
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint256 _amount
    ) internal returns(bool) {

        if (_amount == 0) {
            return true;
        }

        require(parentSnapShotBlock < block.number);

        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != 0) && (_to != address(this)));

        // If the amount being transfered is more than the balance of the
        //  account the transfer returns false
        var previousBalanceFrom = balanceOfAt(_from, block.number);
        if (previousBalanceFrom < _amount) {
            return false;
        }

        // Alerts the token controller of the transfer
        if (isContract(controller)) {
            require(TokenController(controller).onTransfer(_from, _to, _amount));
        }

        // First update the balance array with the new value for the address
        //  sending the tokens
        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

        // Then update the balance array with the new value for the address
        //  receiving the tokens
        var previousBalanceTo = balanceOfAt(_to, block.number);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(balances[_to], previousBalanceTo + _amount);

        // An event to make the transfer easy to find on the blockchain
        Transfer(_from, _to, _amount);

        return true;
    }

    /// @param _owner The address that&#39;s balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
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
    ///  to spend
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
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
    function balanceOfAt(address _owner, uint256 _blockNumber) constant
    returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
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
    function totalSupplyAt(uint256 _blockNumber) constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
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
    ///  this token at `_snapshotBlock`
    /// @param _cloneTokenName Name of the clone token
    /// @param _cloneDecimalUnits Number of decimals of the smallest unit
    /// @param _cloneTokenSymbol Symbol of the clone token
    /// @param _snapshotBlock Block when the distribution of the parent token is
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    /// @param _transfersEnabled True if transfers are allowed in the clone
    /// @return The address of the new MiniMeToken Contract
    function createCloneToken(
    string _cloneTokenName,
    uint8 _cloneDecimalUnits,
    string _cloneTokenSymbol,
    uint256 _snapshotBlock,
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
    function generateTokens(address _owner, uint256 _amount
    ) onlyController returns (bool) {
        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint256 previousBalanceTo = balanceOf(_owner);
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
    function getValueAt(Checkpoint[] storage checkpoints, uint256 _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
        return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint256 min = 0;
        uint256 max = checkpoints.length-1;
        while (max > min) {
            uint256 mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
            newCheckPoint.fromBlock =  uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        uint256 size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    /// @dev Helper function to return a min betwen the two uints
    function min(uint256 a, uint256 b) internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract&#39;s controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function ()  payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

    //////////
    // Safety Methods
    //////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

    ////////////////
    // Events
    ////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint256 _snapshotBlock);
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
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
        address _parentToken,
        uint256 _snapshotBlock,
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

contract TokenBurner {
    function burn(address , uint256 )
    returns (bool result) {
        return false;
    }
}

contract FiinuToken is MiniMeToken, Ownable {

    TokenBurner public tokenBurner;

    function FiinuToken(address _tokenFactory)
    MiniMeToken(
        _tokenFactory,
        0x0,                     // no parent token
        0,                       // no snapshot block number from parent
        "Fiinu Token",           // Token name
        6,                       // Decimals
        "FNU",                   // Symbol
        true                    // Enable transfers
    )
    {}

    function setTokenBurner(address _tokenBurner) onlyOwner {
        tokenBurner = TokenBurner(_tokenBurner);
    }

    // allows a token holder to burn tokens
    // requires tokenBurner to be set to a valid contract address
    // tokenBurner can take any appropriate action
    function burn(uint256 _amount) {
        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint256 previousBalanceFrom = balanceOf(msg.sender);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[msg.sender], previousBalanceFrom - _amount);
        assert(tokenBurner.burn(msg.sender, _amount));
        Transfer(msg.sender, 0, _amount);
    }

}

contract Milestones is Ownable {

    enum State { PreIco, IcoOpen, IcoClosed, IcoSuccessful, IcoFailed, BankLicenseSuccessful, BankLicenseFailed }

    event Milestone(string _announcement, State _state);

    State public state = State.PreIco;
    bool public tradingOpen = false;

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    modifier isTradingOpen() {
        require(tradingOpen);
        _;
    }

    function Milestone_OpenTheIco(string _announcement) onlyOwner inState(State.PreIco) {
        state = State.IcoOpen;
        Milestone(_announcement, state);
    }

    function Milestone_CloseTheIco(string _announcement) onlyOwner inState(State.IcoOpen) {
        state = State.IcoClosed;
        Milestone(_announcement, state);
    }

    function Milestone_IcoSuccessful(string _announcement) onlyOwner inState(State.IcoClosed) {
        state = State.IcoSuccessful;
        Milestone(_announcement, state);
    }

    function Milestone_IcoFailed(string _announcement) onlyOwner inState(State.IcoClosed) {
        state = State.IcoFailed;
        Milestone(_announcement, state);
    }

    function Milestone_BankLicenseSuccessful(string _announcement) onlyOwner inState(State.IcoSuccessful) {
        tradingOpen = true;
        state = State.BankLicenseSuccessful;
        Milestone(_announcement, state);
    }

    function Milestone_BankLicenseFailed(string _announcement) onlyOwner inState(State.IcoSuccessful) {
        state = State.BankLicenseFailed;
        Milestone(_announcement, state);
    }

}

contract Investors is Milestones {

    struct WhitelistEntry {
        uint256 max;
        uint256 total;
        bool init;
    }

    mapping(address => bool) internal admins;
    mapping(address => WhitelistEntry) approvedInvestors;

    modifier onlyAdmins() {
        require(admins[msg.sender] == true);
        _;
    }

    function manageInvestors(address _investors_wallet_address, uint256 _max_approved_investment) onlyAdmins {
        if(approvedInvestors[_investors_wallet_address].init){
            approvedInvestors[_investors_wallet_address].max = SafeMath.mul(_max_approved_investment, 10 ** 18); // ETH to WEI
            // clean up
            if(approvedInvestors[_investors_wallet_address].max == 0 && approvedInvestors[_investors_wallet_address].total == 0)
            delete approvedInvestors[_investors_wallet_address];
        }
        else{
            approvedInvestors[_investors_wallet_address] = WhitelistEntry(SafeMath.mul(_max_approved_investment, 10 ** 18), 0, true);
        }
    }

    function manageAdmins(address _address, bool _add) onlyOwner {
        admins[_address] = _add;
    }

}

contract FiinuCrowdSale is TokenController, Investors {
    using SafeMath for uint256;

    event Investment(address indexed _investor, uint256 _valueEth, uint256 _valueFnu);
    event RefundAdded(address indexed _refunder, uint256 _valueEth);
    event RefundEnabled(uint256 _valueEth);

    address wallet;
    address public staff_1 = 0x2717FCee32b2896E655Ad82EfF81987A34EFF3E7;
    address public staff_2 = 0x7ee4471C371e581Af42b280CD19Ed7593BD7D15F;
    address public staff_3 = 0xE6BeCcc43b48416CE69B6d03c2e44E2B7b8F77b4;
    address public staff_4 = 0x3369De7Ff98bd5C225a67E09ac81aFa7b5dF3d3d;

    uint256 constant minRaisedWei = 20000 ether;
    uint256 constant targetRaisedWei = 100000 ether;
    uint256 constant maxRaisedWei = 400000 ether;
    uint256 public raisedWei = 0;
    uint256 public refundWei = 0;

    bool public refundOpen = false;

    MiniMeToken public tokenContract;   // The new token for this Campaign

    function FiinuCrowdSale(address _wallet, address _tokenAddress) {
        wallet = _wallet; // multi sig wallet
        tokenContract = MiniMeToken(_tokenAddress);// The Deployed Token Contract
    }

    /////////////////
    // TokenController interface
    /////////////////

    /// @notice `proxyPayment()` returns false, meaning ether is not accepted at
    ///  the token address, only the address of FiinuCrowdSale
    /// @param _owner The address that will hold the newly created tokens

    function proxyPayment(address _owner) payable returns(bool) {
        return false;
    }

    /// @notice Notifies the controller about a transfer, for this Campaign all
    ///  transfers are allowed by default and no extra notifications are needed
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint256 _amount) returns(bool) {
        return tradingOpen;
    }

    /// @notice Notifies the controller about an approval, for this Campaign all
    ///  approvals are allowed by default and no extra notifications are needed
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint256 _amount)
    returns(bool)
    {
        return true;
    }

    function weiToFNU(uint256 _wei) public constant returns (uint){
        uint256 _return;
        // 1 FNU = 0.75 ETH
        if(state == State.PreIco){
            _return = _wei.add(_wei.div(3));
        }
        else {
            // 1 FNU = 1 ETH
            if(raisedWei < targetRaisedWei){
                _return = _wei;
            } else {
                // 1 FNU = raisedWei / targetRaisedWei
                _return = _wei.mul(targetRaisedWei).div(raisedWei);
            }
        }
        // WEI to FNU
        return _return.div(10 ** 12);
    }

    function () payable { // incoming investment in the state of PreIco or IcoOpen

        require(msg.value != 0); // incoming transaction must have value
        require(state == State.PreIco || state == State.IcoOpen);
        require(approvedInvestors[msg.sender].init == true); // is approved investor
        require(approvedInvestors[msg.sender].max >= approvedInvestors[msg.sender].total.add(msg.value)); // investment is not breaching max approved investment amount
        require(maxRaisedWei >= raisedWei.add(msg.value)); // investment is not breaching max raising limit

        uint256 _fnu = weiToFNU(msg.value);
        require(_fnu > 0);

        raisedWei = raisedWei.add(msg.value);
        approvedInvestors[msg.sender].total = approvedInvestors[msg.sender].total.add(msg.value); // increase total invested
        mint(msg.sender, _fnu); // Mint the tokens
        wallet.transfer(msg.value); // Move ETH to multi sig wallet
        Investment(msg.sender, msg.value, _fnu); // Announce investment
    }

    function refund() payable {
        require(msg.value != 0); // incoming transaction must have value
        require(state == State.IcoClosed || state == State.IcoSuccessful || state == State.IcoFailed || state == State.BankLicenseFailed);
        refundWei = refundWei.add(msg.value);
        RefundAdded(msg.sender, msg.value);
    }

    function Milestone_IcoSuccessful(string _announcement) onlyOwner {
        require(raisedWei >= minRaisedWei);
        uint256 _toBeAllocated = tokenContract.totalSupply();
        _toBeAllocated = _toBeAllocated.div(10);
        mint(staff_1, _toBeAllocated.mul(81).div(100)); // 81%
        mint(staff_2, _toBeAllocated.mul(9).div(100)); // 9%
        mint(staff_3, _toBeAllocated.mul(15).div(1000));  // 1.5%
        mint(staff_4, _toBeAllocated.mul(15).div(1000)); // 1.5%
        mint(owner, _toBeAllocated.mul(7).div(100)); // 7%
        super.Milestone_IcoSuccessful(_announcement);
    }

    function Milestone_IcoFailed(string _announcement) onlyOwner {
        require(raisedWei < minRaisedWei);
        super.Milestone_IcoFailed(_announcement);
    }

    function Milestone_BankLicenseFailed(string _announcement) onlyOwner {
        // remove staff allocations
        burn(staff_1);
        burn(staff_2);
        burn(staff_3);
        burn(staff_4);
        burn(owner);
        super.Milestone_BankLicenseFailed(_announcement);
    }

    function EnableRefund() onlyOwner {
        require(state == State.IcoFailed || state == State.BankLicenseFailed);
        require(refundWei > 0);
        refundOpen = true;
        RefundEnabled(refundWei);
    }

    // handle automatic refunds
    function RequestRefund() public {
        require(refundOpen);
        require(state == State.IcoFailed || state == State.BankLicenseFailed);
        require(tokenContract.balanceOf(msg.sender) > 0); // you must have some FNU to request refund
        // refund prorata against your ETH investment
        uint256 refundAmount = refundWei.mul(approvedInvestors[msg.sender].total).div(raisedWei);
        burn(msg.sender);
        msg.sender.transfer(refundAmount);
    }

    // minting possible only if State.PreIco and State.IcoOpen for () payable or State.IcoClosed for investFIAT()
    function mint(address _to, uint256 _tokens) internal {
        tokenContract.generateTokens(_to, _tokens);
    }

    // burning only in State.ICOcompleted for Milestone_BankLicenseFailed() or State.BankLicenseFailed for RequestRefund()
    function burn(address _address) internal {
        tokenContract.destroyTokens(_address, tokenContract.balanceOf(_address));
    }
}

contract ProfitSharing is Ownable {
    using SafeMath for uint256;

    event DividendDeposited(address indexed _depositor, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);
    event DividendClaimed(address indexed _claimer, uint256 _dividendIndex, uint256 _claim);
    event DividendRecycled(address indexed _recycler, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);

    MiniMeToken public token;

    uint256 public RECYCLE_TIME = 1 years;

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

    function ProfitSharing(address _token) {
        token = MiniMeToken(_token);
    }

    function depositDividend() payable
    onlyOwner
    {
        uint256 currentSupply = token.totalSupplyAt(block.number);
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
        DividendDeposited(msg.sender, blockNumber, msg.value, currentSupply, dividendIndex);
    }

    function claimDividend(uint256 _dividendIndex) public
    validDividendIndex(_dividendIndex)
    {
        Dividend storage dividend = dividends[_dividendIndex];
        require(dividend.claimed[msg.sender] == false);
        require(dividend.recycled == false);
        uint256 balance = token.balanceOfAt(msg.sender, dividend.blockNumber);
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
        for (uint256 i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {
            if ((dividends[i].claimed[msg.sender] == false) && (dividends[i].recycled == false)) {
                dividendsClaimed[msg.sender] = SafeMath.add(i, 1);
                claimDividend(i);
            }
        }
    }

    function recycleDividend(uint256 _dividendIndex) public
    onlyOwner
    validDividendIndex(_dividendIndex)
    {
        Dividend storage dividend = dividends[_dividendIndex];
        require(dividend.recycled == false);
        require(dividend.timestamp < SafeMath.sub(getNow(), RECYCLE_TIME));
        dividends[_dividendIndex].recycled = true;
        uint256 currentSupply = token.totalSupplyAt(block.number);
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
        DividendRecycled(msg.sender, blockNumber, remainingAmount, currentSupply, dividendIndex);
    }

    //Function is mocked for tests
    function getNow() internal constant returns (uint256) {
        return now;
    }

}