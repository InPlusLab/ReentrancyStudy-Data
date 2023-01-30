/**

 *Submitted for verification at Etherscan.io on 2018-12-25

*/



pragma solidity ^0.5.1;



contract Team {

    using SafeMath for uint256;



    address payable public teamAddressOne = 0x5947D8b85c5D3f8655b136B5De5D0Dd33f8E93D9;

    address payable public teamAddressTwo = 0xC923728AD95f71BC77186D6Fb091B3B30Ba42247;

    address payable public teamAddressThree = 0x763BFB050F9b973Dd32693B1e2181A68508CdA54;



    JackPot public JPContract;

    CBCToken public CBCTokenContract;



    /**

    * @dev Payable function

    */

    function () external payable {

        require(JPContract.getState() && msg.value >= 0.05 ether);



        JPContract.setInfo(msg.sender, msg.value.mul(90).div(100));



        teamAddressOne.transfer(msg.value.mul(4).div(100));

        teamAddressTwo.transfer(msg.value.mul(4).div(100));

        teamAddressThree.transfer(msg.value.mul(2).div(100));

        address(JPContract).transfer(msg.value.mul(90).div(100));

    }

}



contract Bears is Team {

    constructor(address payable _jackPotAddress, address payable _CBCTokenAddress) public {

        JPContract = JackPot(_jackPotAddress);

        JPContract.setBearsAddress(address(this));

        CBCTokenContract = CBCToken(_CBCTokenAddress);

        CBCTokenContract.approve(_jackPotAddress, 9999999999999999999000000000000000000);

    }

}



contract Bulls is Team {

    constructor(address payable _jackPotAddress, address payable _CBCTokenAddress) public {

        JPContract = JackPot(_jackPotAddress);

        JPContract.setBullsAddress(address(this));

        CBCTokenContract = CBCToken(_CBCTokenAddress);

        CBCTokenContract.approve(_jackPotAddress, 9999999999999999999000000000000000000);

    }

}



pragma solidity ^0.5.1;



