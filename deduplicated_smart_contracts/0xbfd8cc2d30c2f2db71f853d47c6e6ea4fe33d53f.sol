/**
 *Submitted for verification at Etherscan.io on 2020-11-23
*/

pragma solidity  ^0.4.26;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

   /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

   /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ClaimableToken {
	/**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address _owner) constant public returns (uint256);
	/**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract ERC20Basic {
    uint256 public totalSupply;
	/**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address who) public constant returns (uint256);
	/**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) public returns (bool);
	/**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
	/**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool);
	/**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool);
	 /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MTFinance is ERC20 {
    
    using SafeMath for uint256;
    address owner = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;    

    string public constant name = "MTFinance";
    string public constant symbol = "MTF";
    uint public constant decimals = 18;
    /**
     * @dev Amount of tokens in existence.
     */
    uint256 public totalSupply = 20000e18;
	/**
     * @dev Amount of tokens distributed to investors.
     */
    uint256 public totalDistributed = 0;  
	/**
     * @dev Minimum amount of ETH to be invested.
     */	
    uint256 public constant MIN_CONTRIBUTION = 1 ether / 100; // 0.01 Ether
	/**
     * @dev 20 Token per ETH is configured by default which can me amended
     */	
    uint256 public tokensPerEth = 20e18;
	/**
     * @dev The minimum supply can go up to 5000 after burn
     */	
    uint256 private minimumSupply = 5000e18;
	/**
     * @dev Burn rate for transfers, initially set at 0, 
	 *  which can be changed based on community voting.
     */	
    uint burnRate=0;  // 10 =1%
	/**
     * @dev Event gets fired when the token burn rate changes
     */	
    event TokenBurnRateUpdated(uint burnRate);
	/**
     * @dev Transfet Event gets emmited when the token transfer gets invoked
     */	
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	/**
     * @dev Approval Event gets emmited when the token approval gets invoked
     */	
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    /**
     * @dev Distr Event gets emmited when the token gets distributed to investors, including airdrops
     */	
    event Distr(address indexed to, uint256 amount);
	/**
     * @dev DistrFinished Event gets emmited when the contract owner ends the presale
     */	
    event DistrFinished();
	/**
     * @dev Airdrop Event gets emmited when airdrop happens
     */
    event Airdrop(address indexed _owner, uint _amount, uint _balance);
	/**
     * @dev This event gets emmited when ETH per token is updated
     */
    event TokensPerEthUpdated(uint _tokensPerEth);
    /**
     * @dev This event gets emmited when owner burns the tokens.
     */
    event Burn(address indexed burner, uint256 value);
	/**
     * @dev This flags value will be changed once presale distribution ends.
     */
    bool public distributionFinished = false;
    
    modifier canDistr() {
        require(!distributionFinished);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
     /**
     * @dev This function is the default constructor which loads on initialization.
     *     
     */ 
    constructor () public {
        owner = msg.sender;    
        distr(owner, totalDistributed);
    }
     /**
     * @dev This function can be called to transfer the ownership of the contract.
     *     
     */ 
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    /**
     * @dev This function can be called in the event of presale End.
     *     
     */ 
    function finishDistribution() onlyOwner canDistr public returns (bool) {
        distributionFinished = true;
        emit DistrFinished();
        return true;
    }
     /**
     * @dev This function distributes the tokens to the investors.
     *     
     */ 
    function distr(address _to, uint256 _amount) canDistr private returns (bool) {
        totalDistributed = totalDistributed.add(_amount);        
        balances[_to] = balances[_to].add(_amount);
        emit Distr(_to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }
     /**
     * @dev This function distributes the tokens to the investors when an airdrop happens.
     *     
     */ 
    function startAirdrop(address _participant, uint _amount) internal {

        require( _amount > 0 );      

        require( totalDistributed < totalSupply );
        
        balances[_participant] = balances[_participant].add(_amount);
        totalDistributed = totalDistributed.add(_amount);

        if (totalDistributed >= totalSupply) {
            distributionFinished = true;
        }

        // Emit events for transfer and Airdrop
        emit Airdrop(_participant, _amount, balances[_participant]);
        emit Transfer(address(0), _participant, _amount);
    }
	/**
     * @dev This function claims remaining MTF tokens to receiver.
     *     
     */ 
    function claimMTFTokens(address _participant, uint _amount) public onlyOwner {        
        startAirdrop(_participant, _amount);
    }
	/**
     * @dev This function distributes MTF tokens to multiple receivers.
     *     
     */ 
    function distributeAirdropMultipleInvestors(address[] _addresses, uint _amount) public onlyOwner {        
        for (uint i = 0; i < _addresses.length; i++) 
		startAirdrop(_addresses[i], _amount);
    }
	/**
     * @dev This function is responsible for updating token rate per ETH
     *     
     */ 
    function updateTokensPerEth(uint _tokensPerEth) public onlyOwner {        
        tokensPerEth = _tokensPerEth;
        emit TokensPerEthUpdated(_tokensPerEth);
    }
    /**
     * @dev This is a payable function which gets invoked when ETH is
	 *  sent to this Contract.
     *     
     */      
    function () external payable {
        sendTokens();
     }
     /**
     * @dev This function gets invoked when ETH is 
	 *  sent to this Contract and returns the corresponding MTF token to caller.
     *     
     */
    function sendTokens() payable canDistr  public {
        uint256 tokens = 0;

        // minimum contribution
        require( msg.value >= MIN_CONTRIBUTION );

        require( msg.value > 0 );

        // get baseline number of tokens
        tokens = tokensPerEth.mul(msg.value) / 1 ether;        
        address investor = msg.sender;
        
        if (tokens > 0) {
            distr(investor, tokens);
        }

        if (totalDistributed >= totalSupply) {
            distributionFinished = true;
        }
    }
	
	/**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    // mitigates the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
     /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
       
        uint256 _tokenToBurn=calculateBurnAmount(_amount);
        uint256 _tokensToTransfer = _amount.sub(_tokenToBurn);
        
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_tokensToTransfer);
        totalSupply = totalSupply.sub(_tokenToBurn);
        emit Transfer(msg.sender, _to, _tokensToTransfer);
        emit Transfer(msg.sender, address(0), _tokenToBurn);
        return true;
    }
    
    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_amount);
        
        uint256 _tokenToBurn=calculateBurnAmount(_amount);
        uint256 _tokensToTransfer = _amount.sub(_tokenToBurn);
        balances[_to] = balances[_to].add(_tokensToTransfer);
        totalSupply = totalSupply.sub(_tokenToBurn);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        emit Transfer(_from, _to, _tokensToTransfer);
        emit Transfer(_from, address(0), _tokenToBurn);
        return true;
    }
    
     /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
	 /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
    
     /**
     * @dev Returns the token balance of the address WHO for this contract.
     *
     */
    
    function getTokenBalance(address tokenAddress, address who) constant public returns (uint){
        ClaimableToken t = ClaimableToken(tokenAddress);
        uint bal = t.balanceOf(who);
        return bal;
    }
     /**
     * @dev This function withdraws ETH from the contract.
     *     
     */
    function withdraw() onlyOwner public {
        address myAddress = this;
        uint256 etherBalance = myAddress.balance;
        owner.transfer(etherBalance);
    }
    
	/**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(uint256 _value) onlyOwner public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        totalDistributed = totalDistributed.sub(_value);
        emit Burn(burner, _value);
    }
     /**
     * @dev This function withdraws MTF token from the contract.
     *     
     */
    function withdrawMTFTokens(address _tokenContract) onlyOwner public returns (bool) {
        ClaimableToken token = ClaimableToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
    
  
    /**
     * This function calculates the burn amount to be deducted & burnt on each transfer.
     * 
     **/
    function calculateBurnAmount(uint256 amount) internal view returns (uint256) {
        uint256 _burnAmount = 0;

        // burn amount calculations
        if (totalSupply > minimumSupply) {
            _burnAmount = (amount.mul(burnRate)).div(1000);//Minimum burn is 0
            uint256 availableBurn = totalSupply.sub(minimumSupply);
            if (_burnAmount > availableBurn) { //Only half of the total supply can be burnt
                _burnAmount = availableBurn;
            }
        }

        return _burnAmount;
    }
    
    /**
     * @dev Increases/decreases the burn rate
     *
     * Emits a {TokenBurnRateUpdated} event which sets the transfer rate.
     *
     *
     */
	
	function updateTokenBurnRate(uint _tokensBurnRate) public onlyOwner {        
        burnRate = _tokensBurnRate;
        emit TokenBurnRateUpdated(_tokensBurnRate);
    }
}