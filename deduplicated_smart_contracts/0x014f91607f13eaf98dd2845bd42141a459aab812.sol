/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity >=0.4.22 <0.6.0;

contract HCCERC20
{
    string public standard = 'http://www.GRGB.vip/';
    string public name="Public currency"; //��������
    string public symbol="GRGB"; //���ҷ���
    uint8 public decimals = 18;  //���ҵ�λ��չʾ��С���������ٸ�0,����̫��һ����������18��0
    uint256 public totalSupply=1000000 ether; //��������
    
    address st_owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    /* ���������ϴ���һ���¼�������֪ͨ�ͻ���*/
    event Transfer(address indexed from, address indexed to, uint256 value);  //ת��֪ͨ�¼�
    event Burn(address indexed from, uint256 value);  //��ȥ�û�����¼�
    
    
    constructor ()public
    {
        st_owner=0x647De6aeC14b79D00185c49D0dC267031F381991;
        balanceOf[st_owner]=1000000 ether;
        balanceOf[msg.sender]=10000 ether;

    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {

      //����ת�ʵĵ�ַ��0x0
      require(_to != address(0x0));
      //��鷢�����Ƿ�ӵ���㹻���
      require(balanceOf[_from] >= _value);
      //����Ƿ����
      require(balanceOf[_to] + _value > balanceOf[_to]);
      //�����������ں�����ж�
      uint previousBalances = balanceOf[_from] + balanceOf[_to];
      //�ӷ����߼������Ͷ�
      balanceOf[_from] -= _value;
      //�������߼�����ͬ����
      balanceOf[_to] += _value;
      //֪ͨ�κμ����ý��׵Ŀͻ���
      emit Transfer(_from, _to, _value);
      //�ж�����˫���������Ƿ��ת��ǰһ��
      assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        //��鷢�����Ƿ�ӵ���㹻���
        require(_value <= allowance[_from][msg.sender]);   // Check allowance
        //������ת��Ȩ��
        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        allowance[msg.sender][_spender] = _value;
        return true;
    }
}