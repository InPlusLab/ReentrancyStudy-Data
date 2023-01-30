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

	



    /* §®§ï§á§á§Ú§ß§Ô§Ú */

    mapping (address => uint256) public balanceOf; //§Ò§Ñ§Ý§Ñ§ß§ã§í §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§Ö§Û

	mapping (address => uint256) public freezeOf; // §Þ§ï§á§á§Ú§ß§Ô §Ù§Ñ§Þ§à§â§à§Ø§Ö§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó

    mapping (address => mapping (address => uint256)) public allowance; // §Þ§ï§á§á§Ú§ß§Ô §Õ§Ö§Ý§Ö§Ô§Ú§â§à§Ó§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó



    /* §³§à§Ò§í§ä§Ú§Ö §á§â§Ú §å§ã§á§Ö§ê§ß§à§Þ §Ó§í§á§à§Ý§ß§Ö§ß§Ú§Ú §æ§å§ß§Ü§è§Ú§Ú transfer */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /* §³§à§Ò§í§ä§Ú§Ö §á§â§Ú §Ó§í§á§à§Ý§ß§Ö§ß§Ú§Ú §æ§å§ß§Ü§è§Ú§Ú §ã§Ø§Ú§Ô§Ñ§ß§Ú§ñ §ä§à§Ü§Ö§ß§à§Ó §°§Ó§ß§Ö§â§Ñ */

    event Burn(address indexed from, uint256 value);

	

	

	/* §³§à§Ò§í§ä§Ú§Ö §á§â§Ú §Ó§í§á§à§Ý§ß§Ö§ß§Ú§Ú §æ§å§ß§Ü§è§Ú§Ú §Ù§Ñ§Þ§à§â§à§Ù§Ü§Ú §ä§à§Ü§Ö§ß§à§Ó */

    event Freeze(address indexed from, uint256 value);

	

	/* §³§à§Ò§í§ä§Ú§Ö §á§â§Ú §Ó§í§á§à§Ý§ß§Ö§ß§Ú§Ú §æ§å§ß§Ü§è§Ú§Ú §â§Ñ§Ù§Þ§à§â§à§Ù§Ü§Ú §ä§à§Ü§Ö§ß§à§Ó */

    event Unfreeze(address indexed from, uint256 value);

	



    /* §¬§à§ß§ã§ä§â§å§Ü§ä§à§â */

	

    function ArCoin (

    

        uint256 initialSupply,

        string tokenName,

        uint8 decimalUnits,

        string tokenSymbol

        

        

        ) onlyOwner {

		

		



		

		owner = msg.sender; // §£§Ý§Ñ§Õ§Ö§Ý§Ö§è == §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§î

		name = tokenName; // §µ§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§ä§ã§ñ §Ú§Þ§ñ §ä§à§Ü§Ö§ß§Ñ

        symbol = tokenSymbol; // §µ§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§ä§ã§ñ §ã§Ú§Þ§Ó§à§Ý §ä§à§Ü§Ö§ß§Ñ

        decimals = decimalUnits; // §¬§à§Ý-§Ó§à §ß§å§Ý§Ö§Û

		

        balanceOf[owner] = initialSupply.safeDiv(2); // §¿§ä§Ú §ä§à§Ü§Ö§ß§í §á§â§Ú§ß§Ñ§Õ§Ý§Ö§Ø§Ñ§ä §ã§à§Ù§Õ§Ñ§ä§Ö§Ý§ð

		balanceOf[this]  = initialSupply.safeDiv(2); // §¿§ä§Ú §ä§à§Ü§Ö§ß§í §á§â§Ú§ß§Ñ§Õ§Ý§Ö§Ø§Ñ§ä §Ü§à§ß§ä§â§Ñ§Ü§ä§å

        totalSupply = initialSupply; // §µ§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§ä§ã§ñ §à§Ò§ë§Ñ§ñ §ï§Þ§Ú§ã§ã§Ú§ñ §ä§à§Ü§Ö§ß§à§Ó

		Transfer(this, owner, balanceOf[owner]); //§±§à§ã§í§Ý§Ñ§Ö§Þ §Ü§à§ß§ä§â§Ñ§Ü§ä§å §á§à§Ý§à§Ó§Ú§ß§å

		

		

        

		

    }  

	



    /* §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §à§ä§á§â§Ñ§Ó§Ü§Ú §ä§à§Ü§Ö§ß§à§Ó */

    function transfer(address _to, uint256 _value) {

	    

        require (_to != 0x0); // §©§Ñ§á§â§Ö§ä §ß§Ñ §á§Ö§â§Ö§Õ§Ñ§é§å §ß§Ñ §Ñ§Õ§â§Ö§ã 0x0. §±§â§à§Ó§Ö§â§Ü§Ñ §é§ä§à §ã§à§à§ä§Ó§Ö§ä§ã§ä§Ó§å§Ö§ä ETH-§Ñ§Õ§â§Ö§ã§å

		require (_value > 0); 

        require (balanceOf[msg.sender] > _value); // §±§â§à§Ó§Ö§â§Ü§Ñ §é§ä§à §å §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§ñ <= §Ü§à§Ý-§Ó§å §ä§à§Ü§Ö§ß§à§Ó

        require (balanceOf[_to] + _value > balanceOf[_to]); // §±§â§à§Ó§Ö§â§Ü§Ñ §ß§Ñ §á§Ö§â§Ö§á§à§Ý§ß§Ö§ß§Ú§Ö

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);// §£§í§é§Ú§ä§Ñ§Ö§ä §ä§à§Ü§Ö§ß§í §å §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§ñ

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);//§±§â§Ú§Ò§Ñ§Ó§Ý§ñ§Ö§ä §ä§à§Ü§Ö§ß§í §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð

        Transfer(msg.sender, _to, _value);// §©§Ñ§á§å§ã§Ü§Ñ§Ö§ä§ã§ñ §ã§à§Ò§í§ä§Ú§Ö Transfer

    }



    /* §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §à§Õ§à§Ò§â§Ö§ß§Ú§ñ §Õ§Ö§Ý§Ö§Ô§Ú§â§à§Ó§Ñ§ß§Ú§ñ §ä§à§Ü§Ö§ß§à§Ó */

    function approve(address _spender, uint256 _value)

        returns (bool success) {

		

		require (_value > 0); 

        allowance[msg.sender][_spender] = _value;

        return true;

    }   



    /* §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §à§ä§á§â§Ñ§Ó§Ü§Ú §Õ§Ö§Ý§Ö§Ô§Ú§â§à§Ó§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó */

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



	/* §¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §ã§Ø§Ú§Ô§Ñ§ß§Ú§ñ §ä§à§Ü§Ö§ß§à§Ó */

    function burn(uint256 _value) onlyOwner returns (bool success) {

	    

        require (balanceOf[msg.sender] > _value); //§á§â§à§Ó§Ö§â§Ü§Ñ §é§ä§à §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §Ö§ã§ä§î §ß§å§Ø§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó

		require (_value > 0); 

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);// §Ó§í§é§Ú§ä§Ñ§ß§Ú§Ö

        totalSupply = SafeMath.safeSub(totalSupply,_value);// §¯§à§Ó§à§Ö §Ù§ß§Ñ§é§Ö§ß§Ú§Ö totalSupply

        Burn(msg.sender, _value);// §©§Ñ§á§å§ã§Ü §ã§à§Ò§í§ä§Ú§ñ Burn

        return true;

    

    }

	

	 /* §¶§å§ß§Ü§è§Ú§ñ §Ù§Ñ§Þ§à§â§à§Ù§Ü§Ú §ä§à§Ü§Ö§ß§à§Ó */

	function freeze(uint256 _value) onlyOwner returns (bool success)   {

	    

        require (balanceOf[msg.sender] > _value); //§á§â§à§Ó§Ö§â§Ü§Ñ §é§ä§à §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã§Ö §Ö§ã§ä§î §ß§å§Ø§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó

		require (_value > 0); 

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value); // §µ§Þ§Ö§ß§î§ê§Ñ§Ö§Þ §Ó §Þ§ï§á§á§Ú§ß§Ô§Ö balanceOf

        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value); // §±§â§Ú§Ò§Ñ§Ó§Ý§ñ§Ö§Þ §Ó §Þ§ï§á§á§Ú§ß§Ô freezeOf

        Freeze(msg.sender, _value);

        return true;

    }

	

	/* §¶§å§ß§Ü§è§Ú§ñ §â§Ñ§Ù§Þ§à§â§à§Ù§Ü§Ú §ä§à§Ü§Ö§ß§à§Ó */

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

		

		

	

	//§±§à§Ù§Ó§à§Ý§ñ§Ö§ä §ã§à§Ù§Õ§Ñ§ä§Ö§Ý§ð §Ó§í§Ó§à§Õ§Ú§ä§î §ç§â§Ñ§ß§ñ§ë§Ú§Ö§ã§ñ §ß§Ñ §Ñ§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §¿§æ§Ú§â§í §Ú §ä§à§Ü§Ö§ß§í

	

	

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

 * §¢§Ö§Ù§à§á§Ñ§ã§ß§í§Ö §Þ§Ñ§ä§Ö§Þ§Ñ§ä§Ú§é§Ö§ã§Ü§Ú§Ö §à§á§Ö§â§Ñ§è§Ú§Ú

 */

 

	

library  SafeMath {

	// §å§Þ§ß§à§Ø§Ö§ß§Ú§Ö

  function safeMul(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }

	//§Õ§Ö§Ý§Ö§ß§Ú§Ö

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {

    assert(b > 0);

    uint256 c = a / b;

    assert(a == b * c + a % b);

    return c;

  }

	//§Ó§í§é§Ú§ä§Ñ§ß§Ú§Ö

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {

    assert(b <= a);

    return a - b;

  }

	//§ã§Ý§à§Ø§Ö§ß§Ú§Ö

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