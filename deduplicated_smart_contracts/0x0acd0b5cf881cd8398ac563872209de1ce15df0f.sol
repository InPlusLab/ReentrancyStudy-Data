/**
 *Submitted for verification at Etherscan.io on 2019-09-09
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;
pragma experimental "ABIEncoderV2";

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

// File: contracts/lib/CommonMath.sol

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



library CommonMath {
    using SafeMath for uint256;

    /**
     * Calculates and returns the maximum value for a uint256
     *
     * @return  The maximum value for uint256
     */
    function maxUInt256()
        internal
        pure
        returns (uint256)
    {
        return 2 ** 256 - 1;
    }

    /**
    * @dev Performs the power on a specified value, reverts on overflow.
    */
    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {
        require(a > 0);

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

            // Using safemath multiplication prevents overflows
            result = previousResult.mul(a);
        }

        return result;
    }

    /**
     * Checks for rounding errors and returns value of potential partial amounts of a principal
     *
     * @param  _principal       Number fractional amount is derived from
     * @param  _numerator       Numerator of fraction
     * @param  _denominator     Denominator of fraction
     * @return uint256          Fractional amount of principal calculated
     */
    function getPartialAmount(
        uint256 _principal,
        uint256 _numerator,
        uint256 _denominator
    )
        internal
        pure
        returns (uint256)
    {
        // Get remainder of partial amount (if 0 not a partial amount)
        uint256 remainder = mulmod(_principal, _numerator, _denominator);

        // Return if not a partial amount
        if (remainder == 0) {
            return _principal.mul(_numerator).div(_denominator);
        }

        // Calculate error percentage
        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));

        // Require error percentage is less than 0.1%.
        require(
            errPercentageTimes1000000 < 1000,
            "CommonMath.getPartialAmount: Rounding error exceeds bounds"
        );

        return _principal.mul(_numerator).div(_denominator);
    }

}

// File: contracts/lib/IERC20.sol

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
 * @title IERC20
 * @author Set Protocol
 *
 * Interface for using ERC20 Tokens. This interface is needed to interact with tokens that are not
 * fully ERC20 compliant and return something other than true on successful transfers.
 */
interface IERC20 {
    function balanceOf(
        address _owner
    )
        external
        view
        returns (uint256);

    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);

    function transfer(
        address _to,
        uint256 _quantity
    )
        external;

    function transferFrom(
        address _from,
        address _to,
        uint256 _quantity
    )
        external;

    function approve(
        address _spender,
        uint256 _quantity
    )
        external
        returns (bool);

    function totalSupply()
        external
        returns (uint256);
}

// File: contracts/lib/ERC20Wrapper.sol

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
 * @title ERC20Wrapper
 * @author Set Protocol
 *
 * This library contains functions for interacting wtih ERC20 tokens, even those not fully compliant.
 * For all functions we will only accept tokens that return a null or true value, any other values will
 * cause the operation to revert.
 */
