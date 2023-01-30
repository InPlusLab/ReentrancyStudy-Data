/**

 *Submitted for verification at Etherscan.io on 2018-10-18

*/



pragma solidity ^0.4.20;



library SafeMath {



    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;

        return c;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }

}



contract Owned {

    address public owner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = 0xbFb06aeB85f3aD1bEfd881b408010EDa1F2160F1;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0x0));

        emit OwnershipTransferred(owner,_newOwner);

        owner = _newOwner;

    }

    

}





contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}





contract BiopToken is ERC20Interface, Owned {

    

    using SafeMath for uint;

   

    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;

  

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    

    event Burn(address indexed burner, uint256 value);

    

    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor() public {

        symbol = "BIOP";

        name = "BlockInterop";

        decimals = 18;

        _totalSupply = 20000000;

        _totalSupply = _totalSupply.mul(10 ** uint(decimals));

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

    }

    

    

    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public view returns (uint) {

        return _totalSupply;

    }



    function() public payable{

        revert();

    }



    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) public returns (bool success) {

        require(to != address(0));

        require(tokens > 0);

        require(balances[msg.sender] >= tokens);

        

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account

    //

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

    // recommends that there are no checks for the approval double-spend attack

    // as this should be implemented in user interfaces 

    // ------------------------------------------------------------------------

    function approve(address spender, uint tokens) public returns (bool success) {

        require(spender != address(0));

        require(tokens > 0);

        

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Transfer `tokens` from the `from` account to the `to` account

    // 

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the `from` account and

    // - From account must have sufficient balance to transfer

    // - Spender must have sufficient allowance to transfer

    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        require(from != address(0));

        require(to != address(0));

        require(tokens > 0);

        require(balances[from] >= tokens);

        require(allowed[from][msg.sender] >= tokens);

        

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }

    

    

    // ------------------------------------------------------------------------

    // Increase the amount of tokens that an owner allowed to a spender.

    //

    // approve should be called when allowed[_spender] == 0. To increment

    // allowed value is better to use this function to avoid 2 calls (and wait until

    // the first transaction is mined)

    // _spender The address which will spend the funds.

    // _addedValue The amount of tokens to increase the allowance by.

    // ------------------------------------------------------------------------

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        require(_spender != address(0));

        

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }

    

    

    // ------------------------------------------------------------------------

    // Decrease the amount of tokens that an owner allowed to a spender.

    //

    // approve should be called when allowed[_spender] == 0. To decrement

    // allowed value is better to use this function to avoid 2 calls (and wait until

    // the first transaction is mined)

    // _spender The address which will spend the funds.

    // _subtractedValue The amount of tokens to decrease the allowance by.

    // ------------------------------------------------------------------------

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        require(_spender != address(0));

        

        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }

    

    

    // ------------------------------------------------------------------------

    // Burns a specific amount of tokens.

    // _value The amount of token to be burned.

    // ------------------------------------------------------------------------

    function burn(uint256 _value) onlyOwner public {

      require(_value > 0);

      require(_value <= balances[owner]);

      balances[owner] = balances[owner].sub(_value);

      _totalSupply = _totalSupply.sub(_value);

      emit Burn(owner, _value);

      emit Transfer(owner, address(0), _value);

    }

    

}