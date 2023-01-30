/**

 *Submitted for verification at Etherscan.io on 2019-06-15

*/



pragma solidity 0.5.6;







/*

*  deex.exchange pre-ICO tokens smart contract

*  implements [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)

*

*  Style

*  1) before start coding, run Python and type 'import this' in Python console.

*  2) we avoid using inheritance (contract B is A) as it makes code less clear for observer

*  ("Flat is better than nested", "Readability counts")

*  3) we avoid using -= ; =- ; +=; =+

*  see: https://github.com/ether-camp/virtual-accelerator/issues/8

*  https://www.ethnews.com/ethercamps-hkg-token-has-a-bug-and-needs-to-be-reissued

*  4) always explicitly mark variables and functions visibility ("Explicit is better than implicit")

*  5) every function except constructor should trigger at leas one event.

*  6) smart contracts have to be audited and reviewed, comment your code.

*

*  Code is published on https://github.com/thedeex/thedeex.github.io

*/





/* "Interfaces" */



//  this is expected from another contracts

//  if it wants to spend tokens of behalf of the token owner in our contract

//  this can be used in many situations, for example to convert pre-ICO tokens to ICO tokens

//  see 'approveAndCall' function

contract allowanceRecipient {

    function receiveApproval(address _from, uint256 _value, address _inContract, bytes memory _extraData) public returns (bool success);

}





// see:

// https://github.com/ethereum/EIPs/issues/677

contract tokenRecipient {

    function tokenFallback(address _from, uint256 _value, bytes memory _extraData) public returns (bool success);

}





