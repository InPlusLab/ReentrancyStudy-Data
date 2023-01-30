/**

 *Submitted for verification at Etherscan.io on 2019-06-22

*/



pragma solidity ^0.4.25;

//ERC20��׼,һ����̫�����ҵı�׼

contract ERC20Interface {

  string public name;           //����string���͵�ERC20���ҵ�����

  string public symbol;         //����string���͵�ERC20���ҵķ��ţ�Ҳ���Ǵ��ҵļ�ƣ����磺SNT��

  uint8 public  decimals;       //֧�ּ�λС�����λ���������Ϊ3��Ҳ����֧��0.001��ʾ

  uint public totalSupply;      //���д��ҵ�����  

  //����transfer�������Լ���tokenת�˸�_to��ַ��_valueΪת�˸���

  function transfer(address _to, uint256 _value) returns (bool success);

  //������approve��������ʹ�ã�approve��׼֮�󣬵���transferFrom������ת��token��

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

  //��׼_spender�˻����Լ����˻�ת��_value��token�����Էֶ��ת�ơ�

  function approve(address _spender, uint256 _value) returns (bool success);

  //����_spender������ȡtoken�ĸ�����

  function allowance(address _owner, address _spender) view returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract ERC20 is ERC20Interface{

    mapping(address => uint256) public balanceOf;//��� 

    mapping(address =>mapping(address => uint256)) allowed;

    constructor(string _name,string _symbol,uint8 _decimals,uint _totalSupply) public{

         name = _name;                          //����string���͵�ERC20���ҵ�����

         symbol = _symbol;                      //����string���͵�ERC20���ҵķ��ţ�Ҳ���Ǵ��ҵļ�ƣ����磺SNT��

         decimals = _decimals;                   //֧�ּ�λС�����λ���������Ϊ3��Ҳ����֧��0.001��ʾ

         totalSupply = _totalSupply * 10 ** uint256(decimals);            //���д��ҵ�����  

         balanceOf[msg.sender]=_totalSupply;

    }

   //����transfer�������Լ���tokenת�˸�_to��ַ��_valueΪת�˸���

  function transfer(address _to, uint256 _value) public returns (bool success){

      require(_to!=address(0));//���Ŀ���ʺŲ����ڿ��ʺ� 

      require(balanceOf[msg.sender] >= _value);

      require(balanceOf[_to] + _value >=balanceOf[_to]);

      balanceOf[msg.sender]-=_value;

      balanceOf[_to]+=_value;

      emit Transfer(msg.sender,_to,_value);//�����¼�

      return true;

  }

  //������approve��������ʹ�ã�approve��׼֮�󣬵���transferFrom������ת��token��

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

      require(_to!=address(0));

      require(balanceOf[_from]>=_value);

      require(balanceOf[_to]+_value>balanceOf[_to]);

      require(allowed[_from][msg.sender]>_value);

      balanceOf[_from]-=_value;

      balanceOf[_to]+=_value;

      allowed[_from][msg.sender]-=_value;

      emit Transfer(_from,_to,_value);

      return true;

  }

  //��׼_spender�˻����Լ����˻�ת��_value��token�����Էֶ��ת�ơ�

  function approve(address _spender, uint256 _value) public returns (bool success){

      allowed[msg.sender][_spender] = _value;

      emit Approval(msg.sender,_spender,_value);

      return true;

  }

  //����_spender������ȡtoken�ĸ�����

  function allowance(address _owner, address _spender) public view returns (uint256 remaining){

      return allowed[_owner][_spender];

  }

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

//ʵ��һ�����ҵĹ�����

contract owned{

    address public owner;

    constructor() public{

        owner=msg.sender;

    }

    modifier onlyOwner{

        require(msg.sender==owner);

        _;

    }

    function transferOwnerShip(address newOwner) public onlyOwner{

        owner=newOwner;

    }

}

//�߼����Ҽ̳���ǰ������Լ

contract CAR is ERC20,owned {

    mapping(address => bool) public frozenAccount;//����������߽ⶳ���ʺ� 

    event AddSupply(uint256 amount);//���������¼� 

    event FrozenFunds(address target,bool freeze);//����������߽ⶳ�¼�

    event Burn(address account,uint256 values);

    /**"Test FQ","TFQC",18,1000 */

    constructor(string _name,string _symbol,uint8 _decimals,uint _totalSupply) ERC20 ( _name,_symbol, _decimals,_totalSupply) public{

    }

    //������������ 

    function mine(address target,uint256 amount) public onlyOwner{

        totalSupply+=amount;

        balanceOf[target]+=amount;

        emit AddSupply(amount);//�����¼�

        emit Transfer(0,target,amount);

    }

    //���ắ��

    function freezeAccount(address target,bool freeze) public onlyOwner{

        frozenAccount[target]=freeze;

        emit FrozenFunds(target,freeze);

    }

       //����transfer�������Լ���tokenת�˸�_to��ַ��_valueΪת�˸���

  function transfer(address _to, uint256 _value) public returns (bool success){

      require(!frozenAccount[msg.sender]);//�ж��˻��Ƿ񶳽� 

      require(_to!=address(0));//���Ŀ���ʺŲ����ڿ��ʺ� 

      require(balanceOf[msg.sender] >= _value);

      require(balanceOf[_to] + _value >=balanceOf[_to]);

      balanceOf[msg.sender]-=_value;

      balanceOf[_to]+=_value;

      emit Transfer(msg.sender,_to,_value);//�����¼�

      return true;

  }

  //����transferFrom������ת��token��

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

      require(!frozenAccount[msg.sender]);//�ж��˻��Ƿ񶳽� 

      require(_to!=address(0));

      require(balanceOf[_from]>=_value);

      require(balanceOf[_to]+_value>balanceOf[_to]);

      require(allowed[_from][msg.sender]>_value);

      balanceOf[_from]-=_value;

      balanceOf[_to]+=_value;

      allowed[_from][msg.sender]-=_value;

      emit Transfer(_from,_to,_value);

      return true;

  }

  //���ٺ��� 

  function burn(uint256 values) public returns(bool success){

      require(balanceOf[msg.sender]>=values);

      totalSupply-=values;

      balanceOf[msg.sender]-=values;

      emit Burn(msg.sender,values);

      return true;

  }

}