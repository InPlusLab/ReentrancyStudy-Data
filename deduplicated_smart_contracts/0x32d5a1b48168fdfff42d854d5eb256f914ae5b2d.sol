/**

 *Submitted for verification at Etherscan.io on 2018-09-05

*/



pragma solidity 0.4.23;



/**



 * �j�T�j    �X�T�T�T�T�T�T�[�X�T�T�T�T�T�T�[ �X�T�T�T�T�T�T�[ �X�T�T�T�T�T�T�[ �X�T�T�T�T�T�T�[     �X�T�T�T�T�T�T�[ �X�T�T�T�T�T�T�[ �X�T�[    �X�T�[

 * �U �U    �U �X�T�T�[ �U�U �X�T�T�T�T�a �U �X�T�T�[ �U �U �X�T�T�[ �U �U �X�T�T�[ �U     �U �X�T�T�[ �U �U �X�T�T�[ �U �U �^�[  �X�a �U

 * �U �U    �U �U  �^�T�a�U �^�T�T�T�[  �U �^�T�T�a �U �U �^�T�T�a �U �U �^�T�T�a �U     �U �U  �^�T�a �U �U  �U �U �U  �^�[�X�a  �U 

 * �U �U    �U �U  �X�T�[�U �X�T�T�T�a  �^�T�T�T�T�[ �U �^�T�T�T�T�[ �U �^�T�T�T�T�[ �U     �U �U  �X�T�[ �U �U  �U �U �U   �^�a   �U 

 * �U �^�T�T�T�g�U �^�T�T�a �U�U �^�T�T�T�T�[ �X�T�T�T�T�a �U �X�T�T�T�T�a �U �X�T�T�T�T�a �U �X�T�[ �U �^�T�T�a �U �U �^�T�T�a �U �U �X�[  �X�[ �U 

 * �m�T�T�T�T�T�a�^�T�T�T�T�T�T�a�^�T�T�T�T�T�T�a �^�T�T�T�T�T�T�a �^�T�T�T�T�T�T�a �^�T�T�T�T�T�T�a �^�T�a �^�T�T�T�T�T�T�a �^�T�T�T�T�T�T�a �m�T�a�^�T�T�a�^�T�m

 * 

 */

 

contract Ownable {

  address public owner;





  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }

}





contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }



contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}





contract token is Pausable{

    string public standard = 'Token 0.1';

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

    event Burn(address indexed from, uint256 value);



    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    event Transfer(address indexed from, address indexed to, uint256 value);



    function token(

        uint256 initialSupply,

        string tokenName,

        uint8 decimalUnits,

        string tokenSymbol

        ) {

        balanceOf[msg.sender] = initialSupply;

        totalSupply = initialSupply;

        name = tokenName;

        symbol = tokenSymbol;

        decimals = decimalUnits;

    }



    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool)   {

        if (balanceOf[msg.sender] < _value) throw;

        if (balanceOf[_to] + _value < balanceOf[_to]) throw;

        balanceOf[msg.sender] -= _value;

        balanceOf[_to] += _value;

        Transfer(msg.sender, _to, _value);

    }



    function approve(address _spender, uint256 _value)

        returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        return true;

    }



    function approveAndCall(address _spender, uint256 _value, bytes _extraData)

        returns (bool success) {    

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        if (balanceOf[_from] < _value) throw;

        if (balanceOf[_to] + _value < balanceOf[_to]) throw;

        if (_value > allowance[_from][msg.sender]) throw;

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;

    }



    function () {

        throw;

    }

}



contract MyAdvancedToken is Ownable, token{



    mapping (address => bool) public frozenAccount;

    bool frozen = false; 

    event FrozenFunds(address target, bool frozen);



    function MyAdvancedToken(

        uint256 initialSupply,

        string tokenName,

        uint8 decimalUnits,

        string tokenSymbol

    ) token (initialSupply, tokenName, decimalUnits, tokenSymbol) {}



    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool)  {

        if (balanceOf[msg.sender] < _value) throw;

        if (balanceOf[_to] + _value < balanceOf[_to]) throw;

        if (frozenAccount[msg.sender]) throw;

        balanceOf[msg.sender] -= _value;

        balanceOf[_to] += _value;

        Transfer(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        if (frozenAccount[_from]) throw;

        if (balanceOf[_from] < _value) throw;

        if (balanceOf[_to] + _value < balanceOf[_to]) throw;

        if (_value > allowance[_from][msg.sender]) throw;

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;

    }



    function freezeAccount(address target, bool isFrozen) onlyOwner public {

        frozenAccount[target] = isFrozen;

        FrozenFunds(target, isFrozen);

    }

    function unfreezeAccount(address target, bool isFrozen) onlyOwner public {

        frozenAccount[target] = !isFrozen;

        FrozenFunds(target, !isFrozen);

    }

    

    function freezeAccounts(address[] targets, bool isFrozen) onlyOwner public {

        require(targets.length > 0);



        for (uint j = 0; j < targets.length; j++) {

            require(targets[j] != 0x0);

            frozenAccount[targets[j]] = isFrozen;

            FrozenFunds(targets[j], isFrozen);

        }

    }



    function unfreezeAccounts(address[] targets, bool isFrozen) onlyOwner public {

        require(targets.length > 0);



        for (uint j = 0; j < targets.length; j++) {

            require(targets[j] != 0x0);

            frozenAccount[targets[j]] = !isFrozen;

            FrozenFunds(targets[j], !isFrozen);

        }

    }



  function freezeTransfers () {

    require (msg.sender == owner);



    if (!frozen) {

      frozen = true;

      Freeze ();

    }

  }



  function unfreezeTransfers () {

    require (msg.sender == owner);



    if (frozen) {

      frozen = false;

      Unfreeze ();

    }

  }





  event Freeze ();



  event Unfreeze ();



    function burn(uint256 _value) public returns (bool success) {        

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;

        totalSupply -= _value;

        Burn(msg.sender, _value);        

        return true;

    }

    

    function burnFrom(address _from, uint256 _value) public returns (bool success) {        

        require(balanceOf[_from] >= _value);

        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;

        allowance[_from][msg.sender] -= _value;

        totalSupply -= _value;

        Burn(_from, _value);        

        return true;

    }



}