contract DEEX {



    // ver. 2.0



    /* ---------- Variables */



    /* --- ERC-20 variables */



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#name

    // function name() constant returns (string name)

    string public name = "deex";



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#symbol

    // function symbol() constant returns (string symbol)

    string public symbol = "deex";



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#decimals

    // function decimals() constant returns (uint8 decimals)

    uint8 public decimals = 0;



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#totalsupply

    // function totalSupply() constant returns (uint256 totalSupply)

    // we start with zero and will create tokens as SC receives ETH

    uint256 public totalSupply;



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#balanceof

    // function balanceOf(address _owner) constant returns (uint256 balance)

    mapping (address => uint256) public balanceOf;



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#allowance

    // function allowance(address _owner, address _spender) constant returns (uint256 remaining)

    mapping (address => mapping (address => uint256)) public allowance;



    /* ----- For tokens sale */



    uint256 public salesCounter = 0;



    uint256 public maxSalesAllowed;



    bool private transfersBetweenSalesAllowed;



    // initial value should be changed by the owner

    uint256 public tokenPriceInWei = 0;



    uint256 public saleStartUnixTime = 0; // block.timestamp

    uint256 public saleEndUnixTime = 0;  // block.timestamp



    /* --- administrative */

    address public owner;



    // account that can set prices

    address public priceSetter;



    // 0 - not set

    uint256 private priceMaxWei = 0;

    // 0 - not set

    uint256 private priceMinWei = 0;



    // accounts holding tokens for for the team, for advisers and for the bounty campaign

    mapping (address => bool) public isPreferredTokensAccount;



    bool public contractInitialized = false;





    /* ---------- Constructor */

    // do not forget about:

    // https://medium.com/@codetractio/a-look-into-paritys-multisig-wallet-bug-affecting-100-million-in-ether-and-tokens-356f5ba6e90a

    constructor () public {

        owner = msg.sender;



        // for testNet can be more than 2

        // --------------------------------2------------------------------------------------------change  in production!

        maxSalesAllowed = 2;

        //

        transfersBetweenSalesAllowed = true;

    }





    function initContract(address team, address advisers, address bounty) public onlyBy(owner) returns (bool){



        require(contractInitialized == false);

        contractInitialized = true;



        priceSetter = msg.sender;



        totalSupply = 100000000;



        // tokens for sale go SC own account

        balanceOf[address(this)] = 75000000;



        // for the team

        balanceOf[team] = balanceOf[team] + 15000000;

        isPreferredTokensAccount[team] = true;



        // for advisers

        balanceOf[advisers] = balanceOf[advisers] + 7000000;

        isPreferredTokensAccount[advisers] = true;



        // for the bounty campaign

        balanceOf[bounty] = balanceOf[bounty] + 3000000;

        isPreferredTokensAccount[bounty] = true;



    }



    /* ---------- Events */



    /* --- ERC-20 events */

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#events



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer-1

    event Transfer(address indexed from, address indexed to, uint256 value);



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#approval

    event Approval(address indexed _owner, address indexed spender, uint256 value);



    /* --- Administrative events:  */

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);



    /* ---- Tokens creation and sale events  */



    event PriceChanged(uint256 indexed newTokenPriceInWei);



    event SaleStarted(uint256 startUnixTime, uint256 endUnixTime, uint256 indexed saleNumber);



    event NewTokensSold(uint256 numberOfTokens, address indexed purchasedBy, uint256 indexed priceInWei);



    event Withdrawal(address indexed to, uint sumInWei);



    /* --- Interaction with other contracts events  */

    event DataSentToAnotherContract(address indexed _from, address indexed _toContract, bytes _extraData);



    /* ---------- Functions */



    /* --- Modifiers  */

    modifier onlyBy(address _account){

        require(msg.sender == _account);



        _;

    }



    /* --- ERC-20 Functions */

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#methods



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transfer

    function transfer(address _to, uint256 _value) public returns (bool){

        return transferFrom(msg.sender, _to, _value);

    }



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#transferfrom

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){



        // transfers are possible only after sale is finished

        // except for manager and preferred accounts



        bool saleFinished = saleIsFinished();

        require(saleFinished || msg.sender == owner || isPreferredTokensAccount[msg.sender]);



        // transfers can be forbidden until final ICO is finished

        // except for manager and preferred accounts

        require(transfersBetweenSalesAllowed || salesCounter == maxSalesAllowed || msg.sender == owner || isPreferredTokensAccount[msg.sender]);



        // Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event (ERC-20)

        require(_value >= 0);



        // The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism

        require(msg.sender == _from || _value <= allowance[_from][msg.sender]);



        // check if _from account have required amount

        require(_value <= balanceOf[_from]);



        // Subtract from the sender

        balanceOf[_from] = balanceOf[_from] - _value;

        //

        // Add the same to the recipient

        balanceOf[_to] = balanceOf[_to] + _value;



        // If allowance used, change allowances correspondingly

        if (_from != msg.sender) {

            allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;

        }



        // event

        emit Transfer(_from, _to, _value);



        return true;

    }



    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#approve

    // there is and attack, see:

    // https://github.com/CORIONplatform/solidity/issues/6,

    // https://drive.google.com/file/d/0ByMtMw2hul0EN3NCaVFHSFdxRzA/view

    // but this function is required by ERC-20

    function approve(address _spender, uint256 _value) public returns (bool success){



        require(_value >= 0);



        allowance[msg.sender][_spender] = _value;



        // event

        emit Approval(msg.sender, _spender, _value);



        return true;

    }



    /*  ---------- Interaction with other contracts  */



    /* User can allow another smart contract to spend some shares in his behalf

    *  (this function should be called by user itself)

    *  @param _spender another contract's address

    *  @param _value number of tokens

    *  @param _extraData Data that can be sent from user to another contract to be processed

    *  bytes - dynamically-sized byte array,

    *  see http://solidity.readthedocs.io/en/v0.4.15/types.html#dynamically-sized-byte-array

    *  see possible attack information in comments to function 'approve'

    *  > this may be used to convert pre-ICO tokens to ICO tokens

    */

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {



        approve(_spender, _value);



        // 'spender' is another contract that implements code as prescribed in 'allowanceRecipient' above

        allowanceRecipient spender = allowanceRecipient(_spender);



        // our contract calls 'receiveApproval' function of another contract ('allowanceRecipient') to send information about

        // allowance and data sent by user

        // 'this' is this (our) contract address

        if (spender.receiveApproval(msg.sender, _value, address(this), _extraData)) {

            emit DataSentToAnotherContract(msg.sender, _spender, _extraData);

            return true;

        }

        else return false;

    }



    function approveAllAndCall(address _spender, bytes memory _extraData) public returns (bool success) {

        return approveAndCall(_spender, balanceOf[msg.sender], _extraData);

    }



    /* https://github.com/ethereum/EIPs/issues/677

    * transfer tokens with additional info to another smart contract, and calls its correspondent function

    * @param address _to - another smart contract address

    * @param uint256 _value - number of tokens

    * @param bytes _extraData - data to send to another contract

    * > this may be used to convert pre-ICO tokens to ICO tokens

    */

    function transferAndCall(address _to, uint256 _value, bytes memory _extraData) public returns (bool success){



        transferFrom(msg.sender, _to, _value);



        tokenRecipient receiver = tokenRecipient(_to);



        if (receiver.tokenFallback(msg.sender, _value, _extraData)) {

            emit DataSentToAnotherContract(msg.sender, _to, _extraData);

            return true;

        }

        else return false;

    }



    // for example for conveting ALL tokens of user account to another tokens

    function transferAllAndCall(address _to, bytes memory _extraData) public returns (bool success){

        return transferAndCall(_to, balanceOf[msg.sender], _extraData);

    }



    /* --- Administrative functions */



    function changeOwner(address _newOwner) public onlyBy(owner) returns (bool success){

        //

        require(_newOwner != address(0));



        address oldOwner = owner;

        owner = _newOwner;



        emit OwnerChanged(oldOwner, _newOwner);



        return true;

    }



    /* ---------- Create and sell tokens  */



    /* set time for start and time for end pre-ICO

    * time is integer representing block timestamp

    * in UNIX Time,

    * see: https://www.epochconverter.com

    * @param uint256 startTime - time to start

    * @param uint256 endTime - time to end

    * should be taken into account that

    * "block.timestamp" can be influenced by miners to a certain degree.

    * That means that a miner can "choose" the block.timestamp, to a certain degree,

    * to change the outcome of a transaction in the mined block.

    * see:

    * http://solidity.readthedocs.io/en/v0.4.15/frequently-asked-questions.html#are-timestamps-now-block-timestamp-reliable

    */



    function startSale(uint256 _startUnixTime, uint256 _endUnixTime) public onlyBy(owner) returns (bool success){



        require(balanceOf[address(this)] > 0);

        require(salesCounter < maxSalesAllowed);



        // time for sale can be set only if:

        // this is first sale (saleStartUnixTime == 0 && saleEndUnixTime == 0) , or:

        // previous sale finished ( saleIsFinished() )

        require(

            (saleStartUnixTime == 0 && saleEndUnixTime == 0) || saleIsFinished()

        );

        // time can be set only for future

        require(_startUnixTime > now && _endUnixTime > now);

        // end time should be later than start time

        require(_endUnixTime - _startUnixTime > 0);



        saleStartUnixTime = _startUnixTime;

        saleEndUnixTime = _endUnixTime;

        salesCounter = salesCounter + 1;



        emit SaleStarted(_startUnixTime, _endUnixTime, salesCounter);



        return true;

    }



    function saleIsRunning() public view returns (bool){



        if (balanceOf[address(this)] == 0) {

            return false;

        }



        if (saleStartUnixTime == 0 && saleEndUnixTime == 0) {

            return false;

        }



        if (now > saleStartUnixTime && now < saleEndUnixTime) {

            return true;

        }



        return false;

    }



    function saleIsFinished() public view returns (bool){



        if (balanceOf[address(this)] == 0) {

            return true;

        }



        else if (

            (saleStartUnixTime > 0 && saleEndUnixTime > 0)

            && now > saleEndUnixTime) {



            return true;

        }



        // <<<

        return true;

    }



    function changePriceSetter(address _priceSetter) public onlyBy(owner) returns (bool success) {

        priceSetter = _priceSetter;

        return true;

    }



    function setMinMaxPriceInWei(uint256 _priceMinWei, uint256 _priceMaxWei) public onlyBy(owner) returns (bool success){

        require(_priceMinWei >= 0 && _priceMaxWei >= 0);

        priceMinWei = _priceMinWei;

        priceMaxWei = _priceMaxWei;

        return true;

    }





    function setTokenPriceInWei(uint256 _priceInWei) public onlyBy(priceSetter) returns (bool success){



        require(_priceInWei >= 0);



        // if 0 - not set

        if (priceMinWei != 0 && _priceInWei < priceMinWei) {

            tokenPriceInWei = priceMinWei;

        }

        else if (priceMaxWei != 0 && _priceInWei > priceMaxWei) {

            tokenPriceInWei = priceMaxWei;

        }

        else {

            tokenPriceInWei = _priceInWei;

        }



        emit PriceChanged(tokenPriceInWei);



        return true;

    }



    // allows sending ether and receiving tokens just using contract address

    // warning:

    // 'If the fallback function requires more than 2300 gas, the contract cannot receive Ether'

    // see:

    // https://ethereum.stackexchange.com/questions/21643/fallback-function-best-practices-when-registering-information

    function() external payable {

        buyTokens();

    }



    //

    function buyTokens() public payable returns (bool success){



        if (saleIsRunning() && tokenPriceInWei > 0) {



            uint256 numberOfTokens = msg.value / tokenPriceInWei;



            if (numberOfTokens <= balanceOf[address(this)]) {



                balanceOf[msg.sender] = balanceOf[msg.sender] + numberOfTokens;

                balanceOf[address(this)] = balanceOf[address(this)] - numberOfTokens;



                emit NewTokensSold(numberOfTokens, msg.sender, tokenPriceInWei);



                return true;

            }

            else {

                // (payable)

                revert();

            }

        }

        else {

            // (payable)

            revert();

        }

    }



    /*  After sale contract owner

    *  (can be another contract or account)

    *  can withdraw all collected Ether

    */

    function withdrawAllToOwner() public onlyBy(owner) returns (bool) {



        // only after sale is finished:

        require(saleIsFinished());

        uint256 sumInWei = address(this).balance;



        if (

        // makes withdrawal and returns true or false

            !msg.sender.send(address(this).balance)

        ) {

            return false;

        }

        else {

            // event

            emit Withdrawal(msg.sender, sumInWei);

            return true;

        }

    }



    /* ---------- Referral System */



    // list of registered referrers

    // represented by keccak256(address) (returns bytes32)

    // ! referrers can not be removed !

    mapping (bytes32 => bool) private isReferrer;



    uint256 private referralBonus = 0;



    uint256 private referrerBonus = 0;

    // tokens owned by referrers:

    mapping (bytes32 => uint256) public referrerBalanceOf;



    mapping (bytes32 => uint) public referrerLinkedSales;



    function addReferrer(bytes32 _referrer) public onlyBy(owner) returns (bool success){

        isReferrer[_referrer] = true;

        return true;

    }



    function removeReferrer(bytes32 _referrer) public onlyBy(owner) returns (bool success){

        isReferrer[_referrer] = false;

        return true;

    }



    // bonuses are set in as integers (20%, 30%), initial 0%

    function setReferralBonuses(uint256 _referralBonus, uint256 _referrerBonus) public onlyBy(owner) returns (bool success){

        require(_referralBonus > 0 && _referrerBonus > 0);

        referralBonus = _referralBonus;

        referrerBonus = _referrerBonus;

        return true;

    }



    function buyTokensWithReferrerAddress(address _referrer) public payable returns (bool success){



        bytes32 referrer = keccak256(abi.encodePacked(_referrer));



        if (saleIsRunning() && tokenPriceInWei > 0) {



            if (isReferrer[referrer]) {



                uint256 numberOfTokens = msg.value / tokenPriceInWei;



                if (numberOfTokens <= balanceOf[address(this)]) {



                    referrerLinkedSales[referrer] = referrerLinkedSales[referrer] + numberOfTokens;



                    uint256 referralBonusTokens = (numberOfTokens * (100 + referralBonus) / 100) - numberOfTokens;

                    uint256 referrerBonusTokens = (numberOfTokens * (100 + referrerBonus) / 100) - numberOfTokens;



                    balanceOf[address(this)] = balanceOf[address(this)] - numberOfTokens - referralBonusTokens - referrerBonusTokens;



                    balanceOf[msg.sender] = balanceOf[msg.sender] + (numberOfTokens + referralBonusTokens);



                    referrerBalanceOf[referrer] = referrerBalanceOf[referrer] + referrerBonusTokens;



                    emit NewTokensSold(numberOfTokens + referralBonusTokens, msg.sender, tokenPriceInWei);



                    return true;

                }

                else {

                    // (payable)

                    revert();

                }

            }

            else {

                // (payable)

                buyTokens();

            }

        }

        else {

            // (payable)

            revert();

        }

    }



    event ReferrerBonusTokensTaken(address referrer, uint256 bonusTokensValue);



    function getReferrerBonusTokens() public returns (bool success){

        require(saleIsFinished());

        uint256 bonusTokens = referrerBalanceOf[keccak256(abi.encodePacked(msg.sender))];

        balanceOf[msg.sender] = balanceOf[msg.sender] + bonusTokens;

        emit ReferrerBonusTokensTaken(msg.sender, bonusTokens);

        return true;

    }



}



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





