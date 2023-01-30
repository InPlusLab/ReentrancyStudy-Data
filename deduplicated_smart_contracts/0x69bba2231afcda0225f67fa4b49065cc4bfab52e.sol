/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.2;


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: set-protocol-contracts/contracts/core/interfaces/ICore.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title ICore
 * @author Set Protocol
 *
 * The ICore Contract defines all the functions exposed in the Core through its
 * various extensions and is a light weight way to interact with the contract.
 */
interface ICore {
    /**
     * Return transferProxy address.
     *
     * @return address       transferProxy address
     */
    function transferProxy()
        external
        view
        returns (address);

    /**
     * Return vault address.
     *
     * @return address       vault address
     */
    function vault()
        external
        view
        returns (address);

    /**
     * Return address belonging to given exchangeId.
     *
     * @param  _exchangeId       ExchangeId number
     * @return address           Address belonging to given exchangeId
     */
    function exchangeIds(
        uint8 _exchangeId
    )
        external
        view
        returns (address);

    /*
     * Returns if valid set
     *
     * @return  bool      Returns true if Set created through Core and isn't disabled
     */
    function validSets(address)
        external
        view
        returns (bool);

    /*
     * Returns if valid module
     *
     * @return  bool      Returns true if valid module
     */
    function validModules(address)
        external
        view
        returns (bool);

    /**
     * Return boolean indicating if address is a valid Rebalancing Price Library.
     *
     * @param  _priceLibrary    Price library address
     * @return bool             Boolean indicating if valid Price Library
     */
    function validPriceLibraries(
        address _priceLibrary
    )
        external
        view
        returns (bool);

