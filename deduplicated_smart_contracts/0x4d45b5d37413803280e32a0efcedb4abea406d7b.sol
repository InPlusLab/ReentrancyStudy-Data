/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity 0.4.24;

contract Eneat {
    //������
    string public name;
    //token ��־
    string public symbol;
    ////token С��λ��
    uint public decimals;

    //ת���¼�֪ͨ
    event Transfer(address indexed from, address indexed to, uint256 value);

    // ����һ�������������û������
    mapping(address => uint256) public balanceOf;


    /* Constructor */
    constructor (uint256 initialSupply,string tokenName, string tokenSymbol, uint8 decimalUnits) public {
        //��ʼ���ҽ��(�ܶ�Ҫȥ��С��λ�����õĳ���)
        balanceOf[msg.sender] = initialSupply;
        name = tokenName;                                 
        symbol = tokenSymbol;                               
        decimals = decimalUnits; 
    }

    //ת�˲���
    function transfer(address _to,uint256 _value) public {
        //���ת���Ƿ��������� 1.ת���˻�����Ƿ���� 2.ת������Ƿ����0 �����Ƿ񳬳�����
        require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        //ת��֪ͨ
        emit Transfer(msg.sender, _to, _value);
    }

}