contract JackPot {



    using SafeMath for uint256;



    mapping (address => uint256) public depositBears;

    mapping (address => uint256) public depositBulls;

    uint256 public currentDeadline;

    uint256 public lastDeadline = 1546257600;

    uint256 public countOfBears;

    uint256 public countOfBulls;

    uint256 public totalSupplyOfBulls;

    uint256 public totalSupplyOfBears;

    uint256 public totalCBCSupplyOfBulls;

    uint256 public totalCBCSupplyOfBears;

    uint256 public probabilityOfBulls;

    uint256 public probabilityOfBears;

    address public lastHero;

    address public lastHeroHistory;

    uint256 public jackPot;

    uint256 public winner;

    bool public finished = false;



    Bears public BearsContract;

    Bulls public BullsContract;

    CBCToken public CBCTokenContract;



    constructor() public {

        currentDeadline = block.timestamp + 60 * 60 * 24 * 3;

    }



    /**

    * @dev Setter the CryptoBossCoin contract address. Address can be set at once.

    * @param _CBCTokenAddress Address of the CryptoBossCoin contract

    */

    function setCBCTokenAddress(address _CBCTokenAddress) public {

        require(address(CBCTokenContract) == address(0x0));

        CBCTokenContract = CBCToken(_CBCTokenAddress);

    }



    /**

    * @dev Setter the Bears contract address. Address can be set at once.

    * @param _bearsAddress Address of the Bears contract

    */

    function setBearsAddress(address payable _bearsAddress) external {

        require(address(BearsContract) == address(0x0));

        BearsContract = Bears(_bearsAddress);

    }



    /**

    * @dev Setter the Bulls contract address. Address can be set at once.

    * @param _bullsAddress Address of the Bulls contract

    */

    function setBullsAddress(address payable _bullsAddress) external {

        require(address(BullsContract) == address(0x0));

        BullsContract = Bulls(_bullsAddress);

    }



    function getNow() view public returns(uint){

        return block.timestamp;

    }



    function getState() view public returns(bool) {

        if (block.timestamp > currentDeadline) {

            return false;

        }

        return true;

    }



    function setInfo(address _lastHero, uint256 _deposit) public {

        require(address(BearsContract) == msg.sender || address(BullsContract) == msg.sender);



        if (address(BearsContract) == msg.sender) {

            require(depositBulls[_lastHero] == 0, "You are already in bulls team");

            if (depositBears[_lastHero] == 0)

                countOfBears++;

            totalSupplyOfBears = totalSupplyOfBears.add(_deposit.mul(90).div(100));

            depositBears[_lastHero] = depositBears[_lastHero].add(_deposit.mul(90).div(100));

        }



        if (address(BullsContract) == msg.sender) {

            require(depositBears[_lastHero] == 0, "You are already in bears team");

            if (depositBulls[_lastHero] == 0)

                countOfBulls++;

            totalSupplyOfBulls = totalSupplyOfBulls.add(_deposit.mul(90).div(100));

            depositBulls[_lastHero] = depositBulls[_lastHero].add(_deposit.mul(90).div(100));

        }



        lastHero = _lastHero;



        if (currentDeadline.add(120) <= lastDeadline) {

            currentDeadline = currentDeadline.add(120);

        } else {

            currentDeadline = lastDeadline;

        }



        jackPot = (address(this).balance.add(_deposit)).mul(10).div(100);



        calculateProbability();

    }



    function calculateProbability() public {

        require(winner == 0 && getState());



        totalCBCSupplyOfBulls = CBCTokenContract.balanceOf(address(BullsContract));

        totalCBCSupplyOfBears = CBCTokenContract.balanceOf(address(BearsContract));

        uint256 percent = (totalSupplyOfBulls.add(totalSupplyOfBears)).div(100);



        if (totalCBCSupplyOfBulls < 1 ether) {

            totalCBCSupplyOfBulls = 0;

        }



        if (totalCBCSupplyOfBears < 1 ether) {

            totalCBCSupplyOfBears = 0;

        }



        if (totalCBCSupplyOfBulls <= totalCBCSupplyOfBears) {

            uint256 difference = totalCBCSupplyOfBears.sub(totalCBCSupplyOfBulls).div(0.01 ether);

            probabilityOfBears = totalSupplyOfBears.mul(100).div(percent).add(difference);



            if (probabilityOfBears > 8000) {

                probabilityOfBears = 8000;

            }

            if (probabilityOfBears < 2000) {

                probabilityOfBears = 2000;

            }

            probabilityOfBulls = 10000 - probabilityOfBears;

        } else {

            uint256 difference = totalCBCSupplyOfBulls.sub(totalCBCSupplyOfBears).div(0.01 ether);

            probabilityOfBulls = totalSupplyOfBulls.mul(100).div(percent).add(difference);



            if (probabilityOfBulls > 8000) {

                probabilityOfBulls = 8000;

            }

            if (probabilityOfBulls < 2000) {

                probabilityOfBulls = 2000;

            }

            probabilityOfBears = 10000 - probabilityOfBulls;

        }



        totalCBCSupplyOfBulls = CBCTokenContract.balanceOf(address(BullsContract));

        totalCBCSupplyOfBears = CBCTokenContract.balanceOf(address(BearsContract));

    }



    function getWinners() public {

        require(winner == 0 && !getState());



        uint256 seed1 = address(this).balance;

        uint256 seed2 = totalSupplyOfBulls;

        uint256 seed3 = totalSupplyOfBears;

        uint256 seed4 = totalCBCSupplyOfBulls;

        uint256 seed5 = totalCBCSupplyOfBulls;

        uint256 seed6 = block.difficulty;

        uint256 seed7 = block.timestamp;



        bytes32 randomHash = keccak256(abi.encodePacked(seed1, seed2, seed3, seed4, seed5, seed6, seed7));

        uint randomNumber = uint(randomHash);



        if (randomNumber == 0){

            randomNumber = 1;

        }



        uint winningNumber = randomNumber % 10000;



        if (1 <= winningNumber && winningNumber <= probabilityOfBears){

            winner = 1;

        }



        if (probabilityOfBears < winningNumber && winningNumber <= 10000){

            winner = 2;

        }

    }



    /**

    * @dev Payable function for take prize

    */

    function () external payable {

        if (msg.value == 0 &&  !getState() && winner > 0){

            require(depositBears[msg.sender] > 0 || depositBulls[msg.sender] > 0);



            uint payout = 0;

            uint payoutCBC = 0;



            if (winner == 1 && depositBears[msg.sender] > 0) {

                payout = calculateETHPrize(msg.sender);

            }

            if (winner == 2 && depositBulls[msg.sender] > 0) {

                payout = calculateETHPrize(msg.sender);

            }



            if (payout > 0) {

                depositBears[msg.sender] = 0;

                depositBulls[msg.sender] = 0;

                msg.sender.transfer(payout);

            }



            if ((winner == 1 && depositBears[msg.sender] == 0) || (winner == 2 && depositBulls[msg.sender] == 0)) {

                payoutCBC = calculateCBCPrize(msg.sender);

                if (CBCTokenContract.balanceOf(address(BullsContract)) > 0)

                    CBCTokenContract.transferFrom(

                        address(BullsContract),

                        address(this),

                        CBCTokenContract.balanceOf(address(BullsContract))

                    );

                if (CBCTokenContract.balanceOf(address(BearsContract)) > 0)

                    CBCTokenContract.transferFrom(

                        address(BearsContract),

                        address(this),

                        CBCTokenContract.balanceOf(address(BearsContract))

                    );

                CBCTokenContract.transfer(msg.sender, payoutCBC);

            }



            if (msg.sender == lastHero) {

                lastHeroHistory = lastHero;

                lastHero = address(0x0);

                msg.sender.transfer(jackPot);

            }

        }

    }



    function calculateETHPrize(address participant) public view returns(uint) {



        uint payout = 0;

        uint256 totalSupply = (totalSupplyOfBears.add(totalSupplyOfBulls));



        if (depositBears[participant] > 0) {

            payout = totalSupply.mul(depositBears[participant]).div(totalSupplyOfBears);

        }



        if (depositBulls[participant] > 0) {

            payout = totalSupply.mul(depositBulls[participant]).div(totalSupplyOfBulls);

        }



        return payout;

    }



    function calculateCBCPrize(address participant) public view returns(uint) {



        uint payout = 0;

        uint totalSupply = (totalCBCSupplyOfBears.add(totalCBCSupplyOfBulls)).mul(80).div(100);



        if (depositBears[participant] > 0) {

            payout = totalSupply.mul(depositBears[participant]).div(totalSupplyOfBears);

        }



        if (depositBulls[participant] > 0) {

            payout = totalSupply.mul(depositBulls[participant]).div(totalSupplyOfBulls);

        }



        return payout;

    }





}