library ERC20Wrapper {

    // ============ Internal Functions ============

    /**
     * Check balance owner's balance of ERC20 token
     *
     * @param  _token          The address of the ERC20 token
     * @param  _owner          The owner who's balance is being checked
     * @return  uint256        The _owner's amount of tokens
     */
    function balanceOf(
        address _token,
        address _owner
    )
        external
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(_owner);
    }

    /**
     * Checks spender's allowance to use token's on owner's behalf.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _owner          The token owner address
     * @param  _spender        The address the allowance is being checked on
     * @return  uint256        The spender's allowance on behalf of owner
     */
    function allowance(
        address _token,
        address _owner,
        address _spender
    )
        internal
        view
        returns (uint256)
    {
        return IERC20(_token).allowance(_owner, _spender);
    }

    /**
     * Transfers tokens from an address. Handle's tokens that return true or null.
     * If other value returned, reverts.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _to             The address to transfer to
     * @param  _quantity       The amount of tokens to transfer
     */
    function transfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external
    {
        IERC20(_token).transfer(_to, _quantity);

        // Check that transfer returns true or null
        require(
            checkSuccess(),
            "ERC20Wrapper.transfer: Bad return value"
        );
    }

    /**
     * Transfers tokens from an address (that has set allowance on the proxy).
     * Handle's tokens that return true or null. If other value returned, reverts.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     * @param  _quantity       The number of tokens to transfer
     */
    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external
    {
        IERC20(_token).transferFrom(_from, _to, _quantity);

        // Check that transferFrom returns true or null
        require(
            checkSuccess(),
            "ERC20Wrapper.transferFrom: Bad return value"
        );
    }

    /**
     * Grants spender ability to spend on owner's behalf.
     * Handle's tokens that return true or null. If other value returned, reverts.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _spender        The address to approve for transfer
     * @param  _quantity       The amount of tokens to approve spender for
     */
    function approve(
        address _token,
        address _spender,
        uint256 _quantity
    )
        internal
    {
        IERC20(_token).approve(_spender, _quantity);

        // Check that approve returns true or null
        require(
            checkSuccess(),
            "ERC20Wrapper.approve: Bad return value"
        );
    }

    /**
     * Ensure's the owner has granted enough allowance for system to
     * transfer tokens.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _owner          The address of the token owner
     * @param  _spender        The address to grant/check allowance for
     * @param  _quantity       The amount to see if allowed for
     */
    function ensureAllowance(
        address _token,
        address _owner,
        address _spender,
        uint256 _quantity
    )
        internal
    {
        uint256 currentAllowance = allowance(_token, _owner, _spender);
        if (currentAllowance < _quantity) {
            approve(
                _token,
                _spender,
                CommonMath.maxUInt256()
            );
        }
    }

    // ============ Private Functions ============

    /**
     * Checks the return value of the previous function up to 32 bytes. Returns true if the previous
     * function returned 0 bytes or 1.
     */
    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {
        // default to failure
        uint256 returnValue = 0;

        assembly {
            // check number of bytes returned from last function call
            switch returndatasize

            // no bytes returned: assume success
            case 0x0 {
                returnValue := 1
            }

            // 32 bytes returned
            case 0x20 {
                // copy 32 bytes into scratch space
                returndatacopy(0x0, 0x0, 0x20)

                // load those bytes into returnValue
                returnValue := mload(0x0)
            }

            // not sure what was returned: dont mark as success
            default { }
        }

        // check if returned value is one or nothing
        return returnValue == 1;
    }
}

// File: contracts/core/interfaces/ICore.sol

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

// File: contracts/core/lib/ExchangeWrapperLibraryV2.sol

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
 * @title ExchangeWrapperLibrary
 * @author Set Protocol
 *
 * This library contains structs and functions to assist executing orders on third party exchanges
 *
 * CHANGELOG
 * - Removes functions that result in circular dependencies when trying to flatten.
 * - Functions using this library mainly use it for the structs
 */
library ExchangeWrapperLibraryV2 {

    // ============ Structs ============

    /**
     * caller                           Original user initiating transaction
     * orderCount                       Expected number of orders to execute
     */
    struct ExchangeData {
        address caller;
        uint256 orderCount;
    }

    /**
     * components                       A list of the acquired components from exchange wrapper
     * componentQuantities              A list of the component quantities acquired
     */
    struct ExchangeResults {
        address[] receiveTokens;
        uint256[] receiveTokenAmounts;
    }
}

// File: contracts/core/interfaces/IExchangeWrapper.sol

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
 * @title IExchangeWrapper
 * @author Set Protocol
 *
 * Interface for executing an order with an exchange wrapper
 */
interface IExchangeWrapper {

    /* ============ External Functions ============ */

    /**
     * Exchange some amount of makerToken for takerToken.
     *
     * maker                            Issuance order maker
     * taker                            Issuance order taker
     * makerToken                       Address of maker token used in exchange orders
     * makerAssetAmount                 Amount of issuance order maker token to use on this exchange
     * orderCount                       Expected number of orders to execute
     * fillQuantity                     Quantity of Set to be filled
     * attemptedFillQuantity            Quantity of Set taker attempted to fill
     *
     * @param  _orderData               Arbitrary bytes data for any information to pass to the exchange
     */
    function exchange(
        ExchangeWrapperLibraryV2.ExchangeData calldata _exchangeData,
        bytes calldata _orderData
    )
        external
        returns (ExchangeWrapperLibraryV2.ExchangeResults memory);
}

// File: contracts/external/0x/LibBytes.sol

