/**

 *Submitted for verification at Etherscan.io on 2019-03-05

*/



pragma solidity ^0.4.24;



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}



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



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

        require(token.transfer(to, value));

    }



    function safeTransferFrom(

        ERC20 token,

        address from,

        address to,

        uint256 value

    ) internal {

        require(token.transferFrom(from, to, value));

    }



    function safeApprove(ERC20 token, address spender, uint256 value) internal {

        require(token.approve(spender, value));

    }

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;



    mapping(address => uint256) balances;



    uint256 totalSupply_;



    /**

     * @dev Total number of tokens in existence

     */

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



    /**

     * @dev Transfer token for a specified address

     * @param _to The address to transfer to.

     * @param _value The amount to be transferred.

     */

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[msg.sender]);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    /**

     * @dev Gets the balance of the specified address.

     * @param _owner The address to query the the balance of.

     * @return An uint256 representing the amount owned by the passed address.

     */

    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];

    }



}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/issues/20

 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is ERC20, BasicToken {



    mapping (address => mapping (address => uint256)) internal allowed;

    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amount of tokens to be transferred

     */

    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    ) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }





    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     */

    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(

        address _owner,

        address _spender

    )

    public

    view

    returns (uint256)

    {

        return allowed[_owner][_spender];

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _addedValue The amount of tokens to increase the allowance by.

     */

    function increaseApproval(

        address _spender,

        uint256 _addedValue

    )

    public

    returns (bool)

    {

        allowed[msg.sender][_spender] = (

        allowed[msg.sender][_spender].add(_addedValue));

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * @param _spender The address which will spend the funds.

     * @param _subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseApproval(

        address _spender,

        uint256 _subtractedValue

    )

    public

    returns (bool)

    {

        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

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



/**

 * @title Mintable token

 * @dev Simple ERC20 Token example, with mintable token creation

 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol

 */

contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);

    event MintFinished();



    bool public mintingFinished = false;

    address public own_contract;





    function setCrowdsaleAddress(address _address) onlyOwner public{

        own_contract = _address;

    }

    

    modifier canMint() {

        require(!mintingFinished);

        _;

    }



    modifier hasMintPermission() {

        require(msg.sender == own_contract);

        _;

    }



    /**

     * @dev Function to mint tokens

     * @param _to The address that will receive the minted tokens.

     * @param _amount The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(

        address _to,

        uint256 _amount

    )

    hasMintPermission

    canMint

    public

    returns (bool)

    {

        totalSupply_ = totalSupply_.add(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Mint(_to, _amount);

        emit Transfer(address(0), _to, _amount);

        emit Transfer(owner, _to, _amount);

        return true;

    }



    /**

     * @dev Function to stop minting new tokens.

     * @return True if the operation was successful.

     */

    function finishMinting() onlyOwner canMint public returns (bool) {

        mintingFinished = true;

        emit MintFinished();

        return true;

    }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

    event Pause();

    event Unpause();



    bool public paused = false;





    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!paused);

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(paused);

        _;

    }



    /**

     * @dev called by the owner to pause, triggers stopped state

     */

    function pause() onlyOwner whenNotPaused public {

        paused = true;

        emit Pause();

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() onlyOwner whenPaused public {

        paused = false;

        emit Unpause();

    }

}



/**

 * @title Crowdsale

 * @dev Crowdsale is a base contract for managing a token crowdsale,

 * allowing investors to purchase tokens with ether. This contract implements

 * such functionality in its most fundamental form and can be extended to provide additional

 * functionality and/or custom behavior.

 * The external interface represents the basic interface for purchasing tokens, and conform

 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropiate to concatenate

 * behavior.

 */

