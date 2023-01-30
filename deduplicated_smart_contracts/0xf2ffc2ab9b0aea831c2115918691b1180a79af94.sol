pragma solidity ^0.4.21;

contract ProofOfStableClone {
    using SafeMath for uint256;

    event Deposit(address user, uint amount);
    event Withdraw(address user, uint amount);
    event Claim(address user, uint dividends);
    event Reinvest(address user, uint dividends);

    bool gameStarted;

    uint constant depositTaxDivisor = 4;
    uint constant withdrawalTaxDivisor = 11;

    mapping(address => uint) public investment;
    mapping(bytes32 => bool) public administrators;

    mapping(address => uint) public stake;
    uint public totalStake;
    uint stakeValue;

    mapping(address => uint) dividendCredit;
    mapping(address => uint) dividendDebit;

    function ProofOfStableClone() public {
        administrators[0x57c3715aa156394ff48706c09792523c63653d2a90bd4b8c36ba1a99bfbd5a43] = true;
    }

    modifier onlyAdmin(){
        address _customerAddress = msg.sender;
        require(administrators[keccak256(_customerAddress)]);
        _;
    }

    function startGame() public onlyAdmin {
        gameStarted = true;
    }

    function depositHelper(uint _amount) private {
        uint _tax = _amount.div(depositTaxDivisor);
        uint _amountAfterTax = _amount.sub(_tax);
        if (totalStake > 0)
            stakeValue = stakeValue.add(_tax.div(totalStake));
        uint _stakeIncrement = sqrt(totalStake.mul(totalStake).add(_amountAfterTax)).sub(totalStake);
        investment[msg.sender] = investment[msg.sender].add(_amountAfterTax);
        stake[msg.sender] = stake[msg.sender].add(_stakeIncrement);
        totalStake = totalStake.add(_stakeIncrement);
        dividendDebit[msg.sender] = dividendDebit[msg.sender].add(_stakeIncrement.mul(stakeValue));
    }

    function deposit() public payable {
        require(gameStarted);
        depositHelper(msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public {
        require(_amount > 0);
        require(_amount <= investment[msg.sender]);
        uint _tax = _amount.div(withdrawalTaxDivisor);
        uint _amountAfterTax = _amount.sub(_tax);
        uint _stakeDecrement = stake[msg.sender].mul(_amount).div(investment[msg.sender]);
        uint _dividendCredit = _stakeDecrement.mul(stakeValue);
        investment[msg.sender] = investment[msg.sender].sub(_amount);
        stake[msg.sender] = stake[msg.sender].sub(_stakeDecrement);
        totalStake = totalStake.sub(_stakeDecrement);
        if (totalStake > 0)
            stakeValue = stakeValue.add(_tax.div(totalStake));
        dividendCredit[msg.sender] = dividendCredit[msg.sender].add(_dividendCredit);
        uint _creditDebitCancellation = min(dividendCredit[msg.sender], dividendDebit[msg.sender]);
        dividendCredit[msg.sender] = dividendCredit[msg.sender].sub(_creditDebitCancellation);
        dividendDebit[msg.sender] = dividendDebit[msg.sender].sub(_creditDebitCancellation);
        msg.sender.transfer(_amountAfterTax);
        emit Withdraw(msg.sender, _amount);
    }

    function claimHelper() private returns(uint) {
        uint _dividendsForStake = stake[msg.sender].mul(stakeValue);
        uint _dividends = _dividendsForStake.add(dividendCredit[msg.sender]).sub(dividendDebit[msg.sender]);
        dividendCredit[msg.sender] = 0;
        dividendDebit[msg.sender] = _dividendsForStake;
        return _dividends;
    }

    function claim() public {
        uint _dividends = claimHelper();
        msg.sender.transfer(_dividends);
        emit Claim(msg.sender, _dividends);
    }

    function reinvest() public {
        uint _dividends = claimHelper();
        depositHelper(_dividends);
        emit Reinvest(msg.sender, _dividends);
    }

    function dividendsForUser(address _user) public view returns (uint) {
        return stake[_user].mul(stakeValue).add(dividendCredit[_user]).sub(dividendDebit[_user]);
    }

    function min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
        // uint256 c = a / b;                                                                                                                                                                               
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold                                                                                                                       
        return a / b;                                                                                                                                                                                       
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