/*
  Copyright 2018 ZeroEx Intl.
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

library LibBytes {

    using LibBytes for bytes;

    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index)
        internal
        pure
        returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );
        assembly {
            result := mload(add(b, 32))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }


    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(bytes memory b, uint256 from, uint256 to)
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            // NOTE: Set Protocol changed from `to < b.length` so that the last byte can be sliced off
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length);
        return result;
    }
}

// File: contracts/core/lib/ExchangeWrapperLibrary.sol

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
 * @title ExchangeWrapperLibrary
 * @author Set Protocol
 *
 * This library contains structs and functions to assist executing orders on third party exchanges
 */
library ExchangeWrapperLibrary {

    // ============ Structs ============

    /**
     * caller                           Original user initiating transaction
     * orderCount                       Expected number of orders to execute
     */
    struct ExchangeData {
        address caller;
        uint256 orderCount;
    }

    /**
     * components                       A list of the acquired components from exchange wrapper
     * componentQuantities              A list of the component quantities acquired
     */
    struct ExchangeResults {
        address[] receiveTokens;
        uint256[] receiveTokenAmounts;
    }

    /**
     * Checks if any send tokens leftover and transfers to caller
     * @param  _sendTokens    The addresses of send tokens
     * @param  _caller        The address of the original transaction caller
     */
    function returnLeftoverSendTokens(
        address[] memory _sendTokens,
        address _caller
    )
        internal
    {
        for (uint256 i = 0; i < _sendTokens.length; i++) {
            // Transfer any unused or remainder send token back to the caller
            uint256 remainderSendToken = ERC20Wrapper.balanceOf(_sendTokens[i], address(this));
            if (remainderSendToken > 0) {
                ERC20Wrapper.transfer(
                    _sendTokens[i],
                    _caller,
                    remainderSendToken
                );
            }
        }
    }

    /**
     * Calls exchange to execute trades and deposits fills into Vault for issuanceOrder maker.
     *
     *
     * @param  _core                    Address of Core
     * @param  _exchangeData            Standard exchange wrapper interface object containing exchange metadata
     * @param  _exchangeWrapper         Address of exchange wrapper being called
     * @param  _bodyData                Arbitrary bytes data for orders to be executed on exchange
     */
    function callExchange(
        address _core,
        ExchangeWrapperLibraryV2.ExchangeData memory _exchangeData,
        address _exchangeWrapper,
        bytes memory _bodyData
    )
        internal
    {
        // Call Exchange
        ExchangeWrapperLibraryV2.ExchangeResults memory exchangeResults = IExchangeWrapper(_exchangeWrapper).exchange(
            _exchangeData,
            _bodyData
        );

        // Transfer receiveToken tokens from wrapper to vault
        ICore(_core).batchDepositModule(
            _exchangeWrapper,
            _exchangeData.caller,
            exchangeResults.receiveTokens,
            exchangeResults.receiveTokenAmounts
        );
    }
}

// File: contracts/external/0x/Exchange/libs/LibEIP712.sol

