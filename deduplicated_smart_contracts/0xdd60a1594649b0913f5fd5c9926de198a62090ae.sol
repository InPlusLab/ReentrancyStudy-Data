/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity 0.5.8;

/**
 * @title SafeMath
 *
 * This contract implements mathematics functions
 * which are not vulnerable to overflow and underflow.
 */
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);

    function totalSupply() public view returns(uint256 supply);
    function balanceOf(address _owner) public view returns(uint256 balance);
    //solhint-disable-next-line no-simple-event-func-name
    function transfer(address _to, uint256 _value) public returns(bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
    function approve(address _spender, uint256 _value) public returns(bool success);
    function allowance(address _owner, address _spender) public view returns(uint256 remaining);

    // function symbol() constant returns(string);
    function decimals() public view returns(uint8);
    // function name() constant returns(string);
}

contract Graceful {
    event Error(bytes32 message);

    // Only for functions that return bool success before any changes made.
    function _softRequire(bool _condition, bytes32 _message) internal {
        if (_condition) {
            return;
        }
        emit Error(_message);
        // Return bytes32(0).
        assembly {
            mstore(0, 0)
            return(0, 32)
        }
    }

    // Generic substitution for require().
    function _hardRequire(bool _condition, bytes32 _message) internal pure {
        if (_condition) {
            return;
        }
        // Revert with bytes32(_message).
        assembly {
            mstore(0, _message)
            revert(0, 32)
        }
    }

    function _not(bool _condition) internal pure returns(bool) {
        return !_condition;
    }
}

contract Owned is Graceful {
    bool public isConstructedOwned;
    address public contractOwner;
    address public pendingContractOwner;

    event ContractOwnerChanged(address newContractOwner);
    event PendingContractOwnerChanged(address newPendingContractOwner);

    constructor() public {
        constructOwned();
    }

    function constructOwned() public returns(bool) {
        if (isConstructedOwned) {
            return false;
        }
        isConstructedOwned = true;
        contractOwner = msg.sender;
        emit ContractOwnerChanged(msg.sender);
        return true;
    }

    modifier onlyContractOwner() {
        _softRequire(contractOwner == msg.sender, 'Not a contract owner');
        _;
    }

    function changeContractOwnership(address _to) public onlyContractOwner() returns(bool) {
        pendingContractOwner = _to;
        emit PendingContractOwnerChanged(_to);
        return true;
    }

    function claimContractOwnership() public returns(bool) {
        _softRequire(pendingContractOwner == msg.sender, 'Not a pending contract owner');
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        emit ContractOwnerChanged(contractOwner);
        return true;
    }

    function forceChangeContractOwnership(address _to) public onlyContractOwner() returns(bool) {
        contractOwner = _to;
        emit ContractOwnerChanged(contractOwner);
        return true;
    }
}

contract Pausable is Owned {
    event Paused();
    event Unpaused();

    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(_not(paused), 'Paused');
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused, 'Not paused');
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyContractOwner whenNotPaused {
        paused = true;
        emit Paused();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyContractOwner whenPaused {
        paused = false;
        emit Unpaused();
    }
}

contract BasicToken is ERC20Interface {
    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

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

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}



contract StandardToken is BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

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

        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens
    * on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk
    *  that someone may use both the old
    * and the new allowance by unfortunate transaction ordering.
    *  One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0
    * and set the desired value afterwards:
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
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender] + _addedValue;
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
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue - _subtractedValue;
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract PausableToken is StandardToken, Pausable {
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
    public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue)
    public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
    public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

contract BurnableToken is BasicToken {
    event Burn(address indexed holder, uint256 value);

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    // solhint-disable-next-line no-simple-event-func-name
    function burn(uint256 _value) public returns (bool success) {
        return _burn(msg.sender, _value);
    }

    function _burn(address _holder, uint256 _value) internal returns (bool success) {
        require(_value <= balances[_holder]);

        balances[_holder] = balances[_holder] - _value;
        totalSupply_ = totalSupply_ - _value;
        emit Burn(_holder, _value);
        emit Transfer(_holder, address(0), _value);

        return true;
    }
}

