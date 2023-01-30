pragma solidity ^0.4.13;

contract GCCExchangeAccessControl {
    address public owner;
    address public operator;

    modifier onlyOwner() {require(msg.sender == owner);_;}
    modifier onlyOperator() {require(msg.sender == operator);_;}
    modifier onlyOwnerOrOperator() {require(msg.sender == owner || msg.sender == operator);_;}

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

    function transferOperator(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        operator = newOperator;
    }

    function withdrawBalance(address _recipient, uint256 amount) external onlyOwnerOrOperator {
        require(amount > 0);
        require(amount <= this.balance);
        require(_recipient != address(0));
        _recipient.transfer(amount);
    }

    function depositBalance() external payable {}
}

contract GCCExchangePausable is GCCExchangeAccessControl {
    bool public paused;

    modifier whenPaused() {require(paused);_;}
    modifier whenNotPaused() {require(!paused);_;}

    function pause() public onlyOwnerOrOperator whenNotPaused {
        paused = true;
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
    }
}

contract GCCExchangeCoinOperation is GCCExchangePausable {
    GoCryptobotCoinERC827 internal coin;

    function setCoinContract(address _address) external onlyOwnerOrOperator {
        GoCryptobotCoinERC827 _contract = GoCryptobotCoinERC827(_address);
        // FIXME: Check coin.isGCC();
        coin = _contract;
    }

    function unpause() public {
        require(coin != address(0));
        super.unpause();
    }

    function operate(bytes data) external onlyOwnerOrOperator {
        require(coin.call(data));
    }
}

contract GCCExchangeCore is GCCExchangeCoinOperation {
    uint8 constant FEE_RATE = 5;
    uint256 public exchangeRate;
    address internal coinStorage;

    event ExchangeRateChange(uint256 from, uint256 to);
    event Withdrawal(address claimant, uint256 mgccAmount, uint256 weiAmount);

    function GCCExchangeCore() public {
        coinStorage = this;
        // 1 mGCC = 0.000001 ETH;
        exchangeRate = 1000000000000 wei;

        paused = true;

        owner = msg.sender;
        operator = msg.sender;
    }

    function setCoinStorage(address _address) public onlyOwnerOrOperator {
        coinStorage = _address;
    }

    function setExchangeRate(uint256 rate) external onlyOwnerOrOperator {
        ExchangeRateChange(exchangeRate, rate);
        exchangeRate = rate;
    }

    function withdraw(address _claimant, uint256 _mgcc) public whenNotPaused {
        // FIXME: Check withdrawal limits here
        require(coin.allowance(_claimant, this) >= _mgcc);
        require(coin.transferFrom(_claimant, coinStorage, _mgcc));
        uint256 exchange = (_convertToWei(_mgcc) / 100) * (100 - FEE_RATE);
        _claimant.transfer(exchange);
        Withdrawal(_claimant, _mgcc, exchange);
    }

    function _convertToWei(uint256 mgcc) internal view returns (uint256) {
        return mgcc * exchangeRate;
    }

    function () external payable {
        revert();
    }
}