/*

  Copyright 2018 ZeroEx Intl.

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

contract LibEIP712 {
    // EIP191 header for EIP712 prefix
    string constant EIP191_HEADER = "\x19\x01";

    // EIP712 Domain Name value
    string constant EIP712_DOMAIN_NAME = "0x Protocol";

    // EIP712 Domain Version value
    string constant EIP712_DOMAIN_VERSION = "2";

    // Hash of the EIP712 Domain Separator Schema
    bytes32 public constant EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "address verifyingContract",
        ")"
    ));

    // Hash of the EIP712 Domain Separator data
    bytes32 public EIP712_DOMAIN_HASH;
}

// File: contracts/external/0x/Exchange/libs/LibOrder.sol

/*

  Copyright 2018 ZeroEx Intl.

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


contract LibOrder is
    LibEIP712
{

    // Hash for the EIP712 Order Schema
    bytes32 constant EIP712_ORDER_SCHEMA_HASH = keccak256(abi.encodePacked(
        "Order(",
        "address makerAddress,",
        "address takerAddress,",
        "address feeRecipientAddress,",
        "address senderAddress,",
        "uint256 makerAssetAmount,",
        "uint256 takerAssetAmount,",
        "uint256 makerFee,",
        "uint256 takerFee,",
        "uint256 expirationTimeSeconds,",
        "uint256 salt,",
        "bytes makerAssetData,",
        "bytes takerAssetData",
        ")"
    ));

    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's state is unaffected by external factors, like account balances.
    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FULLY_FILLED,                // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }
}

// File: contracts/external/0x/Exchange/libs/LibFillResults.sol

/*

  Copyright 2018 ZeroEx Intl.

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

contract LibFillResults
{
    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    struct MatchedFillResults {
        FillResults left;                    // Amounts filled and fees paid of left order.
        FillResults right;                   // Amounts filled and fees paid of right order.
        uint256 leftMakerAssetSpreadAmount;  // Spread between price of left and right order, denominated in the left order's makerAsset, paid to taker.
    }
}

// File: contracts/external/0x/Exchange/interfaces/IExchangeCore.sol

/*

  Copyright 2018 ZeroEx Intl.

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



contract IExchangeCore {

    /// @dev Cancels all orders created by makerAddress with a salt less than or equal to the targetOrderEpoch
    ///      and senderAddress equal to msg.sender (or null address if msg.sender == makerAddress).
    /// @param targetOrderEpoch Orders created with a salt less or equal to this value will be cancelled.
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external;

    /// @dev Fills the input order.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev After calling, the order can not be filled anymore.
    /// @param order Order struct containing order specifications.
    function cancelOrder(LibOrder.Order memory order)
        public;

    /// @dev Gets information about an order: status, hash, and amount filled.
    /// @param order Order to gather information on.
    /// @return OrderInfo Information about the order and its state.
    ///                   See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);
}

// File: contracts/external/0x/Exchange/interfaces/IMatchOrders.sol

/*

  Copyright 2018 ZeroEx Intl.

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



contract IMatchOrders {

    /// @dev Match two complementary orders that have a profitable spread.
    ///      Each order is filled at their respective price point. However, the calculations are
    ///      carried out as though the orders are both being filled at the right order's price point.
    ///      The profit made by the left order goes to the taker (who matched the two orders).
    /// @param leftOrder First order to match.
    /// @param rightOrder Second order to match.
    /// @param leftSignature Proof that order was created by the left maker.
    /// @param rightSignature Proof that order was created by the right maker.
    /// @return matchedFillResults Amounts filled and fees paid by maker and taker of matched orders.
    /// TODO: Make this function external once supported by Solidity (See Solidity Issues #3199, #1603)
    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);
}

// File: contracts/external/0x/Exchange/interfaces/ISignatureValidator.sol

/*

  Copyright 2018 ZeroEx Intl.

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

contract ISignatureValidator {

    /// @dev Approves a hash on-chain using any valid signature type.
    ///      After presigning a hash, the preSign signature type will become valid for that hash and signer.
    /// @param signerAddress Address that should have signed the given hash.
    /// @param signature Proof that the hash has been signed by signer.
    function preSign(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature
    )
        external;

    /// @dev Approves/unnapproves a Validator contract to verify signatures on signer's behalf.
    /// @param validatorAddress Address of Validator contract.
    /// @param approval Approval or disapproval of  Validator contract.
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external;

    /// @dev Verifies that a signature is valid.
    /// @param hash Message hash that is signed.
    /// @param signerAddress Address of signer.
    /// @param signature Proof of signing.
    /// @return Validity of order signature.
    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);
}

// File: contracts/external/0x/Exchange/interfaces/ITransactions.sol

/*

  Copyright 2018 ZeroEx Intl.

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

contract ITransactions {

    /// @dev Executes an exchange method call in the context of signer.
    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.
    /// @param signerAddress Address of transaction signer.
    /// @param data AbiV2 encoded calldata.
    /// @param signature Proof of signer transaction by signer.
    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes calldata data,
        bytes calldata signature
    )
        external;
}

// File: contracts/external/0x/Exchange/interfaces/IAssetProxyDispatcher.sol

/*

  Copyright 2018 ZeroEx Intl.

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

contract IAssetProxyDispatcher {

    /// @dev Registers an asset proxy to an asset proxy id.
    ///      An id can only be assigned to a single proxy at a given time.
    /// @param assetProxyId Id to register`newAssetProxy` under.
    /// @param newAssetProxy Address of new asset proxy to register, or 0x0 to unset assetProxyId.
    /// @param oldAssetProxy Existing asset proxy to overwrite, or 0x0 if assetProxyId is currently unused.
    function registerAssetProxy(
        bytes4 assetProxyId,
        address newAssetProxy,
        address oldAssetProxy
    )
        external;

    /// @dev Gets an asset proxy.
    /// @param assetProxyId Id of the asset proxy.
    /// @return The asset proxy registered to assetProxyId. Returns 0x0 if no proxy is registered.
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);
}

// File: contracts/external/0x/Exchange/interfaces/IWrapperFunctions.sol

/*

  Copyright 2018 ZeroEx Intl.

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



contract IWrapperFunctions {
    /// @dev Fills the input order. Reverts if exact takerAssetFillAmount not filled.
    /// @param order LibOrder.Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev Fills an order with specified parameters and ECDSA signature.
    ///      Returns false if the transaction would otherwise revert.
    /// @param order LibOrder.Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev Synchronously executes multiple calls of fillOrder.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrKill.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Fills an order with specified parameters and ECDSA signature.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketSellOrders(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of makerAsset is bought by taker.
    /// @param orders Array of order specifications.
    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketBuyOrders(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple fill orders in a single transaction until total amount is bought by taker.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously cancels multiple orders in a single transaction.
    /// @param orders Array of order specifications.
    function batchCancelOrders(LibOrder.Order[] memory orders)
        public;
}

// File: contracts/external/0x/Exchange/interfaces/IExchange.sol

/*

  Copyright 2018 ZeroEx Intl.

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







contract IExchange is
    IExchangeCore,
    IMatchOrders,
    ISignatureValidator,
    ITransactions,
    IAssetProxyDispatcher,
    IWrapperFunctions
{}

// File: contracts/core/exchange-wrappers/lib/ZeroExOrderLibrary.sol

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
 * @title ZeroExOrderLibrary
 * @author Set Protocol
 *
 * This library contains functions and structs to assist with parsing 0x wrapper order data
 *
 * The layout of each wrapper order is in the table below. "ordersData" always refers to one or more byte strings,
 * each containing all of these columns concatenated together. Each of the parse methods (header/body) below takes
 * the entire ordersData along with an offset to parse the next (header/body) specified by the offset. This saves
 * from having to do redudant memCopies to isolate the bytes containing the data to parse.
 *
 * | Section | Data                  | Offset              | Length          | Contents                      |
 * |---------|-----------------------|---------------------|-----------------|-------------------------------|
 * | Header  | signatureLength       | 0                   | 32              | Num Bytes of 0x Signature     |
 * |         | fillAmount            | 32                  | 64              | Taker asset fill amouint      |
 * | Body    | signature             | 64                  | signatureLength | Signature in bytes            |
 * |         | order                 | 64+signatureLength  | 384             | ZeroEx Order                  |
 */
