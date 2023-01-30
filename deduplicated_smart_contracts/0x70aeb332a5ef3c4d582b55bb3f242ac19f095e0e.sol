/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

/**
 *Submitted for verification at Etherscan.io on 2019-10-30
*/

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.2;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2¦Ð.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
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

// File: contracts/core/interfaces/IRebalanceAuctionModule.sol

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
pragma experimental "ABIEncoderV2";

/**
 * @title IRebalanceAuctionModule
 * @author Set Protocol
 *
 * The IRebalanceAuctionModule interface provides a light-weight, structured way to interact with the
 * RebalanceAuctionModule contract from another contract.
 */

interface IRebalanceAuctionModule {
    /**
     * Bid on rebalancing a given quantity of sets held by a rebalancing token
     * The tokens are returned to the user.
     *
     * @param  _rebalancingSetToken    Address of the rebalancing token being bid on
     * @param  _quantity               Number of currentSets to rebalance
     * @param  _allowPartialFill       Set to true if want to partially fill bid when quantity
     *                                 is greater than currentRemainingSets
     */
    function bidAndWithdraw(
        address _rebalancingSetToken,
        uint256 _quantity,
        bool _allowPartialFill
    )
        external;
}

// File: contracts/core/lib/RebalancingLibrary.sol

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
 * @title RebalancingLibrary
 * @author Set Protocol
 *
 * The RebalancingLibrary contains functions for facilitating the rebalancing process for
 * Rebalancing Set Tokens. Removes the old calculation functions
 *
 */
library RebalancingLibrary {

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

// File: contracts/core/interfaces/IRebalancingSetToken.sol

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
 * @title IRebalancingSetToken
 * @author Set Protocol
 *
 * The IRebalancingSetToken interface provides a light-weight, structured way to interact with the
 * RebalancingSetToken contract from another contract.
 */

interface IRebalancingSetToken {

    /*
     * Get the auction library contract used for the current rebalance
     *
     * @return address    Address of auction library used in the upcoming auction
     */
    function auctionLibrary()
        external
        view
        returns (address);

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
     * Get proposalTimeStamp of Rebalancing Set
     *
     * @return  proposalTimeStamp
     */
    function proposalStartTime()
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
     * @return RebalancingLibrary.State    Current rebalance state of the RebalancingSetToken
     */
    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);

    /*
     * Get the starting amount of current SetToken for the current auction
     *
     * @return  rebalanceState
     */
    function startingCurrentSetAmount()
        external
        view
        returns (uint256);

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
     * Returns the address of the current base SetToken with the current allocation
     *
     * @return           A address representing the base SetToken
     */
    function currentSet()
        external
        view
        returns (address);

    /**
     * Returns the address of the next base SetToken with the post auction allocation
     *
     * @return  address    Address representing the base SetToken
     */
    function nextSet()
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
     * Get auctionPriceParameters for current auction
     *
     * @return uint256[4]    AuctionPriceParameters for current rebalance auction
     */
    function getAuctionPriceParameters()
        external
        view
        returns (uint256[] memory);

    /*
     * Get biddingParameters for current auction
     *
     * @return uint256[2]    BiddingParameters for current rebalance auction
     */
    function getBiddingParameters()
        external
        view
        returns (uint256[] memory);

    /*
     * Get token inflows and outflows required for bid. Also the amount of Rebalancing
     * Sets that would be generated.
     *
     * @param _quantity               The amount of currentSet to be rebalanced
     * @return inflowUnitArray        Array of amount of tokens inserted into system in bid
     * @return outflowUnitArray       Array of amount of tokens taken out of system in bid
     */
    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);

}

// File: contracts/core/interfaces/ITransferProxy.sol

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
 * @title ITransferProxy
 * @author Set Protocol
 *
 * The ITransferProxy interface provides a light-weight, structured way to interact with the
 * TransferProxy contract from another contract.
 */
interface ITransferProxy {

    /* ============ External Functions ============ */

    /**
     * Transfers tokens from an address (that has set allowance on the proxy).
     * Can only be called by authorized core contracts.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _quantity       The number of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function transfer(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;

    /**
     * Transfers tokens from an address (that has set allowance on the proxy).
     * Can only be called by authorized core contracts.
     *
     * @param  _tokens         The addresses of the ERC20 token
     * @param  _quantities     The numbers of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function batchTransfer(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;
}

// File: contracts/lib/IWETH.sol

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
 * @title IWETH
 * @author Set Protocol
 *
 * Interface for Wrapped Ether. This interface allows for interaction for wrapped ether's deposit and withdrawal
 * functionality.
 */
interface IWETH {
    function deposit()
        external
        payable;

