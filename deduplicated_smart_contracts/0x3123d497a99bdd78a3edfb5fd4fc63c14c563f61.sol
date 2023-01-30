/**

 *Submitted for verification at Etherscan.io on 2018-11-21

*/



pragma solidity ^0.4.25;



interface tribe

{

	function activate (address _owner, address _wallets, uint256 _total_supply, uint256 _remains) external returns (bool changed);

}



contract extended

{

	enum	stage {prepare, private_sale, redemption, public_sale, complete}

	bool	private locker = false;

	

	modifier reentrancy {require (locker == false); locker = true; _; locker = false;}

	

	function is_contract (address _address) internal view returns (bool)

	{

		uint codeLength;

		

		if (_address == 0x0) return false;

		

		assembly {codeLength := extcodesize (_address)}

		

		if (codeLength > 0) return true;

		else return false;

	}

	

	function mmul (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		if (_a == 0) return 0;

		

		uint256 c = _a * _b;

		require (c / _a == _b);

		

		return c;

	}

	

	function mdiv (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		require (_b > 0);

		uint256 c = _a / _b;

		

		return c;

	}

	

	function msub (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		if (_b > _a) _b = 0;

		

		uint256 c = _a - _b;

		

		return c;

	}

	

	function madd (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		uint256 c = _a + _b;

		require (c >= _a);

		

		return c;

	}

}



contract purse is extended

