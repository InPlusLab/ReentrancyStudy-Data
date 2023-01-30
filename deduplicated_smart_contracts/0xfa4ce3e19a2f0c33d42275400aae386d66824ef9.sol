/**

 *Submitted for verification at Etherscan.io on 2019-04-25

*/



pragma solidity ^0.5.0;



interface tokenRecipient

{

	function receiveApproval (address _from, uint256 _value, address _token, bytes calldata _extraData) external;

}



library safemath

{

	function mul (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		if (_a == 0) return 0;



		uint256 c = _a * _b;

		require (c / _a == _b);



		return c;

	}



	function div (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		require (_b > 0);

		uint256 c = _a / _b;



		return c;

	}



	function sub (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		require (_b <= _a);

		uint256 c = _a - _b;



		return c;

	}



	function add (uint256 _a, uint256 _b) internal pure returns (uint256)

	{

		uint256 c = _a + _b;

		require (c >= _a);



		return c;

	}

}



contract wishcoin

{

	using safemath for uint;



	string	public name = "A Wish Coin";

	string	public symbol = "WISH";

	uint8	public decimals = 0;



	address	public owner = address (0);



	uint256	public price = 1 finney;

	uint256	public tokenPrice = 1 finney;

	uint256	public commission = 500;

	uint256 public minlimit = 1 szabo;

	uint256	public tokens_on_sale = 5000000000;



	uint256	public totalSupply = 0;

	uint256	public freeTokens = 2500000000;

	uint256	public tokensPerPrice = 100;



	wish_t	[] public wish;

	uint256	public count = 0;



	mapping (address => uint256) public balanceOf;

	mapping (address => mapping (address => uint256)) public allowance;



	bool	public active = true;

	bool	private blocked = false;



	modifier blockedby {require (blocked == false); blocked = true; _; blocked = false;}

	modifier owneronly {require (msg.sender == owner); _;}



	event DesireCreated (uint256 Index, address Desirous, string Description, uint256 Limit);

	event DesireDeleted (uint256 Index);

	event DesireModified (uint256 Index);

	event DesireSupported (uint256 Index, address Grantor, uint256 Value);



	event TokenSalePriceChanged (uint256 Price);

	event ActiveStateChanged (bool IsActive);



	event Transfer (address indexed From, address indexed To, uint256 Value);

	event Approval (address indexed Owner, address indexed Spender, uint256 Value);

	event Burn (address indexed From, uint256 Value);



	constructor () public

	{

		owner = msg.sender;



		wish.push (wish_t (address (0), "", "", 0, 0));



		count ++;

	}



	function changeOptions (uint256 price_value, uint256 commission_value, uint256 limits) public owneronly blockedby

	{

		if (price != price_value) price = price_value;

		if (commission != commission_value) commission = commission_value;

		if (minlimit != limits) minlimit = limits;

	}



	function changeTokenPrice (uint256 value) public owneronly blockedby

	{

		if (tokenPrice != value)

		{

			tokenPrice = value;



			emit TokenSalePriceChanged (value);

		}

	}



	function setActiveState (bool value) public owneronly blockedby

	{

		if (active != value)

		{

			active = value;



			emit ActiveStateChanged (value);

		}

	}



	function addDesire (string memory title, string memory description, uint256 limit) public payable blockedby

	{

		require (msg.value >= price && !is_contract (msg.sender) && active == true);



		if (limit > 0 && limit < minlimit) revert ();



		uint256 index = wish.push (wish_t (msg.sender, title, description, limit, 0)).sub (1);



		count ++;



		if (msg.value > price) address (uint160 (msg.sender)).transfer (msg.value.sub (price));



		address (uint160 (owner)).transfer (price);



		if (freeTokens > 0)

		{

			balanceOf [msg.sender] = balanceOf [msg.sender].add (tokensPerPrice);

			freeTokens = freeTokens.sub (tokensPerPrice);

			tokens_on_sale = tokens_on_sale.sub (tokensPerPrice);

			totalSupply = totalSupply.add (tokensPerPrice);



			emit Transfer (address (this), msg.sender, tokensPerPrice);

		}

		else if (tokens_on_sale > 0)

		{

			uint256 tokens = 0;



			if (tokenPrice > 0)

			{

			    tokens = price.div (tokenPrice);



			    if (tokens > tokens_on_sale) tokens = tokens_on_sale;



                if (tokens > 0)

                {

        			tokens_on_sale = tokens_on_sale.sub (tokens);

        			totalSupply = totalSupply.add (tokens);



        			emit Transfer (address (this), msg.sender, tokens);

                }

			}

		}



		emit DesireCreated (index, msg.sender, description, limit);

	}



	function deleteDesire (uint256 index) public blockedby

	{

		require (count > 0 && index < count && (wish [index].desirous == msg.sender || msg.sender == owner) && active == true);



		wish [index].desirous = address (0);



		emit DesireDeleted (index);

	}



	function modifyDesire (uint256 index, string memory title, string memory description, uint256 limit) public blockedby

	{

		require (count > 0 && index < count && (wish [index].desirous == msg.sender || msg.sender == owner) && active == true);



		wish [index].title = title;

		wish [index].description = description;

		wish [index].limit = limit;



		emit DesireModified (index);

	}



	function supportDesire (uint256 index) public payable blockedby

	{

		require (count > 0 && index < count && msg.value > 0 && wish [index].desirous != address (0) && active == true);



		if (wish [index].limit > 0 && wish [index].total >= wish [index].limit) revert ();



		uint256 amount = 0;

		uint256 commis = 0;

		uint256 retval = 0;



		if (wish [index].limit > 0) amount = wish [index].limit.sub (wish [index].total);

		else amount = msg.value;



		if (amount > msg.value) amount = msg.value;



		if (msg.value > amount) address (uint160 (msg.sender)).transfer (msg.value.sub (amount));



		commis = amount.mul (commission).div (10000);

		retval = amount.sub (commis);



		address (uint160 (owner)).transfer (commis);

		address (uint160 (wish [index].desirous)).transfer (retval);



		wish [index].total = wish [index].total.add (amount);



		uint256 tokens = 0;



		if (freeTokens > 0)

		{

		    if (price > 0) tokens = amount.div (price).mul (tokensPerPrice);

		    else tokens = tokensPerPrice;



		    if (tokens > freeTokens) tokens = freeTokens;



			balanceOf [msg.sender] = balanceOf [msg.sender].add (tokens);

			freeTokens = freeTokens.sub (tokens);

			tokens_on_sale = tokens_on_sale.sub (tokens);

			totalSupply = totalSupply.add (tokens);



			emit Transfer (address (this), msg.sender, tokens);

		}

		else if (tokens_on_sale > 0)

		{

			if (tokenPrice > 0)

			{

			    tokens = amount.div (tokenPrice).mul (tokenPrice);



    			if (tokens > tokens_on_sale) tokens = tokens_on_sale;



                if (tokens > 0)

                {

        			tokens_on_sale = tokens_on_sale.sub (tokens);

        			totalSupply = totalSupply.add (tokens);



        			emit Transfer (address (this), msg.sender, tokens);

                }

			}

		}



		emit DesireSupported (index, msg.sender, amount);

	}



	function transfer (address to, uint256 value) public blockedby returns (bool success)

	{

		transferring (msg.sender, to, value);

        return true;

    }



    function transferFrom (address from, address to, uint256 value) public blockedby returns (bool success)

    {

        require (value <= allowance [from][msg.sender]);



        allowance [from][msg.sender] = allowance [from][msg.sender].sub (value);

        transferring (from, to, value);



        return true;

    }



    function approve (address spender, uint256 value) public blockedby returns (bool success)

    {

	    require (active == true);



        allowance [msg.sender][spender] = value;



        emit Approval (msg.sender, spender, value);



        return true;

    }



    function approveAndCall (address spender, uint256 value, bytes memory extra) public blockedby returns (bool success)

    {

	    require (active == true);



        tokenRecipient spenders = tokenRecipient (spender);



        if (approve (spender, value))

        {

            spenders.receiveApproval (msg.sender, value, address (this), extra);



            return true;

        }



        return false;

    }



    function burn (uint256 value) public blockedby returns (bool success)

    {

	    require (active == true);



        require (balanceOf [msg.sender] >= value);



        balanceOf [msg.sender] = balanceOf [msg.sender].sub (value);

        totalSupply = totalSupply.sub (value);



        emit Burn (msg.sender, value);



        return true;

    }



    function burnFrom (address from, uint256 value) public blockedby returns (bool success)

    {

	    require (active == true);



        require (balanceOf [from] >= value && value <= allowance [from][msg.sender]);



        balanceOf [from] = balanceOf [from].sub (value);

        allowance [from][msg.sender] = allowance [from][msg.sender].sub (value);

        totalSupply = totalSupply.sub (value);



        emit Burn (from, value);



        return true;

    }



    function () external payable blockedby

    {

	    require (freeTokens == 0 && tokens_on_sale > 0 && msg.value >= tokenPrice && active == true);



	    uint256 tokens = msg.value.div (tokenPrice);

	    uint256 amount = tokens.mul (tokenPrice);



	    if (msg.value > amount) address (uint160 (msg.sender)).transfer (msg.value.sub (amount));



	    balanceOf [msg.sender] = balanceOf [msg.sender].add (tokens);

	    tokens_on_sale = tokens_on_sale.sub (tokens);

	    totalSupply = totalSupply.add (tokens);



	    address (uint160 (owner)).transfer (msg.value.sub (amount));



	    emit Transfer (address (this), msg.sender, tokens);

    }



	function transferring (address from, address to, uint value) internal

	{

        require (to != address (0x0) && balanceOf [from] >= value && balanceOf [to].add (value) >= balanceOf [to] && active == true);



        uint previousBalances = balanceOf [from].add (balanceOf [to]);



        balanceOf [from] = balanceOf [from].sub (value);

        balanceOf [to] = balanceOf [to].add (value);



        emit Transfer (from, to, value);



        assert (balanceOf [from].add (balanceOf [to]) == previousBalances);

    }



	function is_contract (address _address) internal view returns (bool)

	{

		uint codeLength;



		if (_address == address (0)) return false;



		assembly {codeLength := extcodesize (_address)}



		if (codeLength > 0) return true;

		else return false;

	}



	struct wish_t

	{

		address	desirous;

		string	title;

		string	description;

		uint256	limit;

		uint256	total;

	}

}