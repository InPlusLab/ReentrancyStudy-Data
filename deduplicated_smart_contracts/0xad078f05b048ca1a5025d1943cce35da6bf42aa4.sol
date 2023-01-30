/**

 *Submitted for verification at Etherscan.io on 2019-06-06

*/



pragma solidity ^0.4.16;



interface token {

    function transfer(address receiver, uint amount);

}



contract Crowdsale {

    address public beneficiary;  // ļ�ʳɹ�����տ

    uint public fundingGoal;   // ļ�ʶ��

    uint public amountRaised;   // ��������

    uint public deadline;      // ļ�ʽ�ֹ��



    uint public price;    //  token ����̫���Ļ��� , token������Ǯ

    token public tokenReward;   // Ҫ����token



    mapping(address => uint256) public balanceOf;



    bool fundingGoalReached = false;  // �ڳ��Ƿ�ﵽĿ��

    bool crowdsaleClosed = false;   //  �ڳ��Ƿ����



    /**

    * �¼���������������Ϣ

    **/

    event GoalReached(address recipient, uint totalAmountRaised);

    event FundTransfer(address backer, uint amount, bool isContribution);



    /**

     * ���캯��, �����������

     */

    function Crowdsale(

        address ifSuccessfulSendTo,

        uint fundingGoalInEthers,

        uint durationInMinutes,

        uint finneyCostOfEachToken,

        address addressOfTokenUsedAsReward) {

            beneficiary = ifSuccessfulSendTo;

            fundingGoal = fundingGoalInEthers * 1 ether;

            deadline = now + durationInMinutes * 1 minutes;

            price = finneyCostOfEachToken * 1 szabo;

            tokenReward = token(addressOfTokenUsedAsReward);   // �����ѷ����� token ��Լ�ĵ�ַ������ʵ��

    }



    /**

     * �޺�������Fallback������

     * �����Լת��ʱ����������ᱻ����

     */

    function () payable {

        require(!crowdsaleClosed);

        uint amount = msg.value;

        balanceOf [msg.sender] += amount;

        amountRaised += amount;

        tokenReward.transfer(msg.sender, amount /price*10000000000000000);

        FundTransfer(msg.sender, amount, true);

    }



    /**

    *  ���庯���޸���modifier�����ú�Python��װ���������ƣ�

    * �����ں���ִ��ǰ���ĳ��ǰ���������ж�ͨ��֮��Ż����ִ�и÷�����

    * _ ��ʾ����ִ��֮��Ĵ���

    **/

    modifier afterDeadline() { if (now >= deadline) _; }



    /**

     * �ж��ڳ��Ƿ��������Ŀ�꣬ �������ʹ����afterDeadline�����޸���

     *

     */

    function checkGoalReached() afterDeadline {

        if (amountRaised >= fundingGoal) {

            fundingGoalReached = true;

            GoalReached(beneficiary, amountRaised);

        }

        crowdsaleClosed = true;

    }





    /**

     * �������Ŀ��ʱ�����ʿ�͵��տ

     * δ�������Ŀ��ʱ��ִ���˿�

     *

     */

    function safeWithdrawal() afterDeadline {

        if (!fundingGoalReached) {

            uint amount = balanceOf[msg.sender];

            balanceOf[msg.sender] = 0;

            if (amount > 0) {

                if (msg.sender.send(amount)) {

                    FundTransfer(msg.sender, amount, false);

                } else {

                    balanceOf[msg.sender] = amount;

                }

            }

        }



        if (fundingGoalReached && beneficiary == msg.sender) {

            if (beneficiary.send(amountRaised)) {

                FundTransfer(beneficiary, amountRaised, false);

            } else {

                //If we fail to send the funds to beneficiary, unlock funders balance

                fundingGoalReached = false;

            }

        }

    }

}