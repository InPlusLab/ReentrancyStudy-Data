/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity ^0.4.25;







// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

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



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

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

  

    // Transfer the balance from owner's account to another account

    function approve(address _spender, uint _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public view returns (uint) {

        return allowed[_owner][_spender];

    }



}





/*





  / _ \_____ / __/ _` | '__/ _` | __|                                   

 |  __/_____| (_| (_| | | | (_| | |_                                    

  \___|      \___\__,_|_|  \__,_|\__|                                   

  ____  _                                 _    ____ _           _       

 |  _ \(_) __ _ _ __ ___   ___  _ __   __| |  / ___| |__   __ _(_)_ __  

 | | | | |/ _` | '_ ` _ \ / _ \| '_ \ / _` | | |   | '_ \ / _` | | '_ \ 

 | |_| | | (_| | | | | | | (_) | | | | (_| | | |___| | | | (_| | | | | |

 |____/|_|\__,_|_| |_| |_|\___/|_| |_|\__,_|  \____|_| |_|\__,_|_|_| |_|

                                                                        

                                                                        



Symbol      : ECT

Name        : Eclaira

Total supply: 100,000,000.000000000000000000

Decimals    : 18



website:https://e-carat.io/

developer:(c) Block Potentiality Studio 2019

                                                 

*/





contract Eclaira is ERC20CompatibleToken,Ownable {

    using SafeMath for uint;



    string public name    = "Eclaira";

    string public symbol  = "ECT";

    uint public decimals = 18;

    uint public totalSupply = 100*1000*1000 * 1 ether;

    uint public lockSupply=25*1000*1000 * 1 ether;

    



    // ----------------------------------------------------------------------------

    // 

    // Lock 75% tokens until 2019/6/30 24:00:00

    // 

    // ----------------------------------------------------------------------------



    uint public lockDate=1561939200;

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

    

    

    // Send `tokens` amount of tokens from address `from` to address `to`

    // The transferFrom method is used for a withdraw workflow, allowing contracts to send

    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge

    // fees in sub-currencies; the command should fail unless the _from account has

    // deliberately authorized the sender of the message via some mechanism; we propose

    // these standardized APIs for approval:



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

    

    

    // ----------------------------------------------------------------------------

    // 

    // Burn Tokenm

    // Only mainWallet could be burn

    // 

    // ----------------------------------------------------------------------------

    

    function burn(uint256 _value) onlyOwner public { 

        balances[mainWallet] = balances[mainWallet].sub(_value); 

        totalSupply = totalSupply.sub(_value);

        emit Burn(mainWallet, _value); 

        emit Transfer(mainWallet, address(0), _value);

    }



}