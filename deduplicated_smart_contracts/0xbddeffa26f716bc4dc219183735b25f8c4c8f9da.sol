/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.25;



library SafeMath {

	function mul(uint256 a, uint256 b) internal pure returns (uint256)

	{

		uint256 c = a * b;

		assert(a == 0 || c / a == b);

		return c;

	}



	function div(uint256 a, uint256 b) internal pure returns (uint256)

	{

		uint256 c = a / b;

		return c;

	}



	function sub(uint256 a, uint256 b) internal pure returns (uint256)

	{

		assert(b <= a);

		return a - b;

	}



	function add(uint256 a, uint256 b) internal pure returns (uint256)

	{

		uint256 c = a + b;

		assert(c >= a);

		return c;

	}

}



interface TokenERC20 {

    function transfer(address receiver, uint amount) external;

}



contract AIOCrowdsale {

    using SafeMath for uint256;



    TokenERC20 public token;



    uint256 public rate;

    address public wallet;

    uint256 public deadline;

    uint256 public minPurchase;



    uint256 public amountRaised;



    event TokenPurchase(

        address indexed purchaser,

        address indexed beneficiary,

        uint256 value,

        uint256 amount

    );



    constructor(

        TokenERC20 _token,

        uint256 _rate,

        address _wallet,

        uint256 durationInDays,

        uint256 minPurchaseInEther

    )

        public

    {

        require(_token != address(0));

        require(_rate > 0);

        require(_wallet != address(0));



        token = _token;

        rate = _rate;

        wallet = _wallet;

        deadline = now + durationInDays.mul(1 days);

        minPurchase = minPurchaseInEther.mul(1 ether);

    }



    function () public payable {

		buyTokens(msg.sender);

	}



    function buyTokens(address beneficiary) public payable {

		require(beneficiary != 0x0);

		require(validPurchase());



		uint256 amount = msg.value;

		uint256 tokens = amount.mul(rate);

		amountRaised = amountRaised.add(amount);



		token.transfer(beneficiary, tokens);

		emit TokenPurchase(msg.sender, beneficiary, amount, tokens);



		forwardFunds();

	}



    function forwardFunds() internal {

		wallet.transfer(msg.value);

	}



    function validPurchase() internal constant returns (bool) {

		return !hasEnded() && (msg.value >= minPurchase);

	}



    function hasEnded() public constant returns (bool) {

		return now >= deadline;

	}

}