contract CommissionList is Owned {
    using SafeMath for uint256;

    struct CommissionInfo {
        uint256 stat;
        uint256 perc;
    }

    uint256 internal constant ONE_HUNDRED_PERCENT = 10000;

    mapping (string => CommissionInfo) internal refillPaySystemInfo;
    mapping (string => CommissionInfo) internal withdrawPaySystemInfo;

    CommissionInfo internal transferInfo;

    event RefillCommissionIsChanged(string paySystem, uint256 stat, uint256 perc);
    event WithdrawCommissionIsChanged(string paySystem, uint256 stat, uint256 perc);
    event TransferCommissionIsChanged(uint256 stat, uint256 perc);

    function setRefillFor(string memory _paySystem, uint256 _stat, uint256 _perc)
    public onlyContractOwner returns (bool success) {
        _softRequire(_perc <= ONE_HUNDRED_PERCENT, 'perc is out of 100% range');

        refillPaySystemInfo[_paySystem] = CommissionInfo(_stat, _perc);

        emit RefillCommissionIsChanged(_paySystem, _stat, _perc);

        return true;
    }

    function setWithdrawFor(string memory _paySystem, uint256 _stat, uint256 _perc)
    public onlyContractOwner returns (bool success) {
        _softRequire(_perc <= ONE_HUNDRED_PERCENT, 'perc is out of 100% range');

        withdrawPaySystemInfo[_paySystem] = CommissionInfo(_stat, _perc);

        emit WithdrawCommissionIsChanged(_paySystem, _stat, _perc);

        return true;
    }

    function setTransfer(uint256 _stat, uint256 _perc)
    public onlyContractOwner returns (bool success) {
        _softRequire(_perc <= ONE_HUNDRED_PERCENT, 'perc is out of 100% range');

        transferInfo = CommissionInfo(_stat, _perc);

        emit TransferCommissionIsChanged(_stat, _perc);

        return true;
    }

    function getRefillPercFor(string memory _paySystem) public view returns (uint256) {
        return refillPaySystemInfo[_paySystem].perc;
    }

    function getRefillStatFor(string memory _paySystem) public view returns (uint256) {
        return refillPaySystemInfo[_paySystem].stat;
    }

    function getWithdrawPercFor(string memory _paySystem) public view returns (uint256) {
        return withdrawPaySystemInfo[_paySystem].perc;
    }

    function getWithdrawStatFor(string memory _paySystem) public view returns (uint256) {
        return withdrawPaySystemInfo[_paySystem].stat;
    }

    function getTransferPerc() public view returns (uint256) {
        return transferInfo.perc;
    }

    function getTransferStat() public view returns (uint256) {
        return transferInfo.stat;
    }

    function calcWithdraw(string memory _paySystem, uint256 _value) public view returns(uint256) {
        return (_value * withdrawPaySystemInfo[_paySystem].perc)/ONE_HUNDRED_PERCENT +
            withdrawPaySystemInfo[_paySystem].stat;
    }

    function calcRefill(string memory _paySystem, uint256 _value) public view returns(uint256) {
        return (_value * refillPaySystemInfo[_paySystem].perc)/ONE_HUNDRED_PERCENT +
            refillPaySystemInfo[_paySystem].stat;
    }

    function calcTransfer(uint256 _value) public view returns(uint256) {
        return (_value * transferInfo.perc)/ONE_HUNDRED_PERCENT + transferInfo.stat;
    }
}

contract AddressList is Owned {
    string public name;

    mapping (address => bool) public onList;

    constructor(string memory _name, bool nullValue) public {
        name = _name;
        onList[address(0x0)] = nullValue;
    }

    event ChangeWhiteList(address indexed to, bool onList);

    // Set whether _to is on the list or not. Whether 0x0 is on the list
    // or not cannot be set here - it is set once and for all by the constructor.
    function changeList(address _to, bool _onList) public onlyContractOwner returns (bool success) {
        _softRequire(_to != address(0x0), 'Cannot set zero address');
        if (onList[_to] != _onList) {
            onList[_to] = _onList;
            emit ChangeWhiteList(_to, _onList);
        }
        return true;
    }
}