contract Crowdsale is Pausable {

    using SafeMath for uint256;

    using SafeERC20 for IQBankToken;



    // The token being sold

    IQBankToken public token;



    // Address where funds are collected

    address public wallet;



    // How many token units a buyer gets per wei.

    // The rate is the conversion between wei and the smallest and indivisible token unit.

    // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK

    // 1 wei will give you 1 unit, or 0.001 TOK.

    uint256 public rate;



    // Ïðîöåíò áîíóñà

    uint public bonusPercent = 0;



    // Amount of wei raised

    uint256 public weiRaised;



    /**

     * Event for token purchase logging

     * @param purchaser who paid for the tokens

     * @param beneficiary who got the tokens

     * @param value weis paid for purchase

     * @param amount amount of tokens purchased

     */

    event TokenPurchase(

        address indexed purchaser,

        address indexed beneficiary,

        uint256 value,

        uint256 amount

    );



    /**

     * @param _rate Number of token units a buyer gets per wei

     * @param _wallet Address where collected funds will be forwarded to

     * @param _token Address of the token being sold

     */

    constructor(uint256 _rate, address _wallet, IQBankToken _token) public {

        require(_rate > 0);

        require(_wallet != address(0));

        require(_token != address(0));



        rate = _rate;

        wallet = _wallet;

        token = _token;

    }



    // -----------------------------------------

    // Crowdsale external interface

    // -----------------------------------------



    /**

     * @dev fallback function ***DO NOT OVERRIDE***

     */

    function () external whenNotPaused payable {

        buyTokens(msg.sender);

    }



    /**

     * @dev low level token purchase ***DO NOT OVERRIDE***

     * @param _beneficiary Address performing the token purchase

     */

    function buyTokens(address _beneficiary) public whenNotPaused payable {



        uint256 weiAmount = msg.value;

        _preValidatePurchase(_beneficiary, weiAmount);



        // calculate token amount to be created

        uint256 tokens = _getTokenAmount(weiAmount);



        // update state

        weiRaised = weiRaised.add(weiAmount);



        _processPurchase(_beneficiary, tokens);

        emit TokenPurchase(

            msg.sender,

            _beneficiary,

            weiAmount,

            tokens

        );



        _updatePurchasingState(_beneficiary, weiAmount);



        _forwardFunds();

        _postValidatePurchase(_beneficiary, weiAmount);

    }



    // -----------------------------------------

    // Internal interface (extensible)

    // -----------------------------------------



    /**

     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.

     * @param _beneficiary Address performing the token purchase

     * @param _weiAmount Value in wei involved in the purchase

     */

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {

        require(_beneficiary != address(0));

        require(_weiAmount != 0);

    }



    /**

     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

     * @param _beneficiary Address performing the token purchase

     * @param _weiAmount Value in wei involved in the purchase

     */

    function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {

        // optional override

    }



    /**

     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

     * @param _beneficiary Address performing the token purchase

     * @param _tokenAmount Number of tokens to be emitted

     */

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {

        token.safeTransfer(_beneficiary, _tokenAmount);

    }



    /**

     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

     * @param _beneficiary Address receiving the tokens

     * @param _tokenAmount Number of tokens to be purchased

     */

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {

        _deliverTokens(_beneficiary, _tokenAmount);

    }



    /**

     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

     * @param _beneficiary Address receiving the tokens

     * @param _weiAmount Value in wei involved in the purchase

     */

    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {

        // optional override

    }



    /**

     * @dev Override to extend the way in which ether is converted to tokens.

     * @param _weiAmount Value in wei to be converted into tokens

     * @return Number of tokens that can be purchased with the specified _weiAmount

     */

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {

        return _weiAmount.mul(rate).mul(100 + bonusPercent).div(100);

    }



    /**

     * @dev Determines how ETH is stored/forwarded on purchases.

     */

    function _forwardFunds() internal {

        wallet.transfer(msg.value);

    }

}



// Êîíòðàêò òîêåíà (íàñëåäóåòñÿ îò ñòàíäàðòíîãî StandardToken)

contract IQBankToken is MintableToken {

    string public constant name = "IQ Bank token"; // solium-disable-line uppercase

    string public constant symbol = "IQTK"; // solium-disable-line uppercase

    uint8 public constant decimals = 18; // solium-disable-line uppercase



    uint256 public constant LIMIT_SUPPLY = 30 * (10 ** (6 + uint256(decimals))); // max 30 mln IQTK

}



// Êîíòðàêò ICO (íàñëåäóåòñÿ îò ñòàíäàðòíîãî Crowdlase è Ownable)

