/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.11;


/**
 * Safe unsigned safe math.
 *
 * https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736#.750gwtwli
 *
 * Originally from https://raw.githubusercontent.com/AragonOne/zeppelin-solidity/master/contracts/SafeMathLib.sol
 *
 * Maintained here until merged to mainline zeppelin-solidity.
 *
 */
library SMathLib {

    function times(uint a, uint b) returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function divides(uint a, uint b) returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function minus(uint a, uint b) returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function plus(uint a, uint b) returns (uint) {
        uint c = a + b;
        assert(c>=a);
        return c;
    }

}



/**
 * Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }

}
/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */


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


// Created using ICO Wizard https://github.com/oraclesorg/ico-wizard by Oracles Network

/*
 * Haltable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.
 *
 *
 * Originally envisioned in FirstBlood ICO contract.
 */
contract Haltable is Ownable {
    bool public halted;

    modifier stopInEmergency {
        if (halted) throw;
        _;
    }

    modifier stopNonOwnersInEmergency {
        if (halted && msg.sender != owner) throw;
        _;
    }

    modifier onlyInEmergency {
        if (!halted) throw;
        _;
    }

    // called by the owner on emergency, triggers stopped state
    function halt() external onlyOwner {
        halted = true;
    }

    // called by the owner on end of emergency, returns to normal state
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
    }

}


