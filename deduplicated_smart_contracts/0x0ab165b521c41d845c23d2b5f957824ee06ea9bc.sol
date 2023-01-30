/**

 *Submitted for verification at Etherscan.io on 2019-03-09

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {

    /**

    * @dev Multiplies two numbers, reverts on overflow.

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

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



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



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * @notice Renouncing to ownership will leave the contract without an owner.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



pragma solidity ^0.4.24;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



pragma solidity ^0.4.24;



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



    constructor (string name, string symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }

}



contract BonusToken is ERC20, ERC20Detailed, Ownable {



    address public gameAddress;

    address public investTokenAddress;

    uint public maxLotteryParticipants;



    mapping (address => uint256) public ethLotteryBalances;

    address[] public ethLotteryParticipants;

    uint256 public ethLotteryBank;

    bool public isEthLottery;



    mapping (address => uint256) public tokensLotteryBalances;

    address[] public tokensLotteryParticipants;

    uint256 public tokensLotteryBank;

    bool public isTokensLottery;



    modifier onlyGame() {

        require(msg.sender == gameAddress);

        _;

    }



    modifier tokenIsAvailable {

        require(investTokenAddress != address(0));

        _;

    }



    constructor (address startGameAddress) public ERC20Detailed("Bet Token", "BET", 18) {

        setGameAddress(startGameAddress);

    }



    function setGameAddress(address newGameAddress) public onlyOwner {

        require(newGameAddress != address(0));

        gameAddress = newGameAddress;

    }



    function buyTokens(address buyer, uint256 tokensAmount) public onlyGame {

        _mint(buyer, tokensAmount * 10**18);

    }



    function startEthLottery() public onlyGame {

        isEthLottery = true;

    }



    function startTokensLottery() public onlyGame tokenIsAvailable {

        isTokensLottery = true;

    }



    function restartEthLottery() public onlyGame {

        for (uint i = 0; i < ethLotteryParticipants.length; i++) {

            ethLotteryBalances[ethLotteryParticipants[i]] = 0;

        }

        ethLotteryParticipants = new address[](0);

        ethLotteryBank = 0;

        isEthLottery = false;

    }



    function restartTokensLottery() public onlyGame tokenIsAvailable {

        for (uint i = 0; i < tokensLotteryParticipants.length; i++) {

            tokensLotteryBalances[tokensLotteryParticipants[i]] = 0;

        }

        tokensLotteryParticipants = new address[](0);

        tokensLotteryBank = 0;

        isTokensLottery = false;

    }



    function updateEthLotteryBank(uint256 value) public onlyGame {

        ethLotteryBank = ethLotteryBank.sub(value);

    }



    function updateTokensLotteryBank(uint256 value) public onlyGame {

        tokensLotteryBank = tokensLotteryBank.sub(value);

    }



    function swapTokens(address account, uint256 tokensToBurnAmount) public {

        require(msg.sender == investTokenAddress);

        _burn(account, tokensToBurnAmount);

    }



    function sendToEthLottery(uint256 value) public {

        require(!isEthLottery);

        require(ethLotteryParticipants.length < maxLotteryParticipants);

        address account = msg.sender;

        _burn(account, value);

        if (ethLotteryBalances[account] == 0) {

            ethLotteryParticipants.push(account);

        }

        ethLotteryBalances[account] = ethLotteryBalances[account].add(value);

        ethLotteryBank = ethLotteryBank.add(value);

    }



    function sendToTokensLottery(uint256 value) public tokenIsAvailable {

        require(!isTokensLottery);

        require(tokensLotteryParticipants.length < maxLotteryParticipants);

        address account = msg.sender;

        _burn(account, value);

        if (tokensLotteryBalances[account] == 0) {

            tokensLotteryParticipants.push(account);

        }

        tokensLotteryBalances[account] = tokensLotteryBalances[account].add(value);

        tokensLotteryBank = tokensLotteryBank.add(value);

    }



    function ethLotteryParticipants() public view returns(address[]) {

        return ethLotteryParticipants;

    }



    function tokensLotteryParticipants() public view returns(address[]) {

        return tokensLotteryParticipants;

    }



    function setInvestTokenAddress(address newInvestTokenAddress) external onlyOwner {

        require(newInvestTokenAddress != address(0));

        investTokenAddress = newInvestTokenAddress;

    }



    function setMaxLotteryParticipants(uint256 participants) external onlyOwner {

        maxLotteryParticipants = participants;

    }

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract modERC20 is IERC20 {

    using SafeMath for uint256;



    uint256 constant public MIN_HOLDERS_BALANCE = 20 ether;



    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;



    address public gameAddress;



    address[] internal holders;

    mapping(address => bool) internal isUser;



    function getHolders() public view returns (address[]) {

        return holders;

    }



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        if (to != gameAddress && from != gameAddress) {

            uint256 transferFee = value.div(100);

            _burn(from, transferFee);

            value = value.sub(transferFee);

        }

        if (to != gameAddress && _balances[to] == 0 && value >= MIN_HOLDERS_BALANCE) {

            holders.push(to);

        }

        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }

}



contract InvestToken is modERC20, ERC20Detailed, Ownable {



    uint8 constant public REFERRER_PERCENT = 3;

    uint8 constant public CASHBACK_PERCENT = 2;

    uint8 constant public HOLDERS_BUY_PERCENT_WITH_REFERRER = 7;

    uint8 constant public HOLDERS_BUY_PERCENT_WITH_REFERRER_AND_CASHBACK = 5;

    uint8 constant public HOLDERS_BUY_PERCENT = 10;

    uint8 constant public HOLDERS_SELL_PERCENT = 5;

    uint8 constant public TOKENS_DIVIDER = 10;

    uint256 constant public PRICE_INTERVAL = 10000000000;



    uint256 public swapTokensLimit;

    uint256 public investDividends;

    uint256 public casinoDividends;

    mapping(address => uint256) public ethStorage;

    mapping(address => address) public referrers;

    mapping(address => uint256) public investSize24h;

    mapping(address => uint256) public lastInvestTime;

    BonusToken public bonusToken;



    uint256 private holdersIndex;

    uint256 private totalInvestDividends;

    uint256 private totalCasinoDividends;

    uint256 private priceCoeff = 105e9;

    uint256 private constant a = 5e9;



    event Buy(address indexed buyer, uint256 weiAmount, uint256 tokensAmount, uint256 timestamp);

    event Sell(address indexed seller, uint256 weiAmount, uint256 tokensAmount, uint256 timestamp);

    event Reinvest(address indexed investor, uint256 weiAmount, uint256 tokensAmount, uint256 timestamp);

    event Withdraw(address indexed investor, uint256 weiAmount, uint256 timestamp);

    event ReferalsIncome(address indexed recipient, uint256 amount, uint256 timestamp);

    event InvestIncome(address indexed recipient, uint256 amount, uint256 timestamp);

    event CasinoIncome(address indexed recipient, uint256 amount, uint256 timestamp);



    constructor (address _bonusToken) public ERC20Detailed("Get Token", "GET", 18) {

        require(_bonusToken != address (0));

        bonusToken = BonusToken(_bonusToken);

        swapTokensLimit = 10000;

        swapTokensLimit = swapTokensLimit.mul(10 ** uint256(decimals()));

    }



    modifier onlyGame() {

        require(msg.sender == gameAddress, 'The sender must be a game contract.');

        _;

    }



    function () public payable {

        if (msg.sender != gameAddress) {

            address referrer;

            if (msg.data.length == 20) {

                referrer = bytesToAddress(bytes(msg.data));

            }

            buyTokens(referrer);

        }

    }



    function buyTokens(address referrer) public payable {

        uint256 weiAmount = msg.value;

        address buyer = msg.sender;

        uint256 tokensAmount;

        (weiAmount, tokensAmount) = mint(buyer, weiAmount);

        uint256 correctWeiAmount = msg.value.sub(weiAmount);

        checkInvestTimeAndSize(buyer, correctWeiAmount);

        if (!isUser[buyer]) {

            if (referrer != address(0) && referrer != buyer) {

                referrers[buyer] = referrer;

            }

            buyFee(buyer, correctWeiAmount, true);

            isUser[buyer] = true;

        } else {

            buyFee(buyer, correctWeiAmount, false);

        }

        if (weiAmount > 0) {

            buyer.transfer(weiAmount);

        }

        if (balanceOf(buyer) >= MIN_HOLDERS_BALANCE) {

            holders.push(buyer);

        }

        emit Buy(buyer, correctWeiAmount, tokensAmount, now);

    }



    function sellTokens(uint256 tokensAmount) public {

        address seller = msg.sender;

        _burn(seller, tokensAmount.mul(10 ** uint256(decimals())));

        uint256 weiAmount = tokensToEthereum(tokensAmount);

        weiAmount = sellFee(weiAmount);

        seller.transfer(weiAmount);

        emit Sell(seller, weiAmount, tokensAmount, now);

    }



    function swapTokens(uint256 tokensAmountToBurn) public {

        uint256 tokensAmountToMint = tokensAmountToBurn.div(TOKENS_DIVIDER);

        require(tokensAmountToMint <= swapTokensLimit.sub(tokensAmountToMint));

        require(bonusToken.balanceOf(msg.sender) >= tokensAmountToBurn, 'Not enough bonus tokens.');

        bonusToken.swapTokens(msg.sender, tokensAmountToBurn);

        swapTokensLimit = swapTokensLimit.sub(tokensAmountToMint);

        priceCoeff = priceCoeff.add(tokensAmountToMint.mul(1e10));

        _mint(msg.sender, tokensAmountToMint);

    }



    function reinvest(uint256 weiAmount) public {

        ethStorage[msg.sender] = ethStorage[msg.sender].sub(weiAmount);

        uint256 tokensAmount;

        (weiAmount, tokensAmount) = mint(msg.sender, weiAmount);

        if (weiAmount > 0) {

            ethStorage[msg.sender] = ethStorage[msg.sender].add(weiAmount);

        }

        emit Reinvest(msg.sender, weiAmount, tokensAmount, now);

    }



    function withdraw(uint256 weiAmount) public {

        require(weiAmount > 0);

        ethStorage[msg.sender] = ethStorage[msg.sender].sub(weiAmount);

        msg.sender.transfer(weiAmount);

        emit Withdraw(msg.sender, weiAmount, now);

    }



    function sendDividendsToHolders(uint holdersIterations) public onlyOwner {

        if (holdersIndex == 0) {

            totalInvestDividends = investDividends;

            totalCasinoDividends = casinoDividends;

        }

        uint holdersIterationsNumber;

        if (holders.length.sub(holdersIndex) < holdersIterations) {

            holdersIterationsNumber = holders.length.sub(holdersIndex);

        } else {

            holdersIterationsNumber = holdersIterations;

        }

        uint256 holdersBalance = 0;

        uint256 weiAmount = 0;

        for (uint256 i = 0; i < holdersIterationsNumber; i++) {

            holdersBalance = balanceOf(holders[holdersIndex]);

            if (holdersBalance >= MIN_HOLDERS_BALANCE) {

                if (totalInvestDividends > 0) {

                    weiAmount = holdersBalance.mul(totalInvestDividends).div(totalSupply());

                    investDividends = investDividends.sub(weiAmount);

                    emit InvestIncome(holders[holdersIndex], weiAmount, now);

                    ethStorage[holders[holdersIndex]] = ethStorage[holders[holdersIndex]].add(weiAmount);

                }

                if (totalCasinoDividends > 0) {

                    weiAmount = holdersBalance.mul(totalCasinoDividends).div(totalSupply());

                    casinoDividends = casinoDividends.sub(weiAmount);

                    emit CasinoIncome(holders[holdersIndex], weiAmount, now);

                    ethStorage[holders[holdersIndex]] = ethStorage[holders[holdersIndex]].add(weiAmount);

                }

            } else {

                deleteTokensHolder(holdersIndex);

            }

            holdersIndex++;

        }

        if (holdersIndex == holders.length) {

            holdersIndex = 0;

        }

    }



    function setGameAddress(address newGameAddress) public onlyOwner {

        gameAddress = newGameAddress;

    }



    function sendToGame(address player, uint256 tokensAmount) public onlyGame returns(bool) {

        _transfer(player, gameAddress, tokensAmount);

        return true;

    }



    function gameDividends(uint256 weiAmount) public onlyGame {

        casinoDividends = casinoDividends.add(weiAmount);

    }



    function price() public view returns(uint256) {

        return priceCoeff.add(a);

    }



    function mint(address account, uint256 weiAmount) private returns(uint256, uint256) {

        (uint256 tokensToMint, uint256 backPayWeiAmount) = ethereumToTokens(weiAmount);

        _mint(account, tokensToMint);

        return (backPayWeiAmount, tokensToMint);

    }



    function checkInvestTimeAndSize(address account, uint256 weiAmount) private {

        if (now - lastInvestTime[account] > 24 hours) {

            investSize24h[account] = 0;

        }

        require(investSize24h[account].add(weiAmount) <= 5 ether, 'Investment limit exceeded for 24 hours.');

        investSize24h[account] = investSize24h[account].add(weiAmount);

        lastInvestTime[account] = now;

    }



    function buyFee(address sender, uint256 weiAmount, bool isFirstInvest) private {

        address referrer = referrers[sender];

        uint256 holdersWeiAmount;

        if (referrer != address(0)) {

            uint256 referrerWeiAmount = weiAmount.mul(REFERRER_PERCENT).div(100);

            emit ReferalsIncome(referrer, referrerWeiAmount, now);

            ethStorage[referrer] = ethStorage[referrer].add(referrerWeiAmount);

            if (isFirstInvest) {

                uint256 cashbackWeiAmount = weiAmount.mul(CASHBACK_PERCENT).div(100);

                emit ReferalsIncome(sender, cashbackWeiAmount, now);

                ethStorage[sender] = ethStorage[sender].add(cashbackWeiAmount);

                holdersWeiAmount = weiAmount.mul(HOLDERS_BUY_PERCENT_WITH_REFERRER_AND_CASHBACK).div(100);

            } else {

                holdersWeiAmount = weiAmount.mul(HOLDERS_BUY_PERCENT_WITH_REFERRER).div(100);

            }

        } else {

            holdersWeiAmount = weiAmount.mul(HOLDERS_BUY_PERCENT).div(100);

        }

        addDividends(holdersWeiAmount);

    }



    function sellFee(uint256 weiAmount) private returns(uint256) {

        uint256 holdersWeiAmount = weiAmount.mul(HOLDERS_SELL_PERCENT).div(100);

        addDividends(holdersWeiAmount);

        weiAmount = weiAmount.sub(holdersWeiAmount);

        return weiAmount;

    }



    function addDividends(uint256 weiAmount) private {

        investDividends = investDividends.add(weiAmount);

    }



    function ethereumToTokens(uint256 weiAmount) private returns(uint256, uint256) {

        uint256 b = priceCoeff;

        uint256 c = weiAmount;

        uint256 D = (b ** 2).add(a.mul(4).mul(c));

        uint256 tokensAmount = (sqrt(D).sub(b)).div((a).mul(2));

        require(tokensAmount > 0);

        uint256 backPayWeiAmount = weiAmount.sub(a.mul(tokensAmount ** 2).add(priceCoeff.mul(tokensAmount)));

        priceCoeff = priceCoeff.add(tokensAmount.mul(1e10));

        tokensAmount = tokensAmount.mul(10 ** uint256(decimals()));

        return (tokensAmount, backPayWeiAmount);

    }



    function tokensToEthereum(uint256 tokensAmount) private returns(uint256) {

        require(tokensAmount > 0);

        uint256 weiAmount = priceCoeff.mul(tokensAmount).sub((tokensAmount ** 2).mul(5).mul(1e9));

        priceCoeff = priceCoeff.sub(tokensAmount.mul(1e10));

        return weiAmount;

    }



    function bytesToAddress(bytes source) private pure returns(address parsedAddress)

    {

        assembly {

            parsedAddress := mload(add(source,0x14))

        }

        return parsedAddress;

    }



    function sqrt(uint256 x) private pure returns (uint256 y) {

        uint256 z = (x + 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

    }



    function deleteTokensHolder(uint index) private {

        holders[index] = holders[holders.length - 1];

        delete holders[holders.length - 1];

        holders.length--;

    }

}