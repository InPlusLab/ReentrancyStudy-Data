pragma solidity ^0.4.24;

contract OrderString {
 
    string internal _orderString = "�w�Ϳz���t���^˪ѩ���y���հ��R�S�������ʮ����һ��ǧ�ﲻ�������˷���ȥ������c���e�^�����Ó��ϥǰ�M������캥���x�����������Ȼ�Z��[�����p�ۻ�������������������w�]��鳺��������@ǧ�����ʿ�Ӻմ����ǿv���b���㲻�M����Ӣ�l�ܕ��w�°���̫����";
    function getOrderString () view external returns(string) {
        return _orderString;
    }
}