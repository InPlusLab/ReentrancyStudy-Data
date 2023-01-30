/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.8;

/**
 * @title ERC20 compatible token interface
 *
 * - Implements ERC 20 Token standard
 * - Implements short address attack fix
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract IToken { 

    /** 
     * Get the total supply of tokens
     * 
     * @return The total supply
     */
    function totalSupply() external view returns (uint);


    /** 
     * Get balance of `_owner` 
     * 
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) external view returns (uint);


    /** 
     * Send `_value` token to `_to` from `msg.sender`
     * 
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) external returns (bool);


    /** 
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * 
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) external returns (bool);


    /** 
     * `msg.sender` approves `_spender` to spend `_value` tokens
     * 
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint _value) external returns (bool);


    /** 
     * Get the amount of remaining tokens that `_spender` is allowed to spend from `_owner`
     * 
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) external view returns (uint);
}


/**
 * @title ManagedToken interface
 *
 * Adds the following functionality to the basic ERC20 token
 * - Locking
 * - Issuing
 * - Burning 
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract IManagedToken is IToken { 

    /** 
     * Returns true if the token is locked
     * 
     * @return Whether the token is locked
     */
    function isLocked() external view returns (bool);


    /**
     * Locks the token so that the transfering of value is disabled 
     *
     * @return Whether the unlocking was successful or not
     */
    function lock() external returns (bool);


    /**
     * Unlocks the token so that the transfering of value is enabled 
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() external returns (bool);


    /**
     * Issues `_value` new tokens to `_to`
     *
     * @param _to The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the tokens where sucessfully issued or not
     */
    function issue(address _to, uint _value) external returns (bool);


    /**
     * Burns `_value` tokens of `_from`
     *
     * @param _from The address that owns the tokens to be burned
     * @param _value The amount of tokens to be burned
     * @return Whether the tokens where sucessfully burned or not 
     */
    function burn(address _from, uint _value) external returns (bool);
}


/**
 * @title Token observer interface
 *
 * Allows a token smart-contract to notify observers 
 * when tokens are received
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract ITokenObserver {


    /**
     * Called by the observed token smart-contract in order 
     * to notify the token observer when tokens are received
     *
     * @param _from The address that the tokens where send from
     * @param _value The amount of tokens that was received
     */
    function notifyTokensReceived(address _from, uint _value) external;
}


/**
 * @title Abstract token observer
 *
 * Allows observers to be notified by an observed token smart-contract
 * when tokens are received
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract TokenObserver is ITokenObserver {


    /**
     * Called by the observed token smart-contract in order 
     * to notify the token observer when tokens are received
     *
     * @param _from The address that the tokens where send from
     * @param _value The amount of tokens that was received
     */
    function notifyTokensReceived(address _from, uint _value) public {
        onTokensReceived(msg.sender, _from, _value);
    }


    /**
     * Event handler
     * 
     * Called by `_token` when a token amount is received
     *
     * @param _token The token contract that received the transaction
     * @param _from The account or contract that send the transaction
     * @param _value The value of tokens that where received
     */
    function onTokensReceived(address _token, address _from, uint _value) internal;
}


/**
 * @title Token retrieve interface
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 29/09/2017
 * #author Frank Bonnet
 */
contract ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) external;
}


/**
 * @title Token retrieve
 *
 * Allows tokens to be retrieved from a contract
 *
 * #created 18/10/2017
 * #author Frank Bonnet
 */
contract TokenRetriever is ITokenRetriever {

    /**
     * Extracts tokens from the contract
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public {
        IToken tokenInstance = IToken(_tokenContract);
        uint tokenBalance = tokenInstance.balanceOf(address(this));
        if (tokenBalance > 0) {
            tokenInstance.transfer(msg.sender, tokenBalance);
        }
    }
}


/**
 * @title Observable interface
 *
 * Allows observers to register and unregister with the 
 * implementing smart-contract that is observable
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract IObservable {


    /**
     * Returns true if `_account` is a registered observer
     * 
     * @param _account The account to test against
     * @return Whether the account is a registered observer
     */
    function isObserver(address _account) external view returns (bool);


    /**
     * Gets the amount of registered observers
     * 
     * @return The amount of registered observers
     */
    function getObserverCount() external view returns (uint);


    /**
     * Gets the observer at `_index`
     * 
     * @param _index The index of the observer
     * @return The observers address
     */
    function getObserverAtIndex(uint _index) external view returns (address);


    /**
     * Register `_observer` as an observer
     * 
     * @param _observer The account to add as an observer
     */
    function registerObserver(address _observer) external;


    /**
     * Unregister `_observer` as an observer
     * 
     * @param _observer The account to remove as an observer
     */
    function unregisterObserver(address _observer) external;
}