    function withdraw(
        uint256 wad
    )
        external;
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

// File: contracts/helper/RebalancingSetEthBidder.sol

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
 * @title RebalancingSetEthBidder
 * @author Set Protocol
 *
 * A helper contract that wraps your ETH into WETH for bidding in the RebalanceAuctionModule.
 */
contract RebalancingSetEthBidder is
    ReentrancyGuard
{
    using SafeMath for uint256;

    // Address and instance of RebalanceAuctionModule contract
    IRebalanceAuctionModule public rebalanceAuctionModule;

    // Address and instance of RebalanceAuctionModule contract
    ITransferProxy public transferProxy;

    // Address and instance of Wrapped Ether contract
    IWETH public weth;

    /* ============ Events ============ */

    event BidPlacedWithEth(
        address indexed rebalancingSetToken,
        address indexed bidder
    );

    /* ============ Constructor ============ */

    /**
     * Constructor function for RebalancingSetEthBidder
     *
     * @param _rebalanceAuctionModule   The address of RebalanceAuctionModule
     * @param _transferProxy            The address of TransferProxy
     * @param _weth                     The address of Wrapped Ether
     */
    constructor(
        IRebalanceAuctionModule _rebalanceAuctionModule,
        ITransferProxy _transferProxy,
        IWETH _weth
    )
        public
    {
        // Commit the RebalanceAuctionModule instance
        rebalanceAuctionModule = _rebalanceAuctionModule;

        // Commit the TransferProxy instance
        transferProxy = _transferProxy;

        // Commit the WETH instance
        weth = _weth;

        // Add approvals of Wrapped Ether to the Transfer Proxy
        ERC20Wrapper.approve(
            address(_weth),
            address(_transferProxy),
            CommonMath.maxUInt256()
        );
    }

    /**
     * Fallback function. Disallows ether to be sent to this contract without data except when
     * unwrapping WETH.
     */
    function ()
        external
        payable
    {
        require(
            msg.sender == address(weth),
            "RebalancingSetEthBidder.fallback: Cannot receive ETH directly unless unwrapping WETH"
        );
    }

    /* ============ External Functions ============ */

    /**
     * Bid on rebalancing a given quantity of sets held by a rebalancing token wrapping or unwrapping
     * any ETH involved. The tokens are returned to the user.
     *
     * @param  _rebalancingSetToken    Instance of the rebalancing token being bid on
     * @param  _quantity               Number of currentSets to rebalance
     * @param  _allowPartialFill       Set to true if want to partially fill bid when quantity
                                       is greater than currentRemainingSets
     */

    function bidAndWithdrawWithEther(
        IRebalancingSetToken _rebalancingSetToken,
        uint256 _quantity,
        bool _allowPartialFill
    )
        external
        payable
        nonReentrant
    {
        // Wrap all Ether sent to the contract
        weth.deposit.value(msg.value)();

        // Get token addresses
        address[] memory combinedTokenArray = _rebalancingSetToken.getCombinedTokenArray();

        // Get inflow and outflow arrays for the given bid quantity
        uint256[] memory inflowArray;
        uint256[] memory outflowArray;
        (
            inflowArray,
            outflowArray
        ) = _rebalancingSetToken.getBidPrice(_quantity);

        // Ensure allowances and transfer non-weth tokens from user
        depositNonWethComponents(
            combinedTokenArray,
            inflowArray
        );

        // Bid in auction
        rebalanceAuctionModule.bidAndWithdraw(
            address(_rebalancingSetToken),
            _quantity,
            _allowPartialFill
        );

        // Withdraw non-weth tokens to user
        withdrawNonWethComponentsToSender(
            combinedTokenArray
        );

        // Unwrap all remaining Ether and transfer to user
        uint256 wethBalance = ERC20Wrapper.balanceOf(address(weth), address(this));
        if (wethBalance > 0) {
            weth.withdraw(wethBalance);
            msg.sender.transfer(wethBalance);
        }

        // Log bid placed with Eth event
        emit BidPlacedWithEth(
            address(_rebalancingSetToken),
            msg.sender
        );
    }

    /* ============ Private Functions ============ */

    /**
     * Before bidding, calculate the required amount of inflow tokens and deposit token components
     * into this helper contract.
     *
     * @param  _combinedTokenArray            Array of token addresses
     * @param  _inflowArray                   Array of inflow token units
     */
    function depositNonWethComponents(
        address[] memory _combinedTokenArray,
        uint256[] memory _inflowArray
    )
        private
    {
        // Loop through the combined token addresses array and deposit inflow amounts
        for (uint256 i = 0; i < _combinedTokenArray.length; i++) {
            address currentComponent = _combinedTokenArray[i];
            uint256 currentComponentQuantity = _inflowArray[i];

            // Check component inflow is greater than 0
            if (currentComponentQuantity > 0) {
                // Ensure allowance for components to transferProxy
                ERC20Wrapper.ensureAllowance(
                    address(currentComponent),
                    address(this),
                    address(transferProxy),
                    currentComponentQuantity
                );

                // If not WETH, transfer tokens from user to contract
                if (currentComponent != address(weth)) {
                    // Transfer tokens to contract
                    ERC20Wrapper.transferFrom(
                        address(currentComponent),
                        msg.sender,
                        address(this),
                        currentComponentQuantity
                    );
                }
            }
        }
    }

     /**
     * After bidding, loop through token address array and transfer
     * token components except wrapped ether to the sender
     *
     * @param  _combinedTokenArray           Array of token addresses
     */
    function withdrawNonWethComponentsToSender(
        address[] memory _combinedTokenArray
    )
        private
    {
        // Loop through the combined token addresses array and withdraw leftover amounts
        for (uint256 i = 0; i < _combinedTokenArray.length; i++) {
            address currentComponent = _combinedTokenArray[i];

            // Get balance of tokens in contract
            uint256 currentComponentBalance = ERC20Wrapper.balanceOf(
                currentComponent,
                address(this)
            );

            // Check component balance is greater than 0
            if (currentComponentBalance > 0 && currentComponent != address(weth)) {
                // Withdraw tokens from the contract and send to the user
                ERC20Wrapper.transfer(
                    address(currentComponent),
                    msg.sender,
                    currentComponentBalance
                );
            }
        }
    }
}