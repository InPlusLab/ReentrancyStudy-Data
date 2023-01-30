/**

 *Submitted for verification at Etherscan.io on 2019-04-11

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 */

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



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



/**

 * @title Ownable

 */

contract Ownable {

    address public owner;



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



   

    function transferOwnership(address newOwner) public onlyOwner {

        if (newOwner != address(0)) {

            owner = newOwner;

        }

    }



}



/**

 * @title ERC20Basic

 */

contract ERC20Basic {

    uint public _totalSupply;

    function totalSupply() public constant returns (uint);

    function balanceOf(address who) public constant returns (uint);

    function transfer(address to, uint value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

}



/**

 * @title ERC20 interface

 */

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public constant returns (uint);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve(address spender, uint value) public;

    event Approval(address indexed owner, address indexed spender, uint value);

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is Ownable, ERC20Basic {

    using SafeMath for uint;

    mapping(address => uint) public balances;



    /**

    * @dev Fix for the ERC20 short address attack.

    */

    modifier onlyPayloadSize(uint size) {

        require(!(msg.data.length < size + 4));

        _;

    }



    /**

    * @dev transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32)  returns (bool) {

        require(balances[msg.sender] >= _value);

        

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        

        return true;

    }

    

    function batchTransfer(address[] _receivers, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {

      uint cnt = _receivers.length;

      uint256 amount = _value.mul(uint256(cnt));

      require(cnt > 0 && cnt <= 100);

      require(_value > 0 && balances[msg.sender] >= amount);

  

      balances[msg.sender] = balances[msg.sender].sub(amount);

      

      for (uint i = 0; i < cnt; i++) {

          balances[_receivers[i]] = balances[_receivers[i]].add(_value);

          emit Transfer(msg.sender, _receivers[i], _value);

      }

      return true;

    }







    /**

    * @dev Gets the balance of the specified address.

    */

    function balanceOf(address _owner) public constant returns (uint balance) {

        return balances[_owner];

    }



}



/**

 * @title Standard ERC20 token

 * @dev Implementation of the basic standard token.

 */

contract StandardToken is BasicToken, ERC20 {



    mapping (address => mapping (address => uint)) public allowed;



    uint public constant MAX_UINT = 2**256 - 1;



    /**

    * @dev Transfer tokens from one address to another

    * @param _from address The address which you want to send tokens from

    * @param _to address The address which you want to transfer to

    * @param _value uint the amount of tokens to be transferred

    */

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) returns (bool){

        var _allowance = allowed[_from][msg.sender];

        

        require(_allowance >= _value);

        require(balances[_from] >= _value);



        if (_allowance < MAX_UINT) {

            allowed[_from][msg.sender] = _allowance.sub(_value);

        }

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        

        return true;

    }



    /**

    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

    * @param _spender The address which will spend the funds.

    * @param _value The amount of tokens to be spent.

    */

    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {



        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));



        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

    }



    /**

    * @dev Function to check the amount of tokens than an owner allowed to a spender.

    * @param _owner address The address which owns the funds.

    * @param _spender address The address which will spend the funds.

    * @return A uint specifying the amount of tokens still available for the spender.

    */

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {

        return allowed[_owner][_spender];

    }



}





/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

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



contract BlackList is Ownable, BasicToken {



    function getBlackListStatus(address _maker) external constant returns (bool) {

        return isBlackListed[_maker];

    }



    function getOwner() external constant returns (address) {

        return owner;

    }



    mapping (address => bool) public isBlackListed;

    

    function addBlackList (address _evilUser) public onlyOwner {

        isBlackListed[_evilUser] = true;

        emit AddedBlackList(_evilUser);

    }



    function removeBlackList (address _clearedUser) public onlyOwner {

        isBlackListed[_clearedUser] = false;

        emit RemovedBlackList(_clearedUser);

    }



    function destroyBlackFunds (address _blackListedUser) public onlyOwner {

        require(isBlackListed[_blackListedUser]);

        uint dirtyFunds = balanceOf(_blackListedUser);

        balances[_blackListedUser] = 0;

        _totalSupply -= dirtyFunds;

        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);

    }



    event DestroyedBlackFunds(address _blackListedUser, uint _balance);



    event AddedBlackList(address _user);



    event RemovedBlackList(address _user);



}





contract SPAYToken is Pausable, StandardToken, BlackList {



    string public name;

    string public symbol;

    uint public decimals;



    // @param _balance Initial supply of the contract

    // @param _name Token Name

    // @param _symbol Token symbol

    // @param _decimals Token decimals

    function SPAYToken(uint _initialSupply, string _name, string _symbol, uint _decimals) public {

        _totalSupply = _initialSupply;

        name = _name;

        symbol = _symbol;

        decimals = _decimals;

        balances[owner] = _initialSupply;

    }



    function transfer(address _to, uint _value) public whenNotPaused  returns (bool) {

        require(!isBlackListed[msg.sender]);

        return super.transfer(_to, _value);

    }

    

    function batchTransfer (address[] _receivers,uint256 _value ) public whenNotPaused onlyOwner returns (bool)  {

      return super.batchTransfer(_receivers, _value);

    }



    function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool) {

        require(!isBlackListed[_from]);

        return super.transferFrom(_from, _to, _value);

    }



    function balanceOf(address who) public constant returns (uint) {

        return super.balanceOf(who);

    }



    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {

       return super.approve(_spender, _value);

    }



    function allowance(address _owner, address _spender) public constant returns (uint remaining) {

        return super.allowance(_owner, _spender);

    }



    function totalSupply() public constant returns (uint) {

        return _totalSupply;

    }



    // Issue a new amount of tokens

    // these tokens are deposited into the owner address

    // @param _amount Number of tokens to be issued

    function issue(uint amount) public onlyOwner {

        require(_totalSupply + amount > _totalSupply);

        require(balances[owner] + amount > balances[owner]);



        balances[owner] += amount;

        _totalSupply += amount;

        emit Issue(amount);

    }



    // Redeem tokens.

    // These tokens are withdrawn from the owner address

    // @param _amount Number of tokens to be issued

    function redeem(uint amount) public onlyOwner {

        require(_totalSupply >= amount);

        require(balances[owner] >= amount);



        _totalSupply -= amount;

        balances[owner] -= amount;

        emit Redeem(amount);

    }





    event Issue(uint amount);



    event Redeem(uint amount);



}