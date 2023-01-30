/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

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

    uint256 public constant SCALE_FACTOR = 10 ** 18;
    uint256 public constant MAX_UINT_256 = 2 ** 256 - 1;

    /**
     * Returns scale factor equal to 10 ** 18
     *
     * @return  10 ** 18
     */
    function scaleFactor()
        internal
        pure
        returns (uint256)
    {
        return SCALE_FACTOR;
    }

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
        return MAX_UINT_256;
    }

    /**
     * Increases a value by the scale factor to allow for additional precision
     * during mathematical operations
     */
    function scale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {
        return a.mul(SCALE_FACTOR);
    }

    /**
     * Divides a value by the scale factor to allow for additional precision
     * during mathematical operations
    */
    function deScale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {
        return a.div(SCALE_FACTOR);
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
    * @dev Performs division where if there is a modulo, the value is rounded up
    */
    function divCeil(uint256 a, uint256 b)
        internal
        pure
        returns(uint256)
    {
        return a.mod(b) > 0 ? a.div(b).add(1) : a.div(b);
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

    /*
     * Gets the rounded up log10 of passed value
     *
     * @param  _value         Value to calculate ceil(log()) on
     * @return uint256        Output value
     */
    function ceilLog10(
        uint256 _value
    )
        internal
        pure
        returns (uint256)
    {
        // Make sure passed value is greater than 0
        require (
            _value > 0,
            "CommonMath.ceilLog10: Value must be greater than zero."
        );

        // Since log10(1) = 0, if _value = 1 return 0
        if (_value == 1) return 0;

        // Calcualte ceil(log10())
        uint256 x = _value - 1;

        uint256 result = 0;

        if (x >= 10 ** 64) {
            x /= 10 ** 64;
            result += 64;
        }
        if (x >= 10 ** 32) {
            x /= 10 ** 32;
            result += 32;
        }
        if (x >= 10 ** 16) {
            x /= 10 ** 16;
            result += 16;
        }
        if (x >= 10 ** 8) {
            x /= 10 ** 8;
            result += 8;
        }
        if (x >= 10 ** 4) {
            x /= 10 ** 4;
            result += 4;
        }
        if (x >= 100) {
            x /= 100;
            result += 2;
        }
        if (x >= 10) {
            result += 1;
        }

        return result + 1;
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
     * receiveTokens                    A list of the acquired components from exchange wrapper
     * receiveTokenAmounts              A list of the component quantities acquired
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

// File: contracts/external/KyberNetwork/KyberNetworkProxyInterface.sol

pragma solidity 0.5.7;


/// @title Kyber Network interface
interface KyberNetworkProxyInterface {
    function getExpectedRate(
      address src,
      address dest,
      uint256 srcQty
    )
      external
      view
      returns (uint256 expectedRate, uint256 slippageRate);

    function trade(
      address src,
      uint srcAmount,
      address dest,
      address destAddress,
      uint maxDestAmount,
      uint minConversionRate,
      address walletId
    )
      external
      payable
      returns (uint);
}

// File: contracts/core/exchange-wrappers/KyberNetworkWrapper.sol

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
 * @title KyberNetworkWrapper
 * @author Set Protocol
 *
 * The KyberNetworkWrapper contract wrapper to interface with KyberNetwork for reserve liquidity
 */
contract KyberNetworkWrapper {
    using LibBytes for bytes;
    using SafeMath for uint256;

    /* ============ State Variables ============ */

    address public core;
    address public kyberNetworkProxy;
    address public setTransferProxy;

    uint256 public KYBER_TRADE_LENGTH = 160;

    // ============ Structs ============

    struct KyberTrade {
        address destinationToken;
        address sourceToken;
        uint256 sourceTokenQuantity;
        uint256 minimumConversionRate;
        uint256 maxDestinationQuantity;
    }

    /* ============ Constructor ============ */

    /**
     * Initialize exchange wrapper with required addresses to facilitate Kyber trades
     *
     * @param  _core                 Deployed Core contract
     * @param  _kyberNetworkProxy    KyberNetwork contract for filling orders
     * @param  _setTransferProxy     Set Protocol transfer proxy contract
     */
    constructor(
        address _core,
        address _kyberNetworkProxy,
        address _setTransferProxy
    )
        public
    {
        core = _core;
        kyberNetworkProxy = _kyberNetworkProxy;
        setTransferProxy = _setTransferProxy;
    }

    /* ============ Public Functions ============ */

    /**
     * Returns the conversion rate between the issuance order maker token and the set component token
     * in 18 decimals, regardless of component token's decimals
     *
     * @param  _sourceTokens         Address of source token used in exchange orders
     * @param  _destinationTokens    Address of destination token to trade for
     * @param  _quantities           Amount of maker token to exchange for component token
     * @return uint256[]             Conversion rate in wei
     * @return uint256[]             Slippage in wei
     */
    function conversionRate(
        address[] calldata _sourceTokens,
        address[] calldata _destinationTokens,
        uint256[] calldata _quantities
    )
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256 rateCount = _sourceTokens.length;
        uint256[] memory expectedRates = new uint256[](rateCount);
        uint256[] memory slippageRates = new uint256[](rateCount);

        for (uint256 i = 0; i < rateCount; i++) {
            (expectedRates[i], slippageRates[i]) = KyberNetworkProxyInterface(kyberNetworkProxy).getExpectedRate(
                _sourceTokens[i],
                _destinationTokens[i],
                _quantities[i]
            );
        }

        return (
            expectedRates,
            slippageRates
        );
    }

    /**
     * IExchangeWrapper interface delegate method.
     *
     * Parses and executes Kyber trades. Depending on conversion rate, Kyber trades may result in change.
     * We currently pass change back to the issuance order maker, exploring how it can safely be passed to the taker.
     *
     *
     * @param  _exchangeData            Standard exchange wrapper interface object containing exchange metadata
     * @param  _tradesData              Arbitrary bytes data for any information to pass to the exchange
     * @return ExchangeWrapperLibrary.ExchangeResults  Struct containing component acquisition results
     */
    function exchange(
        ExchangeWrapperLibrary.ExchangeData memory _exchangeData,
        bytes memory _tradesData
    )
        public
        returns (ExchangeWrapperLibrary.ExchangeResults memory)
    {
        require(
            ICore(core).validModules(msg.sender),
            "KyberNetworkWrapper.exchange: Sender must be approved module"
        );

        uint256 tradesCount = _exchangeData.orderCount;
        address[] memory sendTokens = new address[](tradesCount);
        address[] memory receiveTokens = new address[](tradesCount);
        uint256[] memory receiveTokensAmounts = new uint256[](tradesCount);

        // Parse and execute the trade at the current offset via the KyberNetworkProxy, each kyber trade is 160 bytes
        for (uint256 i = 0; i < tradesCount; i++) {
            // Parse Kyber trade at the current offset
            KyberTrade memory trade = parseKyberTrade(
                _tradesData,
                i.mul(KYBER_TRADE_LENGTH)
            );

            // Ensure the caller's source token is allowed to be transferred by
            // KyberNetworkProxy as the source token
            ERC20Wrapper.ensureAllowance(
                trade.sourceToken,
                address(this),
                kyberNetworkProxy,
                trade.sourceTokenQuantity
            );

            // Track the send tokens to ensure any leftovers are returned to the user
            sendTokens[i] = trade.sourceToken;

            // Execute Kyber trade
            (receiveTokens[i], receiveTokensAmounts[i]) = tradeOnKyberReserve(trade);
        }

        // Return leftover send tokens to the original caller
        ExchangeWrapperLibrary.returnLeftoverSendTokens(
            sendTokens,
            _exchangeData.caller
        );

        return ExchangeWrapperLibrary.ExchangeResults({
            receiveTokens: receiveTokens,
            receiveTokenAmounts: receiveTokensAmounts
        });
    }

    /* ============ Private ============ */

    /**
     * Parses and executes Kyber trade
     *
     * @return address                  Address of set component to trade for
     * @return uint256                  Amount of set component received in trade
     */
    function tradeOnKyberReserve(
        KyberTrade memory _trade
    )
        private
        returns (address, uint256)
    {
        // Execute Kyber trade via deployed KyberNetworkProxy contract
        uint256 destinationTokenQuantity = KyberNetworkProxyInterface(kyberNetworkProxy).trade(
            _trade.sourceToken,
            _trade.sourceTokenQuantity,
            _trade.destinationToken,
            address(this),
            _trade.maxDestinationQuantity,
            _trade.minimumConversionRate,
            address(0)
        );

        // Ensure the destination token is allowed to be transferred by Set TransferProxy
        ERC20Wrapper.ensureAllowance(
            _trade.destinationToken,
            address(this),
            setTransferProxy,
            destinationTokenQuantity
        );

        return (
            _trade.destinationToken,
            destinationTokenQuantity
        );
    }

    /*
     * Parses the bytes array for a Kyber trade
     *
     * | Data                       | Location                      |
     * |----------------------------|-------------------------------|
     * | destinationToken           | 0                             |
     * | sourceTokenQuantity        | 32                            |
     * | sourceTokenQuantity        | 64                            |
     * | minimumConversionRate      | 96                            |
     * | maxDestinationQuantity     | 128                           |
     *
     * @param  _tradesData    Byte array of (multiple) Kyber trades
     * @param  _offset        Offset to start scanning for Kyber trade body
     * @return KyberTrade     KyberTrade struct
     */
    function parseKyberTrade(
        bytes memory _tradesData,
        uint256 _offset
    )
        private
        pure
        returns (KyberTrade memory)
    {
        KyberTrade memory trade;

        uint256 tradeDataStart = _tradesData.contentAddress().add(_offset);

        assembly {
            mstore(trade,           mload(tradeDataStart))            // destinationToken
            mstore(add(trade, 32),  mload(add(tradeDataStart, 32)))   // sourceToken
            mstore(add(trade, 64),  mload(add(tradeDataStart, 64)))   // sourceTokenQuantity
            mstore(add(trade, 96),  mload(add(tradeDataStart, 96)))   // minimumConversionRate
            mstore(add(trade, 128), mload(add(tradeDataStart, 128)))  // maxDestinationQuantity
        }

        return trade;
    }
}