/**

 *Submitted for verification at Etherscan.io on 2018-08-31

*/



pragma solidity 0.4.18;

/**

 * һ���򵥵Ĵ��Һ�Լ��

 */

 contract FAMELINK{



     string public name; //��������

     string public symbol; //���ҷ��ű���'$'

     uint8 public decimals = 18;  //���ҵ�λ��չʾ��С���������ٸ�0,����̫��һ����������18��0

     uint256 public totalSupply; //��������

     /* This creates an array with all balances */

     mapping (address => uint256) public balanceOf;



     event Transfer(address indexed from, address indexed to, uint256 value);  //ת��֪ͨ�¼�





     /* ��ʼ����Լ�����Ұѳ�ʼ�����д��Ҷ������Լ�Ĵ�����

      * @param _owned ��Լ�Ĺ�����

      * @param tokenName ��������

      * @param tokenSymbol ���ҷ���

      */

     function FAMELINK(uint256 initialSupply,address _owned, string tokenName, string tokenSymbol) public{

          totalSupply = initialSupply * 10 ** uint256(decimals);  // ��С��λ����ʼ������

         //��Լ�Ĺ����߻�õĴ�������

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





  }