/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * Standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
 *
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath {

    /* Token supply got increased and a new owner received these tokens */
    event Minted(address receiver, uint amount);

    /* Actual balances of token holders */
    mapping(address => uint) balances;

    /* approve() allowances */
    mapping (address => mapping (address => uint)) allowed;

    /* Interface declaration */
    function isToken() public constant returns (bool weAre) {
        return true;
    }

    function transfer(address _to, uint _value) returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        uint _allowance = allowed[_from][msg.sender];

        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(_allowance, _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) returns (bool success) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require ((_value != 0) && (allowed[msg.sender][_spender] != 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */





/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */



/**
 * Upgrade agent interface inspired by Lunyr.
 *
 * Upgrade agent transfers tokens to a new contract.
 * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
 */
contract UpgradeAgent {

    uint public originalSupply;

    /** Interface marker */
    function isUpgradeAgent() public constant returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public;

}


/**
 * A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 */
contract UpgradeableToken is StandardToken {

    /** Contract / person who can set the upgrade path. This can be the same as team multisig wallet, as what it is with its default value. */
    address public upgradeMaster;

    /** The next contract where the tokens will be migrated. */
    UpgradeAgent public upgradeAgent;

    /** How many tokens we have upgraded by now. */
    uint256 public totalUpgraded;

    /**
     * Upgrade states.
     *
     * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
     * - WaitingForAgent: Token allows upgrade, but we don&#39;t have a new agent yet
     * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
     * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
     *
     */
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    /**
     * Somebody has upgraded some of his tokens.
     */
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

    /**
     * New upgrade agent available.
     */
    event UpgradeAgentSet(address agent);

    /**
     * Do not allow construction without upgrade master set.
     */
    function UpgradeableToken(address _upgradeMaster) {
        upgradeMaster = _upgradeMaster;
    }

    /**
     * Allow the token holder to upgrade some of their tokens to a new contract.
     */
    function upgrade(uint256 value) public {

        UpgradeState state = getUpgradeState();
        require(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading));

        // Validate input value.
        require (value == 0);

        balances[msg.sender] = safeSub(balances[msg.sender], value);

        // Take tokens out from circulation
        totalSupply = safeSub(totalSupply, value);
        totalUpgraded = safeAdd(totalUpgraded, value);

        // Upgrade agent reissues the tokens
        upgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, upgradeAgent, value);
    }

    /**
     * Set an upgrade agent that handles
     */
    function setUpgradeAgent(address agent) external {

        require(!canUpgrade()); // The token is not yet in a state that we could think upgrading;

        require(agent == 0x0);
        // Only a master can designate the next agent
        require(msg.sender != upgradeMaster);
        // Upgrade has already begun for an agent
        require(getUpgradeState() == UpgradeState.Upgrading);

        upgradeAgent = UpgradeAgent(agent);

        // Bad interface
        require(!upgradeAgent.isUpgradeAgent());
        // Make sure that token supplies match in source and target
        require(upgradeAgent.originalSupply() != totalSupply);

        UpgradeAgentSet(upgradeAgent);
    }

    /**
     * Get the state of the token upgrade.
     */
    function getUpgradeState() public constant returns(UpgradeState) {
        if(!canUpgrade()) return UpgradeState.NotAllowed;
        else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
        else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else return UpgradeState.Upgrading;
    }

    /**
     * Change the upgrade master.
     *
     * This allows us to set a new owner for the upgrade mechanism.
     */
    function setUpgradeMaster(address master) public {
        require(master == 0x0);
        require(msg.sender != upgradeMaster);
        upgradeMaster = master;
    }

    /**
     * Child contract can enable to provide the condition when the upgrade can begun.
     */
    function canUpgrade() public constant returns(bool) {
        return true;
    }

}

/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */




/**
 * A token that can increase its supply by another contract.
 *
 * This allows uncapped crowdsale by dynamically increasing the supply when money pours in.
 * Only mint agents, contracts whitelisted by owner, can mint new tokens.
 *
 */
contract MintableTokenExt is StandardToken, Ownable {

    using SMathLib for uint;

    bool public mintingFinished = false;

    /** List of agents that are allowed to create new tokens */
    mapping (address => bool) public mintAgents;

    event MintingAgentChanged(address addr, bool state  );

    /** inPercentageUnit is percents of tokens multiplied to 10 up to percents decimals.
    * For example, for reserved tokens in percents 2.54%
    * inPercentageUnit = 254
    * inPercentageDecimals = 2
    */
    struct ReservedTokensData {
        uint inTokens;
        uint inPercentageUnit;
        uint inPercentageDecimals;
    }

    mapping (address => ReservedTokensData) public reservedTokensList;
    address[] public reservedTokensDestinations;
    uint public reservedTokensDestinationsLen = 0;

    function setReservedTokensList(address addr, uint inTokens, uint inPercentageUnit, uint inPercentageDecimals) onlyOwner {
        reservedTokensDestinations.push(addr);
        reservedTokensDestinationsLen++;
        reservedTokensList[addr] = ReservedTokensData({inTokens:inTokens, inPercentageUnit:inPercentageUnit, inPercentageDecimals: inPercentageDecimals});
    }

    function getReservedTokensListValInTokens(address addr) constant returns (uint inTokens) {
        return reservedTokensList[addr].inTokens;
    }

    function getReservedTokensListValInPercentageUnit(address addr) constant returns (uint inPercentageUnit) {
        return reservedTokensList[addr].inPercentageUnit;
    }

    function getReservedTokensListValInPercentageDecimals(address addr) constant returns (uint inPercentageDecimals) {
        return reservedTokensList[addr].inPercentageDecimals;
    }

    function setReservedTokensListMultiple(address[] addrs, uint[] inTokens, uint[] inPercentageUnit, uint[] inPercentageDecimals) onlyOwner {
        for (uint iterator = 0; iterator < addrs.length; iterator++) {
            setReservedTokensList(addrs[iterator], inTokens[iterator], inPercentageUnit[iterator], inPercentageDecimals[iterator]);
        }
    }

    /**
     * Create new tokens and allocate them to an address..
     *
     * Only callably by a crowdsale contract (mint agent).
     */
    function mint(address receiver, uint amount) onlyMintAgent canMint public {
        totalSupply = totalSupply.plus(amount);
        balances[receiver] = balances[receiver].plus(amount);

        // This will make the mint transaction apper in EtherScan.io
        // We can remove this after there is a standardized minting event
        Transfer(0, receiver, amount);
    }

    /**
     * Owner can allow a crowdsale contract to mint new tokens.
     */
    function setMintAgent(address addr, bool state) onlyOwner canMint public {
        mintAgents[addr] = state;
        MintingAgentChanged(addr, state);
    }

    modifier onlyMintAgent() {
        // Only crowdsale contracts are allowed to mint new tokens
        if(!mintAgents[msg.sender]) {
            revert();
        }
        _;
    }

    /** Make sure we are not done yet. */
    modifier canMint() {
        if(mintingFinished) {
            revert();
        }
        _;
    }
}
/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */



/**
 * Define interface for releasing the token transfer after a successful crowdsale.
 */
contract ReleasableToken is ERC20, Ownable {

    /* The finalizer contract that allows unlift the transfer limits on this token */
    address public releaseAgent;

    /** A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.*/
    bool public released = false;

    /** Map of agents that are allowed to transfer tokens regardless of the lock down period. These are crowdsale contracts and possible the team multisig itself. */
    mapping (address => bool) public transferAgents;

    /**
     * Limit token transfer until the crowdsale is over.
     *
     */
    modifier canTransfer(address _sender) {

        if(!released) {
            if(!transferAgents[_sender]) {
                revert();
            }
        }

        _;
    }

    /**
     * Set the contract that can call release and make the token transferable.
     *
     * Design choice. Allow reset the release agent to fix fat finger mistakes.
     */
    function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {

        // We don&#39;t do interface check here as we might want to a normal wallet address to act as a release agent
        releaseAgent = addr;
    }

    /**
     * Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
     */
    function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
        transferAgents[addr] = state;
    }

    /**
     * One way function to release the tokens to the wild.
     *
     * Can be called only from the release agent that is the final ICO contract. It is only called if the crowdsale has been success (first milestone reached).
     */
    function releaseTokenTransfer() public onlyReleaseAgent {
        released = true;
    }

    /** The function can be called only before or after the tokens have been releasesd */
    modifier inReleaseState(bool releaseState) {
        if(releaseState != released) {
            revert();
        }
        _;
    }

    /** The function can be called only by a whitelisted release agent. */
    modifier onlyReleaseAgent() {
        if(msg.sender != releaseAgent) {
            revert();
        }
        _;
    }

    function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
        // Call StandardToken.transfer()
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
        // Call StandardToken.transferForm()
        return super.transferFrom(_from, _to, _value);
    }

}

