/**

 *Submitted for verification at Etherscan.io on 2018-11-01

*/



pragma solidity ^0.4.23;



/**

 * @title ��ȫ��ѧ��

 * @dev ����uint256�İ�ȫ���㣬��Լ�ڵĴ��Ҳ�����ʹ�������ĺ�������Ӽ��˳������������硢���������

 */

library SafeMath {



 /**

  * @dev �˷�

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

  * @dev ����

  */

 function div(uint256 a, uint256 b) internal pure returns (uint256) {

  return a / b;

 }



 /**

  * @dev ����

  */

 function sub(uint256 a, uint256 b) internal pure returns (uint256) {

  assert(b <= a);

  return a - b;

 }



 /**

  * @dev �ӷ�

  */

 function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

  c = a + b;

  assert(c >= a);

  return c;

 }

}



/**

 * @title ����Ȩ��Լ

 * @dev ���ڿ��ƺ�Լ������Ȩ������ת������Ȩ

 */

contract Ownable {

 address owner_; //��Լ������



 event OwnershipRenounced(address indexed previousOwner); //��Լ����Ȩ�����¼�

 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); //��Լ����Ȩת���¼�



 /**

  * @dev ���캯��

  */

 constructor() public {

  owner_ = msg.sender; //��Լ������Ϊ��Լ������

 }



 /**

     * @dev ��Լ������

     */

 function owner() public view returns (address) {

  return owner_;

 }



 /**

     * @dev onlyOwner�����޸������жϺ�Լʹ�����ǲ��Ǻ�Լӵ���ߣ��Ǻ�Լӵ���߲���ִ��

     */

 modifier onlyOwner() {

  require(msg.sender == owner_);

  _;

 }



 /**

  * @dev ת�ú�Լ����Ȩ��ֻ�к�Լ��������ʹ�ã�ת�ú�Լ����Ȩ��newOwner

  * @param  newOwner �µĺ�Լ������

  */

 function transferOwnership(address newOwner) public onlyOwner {

  require(newOwner != address(0));

  emit OwnershipTransferred(owner_, newOwner);

  owner_ = newOwner;

 }

}



/**

 * @title ERC20���Һ�Լ

 * @dev ����һ��ʾ����Լ���ڳ��Լʵ��ʹ��ʱ��Ҫ���ڳ��Լ��token�����滻����ĺ�Լ����

 */

