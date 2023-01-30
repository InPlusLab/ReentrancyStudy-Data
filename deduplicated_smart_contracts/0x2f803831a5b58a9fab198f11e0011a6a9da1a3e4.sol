pragma solidity ^0.5.0;





import "./SafeMath.sol";







contract BITBUS {



    using SafeMath for uint;



    address private BTB1;

    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply;



    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    

    constructor() public {



        symbol = "BTB";

        name = "BITBUS";

        decimals = 18;

        BTB1 = msg.sender;

        _totalSupply = 10000000 * 10**uint(decimals);

        _balances[BTB1] = _totalSupply;

        emit Transfer(address(0), BTB1, _totalSupply);



    }





    function totalSupply() public view returns (uint) {

        return _totalSupply;



    }





    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }





    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];

    }





    function increaseAllowance(address spender, uint256 addValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addValue));

        return true;

    }





    function decreaseAllowance(address spender, uint256 subValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subValue));

        return true;

    }





    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }





    function approve(address spender, uint256 value) public returns (bool) {

        require(msg.sender != spender);

        _approve(msg.sender, spender, value);

        return true;

    }





    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);

        _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));

        return true;

    }





    function () external payable {

    }

    



    function ClaimEther(uint256 amount) public{

		require(msg.sender == BTB1);

		msg.sender.transfer(amount);

	}

	

    function _transfer(address from, address to, uint256 value) internal {

        require(from != address(0));

        require(to != address(0));

        require(to != address(this));

        require(value != 0);

        _balances[to] = _balances[to].add(value);

        _balances[from] = _balances[from].sub(value);

        emit Transfer(from, to, value);

    }





    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0));

        require(spender != address(0));

        _allowances[owner][spender] = value;

        emit Approval(owner, spender, value);

    }







}