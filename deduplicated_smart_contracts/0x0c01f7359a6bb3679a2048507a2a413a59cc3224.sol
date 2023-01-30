/**

 *Submitted for verification at Etherscan.io on 2019-01-21

*/



pragma solidity 0.4.25;

pragma experimental ABIEncoderV2;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    uint256 c = _a * _b;

    require(c / _a == _b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    require(_b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    require(_b <= _a);

    uint256 c = _a - _b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

    uint256 c = _a + _b;

    require(c >= _a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}



/**

 * @title Math

 * @dev Assorted math operations

 */



library Math {

  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;

  }



  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;

  }



  function average(uint256 a, uint256 b) internal pure returns (uint256) {

    // (a + b) / 2 can overflow, so we distribute

    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);

  }

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

  function totalSupply() public view returns (uint256);



  function balanceOf(address _who) public view returns (uint256);



  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transfer(address _to, uint256 _value) public returns (bool);



  function approve(address _spender, uint256 _value)

    public returns (bool);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function decimals() public view returns (uint256);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



/*

    Modified Util contract as used by Kyber Network

*/



library Utils {



    uint256 constant internal PRECISION = (10**18);

    uint256 constant internal MAX_QTY   = (10**28); // 10B tokens

    uint256 constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH

    uint256 constant internal MAX_DECIMALS = 18;

    uint256 constant internal ETH_DECIMALS = 18;

    uint256 constant internal MAX_UINT = 2**256-1;



    // Currently constants can't be accessed from other contracts, so providing functions to do that here

    function precision() internal pure returns (uint256) { return PRECISION; }

    function max_qty() internal pure returns (uint256) { return MAX_QTY; }

    function max_rate() internal pure returns (uint256) { return MAX_RATE; }

    function max_decimals() internal pure returns (uint256) { return MAX_DECIMALS; }

    function eth_decimals() internal pure returns (uint256) { return ETH_DECIMALS; }

    function max_uint() internal pure returns (uint256) { return MAX_UINT; }



    /// @notice Retrieve the number of decimals used for a given ERC20 token

    /// @dev As decimals are an optional feature in ERC20, this contract uses `call` to

    /// ensure that an exception doesn't cause transaction failure

    /// @param token the token for which we should retrieve the decimals

    /// @return decimals the number of decimals in the given token

    function getDecimals(address token)

        internal

        view

        returns (uint256 decimals)

    {

        bytes4 functionSig = bytes4(keccak256("decimals()"));



        /// @dev Using assembly due to issues with current solidity `address.call()`

        /// implementation: https://github.com/ethereum/solidity/issues/2884

        assembly {

            // Pointer to next free memory slot

            let ptr := mload(0x40)

            // Store functionSig variable at ptr

            mstore(ptr,functionSig)

            let functionSigLength := 0x04

            let wordLength := 0x20



            let success := call(

                                5000, // Amount of gas

                                token, // Address to call

                                0, // ether to send

                                ptr, // ptr to input data

                                functionSigLength, // size of data

                                ptr, // where to store output data (overwrite input)

                                wordLength // size of output data (32 bytes)

                               )



            switch success

            case 0 {

                decimals := 0 // If the token doesn't implement `decimals()`, return 0 as default

            }

            case 1 {

                decimals := mload(ptr) // Set decimals to return data from call

            }

            mstore(0x40,add(ptr,0x04)) // Reset the free memory pointer to the next known free location

        }

    }



    /// @dev Checks that a given address has its token allowance and balance set above the given amount

    /// @param tokenOwner the address which should have custody of the token

    /// @param tokenAddress the address of the token to check

    /// @param tokenAmount the amount of the token which should be set

    /// @param addressToAllow the address which should be allowed to transfer the token

    /// @return bool true if the allowance and balance is set, false if not

    function tokenAllowanceAndBalanceSet(

        address tokenOwner,

        address tokenAddress,

        uint256 tokenAmount,

        address addressToAllow

    )

        internal

        view

        returns (bool)

    {

        return (

            ERC20(tokenAddress).allowance(tokenOwner, addressToAllow) >= tokenAmount &&

            ERC20(tokenAddress).balanceOf(tokenOwner) >= tokenAmount

        );

    }



    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {

        if (dstDecimals >= srcDecimals) {

            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);

            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;

        } else {

            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);

            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));

        }

    }



    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {



        //source quantity is rounded up. to avoid dest quantity being too low.

        uint numerator;

        uint denominator;

        if (srcDecimals >= dstDecimals) {

            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);

            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));

            denominator = rate;

        } else {

            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);

            numerator = (PRECISION * dstQty);

            denominator = (rate * (10**(dstDecimals - srcDecimals)));

        }

        return (numerator + denominator - 1) / denominator; //avoid rounding down errors

    }



    function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns (uint) {

        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);

    }



    function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns (uint) {

        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);

    }



    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)

        internal pure returns (uint)

    {

        require(srcAmount <= MAX_QTY);

        require(destAmount <= MAX_QTY);



        if (dstDecimals >= srcDecimals) {

            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);

            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));

        } else {

            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);

            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);

        }

    }



    /// @notice Bringing this in from the Math library as we've run out of space in TotlePrimary (see EIP-170)

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }

}