contract Ownable {

    address payable public owner;

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

    function transferOwnership(address payable newOwner) public onlyOwner {

        require(newOwner != address(0));

        owner = newOwner;

    }

}





/*

* @title Bank

* @dev Bank contract which contained all ETH from Dragons and Hamsters teams.

* When time in blockchain will be grater then current deadline or last deadline need call getWinner function

* then participants able get prizes.

*

* Last participant(last hero) win 10% from all bank

*

* - To get prize send 0 ETH to this contract

*/

contract Bank is Ownable {



    using SafeMath for uint256;



    mapping (uint256 => mapping (address => uint256)) public depositDragons;

    mapping (uint256 => mapping (address => uint256)) public depositHamsters;



    address payable public team = 0x7De1eFb9E5035784FB931433c8a884588929338E;



    uint256 public currentDeadline;

    uint256 public currentRound = 1;

    uint256 public lastDeadline;

    uint256 public defaultCurrentDeadlineInHours = 24;

    uint256 public defaultLastDeadlineInHours = 48;

    uint256 public countOfDragons;

    uint256 public countOfHamsters;

    uint256 public totalSupplyOfHamsters;

    uint256 public totalSupplyOfDragons;

    uint256 public totalDeexSupplyOfHamsters;

    uint256 public totalDeexSupplyOfDragons;

    uint256 public probabilityOfHamsters;

    uint256 public probabilityOfDragons;

    address public lastHero;

    address public lastHeroHistory;

    uint256 public jackPot;

    uint256 public winner;

    uint256 public withdrawn;

    uint256 public withdrawnDeex;

    uint256 public remainder;

    uint256 public remainderDeex;

    uint256 public rate = 1;

    uint256 public rateModifier = 0;

    uint256 public tokenReturn;



    uint256 public lastTotalSupplyOfHamsters;

    uint256 public lastTotalSupplyOfDragons;

    uint256 public lastTotalDeexSupplyOfHamsters;

    uint256 public lastTotalDeexSupplyOfDragons;

    uint256 public lastProbabilityOfHamsters;

    uint256 public lastProbabilityOfDragons;

    address public lastRoundHero;

    uint256 public lastJackPot;

    uint256 public lastWinner;

    uint256 public lastBalance;

    uint256 public lastBalanceDeex;

    uint256 public lastCountOfDragons;

    uint256 public lastCountOfHamsters;

    uint256 public lastWithdrawn;

    uint256 public lastWithdrawnDeex;





    bool public finished = false;



    Dragons public DragonsContract;

    Hamsters public HamstersContract;

    DEEX public DEEXContract;



    /**

    * @dev Setter token rate.

    * @param _rate this value for change percent relation rate to count of tokens.

    * @param _rateModifier this value for change math operation under tokens.

    */

    function setRateToken(uint256 _rate, uint256 _rateModifier) public onlyOwner returns(uint256){

        rate = _rate;

        rateModifier = _rateModifier;

    }



    /**

    * @dev Setter round time.

    * @param _currentDeadlineInHours this value current deadline in hours.

    * @param _lastDeadlineInHours this value last deadline in hours.

    */

    function _setRoundTime(uint _currentDeadlineInHours, uint _lastDeadlineInHours) internal {

        defaultCurrentDeadlineInHours = _currentDeadlineInHours;

        defaultLastDeadlineInHours = _lastDeadlineInHours;

        currentDeadline = block.timestamp + 60 * 60 * _currentDeadlineInHours;

        lastDeadline = block.timestamp + 60 * 60 * _lastDeadlineInHours;

    }



    /**

    * @dev Setter round time.

    * @param _currentDeadlineInHours this value current deadline in hours.

    * @param _lastDeadlineInHours this value last deadline in hours.

    */

    function setRoundTime(uint _currentDeadlineInHours, uint _lastDeadlineInHours) public onlyOwner {

        _setRoundTime(_currentDeadlineInHours, _lastDeadlineInHours);

    }





    /**

    * @dev Setter the DEEX contract address. Address can be set at once.

    * @param _DEEXAddress Address of the DEEX contract

    */

    function setDEEXAddress(address payable _DEEXAddress) public {

        require(address(DEEXContract) == address(0x0));

        DEEXContract = DEEX(_DEEXAddress);

    }



    /**

    * @dev Setter the Dragons contract address. Address can be set at once.

    * @param _DragonsAddress Address of the Dragons contract

    */

    function setDragonsAddress(address payable _DragonsAddress) external {

        require(address(DragonsContract) == address(0x0));

        DragonsContract = Dragons(_DragonsAddress);

    }



    /**

    * @dev Setter the Hamsters contract address. Address can be set at once.

    * @param _HamstersAddress Address of the Hamsters contract

    */

    function setHamstersAddress(address payable _HamstersAddress) external {

        require(address(HamstersContract) == address(0x0));

        HamstersContract = Hamsters(_HamstersAddress);

    }



    /**

    * @dev Getting time from blockchain for timer

    */

    function getNow() view public returns(uint){

        return block.timestamp;

    }



    /**

    * @dev Getting state of game. True - game continue, False - game stopped

    */

    function getState() view public returns(bool) {

        if (block.timestamp > currentDeadline) {

            return false;

        }

        return true;

    }



    /**

    * @dev Setting info about participant from Dragons or Hamsters contract

    * @param _lastHero Address of participant

    * @param _deposit Amount of deposit

    */

    function setInfo(address _lastHero, uint256 _deposit) public {

        require(address(DragonsContract) == msg.sender || address(HamstersContract) == msg.sender);



        if (address(DragonsContract) == msg.sender) {

            require(depositHamsters[currentRound][_lastHero] == 0, "You are already in Hamsters team");

            if (depositDragons[currentRound][_lastHero] == 0)

                countOfDragons++;

            totalSupplyOfDragons = totalSupplyOfDragons.add(_deposit.mul(90).div(100));

            depositDragons[currentRound][_lastHero] = depositDragons[currentRound][_lastHero].add(_deposit.mul(90).div(100));

        }



        if (address(HamstersContract) == msg.sender) {

            require(depositDragons[currentRound][_lastHero] == 0, "You are already in Dragons team");

            if (depositHamsters[currentRound][_lastHero] == 0)

                countOfHamsters++;

            totalSupplyOfHamsters = totalSupplyOfHamsters.add(_deposit.mul(90).div(100));

            depositHamsters[currentRound][_lastHero] = depositHamsters[currentRound][_lastHero].add(_deposit.mul(90).div(100));

        }



        lastHero = _lastHero;



        if (currentDeadline.add(120) <= lastDeadline) {

            currentDeadline = currentDeadline.add(120);

        } else {

            currentDeadline = lastDeadline;

        }



        jackPot += _deposit.mul(10).div(100);



        calculateProbability();

    }



    function estimateTokenPercent(uint256 _difference) public view returns(uint256){

        if (rateModifier == 0) {

            return _difference.mul(rate);

        } else {

            return _difference.div(rate);

        }

    }



    /**

    * @dev Calculation probability for team's win

    */

    function calculateProbability() public {

        require(winner == 0 && getState());



        totalDeexSupplyOfHamsters = DEEXContract.balanceOf(address(HamstersContract));

        totalDeexSupplyOfDragons = DEEXContract.balanceOf(address(DragonsContract));

        uint256 percent = (totalSupplyOfHamsters.add(totalSupplyOfDragons)).div(100);



        if (totalDeexSupplyOfHamsters < 1) {

            totalDeexSupplyOfHamsters = 0;

        }



        if (totalDeexSupplyOfDragons < 1) {

            totalDeexSupplyOfDragons = 0;

        }



        if (totalDeexSupplyOfHamsters <= totalDeexSupplyOfDragons) {

            uint256 difference = totalDeexSupplyOfDragons.sub(totalDeexSupplyOfHamsters).mul(100);

            probabilityOfDragons = totalSupplyOfDragons.mul(100).div(percent).add(estimateTokenPercent(difference));

  

            if (probabilityOfDragons > 8000) {

                probabilityOfDragons = 8000;

            }

            if (probabilityOfDragons < 2000) {

                probabilityOfDragons = 2000;

            }

            probabilityOfHamsters = 10000 - probabilityOfDragons;

        } else {

            uint256 difference = totalDeexSupplyOfHamsters.sub(totalDeexSupplyOfDragons).mul(100);

            probabilityOfHamsters = totalSupplyOfHamsters.mul(100).div(percent).add(estimateTokenPercent(difference));



            if (probabilityOfHamsters > 8000) {

                probabilityOfHamsters = 8000;

            }

            if (probabilityOfHamsters < 2000) {

                probabilityOfHamsters = 2000;

            }

            probabilityOfDragons = 10000 - probabilityOfHamsters;

        }



        totalDeexSupplyOfHamsters = DEEXContract.balanceOf(address(HamstersContract));

        totalDeexSupplyOfDragons = DEEXContract.balanceOf(address(DragonsContract));

    }



    /**

    * @dev Getting winner team

    */

    function getWinners() public {

        require(winner == 0 && !getState());

        uint256 seed1 = address(this).balance;

        uint256 seed2 = totalSupplyOfHamsters;

        uint256 seed3 = totalSupplyOfDragons;

        uint256 seed4 = totalDeexSupplyOfHamsters;

        uint256 seed5 = totalDeexSupplyOfHamsters;

        uint256 seed6 = block.difficulty;

        uint256 seed7 = block.timestamp;



        bytes32 randomHash = keccak256(abi.encodePacked(seed1, seed2, seed3, seed4, seed5, seed6, seed7));

        uint randomNumber = uint(randomHash);



        if (randomNumber == 0){

            randomNumber = 1;

        }



        uint winningNumber = randomNumber % 10000;



        if (1 <= winningNumber && winningNumber <= probabilityOfDragons){

            winner = 1;

        }



        if (probabilityOfDragons < winningNumber && winningNumber <= 10000){

            winner = 2;

        }



        if (DEEXContract.balanceOf(address(HamstersContract)) > 0)

            DEEXContract.transferFrom(

                address(HamstersContract),

                address(this),

                DEEXContract.balanceOf(address(HamstersContract))

            );



        if (DEEXContract.balanceOf(address(DragonsContract)) > 0)

            DEEXContract.transferFrom(

                address(DragonsContract),

                address(this),

                DEEXContract.balanceOf(address(DragonsContract))

            );



        lastTotalSupplyOfHamsters = totalSupplyOfHamsters;

        lastTotalSupplyOfDragons = totalSupplyOfDragons;

        lastTotalDeexSupplyOfDragons = totalDeexSupplyOfDragons;

        lastTotalDeexSupplyOfHamsters = totalDeexSupplyOfHamsters;

        lastRoundHero = lastHero;

        lastJackPot = jackPot;

        lastWinner = winner;

        lastCountOfDragons = countOfDragons;

        lastCountOfHamsters = countOfHamsters;

        lastWithdrawn = withdrawn;

        lastWithdrawnDeex = withdrawnDeex;



        if (lastBalance > lastWithdrawn){

            remainder = lastBalance.sub(lastWithdrawn);

           team.transfer(remainder);

        }



        lastBalance = lastTotalSupplyOfDragons.add(lastTotalSupplyOfHamsters).add(lastJackPot);



        if (lastBalanceDeex > lastWithdrawnDeex){

            remainderDeex = lastBalanceDeex.sub(lastWithdrawnDeex);

            tokenReturn = (totalDeexSupplyOfDragons.add(totalDeexSupplyOfHamsters)).mul(20).div(100).add(remainderDeex);

            DEEXContract.transfer(team, tokenReturn);

        }



        lastBalanceDeex = DEEXContract.balanceOf(address(this));



        totalSupplyOfHamsters = 0;

        totalSupplyOfDragons = 0;

        totalDeexSupplyOfHamsters = 0;

        totalDeexSupplyOfDragons = 0;

        remainder = 0;

        remainderDeex = 0;

        jackPot = 0;



        withdrawn = 0;

        winner = 0;

        withdrawnDeex = 0;

        countOfDragons = 0;

        countOfHamsters = 0;

        probabilityOfHamsters = 0;

        probabilityOfDragons = 0;



        _setRoundTime(defaultCurrentDeadlineInHours, defaultLastDeadlineInHours);

        currentRound++;

    }



    /**

    * @dev Payable function for take prize

    */

    function () external payable {

        if (msg.value == 0){

            require(depositDragons[currentRound - 1][msg.sender] > 0 || depositHamsters[currentRound - 1][msg.sender] > 0);



            uint payout = 0;

            uint payoutDeex = 0;



            if (lastWinner == 1 && depositDragons[currentRound - 1][msg.sender] > 0) {

                payout = calculateLastETHPrize(msg.sender);

            }

            if (lastWinner == 2 && depositHamsters[currentRound - 1][msg.sender] > 0) {

                payout = calculateLastETHPrize(msg.sender);

            }



            if (payout > 0) {

                depositDragons[currentRound - 1][msg.sender] = 0;

                depositHamsters[currentRound - 1][msg.sender] = 0;

                withdrawn = withdrawn.add(payout);

                msg.sender.transfer(payout);

            }



            if ((lastWinner == 1 && depositDragons[currentRound - 1][msg.sender] == 0) || (lastWinner == 2 && depositHamsters[currentRound - 1][msg.sender] == 0)) {

                payoutDeex = calculateLastDeexPrize(msg.sender);

                withdrawnDeex = withdrawnDeex.add(payoutDeex);

                DEEXContract.transfer(msg.sender, payoutDeex);

            }



            if (msg.sender == lastRoundHero) {

                lastHeroHistory = lastRoundHero;

                lastRoundHero = address(0x0);

                withdrawn = withdrawn.add(lastJackPot);

                msg.sender.transfer(lastJackPot);

            }

        }

    }



    /**

    * @dev Getting ETH prize of participant

    * @param participant Address of participant

    */

    function calculateETHPrize(address participant) public view returns(uint) {



        uint payout = 0;

        uint256 totalSupply = (totalSupplyOfDragons.add(totalSupplyOfHamsters));



        if (depositDragons[currentRound][participant] > 0) {

            payout = totalSupply.mul(depositDragons[currentRound][participant]).div(totalSupplyOfDragons);

        }



        if (depositHamsters[currentRound][participant] > 0) {

            payout = totalSupply.mul(depositHamsters[currentRound][participant]).div(totalSupplyOfHamsters);

        }



        return payout;

    }



    /**

    * @dev Getting Deex Token prize of participant

    * @param participant Address of participant

    */

    function calculateDeexPrize(address participant) public view returns(uint) {



        uint payout = 0;

        uint totalSupply = (totalDeexSupplyOfDragons.add(totalDeexSupplyOfHamsters)).mul(80).div(100);



        if (depositDragons[currentRound][participant] > 0) {

            payout = totalSupply.mul(depositDragons[currentRound][participant]).div(totalSupplyOfDragons);

        }



        if (depositHamsters[currentRound][participant] > 0) {

            payout = totalSupply.mul(depositHamsters[currentRound][participant]).div(totalSupplyOfHamsters);

        }



        return payout;

    }



    /**

    * @dev Getting ETH prize of _lastParticipant

    * @param _lastParticipant Address of _lastParticipant

    */

    function calculateLastETHPrize(address _lastParticipant) public view returns(uint) {



        uint payout = 0;

        uint256 totalSupply = (lastTotalSupplyOfDragons.add(lastTotalSupplyOfHamsters));



        if (depositDragons[currentRound - 1][_lastParticipant] > 0) {

            payout = totalSupply.mul(depositDragons[currentRound - 1][_lastParticipant]).div(lastTotalSupplyOfDragons);

        }



        if (depositHamsters[currentRound - 1][_lastParticipant] > 0) {

            payout = totalSupply.mul(depositHamsters[currentRound - 1][_lastParticipant]).div(lastTotalSupplyOfHamsters);

        }



        return payout;

    }



    /**

    * @dev Getting Deex Token prize of _lastParticipant

    * @param _lastParticipant Address of _lastParticipant

    */

    function calculateLastDeexPrize(address _lastParticipant) public view returns(uint) {



        uint payout = 0;

        uint totalSupply = (lastTotalDeexSupplyOfDragons.add(lastTotalDeexSupplyOfHamsters)).mul(80).div(100);



        if (depositDragons[currentRound - 1][_lastParticipant] > 0) {

            payout = totalSupply.mul(depositDragons[currentRound - 1][_lastParticipant]).div(lastTotalSupplyOfDragons);

        }



        if (depositHamsters[currentRound - 1][_lastParticipant] > 0) {

            payout = totalSupply.mul(depositHamsters[currentRound - 1][_lastParticipant]).div(lastTotalSupplyOfHamsters);

        }



        return payout;

    }

}