/**
 * @title Ownership interface
 *
 * Perminent ownership
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract IOwnership {

    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public view returns (bool);


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() public view returns (address);
}


/**
 * @title Ownership
 *
 * Perminent ownership
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract Ownership is IOwnership {

    // Owner
    address internal owner;


    /**
     * The publisher is the inital owner
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * Access is restricted to the current owner
     */
    modifier only_owner() {
        require(msg.sender == owner, "m:only_owner");
        _;
    }


    /**
     * Returns true if `_account` is the current owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public view returns (bool) {
        return _account == owner;
    }


    /**
     * Gets the current owner
     *
     * @return address The current owner
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}

/**
 * @title Transferable ownership interface
 *
 * Enhances ownership by allowing the current owner to 
 * transfer ownership to a new owner
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract ITransferableOwnership {
    

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner) external;
}


/**
 * @title Transferable ownership
 *
 * Enhances ownership by allowing the current owner to 
 * transfer ownership to a new owner
 *
 * #created 01/10/2017
 * #author Frank Bonnet
 */
contract TransferableOwnership is ITransferableOwnership, Ownership {


    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner 
     */
    function transferOwnership(address _newOwner) public only_owner {
        owner = _newOwner;
    }
}

/**
 * @title Multi-owned interface
 *
 * Interface that allows multiple owners
 *
 * #created 09/10/2017
 * #author Frank Bonnet
 */
contract IMultiOwned {

    /**
     * Returns true if `_account` is an owner
     *
     * @param _account The address to test against
     */
    function isOwner(address _account) public view returns (bool);


    /**
     * Returns the amount of owners
     *
     * @return The amount of owners
     */
    function getOwnerCount() public view returns (uint);


    /**
     * Gets the owner at `_index`
     *
     * @param _index The index of the owner
     * @return The address of the owner found at `_index`
     */
    function getOwnerAt(uint _index) public view returns (address);


     /**
     * Adds `_account` as a new owner
     *
     * @param _account The account to add as an owner
     */
    function addOwner(address _account) public;


    /**
     * Removes `_account` as an owner
     *
     * @param _account The account to remove as an owner
     */
    function removeOwner(address _account) public;
}

/**
 * @title IAuthenticator 
 *
 * Authenticator interface
 *
 * #created 15/10/2017
 * #author Frank Bonnet
 */
contract IAuthenticator {
    

    /**
     * Authenticate 
     *
     * Returns whether `_account` is authenticated or not
     *
     * @param _account The account to authenticate
     * @return whether `_account` is successfully authenticated
     */
    function authenticate(address _account) public view returns (bool);
}


/**
 * @title Dcorp Dissolvement Proposal
 *
 * Serves as a placeholder for the Dcorp funds, allowing the community the ability 
 * to claim their part of the ether. 
 *
 * This contact is deployed upon receiving the Ether that is currently held by the previous proxy contract.
 *
 * #created 18/7/2019
 * #author Frank Bonnet
 */
