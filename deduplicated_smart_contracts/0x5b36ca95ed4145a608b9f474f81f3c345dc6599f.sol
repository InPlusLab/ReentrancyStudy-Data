/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.4.16;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



library SafeMath {

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

    if (_a == 0) {

      return 0;

    }

    uint256 c = _a * _b;

    require(c / _a == _b);

    return c;

  }



  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    require(_b > 0); 

    uint256 c = _a / _b;

    return c;

  }



  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    require(_b <= _a);

    uint256 c = _a - _b;

    return c;

  }



  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

    uint256 c = _a + _b;

    require(c >= _a);

    return c;

  }



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}





contract owned {

    address public owner;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;

    }

}





contract TokenERC20 {

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 8;

    uint256 public totalSupply;



    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    // This generates a public event on the blockchain that will notify clients

    event Transfer(address indexed from, address indexed to, uint256 value);



    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);





    constructor(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol

    ) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  

        balanceOf[msg.sender] = totalSupply;                

        name = tokenName;                                  

        symbol = tokenSymbol;                              

    }



    function _transfer(address _from, address _to, uint _value) internal {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != 0x0);

        // Check if the sender has enough

        require(balanceOf[_from] >= _value);

        // Check for overflows

        require(balanceOf[_to] + _value > balanceOf[_to]);

        // Save this for an assertion in the future

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        // Subtract from the sender

        balanceOf[_from] = SafeMath.sub(balanceOf[_from],_value);

        // Add the same to the recipient

        balanceOf[_to] = SafeMath.add(balanceOf[_to],_value);

        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] = SafeMath.sub(allowance[_from][msg.sender],_value);

        _transfer(_from, _to, _value);

        return true;

    }

    

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

        require((_value == 0) || (allowance[msg.sender][_spender] == 0));

        allowance[msg.sender][_spender] = _value;

        return true;

    }



    function approveAndCall(address _spender, uint256 _value, bytes _extraData)

        public

        returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

        balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender],_value);            // Subtract from the sender

        totalSupply = SafeMath.sub(totalSupply,_value);                                // Updates totalSupply

        emit Burn(msg.sender, _value);

        return true;

    }





    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);                                                // Check if the targeted balance is enough

        require(_value <= allowance[_from][msg.sender]);                                    // Check allowance

        balanceOf[_from] = SafeMath.sub(balanceOf[_from],_value);                           // Subtract from the targeted balance

        allowance[_from][msg.sender] = SafeMath.sub(allowance[_from][msg.sender],_value);   // Subtract from the sender's allowance

        totalSupply = SafeMath.sub(totalSupply,_value);                                     // Update totalSupply

        emit Burn(_from, _value);

        return true;

    }

}





contract TKF is owned, TokenERC20 {



    mapping (address => bool) public frozenAccount;



    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol

    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}



    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint _value) internal {

        require (_to != 0x0);                                              // Prevent transfer to 0x0 address. Use burn() instead

        require (balanceOf[_from] >= _value);                              // Check if the sender has enough

        require (balanceOf[_to] + _value > balanceOf[_to]);                // Check for overflows

        require(!frozenAccount[_from]);                                    // Check if sender is frozen

        require(!frozenAccount[_to]);                                      // Check if recipient is frozen

        balanceOf[_from] = SafeMath.sub(balanceOf[_from],_value);          // Subtract from the sender

        balanceOf[_to] = SafeMath.add(balanceOf[_to],_value);              // Add the same to the recipient

        emit Transfer(_from, _to, _value);

    }



    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        balanceOf[target] = SafeMath.add(balanceOf[target],mintedAmount);

        totalSupply = SafeMath.add(totalSupply,mintedAmount); 

        emit Transfer(0, this, mintedAmount);

        emit Transfer(this, target, mintedAmount);

    }



    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }



}