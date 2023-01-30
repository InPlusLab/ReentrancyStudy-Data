/**

 *Submitted for verification at Etherscan.io on 2018-09-03

*/



pragma solidity ^0.4.13;



/**

 * @title Ownable

 * @dev ����ӵ�к�ͬҵ����ַ�����ṩ������Ȩ�޿��ƹ��ܣ������û���Ȩ��ִ�С���

 */

contract Ownable {

  address public owner;





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() {

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

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) onlyOwner {

    if (newOwner != address(0)) {

      owner = newOwner;

    }

  }



}



/**

 * @title Destructible

 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.

 */

contract Destructible is Ownable {



  function Destructible() payable { }



  /**

   * @dev Transfers the current balance to the owner and terminates the contract.

   */

  function destroy() onlyOwner {

    selfdestruct(owner);

  }



  function destroyAndSend(address _recipient) onlyOwner {

    selfdestruct(_recipient);

  }

}

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}

/**

 * @title PullPayment

 * @dev Base contract supporting async send for pull payments. Inherit from this

 * contract and use asyncSend instead of send.

 */

contract PullPayment {

  using SafeMath for uint256;



  mapping(address => uint256) public payments;

  uint256 public totalPayments;



  /**

  * @dev Called by the payer to store the sent amount as credit to be pulled.

  * @param dest The destination address of the funds.

  * @param amount The amount to transfer.

  */

  function asyncSend(address dest, uint256 amount) internal {

    payments[dest] = payments[dest].add(amount);

    totalPayments = totalPayments.add(amount);

  }



  /**

  * @dev withdraw accumulated balance, called by payee.

  */

  function withdrawPayments() {

    address payee = msg.sender;

    uint256 payment = payments[payee];



    require(payment != 0);

    require(this.balance >= payment);



    totalPayments = totalPayments.sub(payment);

    payments[payee] = 0;



    assert(payee.send(payment));

  }

}



contract Generatable{

    function generate(

        address token,

        address contractOwner,

        uint256 cycle

    ) public returns(address);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

  function decimals() public view returns (uint8);  //���ҵ�λ

  function totalSupply() public view returns (uint256);



  function balanceOf(address _who) public view returns (uint256);



  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transfer(address _to, uint256 _value) public returns (bool);



  function approve(address _spender, uint256 _value)

    public returns (bool);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}

/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(

    ERC20 _token,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transfer(_to, _value));

  }



  function safeTransferFrom(

    ERC20 _token,

    address _from,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transferFrom(_from, _to, _value));

  }



  function safeApprove(

    ERC20 _token,

    address _spender,

    uint256 _value

  )

    internal

  {

    require(_token.approve(_spender, _value));

  }

}





