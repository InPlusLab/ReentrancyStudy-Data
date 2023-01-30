/**
 *Submitted for verification at Etherscan.io on 2021-07-12
*/

pragma solidity =0.7.6;
pragma abicoder v2;

// File: @uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol
/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    /// @notice Emitted when the owner of the factory is changed
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
    /// @param fee The enabled fee, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice Returns the current owner of the factory
    /// @dev Can be changed by the current owner via setOwner
    /// @return The address of the factory owner
    function owner() external view returns (address);

    /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
    /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
    /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
    /// @return The tick spacing
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param fee The desired fee for the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    /// @return pool The address of the newly created pool
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice Updates the owner of the factory
    /// @dev Must be called by the current owner
    /// @param _owner The new owner of the factory
    function setOwner(address _owner) external;

    /// @notice Enables a fee amount with the given tickSpacing
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol
/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol
/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol
/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolActions.sol
/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol
/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol
/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

// File: @uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol
/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// File: @uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol
/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

// File: @uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol
/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @uniswap/v3-periphery/contracts/libraries/TransferHelper.sol
library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}

// File: @uniswap/v3-periphery/contracts/libraries/BytesLib.sol
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <[email protected]>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
library BytesLib {
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    // Get a location of some free memory and store it in tempBytes as
                    // Solidity does for memory variables.
                    tempBytes := mload(0x40)

                    // The first word of the slice result is potentially a partial
                    // word read from the original array. To read it, we calculate
                    // the length of that partial word and start copying that many
                    // bytes into the array. The first word we copy will start with
                    // data we don't care about, but the last `lengthmod` bytes will
                    // land at the beginning of the contents of the new array. When
                    // we're done copying, we overwrite the full first word with
                    // the actual length of the slice.
                    let lengthmod := and(_length, 31)

                    // The multiplication in the next line is necessary
                    // because when slicing multiples of 32 bytes (lengthmod == 0)
                    // the following copy loop was copying the origin's length
                    // and then ending prematurely not copying everything it should.
                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        // The multiplication in the next line has the same exact purpose
                        // as the one above.
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    //update free-memory pointer
                    //allocating the array padded to 32 bytes like the compiler does now
                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                //if we want a zero-length slice let's just return a zero-length array
                default {
                    tempBytes := mload(0x40)
                    //zero out the 32 bytes slice we are about to return
                    //we need to do it because Solidity does not garbage collect
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}

// File: @uniswap/v3-periphery/contracts/libraries/Path.sol
/// @title Functions for manipulating path data for multihop swaps
library Path {
    using BytesLib for bytes;

    /// @dev The length of the bytes encoded address
    uint256 private constant ADDR_SIZE = 20;
    /// @dev The length of the bytes encoded fee
    uint256 private constant FEE_SIZE = 3;

    /// @dev The offset of a single token address and pool fee
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    /// @dev The offset of an encoded pool key
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    /// @dev The minimum length of an encoding that contains 2 or more pools
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    /// @notice Returns true iff the path contains two or more pools
    /// @param path The encoded swap path
    /// @return True if path contains two or more pools, otherwise false
    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    /// @notice Decodes the first pool in path
    /// @param path The bytes encoded swap path
    /// @return tokenA The first token of the given pool
    /// @return tokenB The second token of the given pool
    /// @return fee The fee level of the pool
    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {
        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    /// @notice Gets the segment corresponding to the first pool in the path
    /// @param path The bytes encoded swap path
    /// @return The segment containing all data necessary to target the first pool in the path
    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(0, POP_OFFSET);
    }

    /// @notice Skips a token + fee element from the buffer and returns the remainder
    /// @param path The swap path
    /// @return The remaining token + fee elements in the path
    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}

// File: contracts/interfaces/IHotPotV2FundERC20.sol
/// @title Hotpot V2 基金份额代币接口定义
interface IHotPotV2FundERC20 is IERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// File: contracts/interfaces/fund/IHotPotV2FundEvents.sol
/// @title Hotpot V2 事件接口定义
interface IHotPotV2FundEvents {
    /// @notice 当存入基金token时，会触发该事件
    event Deposit(address indexed owner, uint amount, uint share);

    /// @notice 当取走基金token时，会触发该事件
    event Withdraw(address indexed owner, uint amount, uint share);
}

// File: contracts/interfaces/fund/IHotPotV2FundState.sol
/// @title Hotpot V2 状态变量及只读函数
interface IHotPotV2FundState {
    /// @notice 控制器合约地址
    function controller() external view returns (address);

    /// @notice 基金经理地址
    function manager() external view returns (address);

    /// @notice 基金本币地址
    function token() external view returns (address);

    /// @notice 8 bytes 基金经理 + 24 bytes 简要描述
    function descriptor() external view returns (bytes32);

    /// @notice 总投入数量
    function totalInvestment() external view returns (uint);

    /// @notice owner的投入数量
    /// @param owner 用户地址
    /// @return 投入本币的数量
    function investmentOf(address owner) external view returns (uint);

    /// @notice 指定头寸的资产数量
    /// @param poolIndex 池子索引号
    /// @param positionIndex 头寸索引号
    /// @return 以本币计价的头寸资产数量
    function assetsOfPosition(uint poolIndex, uint positionIndex) external view returns(uint);

    /// @notice 指定pool的资产数量
    /// @param poolIndex 池子索引号
    /// @return 以本币计价的池子资产数量
    function assetsOfPool(uint poolIndex) external view returns(uint);

    /// @notice 总资产数量
    /// @return 以本币计价的总资产数量
    function totalAssets() external view returns (uint);

    /// @notice 基金本币->目标代币 的购买路径
    /// @param _token 目标代币地址
    /// @return 符合uniswap v3格式的目标代币购买路径
    function buyPath(address _token) external view returns (bytes memory);

    /// @notice 目标代币->基金本币 的购买路径
    /// @param _token 目标代币地址
    /// @return 符合uniswap v3格式的目标代币销售路径
    function sellPath(address _token) external view returns (bytes memory);

    /// @notice 获取池子地址
    /// @param index 池子索引号
    /// @return 池子地址
    function pools(uint index) external view returns(address);

    /// @notice 头寸信息
    /// @dev 由于基金需要遍历头寸，所以用二维动态数组存储头寸
    /// @param poolIndex 池子索引号
    /// @param positionIndex 头寸索引号
    /// @return isEmpty 是否空头寸，tickLower 价格刻度下届，tickUpper 价格刻度上届
    function positions(uint poolIndex, uint positionIndex) 
        external 
        view 
        returns(
            bool isEmpty,
            int24 tickLower,
            int24 tickUpper 
        );

    /// @notice pool数组长度
    function poolsLength() external view returns(uint);

    /// @notice 指定池子的头寸数组长度
    /// @param poolIndex 池子索引号
    /// @return 头寸数组长度
    function positionsLength(uint poolIndex) external view returns(uint);
}

// File: contracts/interfaces/fund/IHotPotV2FundUserActions.sol
/// @title Hotpot V2 用户操作接口定义
/// @notice 存入(deposit)函数适用于ERC20基金; 如果是ETH基金(内部会转换为WETH9)，应直接向基金合约转账; 
interface IHotPotV2FundUserActions {
    /// @notice 用户存入基金本币
    /// @param amount 存入数量
    /// @return share 用户获得的基金份额
    function deposit(uint amount) external returns(uint share);
    
    /// @notice 用户取出指定份额的本币
    /// @param share 取出的基金份额数量
    /// @return amount 返回本币数量
    function withdraw(uint share) external returns(uint amount);
}

// File: contracts/interfaces/fund/IHotPotV2FundManagerActions.sol
/// @notice 基金经理操作接口定义
interface IHotPotV2FundManagerActions {
    /// @notice 设置代币交易路径
    /// @dev This function can only be called by controller 
    /// @dev 设置路径时不能修改为0地址，且path路径里的token必须验证是否受信任
    /// @param distToken 目标代币地址
    /// @param buy 购买路径(本币->distToken)
    /// @param sell 销售路径(distToken->本币)
    function setPath(
        address distToken, 
        bytes memory buy,
        bytes memory sell
    ) external;

    /// @notice 初始化头寸, 允许投资额为0.
    /// @dev This function can only be called by controller
    /// @param token0 token0 地址
    /// @param token1 token1 地址
    /// @param fee 手续费率
    /// @param tickLower 价格刻度下届
    /// @param tickUpper 价格刻度上届
    /// @param amount 初始化投入金额，允许为0, 为0表示仅初始化头寸，不作实质性投资
    function init(
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount
    ) external;

    /// @notice 投资指定头寸，可选复投手续费
    /// @dev This function can only be called by controller 
    /// @param poolIndex 池子索引号
    /// @param positionIndex 头寸索引号
    /// @param amount 投资金额
    /// @param collect 是否收集已产生的手续费并复投
    function add(
        uint poolIndex, 
        uint positionIndex, 
        uint amount, 
        bool collect
    ) external;

    /// @notice 撤资指定头寸
    /// @dev This function can only be called by controller 
    /// @param poolIndex 池子索引号
    /// @param positionIndex 头寸索引号
    /// @param proportionX128 撤资比例，左移128位; 允许为0，为0表示只收集手续费
    function sub(
        uint poolIndex, 
        uint positionIndex, 
        uint proportionX128
    ) external;

    /// @notice 调整头寸投资
    /// @dev This function can only be called by controller 
    /// @param poolIndex 池子索引号
    /// @param subIndex 要移除的头寸索引号
    /// @param addIndex 要添加的头寸索引号
    /// @param proportionX128 调整比例，左移128位
    function move(
        uint poolIndex,
        uint subIndex, 
        uint addIndex, 
        uint proportionX128 //以前是按LP数量移除，现在改成按总比例移除，这样前端就不用管实际LP是多少了
    ) external;
}

// File: contracts/interfaces/IHotPotV2Fund.sol
/// @title Hotpot V2 基金接口
/// @notice 接口定义分散在多个接口文件
interface IHotPotV2Fund is 
    IHotPotV2FundERC20, 
    IHotPotV2FundEvents, 
    IHotPotV2FundState, 
    IHotPotV2FundUserActions, 
    IHotPotV2FundManagerActions
{    
}

// File: contracts/interfaces/IHotPot.sol
/// @title HPT (Hotpot Funds) 代币接口定义.
interface IHotPot is IERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function burn(uint value) external returns (bool) ;
    function burnFrom(address from, uint value) external returns (bool);
}

