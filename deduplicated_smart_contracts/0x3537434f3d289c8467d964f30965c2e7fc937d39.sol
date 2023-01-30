pragma solidity ^0.4.18;



contract AimiToken {
    //---------------------------------------����---------------------------------------- 
    string public name = "���ױ�";//��������
    string public symbol = "AT"; //���ҷ���
    uint8 public decimals = 8; //����С��λ
    uint256 public _totalSupply ; //��������10��
     mapping(address => uint256) balances;
    //��һ��ӳ�����͵ı���������¼��������˻�
    mapping(address=>bool) public frozenATAccount;
    event Approval(address indexed owner, address indexed spender, uint256 value);
    bool  transfersEnabled = false ;//�Ƿ񼤻���ҽ��� ��trueΪ���Ĭ�ϲ����� 
    mapping (address => mapping (address => uint256)) internal allowed;
    address public owner;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(frozenATAccount[_to]==false);
    require(frozenATAccount[msg.sender]==false);
    require(transfersEnabled==true);
    balances[_from] = sub(balances[_from],_value);
    balances[_to] = add(balances[_to],_value);
    allowed[_from][msg.sender] = sub(allowed[_from][msg.sender],_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender],_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = sub(oldValue,_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(frozenATAccount[_to]==false);
    require(frozenATAccount[msg.sender]==false);
    require(transfersEnabled==true);
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = sub(balances[msg.sender],_value);
    balances[_to] = add(balances[_to],_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  /**
  * @dev total number of tokens in existence
  */
    function totalSupply() public view returns (uint256) {
       return _totalSupply;
    }
 


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
   /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  
  
  
    
    //-----------------------------------------���췽��--------------------------------------------- 
    //���캯��,
    function AimiToken(address _sentM,uint256 __totalSupply) public payable{
        //�ֶ�ָ�����ҵ�ӵ���ߣ���������Ĭ��Ϊ��Լ�Ĳ�����
        if(_sentM !=0){
            owner = _sentM;
        }
        if(__totalSupply!=0){
            _totalSupply = __totalSupply;
        }
        //��ʼ����Լ��ӵ����ȫ������ 
        balances[owner] = _totalSupply;
   
    }
 
 function frozenAccount(address froze_address) public onlyOwner{
     frozenATAccount[froze_address]=true;
 } 
  function unfrozenATAccount(address unfroze_address) public onlyOwner{
     frozenATAccount[unfroze_address]=false;
 } 
 
   function openTransfer() public onlyOwner{
    transfersEnabled=true;
 } 
   function closeTransfer() public onlyOwner{
     transfersEnabled=true;
 } 
}