library ZeroExOrderLibrary {
    using LibBytes for bytes;
    using SafeMath for uint256;

    // ============ Structs ============

    struct OrderHeader {
        uint256 signatureLength;
        uint256 fillAmount;
        bytes signature;
    }

    struct ZeroExOrderInformation {
        OrderHeader header;
        LibOrder.Order order;
        address makerToken;
        address takerToken;
    }

    // ============ Internal Functions ============

    /*
     * Parses the header from order byte array
     * Can only be called by authorized contracts.
     *
     * @param  _ordersData   Byte array of order data
     * @param  _offset       Offset to start scanning for order header
     * @return OrderHeader   Struct containing wrapper order header data
     */
    function parseOrderHeader(
        bytes memory _ordersData,
        uint256 _offset
    )
        internal
        pure
        returns (OrderHeader memory)
    {
        OrderHeader memory header;

        uint256 orderDataStart = _ordersData.contentAddress().add(_offset);

        assembly {
            mstore(header,           mload(orderDataStart))           // signatureLength
            mstore(add(header, 32),  mload(add(orderDataStart, 32)))  // fillAmount
        }

        return header;
    }

    /*
     * Parses the bytes array into ZeroEx order
     *
     * | Data                       | Location                      |
     * |----------------------------|-------------------------------|
     * | makerAddress               | 0                             |
     * | takerAddress               | 32                            |
     * | feeRecipientAddress        | 64                            |
     * | senderAddress              | 96                            |
     * | makerAssetAmount           | 128                           |
     * | takerAssetAmount           | 160                           |
     * | makerFee                   | 192                           |
     * | takerFee                   | 224                           |
     * | expirationTimeSeconds      | 256                           |
     * | salt                       | 288                           |
     * | makerToken                 | 320                           |
     * | takerToken                 | 352                           |
     *
     * @param  _ordersData          Byte array of (multiple) 0x wrapper orders
     * @param  _offset              Offset to start scanning for 0x order body
     * @return LibOrder.Order       0x order struct
     */
    function parseZeroExOrder(
        bytes memory _ordersData,
        uint256 _offset
    )
        internal
        pure
        returns (LibOrder.Order memory)
    {
        LibOrder.Order memory order;
        address makerTokenAddress;
        address takerTokenAddress;

        uint256 orderDataStart = _ordersData.contentAddress().add(_offset);

        assembly {
            mstore(order,           mload(orderDataStart))            // maker
            mstore(add(order, 32),  mload(add(orderDataStart, 32)))   // taker
            mstore(add(order, 64),  mload(add(orderDataStart, 64)))   // feeRecipient
            mstore(add(order, 96),  mload(add(orderDataStart, 96)))   // senderAddress
            mstore(add(order, 128), mload(add(orderDataStart, 128)))  // makerAssetAmount
            mstore(add(order, 160), mload(add(orderDataStart, 160)))  // takerAssetAmount
            mstore(add(order, 192), mload(add(orderDataStart, 192)))  // makerFee
            mstore(add(order, 224), mload(add(orderDataStart, 224)))  // takerFee
            mstore(add(order, 256), mload(add(orderDataStart, 256)))  // expirationUnixTimestampSec
            mstore(add(order, 288), mload(add(orderDataStart, 288)))  // salt
            makerTokenAddress := mload(add(orderDataStart, 320))      // makerToken
            takerTokenAddress := mload(add(orderDataStart, 352))      // takerToken
        }

        order.makerAssetData = tokenAddressToAssetData(makerTokenAddress);
        order.takerAssetData = tokenAddressToAssetData(takerTokenAddress);

        return order;
    }
    /*
     * Parses the maker token from the ZeroEx order
     *
     * @param  _ordersData          Byte array of (multiple) 0x wrapper orders
     * @param  _offset              Offset to start scanning for 0x order body
     * @return makerTokenAddress
     */
    function parseMakerTokenFromZeroExOrder(
        bytes memory _ordersData,
        uint256 _offset
    )
        internal
        pure
        returns (address)
    {
        address makerTokenAddress;

        uint256 orderDataStart = _ordersData.contentAddress().add(_offset);

        assembly {
            makerTokenAddress := mload(add(orderDataStart, 320))      // makerToken
        }

        return makerTokenAddress;
    }

    /*
     * Parses the taker token from the ZeroEx order
     *
     * @param  _ordersData          Byte array of (multiple) 0x wrapper orders
     * @param  _offset              Offset to start scanning for 0x order body
     * @return takerTokenAddress
     */
    function parseTakerTokenFromZeroExOrder(
        bytes memory _ordersData,
        uint256 _offset
    )
        internal
        pure
        returns (address)
    {
        address takerTokenAddress;

        uint256 orderDataStart = _ordersData.contentAddress().add(_offset);

        assembly {
            takerTokenAddress := mload(add(orderDataStart, 352))      // takerToken
        }

        return takerTokenAddress;
    }

    /*
     * Encodes an ERC20 token address into 0x asset data
     *
     * @param  _tokenAddress    Address of token to encode into 0x asset data
     * @return bytes            0x asset data representation of a token
     */
    function tokenAddressToAssetData(
        address _tokenAddress
    )
        private
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(36);

        // padded version of bytes4(keccak256("ERC20Token(address)"));
        bytes32 selector = 0xf47261b000000000000000000000000000000000000000000000000000000000;

        assembly {
            mstore(add(result, 32), selector)
            mstore(add(result, 36), _tokenAddress)
        }

        return result;
    }
}