// File: contracts/interfaces/controller/IManagerActions.sol
/// @title 控制器合约基金经理操作接口定义
interface IManagerActions {
    /// @notice 设置代币交易路径
    /// @dev This function can only be called by manager 
    /// @dev 设置路径时不能修改为0地址，且path路径里的token必须验证是否受信任
    /// @param fund 基金地址
    /// @param distToken 目标代币地址
    /// @param path 符合uniswap v3格式的交易路径
    function setPath(
        address fund, 
        address distToken, 
        bytes memory path
    ) external;

    /// @notice 初始化头寸, 允许投资额为0.
    /// @dev This function can only be called by manager
    /// @param fund 基金地址
    /// @param token0 token0 地址
    /// @param token1 token1 地址
    /// @param fee 手续费率
    /// @param tickLower 价格刻度下届
    /// @param tickUpper 价格刻度上届
    /// @param amount 初始化投入金额，允许为0, 为0表示仅初始化头寸，不作实质性投资
    function init(
        address fund,
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount
    ) external;

    /// @notice 投资指定头寸，可选复投手续费
    /// @dev This function can only be called by manager 
    /// @param fund 基金地址
    /// @param poolIndex 池子索引号
    /// @param positionIndex 头寸索引号
    /// @param amount 投资金额
    /// @param collect 是否收集已产生的手续费并复投
    function add(
        address fund,
        uint poolIndex,
        uint positionIndex, 
        uint amount, 
        bool collect
    ) external;

