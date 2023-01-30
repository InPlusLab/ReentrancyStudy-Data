pragma solidity ^0.4.18;

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

interface TokenUpgraderInterface{
    function upgradeFor(address _for, uint256 _value) public returns (bool success);
    function upgradeFrom(address _by, address _for, uint256 _value) public returns (bool success);
}
  
contract Token {
    using SafeMath for uint256;

    address public owner = msg.sender;

    string public name = "\"BANKEX\" project utility token";
    string public symbol = "BKX";

    bool public upgradable = false;
    bool public upgraderSet = false;
    TokenUpgraderInterface public upgrader;

    bool public locked = false;
    uint8 public decimals = 18;
    uint256 public decimalMultiplier = 10**(uint256(decimals));

    modifier unlocked() {
        require(!locked);
        _;
    }

    // Ownership

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner returns (bool success) {
        require(newOwner != address(0));      
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }


    // ERC20 related functions

    uint256 public totalSupply = 0;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */

    function transfer(address _to, uint256 _value) unlocked public returns (bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

 /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */

    function balanceOf(address _owner) view public returns (uint256 bal) {
        return balances[_owner];
    }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */

    function transferFrom(address _from, address _to, uint256 _value) unlocked public returns (bool) {
        require(_to != address(0));
        uint256 _allowance = allowed[_from][msg.sender];
        require(_allowance >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */

    function approve(address _spender, uint256 _value) unlocked public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function increaseApproval (address _spender, uint _addedValue) unlocked public
        returns (bool success) {
            allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
            Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
            return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) unlocked public
        returns (bool success) {
            uint oldValue = allowed[msg.sender][_spender];
            if (_subtractedValue > oldValue) {
                allowed[msg.sender][_spender] = 0;
            } else {
                allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
            }
            Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
            return true;
    }

  /**
    * Constructor mints tokens to corresponding addresses
   */

    function Token () public {
        //values are in natural format

        address publicSaleReserveAddress = 0xDef97e9F16831DA75a52fF583323c4cdd1f508da;
        mint(publicSaleReserveAddress, 74000000);

        address preICOconversionFromWavesReserveAddress = 0x2E3Da0E4DF6C6704c21bD53D873Af09af0a34f86;
        mint(preICOconversionFromWavesReserveAddress, 3000000);

        address preICOconversionFromEthReserveAddress = 0xDE4c839cee9464212C76473420bb87eF0Da8a617;
        mint(preICOconversionFromEthReserveAddress, 3000000);

        address advisorsReserveAddress = 0xDdbC59F27332448EC1e3F9797B69169e680F21Dc;
        mint(advisorsReserveAddress, 40000000);
        
        address frozenForInstitutionalSalesReserveAddress = 0xf026ad161674E4f8b3306a191Bd936E01A5BD4A7;
        mint(frozenForInstitutionalSalesReserveAddress, 140000000);

        address teamReserveAddress = 0x3c0A403245F1C144207935b65da418Ddcc29c94E;
        mint(teamReserveAddress, 50000000);
        
        address optionsReserveAddress = 0x0483bF7eB04cE3d20936e210B9F3801964791EDA;
        mint(optionsReserveAddress, 50000000);
        
        address foundationReserveAddress = 0x6a6a0b4aaa60E97386F94c5414522159b45DEdE8;
        mint(foundationReserveAddress, 40000000);

        assert(totalSupply == 400000000*decimalMultiplier);
    }

  /**
   * @dev Function to mint tokens
   * @param _for The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */

    function mint(address _for, uint256 _amount) internal returns (bool success) {
        _amount = _amount*decimalMultiplier;
        balances[_for] = balances[_for].add(_amount);
        totalSupply = totalSupply.add(_amount);
        Transfer(0, _for, _amount);
        return true;
    }

  /**
   * @dev Function to lock token transfers
   * @param _newLockState New lock state
   * @return A boolean that indicates if the operation was successful.
   */

    function setLock(bool _newLockState) onlyOwner public returns (bool success) {
        require(_newLockState != locked);
        locked = _newLockState;
        return true;
    }

  /**
   * @dev Function to allow token upgrades
   * @param _newState New upgrading allowance state
   * @return A boolean that indicates if the operation was successful.
   */

    function allowUpgrading(bool _newState) onlyOwner public returns (bool success) {
        upgradable = _newState;
        return true;
    }

    function setUpgrader(address _upgraderAddress) onlyOwner public returns (bool success) {
        require(!upgraderSet);
        require(_upgraderAddress != address(0));
        upgraderSet = true;
        upgrader = TokenUpgraderInterface(_upgraderAddress);
        return true;
    }

    function upgrade() public returns (bool success) {
        require(upgradable);
        require(upgraderSet);
        require(upgrader != TokenUpgraderInterface(0));
        uint256 value = balances[msg.sender];
        assert(value > 0);
        delete balances[msg.sender];
        totalSupply = totalSupply.sub(value);
        assert(upgrader.upgradeFor(msg.sender, value));
        return true;
    }

    function upgradeFor(address _for, uint256 _value) public returns (bool success) {
        require(upgradable);
        require(upgraderSet);
        require(upgrader != TokenUpgraderInterface(0));
        uint256 _allowance = allowed[_for][msg.sender];
        require(_allowance >= _value);
        balances[_for] = balances[_for].sub(_value);
        allowed[_for][msg.sender] = _allowance.sub(_value);
        totalSupply = totalSupply.sub(_value);
        assert(upgrader.upgradeFrom(msg.sender, _for, _value));
        return true;
    }

    function () payable external {
        if (upgradable) {
            assert(upgrade());
            return;
        }
        revert();
    }

}