// File: core/exchange-wrappers/ZeroExExchangeWrapper.sol

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
 * @title ZeroExExchangeWrapper
 * @author Set Protocol
 *
 * The ZeroExExchangeWrapper contract wrapper to interface with 0x V2
 */
contract ZeroExExchangeWrapper {
    using LibBytes for bytes;
    using SafeMath for uint256;

    /* ============ State Variables ============ */

    address public core;
    address public zeroExExchange;
    address public zeroExProxy;
    address public zeroExToken;
    address public setTransferProxy;

    /* ============ Constructor ============ */

    /**
     * Initialize exchange wrapper with required addresses to facilitate 0x orders
     *
     * @param _core                 Deployed Core contract
     * @param _zeroExExchange       0x Exchange contract for filling orders
     * @param _zeroExProxy          0x Proxy contract for transferring
     * @param _zeroExToken          ZRX token contract addressed used for 0x relayer fees
     * @param _setTransferProxy     Set Protocol transfer proxy contract
     */
    constructor(
        address _core,
        address _zeroExExchange,
        address _zeroExProxy,
        address _zeroExToken,
        address _setTransferProxy
    )
        public
    {
        core = _core;
        zeroExExchange = _zeroExExchange;
        zeroExProxy = _zeroExProxy;
        zeroExToken = _zeroExToken;
        setTransferProxy = _setTransferProxy;

        // Approve transfer of 0x token from this wrapper in the event of zeroExOrder relayer fees
        ERC20Wrapper.approve(
            _zeroExToken,
            _zeroExProxy,
            CommonMath.maxUInt256()
        );
    }

    /* ============ Public Functions ============ */

    /**
     * Parses 0x exchange orders and executes them for Set component tokens
     *
     *
     * @param  _exchangeData            Standard exchange wrapper interface object containing exchange metadata
     * @param  _ordersData              Arbitrary bytes data for any information to pass to the exchange
     * @return ExchangeWrapperLibrary.ExchangeResults  Struct containing component acquisition results
     */
    function exchange(
        ExchangeWrapperLibrary.ExchangeData memory _exchangeData,
        bytes memory _ordersData
    )
        public
        returns (ExchangeWrapperLibrary.ExchangeResults memory)
    {
        require(
            ICore(core).validModules(msg.sender),
            "ZeroExExchangeWrapper.exchange: Sender must be approved module"
        );

        uint256 tradesCount = _exchangeData.orderCount;
        address[] memory sendTokens = new address[](tradesCount);
        address[] memory receiveTokens = new address[](tradesCount);
        uint256[] memory receiveTokenAmounts = new uint256[](tradesCount);

        uint256 scannedBytes = 0;
        for (uint256 i = 0; i < _exchangeData.orderCount; i++) {
            ZeroExOrderLibrary.ZeroExOrderInformation memory orderInformation;
            uint256 orderBodyStart;

            // Parse order i's information
            (orderInformation, orderBodyStart) = parseOrderInformation(
                _ordersData,
                scannedBytes
            );

            // Track the send tokens to ensure any leftovers are returned to the user
            sendTokens[i] = orderInformation.takerToken;

            // Fill the order via the 0x exchange
            (receiveTokens[i], receiveTokenAmounts[i]) = fillZeroExOrder(
                _exchangeData.caller,
                orderInformation
            );

            // Ensure the received token can be transfered via the Set transfer proxy
            ERC20Wrapper.ensureAllowance(
                receiveTokens[i],
                address(this),
                setTransferProxy,
                receiveTokenAmounts[i]
            );

            // Update current bytes
            scannedBytes = orderBodyStart.add(384);
        }

        // Return leftover send tokens to the original caller
        ExchangeWrapperLibrary.returnLeftoverSendTokens(
            sendTokens,
            _exchangeData.caller
        );

        return ExchangeWrapperLibrary.ExchangeResults({
            receiveTokens: receiveTokens,
            receiveTokenAmounts: receiveTokenAmounts
        });
    }

    /* ============ Private ============ */

    /**
     * Parses and executes 0x order from orders data bytes
     *
     * @param  _caller                  Address of user issuing or redeeming using 0x orders
     * @param  _orderInformation        Object with parsed 0x order, signature, header, and maker/taker tokens
     * @return address                  Address of set component (0x makerToken) in 0x order
     * @return uint256                  Amount of 0x order makerTokenAmount received
     */
    function fillZeroExOrder(
        address _caller,
        ZeroExOrderLibrary.ZeroExOrderInformation memory _orderInformation
    )
        private
        returns (address, uint256)
    {
        LibOrder.Order memory order = _orderInformation.order;
        ZeroExOrderLibrary.OrderHeader memory header = _orderInformation.header;

        // Ensure the taker token is allowed to be transferred by ZeroEx Proxy
        ERC20Wrapper.ensureAllowance(
            _orderInformation.takerToken,
            address(this),
            zeroExProxy,
            order.takerAssetAmount
        );

        // Calculate actual fill amount
        uint256 zeroExFillAmount = header.fillAmount;

        // Tranfer ZRX fee from taker if applicable
        if (order.takerFee > 0) {
            transferRelayerFee(
                order.takerFee,
                order.takerAssetAmount,
                _caller,
                zeroExFillAmount
            );
        }

        // Fill 0x order via their Exchange contract
        LibFillResults.FillResults memory fillResults = IExchange(zeroExExchange).fillOrKillOrder(
            order,
            zeroExFillAmount,
            header.signature
        );

        return (
            _orderInformation.makerToken,
            fillResults.makerAssetFilledAmount
        );
    }

    /**
     * Transfers fees from the caller to this wrapper in the event of taker relayer fees on the 0x order
     *
     * @param  _takerFee                   Taker fee of the 0x order
     * @param  _takerAssetAmount           Taker asset of the original
     * @param  _caller                     Address of original caller who is supploying ZRX
     * @param  _fillAmount                 Amount of takerAssetAmount to fill to calculate partial fee
     */
    function transferRelayerFee(
        uint256 _takerFee,
        uint256 _takerAssetAmount,
        address _caller,
        uint256 _fillAmount
    )
        private
    {
        // Calculate amount of taker fee to transfer if fill quantity of 0x order is not for the full takerAssetAmount
        uint256 takerFeeToTransfer = CommonMath.getPartialAmount(
            _takerFee,
            _fillAmount,
            _takerAssetAmount
        );

        // Transfer ZRX from the caller to this wrapper
        ERC20Wrapper.transferFrom(
            zeroExToken,
            _caller,
            address(this),
            takerFeeToTransfer
        );
    }

    /**
     * Parses 0x order and returns order with offset in bytestring to parse next order
     *
     * @param  _ordersData              Arbitrary bytes data for any information to pass to the exchange
     * @param  _offset                  Where to start the parsing of the _ordersData bytestring
     * @return ZeroExOrderInformation   Object with parsed 0x order, signature, header, and maker/taker tokens
     * @return uint256                  Tracks how many bytes in _ordersData have been parsed
     */
    function parseOrderInformation(
        bytes memory _ordersData,
        uint256 _offset
    )
        private
        pure
        returns (ZeroExOrderLibrary.ZeroExOrderInformation memory, uint256)
    {
        // Parse header of current wrapper order
        ZeroExOrderLibrary.OrderHeader memory header = ZeroExOrderLibrary.parseOrderHeader(
            _ordersData,
            _offset
        );

        // Helper to reduce math, keeping the position of the start of the next 0x order body
        uint256 orderBodyStart = _offset.add(header.signatureLength).add(64);

        // Grab signature of current wrapper order after the header of length 64 and before the start of the body
        header.signature = _ordersData.slice(
            _offset.add(64),
            orderBodyStart
        );

        // Parse 0x order of current wrapper order
        LibOrder.Order memory order = ZeroExOrderLibrary.parseZeroExOrder(_ordersData, orderBodyStart);
        address makerToken = ZeroExOrderLibrary.parseMakerTokenFromZeroExOrder(_ordersData, orderBodyStart);
        address takerToken = ZeroExOrderLibrary.parseTakerTokenFromZeroExOrder(_ordersData, orderBodyStart);

        ZeroExOrderLibrary.ZeroExOrderInformation memory orderInformation = ZeroExOrderLibrary.ZeroExOrderInformation({
            header: header,
            order: order,
            makerToken: makerToken,
            takerToken: takerToken
        });

        return (orderInformation, orderBodyStart);
    }
}