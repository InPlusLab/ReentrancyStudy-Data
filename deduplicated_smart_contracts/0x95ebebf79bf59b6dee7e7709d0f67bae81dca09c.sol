/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity >=0.4.22 <0.6.0;

contract BWSERC20
{
    string public standard = 'https://leeks.cc';
    string public name="Bretton Woods system"; //��������
    string public symbol="BWS"; //���ҷ���
    uint8 public decimals = 18;  //���ҵ�λ��չʾ��С���������ٸ�0,����̫��һ����������18��0
    uint256 public totalSupply=100000000 ether; //��������
    
    address st_owner;
    address st_owner1;

    uint256 public st_bws_pool;//�Ҳ�
    uint256 public st_ready_for_listing;//׼�����С�
    bool st_unlock_owner=false;
    bool st_unlock_owner1=false;
    address st_unlock_to;
    address st_unlock_to1;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint32) public CredibleContract;//�����ε����ܺ�Լ����Ҫ�Ǻ��ڵ���Ϸ֮���
    /* ���������ϴ���һ���¼�������֪ͨ�ͻ���*/
    event Transfer(address indexed from, address indexed to, uint256 value);  //ת��֪ͨ�¼�
    event Burn(address indexed from, uint256 value);  //��ȥ�û�����¼�
    
    
    constructor (address owner1)public
    {
        st_owner=msg.sender;
        st_owner1=owner1;
        
        st_bws_pool = 70000000 ether;
        st_ready_for_listing = 14000000 ether;
        
        balanceOf[st_owner]=8000000 ether;
        balanceOf[st_owner1]=8000000 ether;
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

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    //����Ա���Խ���1400��ҵ�ָ����ַ
    function unlock_listing(address _to) public
    {
        require(_to != address(0x0),"�����д����˿յ�ַ");
        //����1400����Ҫ��������Աͬʱ��������
        if(msg.sender==st_owner)
        {
            st_unlock_owner=true;
            st_unlock_to=_to;
        }
        else if(msg.sender==st_owner1)
        {
            st_unlock_owner1=true;
            st_unlock_to1=_to;
        }
        
        if(st_unlock_owner =true && st_unlock_owner1==true && st_unlock_to !=address(0x0) && st_unlock_to==st_unlock_to1)
        {
            //�����˽�������
            if(st_ready_for_listing==14000000 ether)
                {
                    st_ready_for_listing=0;
                    balanceOf[_to]+=14000000 ether;
                }
            
        }
    }
    //����Աָ�����ŵĺ�Լ��ַ����Щ��ַ���Խ���һЩ���в���������ӱҲ�ȡ�߹ɱҷ��Ÿ�ָ�����
    function set_CredibleContract(address tract_address) public
    {
        require(tract_address != address(0x0),"�����д����˿յ�ַ");
        //��Ҫ��������Աͬʱ���ò���
        if(msg.sender==st_owner)
        {
            if(CredibleContract[tract_address]==0)CredibleContract[tract_address]=2;
            else if(CredibleContract[tract_address]==3)CredibleContract[tract_address]=1;
        }
        if(msg.sender==st_owner1 )
        {
            if(CredibleContract[tract_address]==0)CredibleContract[tract_address]=3;
            else if(CredibleContract[tract_address]==2)CredibleContract[tract_address]=1;
        }
    }
    
    //�ӱҲ�ȡ��ָ������bws��ָ�����
    function TransferFromPool(address _to ,uint256 _value)public
    {
        require(CredibleContract[msg.sender]==1,"�Ƿ��ĵ���");
        require(_value<=st_bws_pool,"Ҫȡ���Ĺɱ�����̫��");
        
        st_bws_pool-=_value;
        balanceOf[_to] +=_value;
        emit Transfer(address(this), _to, _value);
    }
}