/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */






contract BurnableToken is StandardToken {

    using SMathLib for uint;
    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender&#39;s balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].minus(_value);
        totalSupply = totalSupply.minus(_value);
        Burn(burner, _value);
    }
}




/**
 * A crowdsaled token.
 *
 * An ERC-20 token designed specifically for crowdsales with investor protection and further development path.
 *
 * - The token transfer() is disabled until the crowdsale is over
 * - The token contract gives an opt-in upgrade path to a new contract
 * - The same token can be part of several crowdsales through approve() mechanism
 * - The token can be capped (supply set in the constructor) or uncapped (crowdsale contract can mint new tokens)
 *
 */
contract CrowdsaleTokenExt is ReleasableToken, MintableTokenExt, BurnableToken, UpgradeableToken {

    /** Name and symbol were updated. */
    event UpdatedTokenInformation(string newName, string newSymbol);

    string public name;

    string public symbol;

    uint public decimals;

    /* Minimum ammount of tokens every buyer can buy. */
    uint public minCap;


    /**
     * Construct the token.
     *
     * This token must be created through a team multisig wallet, so that it is owned by that wallet.
     *
     * @param _name Token name
     * @param _symbol Token symbol - should be all caps
     * @param _initialSupply How many tokens we start with
     * @param _decimals Number of decimal places
     * @param _mintable Are new tokens created over the crowdsale or do we distribute only the initial supply? Note that when the token becomes transferable the minting always ends.
     */
    function CrowdsaleTokenExt(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable, uint _globalMinCap)
    UpgradeableToken(msg.sender) {

        // Create any address, can be transferred
        // to team multisig via changeOwner(),
        // also remember to call setUpgradeMaster()
        owner = msg.sender;

        name = _name;
        symbol = _symbol;

        totalSupply = _initialSupply;

        decimals = _decimals;

        minCap = _globalMinCap;

        // Create initially all balance on the team multisig
        balances[owner] = totalSupply;

        if(totalSupply > 0) {
            Minted(owner, totalSupply);
        }

        // No more new supply allowed after the token creation
        if(!_mintable) {
            mintingFinished = true;
            if(totalSupply == 0) {
                revert(); // Cannot create a token without supply and no minting
            }
        }
    }

    /**
     * When token is released to be transferable, enforce no new tokens can be created.
     */
    function releaseTokenTransfer() public onlyReleaseAgent {
        super.releaseTokenTransfer();
    }

    /**
     * Allow upgrade agent functionality kick in only if the crowdsale was success.
     */
    function canUpgrade() public constant returns(bool) {
        return released && super.canUpgrade();
    }

    /**
     * Owner can update token information here.
     *
     * It is often useful to conceal the actual token association, until
     * the token operations, like central issuance or reissuance have been completed.
     *
     * This function allows the token owner to rename the token after the operations
     * have been completed and then point the audience to use the token contract.
     */
    function setTokenInformation(string _name, string _symbol) onlyOwner {
        name = _name;
        symbol = _symbol;

        UpdatedTokenInformation(name, symbol);
    }

}


