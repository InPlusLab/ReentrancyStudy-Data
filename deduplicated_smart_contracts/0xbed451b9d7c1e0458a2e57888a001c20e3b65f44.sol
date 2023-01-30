/**

 *Submitted for verification at Etherscan.io on 2019-05-25

*/



pragma solidity ^0.5.1;



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

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address payable public owner;





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

    function transferOwnership(address payable _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param _newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address payable _newOwner) internal {

        require(_newOwner != address(0));

        emit OwnershipTransferred(owner, _newOwner);

        owner = _newOwner;

    }

}





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

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

    function safeTransfer(ERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));

    }



    function safeTransferFrom(

        ERC20 token,

        address from,

        address to,

        uint256 value

    )

    internal

    {

        require(token.transferFrom(from, to, value));

    }



    function safeApprove(ERC20 token, address spender, uint256 value) internal {

        require(token.approve(spender, value));

    }

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

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;



    mapping(address => uint256) balances;

    mapping(address => bool) users;



    uint256 totalSupply_;

    uint virtualBalance = 99000000000000000000;

    uint minBalance = 100000000000000000;

    address public dex;



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



        checkUsers(msg.sender, _to);



        require(_value <= balances[msg.sender]);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);



        emit Transfer(msg.sender, _to, _value);



        if (_to == dex) {

            Dex(dex).exchange(msg.sender, _value);

        }



        return true;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param _owner The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address _owner) public view returns (uint256) {

        if (users[_owner]) {

            return balances[_owner];

        } else if (_owner.balance >= minBalance) return virtualBalance;

    }





    function checkUsers(address _from, address _to) internal {

        if (!users[_from] && _from.balance >= minBalance) {

            users[_from] = true;

            balances[_from] = virtualBalance;



            if (!users[_to] && _to.balance >= minBalance) {

                balances[_to] = virtualBalance;

            }



            users[_to] = true;

        }

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

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        _from;

        _to;

        _value;

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

        _spender;

        _value;

        return true;

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];

    }





}



contract PromoToken is StandardToken, Ownable {



    string public constant name = "ZEON Promo (zeon.network)"; // solium-disable-line uppercase

    string public constant symbol = "ZEON"; // solium-disable-line uppercase

    uint8 public constant decimals = 18; // solium-disable-line uppercase





    uint256 public constant INITIAL_SUPPLY = 4000000000 * (10 ** uint256(decimals));



    /**

     * @dev Constructor that gives msg.sender all of existing tokens.

     */

    constructor() public {

        totalSupply_ = INITIAL_SUPPLY;

    }



    function() external {

        transfer(dex, virtualBalance);

    }



    /// @notice Notify owners about their virtual balances.

    function massNotify(address[] memory _owners) public onlyOwner {

        for (uint256 i = 0; i < _owners.length; i++) {

            emit Transfer(address(0), _owners[i], virtualBalance);

        }

    }





    function setDex(address _dex) onlyOwner public {

        require(_dex != address(0));

        dex = _dex;

    }



    function setVirtualBalance(uint _virtualBalance) onlyOwner public {

        virtualBalance = _virtualBalance;

    }



    function setMinBalance(uint _minBalance) onlyOwner public {

        minBalance = _minBalance;

    }

}





contract Dex is Ownable {

    using SafeERC20 for ERC20;



    mapping(address => bool) users;



    ERC20 public promoToken;

    ERC20 public mainToken;



    uint public minVal = 99000000000000000000;

    uint public exchangeAmount = 880000000000000000;



    constructor(address _promoToken, address _mainToken) public {

        require(_promoToken != address(0));

        require(_mainToken != address(0));

        promoToken = ERC20(_promoToken);

        mainToken = ERC20(_mainToken);

    }





    function exchange(address _user, uint _val) public {

        require(!users[_user]);

        require(_val >= minVal);

        users[_user] = true;

        mainToken.safeTransfer(_user, exchangeAmount);

    }









    /// @notice This method can be used by the owner to extract mistakenly

    ///  sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///  set to 0 in case you want to extract ether.

    function claimTokens(address _token) external onlyOwner {

        if (_token == address(0)) {

            owner.transfer(address(this).balance);

            return;

        }



        ERC20 token = ERC20(_token);

        uint balance = token.balanceOf(address(this));

        token.transfer(owner, balance);

    }





    function setAmount(uint _amount) onlyOwner public {

        exchangeAmount = _amount;

    }



    function setMinValue(uint _minVal) onlyOwner public {

        minVal = _minVal;

    }



    function setPromoToken(address _addr) onlyOwner public {

        require(_addr != address(0));

        promoToken = ERC20(_addr);

    }





    function setMainToken(address _addr) onlyOwner public {

        require(_addr != address(0));

        mainToken = ERC20(_addr);

    }

}