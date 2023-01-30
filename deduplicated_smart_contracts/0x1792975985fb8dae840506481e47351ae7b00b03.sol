/**

 *Submitted for verification at Etherscan.io on 2018-09-27

*/



pragma solidity ^0.4.16;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



/**

 * һ����׼��Լ

 */

contract StandardTokenERC20 {

    //- Token ����

    string public name; 

    //- Token ����

    string public symbol;

    //- Token С��λ

    uint8 public decimals;

    //- Token �ܷ�����

    uint256 public totalSupply;

    //- ��Լ����״̬

    bool public lockAll = true;

    //- ��Լ������

    address public creator;

    //- ��Լ������

    address public owner;

    //- ��Լ��������

    address internal newOwner = 0x0;



    //- ��ַӳ���ϵ

    mapping (address => uint256) public balanceOf;

    //- ��ַ��Ӧ Token

    mapping (address => mapping (address => uint256)) public allowance;

    //- �����б�

    mapping (address => bool) public frozens;



    //- Token ����֪ͨ�¼�

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //- Token ��׼֪ͨ�¼�

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //- Token ����֪ͨ�¼�

    event Burn(address indexed _from, uint256 _value);

    //- ��Լ�����߱��֪ͨ

    event OwnerChanged(address _oldOwner, address _newOwner);

    //- ��ַ����֪ͨ

    event FreezeAddress(address _target, bool _frozen);



    /**

     * ���캯��

     *

     * ��ʼ��һ����Լ

     * @param initialSupplyHM ��ʼ��������λ�ڣ�

     * @param tokenName Token ����

     * @param tokenSymbol Token ����

     * @param tokenDecimals Token С��λ

     */

    constructor(uint256 initialSupplyHM, string tokenName, string tokenSymbol, uint8 tokenDecimals) public {

        name = tokenName;

        symbol = tokenSymbol;

        decimals = tokenDecimals;

        totalSupply = initialSupplyHM * 10000 * 10000 * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;

        owner = msg.sender;

        creator = msg.sender;

    }



    /**

     * ���������η�

     */

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    /**

     * ת�ƺ�Լ������

     * @param _newOwner �º�Լ�����ߵ�ַ

     */

    function transferOwnership(address _newOwner) onlyOwner public {

        require(owner != _newOwner);

        newOwner = _newOwner;

    }

    

    /**

     * ���ܲ���Ϊ�µĺ�Լ������

     */

    function acceptOwnership() public {

        require(msg.sender == newOwner && newOwner != 0x0);

        address oldOwner = owner;

        owner = newOwner;

        newOwner = 0x0;

        emit OwnerChanged(oldOwner, owner);

    }



    /**

     * �趨��Լ����״̬

     * @param _lockAll ״̬

     */

    function setLockAll(bool _lockAll) onlyOwner public {

        lockAll = _lockAll;

    }



    /**

     * �趨�˻�����״̬

     * @param _target ����Ŀ��

     * @param _freeze ����״̬

     */

    function setFreezeAddress(address _target, bool _freeze) onlyOwner public {

        frozens[_target] = _freeze;

        emit FreezeAddress(_target, _freeze);

    }



    /**

     * �ӳ��з�ת��ָ�������� Token �����շ�

     * @param _from ���з�

     * @param _to ���շ�

     * @param _value ����

     */

    function _transfer(address _from, address _to, uint256 _value) internal {

        //- ����У��

        require(!lockAll);

        //- ��ַ��Ч��֤

        require(_to != 0x0);

        //- �����֤

        require(balanceOf[_from] >= _value);

        //- �Ǹ�����֤

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        //- ���з�����У��

        require(!frozens[_from]); 

        //- ���շ�����У��

        //require(!frozenAccount[_to]); 



        //- ����ԤУ������

        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];

        //- ���з����ٴ���

        balanceOf[_from] -= _value;

        //- ���շ����Ӵ���

        balanceOf[_to] += _value;

        //- ����ת���¼�

        emit Transfer(_from, _to, _value);

        //- ȷ�����׹��󣬳��з��ͽ��շ�������������

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /**

     * ת��תָ�������� Token �����շ�

     *

     * @param _to ���շ���ַ

     * @param _value ����

     */

    function transfer(address _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);

        return true;

    }



    /**

     * �ӳ��з�ת��ָ�������� Token �����շ�

     *

     * @param _from ���з�

     * @param _to ���շ�

     * @param _value ����

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        //- ��Ȩ���У��

        require(_value <= allowance[_from][msg.sender]);



        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    /**

     * ��Ȩָ����ַ��ת�ƶ��

     *

     * @param _spender ����

     * @param _value ��Ȩ���

     */

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * ��Ȩָ����ַ��ת�ƶ�ȣ���֪ͨ������Լ

     *

     * @param _spender ����

     * @param _value ת����߶��

     * @param _extraData ��չ���ݣ����ݸ�������Լ��

     */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);//- ������Լ

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    function _burn(address _from, uint256 _value) internal {

        //- ����У��

        require(!lockAll);

        //- �����֤

        require(balanceOf[_from] >= _value);

        //- ����У��

        require(!frozens[_from]); 



        //- ���� Token

        balanceOf[_from] -= _value;

        //- �����µ�

        totalSupply -= _value;



        emit Burn(_from, _value);

    }



    /**

     * ����ָ�������� Token

     *

     * @param _value ��������

     */

    function burn(uint256 _value) public returns (bool success) {

        _burn(msg.sender, _value);

        return true;

    }



    /**

     * ���ĳ��з���Ȩ�����ָ�������� Token

     *

     * @param _from ���з�

     * @param _value ��������

     */

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        //- ��Ȩ���У��

        require(_value <= allowance[_from][msg.sender]);

      

        allowance[_from][msg.sender] -= _value;



        _burn(_from, _value);

        return true;

    }

    

    function() payable public{

    }

}