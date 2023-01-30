/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

pragma solidity 0.5.13;

//EXPERIMENTAL PROJECT BETA

//DONT INVEST MONEY YOU CANNOT LOSE ANYTIME ANYTOKEN!

interface IUniswapV2Pair {
    function sync() external;
}

contract FreakCoin {

	uint256 constant private TOKEN_PRECISION = 1e6;
	uint256 constant private PRECISION = 1e12;
	
	uint256 constant private initial_supply = 1 * TOKEN_PRECISION;
	uint256 constant private final_supply = 1000000 * TOKEN_PRECISION;
	    
	string constant public name = "Freak";
	string constant public symbol = "FREAK";
	
	uint8 constant public decimals = 6;
  
	struct User {
		uint256 balance;
		mapping(address => uint256) allowance;
		uint256 appliedTokenCirculation;
	}

	struct Info {
		uint256 totalSupply;
		mapping(address => User) users;
		address admin;
        address uniswapV2PairAddress;
        bool initialSetup;
        uint256 final_supply;
	}

	Info private info;
	
	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	
	constructor() public {
	    info.uniswapV2PairAddress = address(0);
	     
		info.admin = msg.sender;
		info.totalSupply = initial_supply;
		info.final_supply = final_supply;
		 
		info.users[msg.sender].balance = initial_supply;
		info.users[msg.sender].appliedTokenCirculation = initial_supply;
		
		info.users[address(this)].appliedTokenCirculation = initial_supply;
		
		info.initialSetup = false;
	}
	
    function setUniswapAddress (address _uniswapV2PairAddress) public {
        require(msg.sender == info.admin);
        require(!info.initialSetup);
        info.uniswapV2PairAddress = _uniswapV2PairAddress;
        info.initialSetup = true;
        info.users[_uniswapV2PairAddress].appliedTokenCirculation = info.totalSupply;
		info.users[address(this)].appliedTokenCirculation = info.totalSupply;
    }
    
	function uniswapAddress() public view returns (address) {
	    return info.uniswapV2PairAddress;
	}
	
	function balanceOfTokenCirculation(address _user) private view returns (uint256) {
		return info.users[_user].appliedTokenCirculation;
	}

	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}

	function allUserBalances(address _user) public view returns (uint256 totalTokenSupply, uint256 userTokenCirculation, uint256 userBalance, uint256 realUserBalance) {
		return (totalSupply(), balanceOfTokenCirculation(_user), balanceOf(_user), realUserTokenBalance(_user));
	}
	
	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}
	
	function transfer(address _to, uint256 _tokens) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		require(info.users[_from].allowance[msg.sender] >= _tokens);
		info.users[_from].allowance[msg.sender] -= _tokens;
		_transfer(_from, _to, _tokens);
		return true;
	}
	
	function realUserTokenBalance(address _user)  private view returns (uint256 totalTokenSupply)
	{
        uint256 realTotalSupply = info.totalSupply;
        
	    uint256 AppliedTokenCirculation = info.users[_user].appliedTokenCirculation; 
        uint256 addressBalance = info.users[_user].balance;
       
        uint256 adjustedAddressBalance = ((((addressBalance * PRECISION)) / AppliedTokenCirculation) * realTotalSupply) / PRECISION;
  
        return (adjustedAddressBalance);
	}
	
	function totalSupply() public view returns (uint256) {
		return info.totalSupply;
	}
	
	function _transfer(address _from, address _to, uint256 _tokens) internal returns (uint256) {

	 	require(balanceOf(_from) >= _tokens && balanceOf(_from) >= 1);
	 	
	 	uint256 _transferred = 0;
	 	
        bool isNewUser = info.users[_to].balance == 0;
        		
        if(isNewUser)
        {
            info.users[_to].appliedTokenCirculation = info.totalSupply;
        }
        
        if(info.totalSupply < info.final_supply)
        {
             info.totalSupply = info.totalSupply + _tokens;
        }

		uint256 fromAppliedTokenCirculation = info.users[_from].appliedTokenCirculation; 
		
        uint256 addressBalanceFrom = info.users[_from].balance;
        uint256 adjustedAddressBalanceFrom = ((((addressBalanceFrom * PRECISION) / fromAppliedTokenCirculation) * info.totalSupply)) / PRECISION;
        
        info.users[_from].balance = adjustedAddressBalanceFrom;
        info.users[_from].appliedTokenCirculation = info.totalSupply;
        

        uint256 addressBalanceTo = info.users[_to].balance;
        uint256 adjustedAddressBalanceTo = ((((addressBalanceTo * PRECISION) / info.users[_to].appliedTokenCirculation) * info.totalSupply)) / PRECISION;
                 
		info.users[_to].balance = adjustedAddressBalanceTo;
		info.users[_to].appliedTokenCirculation = info.totalSupply;
		
		if(info.uniswapV2PairAddress != address(0)){
            uint256 addressBalanceUniswap = info.users[info.uniswapV2PairAddress].balance;
            uint256 adjustedAddressBalanceUniswap = ((((addressBalanceUniswap * PRECISION) / info.users[info.uniswapV2PairAddress].appliedTokenCirculation) * info.totalSupply)) / PRECISION;
                     
    		info.users[info.uniswapV2PairAddress].balance = adjustedAddressBalanceUniswap;
    		info.users[info.uniswapV2PairAddress].appliedTokenCirculation = info.totalSupply;
    		
            uint256 addressBalanceContract = info.users[address(this)].balance;
            uint256 adjustedAddressBalanceContract = ((((addressBalanceContract * PRECISION) / info.users[address(this)].appliedTokenCirculation) * info.totalSupply)) / PRECISION;
                     
    		info.users[address(this)].balance = adjustedAddressBalanceContract;
    		info.users[address(this)].appliedTokenCirculation = info.totalSupply;
		}

        uint256 adjustedTokens = (((((_tokens * PRECISION) / fromAppliedTokenCirculation) * info.totalSupply)) / PRECISION);
    	
    	if(info.uniswapV2PairAddress != address(0)){
			info.users[_from].balance -= adjustedTokens;
            _transferred = adjustedTokens;
            
            uint256 burnToHell = ((adjustedTokens * 10) / 100);
        
            info.users[_to].balance += (_transferred - burnToHell);
            info.users[address(this)].balance += (burnToHell);
        }else{
    	    info.users[_from].balance -= adjustedTokens;
    		_transferred = adjustedTokens;
    		info.users[_to].balance += _transferred;
        }
        
       if(info.uniswapV2PairAddress != address(0) && info.uniswapV2PairAddress != _from && info.uniswapV2PairAddress != _to){
            IUniswapV2Pair(info.uniswapV2PairAddress).sync();
        }
        
        emit Transfer(_from, _to, _transferred);
	
		return _transferred;
	}
}