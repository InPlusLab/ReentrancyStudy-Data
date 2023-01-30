/**

 *Submitted for verification at Etherscan.io on 2018-08-17

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

     * @dev Multiplies two numbers, throws on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {

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

    function div(uint256 a, uint256 b) internal pure returns(uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return a / b;

    }



    /**

     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

     * @dev Adds two numbers, throws on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {

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

        require(msg.sender == owner);

        _;

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

        require(!paused, "Contract Paused. Events/Transaction Paused until Further Notice");

        _;

    }



    /**

    * @dev Modifier to make a function callable only when the contract is paused.

    */

    modifier whenPaused() {

        require(paused, "Contract Functionality Resumed");

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



contract StandardToken is Pausable {



    using SafeMath for uint256;



    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 supply;

    uint256 public initialSupply;

    uint256 public totalSupply;



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) internal allowed;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    constructor() public {

        name = "Firetoken";

        symbol = "FPWR";

        decimals = 18;

        supply = 1800000000;

        initialSupply = supply * (10 ** uint256(decimals));



        totalSupply = initialSupply;

        balances[owner] = totalSupply;



        bountyTransfers();

    }



    function bountyTransfers() internal {



        address marketingReserve;

        address devteamReserve;

        address bountyReserve;

        address teamReserve;



        uint256 marketingToken;

        uint256 devteamToken;

        uint256 bountyToken;

        uint256 teamToken;



        marketingReserve = 0x00Fe8117437eeCB51782b703BD0272C14911ECdA;

        bountyReserve = 0x0089F23EeeCCF6bd677C050E59697D1f6feB6227;

        teamReserve = 0x00FD87f78843D7580a4c785A1A5aaD0862f6EB19;

        devteamReserve = 0x005D4Fe4DAf0440Eb17bc39534929B71a2a13F48;



        marketingToken = ( totalSupply * 10 ) / 100;

        bountyToken = ( totalSupply * 10 ) / 100;

        teamToken = ( totalSupply * 26 ) / 100;

        devteamToken = ( totalSupply * 10 ) / 100;



        balances[msg.sender] = totalSupply - marketingToken - teamToken - devteamToken - bountyToken;

        balances[teamReserve] = teamToken;

        balances[devteamReserve] = devteamToken;

        balances[bountyReserve] = bountyToken;

        balances[marketingReserve] = marketingToken;



        emit Transfer(msg.sender, marketingReserve, marketingToken);

        emit Transfer(msg.sender, bountyReserve, bountyToken);

        emit Transfer(msg.sender, teamReserve, teamToken);

        emit Transfer(msg.sender, devteamReserve, devteamToken);

    }



    /**

    * @dev Transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(_value <= balances[msg.sender]);

        require(_to != address(0));



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

    function balanceOf(address _owner) public view whenNotPaused returns (uint256) {

        return balances[_owner];

    }



    /**

    * @dev Transfer tokens from one address to another

    * @param _from address The address which you want to send tokens from

    * @param _to address The address which you want to transfer to

    * @param _value uint256 the amount of tokens to be transferred

    */

    function transferFrom( address _from, address _to, uint256 _value ) public whenNotPaused returns (bool) {

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);

        require(_to != address(0));



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

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {

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

    function allowance(address _owner, address _spender) public view whenNotPaused returns (uint256) {

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

    function increaseApproval( address _spender, uint256 _addedValue ) public whenNotPaused returns (bool) {

        allowed[msg.sender][_spender] = ( allowed[msg.sender][_spender].add(_addedValue));

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

    function decreaseApproval( address _spender, uint256 _subtractedValue ) public whenNotPaused returns (bool) {

        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue >= oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



}



contract Firetoken is StandardToken {



    using SafeMath for uint256;



    mapping (address => uint256) public freezed;



    event Burn(address indexed burner, uint256 value);

    event Mint(address indexed to, uint256 amount);

    event Withdraw(address indexed _from, address indexed _to, uint256 _value);

    event Freeze(address indexed from, uint256 value);

    event Unfreeze(address indexed from, uint256 value);



    /**

    * @dev Burns a specific amount of tokens.

    * @param _value The amount of token to be burned.

    */

    function burn(uint256 _value) public onlyOwner whenNotPaused {

        _burn(msg.sender, _value);

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



    function burnFrom(address _from, uint256 _value) public onlyOwner whenNotPaused {

        require(_value <= allowed[_from][msg.sender]);

        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,

        // this function needs to emit an event with the updated approval.

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        _burn(_from, _value);

    }



    /**

    * @dev Function to mint tokens

    * @param _to The address that will receive the minted tokens.

    * @param _amount The amount of tokens to mint.

    * @return A boolean that indicates if the operation was successful.

    */

    function mint(address _to, uint256 _amount) public onlyOwner whenNotPaused returns (bool) {

        totalSupply = totalSupply.add(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Mint(_to, _amount);

        emit Transfer(address(0), _to, _amount);

        return true;

    }



    function freeze(address _spender,uint256 _value) public onlyOwner whenNotPaused returns (bool success) {

        require(_value < balances[_spender]);

        require(_value >= 0); 

        balances[_spender] = balances[_spender].sub(_value);                     

        freezed[_spender] = freezed[_spender].add(_value);                               

        emit Freeze(_spender, _value);

        return true;

    }

	

    function unfreeze(address _spender,uint256 _value) public onlyOwner whenNotPaused returns (bool success) {

        require(freezed[_spender] < _value);

        require(_value <= 0); 

        freezed[_spender] = freezed[_spender].sub(_value);                      

        balances[_spender] = balances[_spender].add(_value);

        emit Unfreeze(_spender, _value);

        return true;

    }

    

    function withdrawEther(address _account) public onlyOwner whenNotPaused payable returns (bool success) {

        _account.transfer(address(this).balance);



        emit Withdraw(this, _account, address(this).balance);

        return true;

    }



    function() public payable {

        

    }



}