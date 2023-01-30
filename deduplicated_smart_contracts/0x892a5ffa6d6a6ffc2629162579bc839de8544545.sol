/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

pragma solidity ^0.4.26;

//����ӿڣ������ڶԽ� ������Լ��--�Խ�  ���õ� �����ֺ�Լ
interface tokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

/**  ������
 * @title SafeMath --��ȫ����ѧ����
 * @dev  Math operations with safety checks that throw on error//��ѧ�����밲ȫ��鷢������
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.//������������ˣ������ʱ�׳���
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }



  /**
  * @dev Integer division of two numbers, truncating the quotient.//�������������������ض��̡�
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0);   // Solidity automatically throws when dividing by 0  //��ĸΪ0ʱ���Զ��׳�
    // uint256 c = a / b;
    // assert(a == b * c + a % b);   // There is no case in which this doesn't hold //û�����������������
    return a / b;
  }




  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  //��ȥ�������֣������ʱ�׳���������������ڱ���������
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }



  /**
  * @dev Adds two numbers, throws on overflow.//����������֣������ʱ�׳���
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}




contract Ownable {

  address public owner;//��Լӵ���ߵĵ�ַ����
  address public COO; //������ϯ��Ӫ��
  address public CTO; //������ϯ������

//�����µĺ�Լӵ����--�¼�֪ͨ
  event OwnershipTransferred(address indexed _owner, address indexed _newAddress);
//������ϯ��Ӫ��--�¼�֪ͨ
  event COOTransferred(address indexed _COO, address indexed _newAddress);
//������ϯ������--�¼�֪ͨ
  event CTOTransferred(address indexed _CTO, address indexed _newAddress);

  //����ȡ����Լӵ���ߵ�Ȩ��--�¼�֪ͨ
  event OwnershipRenounced(address indexed previousOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   *
   * ��ӵ�еĹ��캯������ͬ��ԭʼ�������ߡ�����Ϊ���ͷ��ʻ���
   */
  constructor() public {
    owner = msg.sender;  //�Ѻ�Լ�����ߵĵ�ַ���� ��Լӵ���߱��� owner
    COO = msg.sender;    //�Ѻ�Լ�����ߵĵ�ַ���� ��ϯ��Ӫ�ٱ��� COO
    CTO = msg.sender;    //�Ѻ�Լ�����ߵĵ�ַ���� ��ϯ�����ٱ��� CTO
  }




  /**
   * @dev Throws if called by any account other than the owner.
   * // �����������������κ��ʻ����ã����׳���
   */
      modifier onlyOwner() {
        require(msg.sender == owner);  //�жϵ�ǰ��Ϣ�����ߣ��Ƿ�Ϊ��Լӵ����
        _;  //�滻���������ߵĺ������룬�Ƿ������
      }


      modifier onlyCOO() {
        //�жϵ�ǰ��Ϣ�����ߣ��Ƿ�Ϊ��ϯ��Ӫ��
        require(msg.sender == COO);
        _;  //�滻���������ߵĺ������룬�Ƿ������
      }


      modifier onlyCTO() {
        //�жϵ�ǰ��Ϣ�����ߣ��Ƿ�Ϊ��ϯ������
        require(msg.sender == CTO);
        _;  //�滻���������ߵĺ������룬�Ƿ������
      }


  /**
   //����ǰ�����߽���ͬ�Ŀ���ת�Ƹ��������ߡ�
   */

   function transferAddress(address _newAddress,uint _type) public onlyOwner returns (bool) {
     require(_newAddress != address(0) && _type > 0  && _type < 4);                //�ж��Ƿ�Ϊ��̫����ַ
         if( _type == 1 ){
               owner = _newAddress;                              //�µĺ�Լӵ����
               emit OwnershipTransferred(owner, _newAddress);    //�¼�֪ͨ
         }
         if ( _type == 2 ){
              COO = _newAddress;                              //�µ���ϯ��Ӫ��
              emit COOTransferred(COO, _newAddress);          //�¼�֪ͨ
         }
         if( _type == 3 ){
              CTO = _newAddress;                              //�µ� ��ϯ������
              emit CTOTransferred(CTO, _newAddress);           //�¼�֪ͨ
         }
         return true;
   }



//����ȡ����Լӵ���ߵ�Ȩ��--�������
  function renounceOwnership() public onlyOwner returns (bool){
    owner = address(0);   //�Ѻ�Լӵ���ߵĵ�ַ��Ϊ 0x000000000��ʽ��
    emit OwnershipRenounced(owner);   //�¼�֪ͨ

    return true;
    }


}








