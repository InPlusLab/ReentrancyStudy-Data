/**

 *Submitted for verification at Etherscan.io on 2019-02-01

*/



pragma solidity ^0.4.24;



// File: Multiownable/contracts/Multiownable.sol



contract Multiownable {



    // VARIABLES



    uint256 public ownersGeneration;

    uint256 public howManyOwnersDecide;

    address[] public owners;

    bytes32[] public allOperations;

    address internal insideCallSender;

    uint256 internal insideCallCount;



    // Reverse lookup tables for owners and allOperations

    mapping(address => uint) public ownersIndices; // Starts from 1

    mapping(bytes32 => uint) public allOperationsIndicies;



    // Owners voting mask per operations

    mapping(bytes32 => uint256) public votesMaskByOperation;

    mapping(bytes32 => uint256) public votesCountByOperation;



    // EVENTS



    event OwnershipTransferred(address[] previousOwners, uint howManyOwnersDecide, address[] newOwners, uint newHowManyOwnersDecide);

    event OperationCreated(bytes32 operation, uint howMany, uint ownersCount, address proposer);

    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint ownersCount, address upvoter);

    event OperationPerformed(bytes32 operation, uint howMany, uint ownersCount, address performer);

    event OperationDownvoted(bytes32 operation, uint votes, uint ownersCount,  address downvoter);

    event OperationCancelled(bytes32 operation, address lastCanceller);

    

    // ACCESSORS



    function isOwner(address wallet) public constant returns(bool) {

        return ownersIndices[wallet] > 0;

    }



    function ownersCount() public constant returns(uint) {

        return owners.length;

    }



    function allOperationsCount() public constant returns(uint) {

        return allOperations.length;

    }



    // MODIFIERS



    /**

    * @dev Allows to perform method by any of the owners

    */

    modifier onlyAnyOwner {

        if (checkHowManyOwners(1)) {

            bool update = (insideCallSender == address(0));

            if (update) {

                insideCallSender = msg.sender;

                insideCallCount = 1;

            }

            _;

            if (update) {

                insideCallSender = address(0);

                insideCallCount = 0;

            }

        }

    }



    /**

    * @dev Allows to perform method only after many owners call it with the same arguments

    */

    modifier onlyManyOwners {

        if (checkHowManyOwners(howManyOwnersDecide)) {

            bool update = (insideCallSender == address(0));

            if (update) {

                insideCallSender = msg.sender;

                insideCallCount = howManyOwnersDecide;

            }

            _;

            if (update) {

                insideCallSender = address(0);

                insideCallCount = 0;

            }

        }

    }



    /**

    * @dev Allows to perform method only after all owners call it with the same arguments

    */

    modifier onlyAllOwners {

        if (checkHowManyOwners(owners.length)) {

            bool update = (insideCallSender == address(0));

            if (update) {

                insideCallSender = msg.sender;

                insideCallCount = owners.length;

            }

            _;

            if (update) {

                insideCallSender = address(0);

                insideCallCount = 0;

            }

        }

    }



    /**

    * @dev Allows to perform method only after some owners call it with the same arguments

    */

    modifier onlySomeOwners(uint howMany) {

        require(howMany > 0, "onlySomeOwners: howMany argument is zero");

        require(howMany <= owners.length, "onlySomeOwners: howMany argument exceeds the number of owners");

        

        if (checkHowManyOwners(howMany)) {

            bool update = (insideCallSender == address(0));

            if (update) {

                insideCallSender = msg.sender;

                insideCallCount = howMany;

            }

            _;

            if (update) {

                insideCallSender = address(0);

                insideCallCount = 0;

            }

        }

    }



    // CONSTRUCTOR



    constructor() public {

        owners.push(msg.sender);

        ownersIndices[msg.sender] = 1;

        howManyOwnersDecide = 1;

    }



    // INTERNAL METHODS



    /**

     * @dev onlyManyOwners modifier helper

     */

    function checkHowManyOwners(uint howMany) internal returns(bool) {

        if (insideCallSender == msg.sender) {

            require(howMany <= insideCallCount, "checkHowManyOwners: nested owners modifier check require more owners");

            return true;

        }



        uint ownerIndex = ownersIndices[msg.sender] - 1;

        require(ownerIndex < owners.length, "checkHowManyOwners: msg.sender is not an owner");

        bytes32 operation = keccak256(msg.data, ownersGeneration);



        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) == 0, "checkHowManyOwners: owner already voted for the operation");

        votesMaskByOperation[operation] |= (2 ** ownerIndex);

        uint operationVotesCount = votesCountByOperation[operation] + 1;

        votesCountByOperation[operation] = operationVotesCount;

        if (operationVotesCount == 1) {

            allOperationsIndicies[operation] = allOperations.length;

            allOperations.push(operation);

            emit OperationCreated(operation, howMany, owners.length, msg.sender);

        }

        emit OperationUpvoted(operation, operationVotesCount, howMany, owners.length, msg.sender);



        // If enough owners confirmed the same operation

        if (votesCountByOperation[operation] == howMany) {

            deleteOperation(operation);

            emit OperationPerformed(operation, howMany, owners.length, msg.sender);

            return true;

        }



        return false;

    }



    /**

    * @dev Used to delete cancelled or performed operation

    * @param operation defines which operation to delete

    */

    function deleteOperation(bytes32 operation) internal {

        uint index = allOperationsIndicies[operation];

        if (index < allOperations.length - 1) { // Not last

            allOperations[index] = allOperations[allOperations.length - 1];

            allOperationsIndicies[allOperations[index]] = index;

        }

        allOperations.length--;



        delete votesMaskByOperation[operation];

        delete votesCountByOperation[operation];

        delete allOperationsIndicies[operation];

    }



    // PUBLIC METHODS



    /**

    * @dev Allows owners to change their mind by cacnelling votesMaskByOperation operations

    * @param operation defines which operation to delete

    */

    function cancelPending(bytes32 operation) public onlyAnyOwner {

        uint ownerIndex = ownersIndices[msg.sender] - 1;

        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) != 0, "cancelPending: operation not found for this user");

        votesMaskByOperation[operation] &= ~(2 ** ownerIndex);

        uint operationVotesCount = votesCountByOperation[operation] - 1;

        votesCountByOperation[operation] = operationVotesCount;

        emit OperationDownvoted(operation, operationVotesCount, owners.length, msg.sender);

        if (operationVotesCount == 0) {

            deleteOperation(operation);

            emit OperationCancelled(operation, msg.sender);

        }

    }



    /**

    * @dev Allows owners to change ownership

    * @param newOwners defines array of addresses of new owners

    */

    function transferOwnership(address[] newOwners) public {

        transferOwnershipWithHowMany(newOwners, newOwners.length);

    }



    /**

    * @dev Allows owners to change ownership

    * @param newOwners defines array of addresses of new owners

    * @param newHowManyOwnersDecide defines how many owners can decide

    */

    function transferOwnershipWithHowMany(address[] newOwners, uint256 newHowManyOwnersDecide) public onlyManyOwners {

        require(newOwners.length > 0, "transferOwnershipWithHowMany: owners array is empty");

        require(newOwners.length <= 256, "transferOwnershipWithHowMany: owners count is greater then 256");

        require(newHowManyOwnersDecide > 0, "transferOwnershipWithHowMany: newHowManyOwnersDecide equal to 0");

        require(newHowManyOwnersDecide <= newOwners.length, "transferOwnershipWithHowMany: newHowManyOwnersDecide exceeds the number of owners");



        // Reset owners reverse lookup table

        for (uint j = 0; j < owners.length; j++) {

            delete ownersIndices[owners[j]];

        }

        for (uint i = 0; i < newOwners.length; i++) {

            require(newOwners[i] != address(0), "transferOwnershipWithHowMany: owners array contains zero");

            require(ownersIndices[newOwners[i]] == 0, "transferOwnershipWithHowMany: owners array contains duplicates");

            ownersIndices[newOwners[i]] = i + 1;

        }

        

        emit OwnershipTransferred(owners, howManyOwnersDecide, newOwners, newHowManyOwnersDecide);

        owners = newOwners;

        howManyOwnersDecide = newHowManyOwnersDecide;

        allOperations.length = 0;

        ownersGeneration++;

    }



}



