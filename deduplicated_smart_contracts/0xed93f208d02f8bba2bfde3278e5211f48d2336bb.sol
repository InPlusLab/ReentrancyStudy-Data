pragma solidity >=0.4.24;
//ERC20 ��׼���� https://eips.ethereum.org/EIPS/eip-20
import "./store.sol";

contract LUKToken {
    /** ERC20 �������� */
    string public name = "Lucky Coin";
    /** ERC20 ���ҷ��� */
    string public symbol = "LUK";
    
    //MUST trigger when tokens are transferred, including zero value transfers.
    event Transfer(address indexed from, address indexed to, uint256 value);
    //MUST trigger on any successful call to approve(address _spender, uint256 _value).
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //��Լ������
    address private owner;
    //���Ҳֿ�
    LUKTokenStore private tokenStore;
    /** �������б� */
    mapping (address => bool) private blackList;

    //���庯�����η����ж���Ϣ�������Ƿ��Ǻ�Լ������
    modifier onlyOwner() {
        require(msg.sender == owner,"Illegal operation.");
        _;
    }
    
    /**
     * Constructor function
     * @param storeAddr HITokenStore �����ַ
     */
    constructor (address storeAddr) public {
        owner = msg.sender;
        tokenStore = LUKTokenStore(storeAddr);
    }

    /**��ԼĬ�ϻ��˺�������û����ĺ���ʱ����ô˺�����������û�и������ݵ���̫ʱ����ô˺��� */
    function () external payable{
    }
    
    /** ERC20 ���ȣ��Ƽ��� 8 */
    function decimals() public view returns (uint8){
        return tokenStore.decimals();
    }
    /** ERC20 �������� */
    function totalSupply() public view returns (uint256){
        return tokenStore.totalSupply();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        balance = tokenStore.balanceOf(_owner);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //������������Ĳ��ܽ���
        require(!blackList[msg.sender],"Prohibit trading.");
        require(!blackList[_to],"Prohibit trading.");

        tokenStore.transfer(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);
        
        success = true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success) {
        //������������Ĳ��ܽ���
        require(!blackList[_from],"Prohibit trading.");
        require(!blackList[msg.sender],"Prohibit trading.");
        require(!blackList[_to],"Prohibit trading.");

        tokenStore.transferFrom(_from,msg.sender,_to,_value);
        emit Transfer(_from, _to, _value);

        success = true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (tokenStore.approve(msg.sender,_spender,_value)){
            emit Approval(msg.sender,_spender,_value); 
            success = true;
        } else {
            success = false;
        }
    }

    function allowance(address _from, address _spender) public view returns (uint256 remaining) {
        remaining = tokenStore.allowance(_from,_spender);
    }
    
    /**
      * ��һ����ַ��ӵ�������������ӵ��������ĵ�ַ�����ܹ�ת��
      * @param _addr ���ҽ�����.
      * @return success �Ƿ��׳ɹ�
      */
    function addToBlackList(address _addr) public onlyOwner returns (bool success) {
        require(_addr != address(0x0),"Invalid address");

        blackList[_addr] = true;
        success = true;
    }

    /**
      * �Ӻ��������Ƴ�һ����ַ
      * @param _addr ���ҽ�����.
      * @return success �Ƿ��׳ɹ�
      */
    function removeFromBlackList(address _addr) public onlyOwner returns (bool success) {
        require(_addr != address(0x0),"Invalid address");

        blackList[_addr] = false;
        success = true;
    }
}