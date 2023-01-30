/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



pragma solidity ^0.4.16;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }



//����һ��owned��Լ

contract owned {



				//����һ������"owner"�����������������address���������ڴ洢���ҵĹ����ߡ�

				//owned()������C++�еĹ��캯���������Ǹ�owner��ֵ��

        address public owner;



        function owned() {

            owner = msg.sender;

        }



				//����һ��modifier(�޸ı�־)���������Ϊ�����ĸ���������

				//��������������Ǽ��跢���߲���owner�������ߣ�������������һ����ݼ�������á�

        modifier onlyOwner {

            require(msg.sender == owner);

            _;

        }



        //ʵ������Ȩת��

        //����һ��transferOwnership�������������������ת�ƹ����ߵ���ݡ�

        //ע�⣬transferOwnership�������"onlyOwner"���������������ǰ���ǣ�ִ���˱�����owner��

        function transferOwnership(address newOwner) onlyOwner {

            owner = newOwner;

        }

}



//����һ��ERC20����

contract TokenERC20 is owned {

    string public name;

    string public symbol;

    uint8 public decimals = 18;  // 18 �ǽ����Ĭ��ֵ

    uint256 public totalSupply;



    mapping (address => uint256) public balanceOf;  // 

    mapping (address => mapping (address => uint256)) public allowance;



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Burn(address indexed from, uint256 value);



    function TokenERC20(

    		uint256 initialSupply, 

    		string tokenName, 

    		string tokenSymbol,

    		//��TokenERC20������˵�ַ����centralMinter�����������������λ�õġ�

    		address centralMinter

    		) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;

        name = tokenName;

        symbol = tokenSymbol;

        //if�Ӿ䣬ֻҪ�����ַ��Ϊ0��ӵ���߾��Ƿ����ߣ�������������ʲô��û��ϵ�����if�Ӿ䣬Ŀǰû������ʲô�ô���

        if(centralMinter != 0 ) owner = centralMinter;

    }

    

    //��������

    //�������:

		//��2������ָ��Ŀ�����Ӵ���������

		//��3��������������������Ӧ����Ŀ��

		//��4��͵�5����������ֻ�����ѿͻ��˷����������Ľ��ס�

		function mintToken(address target, uint256 mintedAmount) onlyOwner {

        balanceOf[target] += mintedAmount;

        totalSupply += mintedAmount;

        Transfer(0, owner, mintedAmount);

        Transfer(owner, target, mintedAmount);

		}



    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;

        Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) public

        returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        return true;

    }



    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;

        totalSupply -= _value;

        Burn(msg.sender, _value);

        return true;

    }



    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);

        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;

        allowance[_from][msg.sender] -= _value;

        totalSupply -= _value;

        Burn(_from, _value);

        return true;

    }

}