// File: zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



// File: zeppelin-solidity/contracts/ownership/Ownable.sol



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



// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: contracts/BadERC20Aware.sol



library BadERC20Aware {

    using SafeMath for uint;



    function isContract(address addr) internal view returns(bool result) {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            result := gt(extcodesize(addr), 0)

        }

    }



    function handleReturnBool() internal pure returns(bool result) {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            switch returndatasize()

            case 0 { // not a std erc20

                result := 1

            }

            case 32 { // std erc20

                returndatacopy(0, 0, 32)

                result := mload(0)

            }

            default { // anything else, should revert for safety

                revert(0, 0)

            }

        }

    }



    function asmTransfer(ERC20 _token, address _to, uint256 _value) internal returns(bool) {

        require(isContract(_token));

        // solium-disable-next-line security/no-low-level-calls

        require(address(_token).call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));

        return handleReturnBool();

    }



    function safeTransfer(ERC20 _token, address _to, uint256 _value) internal {

        require(asmTransfer(_token, _to, _value));

    }

}



// File: contracts/TokenSwap.sol



/**

 * @title TokenSwap

 * This product is protected under license.  Any unauthorized copy, modification, or use without

 * express written consent from the creators is prohibited.

 */















contract TokenSwap is Ownable, Multiownable {



    // LIBRARIES



    using BadERC20Aware for ERC20;

    using SafeMath for uint256;



    // TYPES



    enum Status {AddParties, WaitingDeposits, SwapConfirmed, SwapCanceled}



    struct SwapOffer {

        address participant;

        ERC20 token;



        uint256 tokensTotal;

        uint256 withdrawnTokensTotal;

    }



    struct LockupStage {

        uint256 secondsSinceLockupStart;

        uint8 unlockedTokensPercentage;

    }



    // VARIABLES

    Status public status = Status.AddParties;



    address[] internal participants;

    mapping(address => bool) internal isParticipant;

    mapping(address => address) internal tokenByParticipant;

    mapping(address => SwapOffer) internal offerByToken;



    uint256 internal startLockupAt;

    mapping(address => LockupStage[]) internal lockupStagesByToken;



    address[] internal receivers;

    mapping(address => bool) internal isReceiver;

    mapping(address => bool) internal isTokenAllocated;

    mapping(address => mapping(address => uint256)) internal allocatedTokens;

    mapping(address => mapping(address => uint256)) internal withdrawnTokens;



    // EVENTS

    event StatusUpdate(Status oldStatus, Status newStatus);

    event AddParty(address participant, ERC20 token, uint256 tokensTotal);

    event AddTokenAllocation(ERC20 token, address receiver, uint256 amount);

    event AddLockupStage(

        ERC20 token,

        uint256 secondsSinceLockupStart,

        uint8 unlockedTokensPercentage

    );

    event ConfirmParties();

    event CancelSwap();

    event ConfirmSwap();

    event StartLockup(uint256 startLockupAt);

    event Withdraw(address participant, ERC20 token, uint256 amount);

    event WithdrawFee(ERC20 token, uint256 amount);

    event Reclaim(address participant, ERC20 token, uint256 amount);

    event SoftEmergency(ERC20 token, address receiver, uint256 amount);

    event HardEmergency(ERC20 token, address receiver, uint256 amount);



    // MODIFIERS

    modifier onlyParticipant {

        require(

            isParticipant[msg.sender] == true,

            "Only swap participants allowed to call the method"

        );

        _;

    }



    modifier onlyReceiver {

        require(

            isReceiver[msg.sender] == true,

            "Only token receivers allowed to call the method"

        );

       _;

    }



    modifier canTransferOwnership {

        require(status == Status.AddParties, "Unable to transfer ownership in the current status");

        _;

    }



    modifier canAddParty {

        require(status == Status.AddParties, "Unable to add new parties in the current status");

        _;

    }



    modifier canAddLockupPeriod {

        require(status == Status.AddParties, "Unable to add lockup period in the current status");

        _;

    }



    modifier canAddTokenAllocation {

        require(

            status == Status.AddParties,

            "Unable to add token allocation in the current status"

        );

        _;

    }



    modifier canConfirmParties {

        require(

            status == Status.AddParties,

            "Unable to confirm parties in the current status"

        );

        require(participants.length > 1, "Need at least two participants");

        require(_doesEveryTokenHaveLockupPeriod(), "Each token must have lockup period");

        require(_isEveryTokenFullyAllocated(), "Each token must be fully allocated");

        _;

    }



    modifier canCancelSwap {

        require(

            status == Status.WaitingDeposits,

            "Unable to cancel swap in the current status"

        );

        _;

    }



    modifier canConfirmSwap {

        require(status == Status.WaitingDeposits, "Unable to confirm in the current status");

        require(

            _haveEveryoneDeposited(),

            "Unable to confirm swap before all parties have deposited tokens"

        );

        _;

    }



    modifier canWithdraw {

        require(status == Status.SwapConfirmed, "Unable to withdraw tokens in the current status");

        require(startLockupAt != 0, "Lockup has not been started");

        _;

    }



    modifier canReclaim {

        require(

            status == Status.SwapConfirmed || status == Status.SwapCanceled,

            "Unable to reclaim in the current status"

        );

        _;

    }



    // EXTERNAL METHODS

    /**

     * @dev Add new party to the swap.

     * @param _participant Address of the participant.

     * @param _token An ERC20-compliant token which participant is offering to swap.

     * @param _tokensTotal How much tokens the participant is offering.

     */

    function addParty(

        address _participant,

        ERC20 _token,

        uint256 _tokensTotal

    )

        external

        onlyOwner

        canAddParty

    {

        require(_participant != address(0), "_participant is invalid address");

        require(_token != address(0), "_token is invalid address");

        require(_tokensTotal > 0, "Positive amount of tokens is required");

        require(

            isParticipant[_participant] == false,

            "Unable to add the same party multiple times"

        );



        isParticipant[_participant] = true;

        SwapOffer memory offer = SwapOffer({

            participant: _participant,

            token: _token,

            tokensTotal: _tokensTotal,

            withdrawnTokensTotal: 0

        });

        participants.push(offer.participant);

        offerByToken[offer.token] = offer;

        tokenByParticipant[offer.participant] = offer.token;



        emit AddParty(offer.participant, offer.token, offer.tokensTotal);

    }



    /**

     * @dev Add lockup period stages for one of the tokens.

     * @param _token A token previously added via addParty.

     * @param _secondsSinceLockupStart Array of starts of the stages of the lockup period.

     * @param _unlockedTokensPercentages Array of percentages of the unlocked tokens.

     */

    function addLockupPeriod(

        ERC20 _token,

        uint256[] _secondsSinceLockupStart,

        uint8[] _unlockedTokensPercentages

    )

        external

        onlyOwner

        canAddLockupPeriod

    {

        require(_token != address(0), "Invalid token");

        require(

            _secondsSinceLockupStart.length == _unlockedTokensPercentages.length,

            "Invalid lockup period"

        );

        require(

            lockupStagesByToken[_token].length == 0,

            "Lockup period for this token has been added already"

        );

        require(

            offerByToken[_token].token != address(0),

            "There is no swap offer with this token"

        );



        for (uint256 i = 0; i < _secondsSinceLockupStart.length; i++) {

            LockupStage memory stage = LockupStage(

                _secondsSinceLockupStart[i], _unlockedTokensPercentages[i]

            );

            lockupStagesByToken[_token].push(stage);



            emit AddLockupStage(

                _token, stage.secondsSinceLockupStart, stage.unlockedTokensPercentage

            );

        }



        _validateLockupStages(_token);

    }



    /**

     * @dev Add token allocation.

     * @param _token A token previously added via addParty.

     * @param _receivers Who receives tokens.

     * @param _amounts How much tokens will each receiver get.

     */

    function addTokenAllocation(

        ERC20 _token,

        address[] _receivers,

        uint256[] _amounts

    )

        external

        onlyOwner

        canAddTokenAllocation

    {

        require(_token != address(0), "Invalid token");

        require(_receivers.length == _amounts.length, "Invalid arguments' lengths");

        require(offerByToken[_token].token != address(0), "There is no swap offer with this token");

        require(!isTokenAllocated[_token], "Token has been allocated already");



        uint256 totalAllocation = 0;

        uint256 i;



        for (i = 0; i < _receivers.length; i++) {

            require(_receivers[i] != address(0), "Invalid receiver");

            require(_amounts[i] > 0, "Positive amount is required");

            require(

                allocatedTokens[_token][_receivers[i]] == 0,

                "Tokens for this receiver have been allocated already"

            );



            if (!isReceiver[_receivers[i]]) {

                receivers.push(_receivers[i]);

                isReceiver[_receivers[i]] = true;

            }



            allocatedTokens[_token][_receivers[i]] = _amounts[i];

            totalAllocation = totalAllocation.add(_amounts[i]);



            emit AddTokenAllocation(_token, _receivers[i], _amounts[i]);

        }



        require(totalAllocation == offerByToken[_token].tokensTotal, "Invalid allocation");

        require(isReceiver[owner], "Swap fee hasn't been allocated");



        for (i = 0; i < participants.length; i++) {

            if (tokenByParticipant[participants[i]] == address(_token)) {

                continue;

            }

            require(isReceiver[participants[i]], "Tokens for a participant haven't been allocated");

        }



        isTokenAllocated[_token] = true;

    }



    /**

     * @dev Confirm swap parties

     */

    function confirmParties() external onlyOwner canConfirmParties {

        address[] memory newOwners = new address[](participants.length + 1);



        for (uint256 i = 0; i < participants.length; i++) {

            newOwners[i] = participants[i];

        }



        newOwners[newOwners.length - 1] = owner;

        transferOwnershipWithHowMany(newOwners, newOwners.length - 1);

        _changeStatus(Status.WaitingDeposits);

        emit ConfirmParties();

    }



    /**

     * @dev Confirm swap.

     */

    function confirmSwap() external canConfirmSwap onlyManyOwners {

        emit ConfirmSwap();

        _changeStatus(Status.SwapConfirmed);

        _startLockup();

    }



    /**

     * @dev Cancel swap.

     */

    function cancelSwap() external canCancelSwap onlyManyOwners {

        emit CancelSwap();

        _changeStatus(Status.SwapCanceled);

    }



    /**

     * @dev Withdraw tokens

     */

    function withdraw() external onlyReceiver canWithdraw {

        for (uint i = 0; i < participants.length; i++) {

            address token = tokenByParticipant[participants[i]];

            SwapOffer storage offer = offerByToken[token];



            if (offer.participant == msg.sender) {

                continue;

            }



            uint256 tokensAmount = _withdrawableAmount(offer.token, msg.sender);



            if (tokensAmount > 0) {

                withdrawnTokens[offer.token][msg.sender] =

                    withdrawnTokens[offer.token][msg.sender].add(tokensAmount);

                offer.withdrawnTokensTotal = offer.withdrawnTokensTotal.add(tokensAmount);

                offer.token.safeTransfer(msg.sender, tokensAmount);

                emit Withdraw(msg.sender, offer.token, tokensAmount);

            }

        }

    }



    /**

     * @dev Reclaim tokens if a participant has deposited too much or if the swap has been canceled.

     */

    function reclaim() external onlyParticipant canReclaim {

        address token = tokenByParticipant[msg.sender];



        SwapOffer storage offer = offerByToken[token];

        uint256 currentBalance = offer.token.balanceOf(address(this));

        uint256 availableForReclaim = currentBalance;



        if (status != Status.SwapCanceled) {

            uint256 lockedTokens = offer.tokensTotal.sub(offer.withdrawnTokensTotal);

            availableForReclaim = currentBalance.sub(lockedTokens);

        }



        if (availableForReclaim > 0) {

            offer.token.safeTransfer(offer.participant, availableForReclaim);

        }



        emit Reclaim(offer.participant, offer.token, availableForReclaim);

    }



    /**

     * @dev Transfer tokens back to owners.

     */

    function softEmergency() external onlyOwner {

        for (uint i = 0; i < participants.length; i++) {

            address token = tokenByParticipant[participants[i]];

            SwapOffer storage offer = offerByToken[token];

            uint256 tokensAmount = offer.token.balanceOf(address(this));



            require(offer.withdrawnTokensTotal == 0, "Unavailable after the first withdrawal.");



            if (tokensAmount > 0) {

                offer.token.safeTransfer(offer.participant, tokensAmount);

                emit SoftEmergency(offer.token, offer.participant, tokensAmount);

            }

        }

    }



    /**

     * @dev A way out if nothing else is working.

     */

    function hardEmergency(

        ERC20[] _tokens,

        address[] _receivers,

        uint256[] _values

    )

        external

        onlyAllOwners

    {

        require(_tokens.length == _receivers.length, "Invalid lengths.");

        require(_receivers.length == _values.length, "Invalid lengths.");



        for (uint256 i = 0; i < _tokens.length; i++) {

            _tokens[i].safeTransfer(_receivers[i], _values[i]);

            emit HardEmergency(_tokens[i], _receivers[i], _values[i]);

        }

    }



    // PUBLIC METHODS

    /**

     * @dev Standard ERC223 function that will handle incoming token transfers.

     *

     * @param _from  Token sender address.

     * @param _value Amount of tokens.

     * @param _data  Transaction metadata.

     */

    function tokenFallback(address _from, uint256 _value, bytes _data) public {



    }



    /**

     * @dev Transfer ownership.

     * @param _newOwner Address of the new owner.

     */

    function transferOwnership(address _newOwner) public onlyOwner canTransferOwnership {

        require(_newOwner != address(0), "_newOwner is invalid address");

        require(owners.length == 1, "Unable to transfer ownership in presence of multiowners");

        require(owners[0] == owner, "Unexpected multiowners state");



        address[] memory newOwners = new address[](1);

        newOwners[0] = _newOwner;



        Ownable.transferOwnership(_newOwner);

        Multiownable.transferOwnership(newOwners);

    }



    // INTERNAL METHODS

    /**

     * @dev Validate lock-up period configuration.

     */

    function _validateLockupStages(ERC20 _token) internal view {

        LockupStage[] storage lockupStages = lockupStagesByToken[_token];



        for (uint i = 0; i < lockupStages.length; i++) {

            LockupStage memory stage = lockupStages[i];



            require(

                stage.unlockedTokensPercentage >= 0,

                "LockupStage.unlockedTokensPercentage must not be negative"

            );

            require(

                stage.unlockedTokensPercentage <= 100,

                "LockupStage.unlockedTokensPercentage must not be greater than 100"

            );



            if (i == 0) {

                continue;

            }



            LockupStage memory previousStage = lockupStages[i - 1];

            require(

                stage.secondsSinceLockupStart > previousStage.secondsSinceLockupStart,

                "LockupStage.secondsSinceLockupStart must increase monotonically"

            );

            require(

                stage.unlockedTokensPercentage > previousStage.unlockedTokensPercentage,

                "LockupStage.unlockedTokensPercentage must increase monotonically"

            );

        }



        require(

            lockupStages[lockupStages.length - 1].unlockedTokensPercentage == 100,

            "The last lockup stage must unlock 100% of tokens"

        );

    }



    /**

     * @dev Change swap status.

     */

    function _changeStatus(Status _newStatus) internal {

        emit StatusUpdate(status, _newStatus);

        status = _newStatus;

    }



    /**

     * @dev Check if every token has lockup period.

     */

    function _doesEveryTokenHaveLockupPeriod() internal view returns(bool) {

        for (uint256 i = 0; i < participants.length; i++) {

            address token = tokenByParticipant[participants[i]];



            if (lockupStagesByToken[token].length == 0) {

                return false;

            }

        }



        return true;

    }



    /**

     * @dev Check if every token has been fully allocated.

     */

    function _isEveryTokenFullyAllocated() internal view returns(bool) {

        for (uint256 i = 0; i < participants.length; i++) {

            if (!isTokenAllocated[tokenByParticipant[participants[i]]]) {

                return false;

            }

        }

        return true;

    }



    /**

     * @dev Check whether every participant has deposited enough tokens for the swap to be confirmed.

     */

    function _haveEveryoneDeposited() internal view returns(bool) {

        for (uint i = 0; i < participants.length; i++) {

            address token = tokenByParticipant[participants[i]];

            SwapOffer memory offer = offerByToken[token];



            if (offer.token.balanceOf(address(this)) < offer.tokensTotal) {

                return false;

            }

        }



        return true;

    }



    /**

     * @dev Start lockup period

     */

    function _startLockup() internal {

        startLockupAt = now;

        emit StartLockup(startLockupAt);

    }



    /**

     * @dev Find amount of tokens ready to be withdrawn.

     */

    function _withdrawableAmount(

        ERC20 _token,

        address _receiver

    )

        internal

        view

        returns(uint256)

    {

        uint256 allocated = allocatedTokens[_token][_receiver];

        uint256 withdrawn = withdrawnTokens[_token][_receiver];

        uint256 unlockedPercentage = _getUnlockedTokensPercentage(_token);

        uint256 unlockedAmount = allocated.mul(unlockedPercentage).div(100);



        return unlockedAmount.sub(withdrawn);

    }



    /**

     * @dev Get percent of unlocked tokens

     */

    function _getUnlockedTokensPercentage(ERC20 _token) internal view returns(uint256) {

        for (uint256 i = lockupStagesByToken[_token].length; i > 0; i--) {

            LockupStage storage stage = lockupStagesByToken[_token][i - 1];

            uint256 stageBecomesActiveAt = startLockupAt.add(stage.secondsSinceLockupStart);



            if (now < stageBecomesActiveAt) {

                continue;

            }



            return stage.unlockedTokensPercentage;

        }

    }

}