contract GoCryptobotCoinERC20 {
    using SafeMath for uint256;

    string public constant name = "GoCryptobotCoin";
    string public constant symbol = "GCC";
    uint8 public constant decimals = 3;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 totalSupply_;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
       @dev total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
       @dev Gets the balance of the specified address.
       @param _owner The address to query the the balance of.
       @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /**
       @dev transfer token for a specified address
       @param _to The address to transfer to.
       @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
       @dev Function to check the amount of tokens that an owner allowed to a spender.
       @param _owner address The address which owns the funds.
       @param _spender address The address which will spend the funds.
       @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
       @dev Transfer tokens from one address to another
       @param _from address The address which you want to send tokens from
       @param _to address The address which you want to transfer to
       @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
       @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
      
       Beware that changing an allowance with this method brings the risk that someone may use both the old
       and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
       race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
       https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
       @param _spender The address which will spend the funds.
       @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
       @dev Increase the amount of tokens that an owner allowed to a spender.
      
       approve should be called when allowed[_spender] == 0. To increment
       allowed value is better to use this function to avoid 2 calls (and wait until
       the first transaction is mined)
       From MonolithDAO Token.sol
       @param _spender The address which will spend the funds.
       @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
       @dev Decrease the amount of tokens that an owner allowed to a spender.
      
       approve should be called when allowed[_spender] == 0. To decrement
       allowed value is better to use this function to avoid 2 calls (and wait until
       the first transaction is mined)
       From MonolithDAO Token.sol
       @param _spender The address which will spend the funds.
       @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract GoCryptobotCoinERC827 is GoCryptobotCoinERC20 {
    /**
       @dev Addition to ERC20 token methods. It allows to
       approve the transfer of value and execute a call with the sent data.

       Beware that changing an allowance with this method brings the risk that
       someone may use both the old and the new allowance by unfortunate
       transaction ordering. One possible solution to mitigate this race condition
       is to first reduce the spender's allowance to 0 and set the desired value
       afterwards:
       https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

       @param _spender The address that will spend the funds.
       @param _value The amount of tokens to be spent.
       @param _data ABI-encoded contract call to call `_to` address.

       @return true if the call function was executed successfully
     */
    function approve( address _spender, uint256 _value, bytes _data ) public returns (bool) {
        require(_spender != address(this));
        super.approve(_spender, _value);
        require(_spender.call(_data));
        return true;
    }

    /**
       @dev Addition to ERC20 token methods. Transfer tokens to a specified
       address and execute a call with the sent data on the same transaction

       @param _to address The address which you want to transfer to
       @param _value uint256 the amout of tokens to be transfered
       @param _data ABI-encoded contract call to call `_to` address.

       @return true if the call function was executed successfully
     */
    function transfer( address _to, uint256 _value, bytes _data ) public returns (bool) {
        require(_to != address(this));
        super.transfer(_to, _value);
        require(_to.call(_data));
        return true;
    }

    /**
       @dev Addition to ERC20 token methods. Transfer tokens from one address to
       another and make a contract call on the same transaction

       @param _from The address which you want to send tokens from
       @param _to The address which you want to transfer to
       @param _value The amout of tokens to be transferred
       @param _data ABI-encoded contract call to call `_to` address.

       @return true if the call function was executed successfully
     */
    function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public returns (bool) {
        require(_to != address(this));
        super.transferFrom(_from, _to, _value);
        require(_to.call(_data));
        return true;
    }

    /**
       @dev Addition to StandardToken methods. Increase the amount of tokens that
       an owner allowed to a spender and execute a call with the sent data.

       approve should be called when allowed[_spender] == 0. To increment
       allowed value is better to use this function to avoid 2 calls (and wait until
       the first transaction is mined)
       From MonolithDAO Token.sol
       @param _spender The address which will spend the funds.
       @param _addedValue The amount of tokens to increase the allowance by.
       @param _data ABI-encoded contract call to call `_spender` address.
     */
    function increaseApproval(address _spender, uint _addedValue, bytes _data) public returns (bool) {
        require(_spender != address(this));
        super.increaseApproval(_spender, _addedValue);
        require(_spender.call(_data));
        return true;
    }

    /**
       @dev Addition to StandardToken methods. Decrease the amount of tokens that
       an owner allowed to a spender and execute a call with the sent data.

       approve should be called when allowed[_spender] == 0. To decrement
       allowed value is better to use this function to avoid 2 calls (and wait until
       the first transaction is mined)
       From MonolithDAO Token.sol
       @param _spender The address which will spend the funds.
       @param _subtractedValue The amount of tokens to decrease the allowance by.
       @param _data ABI-encoded contract call to call `_spender` address.
     */
    function decreaseApproval(address _spender, uint _subtractedValue, bytes _data) public returns (bool) {
        require(_spender != address(this));
        super.decreaseApproval(_spender, _subtractedValue);
        require(_spender.call(_data));
        return true;
    }
}

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
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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