library ERC20SafeTransfer {

    function safeTransfer(address _tokenAddress, address _to, uint256 _value) internal returns (bool success) {



        require(_tokenAddress.call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));



        return fetchReturnData();

    }



    function safeTransferFrom(address _tokenAddress, address _from, address _to, uint256 _value) internal returns (bool success) {



        require(_tokenAddress.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value));



        return fetchReturnData();

    }



    function safeApprove(address _tokenAddress, address _spender, uint256 _value) internal returns (bool success) {



        require(_tokenAddress.call(bytes4(keccak256("approve(address,uint256)")), _spender, _value));



        return fetchReturnData();

    }



    function fetchReturnData() internal returns (bool success){

        assembly {

            switch returndatasize()

            case 0 {

                success := 1

            }

            case 32 {

                returndatacopy(0, 0, 32)

                success := mload(0)

            }

            default {

                revert(0, 0)

            }

        }

    }



}



/// @title A contract which is used to check and set allowances of tokens

/// @dev In order to use this contract is must be inherited in the contract which is using

/// its functionality

contract AllowanceSetter {

    uint256 constant MAX_UINT = 2**256 - 1;



    /// @notice A function which allows the caller to approve the max amount of any given token

    /// @dev In order to function correctly, token allowances should not be set anywhere else in

    /// the inheriting contract

    /// @param addressToApprove the address which we want to approve to transfer the token

    /// @param token the token address which we want to call approve on

    function approveAddress(address addressToApprove, address token) internal {

        if(ERC20(token).allowance(address(this), addressToApprove) == 0) {

            require(ERC20SafeTransfer.safeApprove(token, addressToApprove, MAX_UINT));

        }

    }



}



