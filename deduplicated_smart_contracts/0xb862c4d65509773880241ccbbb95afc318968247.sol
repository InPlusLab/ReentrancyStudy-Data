/**

 *Submitted for verification at Etherscan.io on 2019-01-24

*/



pragma solidity ^0.5.0;





library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        require(c / a == b);

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);

        uint256 c = a / b;

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;

        return c;

    }



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



contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string memory name, string memory symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }

    function name() public view returns (string memory) {

        return _name;

    }

    function symbol() public view returns (string memory) {

        return _symbol;

    }

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }

    function owner() public view returns (address) {

        return _owner;

    }

    modifier onlyOwner() {

        require(isOwner());

        _;

    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract Pausable is Ownable {

    event Paused(address account);

    event Unpaused(address account);



    bool private _paused;



    constructor () internal {

        _paused = false;

    }

    function paused() public view returns (bool) {

        return _paused;

    }

    modifier whenNotPaused() {

        require(!_paused);

        _;

    }

    modifier whenPaused() {

        require(_paused);

        _;

    }

    function pause() public onlyOwner whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }

    function unpause() public onlyOwner whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}





contract SCTtoken is ERC20, ERC20Detailed , Pausable{

    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(DECIMALS));

    uint256 private _totalSupply ;

    mapping (address => uint256) private _balances;



    constructor () public ERC20Detailed("ScoutChain Token", "SCT", DECIMALS) {

        _balances[msg.sender] = INITIAL_SUPPLY;

        _totalSupply = INITIAL_SUPPLY;

    }



    using SafeMath for uint256;



    mapping (address => mapping (address => uint256)) private _allowed;   

    mapping (address => uint256) public freezeOf;

    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);

    event Freeze(address indexed from, uint256 value);

    event Unfreeze(address indexed from, uint256 value);   



    function totalSupply() public view  

    returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address owner) public view 

    returns (uint256) {

        return _balances[owner];

    }



    function frozenBalance(address owner) public view 

    returns (uint256) {

        return freezeOf[owner];

    }



    function freezeAccount(address target, bool freeze) public onlyOwner {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }



    function allowance(address owner, address spender) public view 

    returns (uint256) {

        return _allowed[owner][spender];

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



    function transfer(address to, uint256 value) public whenNotPaused

  returns (bool) {

        require(to != address(0) &&!frozenAccount[msg.sender]);  

	

        _transfer(msg.sender, to, value);

        return true;

    }

 

    function transferFrom(address from, address to, uint256 value) public whenNotPaused

  returns (bool) {

        require(to != address(0) &&!frozenAccount[from]); 



        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    function approve(address spender, uint256 value) public 

  returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    function freeze(uint256 _value) public  returns (bool success) {



        _balances[msg.sender] = SafeMath.sub(_balances[msg.sender], _value);  

        freezeOf[msg.sender] = SafeMath.add(freezeOf[msg.sender], _value);    

        emit Freeze(msg.sender, _value);

        return true;

    }

	

    function unfreeze(uint256 _value) public returns (bool success) {



        freezeOf[msg.sender] = SafeMath.sub(freezeOf[msg.sender], _value);    

	_balances[msg.sender] = SafeMath.add(_balances[msg.sender], _value);

        emit Unfreeze(msg.sender, _value);

        return true;

    }



    function _transfer(address from, address to, uint256 value) internal 

 {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }

 

}