    /// @notice 撤资指定头寸
    /// @dev This function can only be called by manager 
    /// @param fund 基金地址
    /// @param poolIndex 池子索引号
    /// @param positionIndex 头寸索引号
    /// @param proportionX128 撤资比例，左移128位; 允许为0，为0表示只收集手续费
    function sub(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint proportionX128
    ) external;

    /// @notice 调整头寸投资
    /// @dev This function can only be called by manager 
    /// @param fund 基金地址
    /// @param poolIndex 池子索引号
    /// @param subIndex 要移除的头寸索引号
    /// @param addIndex 要添加的头寸索引号
    /// @param proportionX128 调整比例，左移128位
    function move(
        address fund,
        uint poolIndex,
        uint subIndex, 
        uint addIndex,
        uint proportionX128
    ) external;
}

// File: contracts/interfaces/controller/IGovernanceActions.sol
/// @title 治理操作接口定义
interface IGovernanceActions {
    /// @notice Change governance
    /// @dev This function can only be called by governance
    /// @param account 新的governance地址
    function setGovernance(address account) external;

    /// @notice Set the token to be verified for all fund, vice versa
    /// @dev This function can only be called by governance
    /// @param token 目标代币
    /// @param isVerified 是否受信任
    function setVerifiedToken(address token, bool isVerified) external;

