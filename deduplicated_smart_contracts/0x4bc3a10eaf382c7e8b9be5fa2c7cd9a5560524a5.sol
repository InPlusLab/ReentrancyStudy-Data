/**

 *Submitted for verification at Etherscan.io on 2018-10-19

*/



pragma solidity ^0.4.24;



// ----------------------------------------------------------------------------

// 'imChat' token contract

//

// Symbol      : IMC

// Name        : IMC

// Total supply: 1000,000,000.000000000000000000

// Decimals    : 8

//

// imChat Technology Service Limited

// ----------------------------------------------------------------------------





// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

library SafeMath {

    

    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;

        require(c >= _a);



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a);

        uint256 c = _a - _b;



        return c;

    }



    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (_a == 0) {

            return 0;

        }



        uint256 c = _a * _b;

        require(c / _a == _b);



        return c;

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0); // Solidity only automatically asserts when dividing by 0

        uint256 c = _a / _b;

        assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



        return c;

    }

}





// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address _owner) public constant returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint remaining);



    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

}





// ----------------------------------------------------------------------------

// Contract function to receive approval and execute function in one call

//

// Borrowed from MiniMeToken

// ----------------------------------------------------------------------------

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}





// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and a

// fixed supply

// ----------------------------------------------------------------------------

contract IMCToken is ERC20Interface, Owned {

    using SafeMath for uint;



    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    address public externalContractAddress;





    /**

     * ���캯��

     */

    constructor() public {

        symbol = "IMC";

        name = "IMC";

        decimals = 8;

        _totalSupply = 1000000000 * (10 ** uint(decimals));

        balances[owner] = _totalSupply;

        

        emit Transfer(address(0), owner, _totalSupply);

    }



    /**

     * ��ѯ�����ܷ�����

     * @return unit ���

     */

    function totalSupply() public view returns (uint) {

        return _totalSupply.sub(balances[address(0)]);

    }



    /**

     * ��ѯ�������

     * @param _owner address ��ѯ���ҵĵ�ַ

     * @return balance ���

     */

    function balanceOf(address _owner) public view returns (uint balance) {

        return balances[_owner];

    }



    /**

     * ˽�з�����һ���ʻ����͸���һ���ʻ�����

     * @param _from address ���ʹ��ҵĵ�ַ

     * @param _to address ���ܴ��ҵĵ�ַ

     * @param _value uint ���ܴ��ҵ�����

     */

    function _transfer(address _from, address _to, uint _value) internal{

        // ȷ��Ŀ���ַ��Ϊ0x0����Ϊ0x0��ַ��������

        require(_to != 0x0);

        // ��鷢�����Ƿ�ӵ���㹻���

        require(balances[_from] >= _value);

        // ����Ƿ����

        require(balances[_to] + _value > balances[_to]);



        // �����������ں�����ж�

        uint previousBalance = balances[_from].add(balances[_to]);



        // �ӷ����߼������Ͷ�

        balances[_from] = balances[_from].sub(_value);

        // �������߼�����ͬ����

        balances[_to] = balances[_to].add(_value);



        // ֪ͨ�κμ����ý��׵Ŀͻ���

        emit Transfer(_from, _to, _value);



        // �жϷ��͡����շ��������Ƿ��ת��ǰһ��

        assert(balances[_from].add(balances[_to]) == previousBalance);

    }



    /**

     * �Ӻ�Լ�����߷��͸����˴���

     * @param _to address ���ܴ��ҵĵ�ַ

     * @param _value uint ���ܴ��ҵ�����

     * @return success ���׳ɹ�

     */

    function transfer(address _to, uint _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);



        return true;

    }



    /**

     * �˺�֮����ҽ���ת�ƣ����ù��̣��������õ���������׶�

     * @param _from address �����ߵ�ַ

     * @param _to address �����ߵ�ַ

     * @param _value uint Ҫת�ƵĴ�������

     * @return success ���׳ɹ�

     */

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {

        

        if (_from == msg.sender) {

            // �Լ�ת��ʱ����Ҫapprove������ֱ�ӽ���ת��

            _transfer(_from, _to, _value);



        } else {

            // ��Ȩ��������ʱ�����鷢�����Ƿ�ӵ���㹻���

            require(allowed[_from][msg.sender] >= _value);

            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);



            _transfer(_from, _to, _value);



        }



        return true;

    }



    /**

     * �����ʻ���Լ���д���

     * @param _to address ���ܴ��ҵĵ�ַ

     * @param _value uint ���ܴ��ҵ�����

     * @return success ���׳ɹ�

     */

    function issue(address _to, uint _value) public returns (bool success) {

        // �ⲿ��Լ���ã��������Լ�����ߺʹ��Һ�Լ�����õ��ⲿ���ú�Լ��ַһ����

        require(msg.sender == externalContractAddress);



        _transfer(owner, _to, _value);



        return true;

    }



    /**

    * �����ʻ���Ȩ�����ʻ�����������ȡ����

    * @param _spender ��Ȩ�ʻ���ַ

    * @param _value ��������

    * @return success ����ɹ�

    */

    function approve(address _spender, uint _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;



        emit Approval(msg.sender, _spender, _value);



        return true;

    }



    /**

    * ��ѯ����Ȩ�ʻ���������ȡ�Ĵ�����

    * @param _owner ��Ȩ���ʻ���ַ

    * @param _spender ����Ȩ���ʻ���ַ

    * @return remaining ��������

    */

    function allowance(address _owner, address _spender) public view returns (uint remaining) {

        return allowed[_owner][_spender];

    }



    /**

     * ��������һ����ַ����Լ�����ң����������ߣ����������໨�ѵĴ�������

     * @param _spender ����Ȩ�ĵ�ַ����Լ��

     * @param _value ���ɻ��Ѵ�����

     * @param _extraData ���͸���Լ�ĸ�������

     * @return success ���óɹ�

     */

    function approveAndCall(address _spender, uint _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            // ֪ͨ��Լ

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    /**

     * ���������ⲿ��Լ��ַ���õ�ǰ��Լ

     * @param _contractAddress ��Լ��ַ

     * @return success ���óɹ�

     */

    function approveContractCall(address _contractAddress) public onlyOwner returns (bool){

        externalContractAddress = _contractAddress;

        

        return true;

    }



    /**

     * ������ Ether

     */

    function () public payable {

        revert();

    }

}