/**

 *Submitted for verification at Etherscan.io on 2018-09-28

*/



pragma solidity ^0.4.24;



contract Token{

    // token������Ĭ�ϻ�Ϊpublic��������һ��getter�����ӿڣ�����ΪtotalSupply().

    uint256 public totalSupply;



    /// ��ȡ�˻�_ownerӵ��token������ 

    function balanceOf(address _owner) constant returns (uint256 balance);



    //����Ϣ�������˻�����_to�˻�ת����Ϊ_value��token

    function transfer(address _to, uint256 _value) returns (bool success);



    //���˻�_from�����˻�_toת����Ϊ_value��token����approve�������ʹ��

    function transferFrom(address _from, address _to, uint256 _value) returns   

    (bool success);



    //��Ϣ�����˻������˻�_spender�ܴӷ����˻���ת������Ϊ_value��token

    function approve(address _spender, uint256 _value) returns (bool success);



    //��ȡ�˻�_spender���Դ��˻�_owner��ת��token������

    function allowance(address _owner, address _spender) constant returns 

    (uint256 remaining);



    //����ת��ʱ����Ҫ�������¼� 

    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    //������approve(address _spender, uint256 _value)�ɹ�ִ��ʱ���봥�����¼�

    event Approval(address indexed _owner, address indexed _spender, uint256 

    _value);

}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {

        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).

        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣

        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value

        balances[_to] += _value;//�������˻�����token����_value

        Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�

        return true;

    }





    function transferFrom(address _from, address _to, uint256 _value) returns 

    (bool success) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= 

        // _value && balances[_to] + _value > balances[_to]);

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;//�����˻�����token����_value

        balances[_from] -= _value; //֧���˻�_from��ȥtoken����_value

        allowed[_from][msg.sender] -= _value;//��Ϣ�����߿��Դ��˻�_from��ת������������_value

        Transfer(_from, _to, _value);//����ת�ҽ����¼�

        return true;

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

}



// ERC20 standard token