contract MjtToken is CrowdsaleTokenExt {

    uint public ownersProductCommissionInPerc = 5;

    uint public operatorProductCommissionInPerc = 25;

    event IndependentSellerJoined(address sellerWallet, uint amountOfTokens, address operatorWallet);
    event OwnersProductAdded(address ownersWallet, uint amountOfTokens, address operatorWallet);
    event OperatorProductCommissionChanged(uint _value);
    event OwnersProductCommissionChanged(uint _value);


    function setOperatorCommission(uint _value) public onlyOwner {
        require(_value >= 0);
        operatorProductCommissionInPerc = _value;
        OperatorProductCommissionChanged(_value);
    }

    function setOwnersCommission(uint _value) public onlyOwner {
        require(_value >= 0);
        ownersProductCommissionInPerc = _value;
        OwnersProductCommissionChanged(_value);
    }


    /**
     * Method called when new seller joined the program
     * To avoid value lost after division, amountOfTokens must be multiple of 100
     */
    function independentSellerJoined(address sellerWallet, uint amountOfTokens, address operatorWallet) public onlyOwner canMint {
        require(amountOfTokens > 100);
        require(sellerWallet != address(0));
        require(operatorWallet != address(0));

        uint operatorCommission = amountOfTokens.divides(100).times(operatorProductCommissionInPerc);
        uint sellerAmount = amountOfTokens.minus(operatorCommission);

        if (operatorCommission > 0) {
            mint(operatorWallet, operatorCommission);
        }

        if (sellerAmount > 0) {
            mint(sellerWallet, sellerAmount);
        }
        IndependentSellerJoined(sellerWallet, amountOfTokens, operatorWallet);
    }


    /**
    * Method called when owners add their own product
    * To avoid value lost after division, amountOfTokens must be multiple of 100
    */
    function ownersProductAdded(address ownersWallet, uint amountOfTokens, address operatorWallet) public onlyOwner canMint {
        require(amountOfTokens > 100);
        require(ownersWallet != address(0));
        require(operatorWallet != address(0));

        uint ownersComission = amountOfTokens.divides(100).times(ownersProductCommissionInPerc);
        uint operatorAmount = amountOfTokens.minus(ownersComission);


        if (ownersComission > 0) {
            mint(ownersWallet, ownersComission);
        }

        if (operatorAmount > 0) {
            mint(operatorWallet, operatorAmount);
        }

        OwnersProductAdded(ownersWallet, amountOfTokens, operatorWallet);
    }

    function MjtToken(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable, uint _globalMinCap)
    CrowdsaleTokenExt(_name, _symbol, _initialSupply, _decimals, _mintable, _globalMinCap) {}

}


/**
 *
 * Time-locked token vault of allocated founder tokens.
 *
 * First used by Lunyr https://github.com/Lunyr/crowdsale-contracts
 *
 *
 * See TokenVault for multi user implementation.
 */
contract TimeVault {

    /** Interface flag to determine if address is for a real contract or not */
    bool public isTimeVault = true;

    /** Token we are holding */
    StandardToken public token;

    /** Address that can claim tokens */
    address public teamMultisig;

    /** UNIX timestamp when tokens can be claimed. */
    uint256 public unlockedAt;

    event Unlocked();

    function TimeVault(address _teamMultisig, StandardToken _token, uint _unlockedAt) {

        teamMultisig = _teamMultisig;
        token = _token;
        unlockedAt = _unlockedAt;

        // Sanity check
        if (teamMultisig == 0x0) throw;
        if (address(token) == 0x0) throw;
    }

    function getTokenBalance() public constant returns (uint) {
        return token.balanceOf(address(this));
    }

    function unlock() public {
        // Wait your turn!
        if (now < unlockedAt) throw;

        // StandardToken will throw in the case of transaction fails
        token.transfer(teamMultisig, getTokenBalance());

        Unlocked();
    }

    // disallow ETH payment for this vault
    function () { throw; }

}