pragma solidity ^0.5.1;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address public owner;





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

        require (msg.sender == owner);

        _;

    }





    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        owner = newOwner;

    }

}







/**

 * @title Authorizable

 * @dev Allows to authorize access to certain function calls

 *

 * ABI

 * [{"constant":true,"inputs":[{"name":"authorizerIndex","type":"uint256"}],"name":"getAuthorizer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"addAuthorized","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"isAuthorized","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"}]

 */

contract Authorizable {



    address[] authorizers;

    mapping(address => uint) authorizerIndex;



    /**

     * @dev Throws if called by any account tat is not authorized.

     */

    modifier onlyAuthorized {

        require(isAuthorized(msg.sender));

        _;

    }



    /**

     * @dev Contructor that authorizes the msg.sender.

     */

    constructor() public {

        authorizers.length = 2;

        authorizers[1] = msg.sender;

        authorizerIndex[msg.sender] = 1;

    }



    /**

     * @dev Function to get a specific authorizer

     * @param authorizerIndex index of the authorizer to be retrieved.

     * @return The address of the authorizer.

     */

    function getAuthorizer(uint authorizerIndex) external view returns(address) {

        return address(authorizers[authorizerIndex + 1]);

    }



    /**

     * @dev Function to check if an address is authorized

     * @param _addr the address to check if it is authorized.

     * @return boolean flag if address is authorized.

     */

    function isAuthorized(address _addr) public view returns(bool) {

        return authorizerIndex[_addr] > 0;

    }



    /**

     * @dev Function to add a new authorizer

     * @param _addr the address to add as a new authorizer.

     */

    function addAuthorized(address _addr) external onlyAuthorized {

        authorizerIndex[_addr] = authorizers.length;

        authorizers.length++;

        authorizers[authorizers.length - 1] = _addr;

    }



}



