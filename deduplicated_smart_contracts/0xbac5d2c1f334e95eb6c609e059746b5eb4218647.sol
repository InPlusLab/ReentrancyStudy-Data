pragma solidity 0.4.21;

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface LandManagementInterface {
    function ownerAddress() external view returns (address);
    function managerAddress() external view returns (address);
    function communityAddress() external view returns (address);
    function dividendManagerAddress() external view returns (address);
    function walletAddress() external view returns (address);
    //    function unicornTokenAddress() external view returns (address);
    function candyToken() external view returns (address);
    function megaCandyToken() external view returns (address);
    function userRankAddress() external view returns (address);
    function candyLandAddress() external view returns (address);
    function candyLandSaleAddress() external view returns (address);

    function isUnicornContract(address _unicornContractAddress) external view returns (bool);

    function paused() external view returns (bool);
    function presaleOpen() external view returns (bool);
    function firstRankForFree() external view returns (bool);

    function ethLandSaleOpen() external view returns (bool);

    function landPriceWei() external view returns (uint);
    function landPriceCandy() external view returns (uint);

    function registerInit(address _contract) external;
}

contract LandAccessControl {

    LandManagementInterface public landManagement;

    function LandAccessControl(address _landManagementAddress) public {
        landManagement = LandManagementInterface(_landManagementAddress);
        landManagement.registerInit(this);
    }

    modifier onlyOwner() {
        require(msg.sender == landManagement.ownerAddress());
        _;
    }

    modifier onlyManager() {
        require(msg.sender == landManagement.managerAddress());
        _;
    }

    modifier onlyCommunity() {
        require(msg.sender == landManagement.communityAddress());
        _;
    }

    modifier whenNotPaused() {
        require(!landManagement.paused());
        _;
    }

    modifier whenPaused {
        require(landManagement.paused());
        _;
    }

    modifier onlyWhileEthSaleOpen {
        require(landManagement.ethLandSaleOpen());
        _;
    }

    modifier onlyLandManagement() {
        require(msg.sender == address(landManagement));
        _;
    }

    modifier onlyUnicornContract() {
        require(landManagement.isUnicornContract(msg.sender));
        _;
    }

    modifier onlyCandyLand() {
        require(msg.sender == address(landManagement.candyLandAddress()));
        _;
    }


    modifier whilePresaleOpen() {
        require(landManagement.presaleOpen());
        _;
    }

    function isGamePaused() external view returns (bool) {
        return landManagement.paused();
    }
}


contract StandardToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 totalSupply_;

    event Burn(address indexed burner, uint256 value);

    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract MegaCandy is StandardToken, LandAccessControl {

    string public constant name = "Unicorn Mega Candy"; // solium-disable-line uppercase
    string public constant symbol = "Mega"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    event Mint(address indexed _to, uint  _amount);


    //uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));


    function MegaCandy(address _landManagementAddress) LandAccessControl(_landManagementAddress) public {
    }

    function init() onlyLandManagement whenPaused external view {
    }

    function transferFromSystem(address _from, address _to, uint256 _value) onlyUnicornContract public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) onlyUnicornContract public returns (bool) {
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        //contract address here
        emit Burn(msg.sender, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }

    function mint(address _to, uint256 _amount) onlyCandyLand public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

}