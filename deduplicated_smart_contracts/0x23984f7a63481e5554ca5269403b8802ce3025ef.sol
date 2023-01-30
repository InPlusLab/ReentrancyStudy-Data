pragma solidity ^0.4.18;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
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
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public{
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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
contract BusinessCreditStop is Ownable{

    bool public stopped;

    modifier stoppable {
        assert (!stopped);
        _;
    }
    function stop() public onlyOwner {
        stopped = true;
    }
    function start()  public onlyOwner {
        stopped = false;
    }

}
contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf( address _owner ) public view returns (uint256);
    function allowance( address owner, address spender )public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom( address from, address to, uint256 value)public returns (bool);
    function approve( address spender, uint256 value )public returns (bool);
    event Transfer( address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}

contract BusinessCreditTokenBase is ERC20,BusinessCreditStop {
    using SafeMath for uint256;
    uint256                                                     _supply;
    mapping (address => uint256)                                _balances;
    mapping (address => mapping (address => uint256)) internal  _approvals;
    
    
     function totalSupply() public view returns (uint256) {
        return _supply;
    }
	/**
    * @dev Gets the balance of the specified address. 
    * @param _owner The address to query the the balance of. 
    * @return An uint256 representing the amount owned by the passed address. 
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }
	/**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender)  public view returns (uint256) {
        return _approvals[_owner][_spender];
    }
	/**
	* @dev transfer token for a specified address 
	* @param _to The address to transfer to. 
	* @param _value The amount to be transferred. 
	*/
    function transfer(address _to, uint256 _value) stoppable public returns (bool) {
        //require(_to != address(0));
        require(_value <= _balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    /**
     * @dev Transfer tokens from one address to another 
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred 
     */
    function transferFrom(address _from, address _to, uint256 _value) stoppable public returns (bool) {
        //require(_to != address(0));
        require(_value <= _balances[_from]);
        require(_value <= _approvals[_from][msg.sender]);

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        _approvals[_from][msg.sender] = _approvals[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) stoppable public returns (bool) {
        _approvals[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

}
contract BusinessCreditToken is BusinessCreditTokenBase{
    string  public name = "Business Credit Token";
    uint8   public decimals = 18; // standard token precision. override to customize
    string  public symbol = &#39;BCT&#39;;
    string  public version = &#39;v0.1&#39;;
    uint256 supply = 100000000 * 100 * 10 ** 18;// 10, 000, 000, 000
    function BusinessCreditToken() public{
        _balances[msg.sender] = supply;
        _supply = supply;
    }
    modifier burnStopped() {
        require(_balances[0x0] <= 100000000 * 90 * 10 ** 18);
        _;
    }
    function burn(uint256 _value) onlyOwner stoppable burnStopped public {
        require(_balances[msg.sender] >= _value);
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[0x0] = _balances[0x0].add(_value);
        Transfer(msg.sender, 0x0, _value);
    }
    function burnBalance() onlyOwner public view returns (uint256) {
        return _balances[0x0];
    }
    function increaseApproval(address _spender, uint256 _addedValue) stoppable public returns (bool) {
        _approvals[msg.sender][_spender] = _approvals[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, _approvals[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) stoppable public returns (bool) {
        uint256 oldValue = _approvals[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            _approvals[msg.sender][_spender] = 0;
        }
        else {
            _approvals[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, _approvals[msg.sender][_spender]);
        return true;
    }
    
}