    /// @notice Set the swap path for harvest
    /// @dev This function can only be called by governance
    /// @param token 目标代币
    /// @param path 路径
    function setHarvestPath(address token, bytes memory path) external;
}

// File: contracts/interfaces/controller/IControllerState.sol
/// @title HotPotV2Controller 状态变量及只读函数
interface IControllerState {
    /// @notice Returns the address of the Uniswap V3 router
    function uniV3Router() external view returns (address);

    /// @notice Returns the address of the Uniswap V3 facotry
    function uniV3Factory() external view returns (address);

    /// @notice 本项目治理代币HPT的地址
    function hotpot() external view returns (address);

    /// @notice 治理账户地址
    function governance() external view returns (address);

    /// @notice Returns the address of WETH9
    function WETH9() external view returns (address);

    /// @notice 代币是否受信任
    /// @dev The call will revert if the the token argument is address 0.
    /// @param token 要查询的代币地址
    function verifiedToken(address token) external view returns (bool);

    /// @notice harvest时交易路径
    /// @param token 要兑换的代币
    function harvestPath(address token) external view returns (bytes memory);
}

// File: contracts/interfaces/controller/IControllerEvents.sol
/// @title HotPotV2Controller 事件接口定义
interface IControllerEvents {
    /// @notice 当设置受信任token时触发
    event ChangeVerifiedToken(address indexed token, bool isVerified);

    /// @notice 当调用Harvest时触发
    event Harvest(address indexed token, uint amount, uint burned);

    /// @notice 当调用setHarvestPath时触发
    event SetHarvestPath(address indexed token, bytes path);

    /// @notice 当调用setGovernance时触发
    event SetGovernance(address indexed account);

    /// @notice 当调用setPath时触发
    event SetPath(address indexed fund, address indexed distToken, bytes path);
}

// File: contracts/interfaces/IHotPotV2FundController.sol
/// @title Hotpot V2 控制合约接口定义.
/// @notice 基金经理和治理均需通过控制合约进行操作.
interface IHotPotV2FundController is IManagerActions, IGovernanceActions, IControllerState, IControllerEvents {
    /// @notice 基金分成全部用于销毁HPT
    /// @dev 任何人都可以调用本函数
    /// @param token 用于销毁时购买HPT的代币类型
    /// @param amount 代币数量
    /// @return burned 销毁数量
    function harvest(address token, uint amount) external returns(uint burned);
}

// File: contracts/interfaces/IMulticall.sol
/// @title Multicall
/// @notice Enables calling multiple methods in a single call to the contract
interface IMulticall {
    /// @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
    /// @param data The encoded function data for each of the calls to make to this contract
    /// @return results The results from each of the calls passed in via data
    /// @dev The `msg.value` should not be trusted for any method callable from multicall.
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}

// File: contracts/base/Multicall.sol
/// @title Multicall
/// @notice Enables calling multiple methods in a single call to the contract
abstract contract Multicall is IMulticall {
    /// @inheritdoc IMulticall
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}

// File: contracts/HotPotV2FundController.sol
// SPDX-License-Identifier: BUSL-1.1