    /**
     * Exchanges components for Set Tokens
     *
     * @param  _set          Address of set to issue
     * @param  _quantity     Quantity of set to issue
     */
    function issue(
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Issues a specified Set for a specified quantity to the recipient
     * using the caller's components from the wallet and vault.
     *
     * @param  _recipient    Address to issue to
     * @param  _set          Address of the Set to issue
     * @param  _quantity     Number of tokens to issue
     */
    function issueTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Converts user's components into Set Tokens held directly in Vault instead of user's account
     *
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to redeem
     */
    function issueInVault(
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Function to convert Set Tokens into underlying components
     *
     * @param _set          The address of the Set token
     * @param _quantity     The number of tokens to redeem. Should be multiple of natural unit.
     */
    function redeem(
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Redeem Set token and return components to specified recipient. The components
     * are left in the vault
     *
     * @param _recipient    Recipient of Set being issued
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to redeem
     */
    function redeemTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Function to convert Set Tokens held in vault into underlying components
     *
     * @param _set          The address of the Set token
     * @param _quantity     The number of tokens to redeem. Should be multiple of natural unit.
     */
    function redeemInVault(
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Composite method to redeem and withdraw with a single transaction
     *
     * Normally, you should expect to be able to withdraw all of the tokens.
     * However, some have central abilities to freeze transfers (e.g. EOS). _toExclude
     * allows you to optionally specify which component tokens to exclude when
     * redeeming. They will remain in the vault under the users' addresses.
     *
     * @param _set          Address of the Set
     * @param _to           Address to withdraw or attribute tokens to
     * @param _quantity     Number of tokens to redeem
     * @param _toExclude    Mask of indexes of tokens to exclude from withdrawing
     */
    function redeemAndWithdrawTo(
        address _set,
        address _to,
        uint256 _quantity,
        uint256 _toExclude
    )
        external;

    /**
     * Deposit multiple tokens to the vault. Quantities should be in the
     * order of the addresses of the tokens being deposited.
     *
     * @param  _tokens           Array of the addresses of the ERC20 tokens
     * @param  _quantities       Array of the number of tokens to deposit
     */
    function batchDeposit(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

    /**
     * Withdraw multiple tokens from the vault. Quantities should be in the
     * order of the addresses of the tokens being withdrawn.
     *
     * @param  _tokens            Array of the addresses of the ERC20 tokens
     * @param  _quantities        Array of the number of tokens to withdraw
     */
    function batchWithdraw(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

    /**
     * Deposit any quantity of tokens into the vault.
     *
     * @param  _token           The address of the ERC20 token
     * @param  _quantity        The number of tokens to deposit
     */
    function deposit(
        address _token,
        uint256 _quantity
    )
        external;

    /**
     * Withdraw a quantity of tokens from the vault.
     *
     * @param  _token           The address of the ERC20 token
     * @param  _quantity        The number of tokens to withdraw
     */
    function withdraw(
        address _token,
        uint256 _quantity
    )
        external;

    /**
     * Transfer tokens associated with the sender's account in vault to another user's
     * account in vault.
     *
     * @param  _token           Address of token being transferred
     * @param  _to              Address of user receiving tokens
     * @param  _quantity        Amount of tokens being transferred
     */
    function internalTransfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;

    /**
     * Deploys a new Set Token and adds it to the valid list of SetTokens
     *
     * @param  _factory              The address of the Factory to create from
     * @param  _components           The address of component tokens
     * @param  _units                The units of each component token
     * @param  _naturalUnit          The minimum unit to be issued or redeemed
     * @param  _name                 The bytes32 encoded name of the new Set
     * @param  _symbol               The bytes32 encoded symbol of the new Set
     * @param  _callData             Byte string containing additional call parameters
     * @return setTokenAddress       The address of the new Set
     */
    function createSet(
        address _factory,
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address);

    /**
     * Exposes internal function that deposits a quantity of tokens to the vault and attributes
     * the tokens respectively, to system modules.
     *
     * @param  _from            Address to transfer tokens from
     * @param  _to              Address to credit for deposit
     * @param  _token           Address of token being deposited
     * @param  _quantity        Amount of tokens to deposit
     */
    function depositModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;

    /**
     * Exposes internal function that withdraws a quantity of tokens from the vault and
     * deattributes the tokens respectively, to system modules.
     *
     * @param  _from            Address to decredit for withdraw
     * @param  _to              Address to transfer tokens to
     * @param  _token           Address of token being withdrawn
     * @param  _quantity        Amount of tokens to withdraw
     */
    function withdrawModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;

    /**
     * Exposes internal function that deposits multiple tokens to the vault, to system
     * modules. Quantities should be in the order of the addresses of the tokens being
     * deposited.
     *
     * @param  _from              Address to transfer tokens from
     * @param  _to                Address to credit for deposits
     * @param  _tokens            Array of the addresses of the tokens being deposited
     * @param  _quantities        Array of the amounts of tokens to deposit
     */
    function batchDepositModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

    /**
     * Exposes internal function that withdraws multiple tokens from the vault, to system
     * modules. Quantities should be in the order of the addresses of the tokens being withdrawn.
     *
     * @param  _from              Address to decredit for withdrawals
     * @param  _to                Address to transfer tokens to
     * @param  _tokens            Array of the addresses of the tokens being withdrawn
     * @param  _quantities        Array of the amounts of tokens to withdraw
     */
    function batchWithdrawModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;

    /**
     * Expose internal function that exchanges components for Set tokens,
     * accepting any owner, to system modules
     *
     * @param  _owner        Address to use tokens from
     * @param  _recipient    Address to issue Set to
     * @param  _set          Address of the Set to issue
     * @param  _quantity     Number of tokens to issue
     */
    function issueModule(
        address _owner,
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Expose internal function that exchanges Set tokens for components,
     * accepting any owner, to system modules
     *
     * @param  _burnAddress         Address to burn token from
     * @param  _incrementAddress    Address to increment component tokens to
     * @param  _set                 Address of the Set to redeem
     * @param  _quantity            Number of tokens to redeem
     */
    function redeemModule(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        external;

    /**
     * Expose vault function that increments user's balance in the vault.
     * Available to system modules
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchIncrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

    /**
     * Expose vault function that decrement user's balance in the vault
     * Only available to system modules.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchDecrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

    /**
     * Expose vault function that transfer vault balances between users
     * Only available to system modules.
     *
     * @param  _tokens           Addresses of tokens being transferred
     * @param  _from             Address tokens being transferred from
     * @param  _to               Address tokens being transferred to
     * @param  _quantities       Amounts of tokens being transferred
     */
    function batchTransferBalanceModule(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;

    /**
     * Transfers token from one address to another using the transfer proxy.
     * Only available to system modules.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _quantity       The number of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function transferModule(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;

    /**
     * Expose transfer proxy function to transfer tokens from one address to another
     * Only available to system modules.
     *
     * @param  _tokens         The addresses of the ERC20 token
     * @param  _quantities     The numbers of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function batchTransferModule(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;
}

// File: set-protocol-contracts/contracts/core/lib/RebalancingLibraryV2.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;
pragma experimental "ABIEncoderV2";



/**
 * @title RebalancingLibrary
 * @author Set Protocol
 *
 * The RebalancingLibrary contains functions for facilitating the rebalancing process for
 * Rebalancing Set Tokens. Removes the old calculation functions
 *
 */
library RebalancingLibraryV2 {
    using SafeMath for uint256;

    /* ============ Enums ============ */

    enum State { Default, Proposal, Rebalance, Drawdown }

    /* ============ Structs ============ */

    struct AuctionPriceParameters {
        uint256 auctionStartTime;
        uint256 auctionTimeToPivot;
        uint256 auctionStartPrice;
        uint256 auctionPivotPrice;
    }

    struct BiddingParameters {
        uint256 minimumBid;
        uint256 remainingCurrentSets;
        uint256[] combinedCurrentUnits;
        uint256[] combinedNextSetUnits;
        address[] combinedTokenArray;
    }
}

// File: set-protocol-contracts/contracts/core/interfaces/IRebalancingSetTokenV2.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title IRebalancingSetTokenV2
 * @author Set Protocol
 *
 * The IRebalancingSetToken interface provides a light-weight, structured way to interact with the
 * RebalancingSetToken contract from another contract.
 */

interface IRebalancingSetTokenV2 {

    /*
     * Get totalSupply of Rebalancing Set
     *
     * @return  totalSupply
     */
    function totalSupply()
        external
        view
        returns (uint256);

    /*
     * Get lastRebalanceTimestamp of Rebalancing Set
     *
     * @return  lastRebalanceTimestamp
     */
    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);

    /*
     * Get rebalanceInterval of Rebalancing Set
     *
     * @return  rebalanceInterval
     */
    function rebalanceInterval()
        external
        view
        returns (uint256);

    /*
     * Get rebalanceState of Rebalancing Set
     *
     * @return  rebalanceState
     */
    function rebalanceState()
        external
        view
        returns (RebalancingLibraryV2.State);

    /**
     * Gets the balance of the specified address.
     *
     * @param owner      The address to query the balance of.
     * @return           A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);

    /**
     * Function used to set the terms of the next rebalance and start the proposal period
     *
     * @param _nextSet                      The Set to rebalance into
     * @param _auctionLibrary               The library used to calculate the Dutch Auction price
     * @param _auctionTimeToPivot           The amount of time for the auction to go ffrom start to pivot price
     * @param _auctionStartPrice            The price to start the auction at
     * @param _auctionPivotPrice            The price at which the price curve switches from linear to exponential
     */
    function propose(
        address _nextSet,
        address _auctionLibrary,
        uint256 _auctionTimeToPivot,
        uint256 _auctionStartPrice,
        uint256 _auctionPivotPrice
    )
        external;

    /*
     * Get natural unit of Set
     *
     * @return  uint256       Natural unit of Set
     */
    function naturalUnit()
        external
        view
        returns (uint256);

    /**
     * Returns the address of the current Base Set
     *
     * @return           A address representing the base Set Token
     */
    function currentSet()
        external
        view
        returns (address);

    /*
     * Get the unit shares of the rebalancing Set
     *
     * @return  unitShares       Unit Shares of the base Set
     */
    function unitShares()
        external
        view
        returns (uint256);

    /*
     * Burn set token for given address.
     * Can only be called by authorized contracts.
     *
     * @param  _from        The address of the redeeming account
     * @param  _quantity    The number of sets to burn from redeemer
     */
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

    /*
     * Place bid during rebalance auction. Can only be called by Core.
     *
     * @param _quantity                 The amount of currentSet to be rebalanced
     * @return combinedTokenArray       Array of token addresses invovled in rebalancing
     * @return inflowUnitArray          Array of amount of tokens inserted into system in bid
     * @return outflowUnitArray         Array of amount of tokens taken out of system in bid
     */
    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);

    /*
     * Get combinedTokenArray of Rebalancing Set
     *
     * @return  combinedTokenArray
     */
    function getCombinedTokenArrayLength()
        external
        view
        returns (uint256);

    /*
     * Get combinedTokenArray of Rebalancing Set
     *
     * @return  combinedTokenArray
     */
    function getCombinedTokenArray()
        external
        view
        returns (address[] memory);

    /*
     * Get failedAuctionWithdrawComponents of Rebalancing Set
     *
     * @return  failedAuctionWithdrawComponents
     */
    function getFailedAuctionWithdrawComponents()
        external
        view
        returns (address[] memory);

    /*
     * Get biddingParameters for current auction
     *
     * @return  biddingParameters
     */
    function getBiddingParameters()
        external
        view
        returns (uint256[] memory);

}

// File: set-protocol-contracts/contracts/core/interfaces/ISetToken.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;

/**
 * @title ISetToken
 * @author Set Protocol
 *
 * The ISetToken interface provides a light-weight, structured way to interact with the
 * SetToken contract from another contract.
 */
interface ISetToken {

    /* ============ External Functions ============ */

    /*
     * Get natural unit of Set
     *
     * @return  uint256       Natural unit of Set
     */
    function naturalUnit()
        external
        view
        returns (uint256);

    /*
     * Get addresses of all components in the Set
     *
     * @return  componentAddresses       Array of component tokens
     */
    function getComponents()
        external
        view
        returns (address[] memory);

    /*
     * Get units of all tokens in Set
     *
     * @return  units       Array of component units
     */
    function getUnits()
        external
        view
        returns (uint256[] memory);

    /*
     * Checks to make sure token is component of Set
     *
     * @param  _tokenAddress     Address of token being checked
     * @return  bool             True if token is component of Set
     */
    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);

    /*
     * Mint set token for given address.
     * Can only be called by authorized contracts.
     *
     * @param  _issuer      The address of the issuing account
     * @param  _quantity    The number of sets to attribute to issuer
     */
    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;

    /*
     * Burn set token for given address
     * Can only be called by authorized contracts
     *
     * @param  _from        The address of the redeeming account
     * @param  _quantity    The number of sets to burn from redeemer
     */
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

    /**
    * Transfer token for a specified address
    *
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(
        address to,
        uint256 value
    )
        external;
}

// File: set-protocol-contracts/contracts/core/lib/SetTokenLibrary.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




library SetTokenLibrary {
    using SafeMath for uint256;

    struct SetDetails {
        uint256 naturalUnit;
        address[] components;
        uint256[] units;
    }

    /**
     * Validates that passed in tokens are all components of the Set
     *
     * @param _set                      Address of the Set
     * @param _tokens                   List of tokens to check
     */
    function validateTokensAreComponents(
        address _set,
        address[] calldata _tokens
    )
        external
        view
    {
        for (uint256 i = 0; i < _tokens.length; i++) {
            // Make sure all tokens are members of the Set
            require(
                ISetToken(_set).tokenIsComponent(_tokens[i]),
                "SetTokenLibrary.validateTokensAreComponents: Component must be a member of Set"
            );

        }
    }

    /**
     * Validates that passed in quantity is a multiple of the natural unit of the Set.
     *
     * @param _set                      Address of the Set
     * @param _quantity                   Quantity to validate
     */
    function isMultipleOfSetNaturalUnit(
        address _set,
        uint256 _quantity
    )
        external
        view
    {
        require(
            _quantity.mod(ISetToken(_set).naturalUnit()) == 0,
            "SetTokenLibrary.isMultipleOfSetNaturalUnit: Quantity is not a multiple of nat unit"
        );
    }

    /**
     * Retrieves the Set's natural unit, components, and units.
     *
     * @param _set                      Address of the Set
     * @return SetDetails               Struct containing the natural unit, components, and units
     */
    function getSetDetails(
        address _set
    )
        internal
        view
        returns (SetDetails memory)
    {
        // Declare interface variables
        ISetToken setToken = ISetToken(_set);

        // Fetch set token properties
        uint256 naturalUnit = setToken.naturalUnit();
        address[] memory components = setToken.getComponents();
        uint256[] memory units = setToken.getUnits();

        return SetDetails({
            naturalUnit: naturalUnit,
            components: components,
            units: units
        });
    }
}

// File: contracts/external/DappHub/interfaces/IMedian.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title IMedian
 * @author Set Protocol
 *
 * Interface for operating with a price feed Medianizer contract
 */
interface IMedian {

    /**
     * Returns the current price set on the medianizer. Throws if the price is set to 0 (initialization)
     *
     * @return  Current price of asset represented in hex as bytes32
     */
    function read()
        external
        view
        returns (bytes32);

    /**
     * Returns the current price set on the medianizer and whether the value has been initialized
     *
     * @return  Current price of asset represented in hex as bytes32, and whether value is non-zero
     */
    function peek()
        external
        view
        returns (bytes32, bool);
}

// File: contracts/meta-oracles/interfaces/IMetaOracle.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title IMetaOracle
 * @author Set Protocol
 *
 * Interface for operating with any MetaOracle (moving average, bollinger, etc.)
 */
interface IMetaOracle {

    /**
     * Returns the queried data from a meta oracle.
     *
     * @return  Current price of asset represented in hex as bytes32
     */
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (bytes32);

    /*
     * Get the medianizer source for the price feed the Meta Oracle uses.
     *
     * @returns                  Address of source medianizer of Price Feed
     */
    function getSourceMedianizer()
        external
        view
        returns (address);
}

// File: contracts/managers/lib/FlexibleTimingManagerLibrary.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;

// V2 is used to allow the verification of contracts





/**
 * @title FlexibleTimingManagerLibrary
 * @author Set Protocol
 *
 * The FlexibleTimingManagerLibrary contains functions for helping Managers create proposals
 *
 */
library FlexibleTimingManagerLibrary {
    using SafeMath for uint256;

    /*
     * Validates whether the Rebalancing Set is in the correct state and sufficient time has elapsed.
     *
     * @param  _rebalancingSetInterface      Instance of the Rebalancing Set Token
     */
    function validateManagerPropose(
        IRebalancingSetTokenV2 _rebalancingSetInterface
    )
        internal
    {
        // Require that enough time has passed from last rebalance
        uint256 lastRebalanceTimestamp = _rebalancingSetInterface.lastRebalanceTimestamp();
        uint256 rebalanceInterval = _rebalancingSetInterface.rebalanceInterval();
        require(
            block.timestamp >= lastRebalanceTimestamp.add(rebalanceInterval),
            "FlexibleTimingManagerLibrary.proposeNewRebalance: Rebalance interval not elapsed"
        );

        // Require that Rebalancing Set Token is in Default state, won't allow for re-proposals
        // because malicious actor could prevent token from ever rebalancing
        require(
            _rebalancingSetInterface.rebalanceState() == RebalancingLibraryV2.State.Default,
            "FlexibleTimingManagerLibrary.proposeNewRebalance: State must be in Default"
        );
    }

    /*
    /*
     * Calculates the auction price parameters, targetting 1% slippage every 10 minutes. Fair value
     * placed in middle of price range.
     *
     * @param  _currentSetDollarAmount      The 18 decimal value of one currenSet
     * @param  _nextSetDollarAmount         The 18 decimal value of one nextSet
     * @param  _timeIncrement               Amount of time to explore 1% of fair value price change
     * @param  _auctionLibraryPriceDivisor  The auction library price divisor
     * @param  _auctionTimeToPivot          The auction time to pivot
     * @return uint256                      The auctionStartPrice for rebalance auction
     * @return uint256                      The auctionPivotPrice for rebalance auction
     */
    function calculateAuctionPriceParameters(
        uint256 _currentSetDollarAmount,
        uint256 _nextSetDollarAmount,
        uint256 _timeIncrement,
        uint256 _auctionLibraryPriceDivisor,
        uint256 _auctionTimeToPivot
    )
        internal
        view
        returns (uint256, uint256)
    {
        // Determine fair value of nextSet/currentSet and put in terms of auction library price divisor
        uint256 fairValue = _nextSetDollarAmount.mul(_auctionLibraryPriceDivisor).div(_currentSetDollarAmount);
        // Calculate how much one percent slippage from fair value is
        uint256 onePercentSlippage = fairValue.div(100);

        // Calculate how many time increments are in auctionTimeToPivot
        uint256 timeIncrements = _auctionTimeToPivot.div(_timeIncrement);
        // Since we are targeting a 1% slippage every time increment the price range is defined as
        // the price of a 1% move multiplied by the amount of time increments in the auctionTimeToPivot
        // This value is then divided by two to get half the price range
        uint256 halfPriceRange = timeIncrements.mul(onePercentSlippage).div(2);

        // Auction start price is fair value minus half price range to center the auction at fair value
        uint256 auctionStartPrice = fairValue.sub(halfPriceRange);
        // Auction pivot price is fair value plus half price range to center the auction at fair value
        uint256 auctionPivotPrice = fairValue.add(halfPriceRange);

        return (auctionStartPrice, auctionPivotPrice);
    }

    /*
     * Query the Medianizer price feeds for a value that is returned as a Uint. Prices
     * have 18 decimals.
     *
     * @param  _priceFeedAddress            Address of the medianizer price feed
     * @return uint256                      The price from the price feed with 18 decimals
     */
    function queryPriceData(
        address _priceFeedAddress
    )
        internal
        view
        returns (uint256)
    {
        // Get prices from oracles
        bytes32 priceInBytes = IMedian(_priceFeedAddress).read();

        return uint256(priceInBytes);
    }

    /*
     * Calculates the USD Value of a Set Token - by taking the individual token prices, units
     * and decimals.
     *
     * @param  _tokenPrices         The 18 decimal values of components
     * @param  _naturalUnit         The naturalUnit of the set being component belongs to
     * @param  _units               The units of the components in the Set
     * @param  _tokenDecimals       The components decimal values
     * @return uint256              The USD value of the Set (in cents)
     */
    function calculateSetTokenDollarValue(
        uint256[] memory _tokenPrices,
        uint256 _naturalUnit,
        uint256[] memory _units,
        uint256[] memory _tokenDecimals
    )
        internal
        view
        returns (uint256)
    {
        uint256 setDollarAmount = 0;

        // Loop through assets
        for (uint256 i = 0; i < _tokenPrices.length; i++) {
            uint256 tokenDollarValue = calculateTokenAllocationAmountUSD(
                _tokenPrices[i],
                _naturalUnit,
                _units[i],
                _tokenDecimals[i]
            );

            setDollarAmount = setDollarAmount.add(tokenDollarValue);
        }

        return setDollarAmount;
    }

    /*
     * Get USD value of one component in a Set to 18 decimals
     *
     * @param  _tokenPrice          The 18 decimal value of one full token
     * @param  _naturalUnit         The naturalUnit of the set being component belongs to
     * @param  _unit                The unit of the component in the set
     * @param  _tokenDecimals       The component token's decimal value
     * @return uint256              The USD value of the component's allocation in the Set
     */
    function calculateTokenAllocationAmountUSD(
        uint256 _tokenPrice,
        uint256 _naturalUnit,
        uint256 _unit,
        uint256 _tokenDecimals
    )
        internal
        view
        returns (uint256)
    {
        uint256 SET_TOKEN_DECIMALS = 18;

        // Calculate the amount of component base units are in one full set token
        uint256 componentUnitsInFullToken = _unit
            .mul(10 ** SET_TOKEN_DECIMALS)
            .div(_naturalUnit);

        // Return value of component token in one full set token, to 18 decimals
        uint256 allocationUSDValue = _tokenPrice
            .mul(componentUnitsInFullToken)
            .div(10 ** _tokenDecimals);

        require(
            allocationUSDValue > 0,
            "FlexibleTimingManagerLibrary.calculateTokenAllocationAmountUSD: Value must be > 0"
        );

        return allocationUSDValue;
    }
}

// File: contracts/managers/MACOStrategyManager.sol

/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;



// V2 is used to allow the verification of contracts








/**
 * @title MACOStrategyManager
 * @author Set Protocol
 *
 * Rebalancing Manager contract for implementing the Moving Average (MA) Crossover
 * Strategy between a risk asset's MA and the spot price of the risk asset. The time
 * frame for the MA is defined on instantiation. When the spot price dips below the MA
 * risk asset is sold for stable asset and vice versa when the spot price exceeds the MA.
 */
contract MACOStrategyManager {
    using SafeMath for uint256;

    /* ============ Constants ============ */
    uint256 constant AUCTION_LIB_PRICE_DIVISOR = 1000;
    uint256 constant ALLOCATION_PRICE_RATIO_LIMIT = 4;

    uint256 constant TEN_MINUTES_IN_SECONDS = 600;

    // Equal to $1 since token prices are passed with 18 decimals
    uint256 constant STABLE_ASSET_PRICE = 10 ** 18;
    uint256 constant SET_TOKEN_DECIMALS = 10**18;

    /* ============ State Variables ============ */
    address public contractDeployer;
    address public rebalancingSetTokenAddress;
    address public coreAddress;
    address public movingAveragePriceFeed;
    address public setTokenFactory;
    address public auctionLibrary;

    address public stableAssetAddress;
    address public riskAssetAddress;
    address public stableCollateralAddress;
    address public riskCollateralAddress;

    uint256 public stableAssetDecimals;
    uint256 public riskAssetDecimals;

    uint256 public auctionTimeToPivot;
    uint256 public movingAverageDays;
    uint256 public lastCrossoverConfirmationTimestamp;

    uint256 public crossoverConfirmationMinTime;
    uint256 public crossoverConfirmationMaxTime;

    /* ============ Events ============ */

    event LogManagerProposal(
        uint256 riskAssetPrice,
        uint256 movingAveragePrice
    );

    /*
     * MACOStrategyManager constructor.
     *
     * @param  _coreAddress                         The address of the Core contract
     * @param  _movingAveragePriceFeed              The address of MA price feed
     * @param  _stableAssetAddress                  The address of the stable asset contract
     * @param  _riskAssetAddress                    The address of the risk asset contract
     * @param  _initialStableCollateralAddress      The address stable collateral
     *                                              (made of stable asset wrapped in a Set Token)
     * @param  _initialRiskCollateralAddress        The address risk collateral
     *                                              (made of risk asset wrapped in a Set Token)
     * @param  _setTokenFactory                     The address of the SetTokenFactory
     * @param  _auctionLibrary                      The address of auction price curve to use in rebalance
     * @param  _movingAverageDays                   The amount of days to use in moving average calculation
     * @param  _auctionTimeToPivot                  The amount of time until pivot reached in rebalance
     * @param  _crossoverConfirmationBounds         The minimum and maximum time in seconds confirm confirmation
     *                                                can be called after the last initial crossover confirmation
     */
    constructor(
        address _coreAddress,
        address _movingAveragePriceFeed,
        address _stableAssetAddress,
        address _riskAssetAddress,
        address _initialStableCollateralAddress,
        address _initialRiskCollateralAddress,
        address _setTokenFactory,
        address _auctionLibrary,
        uint256 _movingAverageDays,
        uint256 _auctionTimeToPivot,
        uint256[2] memory _crossoverConfirmationBounds
    )
        public
    {
        contractDeployer = msg.sender;
        coreAddress = _coreAddress;
        movingAveragePriceFeed = _movingAveragePriceFeed;
        setTokenFactory = _setTokenFactory;
        auctionLibrary = _auctionLibrary;

        stableAssetAddress = _stableAssetAddress;
        riskAssetAddress = _riskAssetAddress;
        stableCollateralAddress = _initialStableCollateralAddress;
        riskCollateralAddress = _initialRiskCollateralAddress;

        auctionTimeToPivot = _auctionTimeToPivot;
        movingAverageDays = _movingAverageDays;
        lastCrossoverConfirmationTimestamp = 0;

        crossoverConfirmationMinTime = _crossoverConfirmationBounds[0];
        crossoverConfirmationMaxTime = _crossoverConfirmationBounds[1];

        address[] memory initialRiskCollateralComponents = ISetToken(_initialRiskCollateralAddress).getComponents();
        address[] memory initialStableCollateralComponents = ISetToken(_initialStableCollateralAddress).getComponents();

        require(
            crossoverConfirmationMaxTime > crossoverConfirmationMinTime,
            "MACOStrategyManager.constructor: Max confirmation time must be greater than min."
        );

        require(
            initialStableCollateralComponents[0] == _stableAssetAddress,
            "MACOStrategyManager.constructor: Stable collateral component must match stable asset."
        );

        require(
            initialRiskCollateralComponents[0] == _riskAssetAddress,
            "MACOStrategyManager.constructor: Risk collateral component must match risk asset."
        );

        // Get decimals of underlying assets from smart contracts
        stableAssetDecimals = ERC20Detailed(_stableAssetAddress).decimals();
        riskAssetDecimals = ERC20Detailed(_riskAssetAddress).decimals();
    }

    /* ============ External ============ */

    /*
     * This function sets the Rebalancing Set Token address that the manager is associated with.
     * Since, the rebalancing set token must first specify the address of the manager before deployment,
     * we cannot know what the rebalancing set token is in advance. This function is only meant to be called
     * once during initialization by the contract deployer.
     *
     * @param  _rebalancingSetTokenAddress       The address of the rebalancing Set token
     */
    function initialize(
        address _rebalancingSetTokenAddress
    )
        external
    {
        // Check that contract deployer is calling function
        require(
            msg.sender == contractDeployer,
            "MACOStrategyManager.initialize: Only the contract deployer can initialize"
        );

        // Make sure the rebalancingSetToken is tracked by Core
        require(
            ICore(coreAddress).validSets(_rebalancingSetTokenAddress),
            "MACOStrategyManager.initialize: Invalid or disabled RebalancingSetToken address"
        );

        rebalancingSetTokenAddress = _rebalancingSetTokenAddress;
        contractDeployer = address(0);
    }

    /*
     * When allowed on RebalancingSetToken, anyone can call for a new rebalance proposal. This begins a six
     * hour period where the signal can be confirmed before moving ahead with rebalance.
     *
     */
    function initialPropose()
        external
    {
        // Make sure propose in manager hasn't already been initiated
        require(
            block.timestamp > lastCrossoverConfirmationTimestamp.add(crossoverConfirmationMaxTime),
            "MACOStrategyManager.initialPropose: 12 hours must pass before new proposal initiated"
        );

        // Create interface to interact with RebalancingSetToken and check enough time has passed for proposal
        FlexibleTimingManagerLibrary.validateManagerPropose(IRebalancingSetTokenV2(rebalancingSetTokenAddress));

        // Get price data from oracles
        (
            uint256 riskAssetPrice,
            uint256 movingAveragePrice
        ) = getPriceData();

        // Make sure price trigger has been reached
        checkPriceTriggerMet(riskAssetPrice, movingAveragePrice);

        lastCrossoverConfirmationTimestamp = block.timestamp;
    }

    /*
     * After initial propose is called, confirm the signal has been met and determine parameters for the rebalance
     *
     */
    function confirmPropose()
        external
    {
        // Make sure enough time has passed to initiate proposal on Rebalancing Set Token
        require(
            block.timestamp >= lastCrossoverConfirmationTimestamp.add(crossoverConfirmationMinTime) &&
            block.timestamp <= lastCrossoverConfirmationTimestamp.add(crossoverConfirmationMaxTime),
            "MACOStrategyManager.confirmPropose: Confirming signal must be within bounds of the initial propose"
        );

        // Create interface to interact with RebalancingSetToken and check not in Proposal state
        FlexibleTimingManagerLibrary.validateManagerPropose(IRebalancingSetTokenV2(rebalancingSetTokenAddress));

        // Get price data from oracles
        (
            uint256 riskAssetPrice,
            uint256 movingAveragePrice
        ) = getPriceData();

        // Make sure price trigger has been reached
        checkPriceTriggerMet(riskAssetPrice, movingAveragePrice);

        // If price trigger has been met, get next Set allocation. Create new set if price difference is too
        // great to run good auction. Return nextSet address and dollar value of current and next set
        (
            address nextSetAddress,
            uint256 currentSetDollarValue,
            uint256 nextSetDollarValue
        ) = determineNewAllocation(
            riskAssetPrice,
            movingAveragePrice
        );

        // Calculate the price parameters for auction
        (
            uint256 auctionStartPrice,
            uint256 auctionPivotPrice
        ) = FlexibleTimingManagerLibrary.calculateAuctionPriceParameters(
            currentSetDollarValue,
            nextSetDollarValue,
            TEN_MINUTES_IN_SECONDS,
            AUCTION_LIB_PRICE_DIVISOR,
            auctionTimeToPivot
        );

        // Propose new allocation to Rebalancing Set Token
        IRebalancingSetTokenV2(rebalancingSetTokenAddress).propose(
            nextSetAddress,
            auctionLibrary,
            auctionTimeToPivot,
            auctionStartPrice,
            auctionPivotPrice
        );

        emit LogManagerProposal(
            riskAssetPrice,
            movingAveragePrice
        );
    }

    /* ============ Internal ============ */

    /*
     * Determine if risk collateral is currently collateralizing the rebalancing set, if so return true,
     * else return false.
     *
     * @return boolean              True if risk collateral in use, false otherwise
     */
    function usingRiskCollateral()
        internal
        view
        returns (bool)
    {
        // Get set currently collateralizing rebalancing set token
        address[] memory currentCollateralComponents = ISetToken(rebalancingSetTokenAddress).getComponents();

        // If collateralized by riskCollateral set return true, else to false
        return (currentCollateralComponents[0] == riskCollateralAddress);
    }

    /*
     * Get the risk asset and moving average prices from respective oracles. Price returned have 18 decimals so
     * 10 ** 18 = $1.
     *
     * @return uint256              USD Price of risk asset
     * @return uint256              Moving average USD Price of risk asset
     */
    function getPriceData()
        internal
        view
        returns(uint256, uint256)
    {
        // Get raw riska asset price feed being used by moving average oracle
        address riskAssetPriceFeed = IMetaOracle(movingAveragePriceFeed).getSourceMedianizer();

        // Get current risk asset price and moving average data
        uint256 riskAssetPrice = FlexibleTimingManagerLibrary.queryPriceData(riskAssetPriceFeed);
        uint256 movingAveragePrice = uint256(IMetaOracle(movingAveragePriceFeed).read(movingAverageDays));

        return (riskAssetPrice, movingAveragePrice);
    }

    /*
     * Check to make sure that the necessary price changes have occured to allow a rebalance.
     *
     * @param  _riskAssetPrice          Current risk asset price as found on oracle
     * @param  _movingAveragePrice      Current MA price from Meta Oracle
     */
    function checkPriceTriggerMet(
        uint256 _riskAssetPrice,
        uint256 _movingAveragePrice
    )
        internal
        view
    {
        if (usingRiskCollateral()) {
            // If currently holding risk asset (riskOn) check to see if price is below MA, otherwise revert.
            require(
                _movingAveragePrice > _riskAssetPrice,
                "MACOStrategyManager.checkPriceTriggerMet: Risk asset price must be below moving average price"
            );
        } else {
            // If currently holding stable asset (not riskOn) check to see if price is above MA, otherwise revert.
            require(
                _movingAveragePrice < _riskAssetPrice,
                "MACOStrategyManager.checkPriceTriggerMet: Risk asset price must be above moving average price"
            );
        }
    }

    /*
     * Check to make sure that the necessary price changes have occured to allow a rebalance.
     * Determine the next allocation to rebalance into. If the dollar value of the two collateral sets is more
     * than 5x different from each other then create a new collateral set. If currently riskOn then a new
     * stable collateral set is created, if !riskOn then a new risk collateral set is created.
     *
     * @param  _riskAssetPrice          Current risk asset price as found on oracle
     * @param  _movingAveragePrice      Current MA price from Meta Oracle
     * @return address                  The address of the proposed nextSet
     * @return uint256                  The USD value of current Set
     * @return uint256                  The USD value of next Set
     */
    function determineNewAllocation(
        uint256 _riskAssetPrice,
        uint256 _movingAveragePrice
    )
        internal
        returns (address, uint256, uint256)
    {
        // Check to see if new collateral must be created in order to keep collateral price ratio in line.
        // If not just return the dollar value of current collateral sets
        (
            uint256 stableCollateralDollarValue,
            uint256 riskCollateralDollarValue
        ) = checkForNewAllocation(_riskAssetPrice);

        (
            address nextSetAddress,
            uint256 currentSetDollarValue,
            uint256 nextSetDollarValue
        ) = usingRiskCollateral() ? (stableCollateralAddress, riskCollateralDollarValue, stableCollateralDollarValue) :
            (riskCollateralAddress, stableCollateralDollarValue, riskCollateralDollarValue);

        return (nextSetAddress, currentSetDollarValue, nextSetDollarValue);
    }

    /*
     * Check to see if a new collateral set needs to be created. If the dollar value of the two collateral sets is more
     * than 5x different from each other then create a new collateral set.
     *
     * @param  _riskAssetPrice          Current risk asset price as found on oracle
     * @return uint256                  The USD value of stable collateral
     * @return uint256                  The USD value of risk collateral
     */
    function checkForNewAllocation(
        uint256 _riskAssetPrice
    )
        internal
        returns(uint256, uint256)
    {
        // Get details of both collateral sets
        SetTokenLibrary.SetDetails memory stableCollateralDetails = SetTokenLibrary.getSetDetails(
            stableCollateralAddress
        );
        SetTokenLibrary.SetDetails memory riskCollateralDetails = SetTokenLibrary.getSetDetails(
            riskCollateralAddress
        );

        // Value both Sets
        uint256 stableCollateralDollarValue = FlexibleTimingManagerLibrary.calculateTokenAllocationAmountUSD(
            STABLE_ASSET_PRICE,
            stableCollateralDetails.naturalUnit,
            stableCollateralDetails.units[0],
            stableAssetDecimals
        );
        uint256 riskCollateralDollarValue = FlexibleTimingManagerLibrary.calculateTokenAllocationAmountUSD(
            _riskAssetPrice,
            riskCollateralDetails.naturalUnit,
            riskCollateralDetails.units[0],
            riskAssetDecimals
        );

        // If value of one Set is 5 times greater than the other, create a new collateral Set
        if (riskCollateralDollarValue.mul(ALLOCATION_PRICE_RATIO_LIMIT) <= stableCollateralDollarValue ||
            riskCollateralDollarValue >= stableCollateralDollarValue.mul(ALLOCATION_PRICE_RATIO_LIMIT)) {
            //Determine the new collateral parameters
            return determineNewCollateralParameters(
                _riskAssetPrice,
                stableCollateralDollarValue,
                riskCollateralDollarValue,
                stableCollateralDetails,
                riskCollateralDetails
            );
        } else {
            return (stableCollateralDollarValue, riskCollateralDollarValue);
        }
    }

    /*
     * Create new collateral Set for the occasion where the dollar value of the two collateral
     * sets is more than 5x different from each other. The new collateral set address is then
     * assigned to the correct state variable (risk or stable collateral)
     *
     * @param  _riskAssetPrice                  Current risk asset price as found on oracle
     * @param  _stableCollateralValue           Value of current stable collateral set in USD
     * @param  _riskCollateralValue             Value of current risk collateral set in USD
     * @param  _stableCollateralDetails         Set details of current stable collateral set
     * @param  _riskCollateralDetails           Set details of current risk collateral set
     * @return uint256                          The USD value of stable collateral
     * @return uint256                          The USD value of risk collateral
     */
    function determineNewCollateralParameters(
        uint256 _riskAssetPrice,
        uint256 _stableCollateralValue,
        uint256 _riskCollateralValue,
        SetTokenLibrary.SetDetails memory _stableCollateralDetails,
        SetTokenLibrary.SetDetails memory _riskCollateralDetails
    )
        internal
        returns (uint256, uint256)
    {
        uint256 stableCollateralDollarValue;
        uint256 riskCollateralDollarValue;

        if (usingRiskCollateral()) {
            // Create static components and units array
            address[] memory nextSetComponents = new address[](1);
            nextSetComponents[0] = stableAssetAddress;

            (
                uint256[] memory nextSetUnits,
                uint256 nextNaturalUnit
            ) = getNewCollateralSetParameters(
                _riskCollateralValue,
                STABLE_ASSET_PRICE,
                stableAssetDecimals,
                _stableCollateralDetails.naturalUnit
            );

            // Create new stable collateral set with units and naturalUnit as calculated above
            stableCollateralAddress = ICore(coreAddress).createSet(
                setTokenFactory,
                nextSetComponents,
                nextSetUnits,
                nextNaturalUnit,
                bytes32("STBLCollateral"),
                bytes32("STBLMACO"),
                ""
            );
            // Calculate dollar value of new stable collateral
            stableCollateralDollarValue = FlexibleTimingManagerLibrary.calculateTokenAllocationAmountUSD(
                STABLE_ASSET_PRICE,
                nextNaturalUnit,
                nextSetUnits[0],
                stableAssetDecimals
            );
            riskCollateralDollarValue = _riskCollateralValue;
        } else {
            // Create static components and units array
            address[] memory nextSetComponents = new address[](1);
            nextSetComponents[0] = riskAssetAddress;

            (
                uint256[] memory nextSetUnits,
                uint256 nextNaturalUnit
            ) = getNewCollateralSetParameters(
                _stableCollateralValue,
                _riskAssetPrice,
                riskAssetDecimals,
                _riskCollateralDetails.naturalUnit
            );

            // Create new risk collateral set with units and naturalUnit as calculated above
            riskCollateralAddress = ICore(coreAddress).createSet(
                setTokenFactory,
                nextSetComponents,
                nextSetUnits,
                nextNaturalUnit,
                bytes32("RISKCollateral"),
                bytes32("RISKMACO"),
                ""
            );

            // Calculate dollar value of new risk collateral
            riskCollateralDollarValue = FlexibleTimingManagerLibrary.calculateTokenAllocationAmountUSD(
                _riskAssetPrice,
                nextNaturalUnit,
                nextSetUnits[0],
                riskAssetDecimals
            );
            stableCollateralDollarValue = _stableCollateralValue;
        }

        return (stableCollateralDollarValue, riskCollateralDollarValue);
    }

    /*
     * Calculate new collateral units and natural unit. If necessary iterate through until naturalUnit
     * found that supports non-zero unit amount. Here Underlying refers to the token underlying the
     * collateral Set (i.e. ETH is underlying of riskCollateral Set).
     *
     * @param  _currentCollateralUSDValue              USD Value of current collateral set
     * @param  _replacementUnderlyingPrice             Price of underlying token to be rebalanced into
     * @param  _replacementUnderlyingDecimals          Amount of decimals in replacement token
     * @param  _replacementCollateralNaturalUnit       Natural Unit of replacement collateral Set
     * @return uint256[]                               Units array for new collateral set
     * @return uint256                                 NaturalUnit for new collateral set
     */
    function getNewCollateralSetParameters(
        uint256 _currentCollateralUSDValue,
        uint256 _replacementUnderlyingPrice,
        uint256 _replacementUnderlyingDecimals,
        uint256 _replacementCollateralNaturalUnit
    )
        internal
        pure
        returns (uint256[] memory, uint256)
    {
        // Calculate nextSetUnits such that the USD value of new Set is equal to the USD value of the Set
        // being rebalanced out of
        uint256[] memory nextSetUnits = new uint256[](1);

        uint256 potentialNextUnit = 0;
        uint256 naturalUnitMultiplier = 1;
        uint256 nextNaturalUnit;

        // Calculate next units. If nextUnit is 0 then bump natural unit (and thus units) by factor of
        // ten until unit is greater than 0
        while (potentialNextUnit == 0) {
            nextNaturalUnit = _replacementCollateralNaturalUnit.mul(naturalUnitMultiplier);
            potentialNextUnit = calculateNextSetUnits(
                _currentCollateralUSDValue,
                _replacementUnderlyingPrice,
                _replacementUnderlyingDecimals,
                nextNaturalUnit
            );
            naturalUnitMultiplier = naturalUnitMultiplier.mul(10);
        }

        nextSetUnits[0] = potentialNextUnit;
        return (nextSetUnits, nextNaturalUnit);
    }

    /*
     * Calculate new collateral units by making the new collateral USD value equal to the USD value of the
     * Set currently collateralizing the Rebalancing Set. Here Underlying refers to the token underlying the
     * collateral Set (i.e. ETH is underlying of riskCollateral Set).
     *
     * @param  _currentCollateralUSDValue              USD Value of current collateral set
     * @param  _replacementUnderlyingPrice             Price of asset to be rebalanced into
     * @param  _replacementUnderlyingDecimals          Amount of decimals in replacement collateral
     * @param  _replacementCollateralNaturalUnit       Natural Unit of collateral set to be replacement
     * @return uint256                                 New unit for new collateral set
     */
    function calculateNextSetUnits(
        uint256 _currentCollateralUSDValue,
        uint256 _replacementUnderlyingPrice,
        uint256 _replacementUnderlyingDecimals,
        uint256 _replacementCollateralNaturalUnit
    )
        internal
        pure
        returns (uint256)
    {
        return _currentCollateralUSDValue
            .mul(10 ** _replacementUnderlyingDecimals)
            .mul(_replacementCollateralNaturalUnit)
            .div(SET_TOKEN_DECIMALS.mul(_replacementUnderlyingPrice));
    }
}