/**

 * @title ExchangeRate

 * @dev Allows updating and retrieveing of Conversion Rates for PAY tokens

 *

 * ABI

 * [{"constant":false,"inputs":[{"name":"_symbol","type":"string"},{"name":"_rate","type":"uint256"}],"name":"updateRate","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"data","type":"uint256[]"}],"name":"updateRates","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_symbol","type":"string"}],"name":"getRate","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"rates","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"timestamp","type":"uint256"},{"indexed":false,"name":"symbol","type":"bytes32"},{"indexed":false,"name":"rate","type":"uint256"}],"name":"RateUpdated","type":"event"}]

 */

contract ExchangeRate is Ownable {



    event RateUpdated(uint timestamp, bytes32 symbol, uint rate);



    mapping(bytes32 => uint) public rates;



    /**

     * @dev Allows the current owner to update a single rate.

     * @param _symbol The symbol to be updated.

     * @param _rate the rate for the symbol.

     */

    function updateRate(string memory _symbol, uint _rate) public onlyOwner {

        rates[keccak256(abi.encodePacked(_symbol))] = _rate;

        emit RateUpdated(now, keccak256(bytes(_symbol)), _rate);

    }



    /**

     * @dev Allows the current owner to update multiple rates.

     * @param data an array that alternates keccak256 hashes of the symbol and the corresponding rate .

     */

    function updateRates(uint[] memory data) public onlyOwner {

        require (data.length % 2 <= 0);

        uint i = 0;

        while (i < data.length / 2) {

            bytes32 symbol = bytes32(data[i * 2]);

            uint rate = data[i * 2 + 1];

            rates[symbol] = rate;

            emit RateUpdated(now, symbol, rate);

            i++;

        }

    }



    /**

     * @dev Allows the anyone to read the current rate.

     * @param _symbol the symbol to be retrieved.

     */

    function getRate(string memory _symbol) public view returns(uint) {

        return rates[keccak256(abi.encodePacked(_symbol))];

    }



}



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





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20Basic {

    uint public totalSupply;

    function balanceOf(address who) public view returns (uint);

    function transfer(address to, uint value) public;

    event Transfer(address indexed from, address indexed to, uint value);

}









/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) view public returns (uint);

    function transferFrom(address from, address to, uint value) public;

    function approve(address spender, uint value) public;

    event Approval(address indexed owner, address indexed spender, uint value);

}









/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

    using SafeMath for uint;



    mapping(address => uint) balances;



    /**

     * @dev Fix for the ERC20 short address attack.

     */

    modifier onlyPayloadSize(uint size) {

        require (size + 4 <= msg.data.length);

        _;

    }



    /**

    * @dev transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param _owner The address to query the the balance of.

    * @return An uint representing the amount owned by the passed address.

    */

    function balanceOf(address _owner) view public returns (uint balance) {

        return balances[_owner];

    }



}









/**

 * @title Standard ERC20 token

 *

 * @dev Implemantation of the basic standart token.

 * @dev https://github.com/ethereum/EIPs/issues/20

 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

contract StandardToken is BasicToken, ERC20 {



    mapping (address => mapping (address => uint)) allowed;





    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint the amout of tokens to be transfered

     */

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {

        uint256 _allowance = allowed[_from][msg.sender];



        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met

        // if (_value > _allowance) throw;



        balances[_to] = balances[_to].add(_value);

        balances[_from] = balances[_from].sub(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        emit Transfer(_from, _to, _value);

    }



    /**

     * @dev Aprove the passed address to spend the specified amount of tokens on beahlf of msg.sender.

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     */

    function approve(address _spender, uint _value) public {



        // To change the approve amount you first have to reduce the addresses`

        //  allowance to zero by calling `approve(_spender, 0)` if it is not

        //  already 0 to mitigate the race condition described here:

        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();



        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

    }



    /**

     * @dev Function to check the amount of tokens than an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint specifing the amount of tokens still avaible for the spender.

     */

    function allowance(address _owner, address _spender) view public returns (uint remaining) {

        return allowed[_owner][_spender];

    }



}





/**

 * @title Mintable token

 * @dev Simple ERC20 Token example, with mintable token creation

 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120

 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol

 */



contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint value);

    event MintFinished();

    event Burn(address indexed burner, uint256 value);



    bool public mintingFinished = false;

    uint public totalSupply = 0;





    modifier canMint() {

        require(!mintingFinished);

        _;

    }



    /**

     * @dev Function to mint tokens

     * @param _to The address that will recieve the minted tokens.

     * @param _amount The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(address _to, uint _amount) onlyOwner canMint public returns (bool) {

        totalSupply = totalSupply.add(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Mint(_to, _amount);

        return true;

    }



    /**

     * @dev Function to stop minting new tokens.

     * @return True if the operation was successful.

     */

    function finishMinting() onlyOwner public returns (bool) {

        mintingFinished = true;

        emit MintFinished();

        return true;

    }





    /**

     * @dev Burns a specific amount of tokens.

     * @param _value The amount of token to be burned.

     */

    function burn(address _who, uint256 _value) onlyOwner public {

        _burn(_who, _value);

    }



    function _burn(address _who, uint256 _value) internal {

        require(_value <= balances[_who]);

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure



        balances[_who] = balances[_who].sub(_value);

        totalSupply = totalSupply.sub(_value);

        emit Burn(_who, _value);

        emit Transfer(_who, address(0), _value);

    }

}





/**

 * @title CBCToken

 * @dev The main CBC token contract

 *

 * ABI

 * [{"constant":true,"inputs":[],"name":"mintingFinished","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"startTrading","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tradingStarted","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finishMinting","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Mint","type":"event"},{"anonymous":false,"inputs":[],"name":"MintFinished","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]

 */

contract CBCToken is MintableToken {



    string public name = "Crypto Boss Coin";

    string public symbol = "CBC";

    uint public decimals = 18;



    bool public tradingStarted = false;

    /**

     * @dev modifier that throws if trading has not started yet

     */

    modifier hasStartedTrading() {

        require(tradingStarted);

        _;

    }





    /**

     * @dev Allows the owner to enable the trading. This can not be undone

     */

    function startTrading() onlyOwner public {

        tradingStarted = true;

    }



    /**

     * @dev Allows anyone to transfer the PAY tokens once trading has started

     * @param _to the recipient address of the tokens.

     * @param _value number of tokens to be transfered.

     */

    function transfer(address _to, uint _value) hasStartedTrading public {

        super.transfer(_to, _value);

    }



    /**

    * @dev Allows anyone to transfer the CBC tokens once trading has started

    * @param _from address The address which you want to send tokens from

    * @param _to address The address which you want to transfer to

    * @param _value uint the amout of tokens to be transfered

    */

    function transferFrom(address _from, address _to, uint _value) hasStartedTrading public{

        super.transferFrom(_from, _to, _value);

    }



}



/**

 * @title MainSale

 * @dev The main CBC token sale contract

 *

 * ABI

 * [{"constant":false,"inputs":[{"name":"_multisigVault","type":"address"}],"name":"setMultisigVault","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"authorizerIndex","type":"uint256"}],"name":"getAuthorizer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"exchangeRate","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"altDeposits","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"recipient","type":"address"},{"name":"tokens","type":"uint256"}],"name":"authorizedCreateTokens","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finishMinting","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_exchangeRate","type":"address"}],"name":"setExchangeRate","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_token","type":"address"}],"name":"retrieveTokens","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"totalAltDeposits","type":"uint256"}],"name":"setAltDeposit","outputs":[],"payable":false,"type":"function"},{"constant":!1,"inputs":[{"name":"victim","type":"address"},{"name":"amount","type":"uint256"}],"name":"burnTokens","outputs":[],"payable":!1,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"start","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"recipient","type":"address"}],"name":"createTokens","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"addAuthorized","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"multisigVault","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_hardcap","type":"uint256"}],"name":"setHardCap","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_start","type":"uint256"}],"name":"setStart","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"isAuthorized","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"recipient","type":"address"},{"indexed":false,"name":"ether_amount","type":"uint256"},{"indexed":false,"name":"pay_amount","type":"uint256"},{"indexed":false,"name":"exchangerate","type":"uint256"}],"name":"TokenSold","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"recipient","type":"address"},{"indexed":false,"name":"pay_amount","type":"uint256"}],"name":"AuthorizedCreate","type":"event"},{"anonymous":false,"inputs":[],"name":"MainSaleClosed","type":"event"}]

 */