contract TokenERC20 is Ownable {

  // ������
  using SafeMath for uint256;   //�Ѻ����⸽�ӵ� SafeMath������

  string public name;
  string public symbol;
  uint8 public decimals = 1;   // ��ʾ��������ʾС��������λ��,����ʱ����Ϊ18
  uint256 public totalSupply;  // ��Լ����������

  mapping (address => uint256) public balanceOf;  //�û��Ĵ������
  mapping (address => mapping (address => uint256)) public allowance;  //����ĳ��ַ��Ȩĳ��ַ���ٴ���
  mapping (address => bool) public frozenAccount;  // ���涳���˻��Ķ���״̬ ��Ĭ��Ϊ��false


// �¼���
    event Transfer(address indexed from, address indexed to, uint256 value);  //�����¼�֪ͨ
    event Approval(address indexed owner, address indexed spender, uint256 value);  //��Ȩĳ��ַ���ٸ�����-�¼�֪ͨ
    event Burn(address indexed from, uint256 value);  // �¼�������֪ͨ�ͻ��˴��ұ�����
    event FrozenFunds(address target, bool frozen);  // �����˻��¼�֪ͨ






// ���캯��
  constructor(uint256 _totalSupply,string _name,string tokenSymbol) public {
      totalSupply = _totalSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
      balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
      name = _name;                                   // Set the name for display purposes
      symbol = tokenSymbol;                               // Set the symbol for display purposes
  }








//��Ҫ������ʼ
/**����ת�˹���--��ʼ **/
   function _transfer(address _from, address _to, uint _value) internal  returns (bool) {
         require(_to != address(0));                    //�Ƿ�Ϊ��̫����ַ
         require(_value <= balanceOf[_from]);            //Ҫת���Ĵ�����������Ҫ���ڵ�ǰ���������

         balanceOf[_from] = balanceOf[_from].sub(_value); //�ۼ�����
         balanceOf[_to] = balanceOf[_to].add(_value);     //���Ӵ���

         emit Transfer(_from, _to, _value);             //����event�¼���������log��web3���Իص�.
         return true;
       }

//����ת�˹���
    function transfer(address _to, uint256 _value) public returns (bool){
           //require(_filters(0,msg.sender,_to,_value)); //��������Ҫ�ڹر�״̬ + �����ߵ�ַΪ�Ƕ���״̬ + �����ߵ�ַΪ�Ƕ���״̬
           require( _transfer(msg.sender, _to, _value) );
           return true;
         }

/**����ת�˹���--���� **/







/** ������Ȩ����--��ʼ**/
//��Ȩ��ı����շ�������ǲ�����ʾ�ģ�ֻ��ͨ����Ȩ��ѯ����ʾ
    function _approve(address _spender, uint256 _value) internal returns (bool) {
           allowance[msg.sender][_spender] = _value;
           emit Approval(msg.sender, _spender, _value);
           return true;
         }

//1--approve()-- ����Ȩĳ����ַ�������Ҷ��ٸ����� --����ӿ�
    function approve(address _to, uint256 _value) public returns (bool){
           //require(_filters(1,msg.sender,_to,_value));
           require( _approve(_to, _value) );
           return true;
        }


/** ������Ȩ����---���� **/



/**������Ȩת�˹���---��ʼ**/
        function _transferFrom(address _from, address _to, uint256 _value) internal returns (bool) {
           //�����µĴ��룬���Կ��������������˼�ǣ��� ��ĳ����Ȩ���ҵĴ����˻��У�ת�����ٴ��Ҹ�����
            require(_to != address(0)  && _value <= balanceOf[_from] && _value <= allowance[_from][msg.sender]);

            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);  //�� allowance[_from][msg.sender] �пۼ�
            require( _transfer(_from, _to, _value) ); //�� _from �пۼ����� _to ������

            emit Transfer(_from, _to, _value);
            return true;
          }

          function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
                //require(_filters2(2,_from,_to,_value,msg.sender));  //������
                require( _transferFrom(_from,_to,_value) );
                return true;
             }

/**������Ȩת�˹���---����**/






/**׷�ӿۼ�������Ȩ����---��ʼ**/
//3--increaseApproval()-- �Ҷ�ĳ����ַ׷����Ȩ�Ĵ���
      function _increaseApproval(address _spender, uint _addedValue) internal returns (bool) {
         allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_addedValue);//��ԭ������������׷��

         emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
         return true;
         }

      function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
            //require(_filters(3,msg.sender,_spender,_addedValue));
            require( _increaseApproval(_spender,_addedValue) );
            return true;
         }


//4--decreaseApproval()-- �Ҷ�ĳ����ַ�ۼ���Ȩ�Ĵ���
      function _decreaseApproval(address _spender, uint _subtractedValue) internal returns (bool) {

          uint oldValue = allowance[msg.sender][_spender]; //��õ�ǰ����Ȩ�˻������

          if (_subtractedValue > oldValue) {      //�����Ȩ�˻������� �ۼ�
                 allowance[msg.sender][_spender] = 0;     //��0
           } else {
                 allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);  //�����Ļ����Ͽۼ�
           }

           emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);//�¼�֪ͨ
           return true;
         }

       function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
             //require(_filters(4,msg.sender,_spender,_subtractedValue));
             require( _decreaseApproval(_spender,_subtractedValue) );
             return true;
         }
