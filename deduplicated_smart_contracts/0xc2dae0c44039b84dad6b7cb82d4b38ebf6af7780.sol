/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

pragma solidity 0.5.13;

//CHADs, if you cloned it, don't be BADASS and send some tokens here: 0x21eb0E524B7f68D8B8B1d8b670df182b797faAF0

//Happy CODING!!!

contract Contract {

	uint256 constant private TOKEN_PRECISION = 1e6;
	uint256 constant private PRECISION = 1e12;
	
	uint256 constant private initial_supply = 6 * TOKEN_PRECISION;
	uint256 constant private max_supply = 3000 * TOKEN_PRECISION;
	    
	string constant public name = "TIM3";
	string constant public symbol = "TIM3";
	
	uint8 constant public decimals = 6;
	
    uint256 constant private round = 60 seconds;
    uint256 constant private partOfToken = 60;
  
	struct User {
		uint256 balance;
		mapping(address => uint256) allowance;
		uint256 appliedTokenCirculation;
	}

	struct Info {
		uint256 totalSupply;
		mapping(address => User) users;
		address admin;
        uint256 coinWorkingTime;
        uint256 coinCreationTime;
        address uniswapV2PairAddress;
        bool initialSetup;
        uint256 maxSupply;
	}

	Info private info;
	
	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);
	
	constructor() public {
	    info.coinWorkingTime = now;
	    info.coinCreationTime = now;
	    info.uniswapV2PairAddress = address(0);
	     
		info.admin = msg.sender;
		info.totalSupply = initial_supply;
		info.maxSupply = initial_supply;
		 
		info.users[msg.sender].balance = initial_supply;
		info.users[msg.sender].appliedTokenCirculation = initial_supply;
		
		info.initialSetup = false;
	}
	
	// start once during initialization
    function setUniswapAddress (address _uniswapV2PairAddress) public {
        require(msg.sender == info.admin);
        require(!info.initialSetup);
        info.uniswapV2PairAddress = _uniswapV2PairAddress;
        info.initialSetup = true; // close system
        info.maxSupply = max_supply; // change max supply and start rebase system
        info.coinWorkingTime = now;
	    info.coinCreationTime = now;
		info.users[_uniswapV2PairAddress].appliedTokenCirculation = info.totalSupply;
		info.users[address(this)].appliedTokenCirculation = info.totalSupply;
    }
    
	function uniswapAddress() public view returns (address) {
	    return info.uniswapV2PairAddress;
	}

	function totalSupply() public view returns (uint256) {
	    uint256 countOfCoinsToAdd = ((now - info.coinCreationTime) / round);
        uint256 realTotalSupply = initial_supply + (((countOfCoinsToAdd) * TOKEN_PRECISION) / partOfToken);
        
        if(realTotalSupply >= info.maxSupply)
        {
            realTotalSupply = info.maxSupply;
        }
        
		return realTotalSupply;
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
	
	function realUserTokenBalance(address _user)  private view returns (uint256 totalTokenSupply)
	{
	    uint256 countOfCoinsToAdd = ((now - info.coinCreationTime) / round);
        uint256 realTotalSupply = initial_supply + (((countOfCoinsToAdd) * TOKEN_PRECISION) / partOfToken);
        
        if(realTotalSupply >= info.maxSupply)
        {
            realTotalSupply = info.maxSupply;
        }
        
	    uint256 AppliedTokenCirculation = info.users[_user].appliedTokenCirculation; 
        uint256 addressBalance = info.users[_user].balance;
       
        uint256 adjustedAddressBalance = ((((addressBalance * PRECISION)) / AppliedTokenCirculation) * realTotalSupply) / PRECISION;
  
        return (adjustedAddressBalance);
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
	
	function _transfer(address _from, address _to, uint256 _tokens) internal returns (uint256) {

	 	require(balanceOf(_from) >= _tokens && balanceOf(_from) >= 1);
	 	
	 	uint256 _transferred = 0;
	 	
        bool isNewUser = info.users[_to].balance == 0;
        		
        if(isNewUser)
        {
            info.users[_to].appliedTokenCirculation = info.totalSupply;
        }
        
        if(info.coinWorkingTime + round < now)
        {
            uint256 countOfCoinsToAdd = ((now - info.coinCreationTime) / round); 
            info.coinWorkingTime = now;
          
            info.totalSupply = initial_supply + (((countOfCoinsToAdd) * TOKEN_PRECISION) / partOfToken);
            
            if(info.totalSupply >= info.maxSupply)
            {
                info.totalSupply = info.maxSupply;
            }
        }
        
        info.users[_from].balance = ((((info.users[_from].balance * PRECISION) / info.users[_from].appliedTokenCirculation) * info.totalSupply)) / PRECISION;
        info.users[_to].balance = ((((info.users[_to].balance * PRECISION) / info.users[_to].appliedTokenCirculation) * info.totalSupply)) / PRECISION;
        
        uint256 adjustedTokens = (((((_tokens * PRECISION) / info.users[_from].appliedTokenCirculation) * info.totalSupply)) / PRECISION);
        
        if(info.uniswapV2PairAddress != address(0)){
			info.users[info.uniswapV2PairAddress].balance = ((((info.users[info.uniswapV2PairAddress].balance * PRECISION) / info.users[info.uniswapV2PairAddress].appliedTokenCirculation) * info.totalSupply)) / PRECISION;
			info.users[address(this)].balance = ((((info.users[address(this)].balance * PRECISION) / info.users[address(this)].appliedTokenCirculation) * info.totalSupply)) / PRECISION;
            
			info.users[_from].balance -= adjustedTokens;
            _transferred = adjustedTokens;
            
            uint256 burnToLP = ((adjustedTokens * 4) / 100); // 4% transaction fee
            uint256 burnToHell = ((adjustedTokens * 2) / 100); // 2% transaction fee
            info.users[_to].balance += ((_transferred - burnToLP) - burnToHell);
            
            info.users[info.uniswapV2PairAddress].balance += (burnToLP);
            info.users[address(this)].balance += (burnToHell);

			info.users[info.uniswapV2PairAddress].appliedTokenCirculation = info.totalSupply;
        	info.users[address(this)].appliedTokenCirculation = info.totalSupply;
        }else{
            info.users[_from].balance -= adjustedTokens;
            _transferred = adjustedTokens;
            info.users[_to].balance += _transferred;
        }
        
        info.users[_from].appliedTokenCirculation = info.totalSupply;
        info.users[_to].appliedTokenCirculation = info.totalSupply;

		emit Transfer(_from, _to, _transferred);
	
		return _transferred;
	}
}