contract ErrorReporter {

    function revertTx(string reason) public pure {

        revert(reason);

    }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;



  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

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

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



/// @title A contract which can be used to ensure only the TotlePrimary contract can call

/// some functions

/// @dev Defines a modifier which should be used when only the totle contract should

/// able able to call a function

contract TotleControl is Ownable {

    mapping(address => bool) public authorizedPrimaries;



    /// @dev A modifier which only allows code execution if msg.sender equals totlePrimary address

    modifier onlyTotle() {

        require(authorizedPrimaries[msg.sender]);

        _;

    }



    /// @notice Contract constructor

    /// @dev As this contract inherits ownable, msg.sender will become the contract owner

    /// @param _totlePrimary the address of the contract to be set as totlePrimary

    constructor(address _totlePrimary) public {

        authorizedPrimaries[_totlePrimary] = true;

    }



    /// @notice A function which allows only the owner to change the address of totlePrimary

    /// @dev onlyOwner modifier only allows the contract owner to run the code

    /// @param _totlePrimary the address of the contract to be set as totlePrimary

    function addTotle(

        address _totlePrimary

    ) external onlyOwner {

        authorizedPrimaries[_totlePrimary] = true;

    }



    function removeTotle(

        address _totlePrimary

    ) external onlyOwner {

        authorizedPrimaries[_totlePrimary] = false;

    }

}



/// @title A contract which allows its owner to withdraw any ether which is contained inside

contract Withdrawable is Ownable {



    /// @notice Withdraw ether contained in this contract and send it back to owner

    /// @dev onlyOwner modifier only allows the contract owner to run the code

    /// @param _token The address of the token that the user wants to withdraw

    /// @param _amount The amount of tokens that the caller wants to withdraw

    /// @return bool value indicating whether the transfer was successful

    function withdrawToken(address _token, uint256 _amount) external onlyOwner returns (bool) {

        return ERC20SafeTransfer.safeTransfer(_token, owner, _amount);

    }



    /// @notice Withdraw ether contained in this contract and send it back to owner

    /// @dev onlyOwner modifier only allows the contract owner to run the code

    /// @param _amount The amount of ether that the caller wants to withdraw

    function withdrawETH(uint256 _amount) external onlyOwner {

        owner.transfer(_amount);

    }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Paused();

  event Unpaused();



  bool private _paused = false;



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns (bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused, "Contract is paused.");

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused, "Contract not paused.");

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyOwner whenNotPaused {

    _paused = true;

    emit Paused();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    _paused = false;

    emit Unpaused();

  }

}



contract SelectorProvider {

    bytes4 constant getAmountToGiveSelector = bytes4(keccak256("getAmountToGive(bytes)"));

    bytes4 constant staticExchangeChecksSelector = bytes4(keccak256("staticExchangeChecks(bytes)"));

    bytes4 constant performBuyOrderSelector = bytes4(keccak256("performBuyOrder(bytes,uint256)"));

    bytes4 constant performSellOrderSelector = bytes4(keccak256("performSellOrder(bytes,uint256)"));



    function getSelector(bytes4 genericSelector) public pure returns (bytes4);

}



/// @title Interface for all exchange handler contracts

