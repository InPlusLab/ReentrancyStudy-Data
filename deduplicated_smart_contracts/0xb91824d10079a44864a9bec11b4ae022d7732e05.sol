pragma solidity ^0.4.8;

//���Һ�Լ
 contract token {
     string public name = "cao token"; //��������
     string public symbol = "CAO"; //���ҷ��ű���'$'
     uint8 public decimals = 18;  //���ҵ�λ��չʾ��С���������ٸ�0,����̫��һ����������18��0
     uint256 public totalSupply; //��������,����û��������,��Ҳ�����޶�

    //��ַ��Ӧ�����
     mapping (address => uint256) public balanceOf;

     event Transfer(address indexed from, address indexed to, uint256 value);  //ת��֪ͨ�¼�

     /* ��ʼ����Լ�����Ұѳ�ʼ�����д��Ҷ������Լ�Ĵ�����
      * @param _owned ��Լ�Ĺ�����
      * @param tokenName ��������
      * @param tokenSymbol ���ҷ���
      */

     function token(address _owned, string tokenName, string tokenSymbol) public {
         //��Լ�Ĵ����߻�õ����д���
         balanceOf[_owned] = totalSupply;
         name = tokenName;
         symbol = tokenSymbol;
     }

     /**
      * ת�ʣ�������Ը����Լ���������ʵ��
      * @param  _to address ���ܴ��ҵĵ�ַ
      * @param  _value uint256 ���ܴ��ҵ�����
      */
     function transfer(address _to, uint256 _value) public{
       //�ӷ����߼������Ͷ�
       balanceOf[msg.sender] -= _value;

       //�������߼�����ͬ����
       balanceOf[_to] += _value;

       //֪ͨ�κμ����ý��׵Ŀͻ���
       Transfer(msg.sender, _to, _value);
     }

     /**
      * ���Ӵ��ң��������ҷ��͸��������û�,����ν������,���Ĺ̶�����,
      * @param  _to address ���ܴ��ҵĵ�ַ
      * @param  _amount uint256 ���ܴ��ҵ�����
      */
     function issue(address _to, uint256 _amount) public{
         totalSupply = totalSupply + _amount;
         balanceOf[_to] += _amount;

         //֪ͨ�κμ����ý��׵Ŀͻ���
         Transfer(this, _to, _amount);
     }
  }

/**
 * �ڳ��Լ
 */
contract CAOsale is token {
    address public beneficiary = msg.sender; //�����˵�ַ������ʱΪ��Լ������,�Լ����Լ�
    uint public fundingGoal;  //�ڳ�Ŀ�꣬��λ��ether
    uint public amountRaised; //�ѳＯ��������� ��λ��wei
    uint public deadline; //��ֹʱ��
    uint public price;  //���Ҽ۸�
    bool public fundingGoalReached = false;  //����ڳ�Ŀ��,Ĭ��δ���
    bool public crowdsaleClosed = false; //�ڳ�ر�,Ĭ�ϲ��ر�


    mapping(address => uint256) public balance; //�����ڳ��ַ

    //��¼�ѽ��յ�eth֪ͨ
    event GoalReached(address _beneficiary, uint _amountRaised);

    //ת��ʱ�¼�
    event FundTransfer(address _backer, uint _amount, bool _isContribution);

    /**
     * ��ʼ�����캯��
     * @param fundingGoalInEthers �ڳ���̫������
     * @param durationInMinutes �ڳ��ֹ,��λ�Ƿ���
     * @param tokenName ��������
     * @param tokenSymbol ���ҷ���
     */

    //  �ڳ�ʼ���ڳ��Լ���캯����ʱ�����ǻὫ�ڳ��Լ���ʻ���ַ��
    //  ���ݸ�������Ϊ�����ַ������ʹ�õ��ǹؼ���this��ʾ��ǰ��Լ�ĵ�ַ��
    //  Ҳ���Դ��ݸ�ĳ���ˣ���ʼ����ʱ�����������ָ�����Ĵ��ҡ�
    function CAOsale(
        uint fundingGoalInEthers,
        uint durationInMinutes,
        string tokenName,
        string tokenSymbol
    ) public token(this, tokenName, tokenSymbol){
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = 0.00001 ether; //1����̫�ҿ����� 1 ������
    }

    // ���ڳ��Լ�У����������ڳ���̫���������ڳ��ֹʱ�䡢��̫�Һʹ��ҵĶһ�����,
    // �����ʹ�õ�λ�����������㣬Ĭ������̫���У����еĵ�λ����wei��1 ether=10^18 wei��

    /**
     * Ĭ�Ϻ���
     *
     * Ĭ�Ϻ������������Լֱ�Ӵ��
     */
    function () payable public{
        //�ж��Ƿ�ر��ڳ�
        //����ر�,���ֹ���.
        require(!crowdsaleClosed);
        // if (!crowdsaleClosed) throw; �������д��,�汾��Ӱ�!
        uint amount = msg.value;

        //����˵Ľ���ۼ�
        balance[msg.sender] += amount;

        //����ܶ��ۼ�
        amountRaised += amount;

        //ת�ʲ�����ת���ٴ��Ҹ������
        issue(msg.sender, amount / price * 10 ** uint256(decimals));
        FundTransfer(msg.sender, amount, true);
    }

    /**
     * �ж��Ƿ��Ѿ������ڳ��ֹ����
     */
    modifier afterDeadline() {
        // if (this == msg.sender && now >= deadline) _; ���Ҹ÷���ֻ�ܱ������ߵ���,�ϸ�һ��
        if (now >= deadline) _;
        }

    /**
     * ����ڳ�Ŀ���Ƿ����
     */
    function checkGoalReached() afterDeadline public{
        if (amountRaised >= fundingGoal){
            //����ڳ�Ŀ��
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        //�ر��ڳ�,��ֹ���
        crowdsaleClosed = true;
    }

    /**
     * �ջ��ʽ�
     * ����Ƿ�ﵽ��Ŀ���ʱ�����ƣ�����У����Ҵﵽ���ʽ�Ŀ�꣬
     * ��ȫ�����͸������ˡ����û�дﵽĿ�꣬ÿ�������߶������˳�
     * ���ǹ��׵Ľ��
     */
    function safeWithdrawal() afterDeadline public{

        //���û�д���ڳ�Ŀ��,��մ���
        if (!fundingGoalReached) {
            //��ȡ��Լ�������Ѿ�����
            uint amount = balance[msg.sender];

            if (amount > 0) {
                //���غ�Լ�������������
                //transfer���Դ��ķ���,���ǳ�msg.senderת����������˼.���Ʒ������� send
                //�ĵ������ַ:http://solidity.readthedocs.io/en/develop/types.html#members-of-addresses
                msg.sender.transfer(amount);
                FundTransfer(msg.sender, amount, false);
                balance[msg.sender] = 0;
            }
        }

        //�������ڳ�Ŀ�꣬���Һ�Լ��������������
        if (fundingGoalReached && beneficiary == msg.sender) {

            //�����о��Ӻ�Լ�и�������
            beneficiary.transfer(amountRaised);

            FundTransfer(beneficiary, amount, false);
        }
    }
}