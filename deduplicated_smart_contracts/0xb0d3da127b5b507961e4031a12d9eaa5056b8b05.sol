/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.

.*/
pragma solidity ^0.4.4;

import "./StandardToken.sol";

contract FML is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //token����: FML 
    uint8 public decimals;                //С��λ
    string public symbol;                 //��ʶ
    string public version = 'H0.1';       //�汾��

    function FML(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;               // ��Լ�����ߵ�����Ƿ�������
        totalSupply = _initialAmount;                        // ������
        name = _tokenName;                                   // token����
        decimals = _decimalUnits;                            // tokenС��λ
        symbol = _tokenSymbol;                               // token��ʶ
    }

    /* ��׼Ȼ����ý��պ�Լ */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //��������Ҫ֪ͨ��Լ�� receiveApprovalcall ���� ����������ǿ��Բ���Ҫ�����������Լ��ġ�
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //������ô���ǿ��Գɹ�����ȻӦ�õ���vanilla approve��
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}