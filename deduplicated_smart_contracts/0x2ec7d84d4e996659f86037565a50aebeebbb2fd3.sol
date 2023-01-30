/**

 *Submitted for verification at Etherscan.io on 2018-08-18

*/



pragma solidity ^0.4.24;





contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}

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



contract KAA is ERC20,Pausable{

	using SafeMath for uint256;



	//the base info of the token

	string public constant name="KAA";

	string public constant symbol="KAA";

	string public constant version = "1.0";

	uint256 public constant decimals = 18;







	//ƽ̨����13395000000

	uint256 public constant PLATFORM_FUNDING_SUPPLY=13395000000*10**decimals;





	//��ʼ�Ŷ�13395000000

	uint256 public constant TEAM_KEEPING=13395000000*10**decimals;



	//ս�Ի��8037000000	

	uint256 public constant COOPERATE_REWARD=8037000000*10**decimals;



	//������8930000000

	uint256 public constant SHARDING_REWARD=8930000000*10**decimals;



	//�ڿ���45543000000

	uint256 public constant MINING_REWARD=45543000000*10**decimals;



	//����ͨ���ֶ��8930000000+45543000000=54473000000

	uint256 public constant COMMON_WITHDRAW_SUPPLY=SHARDING_REWARD+MINING_REWARD;





	//�ܷ���54473000000+13395000000+13395000000+8037000000=89300000000

	uint256 public constant MAX_SUPPLY=COMMON_WITHDRAW_SUPPLY+PLATFORM_FUNDING_SUPPLY+TEAM_KEEPING+COOPERATE_REWARD;



	//�ڲ����ֻ�׼ʱ��

	uint256 public innerlockStartTime;

	//�ⲿ���ֻ�׼ʱ��

	uint256 public outterlockStartTime;

	//����������30�죩

	uint256 public unlockStepLong;



	//ƽ̨������

	uint256 public platformFundingSupply;

	//ƽ̨ÿ�ڿ�����

	uint256 public platformFundingPerEpoch;



	//�Ŷ�������

	uint256 public teamKeepingSupply;

	//�Ŷ�ÿ�ڿ�����

	uint256 public teamKeepingPerEpoch;



	//ս�Ի���Ѿ��ַ����

	uint256 public cooperateRewardSupply;





	//�Ѿ���ͨ������

	uint256 public totalCommonWithdrawSupply;



    //ս�Ի�������ܶ��

    mapping(address=>uint256) public lockAmount;

	 

	//ERC20�����

    mapping(address => uint256) balances;

	mapping (address => mapping (address => uint256)) allowed;

	



     constructor() public{

		totalSupply = 0 ;



		platformFundingSupply=0;

		teamKeepingSupply=0;

		cooperateRewardSupply=0;

		totalCommonWithdrawSupply=0;



		//��12�ڽ��� 13395000000/12

		platformFundingPerEpoch=1116250000*10**decimals;

		teamKeepingPerEpoch=1116250000*10**decimals;





		//��ʼʱ�� 20210818

		innerlockStartTime = 1629216000;

		//��ʼʱ�� 20190818

		outterlockStartTime=1566057600;



		unlockStepLong=2592000;



	}



	event CreateKAA(address indexed _to, uint256 _value);





	modifier notReachTotalSupply(uint256 _value){

		assert(MAX_SUPPLY>=totalSupply.add(_value));

		_;

	}



	//ƽ̨������ֶ��

	modifier notReachPlatformFundingSupply(uint256 _value){

		assert(PLATFORM_FUNDING_SUPPLY>=platformFundingSupply.add(_value));

		_;

	}



	modifier notReachTeamKeepingSupply(uint256 _value){

		assert(TEAM_KEEPING>=teamKeepingSupply.add(_value));

		_;

	}





	modifier notReachCooperateRewardSupply(uint256 _value){

		assert(COOPERATE_REWARD>=cooperateRewardSupply.add(_value));

		_;

	}



	modifier notReachCommonWithdrawSupply(uint256 _value){

		assert(COMMON_WITHDRAW_SUPPLY>=totalCommonWithdrawSupply.add(_value));

		_;

	}







	//ͳһ���ҷַ��������ڲ�ʹ��

	function processFunding(address receiver,uint256 _value) internal

		notReachTotalSupply(_value)

	{

		totalSupply=totalSupply.add(_value);

		balances[receiver]=balances[receiver].add(_value);

		emit CreateKAA(receiver,_value);

		emit Transfer(0x0, receiver, _value);

	}







	//��ͨ�ַ�,��������ڿ�ʹ��

	function commonWithdraw(uint256 _value) external

		onlyOwner

		notReachCommonWithdrawSupply(_value)



	{

		processFunding(msg.sender,_value);

		//�����Ѿ���ͨ���ַݶ�

		totalCommonWithdrawSupply=totalCommonWithdrawSupply.add(_value);

	}





	//ƽ̨������ң����ֱ����֣�12���ͷţ�

	function withdrawToPlatformFunding(uint256 _value) external

		onlyOwner

		notReachPlatformFundingSupply(_value)

	{

		//�жϿ����ֶ���Ƿ��㹻

		if (!canPlatformFundingWithdraw(_value)) {

			revert();

		}else{

			processFunding(msg.sender,_value);

			//ƽ̨�����ֶ��

			platformFundingSupply=platformFundingSupply.add(_value);

		}



	}	



	//�Ŷ���ң����ֱ����֣�12���ͷţ�

	function withdrawToTeam(uint256 _value) external

		onlyOwner

		notReachTeamKeepingSupply(_value)	

	{

		//�жϿ����ֶ���Ƿ��㹻

		if (!canTeamKeepingWithdraw(_value)) {

			revert();

		}else{

			processFunding(msg.sender,_value);

			//�Ŷ������ֶ��

			teamKeepingSupply=teamKeepingSupply.add(_value);

		}

	}



	//��Ҹ�ս�Ի�飨�ֱ����֣�12���ͷţ�

	function withdrawToCooperate(address _to,uint256 _value) external

		onlyOwner

		notReachCooperateRewardSupply(_value)

	{

		processFunding(_to,_value);

		cooperateRewardSupply=cooperateRewardSupply.add(_value);



		//��¼�ַ��ݶ�

		lockAmount[_to]=lockAmount[_to].add(_value);

	}



	//ƽ̨�Ƿ������

	function canPlatformFundingWithdraw(uint256 _value)public view returns (bool) {

		//���С�ڻ�׼ʱ�䣬ֱ�ӷ���false

		if(queryNow()<innerlockStartTime){

			return false;

		}



		//��ǰ����=����ʱ��-��ʼʱ��)/��������

		uint256 epoch=queryNow().sub(innerlockStartTime).div(unlockStepLong);

		//�������12��ʱ�䣬��ô������Ϊ12

		if (epoch>12) {

			epoch=12;

		}



		//�����Ѿ��ͷŶ�� = ÿ�ڿ����ֶ��*����

		uint256 releaseAmount = platformFundingPerEpoch.mul(epoch);

		//��������ֶ��=�Ѿ��ͷŶ��-�Ѿ����ֶ��

		uint256 canWithdrawAmount=releaseAmount.sub(platformFundingSupply);

		if(canWithdrawAmount>=_value){

			return true;

		}else{

			return false;

		}

	}



	function canTeamKeepingWithdraw(uint256 _value)public view returns (bool) {

		//���С�ڻ�׼ʱ�䣬ֱ�ӷ���false

		if(queryNow()<innerlockStartTime){

			return false;

		}



		//��ǰ����=����ʱ��-��ʼʱ��)/��������

		uint256 epoch=queryNow().sub(innerlockStartTime).div(unlockStepLong);

		//�������12��ʱ�䣬��ô������Ϊ12

		if (epoch>12) {

			epoch=12;

		}



		//�����Ѿ��ͷŶ�� = ÿ�ڿ����ֶ��*����

		uint256 releaseAmount=teamKeepingPerEpoch.mul(epoch);

		//��������ֶ��=�Ѿ��ͷŶ��-�Ѿ����ֶ��

		uint256 canWithdrawAmount=releaseAmount.sub(teamKeepingSupply);

		if(canWithdrawAmount>=_value){

			return true;

		}else{

			return false;

		}

	}





	function clacCooperateNeedLockAmount(uint256 totalLockAmount)public view returns (uint256) {

		//���С�ڻ�׼ʱ�䣬ֱ�ӷ������������

		if(queryNow()<outterlockStartTime){

			return totalLockAmount;

		}		

		

		//��ǰ����=����ʱ��-��ʼʱ��)/��������

		uint256 epoch=queryNow().sub(outterlockStartTime).div(unlockStepLong);

		//�������12��ʱ�䣬��ô������Ϊ12

		if (epoch>12) {

			epoch=12;

		}



		//ʣ������

		uint256 remainingEpoch=uint256(12).sub(epoch);



		//����ÿ�ڿ��ͷ�ת�˶�ȣ��ַܷ����/12��

		uint256 cooperatePerEpoch= totalLockAmount.div(12);



		//����ʣ�����ֶ�ȣ�ÿ�ڿ��ͷ�ת�˶��*ʣ��������

		return cooperatePerEpoch.mul(remainingEpoch);

	}

    function queryNow() public view returns(uint256){

        return now;

    }

	function () payable external

	{

		revert();

	}







  //ת��ǰ����У���ȥת���ݶ���Ƿ���ڵ������ַݶ�

  	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool)

 	{

		require(_to != address(0));



		//�������ַݶ�

		uint256 needLockBalance=0;

		if (lockAmount[msg.sender]>0) {

			needLockBalance=clacCooperateNeedLockAmount(lockAmount[msg.sender]);

		}





		require(balances[msg.sender].sub(_value)>=needLockBalance);



		// SafeMath.sub will throw if there is not enough balance.

		balances[msg.sender] = balances[msg.sender].sub(_value);

		balances[_to] = balances[_to].add(_value);

		emit Transfer(msg.sender, _to, _value);

		return true;

  	}



  	function balanceOf(address _owner) public constant returns (uint256 balance) 

  	{

		return balances[_owner];

  	}





  //��ί��������ת���ݶ�ʱ����Ҫ�ж�ί���˵����-ת���ݶ��Ƿ���ڵ������ַݶ�

  	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) 

  	{

		require(_to != address(0));



		//�������ַݶ�

		uint256 needLockBalance=0;

		if (lockAmount[_from]>0) {

			needLockBalance=clacCooperateNeedLockAmount(lockAmount[_from]);

		}





		require(balances[_from].sub(_value)>=needLockBalance);



		uint256 _allowance = allowed[_from][msg.sender];



		balances[_from] = balances[_from].sub(_value);

		balances[_to] = balances[_to].add(_value);

		allowed[_from][msg.sender] = _allowance.sub(_value);

		emit Transfer(_from, _to, _value);

		return true;

  	}



  	function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) 

  	{

		allowed[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);

		return true;

  	}



  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) 

  	{

		return allowed[_owner][_spender];

  	}

	  

}