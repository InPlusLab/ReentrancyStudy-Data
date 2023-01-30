/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

/*
*
*  v1.0
*  
*  By EP Cloud Team 
*
*/
pragma solidity 0.5.10;

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "msg.sender != owner");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}


contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;

  modifier whenNotPaused() {
    assert(!paused);
    _;
  }

  modifier whenPaused() {
    assert(paused);
    _;
  }

  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  function unpause() public onlyOwner whenPaused{
    paused = false;
    emit Unpause();
  }
}


contract TokenERC20 is Pausable {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // Check allowance
        require(allowance[_from][msg.sender] >= _value, "allowance[_from][msg.sender] < _value");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal whenNotPaused returns (bool success) {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0), "_to == address(0)");
        // Check if the sender has enough
        require(balanceOf[_from] >= _value, "balanceOf[_from] < _value");
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to], "balanceOf[_to] + _value < balanceOf[_to]");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        return true;
    }

}