contract HotPotV2FundController is IHotPotV2FundController, Multicall {
    using Path for bytes;

    address public override immutable uniV3Factory;
    address public override immutable uniV3Router;
    address public override immutable hotpot;
    address public override governance;
    address public override immutable WETH9;

    mapping (address => bool) public override verifiedToken;
    mapping (address => bytes) public override harvestPath;

    modifier onlyManager(address fund){
        require(msg.sender == IHotPotV2Fund(fund).manager(), "OMC");
        _;
    }

    modifier onlyGovernance{
        require(msg.sender == governance, "OGC");
        _;
    }

    constructor(
        address _hotpot,
        address _governance,
        address _uniV3Router,
        address _uniV3Factory,
        address _weth9
    ) {
        hotpot = _hotpot;
        governance = _governance;
        uniV3Router = _uniV3Router;
        uniV3Factory = _uniV3Factory;
        WETH9 = _weth9;
    }

    /// @inheritdoc IGovernanceActions
    function setHarvestPath(address token, bytes memory path) external override onlyGovernance {
        bytes memory _path = path;
        (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
        while (true) {
            // pool is exist
            require(IUniswapV3Factory(uniV3Factory).getPool(tokenIn, tokenOut, fee) != address(0), "PIE");
            if (path.hasMultiplePools()) {
                path = path.skipToken();
                (tokenIn, tokenOut, fee) = path.decodeFirstPool();
            } else {
                //最后一个交易对：输入WETH9, 输出hotpot
                require(tokenIn == WETH9 && tokenOut == hotpot, "IOT");
                break;
            }
        }
        harvestPath[token] = _path;
        emit SetHarvestPath(token, _path);
    }

    /// @inheritdoc IHotPotV2FundController
    function harvest(address token, uint amount) external override returns(uint burned) {
        uint value = amount <= IERC20(token).balanceOf(address(this)) ? amount : IERC20(token).balanceOf(address(this));
        TransferHelper.safeApprove(token, uniV3Router, value);

        ISwapRouter.ExactInputParams memory args = ISwapRouter.ExactInputParams({
            path: harvestPath[token],
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: value,
            amountOutMinimum: 0
        });
        burned = ISwapRouter(uniV3Router).exactInput(args);
        IHotPot(hotpot).burn(burned);
        emit Harvest(token, amount, burned);
    }

    /// @inheritdoc IGovernanceActions
    function setGovernance(address account) external override onlyGovernance {
        require(account != address(0));
        governance = account;
        emit SetGovernance(account);
    }

    /// @inheritdoc IGovernanceActions
    function setVerifiedToken(address token, bool isVerified) external override onlyGovernance {
        verifiedToken[token] = isVerified;
        emit ChangeVerifiedToken(token, isVerified);
    }

    /// @inheritdoc IManagerActions
    function setPath(
        address fund,
        address distToken,
        bytes memory path
    ) external override onlyManager(fund){
        require(verifiedToken[distToken]);

        address fundToken = IHotPotV2Fund(fund).token();
        bytes memory _path = path;
        bytes memory _reverse;
        (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
        _reverse = abi.encodePacked(tokenOut, fee, tokenIn);
        bool isBuy;
        // 第一个tokenIn是基金token，那么就是buy路径
        if(tokenIn == fundToken){
            isBuy = true;
        } 
        // 如果是sellPath, 第一个需要是目标代币
        else{
            require(tokenIn == distToken);
        }

        while (true) {
            require(verifiedToken[tokenIn], "VIT");
            require(verifiedToken[tokenOut], "VOT");
            // pool is exist
            address pool = IUniswapV3Factory(uniV3Factory).getPool(tokenIn, tokenOut, fee);
            require(pool != address(0), "PIE");
            // at least 2 observations
            (,,,uint16 observationCardinality,,,) = IUniswapV3Pool(pool).slot0();
            require(observationCardinality >= 2, "OC");

            if (path.hasMultiplePools()) {
                path = path.skipToken();
                (tokenIn, tokenOut, fee) = path.decodeFirstPool();
                _reverse = abi.encodePacked(tokenOut, fee, _reverse);
            } else {
                /// @dev 如果是buy, 最后一个token要是目标代币;
                /// @dev 如果是sell, 最后一个token要是基金token.
                if(isBuy)
                    require(tokenOut == distToken, "OID");
                else
                    require(tokenOut == fundToken, "OIF");
                break;
            }
        }
        emit SetPath(fund, distToken, _path);
        if(!isBuy) (_path, _reverse) = (_reverse, _path);
        IHotPotV2Fund(fund).setPath(distToken, _path, _reverse);
    }

    /// @inheritdoc IManagerActions
    function init(
        address fund,
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).init(token0, token1, fee, tickLower, tickUpper, amount);
    }

    /// @inheritdoc IManagerActions
    function add(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint amount,
        bool collect
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).add(poolIndex, positionIndex, amount, collect);
    }

    /// @inheritdoc IManagerActions
    function sub(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint proportionX128
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).sub(poolIndex, positionIndex, proportionX128);
    }

    /// @inheritdoc IManagerActions
    function move(
        address fund,
        uint poolIndex,
        uint subIndex,
        uint addIndex,
        uint proportionX128
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).move(poolIndex, subIndex, addIndex, proportionX128);
    }
}