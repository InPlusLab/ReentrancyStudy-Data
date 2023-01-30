/**

 *Submitted for verification at Etherscan.io on 2018-09-12

*/



pragma solidity ^0.4.24;



/**

 * Utility library of inline functions on addresses

 */

library AddressUtilsLib {



    /**

    * Returns whether there is code in the target address

    * @dev This function will return false if invoked during the constructor of a contract,

    *  as the code is not actually created until after the constructor finishes.

    * @param _addr address address to check

    * @return bool whether there is code in the target address

    */

    function isContract(address _addr) internal view returns (bool) {

        uint256 size;

        assembly {

            size := extcodesize(_addr)

        }



        return size > 0;

    }

    

}



pragma solidity ^0.4.24;





/**

 * Math operations with safety checks

 */

library SafeMathLib {



    /**

    * @dev uint256�˷�

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    /**

    * @dev ����

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(0==b);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev ��������

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev �ӷ�����

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



    /**

    * @dev 64bit�����

    */

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {

        return a >= b ? a : b;

    }



    /**

    * @dev 64bit��С��

    */

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {

        return a < b ? a : b;

    }



    /**

    * @dev uint256�����

    */

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;

    }



    /**

    * @dev uint256��С��

    */

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }

}



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





    /**

    * @dev The Ownable constructor sets the original `owner` of the contract to the sender

    * account.

    */

    constructor() public {

        owner = msg.sender;

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

    * @param _newOwner The address to transfer ownership to.

    */

    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0));

        emit    OwnershipTransferred(owner, _newOwner);

        owner = _newOwner;

    }

}



pragma solidity ^0.4.24;

contract ERC20Basic {

    /**

    * @dev �����¼�

    */

    event Transfer(address indexed _from,address indexed _to,uint256 value);



    //��������  

    uint256 public  totalSupply;



    /**

    *@dev ��ȡ����

     */

    function name() public view returns (string);



    /**

    *@dev ��ȡ���ҷ���

     */

    function symbol() public view returns (string);



    /**

    *@dev ֧�ּ�λС��

     */

    function decimals() public view returns (uint8);



    /**

    *@dev ��ȡ������

     */

    function totalSupply() public view returns (uint256){

        return totalSupply;

    }



    /**

    * @dev ��ȡ���

    */

    function balanceOf(address _owner) public view returns (uint256);



    /**

    * @dev ת�ƴ���

    * @param _to ת�Ƶ�ַ

    * @param _value ����

    */

    function transfer(address _to, uint256 _value) public returns (bool);

}

pragma solidity ^0.4.24;



contract ERC20 is ERC20Basic {

    /**

    * @dev �����¼�

    */

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



     /**

    * @dev �鿴_owner��ַ�����Ե���_spender��ַ���ٴ���

    * @param _owner ��ǰ

    * @param _spender ��ַ

    * @return uint256 �ɵ��õĴ�����

    */

    function allowance(address _owner, address _spender) public view returns (uint256);



    /**

    * @dev approve��׼֮�󣬵�ǰ�ʺŴ�_from�˻�ת��_value����

    * @param _from �˻�ת��

    * @param _to ת�Ƶ�ַ

    * @param _value ����

    */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);



    /**

    * @dev ��Ȩ����׼_spender�˻����Լ����˻�ת��_value������

    * @param _spender ��Ȩ��ַ

    * @param _value ��Ȩ����

    */

    function approve(address _spender, uint256 _value) public returns (bool);

}



pragma solidity ^0.4.24;



/**

 * @title Basic token

 */

contract BasicToken is ERC20Basic {

    //SafeMathLib�ӿ�

    using SafeMathLib for uint256;

    using AddressUtilsLib for address;

    

    //����ַ

    mapping(address => uint256) public balances;



    /**

    * @dev ָ����ַ����

    * @param _from ���͵�ַ

    * @param _to ���͵�ַ

    * @param _value ��������

    */

    function _transfer(address _from,address _to, uint256 _value) public returns (bool){

        require(!_from.isContract());

        require(!_to.isContract());

        require(0 < _value);

        require(balances[_from] > _value);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

    * @dev ָ����ַ����

    * @param _to ���͵�ַ

    * @param _value ��������

    */

    function transfer(address _to, uint256 _value) public returns (bool){

        return   _transfer(msg.sender,_to,_value);

    }



    



    /**

    * @dev ��ѯ��ַ���

    * @param _owner ��ѯ��ַ 

    * @return uint256 �������

    */

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



}

pragma solidity ^0.4.24;



contract UCBasic is ERC20,BasicToken{

    //

    mapping (address => mapping (address => uint256)) allowed;





    /**

    * @dev approve��׼֮�󣬵���transferFrom������ת��token

    * @param _from ��ǰ�û�token

    * @param _to ת�Ƶ�ַ

    * @param _value ����

    */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){

        //��⴫��ֵ�Ƿ�Ϊ��

        require(0 < _value);

        //����ַ�Ƿ���Ч

        require(address(0) != _from && address(0) != _to);

        //����Ƿ���������֧��

        require(allowed[_from][msg.sender] > _value);

        //����˻�����Ƿ���

        require(balances[_from] > _value);

        //����ַ�Ƿ���Ч

        require(!_from.isContract());

        //����ַ�Ƿ���Ч

        require(!_to.isContract());



        //���

        uint256 _allowance = allowed[_from][msg.sender];



        balances[_to] = balances[_to].add(_value);

        balances[_from] = balances[_from].sub(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    /**

    * @dev ��׼��һ����address������ָ���Ĵ���

    * @dev 0 address ��ʾû����Ȩ�ĵ�ַ

    * @dev ������ʱ���ڣ�һ��tokenֻ����һ����׼�ĵ�ַ

    * @dev ֻ��token�ĳ����߻�����Ȩ�Ĳ����˲ſ��Ե���

    * @param _spender ָ���ĵ�ַ

    * @param _value uint256 �������

    */

    function approve(address _spender, uint256 _value) public returns (bool){

        require(address(0) != _spender);

        require(!_spender.isContract());

        require(msg.sender != _spender);

        require(0 != _value);



        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



   /**

    * @dev �鿴_owner��ַ�����Ե���_spender��ַ���ٴ���

    * @param _owner ��ǰ

    * @param _spender ��ַ

    * @return uint256 �ɵ��õĴ�����

    */

    function allowance(address _owner, address _spender) public view returns (uint256) {

        //����ַ�Ƿ���Ч

        require(!_owner.isContract());

        //����ַ�Ƿ���Ч

        require(!_spender.isContract());



        return allowed[_owner][_spender];

    }

}

pragma solidity ^0.4.24;



contract STOToken is UCBasic,Ownable{

    using SafeMathLib for uint256;

    //����

    string constant public tokenName = "STOCK";

    //��ʶ

    string constant public tokenSymbol = "STO";

    //������30��

    uint256 constant public totalTokens = 30*10000*10000;

    //С��λ

    uint8 constant public  totalDecimals = 18;   

    //�汾��

    string constant private version = "20180908";

    //������̫����ַ

    address private wallet;



    constructor() public {

        totalSupply = totalTokens*10**uint256(totalDecimals);

        balances[msg.sender] = totalSupply;

        wallet = msg.sender;

    }



    /**

    *@dev ��ȡ����

     */

    function name() public view returns (string){

        return tokenName;

    }



    /**

    *@dev ��ȡ���ҷ���

     */

    function symbol() public view returns (string){

        return tokenSymbol;

    }



    /**

    *@dev ֧�ּ�λС��

     */

    function decimals() public view returns (uint8){

        return totalDecimals;

    }

}