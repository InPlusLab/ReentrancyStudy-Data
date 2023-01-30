/**

 *Submitted for verification at Etherscan.io on 2019-02-03

*/



pragma solidity 0.4.25;





library SafeMath {



	/**

	* @dev Multiplies two numbers, throws on overflow.

	*/

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {

		if (a == 0) {

			return 0;

		}

		uint256 c = a * b;

		assert(c / a == b);

		return c;

	}



	/**

	* @dev Integer division of two numbers, truncating the quotient.

	*/

	function div(uint256 a, uint256 b) internal pure returns (uint256) {

		// assert(b > 0); // Solidity automatically throws when dividing by 0

		uint256 c = a / b;

		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;

	}



	/**

	* @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

	*/

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {

		assert(b <= a);

		return a - b;

	}



	/**

	* @dev Adds two numbers, throws on overflow.

	*/

	function add(uint256 a, uint256 b) internal pure returns (uint256) {

		uint256 c = a + b;

		assert(c >= a);

		return c;

	}



}





contract Ownable {

	address private _owner;

	event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);



	/**

	* @dev The Ownable constructor sets the original `owner` of the contract to the sender

	* account.

	*/

	constructor() internal {

		_owner = msg.sender;

		emit OwnershipTransferred(address(0), _owner);

	}



	/**

	* @return the address of the owner.

	*/

	function owner() public view returns(address) {

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

	function isOwner() public view returns(bool) {

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





contract RicoContract is Ownable {

	

	using SafeMath for uint256;

	

	string public name;

	string public symbol;

	uint32 public decimals;

	

	uint256 private  _totalSupply;

	mapping(address => uint256) private  _balances;

	mapping (address => mapping (address => uint256)) private  _allowed;

	

	event Approval(address indexed owner, address indexed spender, uint256 value);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event CreateOrder(address indexed owner, uint256 indexed amount, uint256 indexed price);

	

	struct Stage{

		uint256 leadTime;

		uint256 startTime;

		uint256 amount;

		uint256 amountLimit;

		uint256 price;

		bool additional;

	}

	Stage[] public stages;

	

	uint256 constant public minLeadTime = 1 minutes; 

	

	struct Order{

	    address owner;

		uint256 price;

		uint256 amount;

	}

	Order[] public orders;

	

	mapping( address => mapping( uint256 => uint256 ) ) public stageBalances;



	modifier onlyValidStage() {

		require( getCurrentStage() > 0 );

		_;

	}

	



    /**

     * @dev Create new oprder

     * @param _price Price for one token

     * @param _amount Total tokens amount

     */

	function createOrder( uint256 _price, uint256 _amount ) public 

	{

	    require( _balances[msg.sender] > 0 && _balances[msg.sender] >= _amount );

	    require( _price > 0 && _amount > 0 );

	    

	    _pushOrder(msg.sender, _price, _amount);

	    _transfer( msg.sender, address( this ), _amount );

	    emit CreateOrder( msg.sender, _amount, _price );

	}

	

	/**

     * @dev Delete order by id

     * @param _orderID order id

     */

	function removeOrder( uint256 _orderID ) public

	{

	    require( orders[_orderID].owner == msg.sender && orders[_orderID].amount > 0 );

	    _transfer( address( this ), orders[_orderID].owner, orders[_orderID].amount );

	    delete(orders[_orderID]);

	}

	

	/**

     * @dev Total number of stages

     */

	function getStageCount() public view returns( uint256 )

	{

	    return stages.length;

	}

	

	/**

     * @dev Internal function that implements the creation new order

     * @param _address owner address

     * @param _price token price

     * @param _amount Total tokens amount

     */

    function _pushOrder( address _address, uint256 _price, uint256 _amount ) internal returns( uint256 )

    {

        orders.push(Order({

            owner: _address,

            price: _price,

            amount: _amount

        }));

        

        return orders.length-1;

    }

    

    /**

     * @dev Function return total orders count

     */

    function getOrdersCount() public view returns( uint256 )

    {

        return orders.length;

    }



    /**

     * @dev Buying tokens in oreder

     * @param _orderID order id

     */

    function buyByOrder( uint256 _orderID ) public payable

    {

        require( msg.value % orders[_orderID].price == 0 );

        uint256 _calcTokens = msg.value.div( orders[_orderID].price ) *1 ether;

        

        require( _calcTokens <= orders[_orderID].amount );

        

        orders[_orderID].owner.transfer(msg.value);

        _transfer( address(this), msg.sender, _calcTokens );

        orders[_orderID].amount = orders[_orderID].amount.sub( _calcTokens );

    }



	/**

	* @dev Default setting

	*/

	constructor() public {

		

		stages.push(Stage({

			leadTime: 1 days, 

			startTime: 0,

			amount:0,

			amountLimit: 3 ether,

			price: 0.1 ether,

			additional: false

		}));

		

		stages.push(Stage({

			leadTime: 7 days, 

			startTime: 0,

			amount:0,

			amountLimit: 11 ether,

			price: 0.1 ether,

			additional: false

		}));

		

		stages.push(Stage({

			leadTime: 7 days, 

			startTime: 0,

			amount:0,

			amountLimit:  4.5 ether,

			price: 0.1 ether,

			additional: false

		}));

		

		stages.push(Stage({

			leadTime: 30 days, 

			startTime: 0,

			amount:0,

			amountLimit:  12.7 ether,

			price: 0.1 ether,

			additional: false

		}));

		

		stages.push(Stage({

			leadTime: 7 days, 

			startTime: 0,

			amount:0,

			amountLimit:  3.5 ether,

			price: 0.1 ether,

			additional: false

		}));



		name = "RICO";

		symbol = "RICO";

		decimals = 18;

		

		require( checkDefaultStages() );

	}

	

	

	/**

     * @dev Buying tokens 

     */

	function() public payable 

	{

		buy();

	}

	

	/**

     * @dev Function that implements the buying tokens

     */

	function buy() public payable onlyValidStage

	{

	    uint256 _stage = getCurrentStage()-1;

	    

	    require( msg.value % stages[_stage].price == 0 );

		require( msg.value >= stages[_stage].price );

		require( stages[_stage].amount.add( msg.value ) <= stages[_stage].amountLimit );

		

		uint256 _calcTokens = msg.value.div( stages[_stage].price ) * 1 ether;

		_mint( this, _calcTokens );

		_transfer(this, msg.sender, _calcTokens);

		stages[_stage].amount = stages[_stage].amount.add( msg.value );

		stageBalances[msg.sender][_stage] = stageBalances[msg.sender][_stage].add( _calcTokens );

		

		if( stages[_stage].amount == stages[_stage].amountLimit && stages[_stage].startTime == 0)

	        _fixStateStartTime( _stage );

	}

	

	

	/**

     * @dev Sselling tokens to smart contract

     */

	function sell( uint256 _amount ) public onlyValidStage

	{

		_sell( msg.sender, _amount );

	}

	

	

	/**

     * @dev Internal function that implements the selling tokens

     */

	function _sell( address _from, uint256 _amount ) internal

	{

	    uint256 _stage = getCurrentStage()-1;

	    uint256 _ethamount = _amount.div(1 ether).mul( stages[_stage].price );

	    

	    require( stageBalances[_from][_stage] >= _amount );

		require( stages[_stage].amount >= _ethamount );

		

		stages[getCurrentStage()-1].amount = stages[_stage].amount.sub( _ethamount );

		_from.transfer( _ethamount );

		_burn( _from, _amount );

		stageBalances[_from][_stage] = stageBalances[_from][_stage].sub( _amount );

	}

	



	/**

     * @dev Function checks the validity of the stages conditions.

     */

	function checkDefaultStages() internal view returns(bool)

	{

	    uint256 i;

	    

		for( i = 1; i < stages.length; i++ ){

			if( stages[i].leadTime < minLeadTime ) return false;

		}



		for( i = 1; i < stages.length; i++ ){

			if( stages[i].startTime != 0 ) return false;

		}

		

		for( i = 1; i < stages.length; i++ ){

			if( stages[i].price < stages[i-1].price ) return false;

		}

		

		for( i = 0; i <= stages.length - 1; i++ ){

			if( stages[i].additional == true ) return false;

		}



		return true;

	}

	

	/**

     * @dev Internal function which records the time of the stage after fees

     * @param _stageID stage id

     */

	function _fixStateStartTime( uint256 _stageID ) internal

	{

	    require( stages[_stageID].amount >= stages[_stageID].amountLimit );

	    require( stages[_stageID].startTime == 0 );

	    

	    stages[_stageID].startTime = now;

	}

	

	/**

     * @dev Function which records the time of the stage after fees

     * @param _stageID stage id

     */

	function fixStateStartTime( uint256 _stageID ) public onlyOwner

	{

	    _fixStateStartTime( _stageID );

	}

	

	/**

     * @dev Function return current stage

     */

	function getCurrentStage() public view returns( uint256 )

	{

		for( uint256 i = 0; i < stages.length; i++ ){

		    

		    if( stages[i].startTime == 0 )

		        return i + 1;

	        else

	            if( now < stages[i].startTime.add( stages[i].leadTime ) )

	                return i + 1;

			

		}

		

		return 0;

	}

	



    /**

     * @dev Withdrawal of funds from the smart contract

     * @param _amount amount tokens

     * @param _address address where to send eth

     * @param _stageID stage id

     */

	function withdraw( uint256 _amount, address _address, uint256 _stageID ) public onlyOwner

	{

		require( getCurrentStage() >= 2 || getCurrentStage() == 0 );

		require( _amount <= stages[_stageID].amount );

		require( stages[_stageID].startTime != 0 );

		

		require( now > stages[_stageID].startTime.add( stages[_stageID].leadTime ) );

		_address.transfer( _amount );

		stages[_stageID].amount = stages[_stageID].amount.sub( _amount );

	}





    /**

     * @dev Add new stage

     * @param _leadTime stage development time

     * @param _amountLimit required amount of funds

     * @param _price token price

     */

	function addStage( uint256 _leadTime, uint256 _amountLimit, uint256 _price ) public onlyOwner

	{

		require( _leadTime >= minLeadTime );

		require( _price >= stages[stages.length-1].price );

		

		stages.push(Stage({

			leadTime: _leadTime, 

			startTime: 0,

			amount: 0,

			amountLimit: _amountLimit,

			price: _price,

			additional: true

		}));

	}

	

	/**

     * @dev Delete stage by id

     * @param _stageID stage id

     */

	function deleteStage( uint256 _stageID ) public onlyOwner

	{

		require( stages[_stageID].additional );

		require( stages[_stageID].amount == 0 );

		delete stages[ _stageID ];

	}





    /**

     * @dev Transfer token for a specified addresses

     * @param _from The address to transfer from.

     * @param _to The address to transfer to.

     * @param _amount The amount to be transferred.

     */

	function _transfer(address _from, address _to, uint256 _amount) internal returns (bool)

	{

		require(_to != address(0));

		require(_amount <= _balances[_from]);

		

		_balances[_from] = _balances[_from].sub(_amount);

		_balances[_to] = _balances[_to].add(_amount);

		emit Transfer(_from, _to, _amount);

		return true;

	}





    /**

     * @dev Transfer token for a specified address

     * @param _to The address to transfer to.

     * @param _amount The amount to be transferred.

     */

	function transfer(address _to, uint256 _amount) public returns (bool)

	{

	    if( _to == address( this ) )

	        _sell( msg.sender, _amount );

        else

		    _transfer(msg.sender, _to, _amount);

		    

		return true;

	}





    /**

     * @dev Gets the balance of the specified address.

     * @param _owner The address to query the balance of.

     * @return An uint256 representing the amount owned by the passed address.

     */

	function balanceOf(address _owner) public view returns (uint256 balance)

	{

		return _balances[_owner];

	}

	

	/**

     * @dev Total number of tokens in existence

     */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }

	

	

	/**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _amount uint256 the amount of tokens to be transferred

     */

	function transferFrom(address _from, address _to, uint256 _amount) public returns (bool)

	{

		require(_amount <= _allowed[_from][msg.sender]);

		_allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_amount);

		

		if( _to == address( this ) )

	        _sell( _from, _amount );

        else

		    _transfer(_from, _to, _amount);

		    

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

	function approve(address _spender, uint256 _value) public returns (bool)

	{

		_allowed[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);

		return true;

	}

	

	

	/**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param _owner address The address which owns the funds.

     * @param _spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

	function allowance(address _owner, address _spender) public view returns (uint256)

	{

		return _allowed[_owner][_spender];

	}

	

	/**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param _spender The address which will spend the funds.

     * @param _addedValue The amount of tokens to increase the allowance by.

     */

	function increaseAllowance(address _spender, uint _addedValue) public returns (bool)

	{

		_allowed[msg.sender][_spender] = _allowed[msg.sender][_spender].add(_addedValue);

		emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);

		return true;

	}

	

	/**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param _spender The address which will spend the funds.

     * @param _subtractedValue The amount of tokens to decrease the allowance by.

     */

	function decreaseAllowance(address _spender, uint _subtractedValue) public returns (bool)

	{

		uint oldValue = _allowed[msg.sender][_spender];

		

		if (_subtractedValue > oldValue) {

			_allowed[msg.sender][_spender] = 0;

		} else {

			_allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

		}



		emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);

		return true;

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