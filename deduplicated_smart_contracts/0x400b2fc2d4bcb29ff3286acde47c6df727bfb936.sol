import "./StandardToken.sol";
pragma solidity ^0.4.8;
contract MToken is StandardToken {
    /* Public variables of the token */
    string public name;                   //����: eg Davie
    uint8 public decimals;                //����С��λ��How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //token���: eg DAC
    string public version = 'H0.1';       //�汾

    function MToken(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol,address owner) {
        balances[owner] = _initialAmount; // ��ʼtoken����������Ϣ������
        totalSupply = _initialAmount;         // ���ó�ʼ����
        name = _tokenName;                   // token����
        decimals = _decimalUnits;           // С��λ��
        symbol = _tokenSymbol;             // token���
    }
   
}