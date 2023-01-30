/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity ^0.4.25;







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}





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





  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



contract ERC20CompatibleToken {

    using SafeMath for uint;



    mapping(address => uint) balances; // List of user balances.



    event Transfer(address indexed from, address indexed to, uint value);

  	event Approval(address indexed owner, address indexed spender, uint value);

    event Burn(address indexed who, uint value);



  	mapping (address => mapping (address => uint)) internal allowed;



    function transferFrom(address _from, address _to, uint _value) public returns (bool) {

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);

    

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }

  

    function approve(address _spender, uint _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public view returns (uint) {

        return allowed[_owner][_spender];

    }



}









contract Eclaira is ERC20CompatibleToken,Ownable {

    using SafeMath for uint;



    string public name    = "Eclaira";

    string public symbol  = "ECT";

    uint public decimals = 18;

    uint public totalSupply = 100*1000*1000 * 1 ether;

    uint public lockSupply=25*1000*1000 * 1 ether;

    

    uint public lockDate=1543791600;

    address public mainWallet;

    

    modifier isLocked() {

        if(now<lockDate){

            require(balances[mainWallet] - totalSupply.sub(lockSupply) >=0);

        }

        _;

    }



    constructor(address _mainWallet) public {

        mainWallet=_mainWallet;

        

        balances[mainWallet] = totalSupply;

        emit Transfer(msg.sender, mainWallet, totalSupply);

    }

   



    function balanceOf(address _who) public view returns(uint){

        return balances[_who];

    }

    

    function transfer(address _to, uint256 _value) isLocked public returns (bool) {

        require(_to != address(0));

        require(_value >= 0);

        require(_value <= balances[msg.sender]);

        

        if(msg.sender==mainWallet && now < lockDate){

            require(balances[mainWallet].sub(_value).sub(totalSupply.sub(lockSupply)) >=0);

        }



        balances[_to] = balances[_to].add(_value);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) isLocked public returns (bool) {

        require(_value <= allowed[_from][msg.sender]);



        if(msg.sender==mainWallet && now < lockDate){

            require(balances[mainWallet].sub(_value).sub(totalSupply.sub(lockSupply)) >=0);

        }

        

        balances[_from] = balances[_from].sub(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }

    

    function burn(address _who, uint256 _value) onlyOwner public { 

        balances[_who] = balances[_who].sub(_value); 

        totalSupply = totalSupply.sub(_value);

        emit Burn(_who, _value); 

    }



}