{

	address	public owner = address (0);

	address public trust = address (0);

	

	mapping (address => wallet_t) private account;

	

	event AccountCreated (address AccountAddress);

	event AccountTokensBalanceUpdated (address AccountAddress, uint256 TokensAmount, uint256 TokensFreeze);

	event AccountDepositBalanceUpdated (address AccountAddress, uint256 DepositAmount, uint256 DepositFreeze);

	event AccountFlagsUpdated (address AccountAddress, uint256 Flags);

	event ContractOwnerChanged (address NewOwnerAddress);

	event AccountDiscountPercentUpdated (address AccountAddress, uint256 Percent);

	event AccountDiscountAmountUpdated (address AccountAddress, uint256 Amount);

	event EmergencySituation (address RecieverAddress, string Reason, address Initiator);

	

	constructor (address _trust) public

	{

		owner = msg.sender;

		

		account [address (this)].wallet = address (this);

		account [address (this)].tokens = value_t (0, 0);

		account [address (this)].deposit = value_t (0, 0);

		account [address (this)].discount = vdisc_t (0, 0);

		account [address (this)].flags = 3;

		

		trust = _trust;

	}

	

	function reset_owner (address _owner) public reentrancy returns (bool is_changed)

	{

		if (msg.sender != owner && (account [msg.sender].flags & 3) != 3) return false;

		if (_owner == address (0)) return false;

		if (_owner == owner) return true;

		

		owner = _owner;

		

		emit ContractOwnerChanged (_owner);

		

		return true;

	}

	

	function urgently (address _reciever, string _reason) public payable reentrancy

	{

	    if (address (this).balance > 0 && (msg.sender == owner || msg.sender == trust))

	    {

	        _reciever.transfer (address (this).balance);

	        

	        emit EmergencySituation (_reciever, _reason, msg.sender);

	    }

	}

	

	function access_allowed (address _wallet) public view returns (bool is_allowed)

	{

		if (_wallet != owner && (account [_wallet].flags & 3) != 3) return false;

		

		return true;

	}

	

	function total_deposited () public view returns (uint256 deposited)

	{

	    return address (this).balance;

	}

	

	function balance_of (address _wallet) public view returns (uint256 account_balance)

	{

		return account [_wallet].tokens.amount;

	}

	

	function available_balance_of (address _wallet) public view returns (uint256 available_balance)

	{

		return msub (account [_wallet].tokens.amount, account [_wallet].tokens.freeze);

	}

	

	function exists (address _wallet, bool _create) public returns (bool account_exists)

	{

		if (_wallet == address (0) || (account [_wallet].wallet != _wallet && _create == false)) return false;

		if (account [_wallet].wallet == _wallet) return true;

		

		if (msg.sender != owner && (account [msg.sender].flags & 3) != 3) return false;

		

		account [_wallet].wallet = _wallet;

		account [_wallet].tokens = value_t (0, 0);

		account [_wallet].deposit = value_t (0, 0);

		account [_wallet].discount = vdisc_t (0, 0);

		account [_wallet].flags = 1;

		

		emit AccountCreated (_wallet);

		

		return true;

	}

	

	function get_wallet_tokens (address _wallet) public view returns (uint256 tokens, uint256 freeze)

	{

		return (account [_wallet].tokens.amount, account [_wallet].tokens.freeze);

	}

	

	function set_wallet_tokens (address _wallet, uint256 _amount, uint256 _freeze) public reentrancy returns (bool success)

	{

		if (msg.sender != owner && (account [msg.sender].flags & 3) != 3) return false;

		if (_wallet == address (0) || account [_wallet].wallet != _wallet) return false;

		if (account [_wallet].tokens.amount == _amount && account [_wallet].tokens.freeze == _freeze) return true;

		

		account [_wallet].tokens.amount = _amount;

		

		if (_freeze <= account [_wallet].tokens.amount) account [_wallet].tokens.freeze = _freeze;

		else account [_wallet].tokens.freeze = account [_wallet].tokens.amount;

		

		emit AccountTokensBalanceUpdated (_wallet, account [_wallet].tokens.amount, account [_wallet].tokens.freeze);

		

		return true;

	}

	

	function get_wallet_deposit (address _wallet) public view returns (uint256 deposited, uint256 freeze)

	{

		return (account [_wallet].deposit.amount, account [_wallet].deposit.freeze);

	}

	

	function set_wallet_deposit (address _wallet, address _recipient, uint256 _amount, uint256 _freeze) public payable reentrancy returns (bool success)

	{

		if (msg.sender != owner && (account [msg.sender].flags & 3) != 3) revert ();

		if (_wallet == address (0) || account [_wallet].wallet != _wallet) revert ();

		if (account [_wallet].deposit.amount == _amount && account [_wallet].deposit.freeze == _freeze) return true;

		

		uint256 odds = 0;

		

		if (account [_wallet].deposit.amount > _amount)

		{

			odds = msub (account [_wallet].deposit.amount, _amount);

			

			if (address (this).balance < odds || _recipient == address (0)) revert ();

			

			_recipient.transfer (odds);

		}

		else

		{

			odds = msub (_amount, account [_wallet].deposit.amount);

			

			if (msg.value < odds) revert ();

			if (msg.value > odds) msg.sender.transfer (msub (msg.value, odds));

		}

		

		account [_wallet].deposit.amount = _amount;

		

		if (_freeze <= account [_wallet].deposit.amount) account [_wallet].deposit.freeze = _freeze;

		else account [_wallet].deposit.freeze = account [_wallet].deposit.amount;

		

		emit AccountDepositBalanceUpdated (_wallet, account [_wallet].deposit.amount, account [_wallet].deposit.freeze);

		

		return true;

	}

	

	function get_wallet_flags (address _wallet) public view returns (uint256 flags)

	{

		return account [_wallet].flags;

	}

	

	function set_wallet_flags (address _wallet, uint256 _flags) public reentrancy returns (bool success)

	{

		if (msg.sender != owner && (account [msg.sender].flags & 3) != 3) return false;

		if (_wallet == address (0) || account [_wallet].wallet != _wallet) return false;

		

		account [_wallet].flags = _flags;

		

		emit AccountFlagsUpdated (_wallet, _flags);

		

		return true;

	}

	

	function get_wallet_discount_percent (address _wallet) public view returns (uint256)

	{

		return account [_wallet].discount.percent;

	}

	

	function set_wallet_discount_percent (address _wallet, uint256 _percent) public reentrancy returns (bool)

	{

		if (msg.sender != owner && (account [msg.sender].flags & 3) != 3) return false;

		if (_wallet == address (0) || account [_wallet].wallet != _wallet || _percent > 10000) return false;

		

		account [_wallet].discount.percent = _percent;

		

		emit AccountDiscountPercentUpdated (_wallet, _percent);

		

		return true;

	}

	

	function get_wallet_discount_amount (address _wallet) public view returns (uint256)

	{

		return account [_wallet].discount.amount;

	}

	

	function set_wallet_discount_amount (address _wallet, uint256 _amount) public reentrancy returns (bool)

	{

		if (msg.sender != owner && (account [msg.sender].flags & 3) != 3) return false;

		if (_wallet == address (0) || account [_wallet].wallet != _wallet) return false;

		

		account [_wallet].discount.amount = _amount;

		

		emit AccountDiscountAmountUpdated (_wallet, _amount);

		

		return true;

	}

	

	function () public payable

	{

		require (msg.value > 0);

		

		account [address (this)].deposit.amount = madd (account [address (this)].deposit.amount, msg.value);

		

		emit AccountDepositBalanceUpdated (address (this), account [address (this)].deposit.amount, account [address (this)].deposit.freeze);

	}

	

	struct value_t

	{

		uint256	amount;

		uint256	freeze;

	}

	

	struct vdisc_t

	{

		uint256	percent;

		uint256	amount;

	}

	

	struct wallet_t

	{

		address	wallet;

		

		value_t	tokens;

		value_t	deposit;

		vdisc_t	discount;

		

		uint256	flags;

	}

}



contract cashbox is extended