contract MainSale is Ownable, Authorizable {

    using SafeMath for uint;

    event TokenSold(address recipient, uint ether_amount, uint pay_amount, uint exchangerate);

    event AuthorizedCreate(address recipient, uint pay_amount);

    event AuthorizedBurn(address receiver, uint value);

    event AuthorizedStartTrading();

    event MainSaleClosed();

    CBCToken public token = new CBCToken();



    address payable public multisigVault;



    uint hardcap = 100000000000000 ether;

    ExchangeRate public exchangeRate;



    uint public altDeposits = 0;

    uint public start = 1525996800;



    /**

     * @dev modifier to allow token creation only when the sale IS ON

     */

    modifier saleIsOn() {

        require(now > start && now < start + 28 days);

        _;

    }



    /**

     * @dev modifier to allow token creation only when the hardcap has not been reached

     */

    modifier isUnderHardCap() {

        require(multisigVault.balance + altDeposits <= hardcap);

        _;

    }



    /**

     * @dev Allows anyone to create tokens by depositing ether.

     * @param recipient the recipient to receive tokens.

     */

    function createTokens(address recipient) public isUnderHardCap saleIsOn payable {

        uint rate = exchangeRate.getRate("ETH");

        uint tokens = rate.mul(msg.value).div(1 ether);

        token.mint(recipient, tokens);

        require(multisigVault.send(msg.value));

        emit TokenSold(recipient, msg.value, tokens, rate);

    }



    /**

     * @dev Allows to set the toal alt deposit measured in ETH to make sure the hardcap includes other deposits

     * @param totalAltDeposits total amount ETH equivalent

     */

    function setAltDeposit(uint totalAltDeposits) public onlyOwner {

        altDeposits = totalAltDeposits;

    }



    /**

     * @dev Allows authorized acces to create tokens. This is used for Bitcoin and ERC20 deposits

     * @param recipient the recipient to receive tokens.

     * @param tokens number of tokens to be created.

     */

    function authorizedCreateTokens(address recipient, uint tokens) public onlyAuthorized {

        token.mint(recipient, tokens);

        emit AuthorizedCreate(recipient, tokens);

    }



    function authorizedStartTrading() public onlyAuthorized {

        token.startTrading();

        emit AuthorizedStartTrading();

    }



    /**

     * @dev Allows authorized acces to burn tokens.

     * @param receiver the receiver to receive tokens.

     * @param value number of tokens to be created.

     */

    function authorizedBurnTokens(address receiver, uint value) public onlyAuthorized {

        token.burn(receiver, value);

        emit AuthorizedBurn(receiver, value);

    }



    /**

     * @dev Allows the owner to set the hardcap.

     * @param _hardcap the new hardcap

     */

    function setHardCap(uint _hardcap) public onlyOwner {

        hardcap = _hardcap;

    }



    /**

     * @dev Allows the owner to set the starting time.

     * @param _start the new _start

     */

    function setStart(uint _start) public onlyOwner {

        start = _start;

    }



    /**

     * @dev Allows the owner to set the multisig contract.

     * @param _multisigVault the multisig contract address

     */

    function setMultisigVault(address payable _multisigVault) public onlyOwner {

        if (_multisigVault != address(0)) {

            multisigVault = _multisigVault;

        }

    }



    /**

     * @dev Allows the owner to set the exchangerate contract.

     * @param _exchangeRate the exchangerate address

     */

    function setExchangeRate(address _exchangeRate) public onlyOwner {

        exchangeRate = ExchangeRate(_exchangeRate);

    }



    /**

     * @dev Allows the owner to finish the minting. This will create the

     * restricted tokens and then close the minting.

     * Then the ownership of the PAY token contract is transfered

     * to this owner.

     */

    function finishMinting() public onlyOwner {

        uint issuedTokenSupply = token.totalSupply();

        uint restrictedTokens = issuedTokenSupply.mul(49).div(51);

        token.mint(multisigVault, restrictedTokens);

        token.finishMinting();

        token.transferOwnership(owner);

        emit MainSaleClosed();

    }



    /**

     * @dev Allows the owner to transfer ERC20 tokens to the multi sig vault

     * @param _token the contract address of the ERC20 contract

     */

    function retrieveTokens(address _token) public onlyOwner {

        ERC20 token = ERC20(_token);

        token.transfer(multisigVault, token.balanceOf(address(this)));

    }



    /**

     * @dev Fallback function which receives ether and created the appropriate number of tokens for the

     * msg.sender.

     */

    function() external payable {

        createTokens(msg.sender);

    }



}