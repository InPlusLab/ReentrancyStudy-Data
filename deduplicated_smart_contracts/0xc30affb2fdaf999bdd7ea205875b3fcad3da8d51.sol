pragma solidity ^0.5.0;





import "./SafeMath.sol";







    // Phaselabs ERC20+ contract.



contract Phase {



    using SafeMath for uint;



    address private Phaselabs;

    string public symbol;

    string public  name;

    uint public decimals;

    uint _totalSupply;



    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    

    constructor() public {

        symbol = "psx";

        name = "PHASE";

        decimals = 18;

        Phaselabs = msg.sender;

        _totalSupply = 1000000000 * 10**uint(decimals);

        _balances[Phaselabs] = _totalSupply;

        emit Transfer(address(0), Phaselabs, _totalSupply);

    }

    

    

    // Returns total token supply.    



    function totalSupply() public view returns (uint) {

        return _totalSupply;

    }

    



    // Returns the balance of the specified address.



    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }

    



    // Returns the amount of tokens that an owner allowed to a spender.



    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];

    }

    



    // Increase the amount of tokens that an owner allowed to a spender.



    function increaseAllowance(address spender, uint256 addValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addValue));

        return true;

    }

    



    // Decrease the amount of tokens that an owner allowed to a spender.



    function decreaseAllowance(address spender, uint256 subValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subValue));

        return true;

    }

    



    // Transfer token function.



    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }

    



    // Allow someone to spend some tokens in your behalf.



    function approve(address spender, uint256 value) public returns (bool) {

        require(msg.sender != spender);

        _approve(msg.sender, spender, value);

        return true;

    }

    



    // Function for attempts to send tokens that are approved from an owner to a spender.



    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);

        _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));

        return true;

    }





    // Contract will accept ether.

    

    function () external payable {

    }

    



    // Withdraw ether.

    

    function WithdrawEther(uint256 amount) public{

		require(msg.sender == Phaselabs);

		msg.sender.transfer(amount);

	}

	



    // Safety checks for token transfer.	

	

    function _transfer(address from, address to, uint256 value) internal {

        require(from != address(0));

        require(to != address(0));

        require(to != address(this));

        require(value != 0);

        _balances[to] = _balances[to].add(value);

        _balances[from] = _balances[from].sub(value);

        emit Transfer(from, to, value);

    }



    // Safety checks for the approve function.

    

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0));

        require(spender != address(0));

        _allowances[owner][spender] = value;

        emit Approval(owner, spender, value);

    }



}