/**

 *Submitted for verification at Etherscan.io on 2018-10-23

*/



pragma solidity ^0.4.13;



library SafeMath {







  /**



  * @dev Multiplies two numbers, throws on overflow.



  */



  function mul(uint256 a, uint256 b) internal pure returns (uint256) {



    if (a == 0) {



      return 0;



    }



    uint256 c = a * b;



    require(c / a == b);



    return c;



  }







  /**



  * @dev Integer division of two numbers, truncating the quotient.



  */



  function div(uint256 a, uint256 b) internal pure returns (uint256) {



    require(b > 0); // Solidity automatically throws when dividing by 0



    uint256 c = a / b;



    return c;



  }







  /**



  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).



  */



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {



    require(b <= a);



    return a - b;



  }







  /**



  * @dev Adds two numbers, throws on overflow.



  */



  function add(uint256 a, uint256 b) internal pure returns (uint256) {



    uint256 c = a + b;



    require(c >= a);



    return c;



  }



}



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



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



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

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

  )

    public

    returns (bool)

  {

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

   *

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

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint _addedValue

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

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint _subtractedValue

  )

    public

    returns (bool)

  {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



contract Ownable 



{



  address public owner;



 



  constructor(address _owner) public 



  {



    owner = _owner;



  }



 



  modifier onlyOwner() 



  {



    require(msg.sender == owner);



    _;



  }



 



  function transferOwnership(address newOwner) onlyOwner 



  {



    require(newOwner != address(0));      



    owner = newOwner;



  }



}



contract BiLinkToken is StandardToken, Ownable {

	string public name = "BiLink"; 

	string public symbol = "BINK";

	uint256 public decimals = 18;

	uint256 public INITIAL_SUPPLY = 10000 * 10000 * (10 ** decimals);

	bool public mintingFinished = false;

	uint256 public totalMintableAmount;



	address public contractBalance;



	address public accountFoundation;

	address public accountCompany;

	address public accountPartnerBase;

	mapping (address => uint256) public lockedAccount2WithdrawTap;

	mapping (address => uint256) public lockedAccount2WithdrawedAmount;

	uint256 public lockStartTime;

	uint256 public lockEndTime;

	uint256 public releaseEndTime;

	uint256 public tapOfOne;

	uint256 public amountMinted;

	uint256 public lockTimeSpan;



	address[] public accountsCanShareProfit;//balance > 10000 * (10 ** decimals)

	uint256 public amountMinCanShareProfit;



	event Burn(address indexed burner, uint256 value);

	event Mint(address indexed to, uint256 amount);

	event MintFinished();



	constructor(address _owner, address _accountFoundation, address _accountCompany, address _accountPartnerBase) public 

		Ownable(_owner)

	{

		totalSupply_ = INITIAL_SUPPLY* 70/ 100;

		accountFoundation= _accountFoundation;

		accountCompany= _accountCompany;

		accountPartnerBase= _accountPartnerBase;



		lockStartTime= now;

		lockTimeSpan= 1 * 365 * 24 * 3600;

		lockEndTime= now+ lockTimeSpan;

		releaseEndTime= now+ 2 * lockTimeSpan;



		balances[accountCompany]= INITIAL_SUPPLY* 40/ 100;

		balances[accountFoundation]= INITIAL_SUPPLY* 10/ 100;

		balances[accountPartnerBase]= INITIAL_SUPPLY* 20/ 100;



		tapOfOne= (10 ** decimals)/ (lockTimeSpan);

		lockedAccount2WithdrawTap[accountCompany]= tapOfOne.mul(balances[accountCompany]);

		lockedAccount2WithdrawTap[accountPartnerBase]= tapOfOne.mul(balances[accountPartnerBase]);



		accountsCanShareProfit.push(accountCompany);

		accountsCanShareProfit.push(accountFoundation);

		accountsCanShareProfit.push(accountPartnerBase);



		amountMinCanShareProfit= 10000 * (10 ** decimals);

		totalMintableAmount= INITIAL_SUPPLY * 30/ 100;

	}



	function setMintAndBurnOwner (address _contractBalance) public onlyOwner {

		contractBalance= _contractBalance;

	}



	function burn(uint256 _amount) public {

		require(msg.sender== contractBalance);

		require(_amount <= balances[msg.sender]);



		balances[msg.sender] = balances[msg.sender].sub(_amount);

		totalSupply_ = totalSupply_.sub(_amount);

		emit Burn(msg.sender, _amount);

		emit Transfer(msg.sender, address(0), _amount);

	}



	function transferToPartnerAccount(address _partner, uint256 _amount) onlyOwner {

		require(balances[accountPartnerBase].sub(_amount) > 0);



		balances[_partner]= balances[_partner].add(_amount);

		balances[accountPartnerBase]= balances[accountPartnerBase].sub(_amount);



		lockedAccount2WithdrawTap[_partner]= tapOfOne.mul(balances[_partner]);



		if(balances[_partner].sub(_amount) < amountMinCanShareProfit&& balances[_partner] >= amountMinCanShareProfit)

			accountsCanShareProfit.push(_partner);

	}



	modifier canMint() {

		require(!mintingFinished);

		_;

	}



	modifier hasMintPermission() {

		require(msg.sender == contractBalance);

		_;

	}



	modifier canTransfer(address _from, address _to, uint256 _value)  {

        require(_from != accountFoundation&& (lockedAccount2WithdrawTap[_from] <= 0 || now >= releaseEndTime || (now >= lockEndTime && _value <= (lockedAccount2WithdrawTap[_from].mul(now.sub(lockStartTime))).sub(lockedAccount2WithdrawedAmount[_from]))));

        _;

    }



	function mintFinished() public constant returns (bool) {

		return mintingFinished;

	}



	function mint(address _to, uint256 _amount)

		hasMintPermission

		canMint

		public

		returns (bool)

	{

		uint256 _actualMintAmount= _amount.mul(totalMintableAmount- amountMinted).div(totalMintableAmount);

		if(amountMinted.add(_actualMintAmount) > totalMintableAmount) {

			finishMinting();

			return false;

		}

		else {

			amountMinted= amountMinted.add(_actualMintAmount);

			totalSupply_ = totalSupply_.add(_actualMintAmount);

			balances[_to] = balances[_to].add(_actualMintAmount);



			emit Mint(_to, _actualMintAmount);

			emit Transfer(address(0), _to, _actualMintAmount);

			return true;

		}

	}



	function finishMinting() canMint private returns (bool) {

		mintingFinished = true;

		emit MintFinished();

		return true;

	}



	function preTransfer(address _from, address _to, uint256 _value) private {

		if(lockedAccount2WithdrawTap[_from] > 0)

			lockedAccount2WithdrawedAmount[_from]= lockedAccount2WithdrawedAmount[_from].add(_value);



		if(balances[_from] >= amountMinCanShareProfit && balances[_from].sub(_value) < amountMinCanShareProfit) {

			for(uint256 i= 0; i< accountsCanShareProfit.length; i++) {



				if(accountsCanShareProfit[i]== _from) {



					if(i< accountsCanShareProfit.length- 1&& accountsCanShareProfit.length> 1)



						accountsCanShareProfit[i]= accountsCanShareProfit[accountsCanShareProfit.length- 1];



					delete accountsCanShareProfit[accountsCanShareProfit.length- 1];



					accountsCanShareProfit.length--;



					break;



				}



			}

		}



		if(balances[_to] < amountMinCanShareProfit&& balances[_to].add(_value) >= amountMinCanShareProfit) {

			accountsCanShareProfit.push(_to);

		}

	}



	function transfer(address _to, uint256 _value) public canTransfer(msg.sender, _to, _value) returns (bool) {

		preTransfer(msg.sender, _to, _value);



        return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from, _to, _value) returns (bool) {

		preTransfer(_from, _to, _value);



        return super.transferFrom(_from, _to, _value);

    }



    function approve(address _spender, uint256 _value) public canTransfer(msg.sender, _spender, _value) returns (bool) {

        return super.approve(_spender,_value);

    }



	function getCanShareProfitAccounts() public constant returns (address[]) {

		return accountsCanShareProfit;

	}

}