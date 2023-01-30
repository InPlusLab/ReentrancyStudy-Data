pragma solidity ^0.5.0;

import "SafeMath.sol";

contract GlosferToken {
    using SafeMath for uint;

    // ## Variables ## //    
    string public name = "Glosfer Token";
    string public symbol = "GLO";
    uint256 public decimals = 18;
    // Beneficiary of tokens
    uint256 public totalSupply;
    uint256 public ProjectSupply;
    uint256 public PrivateSale;
    uint256 public LockTwoYears;
    uint256 public LockOneYear;
    uint256 public DappSupply;
    address public admin;
    address public projectSupply;
    address public privateSale;
    // Address for locked tokens for two years
    address public lockTwoYears;
    // Address for locked tokens for one year
    address public lockOneYear;
    address public dappSupply;
    uint256 public releaseTime;
    bool public released;
    uint public lockTypeOneCounter;
    uint public lockTypeTwoCounter;
    bool public oneYearReleased;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _admin, address _projectSupply, address _privateSale, address _dappSupply, address _lockTwoYears, address _lockOneYear, uint256 _releaseTime) public {
        admin = _admin;
        projectSupply = _projectSupply;
        privateSale = _privateSale;
        lockTwoYears = _lockTwoYears;
        lockOneYear = _lockOneYear;
        dappSupply = _dappSupply;

        releaseTime = _releaseTime;
        released = false;

        totalSupply = 4000000000 * (10 ** decimals);

        ProjectSupply = totalSupply * 15 / 100;
        balanceOf[_projectSupply] = ProjectSupply;

        PrivateSale = totalSupply * 10 / 100;
        balanceOf[_privateSale] = PrivateSale;

        DappSupply = totalSupply * 65 / 100;
        balanceOf[_dappSupply] = DappSupply;

        LockTwoYears = totalSupply * 5 / 100;
        LockOneYear = totalSupply * 5 / 100;
    }

    modifier onlyOwner {
        require(msg.sender == admin);
        _;                            
    }

    function setReleaseTime(uint256 _releaseTime) public onlyOwner {
        releaseTime = _releaseTime;        
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function release() public onlyOwner {        
        require(released == false);
        require(now >= releaseTime);
        
        if (lockTypeOneCounter < 24)
            lockTypeOneCounter ++;
        
        if (lockTypeTwoCounter < 12)
            lockTypeTwoCounter ++;
        
        // One year release 
        if (oneYearReleased == false) {
            balanceOf[lockOneYear] = balanceOf[lockOneYear].add(LockOneYear.div(12));
            if (lockTypeTwoCounter == 12)
                // All released for one year
                oneYearReleased = true;
        }

        // Two years release 
        if (released == false) {
            balanceOf[lockTwoYears] = balanceOf[lockTwoYears].add(LockTwoYears.div(24));            
            if (lockTypeOneCounter == 24)
                // All released for two years
                released = true;
            else
                // Increase release time for one month
                releaseTime = releaseTime + 2678400;
        }
    }
}