/**
 *Submitted for verification at Etherscan.io on 2019-09-23
*/

pragma solidity >=0.4.24;
contract LUKTokenStore {
    /** ���ȣ��Ƽ��� 8 */
    uint8 public decimals = 8;
    /** �������� */
    uint256 public totalSupply;
    /** �鿴ĳһ��ַ������� */
    mapping (address => uint256) private tokenAmount;
    /** ���ҽ��״�������Ȩ�б� */
    mapping (address => mapping (address => uint256)) private allowanceMapping;
    //��Լ������
    address private owner;
    //д��Ȩ
    mapping (address => bool) private authorization;
    
    /**
     * Constructor function
     * 
     * ��ʼ��Լ
     * @param initialSupply ��������
     */
    constructor (uint256 initialSupply) public {
        //** ��������
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        tokenAmount[msg.sender] = totalSupply;                // Give the creator all initial tokens
        owner = msg.sender;
    }
    
    //���庯�����η����ж���Ϣ�������Ƿ��Ǻ�Լ������
    modifier onlyOwner() {
        require(msg.sender == owner,"Illegal operation.");
        _;
    }
    
    modifier checkWrite() {
        require(authorization[msg.sender] == true,"Illegal operation.");
        _;
    }
    
    //д��Ȩ����Լ���ú�Լʱ������Ϊ����Լ��ַ
    function writeGrant(address _address) public onlyOwner {
        authorization[_address] = true;
    }
    function writeRevoke(address _address) public onlyOwner {
        authorization[_address] = false;
    }
    
    /**
     * ���ô������Ѵ����ˣ������˿���������ʹ�ý�������Ѵ���
     *
     * @param _from �ʽ������ߵ�ַ
     * @param _spender �����˵�ַ
     * @param _value ����ʹ�ý��
     */
    function approve(address _from,address _spender, uint256 _value) public checkWrite returns (bool) {
        allowanceMapping[_from][_spender] = _value;
        return true;
    }
    
    function allowance(address _from, address _spender) public view returns (uint256) {
        return allowanceMapping[_from][_spender];
    }
    
    /**
     * Internal transfer, only can be called by this contract
     */
    function transfer(address _from, address _to, uint256 _value) public checkWrite returns (bool) {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0),"Invalid address");
        // Check if the sender has enough
        require(tokenAmount[_from] >= _value,"Not enough balance.");
        // Check for overflows
        require(tokenAmount[_to] + _value > tokenAmount[_to],"Target account cannot be received.");

        // ת��
        // Subtract from the sender
        tokenAmount[_from] -= _value;
        // Add the same to the recipient
        tokenAmount[_to] += _value;

        return true;
    }
    
    function transferFrom(address _from,address _spender, address _to, uint256 _value) public checkWrite returns (bool) {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_from != address(0x0),"Invalid address");
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0),"Invalid address");
        
        // Check if the sender has enough
        require(allowanceMapping[_from][_spender] >= _value,"Insufficient credit limit.");
        // Check if the sender has enough
        require(tokenAmount[_from] >= _value,"Not enough balance.");
        // Check for overflows
        require(tokenAmount[_to] + _value > tokenAmount[_to],"Target account cannot be received.");
        
        // ת��
        // Subtract from the sender
        tokenAmount[_from] -= _value;
        // Add the same to the recipient
        tokenAmount[_to] += _value;
        
        allowanceMapping[_from][_spender] -= _value; 
    }
    
    function balanceOf(address _owner) public view returns (uint256){
        require(_owner != address(0x0),"Address can't is zero.");
        return tokenAmount[_owner] ;
    }
}