contract MUSD is StandardToken{

    

    address public admin; // ����Ա

    string public name = "CHINA MOROCCO MERCANTILE EXCHANGE"; // ��������

    string public symbol = "MUSD"; // ���ҷ���

    uint8 public decimals = 18; // ���Ҿ���

    uint256 public INITIAL_SUPPLY = 10000000000000000000000000; // ����80�� *10^18

    // ͬһ���˻��������ⶳ��������������

    mapping (address => bool) public frozenAccount; //�����ڶ�����˻�

    mapping (address => uint256) public frozenTimestamp; // �����ڶ�����˻�



    bool public exchangeFlag = true; // ���Ҷһ�����

    // ������������ļ����ɶ����eth�����ظ�ԭ�˻�

    uint256 public minWei = 1;  //��ʹ� 1 wei  1eth = 1*10^18 wei

    uint256 public maxWei = 20000000000000000000000; // ���һ�δ� 20000 eth

    uint256 public maxRaiseAmount = 20000000000000000000000; // ļ������ 20000 eth

    uint256 public raisedAmount = 0; // ��ļ�� 0 eth

    uint256 public raiseRatio = 200000; // �һ����� 1eth = 20��token

    // event ֪ͨ

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);



    // ���캯��

    constructor() public {

        totalSupply = INITIAL_SUPPLY;

        admin = msg.sender;

        balances[msg.sender] = INITIAL_SUPPLY;

    }



    // fallback ���Լ��ַת�� or ���÷Ǻ�Լ��������

    // �����Զ��һ�eth

    function()

    public payable {

        require(msg.value > 0);

        if (exchangeFlag) {

            if (msg.value >= minWei && msg.value <= maxWei){

                if (raisedAmount < maxRaiseAmount) {

                    uint256 valueNeed = msg.value;

                    raisedAmount = raisedAmount + msg.value;

                    if (raisedAmount > maxRaiseAmount) {

                        uint256 valueLeft = raisedAmount - maxRaiseAmount;

                        valueNeed = msg.value - valueLeft;

                        msg.sender.transfer(valueLeft);

                        raisedAmount = maxRaiseAmount;

                    }

                    if (raisedAmount >= maxRaiseAmount) {

                        exchangeFlag = false;

                    }

                    // �Ѵ�������� *10^18

                    uint256 _value = valueNeed * raiseRatio;



                    require(_value <= balances[admin]);

                    balances[admin] = balances[admin] - _value;

                    balances[msg.sender] = balances[msg.sender] + _value;



                    emit Transfer(admin, msg.sender, _value);



                }

            } else {

                msg.sender.transfer(msg.value);

            }

        } else {

            msg.sender.transfer(msg.value);

        }

    }



    /**

    * �޸Ĺ���Ա

    */

    function changeAdmin(

        address _newAdmin

    )

    public

    returns (bool)  {

        require(msg.sender == admin);

        require(_newAdmin != address(0));

        balances[_newAdmin] = balances[_newAdmin] + balances[admin];

        balances[admin] = 0;

        admin = _newAdmin;

        return true;

    }

    /**

    * ����

    */

    function generateToken(

        address _target,

        uint256 _amount

    )

    public

    returns (bool)  {

        require(msg.sender == admin);

        require(_target != address(0));

        balances[_target] = balances[_target] + _amount;

        totalSupply = totalSupply + _amount;

        INITIAL_SUPPLY = totalSupply;

        return true;

    }



    // �Ӻ�Լ����

    // ֻ���������Ա

    function withdraw (

        uint256 _amount

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        msg.sender.transfer(_amount);

        return true;

    }

    /**

    * �����˻�

    */

    function freeze(

        address _target,

        bool _freeze

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        require(_target != address(0));

        frozenAccount[_target] = _freeze;

        return true;

    }

    /**

    * ͨ��ʱ��������˻�

    */

    function freezeWithTimestamp(

        address _target,

        uint256 _timestamp

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        require(_target != address(0));

        frozenTimestamp[_target] = _timestamp;

        return true;

    }



    /**

        * ���������˻�

        */

    function multiFreeze(

        address[] _targets,

        bool[] _freezes

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        require(_targets.length == _freezes.length);

        uint256 len = _targets.length;

        require(len > 0);

        for (uint256 i = 0; i < len; i += 1) {

            address _target = _targets[i];

            require(_target != address(0));

            bool _freeze = _freezes[i];

            frozenAccount[_target] = _freeze;

        }

        return true;

    }

    /**

            * ����ͨ��ʱ��������˻�

            */

    function multiFreezeWithTimestamp(

        address[] _targets,

        uint256[] _timestamps

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        require(_targets.length == _timestamps.length);

        uint256 len = _targets.length;

        require(len > 0);

        for (uint256 i = 0; i < len; i += 1) {

            address _target = _targets[i];

            require(_target != address(0));

            uint256 _timestamp = _timestamps[i];

            frozenTimestamp[_target] = _timestamp;

        }

        return true;

    }

    /**

    * ����ת��

    */

    function multiTransfer(

        address[] _tos,

        uint256[] _values

    )

    public

    returns (bool) {

        require(!frozenAccount[msg.sender]);

        require(now > frozenTimestamp[msg.sender]);

        require(_tos.length == _values.length);

        uint256 len = _tos.length;

        require(len > 0);

        uint256 amount = 0;

        for (uint256 i = 0; i < len; i += 1) {

            amount = amount + _values[i];

        }

        require(amount <= balances[msg.sender]);

        for (uint256 j = 0; j < len; j += 1) {

            address _to = _tos[j];

            require(_to != address(0));

            balances[_to] = balances[_to] + _values[j];

            balances[msg.sender] = balances[msg.sender] - _values[j];

            emit Transfer(msg.sender, _to, _values[j]);

        }

        return true;

    }

    /**

    * �ӵ�����ת����_to

    */

    function transfer(

        address _to,

        uint256 _value

    )

    public

    returns (bool) {

        require(!frozenAccount[msg.sender]);

        require(now > frozenTimestamp[msg.sender]);

        require(_to != address(0));

        require(_value <= balances[msg.sender]);



        balances[msg.sender] = balances[msg.sender] - _value;

        balances[_to] = balances[_to] + _value;



        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    /*

    * �ӵ�������Ϊfrom����from�˻��е�tokenת����to

    * ��������from����ɶ���б���>=value

    */

    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

    public

    returns (bool)

    {

        require(!frozenAccount[_from]);

        require(now > frozenTimestamp[msg.sender]);

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);



        balances[_from] = balances[_from] - _value;

        balances[_to] = balances[_to] + _value;

        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;



        emit Transfer(_from, _to, _value);

        return true;

    }

    /**

    * ����ת�˴���spender�Ĵ������ɶ��

    */

    function approve(

        address _spender,

        uint256 _value

    ) public

    returns (bool) {

        // ת�˵�ʱ���У��balances���ô�require������

        // require(_value <= balances[msg.sender]);



        allowed[msg.sender][_spender] = _value;



        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    /**

    * ����ת�˴���spender�Ĵ������ɶ��

    * ���岻���function

    */

    function increaseApproval(

        address _spender,

        uint256 _addedValue

    )

    public

    returns (bool)

    {

        // uint256 value_ = allowed[msg.sender][_spender].add(_addedValue);

        // require(value_ <= balances[msg.sender]);

        // allowed[msg.sender][_spender] = value_;



        // emit Approval(msg.sender, _spender, value_);

        return true;

    }

    /**

    * ����ת�˴���spender�Ĵ������ɶ��

    * ���岻���function

    */

    function decreaseApproval(

        address _spender,

        uint256 _subtractedValue

    )

    public

    returns (bool)

    {

        // uint256 oldValue = allowed[msg.sender][_spender];

        // if (_subtractedValue > oldValue) {

        //    allowed[msg.sender][_spender] = 0;

        // } else {

        //    uint256 newValue = oldValue.sub(_subtractedValue);

        //    require(newValue <= balances[msg.sender]);

        //   allowed[msg.sender][_spender] = newValue;

        //}



        // emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    //********************************************************************************

    //��ѯ�˻��Ƿ��������ʱ���

    function getFrozenTimestamp(

        address _target

    )

    public view

    returns (uint256) {

        require(_target != address(0));

        return frozenTimestamp[_target];

    }

    //��ѯ�˻��Ƿ�����

    function getFrozenAccount(

        address _target

    )

    public view

    returns (bool) {

        require(_target != address(0));

        return frozenAccount[_target];

    }

    //��ѯ��Լ�����

    function getBalance()

    public view

    returns (uint256) {

        return address(this).balance;

    }

    // �޸�name

    function setName (

        string _value

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        name = _value;

        return true;

    }

    // �޸�symbol

    function setSymbol (

        string _value

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        symbol = _value;

        return true;

    }



    // �޸�ļ��flag

    function setExchangeFlag (

        bool _flag

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        exchangeFlag = _flag;

        return true;



    }

    // �޸ĵ���ļ������

    function setMinWei (

        uint256 _value

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        minWei = _value;

        return true;



    }

    // �޸ĵ���ļ������

    function setMaxWei (

        uint256 _value

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        maxWei = _value;

        return true;

    }

    // �޸���ļ������

    function setMaxRaiseAmount (

        uint256 _value

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        maxRaiseAmount = _value;

        return true;

    }



    // �޸���ļ����

    function setRaisedAmount (

        uint256 _value

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        raisedAmount = _value;

        return true;

    }



    // �޸�ļ������

    function setRaiseRatio (

        uint256 _value

    )

    public

    returns (bool) {

        require(msg.sender == admin);

        raiseRatio = _value;

        return true;

    }



    // ���ٺ�Լ

    function kill()

    public {

        require(msg.sender == admin);

        selfdestruct(admin);

    }



}