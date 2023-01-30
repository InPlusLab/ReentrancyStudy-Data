/**

 *Submitted for verification at Etherscan.io on 2019-02-07

*/



pragma solidity 0.4.25;



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



/// @title ARXToken Contract

/// @dev It is ERC20 compliant, but still needs to under go further testing.



contract Ownable {

    address public owner;

    mapping(address => bool) ewContracts;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () public {

        owner = msg.sender;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    modifier onlyEWContracts() {

        require(isEWContract(msg.sender));

        _;

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param _newOwner The address to transfer ownership to.

     */

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0));

        owner = _newOwner;

        emit OwnershipTransferred(owner, _newOwner);

    }



    function addEWContract(address _ewContract) external onlyOwner {

        require(_ewContract != address(0));

        ewContracts[_ewContract] = true;

    }



    function delEWContract(address _ewContract) external onlyOwner {

        require(ewContracts[_ewContract]);

        ewContracts[_ewContract] = false;

    }



    function isEWContract(address _ewContract) public view returns (bool) {

        return ewContracts[_ewContract];

    }

}



contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) external;

}



/// @dev The actual token contract, the default owner is the msg.sender

contract ETWINToken is Ownable {



    string public name;                //The Token's name: e.g. DigixDAO Tokens

    uint8 public decimals;             //Number of decimals of the smallest unit

    string public symbol;              //An identifier: e.g. REP



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

    ETWINToken public parentToken;



    // `parentSnapShotBlock` is the block number from the Parent Token that was

    //  used to determine the initial distribution of the Clone Token

    uint public parentSnapShotBlock;



    // `creationBlock` is the block number that the Clone Token was created

    uint public creationBlock;



    // `balances` is the map that tracks the balance of each address, in this

    //  contract when the balance changes the block number that the change

    //  occurred is also included in the map

    mapping (address => Checkpoint[]) balances;



    // `allowed` tracks any extra transfer rights as in all ERC20 tokens

    mapping (address => mapping (address => uint256)) allowed;



    // Tracks the history of the `totalSupply` of the token

    Checkpoint[] totalSupplyHistory;



    ////////////////

    // Events

    ////////////////

    event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);



    ////////////////

    // Constructor

    ////////////////



    /// @param _parentToken Address of the parent token, set to 0x0 if it is a

    ///  new token

    /// @param _parentSnapShotBlock Block of the parent token that will

    ///  determine the initial distribution of the clone token, set to 0 if it

    ///  is a new token

    constructor (address _parentToken, uint _parentSnapShotBlock) public {

        name = "ETHERWIN";

        symbol = "ETWIN";

        decimals = 18;

        parentToken = ETWINToken(_parentToken);

        parentSnapShotBlock = _parentSnapShotBlock == 0 ? block.number : _parentSnapShotBlock;

        creationBlock = block.number;



        //initial emission

        uint _amount = 10000000 * (10 ** uint256(decimals));

        updateValueAtNow(totalSupplyHistory, _amount);

        updateValueAtNow(balances[msg.sender], _amount);

        emit Transfer(0, msg.sender, _amount);

    }





    ///////////////////

    // ERC20 Methods

    ///////////////////



    /// @notice Send `_amount` tokens to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _amount) external returns (bool success) {

        doTransfer(msg.sender, _to, _amount);

        return true;

    }



    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it

    ///  is approved by `_from`

    /// @param _from The address holding the tokens being transferred

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return True if the transfer was successful

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success) {

        // The standard ERC 20 transferFrom functionality

        require(allowed[_from][msg.sender] >= _amount);

        allowed[_from][msg.sender] -= _amount;

        doTransfer(_from, _to, _amount);

        return true;

    }



    /// @dev This is the actual transfer function in the token contract, it can

    ///  only be called by other functions in this contract.

    /// @param _from The address holding the tokens being transferred

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be transferred

    /// @return True if the transfer was successful

    function doTransfer(address _from, address _to, uint _amount) internal {



        if (_amount == 0) {

            emit Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0

            return;

        }



        require(parentSnapShotBlock < block.number);



        // Do not allow transfer to 0x0 or the token contract itself

        require((_to != 0) && (_to != address(this)));



        // If the amount being transfered is more than the balance of the

        //  account the transfer throws

        uint previousBalanceFrom = balanceOfAt(_from, block.number);



        require(previousBalanceFrom >= _amount);



        // First update the balance array with the new value for the address

        //  sending the tokens

        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);



        // Then update the balance array with the new value for the address

        //  receiving the tokens

        uint previousBalanceTo = balanceOfAt(_to, block.number);

        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow

        updateValueAtNow(balances[_to], previousBalanceTo + _amount);



        // An event to make the transfer easy to find on the blockchain

        emit Transfer(_from, _to, _amount);



    }



    /// @param _owner The address that's balance is being requested

    /// @return The balance of `_owner` at the current block

    function balanceOf(address _owner) external view returns (uint256 balance) {

        return balanceOfAt(_owner, block.number);

    }



    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on

    ///  its behalf. This is a modified version of the ERC20 approve function

    ///  to be a little bit safer

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _amount The amount of tokens to be approved for transfer

    /// @return True if the approval was successful

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        // To change the approve amount you first have to reduce the addresses`

        //  allowance to zero by calling `approve(_spender,0)` if it is not

        //  already 0 to mitigate the race condition described here:

        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));



        allowed[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     *

     * approve should be called when allowance[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _addedAmount The amount of tokens to increase the allowance by.

     */

    function increaseApproval(address _spender, uint _addedAmount) external returns (bool) {

        require(allowed[msg.sender][_spender] + _addedAmount >= allowed[msg.sender][_spender]); // Check for overflow

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _addedAmount;

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     *

     * approve should be called when allowance[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _subtractedAmount The amount of tokens to decrease the allowance by.

     */

    function decreaseApproval(address _spender, uint _subtractedAmount) external returns (bool)

    {

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedAmount >= oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue - _subtractedAmount;

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }





    /// @dev This function makes it easy to read the `allowed[]` map

    /// @param _owner The address of the account that owns the token

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens of _owner that _spender is allowed

    ///  to spend

    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on

    ///  its behalf, and then a function is triggered in the contract that is

    ///  being approved, `_spender`. This allows users to use their tokens to

    ///  interact with contracts in one function call instead of two

    /// @param _spender The address of the contract able to transfer the tokens

    /// @param _amount The amount of tokens to be approved for transfer

    /// @return True if the function call was successful

    function approveAndCall(address _spender, uint256 _amount, bytes _extraData) external returns (bool success) {

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

    function totalSupply() external view returns (uint) {

        return totalSupplyAt(block.number);

    }





    ////////////////

    // Query balance and totalSupply in History

    ////////////////



    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`

    /// @param _owner The address from which the balance will be retrieved

    /// @param _blockNumber The block number when the balance is queried

    /// @return The balance at `_blockNumber`

    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint) {



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

    function totalSupplyAt(uint _blockNumber) public view returns(uint) {



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

    // Internal helper functions to query and set a value in a snapshot array

    ////////////////



    /// @dev `getValueAt` retrieves the number of tokens at a given block number

    /// @param checkpoints The history of values being queried

    /// @param _block The block number to retrieve the value at

    /// @return The number of tokens being queried

    function getValueAt(Checkpoint[] storage checkpoints, uint _block) view internal returns (uint) {

        if (checkpoints.length == 0) return 0;



        // Shortcut for the actual value

        if (_block >= checkpoints[checkpoints.length-1].fromBlock)

            return checkpoints[checkpoints.length-1].value;

        if (_block < checkpoints[0].fromBlock) return 0;



        // Binary search of the value in the array

        uint min = 0;

        uint max = checkpoints.length-1;

        while (max > min) {

            uint mid = (max + min + 1)/ 2;

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

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal  {

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





    /// @dev Helper function to return a min betwen the two uints

    function min(uint a, uint b) pure internal returns (uint) {

        return a < b ? a : b;

    }



    /// @notice The fallback function

    function () public {}



    //////////

    // Safety Methods

    //////////



    /// @notice This method can be used by the owner to extract mistakenly

    ///  sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///  set to 0 in case you want to extract ether.

    function claimTokens(address _token) external onlyOwner {

        if (_token == 0x0) {

            owner.transfer(address(this).balance);

            return;

        }



        ETWINToken token = ETWINToken(_token);

        uint balance = token.balanceOf(this);

        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);

    }

}





contract ETWinDividendManager is Ownable {

    using SafeMath for uint;



    event DividendDeposited(address indexed _depositor, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);

    event DividendClaimed(address indexed _claimer, uint256 _dividendIndex, uint256 _claim);

    event DividendRecycled(address indexed _recycler, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);



    ETWINToken public token;



    uint256 public RECYCLE_TIME = 365 days;



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



    constructor(address _token) public {

        token = ETWINToken(_token);

    }



    function depositDividend() onlyEWContracts payable public {

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

        emit DividendDeposited(msg.sender, blockNumber, msg.value, currentSupply, dividendIndex);

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

            emit DividendClaimed(msg.sender, _dividendIndex, claim);

        }

    }



    function claimDividendAll() public {

        require(dividendsClaimed[msg.sender] < dividends.length);

        for (uint i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {

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

        emit DividendRecycled(msg.sender, blockNumber, remainingAmount, currentSupply, dividendIndex);

    }



    //Function is mocked for tests

    function getNow() internal constant returns (uint256) {

        return now;

    }



    function dividendsCount() external view returns (uint) {

        return dividends.length;

    }



    /// @notice This method can be used by the owner to extract mistakenly

    ///  sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///  set to 0 in case you want to extract ether.

    function claimTokens(address _token) external onlyOwner {

        //        if (_token == 0x0) {

        //            owner.transfer(address(this).balance);

        //            return;

        //        }



        ETWINToken claimToken = ETWINToken(_token);

        uint balance = claimToken.balanceOf(this);

        claimToken.transfer(owner, balance);

    }

}