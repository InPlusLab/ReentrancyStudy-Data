/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract seaToken{
    string public name;  //�������� 
    string public symbol;    //���ҷ��� 
    uint256 public decimals;   //����С����λ�� 
    uint256 public totalSupply; //���ҷ�������
    uint256 public rate; //ת�������ѷ���
    address private ownerAddress;   //�������˺�
    
    mapping (address => uint256) public balanceOf;    //�洢�û����
    mapping (address => mapping(address=>uint256)) public allowance;   //�洢����Ȩ�߿ɲ�����Ȩ�ߵĽ��
    
    event Transfer(address indexed from,address indexed to,uint256 value,uint256 fee);  //ת���¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);   //��Ȩ�¼�
    event Rate(address indexed from, uint256 value);    //�����������¼�
    
    constructor(string memory tokenName,string memory tokenSymbol,uint256 tokenDecimals,uint256 tokenTotalSupply)public{
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = tokenTotalSupply * 10 ** tokenDecimals;
        balanceOf[msg.sender] = totalSupply;
        rate = 1000;
        ownerAddress = msg.sender;
    }
    /**
     * ��Լ�ڲ����ã�ִ��ת�˷���
     */
    function _transfer(address _from,address _to, uint256 _value) internal{
        require(_to != address(0x0));
        uint fee;
        if(ownerAddress != _from){   //�û�ת����������
            fee = _value / rate;
        }
        require(balanceOf[_from] >= (_value + fee));
        require(balanceOf[_to] + _value >= balanceOf[_to]); //��ֹת����
        uint previousBalances = balanceOf[_from] + balanceOf[_to] - fee;
        balanceOf[_from] = balanceOf[_from] - _value - fee;
        balanceOf[_to] += _value;
        balanceOf[ownerAddress] += fee;
        emit Transfer(_from, _to, _value,fee);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    /*
    * ����ת����������
    */
    function setRate(uint256 _value)public returns(bool success){
        require(msg.sender == ownerAddress);
        rate = _value;
        emit Rate(msg.sender,_value);
        return true;
    }
    
    /*
    *�����˻��и��û�����
    */
    function transfer(address _to,uint256 _value) public returns(bool success) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    /*
    *   �û�֮��ת�ˣ��������Ѳ���
    */
    function transferFrom(address _from,address _to,uint256 _value)public returns(bool success){
        require(msg.sender == _from || ownerAddress == msg.sender);
        _transfer(_from,_to,_value);
        return true;
    }
    /*
    *�����û��ɻ��ѵĴ�����
    */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /*
    *    *�����û����ҽ�����
    */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    
    /*
    *   ��ѯ�����ߵ��˻����
    */
    function getBalance()public view returns(uint256 balance){
        return balanceOf[msg.sender];
    }
    
    /*
    *   ��Լ����
    */
    function destroy()public{
        require(ownerAddress == msg.sender);
        selfdestruct(msg.sender);
    }
}