/**

* @dev Base contract for teams

*/

contract CryptoTeam {

    using SafeMath for uint256;



    Bank public BankContract;

    DEEX public DEEXContract;

    address payable public team = 0x7De1eFb9E5035784FB931433c8a884588929338E;



    /**

    * @dev Payable function. 10% will send to Developers fund and 90% will send to JackPot contract.

    * Also setting info about player.

    */

    function () external payable {

        require(BankContract.getState() && msg.value >= 0.05 ether);



        BankContract.setInfo(msg.sender, msg.value.mul(90).div(100));



        team.transfer(msg.value.mul(10).div(100));



        address(BankContract).transfer(msg.value.mul(90).div(100));

    }

}



/*

* @dev Dragons contract. To play game with Dragons send ETH to this contract

*/

contract Dragons is CryptoTeam {

    constructor(address payable _bankAddress, address payable _DEEXAddress) public {

        BankContract = Bank(_bankAddress);

        BankContract.setDragonsAddress(address(this));

        DEEXContract = DEEX(_DEEXAddress);

        DEEXContract.approve(_bankAddress, 9999999999999999999000000000000000000);

    }

}



/*

* @dev Hamsters contract. To play game with Hamsters send ETH to this contract

*/

contract Hamsters is CryptoTeam {

    constructor(address payable _bankAddress, address payable _DEEXAddress) public {

        BankContract = Bank(_bankAddress);

        BankContract.setHamstersAddress(address(this));

        DEEXContract = DEEX(_DEEXAddress);

        DEEXContract.approve(_bankAddress, 9999999999999999999000000000000000000);

    }

}