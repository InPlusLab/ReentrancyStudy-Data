/**

 *Submitted for verification at Etherscan.io on 2019-03-07

*/



pragma solidity 0.5.5;



library SafeMath {

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);

        uint256 c = a / b;



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

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



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



contract ERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



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

}



contract GameTheoryToken is ERC20 {



  uint256 constant public MAX_SUPPLY = 100000000000000;

  uint256 constant public SUPPLY_PER_CONTRACT = 25000000000000;



  string public name = "GameTheoryToken";

  string public symbol = "GTT";

  uint8 public decimals = 8;



  address public gasPriceGame;

  address public lastBlockGame;

  address public currentKingGame;

  address public auctionGame;



  constructor(

    address _gasPriceGame,

    address _lastBlockGame,

    address _currentKingGame,

    address _auctionGame

  )

    public

  {

    gasPriceGame = _gasPriceGame;

    lastBlockGame = _lastBlockGame;

    currentKingGame = _currentKingGame;

    auctionGame = _auctionGame;



    _mint(gasPriceGame, SUPPLY_PER_CONTRACT);

    _mint(lastBlockGame, SUPPLY_PER_CONTRACT);

    _mint(currentKingGame, SUPPLY_PER_CONTRACT);

    _mint(auctionGame, SUPPLY_PER_CONTRACT);

  }



}