contract DcorpDissolvementProposal is TokenObserver, TransferableOwnership, TokenRetriever {

    enum Stages {
        Deploying,
        Deployed,
        Executed
    }

    struct Balance {
        uint drps;
        uint drpu;
        uint index;
    }

    // State
    Stages private stage;

    // Settings
    uint public constant CLAIMING_DURATION = 60 days;
    uint public constant WITHDRAW_DURATION = 60 days;
    uint public constant DISSOLVEMENT_AMOUNT = 1888 ether; // +- 355000 euro

    // Alocated balances
    mapping (address => Balance) private allocated;
    address[] private allocatedIndex;

    // Whitelist
    IAuthenticator public authenticator;

    // Tokens
    IToken public drpsToken;
    IToken public drpuToken;

    // Previous proxy
    address public prevProxy;
    uint public prevProxyRecordedBalance;

    // Dissolvement
    address payable public dissolvementFund;

    uint public claimTotalWeight;
    uint public claimTotalEther;
    uint public claimDeadline;
    uint public withdrawDeadline;
    

    /**
     * Require that the sender is authentcated
     */
    modifier only_authenticated() {
        require(authenticator.authenticate(msg.sender), "m:only_authenticated");
        _;
    }


    /**
     * Require that the contract is in `_stage` 
     */
    modifier only_at_stage(Stages _stage) {
        require(stage == _stage, "m:only_at_stage");
        _;
    }


    /**
     * Require `_token` to be one of the drp tokens
     *
     * @param _token The address to test against
     */
    modifier only_accepted_token(address _token) {
        require(_token == address(drpsToken) || _token == address(drpuToken), "m:only_accepted_token");
        _;
    }


    /**
     * Require that `_token` is not one of the drp tokens
     *
     * @param _token The address to test against
     */
    modifier not_accepted_token(address _token) {
        require(_token != address(drpsToken) && _token != address(drpuToken), "m:not_accepted_token");
        _;
    }


    /**
     * Require that sender has more than zero tokens 
     */
    modifier only_token_holder() {
        require(allocated[msg.sender].drps > 0 || allocated[msg.sender].drpu > 0, "m:only_token_holder");
        _;
    }


    /**
     * Require that the claiming period for the proposal has
     * not yet ended
     */
    modifier only_during_claiming_period() {
        require(claimDeadline > 0 && now <= claimDeadline, "m:only_during_claiming_period");
        _;
    }


    /**
     * Require that the claiming period for the proposal has ended
     */
    modifier only_after_claiming_period() {
        require(claimDeadline > 0 && now > claimDeadline, "m:only_after_claiming_period");
        _;
    }


    /**
     * Require that the withdraw period for the proposal has
     * not yet ended
     */
    modifier only_during_withdraw_period() {
        require(withdrawDeadline > 0 && now <= withdrawDeadline, "m:only_during_withdraw_period");
        _;
    }


    /**
     * Require that the withdraw period for the proposal has ended
     */
    modifier only_after_withdraw_period() {
        require(withdrawDeadline > 0 && now > withdrawDeadline, "m:only_after_withdraw_period");
        _;
    }
    

    /**
     * Construct the proxy
     *
     * @param _authenticator Whitelist
     * @param _drpsToken The new security token
     * @param _drpuToken The new utility token
     * @param _prevProxy Proxy accepts and requires ether from the prev proxy
     * @param _dissolvementFund Ether to be used for the dissolvement of DCORP
     */
    constructor(address _authenticator, address _drpsToken, address _drpuToken, address _prevProxy, address payable _dissolvementFund) public {
        authenticator = IAuthenticator(_authenticator);
        drpsToken = IToken(_drpsToken);
        drpuToken = IToken(_drpuToken);
        prevProxy = _prevProxy;
        prevProxyRecordedBalance = _prevProxy.balance;
        dissolvementFund = _dissolvementFund;
        stage = Stages.Deploying;
    }


    /**
     * Returns whether the proposal is being deployed
     *
     * @return Whether the proposal is in the deploying stage
     */
    function isDeploying() public view returns (bool) {
        return stage == Stages.Deploying;
    }


    /**
     * Returns whether the proposal is deployed. The proposal is deployed 
     * when it receives Ether from the prev proxy contract
     *
     * @return Whether the proposal is deployed
     */
    function isDeployed() public view returns (bool) {
        return stage == Stages.Deployed;
    }


    /**
     * Returns whether the proposal is executed
     *
     * @return Whether the proposal is deployed
     */
    function isExecuted() public view returns (bool) {
        return stage == Stages.Executed;
    }


    /**
     * Accept eth from the prev proxy while deploying
     */
    function () external payable only_at_stage(Stages.Deploying) {
        require(msg.sender == address(prevProxy), "f:fallback;e:invalid_sender");
    }


    /**
     * Deploy the proposal
     */
    function deploy() public only_owner only_at_stage(Stages.Deploying) {
        require(address(this).balance >= prevProxyRecordedBalance, "f:deploy;e:invalid_balance");

        // Mark deployed
        stage = Stages.Deployed;
        
        // Start claiming period
        claimDeadline = now + CLAIMING_DURATION;

        // Remove prev proxy as observer
        IObservable(address(drpsToken)).unregisterObserver(prevProxy);
        IObservable(address(drpuToken)).unregisterObserver(prevProxy);

        // Register this proxy as observer
        IObservable(address(drpsToken)).registerObserver(address(this));
        IObservable(address(drpuToken)).registerObserver(address(this));

        // Transfer dissolvement funds
        uint amountToTransfer = DISSOLVEMENT_AMOUNT;
        if (amountToTransfer > address(this).balance) {
            amountToTransfer = address(this).balance;
        }

        dissolvementFund.transfer(amountToTransfer);
    }


    /**
     * Returns the combined total supply of all drp tokens
     *
     * @return The combined total drp supply
     */
    function getTotalSupply() public view returns (uint) {
        uint sum = 0; 
        sum += drpsToken.totalSupply();
        sum += drpuToken.totalSupply();
        return sum;
    }


    /**
     * Returns true if `_owner` has a balance allocated
     *
     * @param _owner The account that the balance is allocated for
     * @return True if there is a balance that belongs to `_owner`
     */
    function hasBalance(address _owner) public view returns (bool) {
        return allocatedIndex.length > 0 && _owner == allocatedIndex[allocated[_owner].index];
    }


    /** 
     * Get the allocated drps or drpu token balance of `_owner`
     * 
     * @param _token The address to test against
     * @param _owner The address from which the allocated token balance will be retrieved
     * @return The allocated drps token balance
     */
    function balanceOf(address _token, address _owner) public view returns (uint) {
        uint balance = 0;
        if (address(drpsToken) == _token) {
            balance = allocated[_owner].drps;
        } 
        
        else if (address(drpuToken) == _token) {
            balance = allocated[_owner].drpu;
        }

        return balance;
    }


    /**
     * Executes the proposal
     *
     * Dissolves DCORP Decentralized and allows the ether to be withdrawn
     *
     * Should only be called after the claiming period
     */
    function execute() public only_at_stage(Stages.Deployed) only_after_claiming_period {
        
        // Mark as executed
        stage = Stages.Executed;
        withdrawDeadline = now + WITHDRAW_DURATION;

        // Remaining balance is claimable
        claimTotalEther = address(this).balance;

        // Disable tokens
        IManagedToken(address(drpsToken)).lock();
        IManagedToken(address(drpuToken)).lock();

        // Remove self token as owner
        IMultiOwned(address(drpsToken)).removeOwner(address(this));
        IMultiOwned(address(drpuToken)).removeOwner(address(this));
    }


    /**
     * Allows an account to claim ether during the claiming period
     */
    function withdraw() public only_at_stage(Stages.Executed) only_during_withdraw_period only_token_holder only_authenticated {
        Balance storage b = allocated[msg.sender];
        uint weight = b.drpu + _convertDrpsWeight(b.drps);

        // Mark claimed
        b.drpu = 0;
        b.drps = 0;

        // Transfer amount
        uint amountToTransfer = weight * claimTotalEther / claimTotalWeight;
        msg.sender.transfer(amountToTransfer);
    }


    /**
     * Event handler that initializes the token conversion
     * 
     * Called by `_token` when a token amount is received on 
     * the address of this token changer
     *
     * @param _token The token contract that received the transaction
     * @param _from The account or contract that send the transaction
     * @param _value The value of tokens that where received
     */
    function onTokensReceived(address _token, address _from, uint _value) internal only_during_claiming_period only_accepted_token(_token) {
        require(_token == msg.sender, "f:onTokensReceived;e:only_receiving_token");

        // Allocate tokens
        if (!hasBalance(_from)) {
            allocated[_from] = Balance(
                0, 0, allocatedIndex.push(_from) - 1);
        }

        Balance storage b = allocated[_from];
        if (_token == address(drpsToken)) {
            b.drps += _value;
            claimTotalWeight += _convertDrpsWeight(_value);
        } else {
            b.drpu += _value;
            claimTotalWeight += _value;
        }
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve ether from the contract that was not claimed 
     * within the claiming period.
     */
    function retrieveEther() public only_owner only_after_withdraw_period {
        selfdestruct(msg.sender);
    }


    /**
     * Failsafe mechanism
     * 
     * Allows the owner to retrieve tokens (other than DRPS and DRPU tokens) from the contract that 
     * might have been send there by accident
     *
     * @param _tokenContract The address of ERC20 compatible token
     */
    function retrieveTokens(address _tokenContract) public only_owner not_accepted_token(_tokenContract) {
        super.retrieveTokens(_tokenContract);
    }


    /**
     * Converts the weight for DRPS tokens
     * 
     * @param _value The amount of tokens to convert
     */
    function _convertDrpsWeight(uint _value) private pure returns (uint) {
        return _value * 2;
    }
}