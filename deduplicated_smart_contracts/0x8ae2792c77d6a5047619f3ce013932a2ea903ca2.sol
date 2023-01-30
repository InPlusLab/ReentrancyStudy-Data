pragma solidity ^0.4.4;

contract Token {

    /// @return ����token�ķ�����
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner ��ѯ��̫����ַtoken���
    /// @return The balance �������
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice msg.sender�����׷����ߣ����� _value��һ���������� token �� _to�������ߣ�  
    /// @param _to �����ߵĵ�ַ
    /// @param _value ����token������
    /// @return �Ƿ�ɹ�
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice ������ ���� _value��һ���������� token �� _to�������ߣ�  
    /// @param _from �����ߵĵ�ַ
    /// @param _to �����ߵĵ�ַ
    /// @param _value ���͵�����
    /// @return �Ƿ�ɹ�
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice ���з� ��׼ һ����ַ����һ��������token
    /// @param _spender ��Ҫ����token�ĵ�ַ
    /// @param _value ����token������
    /// @return �Ƿ�ɹ�
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner ӵ��token�ĵ�ַ
    /// @param _spender ���Է���token�ĵ�ַ
    /// @return �������͵�token������
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    /// ����Token�¼�
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    /// ��׼�¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
