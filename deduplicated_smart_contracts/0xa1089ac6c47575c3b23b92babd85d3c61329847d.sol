pragma solidity ^0.4.16;
contract Refund {
    address owner = 0x0;
    function Refund() public payable {
        // �������Լ�ĵ�ַ��Ϊ��Լӵ����
        owner = msg.sender;
    }
    

}