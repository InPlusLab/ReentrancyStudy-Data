/**
 *Submitted for verification at Etherscan.io on 2019-06-29
*/

pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
  
}

contract SSTXCOIN {
    
    using SafeMath for uint256;

    string public name      = "Speed Shopper Token";                                    // Token name
    string public symbol    = "SSTX";                                                   // Token symbol
    uint256 public decimals = 18;                                                       // Token decimal points
    uint256 private _totalSupply = 500000000;                                           // Token total supply
    uint256 public totalSupply  = _totalSupply.mul(10 ** uint256(decimals));            // Token total supply with decimals
    
    
    // Balances for each account
    mapping (address => uint256) public balances;
    
    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) public allowance;


    // event to 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // contract constructor
    constructor() public {
        balances[0xa6052FB9334942A7e3B21c55f95af973B6b12918] = totalSupply;
    }
    
    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _value) public  returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        require(balances[_to].add(_value) >= balances[_to]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    // function to get the balance of a specific address
    function balanceOf(address _address) public view returns (uint256 balance) {
        // Return the balance for the specific address
        return balances[_address];
    }

    // Send `tokens` amount of tokens from address `from` to address `to`
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success) {
        require(_from != address(0) && _to != address(0));
        require(balances[_from] >= _value);
        require(balances[_to].add(_value) >= balances[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Allow `spender` to withdraw from your account, multiple times, up to the `tokens` amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) public  returns (bool success) {
        require(_spender != address(0));
        require(_value <= balances[msg.sender]);
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


}

contract SpeedShopper is SSTXCOIN {
    
    using SafeMath for uint256;
    
    // SSTXCOIN TokenAddress  = SSTXCOIN(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c);
    
    // variable to start and stop ico
    bool public stopped = false;
    uint public minEth  = 0.2 ether;

    // contract owner
    address public owner;
    
    // wallet address ethereum will going
    address public wallet;
    
    // number token we are going to provide in one ethereum
    uint256 public tokenPerEth = 2500;
    
    // struct to set ico stage detail
    struct icoData {
        uint256 icoStage;
        uint256 icoStartDate;
        uint256 icoEndDate;
        uint256 icoFund;
        uint256 icoBonus;
        uint256 icoSold;
    }
    
    // ico struct alias
    icoData public ico;


    // modifier to check sender is owner ot not
    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    // modifier to check ico is running ot not
    modifier isRunning {
        assert (!stopped);
        _;
    }

    // modifier to check ico is stopped ot not
    modifier isStopped {
        assert (stopped);
        _;
    }

    // modifier to check sender is valid or not
    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    // contract constructor
    constructor() public {
        
        wallet = 0xa6052FB9334942A7e3B21c55f95af973B6b12918;
        owner = 0xa6052FB9334942A7e3B21c55f95af973B6b12918;
    }
    
    function() payable public   {
        //revert if any ethereum  sent
        revert();
    }

    // payable to send tokens who is paying to the contract
    function participate() payable public isRunning validAddress  {
        
        // sender must send atleast 0.02 ETH
        require(msg.value > minEth);
        // check for ico is active or not
        require(now >= ico.icoStartDate && now <= ico.icoEndDate );

        // calculate the tokens amount
        uint tokens = msg.value * tokenPerEth;
        // calculate the bounus
        uint bonus  = ( tokens.mul(ico.icoBonus) ).div(100);
        // add the bonus tokens to actual token amount
        uint total  = tokens + bonus;

        // ico must have the fund to send
        require(ico.icoFund >= total);
        // contract must have the balance to send
        require(balanceOf(address(this)) >= total);
        
        // sender's new balance must be greate then old balance
        require(balanceOf(msg.sender).add(total) >= balanceOf(msg.sender));
        
        // update ico fund and sold token count
        ico.icoFund      = ico.icoFund.sub(total);
        ico.icoSold      = ico.icoSold.add(total);
        
        // send the tokens from contract to msg.sender
      
        transfer(msg.sender, total);
        
        // transfer ethereum to the withdrawal address
        wallet.transfer( msg.value );
        
    }
    
    // set new ico stage
    function setStage(uint256 _stage, uint256 _startDate, uint256 _endDate, uint256 _fund, uint256 _bonus) external isOwner returns(bool) {
        
        // current time must be greater then previous ico stage end time
        //require(now > ico.icoEndDate);
        // current stage must be greater then previous ico stage 
        //require(_stage > ico.icoStage);
        // current time must be less then start new ico time
        require(now < _startDate);
        // new ico start time must be less then new ico stage end date
        require(_startDate < _endDate);
        // owner must have fund to start the ico stage
        require(balanceOf(msg.sender) >= _fund);
        
        // calculate the token
        uint tokens = _fund;
        
        // set ico data
        ico.icoStage        = _stage;
        ico.icoStartDate    = _startDate;
        ico.icoEndDate      = _endDate;
        ico.icoFund         = tokens;
        ico.icoBonus        = _bonus;
        ico.icoSold         = 0;
        
        // transfer tokens to the contract
        //need to call allowance on the owner account approve(address ICO ADDRESS, uint256 _value)
        
        transferFrom(msg.sender, address(this), tokens);
        
        return true;
    }
    
    // set withdrawal wallet address
    function setWithdrawalWallet(address _newWallet) external isOwner {
        
        // new and old address should not be same
        require( _newWallet != wallet );
        // new balance is valid or not
        require( _newWallet != address(0) );
        
        // set new withdrawal wallet
        wallet = _newWallet;
        
    }

    // function to get back the token from contract to owner
    function withdrawTokens(address _address, uint256 _value) external isOwner validAddress {
        
        // check for valid address
        require(_address != address(0) && _address != address(this));
        
        // calculate the tokens
        uint256 tokens = _value * 10 ** uint256(18);
        
        // check contract have the sufficient balance
        require(balanceOf(address(this)) > tokens);
        
        // check for valid value of value params
        require(balanceOf(_address) < balanceOf(_address).add(tokens));
        
        // send the tokens
        transfer(_address, tokens);
        
    }
    
    // pause the ICO
    function pauseICO() external isOwner isRunning {
        stopped = true;
    }
    
    // resume the ICO
    function resumeICO() external isOwner isStopped {
        stopped = false;
    }
    
}