/**׷�ӿۼ�������Ȩ����---����**/





/**���ٴ��ҹ���---��ʼ**/
/**����ĳ����ַ�Ĵ���--�ڲ�����(�û���������)**/
         function _burn(address _who, uint256 _value) internal returns (bool){
              require(_value <= balanceOf[_who]);  //���Դ�˻��Ƿ���㹻�Ĵ���

              balanceOf[_who] = balanceOf[_who].sub(_value);   //��Դ�˻�(���»����˻�)�м�ȥ
              totalSupply = totalSupply.sub(_value);       //�Ӻ�Լ���˻��м�ȥ

              emit Burn(_who, _value);                       //�����¼�֪ͨ
              emit Transfer(_who, address(0), _value);       //�����¼�֪ͨ
              return true;
             }
//5--burn() -- �û������������ѵĴ���
        function burn(uint256 _value) public returns (bool) {
              //require(_filters0(5,msg.sender,_value));
              require( _burn(msg.sender, _value) );
              return true;
             }




/**����Ȩ���û������� ָ����Ȩ�����ѵĴ���-�����ٴ���**/
//��������   ���� ���»�  ��Ȩ ���ҵĴ���
         function _burnFrom(address _from, uint256 _value) internal returns (bool){
               require(_value <= allowance[_from][msg.sender]);  //���»�  ��Ȩ ���ҵĴ���������Ҫ���� ���� ������
               //�����»� ��Ȩ ���ҵ��˻��пۼ�
               allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
               //1. �ж����»����˻��㹻 �� 2. ���ٴ���  3. �¼�֪ͨ
               require( _burn(_from, _value) );  //�������ٴ��ҵ��ڲ�����
               return true;
           }

//6--burnFrom()-- ������ĳ�ˣ��磺���»���  ��Ȩ ���ҵĴ���
          function burnFrom(address _from, uint256 _value) public returns (bool) {
               //require(_filters(6,msg.sender,_from,_value));
               require( _burnFrom(_from,_value) );
               return true;
           }


/**���ٴ��ҹ���---����**/





/**��Ͷ���ҹ���---��ʼ**/
//��������--��Ͷ����
     function _mintToken(address target, uint256 mintedAmount) onlyOwner internal returns (bool) {
         //ע��totalSupply �� ���ҵ�������  balanceOf[this] -- �Ǻ�Լ��ǰ�Ĵ����������ǲ�ͬ��
            totalSupply = totalSupply.add(mintedAmount);       //��Լ���˻����Ӵ���
            balanceOf[target] = balanceOf[target].add(mintedAmount);  //ĳ��ַ���Ӵ���

            emit Transfer(0, this, mintedAmount);       //��Լ���˻����Ӵ���---�¼�֪ͨ
            emit Transfer(this, target, mintedAmount);  //ĳ��ַ���Ӵ���--�¼�֪ͨ
            return true;
         }

//7--mintToken()--��ĳ����ַ��Ͷ����
    function mintToken(address _target, uint256 _mintedAmount) onlyOwner public returns (bool) {
            //require(_filters0(7,_target,_mintedAmount));
            require( _mintToken(_target,_mintedAmount) );
            return true;
         }




/**��Ͷ���ҹ���---����**/





/**�����˻�����---��ʼ**/
/**�����˻��ķ���**/
     function _freezeAccount(address target, bool freeze) onlyCTO internal  returns (bool) {
           frozenAccount[target] = freeze;     //ֵ�����Ĳ���������
           emit  FrozenFunds(target, freeze);
           return true;
        }

//8--freezeAccount() --��ĳ��ַ���ж����ⶳ
     function freezeAccount(address _target, bool _freeze) onlyCTO public returns (bool) {
           //require(values[8]==0 && frozenAccount[_target] != _freeze);
           require( _freezeAccount(_target,_freeze) );
           return true;
        }



/**�����˻�����---����**/









/**�߼�����---��ʼ**/
//15--��˼�ǣ�������  ��Ȩĳ��ַ���Ǻ�Լ��ַ�� ������ʹ�����Ѷ��ٴ��ң�����������--ע�������ݣ������ɽ���ETH
//approve������������--�������һ����ĺ�Լ��ַ--����ӿ�
//�÷����������磬������Ȩ A��Լ  1000�����ң������������� A��Լ ��� receiveApproval() ����������1000������ת�� B
   function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool) {
           //require(_filters(15,msg.sender,_spender,_value));
           require(_spender != address(this));   //�ų����������ǵ�ǰ��Լ��ַ

           tokenRecipient spender = tokenRecipient(_spender); //��ú�Լ����
           if (approve(_spender, _value)) {  //�Ҷ�ǰ�涨��ĺ�Լ������Ȩ���ٴ���
               spender.receiveApproval(msg.sender, _value, this, _extraData);
               return true;
           }
       }




/**�߼�����---��ʼ**/






  }