contract ContractFactory is Destructible,PullPayment{

    using SafeERC20 for ERC20;

    uint256 public diviRate;

    uint256 public developerTemplateAmountLimit;

    address public platformWithdrawAccount;





	struct userContract{

		uint256 templateId;

		uint256 orderid;

		address contractAddress;

		uint256 incomeDistribution;

		uint256 creattime;

		uint256 endtime;

	}



	struct contractTemplate{

		string templateName;

		address contractGeneratorAddress;

		string abiStr;

		uint256 startTime;

		uint256 endTime;

		uint256 startUp;

		uint256 profit;

		uint256 quota;

		uint256 cycle;

		address token;

	}



    mapping(address => userContract[]) public userContractsMap;

    mapping(uint256 => contractTemplate) public contractTemplateAddresses;

    mapping(uint256 => uint256) public skipMap;



    event ContractCreated(address indexed creator,uint256 templateId,uint256 orderid,address contractAddress);

    event ContractTemplatePublished(uint256 indexed templateId,address  creator,string templateName,address contractGeneratorAddress);

    event Log(address data);

    event yeLog(uint256 balanceof);

    function ContractFactory(){

        //0~10

        diviRate=5;

        platformWithdrawAccount=0x4b533502d8c4a11c7e7de42b89d8e3833ebf6aeb;

        developerTemplateAmountLimit=500000000000000000;

    }



    function generateContract(uint256 templateId,uint256 orderid) public returns(address){



        //����֧������ҵ���Ӧģ��

        contractTemplate storage ct = contractTemplateAddresses[templateId];

        if(ct.contractGeneratorAddress!=0x0){

            address contractTemplateAddress = ct.contractGeneratorAddress;

            string templateName = ct.templateName;

            require(block.timestamp >= ct.startTime);

            require(block.timestamp <= ct.endTime);

            //�ҵ���Ӧ������������Ŀ���Լ

            Generatable generator = Generatable(contractTemplateAddress);

            address target = generator.generate(ct.token,msg.sender,ct.cycle);

            //��¼�û���Լ

            userContract[] storage userContracts = userContractsMap[msg.sender];

            userContracts.push(userContract(templateId,orderid,target,1,now,now.add(uint256(1 days))));

            ContractCreated(msg.sender,templateId,orderid,target);

            return target;

        }else{

            revert();

        }

    }



    function returnOfIncome(address user,uint256 _index) public{

        require(msg.sender == user);

        userContract[] storage ucs = userContractsMap[user];

        if(ucs[_index].contractAddress!=0x0 && ucs[_index].incomeDistribution == 1){

            contractTemplate storage ct = contractTemplateAddresses[ucs[_index].templateId];

            if(ct.contractGeneratorAddress!=0x0){

                //������ڼ���ʱ��1�콫���ֺܷ�

                if(now > ucs[_index].creattime.add(uint256(1 days))){

                     revert();

                }



                ERC20 token = ERC20(ct.token);

                uint256 balanceof = token.balanceOf(ucs[_index].contractAddress);



                uint256 decimals = token.decimals();

                //��Ҫ������Ͷ��

                //���С��ǰ10�� ��4w��Ͷ��

                if(now < ct.startTime.add(uint256(10 days))){

        		    if(balanceof < ct.startUp.sub(10000).mul(10**uint256(decimals))){

                        revert();    

                    } 

                } else {

                   if(balanceof < ct.startUp.mul(10**uint256(decimals))){

                        revert();    

                    } 

                }

                

             

                //��Ҫת���Ӻ�Լ������

                uint256 income = ct.profit.mul(ct.cycle).mul(balanceof).div(36000);



                if(!token.transfer(ucs[_index].contractAddress,income)){

        			revert();

        		} else {

        		    ucs[_index].incomeDistribution = 2;

        		}

        		//�ǹ����� 

        		

        		if(now < ct.startTime.add(uint256(10 days))){

        		    uint256 incomes = balanceof.div(10);

                    if(!token.transfer(ucs[_index].contractAddress,incomes)){

            			revert();

            		}

                }

            }else{

                revert();

            }

        }else{

            revert();

        }

    }



    /**

    *������ʵ��Generatable�ӿ�,���Һ�Լʵ����ownerable�ӿڣ�������ͨ���˺����ϴ���TODO�����У�飿��

    * @param templateId   ģ��Id

    * @param _templateName   ģ������

    * @param _contractGeneratorAddress   ģ������ģ������Ī

    * @param _abiStr   abi�ӿ�

    * @param _startTime  ��ʼʱ��

    * @param _endTime   ����ʱ��

    * @param _profit  ����

    * @param _startUp ��Ͷ

    * @param _quota   �޶�

    * @param _cycle   ����

    * @param _token   ���Һ�Լ

    */

    function publishContractTemplate(

        uint256 templateId,

        string _templateName,

        address _contractGeneratorAddress,

        string _abiStr,

        uint256 _startTime,

        uint256 _endTime,

        uint256 _profit,

        uint256 _startUp,

        uint256 _quota,

        uint256 _cycle,

        address _token

    )

        public

    {

         //��owner����������ģ��

         if(msg.sender!=owner){

            revert();

         }



         contractTemplate storage ct = contractTemplateAddresses[templateId];

         if(ct.contractGeneratorAddress!=0x0){

            revert();

         }else{



            ct.templateName = _templateName;

            ct.contractGeneratorAddress = _contractGeneratorAddress;

            ct.abiStr = _abiStr;

            ct.startTime = _startTime;

            ct.endTime = _endTime;

            ct.startUp = _startUp;

            ct.profit = _profit;

            ct.quota = _quota;

            ct.cycle = _cycle;

            ct.token = _token;

            ContractTemplatePublished(templateId,msg.sender,_templateName,_contractGeneratorAddress);

         }

    }

    

    /**

    *����

    */

    function putforward(

        address _token,

        address _value

    )

        public

    {

       

        if(msg.sender!=owner){

            revert();

        }

        ERC20 token = ERC20(_token);

        uint256 balanceof = token.balanceOf(address(this));



        if(!token.transfer(_value,balanceof)){

			revert();

		}

    }

    



    function queryPublishedContractTemplate(

        uint256 templateId

    )

        public

        constant

    returns(

        string,

        address,

        string,

        uint256,

        uint256,

        uint256,

        uint256,

        uint256,

        uint256,

        address

    ) {

        contractTemplate storage ct = contractTemplateAddresses[templateId];

        if(ct.contractGeneratorAddress!=0x0){

            return (

                ct.templateName,

                ct.contractGeneratorAddress,

                ct.abiStr,

                ct.startTime,

                ct.endTime,

                ct.profit,

                ct.startUp,

                ct.quota,

                ct.cycle,

                ct.token

            );

        }else{

            return ('',0x0,'',0,0,0,0,0,0,0x0);

        }

    }





    function queryUserContract(address user,uint256 _index) public constant returns(

        uint256,

        uint256,

        address,

        uint256,

        uint256,

        uint256

    ){

        userContract[] storage ucs = userContractsMap[user];

        contractTemplate storage ct = contractTemplateAddresses[ucs[_index].templateId];

        ERC20 tokens = ERC20(ct.token);

        uint256 balanceofs = tokens.balanceOf(ucs[_index].contractAddress);

        return (

            ucs[_index].templateId,

            ucs[_index].orderid,

            ucs[_index].contractAddress,

            ucs[_index].incomeDistribution,

            ucs[_index].endtime,

            balanceofs

        );

    }

   

    function queryUserContractCount(address user) public constant returns (uint256){

        userContract[] storage ucs = userContractsMap[user];

        return ucs.length;

    }



    function changeDiviRate(uint256 _diviRate) external onlyOwner(){

        diviRate=_diviRate;

    }



    function changePlatformWithdrawAccount(address _platformWithdrawAccount) external onlyOwner(){

        platformWithdrawAccount=_platformWithdrawAccount;

    }



    function changeDeveloperTemplateAmountLimit(uint256 _developerTemplateAmountLimit) external onlyOwner(){

        developerTemplateAmountLimit=_developerTemplateAmountLimit;

    }

    function addSkipPrice(uint256 price) external onlyOwner(){

        skipMap[price]=1;

    }



    function removeSkipPrice(uint256 price) external onlyOwner(){

        skipMap[price]=0;

    }

}