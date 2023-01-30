/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

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
/*
This implements ONLY the standard functions and NOTHING else.
For a token like you would want to deploy in something like Mist, see HumanStandardToken.sol.

If you deploy this, you won't have anything useful.

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20

ʵ��ERC20��׼
.*/

pragma solidity ^0.4.4;



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Ĭ��token���������ܳ���(2^256 - 1)
        //����㲻���÷���������������ʱ��ķ��͸����token����Ҫȷ��û�г������ֵ��ʹ������� if ���
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}
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



contract KPICoin is StandardToken {

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
    string public name;                   //token����: KPICoin 
    uint8 public decimals;                //С��λ
    string public symbol;                 //��ʶ
    string public version = 'H0.1';       //�汾��

    function KPICoin(
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

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}