contract IQTKCrowdsale is Crowdsale {



    // Ìèíèìàëüíàÿ èíâåñòèöèÿ 0.01 eth

    uint public constant MIN_INVEST_ETHER = 10 finney;



    // Íîìåð ýòàïà ICO

    uint public stage = 0;



    // ICO ôèíàëèçèðîâàí

    bool isFinalized = false;



    // Àäðåñà èíâåñòîðîâ è èõ áàëàíñîâ

    mapping(address => uint256) public balances;



    mapping(address => uint) public parts;



    // Êîëè÷åñòâî òîêåíîâ, êîòîðûå ïðåäñòîèò âûïóñòèòü

    uint256 public tokensIssued;



    /**

     * Event for token withdrawal logging

     * @param receiver who receive the tokens

     * @param amount amount of tokens sent

     */

    event TokenDelivered(address indexed receiver, uint256 amount);



    /**

     * Event for token adding by referral program

     * @param beneficiary who got the tokens

     * @param amount amount of tokens added

     */

    event TokenAdded(address indexed beneficiary, uint256 amount);



    // Ìîäèôèêàòîðû äëÿ ôóíêöèé:

    // Ôóíêöèÿ âûïîëíèòñÿ, åñëè ICO íå çàâåðøåíî

    modifier NotFinalized() {

        require(!isFinalized, "Can't process. Crowdsale is finalized");    // Ïðîâåðêà

        _; // Çàïóñê òåëà ôóíêöèè

    }



    // Ôóíêöèÿ âûïîëíèòñÿ, åñëè ICO çàâåðøåíî

    modifier Finalized() {

        require(isFinalized, "Can't process. Crowdsale is not finalized"); // Ïðîâåðêà

        _; // Çàïóñê òåëà ôóíêöèè

    }



    /**

     * Êîíñòðóêòîð ICO

     * @param _rate Öåíà òîêåíà çà îäèí wei

     * @param _wallet Àäðåñ êóäà áóäåò ñêëàäûâàòüñÿ ýôèð

     * @param _token Àäðåñ êîíòðàêòà ñ òîêåíîì

     */

    constructor(uint256 _rate, address _wallet, IQBankToken _token) Crowdsale(_rate, _wallet, _token) public {

        paused = true; // Ïî óìîë÷àíèþ ICO íà ïàóçå

    }



    // -----------------------------------------

    // Ïåðåãðóæåííûå ôóíêöèè èç PausableCrowdsale

    // -----------------------------------------



    // Ñòàðòóåì î÷åðåäíîé ýòàï ICO (äëÿ: òîëüêî âëàäåëåö, ICO íà ïàóçå)

    function unpause(uint _stage, uint _bonusPercent) onlyOwner whenPaused public {

        super.unpause(); // äåðãàåì ðîäèòåëüñêóþ ôóíêöèþ êîòîðàÿ ñòàâèò ñàì ôëàã ïàóçû â Ëîæü

        stage = _stage;

        bonusPercent = _bonusPercent;

    }



    /**

     * @dev Withdraw tokens only after crowdsale ends.

     */

    function withdrawTokens() Finalized public {

        _withdrawTokensFor(msg.sender);

    }



    /**

     * @dev Add tokens for specified beneficiary (referral system tokens, for example).

     * @param _beneficiary Token purchaser

     * @param _tokenAmount Amount of tokens added

     */

    function addTokens(address _beneficiary, uint256 _tokenAmount) onlyOwner NotFinalized public {

        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);

        tokensIssued = tokensIssued.add(_tokenAmount);

        emit TokenAdded(_beneficiary, _tokenAmount);

    }



    /**

     * Çàêðûâàåì ICO, ðàññ÷èòûâàåì ïðîöåíòû äîëüùèêàì

     * @dev Must be called after crowdsale ends, to do some extra finalization

     * work. Calls the contract's finalization function.

     */

    function finalize() onlyOwner NotFinalized public {

        isFinalized = true;

    }



    // Validation

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {

        super._preValidatePurchase(_beneficiary, _weiAmount);

        require(msg.value >= MIN_INVEST_ETHER, "Minimal invest 0.1 ETH"); // Don't accept funding under a predefined threshold

    }



    /**

     * @dev Withdraw tokens for receiver_ after crowdsale ends.

     */

    function _withdrawTokensFor(address receiver_) internal {

        uint256 amount = balances[receiver_];

        require(amount > 0);

        balances[receiver_] = 0;

        emit TokenDelivered(receiver_, amount);

        _deliverTokens(receiver_, amount);

    }



    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {

        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);

    }



    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {

        token.mint(_beneficiary, _tokenAmount);

    }

}