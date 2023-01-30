/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



pragma solidity ^0.4.12;

contract Token{

    // token������Ĭ�ϻ�Ϊpublic��������һ��getter�����ӿڣ�����ΪtotalSupply().

    uint256 public totalSupply;



    /// ��ȡ�˻�_ownerӵ��token������ 

    function balanceOf(address _owner) constant returns (uint256 balance);



    //����Ϣ�������˻�����_to�˻�ת����Ϊ_value��token

    function transfer(address _to, uint256 _value) returns (bool success);



    //���˻�_from�����˻�_toת����Ϊ_value��token����approve�������ʹ��

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);



    //��Ϣ�����˻������˻�_spender�ܴӷ����˻���ת������Ϊ_value��token

    function approve(address _spender, uint256 _value) returns (bool success);



    //��ȡ�˻�_spender���Դ��˻�_owner��ת��token������

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);



    //����ת��ʱ����Ҫ�������¼� 

    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    //������approve(address _spender, uint256 _value)�ɹ�ִ��ʱ���봥�����¼�

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract QFBToken is Token {

    address manager;

//    mapping(address => bool) accountFrozen;

    mapping(address => uint) frozenTime;



    modifier onlyManager() {

        require(msg.sender == manager);

        _;

    }



    function freeze(address account, bool frozen) public onlyManager {

        frozenTime[account] = now + 10 minutes;

//        accountFrozen[account] = frozen;

    }



    function transfer(address _to, uint256 _value) returns (bool success) {

        if(balances[msg.sender] >= _value && _value > 0) {

            require(balances[msg.sender] >= _value);

            balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value

            balances[_to] += _value;//�������˻�����token����_value

            Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�

            freeze(_to, true);

            return true;

        }

        

    }





    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        require(frozenTime[_from] <= now);

        

        if(balances[_from] >= _value  && _value > 0) {

            balances[_to] += _value;

            balances[_from] -= _value;

            Transfer(_from, _to, _value);



            return true;

        } else {

            return false;

        }

    }

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }





    function approve(address _spender, uint256 _value) returns (bool success)   

    {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }





    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];//����_spender��_owner��ת����token��

    }

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;



    string public constant name = "QFBCOIN";                   //����: eg Simon Bucks

    uint256 public constant decimals = 18;               //����С��λ����How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.

    string public constant symbol = "QFB";               //token���: eg SBX

    string public version = 'QF1.0';    //�汾



    // contracts

    address public ethFundDeposit;          // ETH��ŵ�ַ

    address public newContractAddr;         // token���µ�ַ



    // crowdsale parameters

    bool    public isFunding;                // ״̬�л���true

    uint256 public fundingStartBlock;

    uint256 public fundingStopBlock;



    uint256 public currentSupply;           // ���������е�tokens����

    uint256 public tokenRaised = 0;         // �ܵ���������token

    uint256 public tokenMigrated = 0;     // �ܵ��Ѿ����׵� token

    uint256 public tokenExchangeRate = 625;             // 625 BILIBILI �һ� 1 ETH



    // events

    event AllocateToken(address indexed _to, uint256 _value);   // �����˽�н���token;

    event IssueToken(address indexed _to, uint256 _value);      // ��������������token;

    event IncreaseSupply(uint256 _value);

    event DecreaseSupply(uint256 _value);

    event Migrate(address indexed _to, uint256 _value);



     // ת��

    function formatDecimals(uint256 _value) internal returns (uint256) {

        return _value * 10 ** decimals;

    }



    // constructor

    function QFBToken( address _ethFundDeposit, uint256 _currentSupply) {

        ethFundDeposit = _ethFundDeposit;



        isFunding = false;

        //ͨ������ԤCrowdS ale״̬

        fundingStartBlock = 0;

        fundingStopBlock = 0;

        currentSupply = formatDecimals(_currentSupply);

        totalSupply = formatDecimals(10000);

        balances[msg.sender] = totalSupply;

        manager = msg.sender;

        if (currentSupply > totalSupply) throw;

    }

}