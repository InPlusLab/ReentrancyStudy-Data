/**

 *Submitted for verification at Etherscan.io on 2018-09-16

*/



pragma solidity ^0.4.24;



//���ѧ� ���ڧӧ֧���ӧ�֧� �ܧ�ާѧߧէ� ����֧ܧ�� SmartPromise

//���ѧߧߧ��� �ܧ�ߧ��ѧܧ� �ҧ�է֧� �ӧ���ݧѧ�ڧӧѧ�� ���ѧ� 7% ��� ���ѧ�֧ԧ� �ӧܧݧѧէ� �ܧѧاէ��� �է֧ߧ�, �� ���� �٧ߧѧ�ڧ�, ���� ���� �ӧ��ۧէ֧�� �� ��ݧ�� ��ا� ��֧�֧� 2 �ߧ֧է֧ݧ�

//���ߧ����ܧ�ڧ� �� ����, �ܧѧ� ��է֧ݧѧ�� �ӧܧݧѧ� ���� �ާ�ا֧�� �ߧѧۧ�� �ߧ� �ߧѧ�֧� ���ڧ�ڧѧݧ�ߧ�� ��ѧۧ��: 

//https://smartpromise.ru/

//����ݧ� �� ���ѧ� �֧��� �ܧѧܧڧ�-�ݧڧҧ� �ӧ������, ���� �ާ�ا֧�� �٧ѧէѧ�� �ڧ� �ߧѧ�֧ާ� ���֧�ѧ���� �� telegram:

//https://t.me/smartpromise



//���ѧݧ֧� ���֧է��ѧӧݧ֧� �ڧ���էߧ��� �ܧ�� �ߧѧ�֧ԧ� �ܧ�ߧ��ѧܧ�� �� ���է��ҧߧ��ާ� �ܧ�ާާ֧ߧ�ѧ�ڧ�ާ�, �ܧ������� ���ڧ���ӧѧ�� �֧ԧ� ��ѧҧ���

//����ߧ��ѧܧ� �٧ѧԧ��ا֧� �� �ҧݧ�ܧ�֧ۧ�, ������ާ� �֧ԧ� �ߧ֧ݧ�٧� �ڧ٧ާ֧ߧڧ�� �ڧݧ� ��էѧݧڧ��

//����٧էѧ�֧ݧ� �ܧ�ߧ��ѧܧ�� �ߧ� �ڧާ֧֧� �է����� �� ���֧է��ӧѧ�, �ܧ������� ���ѧߧ����� �ߧ� �ܧ�ߧ��ѧܧ��



contract SmartPromiseSEVEN {

   

    address owner; //����է� �٧ѧ��ާڧߧѧ֧� �ѧէ�֧� ��֧ܧݧѧާߧ�ԧ� ���ߧէ� �ܧ�ߧ��ѧܧ��

    mapping (address => uint256) balances; //���է֧�� �ާ� ���ѧߧڧ� ��ѧ�� �ѧէ�֧� -> �ҧѧݧѧߧ�

    mapping (address => uint256) timestamp; //���է֧�� �ާ� ���ѧߧڧ� ��ѧ�� �ѧէ�֧� -> �ӧ�֧ާ�



    constructor() public { owner = msg.sender;} //����� �ܧ�ߧ����ܧ���, �ܧ������� �ӧ��٧��ӧѧ֧��� ���� ���٧էѧߧڧ� �ܧ�ߧ��ѧܧ�� �էݧ� �٧ѧ��ާڧߧѧߧڧ� �ѧէ�֧�� �֧ԧ� �ӧݧѧէ֧ݧ���

//����ߧܧ�ڧ�, �����֧��ӧݧ���ѧ� �ӧ���ݧѧ�� �� ��էߧ�ӧ�֧ާ֧ߧߧ� �� ���ڧ� ���ڧߧڧާѧ��ѧ� �ӧ٧ߧ���

    function() external payable {

        owner.send(msg.value / 10); //������ѧӧܧ� 10% ��� �ӧܧݧѧէ� �ߧ� �ѧէ�֧� ��֧ܧݧѧާߧ�ԧ� ���ߧէ� �ܧ�ߧ��ѧܧ��

        //������ݧѧ�� �����֧��ӧݧ�֧��� �֧�ݧ� �ҧѧݧѧߧ� �ѧէ�֧��, �ܧ������� �ӧ����ݧߧ�֧� �ܧ�ߧ��ѧܧ� �ߧ֧ߧ�ݧ֧ӧ��

        if (balances[msg.sender] != 0){

        address paymentAddress = msg.sender; //���ѧ�ڧ���ӧѧ֧� �� ��֧�֧ާ֧ߧߧ�� paymentAddress �ѧէ�֧� ���ԧ�, �ܧ�� �ӧ����ݧߧ�֧� �ܧ�ߧ��ѧܧ� �� �էѧߧߧ��� �ާ�ާ֧ߧ�

        uint256 paymentAmount = balances[msg.sender]*7/100*(block.number-timestamp[msg.sender])/5900; //�� ��֧�֧ާ֧ߧߧ�� paymentAmount �٧ѧ�ڧ���ӧѧ֧� ��ѧ٧ާ֧� �ӧ���ݧѧ��

        paymentAddress.send(paymentAmount); //������ѧӧݧ�֧� �ӧ���ݧѧ��

        }



        timestamp[msg.sender] = block.number; //���ҧߧ�ӧݧ�֧� �ӧ�֧ާ�

        balances[msg.sender] += msg.value;  //���ҧߧ�ӧݧ�֧� �ҧѧݧѧߧ�

    }

}







//�� �ڧ��ԧ�, �ܧѧ� ���� �ӧ�� ��ѧҧ��ѧ֧�

//���ܧݧѧէ�ڧ� �٧ѧܧڧէ��ӧѧ֧� ���ڧ� �ߧ� ���ק� �ܧ�ߧ��ѧܧ�� -> �� �ߧ֧ԧ� ��ҧߧ�ӧݧ�֧��� �ҧѧݧѧߧ� �� �ӧ�֧ާ֧ߧߧѧ� �ާ֧�ܧ� �ӧݧ�ا֧ߧڧ�

//�� �ݧ�ҧ�� �ާ�ާ֧ߧ� �ӧܧݧѧէ�ڧ� �ާ�ا֧� �ӧ��ӧ֧��� �����֧ߧ� ���ާާ�, �� �٧ѧӧڧ�ڧާ���� ��� �ӧ�֧ާ֧ߧ� (7 �����֧ߧ��� �� ����ܧ�)

//�����ӧ�� �����֧��ӧݧ�֧��� ���� �����ݧߧ֧ߧڧ� �ӧܧݧѧէ�. ���� �֧��� ����ҧ� �ӧ��ӧ֧��� ��ӧ�� �����֧ߧ� �ߧ֧�ҧ��էڧާ� �����ݧߧڧ�� �ӧܧݧѧ� �ߧ� 0 ETH