contract EvaCurrency is PausableToken, BurnableToken {
    using SafeMath for uint256;

    string public name;
    string public symbol;

    CommissionList public commissionList;
    AddressList public moderList;

    // solhint-disable-next-line const-name-snakecase
    uint8 internal constant baseUnit = 2;

    mapping(address => uint) public lastUsedNonce;

    address public staker;

    event Mint(address holder, uint256 amount);
    event StakerChanged(address oldStaker, address newStaker);
    event ListsSet(CommissionList commissionList, AddressList addList);

    constructor() public {
        _constructEvaCurrency('lockPrototype', 'lockPrototype');
    }

    function isConstructableEvaCurrency() public view returns(bool) {
        return contractOwner == address(0);
    }

    function _constructEvaCurrency(string memory _name, string memory _symbol) internal {
        contractOwner = msg.sender;
        staker = msg.sender;
        name = _name;
        symbol = _symbol;
    }

    function constructEvaCurrency(string memory _name, string memory _symbol) public {
        require(isConstructableEvaCurrency(), 'Contract owner is already set');
        _constructEvaCurrency(_name, _symbol);
    }

    function decimals() public view returns(uint8) {
        return baseUnit;
    }

    function setLists(CommissionList _commissionList, AddressList _moderList)
    public onlyContractOwner returns(bool success) {
        commissionList = _commissionList;
        moderList = _moderList;
        emit ListsSet(commissionList, moderList);

        return true;
    }

    modifier onlyModer() {
        require(moderList.onList(msg.sender), 'Called not by moder');
        _;
    }

    function transferOnBehalf(address _to, uint256 _amount, uint256 _nonce, uint8 _v, bytes32 _r,
        bytes32 _s)
    public onlyModer whenNotPaused returns (bool success) {
        uint256 fee;
        uint256 resultAmount;
        bytes32 hash = keccak256(abi.encodePacked(_to, _amount, _nonce, address(this)));
        address sender = ecrecover(hash, _v, _r, _s);

        _softRequire(lastUsedNonce[sender] < _nonce, 'Invalid nonce');

        fee = commissionList.calcTransfer(_amount);
        resultAmount = _amount.add(fee);

        _softRequire(balances[sender] >= resultAmount, 'Insufficient funds');

        balances[sender] = balances[sender] - resultAmount;
        balances[_to] = balances[_to] + _amount;
        balances[staker] = balances[staker] + fee;
        lastUsedNonce[sender] = _nonce;

        emit Transfer(sender, _to, _amount);
        emit Transfer(sender, staker, fee);
        return true;
    }

    function withdrawOnBehalf(uint256 _amount, string memory _paySystem, uint256 _nonce, uint8 _v,
        bytes32 _r, bytes32 _s)
    public onlyModer whenNotPaused returns (bool success) {
        uint256 fee;
        uint256 resultAmount;
        bytes32 hash = keccak256(abi.encodePacked(address(0), _amount, _nonce, address(this)));
        address sender = ecrecover(hash, _v, _r, _s);

        _softRequire(lastUsedNonce[sender] < _nonce, 'Invalid nonce');

        fee = commissionList.calcWithdraw(_paySystem, _amount);

        _softRequire(_amount > fee, 'Fee is more than value');
        _softRequire(balances[sender] >= _amount, 'Insufficient funds');

        resultAmount = _amount - fee;

        balances[sender] = balances[sender] - _amount;
        balances[staker] = balances[staker] + fee;
        totalSupply_ = totalSupply_ - resultAmount;
        lastUsedNonce[sender] = _nonce;

        emit Burn(sender, resultAmount);
        emit Transfer(sender, address(0), resultAmount);
        emit Transfer(sender, staker, fee);
        return true;
    }

    function refill(address _to, uint256 _amount, string memory _paySystem)
    public onlyModer whenNotPaused returns (bool success) {
        uint256 fee;
        uint256 resultAmount;

        fee = commissionList.calcRefill(_paySystem, _amount);
        resultAmount = _amount.add(fee);

        balances[_to] = balances[_to] + _amount;
        balances[staker] = balances[staker] + fee;
        totalSupply_ = totalSupply_.add(resultAmount);

        emit Mint(_to, resultAmount);
        emit Transfer(address(0), _to, resultAmount);
        emit Transfer(_to, staker, fee);
        return true;
    }

    function changeStaker(address _staker) public onlyContractOwner returns(bool success) {
        address oldStaker = staker;
        staker = _staker;

        emit StakerChanged(oldStaker, staker);
        return true;
    }
}