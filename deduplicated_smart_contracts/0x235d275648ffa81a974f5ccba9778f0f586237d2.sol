/**

 *Submitted for verification at Etherscan.io on 2018-10-21

*/



pragma solidity ^0.4.11;





contract owned {



    address public owner;

	

    function owned() payable { owner = msg.sender; }

    

    modifier onlyOwner { require(owner == msg.sender); _; }



 }





	

contract ARCEON is owned {



    using SafeMath for uint256;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

	address public owner;

	



    /* ������ڧߧԧ� */

    mapping (address => uint256) public balanceOf; //�ҧѧݧѧߧ�� ���ݧ�٧�ӧѧ�֧ݧ֧�

	mapping (address => uint256) public freezeOf; // �ާ���ڧߧ� �٧ѧާ���ا֧ߧߧ�� ���ܧ֧ߧ��

    mapping (address => mapping (address => uint256)) public allowance; // �ާ���ڧߧ� �է֧ݧ֧ԧڧ��ӧѧߧߧ�� ���ܧ֧ߧ��



    /* ����ҧ��ڧ� ���� ����֧�ߧ�� �ӧ���ݧߧ֧ߧڧ� ���ߧܧ�ڧ� transfer */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /* ����ҧ��ڧ� ���� �ӧ���ݧߧ֧ߧڧ� ���ߧܧ�ڧ� ��اڧԧѧߧڧ� ���ܧ֧ߧ�� ���ӧߧ֧�� */

    event Burn(address indexed from, uint256 value);

	

	

	/* ����ҧ��ڧ� ���� �ӧ���ݧߧ֧ߧڧ� ���ߧܧ�ڧ� �٧ѧާ���٧ܧ� ���ܧ֧ߧ�� */

    event Freeze(address indexed from, uint256 value);

	

	/* ����ҧ��ڧ� ���� �ӧ���ݧߧ֧ߧڧ� ���ߧܧ�ڧ� ��ѧ٧ާ���٧ܧ� ���ܧ֧ߧ�� */

    event Unfreeze(address indexed from, uint256 value);

	



    /* ����ߧ����ܧ��� */

	

    function ArCoin (

    

        uint256 initialSupply,

        string tokenName,

        uint8 decimalUnits,

        string tokenSymbol

        

        

        ) onlyOwner {

		

		



		

		owner = msg.sender; // ���ݧѧէ֧ݧ֧� == �����ѧӧڧ�֧ݧ�

		name = tokenName; // �����ѧߧѧӧݧڧӧѧ֧��� �ڧާ� ���ܧ֧ߧ�

        symbol = tokenSymbol; // �����ѧߧѧӧݧڧӧѧ֧��� ��ڧާӧ�� ���ܧ֧ߧ�

        decimals = decimalUnits; // �����-�ӧ� �ߧ�ݧ֧�

		

        balanceOf[owner] = initialSupply.safeDiv(2); // ����� ���ܧ֧ߧ� ���ڧߧѧէݧ֧اѧ� ���٧էѧ�֧ݧ�

		balanceOf[this]  = initialSupply.safeDiv(2); // ����� ���ܧ֧ߧ� ���ڧߧѧէݧ֧اѧ� �ܧ�ߧ��ѧܧ��

        totalSupply = initialSupply; // �����ѧߧѧӧݧڧӧѧ֧��� ��ҧ�ѧ� ��ާڧ��ڧ� ���ܧ֧ߧ��

		Transfer(this, owner, balanceOf[owner]); //������ݧѧ֧� �ܧ�ߧ��ѧܧ�� ���ݧ�ӧڧߧ�

		

		

        

		

    }  

	



    /* ����ߧܧ�ڧ� �էݧ� �����ѧӧܧ� ���ܧ֧ߧ�� */

    function transfer(address _to, uint256 _value) {

	    

        require (_to != 0x0); // ���ѧ��֧� �ߧ� ��֧�֧էѧ�� �ߧ� �ѧէ�֧� 0x0. �����ӧ֧�ܧ� ���� �����ӧ֧���ӧ�֧� ETH-�ѧէ�֧��

		require (_value > 0); 

        require (balanceOf[msg.sender] > _value); // �����ӧ֧�ܧ� ���� �� �����ѧӧڧ�֧ݧ� <= �ܧ��-�ӧ� ���ܧ֧ߧ��

        require (balanceOf[_to] + _value > balanceOf[_to]); // �����ӧ֧�ܧ� �ߧ� ��֧�֧��ݧߧ֧ߧڧ�

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);// �����ڧ�ѧ֧� ���ܧ֧ߧ� �� �����ѧӧڧ�֧ݧ�

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);//����ڧҧѧӧݧ�֧� ���ܧ֧ߧ� ���ݧ��ѧ�֧ݧ�

        Transfer(msg.sender, _to, _value);// ���ѧ���ܧѧ֧��� ���ҧ��ڧ� Transfer

    }



    /* ����ߧܧ�ڧ� �էݧ� ��է�ҧ�֧ߧڧ� �է֧ݧ֧ԧڧ��ӧѧߧڧ� ���ܧ֧ߧ�� */

    function approve(address _spender, uint256 _value)

        returns (bool success) {

		

		require (_value > 0); 

        allowance[msg.sender][_spender] = _value;

        return true;

    }   



    /* ����ߧܧ�ڧ� �էݧ� �����ѧӧܧ� �է֧ݧ֧ԧڧ��ӧѧߧߧ�� ���ܧ֧ߧ�� */

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

	    

        require(_to != 0x0);

		require (_value > 0); 

        require (balanceOf[_from] > _value);

        require (balanceOf[_to] + _value > balanceOf[_to]);

        require (_value < allowance[_from][msg.sender]);

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);

        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);

        Transfer(_from, _to, _value);

        return true;

    }



	/* ����ߧܧ�ڧ� �էݧ� ��اڧԧѧߧڧ� ���ܧ֧ߧ�� */

    function burn(uint256 _value) onlyOwner returns (bool success) {

	    

        require (balanceOf[msg.sender] > _value); //����ӧ֧�ܧ� ���� �ߧ� �ҧѧݧѧߧ�� �֧��� �ߧ�اߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ��

		require (_value > 0); 

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);// �ӧ��ڧ�ѧߧڧ�

        totalSupply = SafeMath.safeSub(totalSupply,_value);// ����ӧ�� �٧ߧѧ�֧ߧڧ� totalSupply

        Burn(msg.sender, _value);// ���ѧ���� ���ҧ��ڧ� Burn

        return true;

    

    }

	

	 /* ����ߧܧ�ڧ� �٧ѧާ���٧ܧ� ���ܧ֧ߧ�� */

	function freeze(uint256 _value) onlyOwner returns (bool success)   {

	    

        require (balanceOf[msg.sender] > _value); //����ӧ֧�ܧ� ���� �ߧ� �ҧѧݧѧߧ�� �֧��� �ߧ�اߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ��

		require (_value > 0); 

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value); // ���ާ֧ߧ��ѧ֧� �� �ާ���ڧߧԧ� balanceOf

        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value); // ����ڧҧѧӧݧ�֧� �� �ާ���ڧߧ� freezeOf

        Freeze(msg.sender, _value);

        return true;

    }

	

	/* ����ߧܧ�ڧ� ��ѧ٧ާ���٧ܧ� ���ܧ֧ߧ�� */

	function unfreeze(uint256 _value) onlyOwner returns (bool success) {

	   

        require(freezeOf[msg.sender] > _value);

		require (_value > 0);

        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);

		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);

        Unfreeze(msg.sender, _value);

        return true;

    }

	

	

	            function  BalanceContract() public constant returns (uint256 BalanceContract) {

        BalanceContract = balanceOf[this];

                return BalanceContract;

	            }

				

				function  BalanceOwner() public constant returns (uint256 BalanceOwner) {

        BalanceOwner = balanceOf[msg.sender];

                return BalanceOwner;

				}

		

		

	

	//����٧ӧ�ݧ�֧� ���٧էѧ�֧ݧ� �ӧ�ӧ�էڧ�� ���ѧߧ��ڧ֧�� �ߧ� �ѧէ�֧� �ܧ�ߧ��ѧܧ�� ����ڧ�� �� ���ܧ֧ߧ�

	

	

	function withdrawEther () public onlyOwner {

	    

        owner.transfer(this.balance);

    }

	

	function () payable {

        require(balanceOf[this] > 0);

       uint256 tokensPerOneEther = 20000;

        uint256 tokens = tokensPerOneEther * msg.value / 1000000000000000000;

        if (tokens > balanceOf[this]) {

            tokens = balanceOf[this];

            uint valueWei = tokens * 1000000000000000000 / tokensPerOneEther;

            msg.sender.transfer(msg.value - valueWei);

        }

        require(tokens > 0);

        balanceOf[msg.sender] += tokens;

        balanceOf[this] -= tokens;

        Transfer(this, msg.sender, tokens);

    }

}



/**

 * ���֧٧��ѧ�ߧ�� �ާѧ�֧ާѧ�ڧ�֧�ܧڧ� ���֧�ѧ�ڧ�

 */

 

	

library  SafeMath {

	// ��ާߧ�ا֧ߧڧ�

  function safeMul(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }

	//�է֧ݧ֧ߧڧ�

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {

    assert(b > 0);

    uint256 c = a / b;

    assert(a == b * c + a % b);

    return c;

  }

	//�ӧ��ڧ�ѧߧڧ�

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {

    assert(b <= a);

    return a - b;

  }

	//��ݧ�ا֧ߧڧ�

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a + b;

    assert(c>=a && c>=b);

    return c;

  }



  function assert(bool assertion) internal {

    if (!assertion) {

      throw;

    }

  }

}