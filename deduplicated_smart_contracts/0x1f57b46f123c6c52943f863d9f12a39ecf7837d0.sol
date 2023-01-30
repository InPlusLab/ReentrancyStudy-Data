/**

 *Submitted for verification at Etherscan.io on 2018-11-15

*/



pragma solidity 0.4.25;

/**

 * �ⲿ�����ⲿ���ҡ�

 */

 interface token {

    function transfer(address receiver, uint amount) external;

}



/**

 * �ڳ��Լ

 */

contract Crowdsale {

    address public beneficiary = msg.sender; //�����˵�ַ������ʱΪ��Լ������

    uint public fundingGoal;  //�ڳ�Ŀ�꣬��λ��ether

    uint public amountRaised; //�ѳＯ��������� ��λ��ether

    uint public deadline; //��ֹʱ��

    uint public price;  //���Ҽ۸�

    token public tokenReward;   // Ҫ����token

    bool public fundingGoalReached = false;  //����ڳ�Ŀ��

    bool public crowdsaleClosed = false; //�ڳ�ر�





    mapping(address => uint256) public balance; //�����ڳ��ַ����Ӧ����̫������



    // �����˽��ڳ���ת�ߵ�֪ͨ

    event GoalReached(address _beneficiary, uint _amountRaised);



    // ������¼�ڳ��ʽ�䶯��֪ͨ��_isContribution��ʾ�Ƿ��Ǿ�������Ϊ�п����Ǿ������˳�������ת���ڳ��ʽ�

    event FundTransfer(address _backer, uint _amount, bool _isContribution);



    /**

     * ��ʼ�����캯��

     *

     * @param fundingGoalInEthers �ڳ���̫������

     * @param durationInMinutes �ڳ��ֹ,��λ�Ƿ���

     */

    constructor(

        uint fundingGoalInEthers,

        uint durationInMinutes,

        uint TokenCostOfEachether,

        address addressOfTokenUsedAsReward

    )  public {

        fundingGoal = fundingGoalInEthers * 1 ether;

        deadline = now + durationInMinutes * 1 minutes;

        price = TokenCostOfEachether ; //1����̫�ҿ����򼸸�����

        tokenReward = token(addressOfTokenUsedAsReward); 

    }





    /**

     * Ĭ�Ϻ���

     *

     * Ĭ�Ϻ������������Լֱ�Ӵ��

     */

    function () payable public {



        //�ж��Ƿ�ر��ڳ�

        require(!crowdsaleClosed);

        uint amount = msg.value;



        //����˵Ľ���ۼ�

        balance[msg.sender] += amount;



        //����ܶ��ۼ�

        amountRaised += amount;



        //ת�ʲ�����ת���ٴ��Ҹ������

         tokenReward.transfer(msg.sender, amount * price);

         emit FundTransfer(msg.sender, amount, true);

    }



    /**

     * �ж��Ƿ��Ѿ������ڳ��ֹ����

     */

    modifier afterDeadline() { if (now >= deadline) _; }



    /**

     * ����ڳ�Ŀ���Ƿ��Ѿ��ﵽ

     */

    function checkGoalReached() afterDeadline public {

        if (amountRaised >= fundingGoal){

            //����ڳ�Ŀ��

            fundingGoalReached = true;

          emit  GoalReached(beneficiary, amountRaised);

        }



        //�ر��ڳ�

        crowdsaleClosed = true;

    }

    function backtoken(uint backnum) public{

        uint amount = backnum * 10 ** 18;

        tokenReward.transfer(beneficiary, amount);

       emit FundTransfer(beneficiary, amount, true);

    }

    

    function backeth() public{

        beneficiary.transfer(amountRaised);

        emit FundTransfer(beneficiary, amountRaised, true);

    }



    /**

     * �ջ��ʽ�

     *

     * ����Ƿ�ﵽ��Ŀ���ʱ�����ƣ�����У����Ҵﵽ���ʽ�Ŀ�꣬

     * ��ȫ�����͸������ˡ����û�дﵽĿ�꣬ÿ�������߶������˳�

     * ���ǹ��׵Ľ��

     * ע���������Ӧ�����������ڳ�ʱ��������ڳ�Ŀ��û�д�ɵ�����²������˳������ȥ����������afterDeadline��Ӧ���ǿ��������ڳ�ʱ�仹δ�����ڳ�Ŀ��û�д�ɵ�������˳�

     */

    function safeWithdrawal() afterDeadline public {



        //���û�д���ڳ�Ŀ��

        if (!fundingGoalReached) {

            //��ȡ��Լ�������Ѿ�����

            uint amount = balance[msg.sender];



            if (amount > 0) {

                //���غ�Լ�������������

                beneficiary.transfer(amountRaised);

                emit  FundTransfer(beneficiary, amount, false);

                balance[msg.sender] = 0;

            }

        }



        //�������ڳ�Ŀ�꣬���Һ�Լ��������������

        if (fundingGoalReached && beneficiary == msg.sender) {



            //�����о��Ӻ�Լ�и�������

            beneficiary.transfer(amountRaised);



          emit  FundTransfer(beneficiary, amount, false);

        }

    }

}