contract ExchangeHandler is SelectorProvider, TotleControl, Withdrawable, Pausable {



    /*

    *   State Variables

    */



    ErrorReporter public errorReporter;

    /* Logger public logger; */

    /*

    *   Modifiers

    */



    /// @notice Constructor

    /// @dev Calls the constructor of the inherited TotleControl

    /// @param totlePrimary the address of the totlePrimary contract

    constructor(

        address totlePrimary,

        address _errorReporter

        /* ,address _logger */

    )

        TotleControl(totlePrimary)

        public

    {

        require(_errorReporter != address(0x0));

        /* require(_logger != address(0x0)); */

        errorReporter = ErrorReporter(_errorReporter);

        /* logger = Logger(_logger); */

    }



    /// @notice Gets the amount that Totle needs to give for this order

    /// @param genericPayload the data for this order in a generic format

    /// @return amountToGive amount taker needs to give in order to fill the order

    function getAmountToGive(

        bytes genericPayload

    )

        public

        view

        returns (uint256 amountToGive)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.getAmountToGive.selector);



        assembly {

            let functionSelectorLength := 0x04

            let functionSelectorOffset := 0x1C

            let scratchSpace := 0x0

            let wordLength := 0x20

            let bytesLength := mload(genericPayload)

            let totalLength := add(functionSelectorLength, bytesLength)

            let startOfNewData := add(genericPayload, functionSelectorOffset)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(genericPayload, functionSelectorCorrect)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            wordLength // Length of return variable is one word

                           )

            amountToGive := mload(scratchSpace)

            if eq(success, 0) { revert(0, 0) }

        }

    }



    /// @notice Perform exchange-specific checks on the given order

    /// @dev this should be called to check for payload errors

    /// @param genericPayload the data for this order in a generic format

    /// @return checksPassed value representing pass or fail

    function staticExchangeChecks(

        bytes genericPayload

    )

        public

        view

        returns (bool checksPassed)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.staticExchangeChecks.selector);

        assembly {

            let functionSelectorLength := 0x04

            let functionSelectorOffset := 0x1C

            let scratchSpace := 0x0

            let wordLength := 0x20

            let bytesLength := mload(genericPayload)

            let totalLength := add(functionSelectorLength, bytesLength)

            let startOfNewData := add(genericPayload, functionSelectorOffset)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(genericPayload, functionSelectorCorrect)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            wordLength // Length of return variable is one word

                           )

            checksPassed := mload(scratchSpace)

            if eq(success, 0) { revert(0, 0) }

        }

    }



    /// @notice Perform a buy order at the exchange

    /// @param genericPayload the data for this order in a generic format

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performBuyOrder(

        bytes genericPayload,

        uint256 amountToGiveForOrder

    )

        public

        payable

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.performBuyOrder.selector);

        assembly {

            let callDataOffset := 0x44

            let functionSelectorOffset := 0x1C

            let functionSelectorLength := 0x04

            let scratchSpace := 0x0

            let wordLength := 0x20

            let startOfFreeMemory := mload(0x40)



            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)



            let bytesLength := mload(startOfFreeMemory)

            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)



            let functionSelectorCorrect := mload(scratchSpace)



            mstore(startOfFreeMemory, functionSelectorCorrect)



            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)



            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            mul(wordLength, 0x02) // Length of return variables is two words

                          )

            amountSpentOnOrder := mload(scratchSpace)

            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))

            if eq(success, 0) { revert(0, 0) }

        }

    }



    /// @notice Perform a sell order at the exchange

    /// @param genericPayload the data for this order in a generic format

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performSellOrder(

        bytes genericPayload,

        uint256 amountToGiveForOrder

    )

        public

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        bool success;

        bytes4 functionSelector = getSelector(this.performSellOrder.selector);

        assembly {

            let callDataOffset := 0x44

            let functionSelectorOffset := 0x1C

            let functionSelectorLength := 0x04

            let scratchSpace := 0x0

            let wordLength := 0x20

            let startOfFreeMemory := mload(0x40)



            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)



            let bytesLength := mload(startOfFreeMemory)

            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)



            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)



            let functionSelectorCorrect := mload(scratchSpace)



            mstore(startOfFreeMemory, functionSelectorCorrect)



            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)



            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)



            success := delegatecall(

                            gas,

                            address, // This address of the current contract

                            startOfNewData, // Start data at the beginning of the functionSelector

                            totalLength, // Total length of all data, including functionSelector

                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.

                            mul(wordLength, 0x02) // Length of return variables is two words

                          )

            amountSpentOnOrder := mload(scratchSpace)

            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))

            if eq(success, 0) { revert(0, 0) }

        }

    }

}



interface WeiDex {

    function depositEthers() external payable;

    function withdrawEthers(uint256 amount) external;

    function depositTokens(address token, uint256 amount) external;

    function withdrawTokens(address token, uint256 amount) external;

    function takeBuyOrder(address[3] orderAddresses, uint256[3] orderValues, uint256 takerSellAmount, uint8 v, bytes32 r, bytes32 s) external;

    function takeSellOrder(address[3] orderAddresses, uint256[3] orderValues, uint256 takerSellAmount, uint8 v, bytes32 r, bytes32 s) external;

    function filledAmounts(bytes32 orderHash) external view returns (uint256);

    function feeRate() external view returns (uint256);

    function balances(address token, address user) external view returns (uint256);

}



/// @title WeiDexHandler

/// @notice Handles the all WeiDex trades for the primary contract

