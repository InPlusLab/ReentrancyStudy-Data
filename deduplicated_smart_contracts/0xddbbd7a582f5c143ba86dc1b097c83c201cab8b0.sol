/**
 *Submitted for verification at Etherscan.io on 2019-12-27
*/

pragma solidity ^0.4.24;

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256){
    if (_a == 0) {
      return 0;
    }
    uint256 c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256){
    uint256 c = _a / _b;
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256){
    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a,uint256 _b) internal pure returns (uint256){
    uint256 c = _a + _b;
    assert(c >= _a);
    return c;
  }

}

contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor () public{
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(
    address _newOwner
  )
    onlyOwner
    public
  {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract ERC20StdToken is Ownable, SafeMath {
  uint256 public totalSupply;
	string  public name;
	uint8   public decimals;
	string  public symbol;
	bool    public isMint;     // 是否可增发
    bool    public isBurn;    // 是否可销毁
    bool    public isFreeze; // 是否可冻结

  mapping (address => uint256) public balanceOf;
  mapping (address => uint256) public freezeOf;
  mapping (address => mapping (address => uint256)) public allowance;

  constructor(
    address _owner,
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _initialSupply,
    bool _isMint,
    bool _isBurn,
    bool _isFreeze) public {
    require(_owner != address(0));
    owner             = _owner;
  	decimals          = _decimals;
  	symbol            = _symbol;
  	name              = _name;
  	isMint            = _isMint;
    isBurn            = _isBurn;
    isFreeze          = _isFreeze;
  	totalSupply       = _initialSupply * 10 ** uint256(decimals);
    balanceOf[_owner] = totalSupply;
 }

 // This generates a public event on the blockchain that will notify clients
 event Transfer(address indexed _from, address indexed _to, uint256 _value);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);

 /* This notifies clients about the amount burnt */
 event Burn(address indexed _from, uint256 value);

  /* This notifies clients about the amount frozen */
 event Freeze(address indexed _from, uint256 value);

  /* This notifies clients about the amount unfrozen */
 event Unfreeze(address indexed _from, uint256 value);

 function approve(address _spender, uint256 _value) public returns (bool success) {
   allowance[msg.sender][_spender] = _value;
   emit Approval(msg.sender, _spender, _value);
   success = true;
 }

 /// @notice send `_value` token to `_to` from `msg.sender`
 /// @param _to The address of the recipient
 /// @param _value The amount of token to be transferred
 /// @return Whether the transfer was successful or not
 function transfer(address _to, uint256 _value) public returns (bool success) {
   require(_to != 0);
   require(balanceOf[msg.sender] >= _value);
   require(balanceOf[_to] + _value >= balanceOf[_to]);
   // balanceOf[msg.sender] -= _value;
   balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);

   // balanceOf[_to] += _value;
   balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);

   emit Transfer(msg.sender, _to, _value);
   success = true;
 }

 /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
 /// @param _from The address of the sender
 /// @param _to The address of the recipient
 /// @param _value The amount of token to be transferred
 /// @return Whether the transfer was successful or not
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
   require(_to != 0);
   require(balanceOf[_from] >= _value);
   require(allowance[_from][msg.sender] >= _value);
   require(balanceOf[_to] + _value >= balanceOf[_to]);
   // balanceOf[_from] -= _value;
   balanceOf[_from] = SafeMath.sub(balanceOf[_from], _value);
   // balanceOf[_to] += _value;
   balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);

   // allowance[_from][msg.sender] -= _value;
   allowance[_from][msg.sender] = SafeMath.sub(allowance[_from][msg.sender], _value);

   emit Transfer(_from, _to, _value);
   success = true;
 }

  function mint(uint256 amount) onlyOwner public {
  	require(isMint);
  	require(amount >= 0);
  	// balanceOf[msg.sender] += amount;
    balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], amount);
  	// totalSupply += amount;
    totalSupply = SafeMath.add(totalSupply, amount);
  }

  function burn(uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value);            // Check if the sender has enough
    require(_value > 0);
    balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);                      // Subtract from the sender
    totalSupply = SafeMath.sub(totalSupply, _value);                                // Updates totalSupply
    emit Burn(msg.sender, _value);
    success = true;
 }

  function freeze(uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value);            // Check if the sender has enough
    require(_value > 0);
    balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);                      // Subtract from the sender
    freezeOf[msg.sender] = SafeMath.add(freezeOf[msg.sender], _value);                                // Updates totalSupply
    emit Freeze(msg.sender, _value);
    success = true;
  }

  function unfreeze(uint256 _value) public returns (bool success) {
    require(freezeOf[msg.sender] >= _value);            // Check if the sender has enough
    require(_value > 0);
    freezeOf[msg.sender] = SafeMath.sub(freezeOf[msg.sender], _value);                      // Subtract from the sender
    balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], _value);
    emit Unfreeze(msg.sender, _value);
    success = true;
  }
}