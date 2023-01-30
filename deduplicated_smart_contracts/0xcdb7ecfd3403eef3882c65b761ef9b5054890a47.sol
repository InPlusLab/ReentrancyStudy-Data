pragma solidity ^0.4.18;
contract Hurify {
/* Public variables of the token */
string public name = "Hurify Token";                  // Token Name
string public symbol = "HUR";                         // Token symbol
uint public decimals = 18;                            // Token Decimal Point
address public owner;                                 // Owner of the Token Contract
uint256 totalHurify;                                  // Total Token for the Crowdsale
uint256 totalToken;                                   // The current total token supply.
bool public hault = false;                            // Crowdsale State
 /* This creates an array with all balances */
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
/* This generates a public event on the blockchain that will notify clients */
event Transfer(address indexed from, address indexed to, uint256 value);
/* This notifies clients about the refund amount */
 event Burn(address _from, uint256 _value);
 event Approval(address _from, address _to, uint256 _value);
/* Initializes contract with initial supply tokens to the creator of the contract */
function Hurify (
  address _hurclan
  ) public {
   owner = msg.sender;                                            // Assigning owner address.
   balances[msg.sender] = 212500000 * (10 ** decimals);            // Assigning Total Token balance to owner
   totalHurify = 273125000 * (10 ** decimals);
   balances[_hurclan] = safeAdd(balances[_hurclan], 53125000 * (10 ** decimals));
}
function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
modifier onlyPayloadSize(uint size) {
   require(msg.data.length >= size + 4) ;
   _;
}
modifier onlyowner {
  require (owner == msg.sender);
  _;
}
///@notice Alter the Total Supply.
function tokensup(uint256 _value) onlyowner public{
  totalHurify = safeAdd(totalHurify, _value * (10 ** decimals));
  balances[owner] = safeAdd(balances[owner], _value * (10 ** decimals));
}
///@notice Transfer tokens based on type
function hurifymint( address _client, uint _value, uint _type) onlyowner public {
  uint numHur;
  require(totalToken <= totalHurify);
  if(_type == 1){
      numHur = _value * 6000 * (10 ** decimals);
  }
  else if (_type == 2){
      numHur = _value * 5000 * (10 ** decimals);
  }
  balances[owner] = safeSub(balances[owner], numHur);
  balances[_client] = safeAdd(balances[_client], numHur);
  totalToken = safeAdd(totalToken, numHur);
  Transfer(owner, _client, numHur);
}
///@notice Transfer token with only value
function hurmint( address _client, uint256 _value) onlyowner public {
  require(totalToken <= totalHurify);
  uint256 numHur = _value * ( 10 ** decimals);
  balances[owner] = safeSub(balances[owner], numHur);
  balances[_client] = safeAdd(balances[_client], numHur);
  totalToken = safeAdd(totalToken, numHur);
  Transfer(owner, _client, numHur);
}
//Default assumes totalSupply can&#39;t be over max (2^256 - 1).
//If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check requireit doesn&#39;t wrap.
//Replace the if with this one instead.
function transfer(address _to, uint256 _value) public returns (bool success) {
    require(!hault);
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = safeSub(balances[msg.sender],_value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
          // Balance or allowance too low
          revert();
      }
      require(!hault);
      balances[_to] = safeAdd(balances[_to], _value);
      balances[_from] = safeSub(balances[_from],_value);
      allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);
      Transfer(_from, _to, _value);
      return true;
}
/// @dev Sets approved amount of tokens for spender. Returns success.
/// @param _spender Address of allowed account.
/// @param _value Number of approved tokens.
/// @return Returns success of function call.
function approve(address _spender, uint256 _value)
    public
    returns (bool)
{
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
}
/// @dev Returns number of allowed tokens for given address.
/// @param _owner Address of token owner.
/// @param _spender Address of token spender.
/// @return Returns remaining allowance for spender.
function allowance(address _owner, address _spender)
    constant
    public
    returns (uint256)
{
    return allowed[_owner][_spender];
}
/// @notice Returns balance of HUR Tokens.
/// @param _from Balance for Address.
function balanceOf(address _from) public view returns (uint balance) {
    return balances[_from];
  }

///@notice Returns the Total Number of HUR Tokens.
function totalSupply() public view returns (uint Supply){
  return totalHurify;
}
/// @notice Pause the crowdsale
function pauseable() public onlyowner {
    hault = true;
  }
/// @notice Unpause the crowdsale
function unpause() public onlyowner {
    hault = false;
}

/// @notice Remove `_value` tokens from the system irreversibly
function burn(uint256 _value) onlyowner public returns (bool success) {
    require (balances[msg.sender] >= _value);                                          // Check if the sender has enough
    balances[msg.sender] = safeSub(balances[msg.sender], _value);                      // Subtract from the sender
    totalHurify = safeSub(totalHurify, _value);                                        // Updates totalSupply
    Burn(msg.sender, _value);
    return true;
}
}