contract ERC20 is Ownable {



 using SafeMath for uint256; //uint256����ʹ��SafeMath��



 string name_; //��������

 string symbol_; //���ҷ��ţ����ƻ��ҷ���

 uint8 decimals_; //С�����λ��

 uint256 totalSupply_; //��������



 mapping(address => uint256) balances; //��ַ���ӳ��

 mapping(address => mapping(address => uint256)) internal allowed; //��Ȩ���ӳ��



 event Transfer(address indexed from, address indexed to, uint256 value); //����ת���¼�

 event Approval(address indexed owner, address indexed spender, uint256 value); //��Ȩ����¼�

 event OwnershipRenounced(address indexed previousOwner); //��Լ����Ȩ�����¼�

 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); //��Լ����Ȩת���¼�



 /**

  * @dev ���캯����web3�������ɺ���Ҫ�Զ���_name,_symbol,_decimals,_totalSupply

  */

 constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {

  name_ = _name;

  symbol_ = _symbol;

  decimals_ = _decimals;

  totalSupply_ = _totalSupply.mul(10 ** uint256(decimals_)); //����������С�����λ��ת��

  balances[owner_] = totalSupply_; //��Լ�����߳��г�ʼ���д���

 }



 /**

  * @dev ��������

  */

 function name() public view returns (string) {

  return name_;

 }



 /**

  * @dev ���ҷ���

  */

 function symbol() public view returns (string) {

  return symbol_;

 }



 /**

  * @dev С�����λ��

  */

 function decimals() public view returns (uint8) {

  return decimals_;

 }



 /**

  * @dev ��������

  */

 function totalSupply() public view returns (uint256) {

  return totalSupply_;

 }



 /**

  * @dev onlyOwner�����޸������жϺ�Լʹ�����ǲ��Ǻ�Լӵ���ߣ��Ǻ�Լӵ���߲���ִ��

  */

 modifier onlyOwner() {

  require(msg.sender == owner_);

  _;

 }



 /**

  * @dev ����ת�ˣ��ں�Լδ��ͣʱ���ɺ�Լʹ����msg.sender����_toת��_value�����Ĵ���

  * @param  _to ת���ַ _value ��������

  * @return  bool �Ƿ�ת�˳ɹ�

  */

 function transfer(address _to, uint256 _value) public {

  require(_to != address(0));

  require(_value <= balances[msg.sender]);



  balances[msg.sender] = balances[msg.sender].sub(_value);

  balances[_to] = balances[_to].add(_value);

  emit Transfer(msg.sender, _to, _value);

 }



 /**

  * @dev ����ѯ����ѯ_account��ַ�Ĵ������

  * @param  _account �����˻���ַ

  * @return  uint256 �������

  */

 function balanceOf(address _account) public view returns (uint256) {

  return balances[_account];

 }



 /**

  * @dev ��Ȩ��ȣ��ں�Լδ��ͣʱ���ɺ�Լʹ����msg.sender����_spender��Ȩ_value�������Ҷ��

  * @param  _spender ����Ȩ��ַ _value ��Ȩ���

  * @return  bool �Ƿ���Ȩ�ɹ�

  */

 function approve(address _spender, uint256 _value) public returns (bool) {

  allowed[msg.sender][_spender] = _value;

  emit Approval(msg.sender, _spender, _value);

  return true;

 }



 /**

     * @dev �ڶ�ת�ˣ��ں�Լδ��ͣʱ���ɺ�Լʹ����msg.sender����_from��_toת��_value�����Ĵ��ң�ת���������ܳ���_from����Ȩ��Ⱥ����

     * @param  _from �ڶ��ַ _toת���ַ _value ��������

     * @return  bool �Ƿ�ת�˳ɹ�

     */

 function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

  require(_to != address(0));

  require(_value <= balances[_from]);

  require(_value <= allowed[_from][msg.sender]);



  balances[_from] = balances[_from].sub(_value);

  balances[_to] = balances[_to].add(_value);

  allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

  emit Transfer(_from, _to, _value);

  return true;

 }



 /**

  * @dev ��ѯ�ڶ��ѯ��_owner��_spender��Ȩ�Ĵ��Ҷ��

  * @param  _owner ��Ȩ��ַ _spender ����Ȩ��ַ

  * @return  uint256 ��Ȩ���

  */

 function allowance(address _owner, address _spender) public view returns (uint256) {

  return allowed[_owner][_spender];

 }



 /**

  * @dev �����ڶ�ں�Լδ��ͣʱ���ɺ�Լʹ����msg.sender��_spender����_addValue�����Ĵ��Ҷ��

  * @param  _spender ����Ȩ��ַ _addedValue ���ӵ���Ȩ���

  * @return  bool �Ƿ������ڶ�ɹ�

  */

 function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {

  allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

  emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

  return true;

 }



 /**

  * @dev �����ڶ�ں�Լδ��ͣʱ���ɺ�Լʹ����msg.sender��_spender����_subtractedValue�����Ĵ��Ҷ��

  * @param  _spender ����Ȩ��ַ _subtractedValue ���ٵ���Ȩ���

  * @return  bool �Ƿ�����ڶ�ɹ�

  */

 function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {

  uint oldValue = allowed[msg.sender][_spender];

  if (_subtractedValue > oldValue) {

   allowed[msg.sender][_spender] = 0;

  } else {

   allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

  }

  emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

  return true;

 }

}