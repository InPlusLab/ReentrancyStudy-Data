/**

 *Submitted for verification at Etherscan.io on 2019-02-19

*/



pragma solidity ^0.4.2;



//  import "./IERC20.sol"; 

//  import "./SafeMath.sol";



pragma solidity ^0.4.2;







library SafeMath {



   function mul(uint256 a, uint256 b) internal pure returns (uint256) {

       // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

       // benefit is lost if 'b' is also tested.

       // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

       if (a == 0) {

           return 0;

       }



       uint256 c = a * b;

       require(c / a == b);



       return c;

   }



 

   function div(uint256 a, uint256 b) internal pure returns (uint256) {

       // Solidity only automatically asserts when dividing by 0

       require(b > 0);

       uint256 c = a / b;

       // assert(a == b * c + a % b); // There is no case in which this doesn't hold



       return c;

   }



 

   function sub(uint256 a, uint256 b) internal pure returns (uint256) {

       require(b <= a);

       uint256 c = a - b;



       return c;

   }



   /**

   * @dev Adds two unsigned integers, reverts on overflow.

   */

   function add(uint256 a, uint256 b) internal pure returns (uint256) {

       uint256 c = a + b;

       require(c >= a);



       return c;

   }



 

   function mod(uint256 a, uint256 b) internal pure returns (uint256) {

       require(b != 0);

       return a % b;

   }

}

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

contract ERC20 is IERC20 {

   using SafeMath for uint256;



   mapping (address => uint256) private _balances;



   mapping (address => mapping (address => uint256)) private _allowed;



   uint256 private _totalSupply;





   function totalSupply() public view returns (uint256) {

       return _totalSupply;

   }



 

   function balanceOf(address owner) public view returns (uint256) {

       return _balances[owner];

   }



 

   function allowance(address owner, address spender) public view returns (uint256) {

       return _allowed[owner][spender];

   }





   function transfer(address to, uint256 value) public returns (bool) {

       _transfer(msg.sender, to, value);

       return true;

   }





   function approve(address spender, uint256 value) public returns (bool) {

       require(spender != address(0));



       _allowed[msg.sender][spender] = value;

       emit Approval(msg.sender, spender, value);

       return true;

   }





   function transferFrom(address from, address to, uint256 value) public returns (bool) {

       _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

       _transfer(from, to, value);

       emit Approval(from, msg.sender, _allowed[from][msg.sender]);

       return true;

   }



   function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

       require(spender != address(0));



       _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

       emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

       return true;

   }





   function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

       require(spender != address(0));



       _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

       emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

       return true;

   }





   function _transfer(address from, address to, uint256 value) internal {

       require(to != address(0));



       _balances[from] = _balances[from].sub(value);

       _balances[to] = _balances[to].add(value);

       emit Transfer(from, to, value);

   }





   function _mint(address account, uint256 value) internal {

       require(account != address(0));



       _totalSupply = _totalSupply.add(value);

       _balances[account] = _balances[account].add(value);

       emit Transfer(address(0), account, value);

   }



   function _burn(address account, uint256 value) internal {

       require(account != address(0));



       _totalSupply = _totalSupply.sub(value);

       _balances[account] = _balances[account].sub(value);

       emit Transfer(account, address(0), value);

   }





   function _burnFrom(address account, uint256 value) internal {

       _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

       _burn(account, value);

       emit Approval(account, msg.sender, _allowed[account][msg.sender]);

   }

}



// import "./IERC20.sol";





contract ERC20Detailed is IERC20 {

   string private _name;

   string private _symbol;

   uint8 private _decimals;



   constructor (string memory name, string memory symbol, uint8 decimals) public {

       _name = name;

       _symbol = symbol;

       _decimals = decimals;

   }



   /**

    * @return the name of the token.

    */

   function name() public view returns (string memory) {

       return _name;

   }



   /**

    * @return the symbol of the token.

    */

   function symbol() public view returns (string memory) {

       return _symbol;

   }



   /**

    * @return the number of decimals of the token.

    */

   function decimals() public view returns (uint8) {

       return _decimals;

   }

}

pragma solidity ^0.4.2;



// import "./ERC20.sol";



/**

* @title Burnable Token

* @dev Token that can be irreversibly burned (destroyed).

*/

contract ERC20Burnable is ERC20 {

   /**

    * @dev Burns a specific amount of tokens.

    * @param value The amount of token to be burned.

    */

   function burn(uint256 value) public {

       _burn(msg.sender, value);

   }



   /**

    * @dev Burns a specific amount of tokens from the target address and decrements allowance

    * @param from address The address which you want to send tokens from

    * @param value uint256 The amount of token to be burned

    */

   function burnFrom(address from, uint256 value) public {

       _burnFrom(from, value);

   }

}

pragma solidity ^0.4.2;



/**

* @title ERC20 interface

* @dev see https://github.com/ethereum/EIPs/issues/20

*/

pragma solidity ^0.4.2;



// import "./ERC20.sol";

// import "./ERC20Detailed.sol";

// import "./ERC20Burnable.sol";





contract BettingZone is ERC20, ERC20Detailed, ERC20Burnable {

   uint8 public constant DECIMALS = 18;

   uint256 public constant INITIAL_SUPPLY = 150000000 * (10 ** uint256(DECIMALS));



   /**

    * @dev Constructor that gives msg.sender all of existing tokens.

    */

   constructor () public ERC20Detailed("BettingZone", "BZT", 18) {

       _mint(msg.sender, INITIAL_SUPPLY);

   }

}