{

	string	public name = "Corporate Integrated Ecosystems - CoinECO Inc.";

	string	public symbol = "CES";

	uint8	public decimals = 0;

	string	public version = "1.0";

	string	public description = "https://bitcointalk.org/index.php?topic=5064353";

	

	address	public owner = address (0);

	address	public author = address (0);

	

	purse	public wallets = purse (address (0));

	tribe	public company = tribe (address (0));

	

	bool	public redeemable = true;

	

	uint256	public limits = 224000000;

	uint256	public issued = 0;

	uint256	public supply = 0;

	

	uint256	public public_price = 41666666666666700;

	

	stage	public milestone = stage.private_sale;

	

	option_t [4] public option;

	

	uint256	public options_count = 4;

	

	mapping (address => buyer_t) public buyer;

	

	modifier owneronly {require (msg.sender == owner); _;}

	modifier allowonly {require (msg.sender == owner || msg.sender == author); _;}

	

	event PackageSold (uint256 OptionId, uint256 PackagesCount, uint256 TotalPrice, address Purchaser);

	event TokensRedeemed (uint256 OptionId, uint256 TokensCount, uint256 TokensRemains, address Purchaser);

	event TokensSold (uint256 TokensCount, uint256 TokensPrice, address Purchaser);

	event OptionStageChanged (stage CurrentStage);

	event OptionSaleComplete ();

	event DescriptionChanged (string DescriptionURL);

	event OwnerChanged (address NewOwnerAddress);

	event CompanyActivated (address CompanyAddress);

	event CompanyAddressUpdated (address CompanyAddress);

	event CompanyInfoUpdated (string TokenName, string TokenSymbol, uint8 TokenDecimals);

	event RedeemableStateChanged (bool Allowed);

	event TokenSaleLimitsUpdated (uint256 NewLimits);

	event TokenSalePublicPriceUpdated (uint256 TokenPublicSalePrice);

	event TokenSaleTimeoutUpdated (uint256 Stage, uint256 TimeoutValue);

	event OptionPackageUpdated (uint256 OptionIndex, uint256 OptionId, uint256 PackagesCount, uint256 TokensPerPackage, uint256 PackagePrice, uint256 PackageRedemptionPrice);

	

	constructor () public

	{

	    owner = msg.sender;

	    author = msg.sender;

	    

	    require (address (wallets = new purse (msg.sender)) != address (0) && is_contract (address (wallets)) == true);

	    

	    option [0] = option_t (0, 5600, 10000, 6510416666666670000, 26041666666666700000);

		option [1] = option_t (1, 56000, 1000, 1302083333333330000,  5208333333333330000);

		option [2] = option_t (2, 560000, 100,  260416666666667000,  1041666666666670000);

		option [3] = option_t (3, 5600000, 10,   52083333333333300,   208333333333333000);

	}

	

	function get_buyer_package_info (address _buyer, uint256 _index) public view returns (uint256 remains_tokens, uint256 price_per_token)

	{

	    return (buyer [_buyer].deals [_index].tokens, buyer [_buyer].deals [_index].price);

	}

	

	function package (uint256 _option_id) public payable reentrancy returns (bool success)

	{

	    if ((milestone == stage.private_sale || milestone == stage.redemption) && msg.value > 0 && issued < limits)

	    {

	        uint256 index = _option_id;

	        uint256 count = 0;

	        uint256 price = 0;

	        uint256 token = 0;

	        

	        if (_option_id > 3) index = 3;

	        

	        count = mdiv (msg.value, option [index].price);

	        

	        if (count == 0)

	        {

	            msg.sender.transfer (msg.value);

	            

	            return false;

	        }

	        

	        if (count > option [index].count) count = option [index].count;

	        

	        price = mmul (count, option [index].price);

	        token = mmul (count, option [index].package);

	        

	        if (buyer [msg.sender].wallet != msg.sender)

	        {

	            buyer [msg.sender].wallet = msg.sender;

	            buyer [msg.sender].deals.length = 4;

	        }

	        

	        buyer [msg.sender].deals [index].tokens = madd (buyer [msg.sender].deals [index].tokens, token);

	        buyer [msg.sender].deals [index].price = mdiv (option [index].redemption, option [index].package);

	        

	        issued = madd (issued, token);

	        

	        owner.transfer (price);

	        

	        option [index].count = msub (option [index].count, count);

	        

	        emit PackageSold (index, count, price, msg.sender);

	        

	        return true;

	    }

	    

	    revert ();

	}

	

	function redemption (uint256 _id) public payable reentrancy returns (bool success)

	{

	    if ((milestone == stage.redemption || redeemable == true) && msg.value > 0 && buyer [msg.sender].wallet == msg.sender && wallets.exists (msg.sender, true) == true)

	    {

	        uint256 index = _id;

	        uint256 limit = 0;

	        uint256 price = 0;

	        

	        if (index >= options_count) index = msub (options_count, 1);

	        

	        if (buyer [msg.sender].deals [index].tokens > 0)

	        {

	            limit = mdiv (msg.value, buyer [msg.sender].deals [index].price);

	            

	            if (limit > 0)

	            {

	                if (limit > buyer [msg.sender].deals [index].tokens) limit = buyer [msg.sender].deals [index].tokens;

	                

	                price = mmul (limit, buyer [msg.sender].deals [index].price);

	                

	                if (msg.value > price) msg.sender.transfer (msub (msg.value, price));

	                

	                //uint256 old = buyer [msg.sender].deals [index].tokens;

	                

	                buyer [msg.sender].deals [index].tokens = msub (buyer [msg.sender].deals [index].tokens, limit);

	                

	                supply = madd (supply, limit);

	                

    	            uint256 amount = 0;

    	            uint256 freeze = 0;

    	            

    	            (amount, freeze) = wallets.get_wallet_tokens (msg.sender);

    	            

    	            amount = madd (amount, limit);

    	            

    	            if (wallets.set_wallet_tokens (msg.sender, amount, freeze) == false) revert ();

	                

	                //emit TokensRedeemed (index, old, buyer [msg.sender].deals [index].tokens, msg.sender);

	                emit TokensRedeemed (index, limit, buyer [msg.sender].deals [index].tokens, msg.sender);

	                

	                return true;

	            }

	        }

	    }

	    

	    revert ();

	}

	

	function purchase () public payable reentrancy returns (bool success)

	{

	    if (milestone == stage.public_sale && msg.value > 0 && limits > supply && wallets.exists (msg.sender, true) == true)

	    {

	        uint256 limit = mdiv (msg.value, public_price);

	        uint256 token = msub (limits, supply);

	        uint256 price = 0;

	        

	        if (limit > 0)

	        {

	            if (limit > token) limit = token;

	            

	            price = mmul (limit, public_price);

	            

	            if (msg.value > price) msg.sender.transfer (msub (msg.value, price));

	            

	            supply = madd (supply, limit);

	            

	            uint256 amount = 0;

	            uint256 freeze = 0;

	            

	            (amount, freeze) = wallets.get_wallet_tokens (msg.sender);

	            

	            amount = madd (amount, limit);

	            

	            if (wallets.set_wallet_tokens (msg.sender, amount, freeze) == false) revert ();

	            

	            emit TokensSold (limit, price, msg.sender);

	            

	            return true;

	        }

	    }

	    

	    revert ();

	}

	

	function update_description_url (string _url) public

	{

	    if (msg.sender == owner || msg.sender == author)

	    {

	        description = _url;

	        

	        emit DescriptionChanged (_url);

	    }

	}

	

	function activate_company (address _company) public returns (bool activated)

	{

	    if (msg.sender == owner && _company != address (0) && is_contract (_company) == true && address (company) == address (0) && milestone == stage.complete)

	    {

	        company = tribe (_company);

			

			return run_activate_company ();

	    }

	    

	    return false;

	}

	

	function next_stage () public reentrancy returns (bool success)

	{

	    if (msg.sender == owner || msg.sender == author) return set_next_stage ();

	    else return false;

	}

	

	function run_activate_company () internal returns (bool)

	{

		if (address (company) != address (0) && company.activate (author, address (wallets), supply, msub (limits, supply)) == true && milestone == stage.complete)

		{

			if (wallets.reset_owner (address (company)) == false) revert ();



			emit CompanyActivated (address (company));



			return true;

		}

		

		return false;

	}

	

	function set_next_stage () internal returns (bool is_set)

	{

        if (milestone == stage.private_sale)

        {

            redeemable == true;

            milestone = stage.redemption;

            

            if (address (this).balance > 0) owner.transfer (address (this).balance);

        }

        else if (milestone == stage.redemption)

        {

            redeemable = false;

            milestone = stage.public_sale;

        }

        else if (milestone == stage.public_sale)

        {

            redeemable = false;

            milestone = stage.complete;

            

            if (address (this).balance > 0) address (wallets).transfer (address (this).balance);

            

            run_activate_company ();

            

            emit OptionSaleComplete ();

        }

        else return false;

        

        emit OptionStageChanged (milestone);

        emit RedeemableStateChanged (redeemable);

        

        return true;

    }

	

	struct option_t

	{

	    uint256 id;

	    

	    uint256 count;

	    uint256 package;

	    uint256 price;

	    uint256 redemption;

	}

	

	struct optinfo

	{

	    uint256 tokens;

	    uint256 price;

	}

	

	struct buyer_t

	{

	    address wallet;

	    

	    optinfo [] deals;

	}

}