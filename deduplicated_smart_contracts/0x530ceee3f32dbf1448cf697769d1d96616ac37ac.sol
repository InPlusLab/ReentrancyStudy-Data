/**

 *Submitted for verification at Etherscan.io on 2019-05-15

*/



//*******************************************************************************************************************//

// RevolutionAI is redefined revolution for blockchain.                                                              //

// https://twitter.com/revolutions_ai                                                                                //

// https://www.facebook.com/ai.revolutions/                                                                          //

// https://www.linkedin.com/company/revolutions-ai/                                                                  //

//*******************************************************************************************************************//



pragma solidity ^0.5.0;

/**

 * @title SafeMath

 * @dev   Unsigned math operations with safety checks that revert on error

 */

 

library SafeMath {

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256){

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        require(c / a == b,"Calculation error");

        return c;

    }



    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256){

        // Solidity only automatically asserts when dividing by 0

        require(b > 0,"Calculation error");

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256){

        require(b <= a,"Calculation error");

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256){

        uint256 c = a + b;

        require(c >= a,"Calculation error");



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256){

        require(b != 0,"Calculation error");

        return a % b;

    }

}



/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */



interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title RevolutionsAi

 * @dev   RevolitionAi contract following erc20 standard

 */



contract RevolutionsAi is IERC20

{

    using SafeMath for uint256;

    string  public constant name               = "RevolutionsAi";			                           // Token Name

    string  public constant symbol             = "REVI";			                                   // Token Symbol

    uint256 public constant decimals           =  18;

    uint256 public constant decimalsETH        =  10 ** 18;

    uint256 public totalSupply_                =  1000000000 * decimalsETH;                            // Total supply of Token

    uint256 public bountySupply                =  10000000 * decimalsETH;	                            // 1 % of total supply

    uint256 public teamSupply                  =  150000000 * decimalsETH;                             // 15 % of total supply

    uint256 public HNI_Supply                  =  50000000 * decimalsETH;	                            // 5 % of total supply

    uint256 public marketingAndAdvisorSupply   =  100000000 * decimalsETH;                             // 10 % of total supply

    address private bounty                     =  0x3959907Ca87bcF914E55114b317c3BBEc4e5678e;          // Bounty reserve address

    address private team                       =  0x0b78E45Ef37769cA074a7A49d9B4d20f4d9c836F;          // Team reserve address

    address private HNI                        =  0x5CA7c7d0a6ad3B3FE55c2a5cD62f388Aa806EF66;          // High Network Individual reserve address

    address private marketingAndAdvisor        =  0xe22a63704f50226b9716A4d60d16c775D09fe21f;          // Team reserve address

    address private owner;

    bool public lockStatus;

    

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;



     constructor() public{

        owner = msg.sender;

        balances[bounty] = bountySupply;                                                // Total bounty supply

        balances[team] = teamSupply;                                                    // Reserve for team

        balances[HNI] = HNI_Supply;                                                     // Reserve for High Networth Individuals

        balances[marketingAndAdvisor] = marketingAndAdvisorSupply;                      // Reserve for marketing advisor

        balances[owner] = totalSupply_;                                                 // Owner tokens

        emit Transfer(address(0), bounty, balances[bounty]);

        emit Transfer(address(0), team, balances[team]);

        emit Transfer(address(0), HNI, balances[HNI]);

        emit Transfer(address(0), marketingAndAdvisor, balances[marketingAndAdvisor]);

        emit Transfer(address(0), owner, balances[owner]);

        totalSupply_ = totalSupply_.sub(bountySupply);

        totalSupply_ = totalSupply_.sub(teamSupply);

        totalSupply_ = totalSupply_.sub(HNI_Supply);

        totalSupply_ = totalSupply_.sub(marketingAndAdvisorSupply);

        totalSupply_ = balances[owner];

        lockStatus = false;

     }

     

     modifier onlyOwner(){

        require(isOwner(),"You are not the owner");

        _;

      }

     function isOwner() public view returns (bool) {

        return msg.sender == owner;

     }

     function Owner() internal view returns (address){

        return owner;

     }

     function burn(uint256 _value) public onlyOwner returns(bool){

        require(owner != address(0), "ERC20: burn from the zero address");

        totalSupply_ = totalSupply_.sub(_value);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        emit Transfer(msg.sender, address(0), _value);

     }

     function burnFrom(address _from, uint256 _value) public onlyOwner returns(bool){

        totalSupply_ = totalSupply_.sub(_value);

        balances[_from] = balances[_from].sub(_value);

        emit Transfer(_from, address(0), _value);

     }

     function mint(uint256 _value) public onlyOwner returns(bool){

        require(owner != address(0), "ERC20: burn from the zero address");

        require(_value > 0,"The amount should be greater than 0");

        balances[msg.sender] = balances[msg.sender].add(_value);

        totalSupply_ = totalSupply_.add(_value);

        emit Transfer(address(0), msg.sender, _value);

        return true;

     }

     function lock(bool _status) public onlyOwner returns(bool){

        lockStatus = _status;

        return true;

     }

     function transferOwnership(address _newOwner) public onlyOwner returns(bool){

        require(_newOwner != address(0),"Not a correct address");

        owner = _newOwner;

        return true;

     }

     function transfer(address _to, uint256 _value) external returns(bool){

        require(!lockStatus, "Transaction is not allowed");

        require(_to != address(0),"Address is Incorrect");

        require(balances[msg.sender] >= _value,"Token amount invalid");

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

     }

     function transferFrom(address _from, address _to, uint256 _value) external returns(bool){

        require(!lockStatus, "Transaction is not allowed");

        require(_from != address(0),"Address is Incorrect");

        require(_to != address(0),"Address is Incorrect");

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0,"Invalid Amount of Token");

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;

     }

     function balanceOf(address _owner) external view returns(uint256){

        return balances[_owner];

     }

     function totalSupply() external view returns(uint256){

        return totalSupply_;

     }

     function approve(address _spender, uint256 _value) external returns(bool){

        require(owner != address(0), "Incorrect address");

        require(_spender != address(0),"Incorrect Address");

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

     }

     function allowance(address _owner, address _spender) external view returns(uint256){

        require(_owner != address(0) && _spender != address(0),"Adddress is not correct");

        return allowed[_owner][_spender];

     }

     /**Get the current supply */

     function getSupply() public view returns(

     uint256 _totalsupply,

     uint256 _bountySupply,

     uint256 _teamSupply,

     uint256 _HNI_Supply,

     uint256 _marketingAndAdvisorSupply){

          _totalsupply = totalSupply_;

          _bountySupply = bountySupply;

          _teamSupply = teamSupply;

          _HNI_Supply = HNI_Supply;

          _marketingAndAdvisorSupply = marketingAndAdvisorSupply;

     }

}