contract WeiDexHandler is ExchangeHandler, AllowanceSetter {



    /*

    *   State Variables

    */



    WeiDex public exchange;



    /*

    *   Types

    */



    struct OrderData {

        address[3] addresses; //Creator (maker), maker token address, taker token address. 0x0 for ETH

        uint256[3] values; // Amount of maker tokens, amount of taker tokens, nonce

        uint8 v; //Signature v

        bytes32 r; //Signature r

        bytes32 s; //Signature s

    }



    /// @notice Constructor

    /// @param _exchange Address of the WeiDex exchange

    /// @param totlePrimary the address of the totlePrimary contract

    /// @param errorReporter the address of the error reporter contract

    constructor(

        address _exchange,

        address totlePrimary,

        address errorReporter

        /* ,address logger */

    )

        ExchangeHandler(totlePrimary, errorReporter/*, logger*/)

        public

    {

        require(_exchange != address(0x0));

        exchange = WeiDex(_exchange);

    }



    /*

    *   Public functions

    */



    /// @notice Gets the amount that Totle needs to give for this order

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param order OrderData struct containing order values

    /// @return amountToGive amount taker needs to give in order to fill the order

    function getAmountToGive(

        OrderData order

    )

        public

        view

        onlyTotle

        returns (uint256 amountToGive)

    {

        amountToGive = getAvailableTakerVolume(order);

        /* logger.log("Remaining volume from weiDex", amountToGive); */

    }



    /// @notice Perform exchange-specific checks on the given order

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract.

    /// This should be called to check for payload errors.

    /// @param order OrderData struct containing order values

    /// @return checksPassed value representing pass or fail

    function staticExchangeChecks(

        OrderData order

    )

        public

        view

        onlyTotle

        returns (bool checksPassed)

    {

        bool correctMaker = order.addresses[0] == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", createHash(order))), order.v, order.r, order.s);

        bool hasAvailableVolume = exchange.filledAmounts(createHash(order)) < order.values[1];

        bool oneOfTokensIsEth = order.addresses[1] == address(0x0) || order.addresses[2] == address(0x0);

        return correctMaker && hasAvailableVolume && oneOfTokensIsEth;

    }



    /// @notice Perform a buy order at the exchange

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param order OrderData struct containing order values

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performBuyOrder(

        OrderData order,

        uint256 amountToGiveForOrder

    )

        public

        payable

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        /* logger.log("Depositing eth to weiDex arg2: amountToGiveForOrder, arg3: ethBalance", amountToGiveForOrder, address(this).balance); */

        exchange.depositEthers.value(amountToGiveForOrder)();



        uint256 feeRate = exchange.feeRate();



        exchange.takeSellOrder(order.addresses, order.values, amountToGiveForOrder, order.v, order.r, order.s);



        amountSpentOnOrder = amountToGiveForOrder;

        amountReceivedFromOrder = SafeMath.div(SafeMath.mul(amountToGiveForOrder, order.values[0]), order.values[1]);

        amountReceivedFromOrder = SafeMath.sub(amountReceivedFromOrder, SafeMath.div(amountReceivedFromOrder, feeRate)); //Remove fee

        exchange.withdrawTokens(order.addresses[1], amountReceivedFromOrder);

        if (!ERC20SafeTransfer.safeTransfer(order.addresses[1], msg.sender, amountReceivedFromOrder)) {

            errorReporter.revertTx("Unable to transfer bought tokens to primary");

        }



        /* logger.log("Withdrawing tokens from weiDex arg2: amountReceivedFromOrder, arg3: amountSpentOnOrder", amountReceivedFromOrder, amountSpentOnOrder); */

    }



    /// @notice Perform a sell order at the exchange

    /// @dev Uses the `onlyTotle` modifier with public visibility as this function

    /// should only be called from functions which are inherited from the ExchangeHandler

    /// base contract

    /// @param order OrderData struct containing order values

    /// @param  amountToGiveForOrder amount that should be spent on this order

    /// @return amountSpentOnOrder the amount that would be spent on the order

    /// @return amountReceivedFromOrder the amount that was received from this order

    function performSellOrder(

        OrderData order,

        uint256 amountToGiveForOrder

    )

        public

        onlyTotle

        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)

    {

        approveAddress(address(exchange), order.addresses[2]);

        /* logger.log("Depositing tokens to weiDex arg2: amountToGiveForOrder", amountToGiveForOrder); */

        exchange.depositTokens(order.addresses[2], amountToGiveForOrder);



        uint256 feeRate = exchange.feeRate();

        uint256 amountToGive = SafeMath.div(SafeMath.mul(amountToGiveForOrder, feeRate), SafeMath.add(feeRate,1));



        exchange.takeBuyOrder(order.addresses, order.values, amountToGive, order.v, order.r, order.s);

        amountSpentOnOrder = amountToGiveForOrder;

        amountReceivedFromOrder = SafeMath.div(SafeMath.mul(amountToGive, order.values[0]), order.values[1]);



        /* logger.log("Withdrawing ether from weiDex arg2: amountReceivedFromOrder, arg3: amountSpentOnOrder", amountReceivedFromOrder, amountSpentOnOrder); */



        exchange.withdrawEthers(amountReceivedFromOrder);

        /* logger.log("Withdrawing ether arg2: amountReceived", amountReceivedFromOrder); */

        msg.sender.transfer(amountReceivedFromOrder);

    }



    /**

    * @dev Hashes the order.

    * @param order Order to be hashed.

    * @return hash result

    */

    function createHash(OrderData memory order)

        internal

        view

        returns (bytes32)

    {

        return keccak256(

            abi.encodePacked(

                order.addresses[0],

                order.addresses[1],

                order.values[0],

                order.addresses[2],

                order.values[1],

                order.values[2],

                exchange

            )

        );

    }



    /**

    * @dev Gets available taker volume

    * @param order Order to get the available volume.

    * @return available volume

    */

    function getAvailableTakerVolume(OrderData memory order)

        internal

        view

        returns (uint256)

    {

        uint256 feeRate = exchange.feeRate();

        //Taker volume that's been filled

        uint256 filledTakerAmount = exchange.filledAmounts(createHash(order));

        //Amount of taker volume remaining based on filled amount

        uint256 remainingTakerVolumeFromFilled = SafeMath.sub(order.values[1], filledTakerAmount);

        //The maker's balance of eth

        uint256 remainingTakerVolumeFromMakerBalance;

        if(order.addresses[1]== address(0x0)){

            uint256 makerEthBalance = exchange.balances(address(0x0), order.addresses[0]);

            makerEthBalance = SafeMath.div(SafeMath.mul(makerEthBalance, feeRate), SafeMath.add(feeRate, 1));

            remainingTakerVolumeFromMakerBalance = SafeMath.div(SafeMath.mul(makerEthBalance, order.values[1]), order.values[0]);

        } else {

            uint256 makerTokenBalance = exchange.balances(order.addresses[1], order.addresses[0]);

            remainingTakerVolumeFromMakerBalance = SafeMath.div(SafeMath.mul(makerTokenBalance, order.values[1]), order.values[0]);

        }

        return Math.min(remainingTakerVolumeFromFilled, remainingTakerVolumeFromMakerBalance);

    }



    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {

        if (genericSelector == getAmountToGiveSelector) {

            return bytes4(keccak256("getAmountToGive((address[3],uint256[3],uint8,bytes32,bytes32))"));

        } else if (genericSelector == staticExchangeChecksSelector) {

            return bytes4(keccak256("staticExchangeChecks((address[3],uint256[3],uint8,bytes32,bytes32))"));

        } else if (genericSelector == performBuyOrderSelector) {

            return bytes4(keccak256("performBuyOrder((address[3],uint256[3],uint8,bytes32,bytes32),uint256)"));

        } else if (genericSelector == performSellOrderSelector) {

            return bytes4(keccak256("performSellOrder((address[3],uint256[3],uint8,bytes32,bytes32),uint256)"));

        } else {

            return bytes4(0x0);

        }

    }



    /*

    *   Payable fallback function

    */



    /// @notice payable fallback to allow the exchange to return ether directly to this contract

    /// @dev note that only the exchange should be able to send ether to this contract

    function() public payable {

        if (msg.sender != address(exchange)) {

            errorReporter.revertTx("An address other than the exchange cannot send ether to EDHandler fallback");

        }

    }

}