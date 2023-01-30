/**
 *Submitted for verification at Etherscan.io on 2019-10-09
*/

pragma solidity 0.5.12; 
/*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



 █████╗ ███████╗██╗   ██╗███╗   ███╗ █████╗      ██████╗ ██████╗ ██╗███╗   ██╗
██╔══██╗╚══███╔╝██║   ██║████╗ ████║██╔══██╗    ██╔════╝██╔═══██╗██║████╗  ██║
███████║  ███╔╝ ██║   ██║██╔████╔██║███████║    ██║     ██║   ██║██║██╔██╗ ██║
██╔══██║ ███╔╝  ██║   ██║██║╚██╔╝██║██╔══██║    ██║     ██║   ██║██║██║╚██╗██║
██║  ██║███████╗╚██████╔╝██║ ╚═╝ ██║██║  ██║    ╚██████╗╚██████╔╝██║██║ ╚████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
                                                                              


-------------------------------------------------------------------
 Copyright (c) 2019 onwards Azuma Coin Inc. ( https://Azumacoin.io )
 Contract designed with ❤ by EtherAuthority ( https://EtherAuthority.io )
-------------------------------------------------------------------
*/ 




//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//
/**
    * @title SafeMath
    * @dev Math operations with safety checks that throw on error
    */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address payable public owner;
    address payable private newOwner;

    /**
        Signer is deligated admin wallet, which can do sub-owner functions.
        Signer calls following four functions:
            => updateEthUsdPrice
    */
    address payable public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner {
        require(msg.sender == signer);
        _;
    }

    function changeSigner(address payable _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
 

interface tokenInterface
{
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
} 

 
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//

contract AzumaPrivateSale is owned {

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables for private sale
    using SafeMath for uint256;
    address public azumaContractAddress;            // main token address to run ICO on
   	uint256 public icoETHReceived;                  // how many ETH Received through ICO
   	uint256 public totalTokenSold;                  // how many tokens sold
	uint256 public minimumContribution = 10**16;    // Minimum amount to invest - 0.01 ETH (in 18 decimal format)
	uint256 public etherUsdPrice = 172000;          // 1 ETH = 172 USD on 07/11/2019
	uint256 public etherPriceLastUpdated = now;     // Timestamp when the price was last updated
	uint256 public tokenPriceUSD = 150;             // 1 Token = 0.15 USD


    //nothing happens in constructor
    constructor() public{ }    


    /**
        * Fallback function. It accepts incoming ETH and issue tokens
    */
    function () payable external {
        buyToken();
    }

    event buyTokenEvent (address sender,uint amount, uint tokenPaid);
    function buyToken() payable public returns(uint)
    {
        uint256 etherAmount = msg.value;
		
		//checking conditions
        require(etherAmount >= minimumContribution, "less then minimum contribution"); 
        
        //getting USD value of incoming ether based on set ETH/USD exchang rate
        //etherUsdValue is in WEI
        uint256 etherUsdValue = etherAmount * etherUsdPrice;
        
        //calculating tokens to issue
        uint256 tokenTotal = etherUsdValue  / tokenPriceUSD;

        //updating state variables
        icoETHReceived += etherAmount;
        totalTokenSold += tokenTotal;
        
        //sending tokens. This crowdsale contract must hold enough tokens.
        tokenInterface(azumaContractAddress).transfer(msg.sender, tokenTotal);
        
        
        //send ether to owner
        forwardETHToOwner();
        
        //logging event
        emit buyTokenEvent(msg.sender, etherAmount, tokenTotal);
        
        return tokenTotal;

    }
    
    // this function called by signer from oracle script. The pricing of ether is fetched from:
    // https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD
    // If any changes in that API, the above URL may change.
    function updateEthUsdPrice(uint256 usdPrice) public onlySigner returns(bool){
        
        etherUsdPrice = usdPrice;          
	    etherPriceLastUpdated = now;
	    
	    return true;
    }


	//Automatocally forwards ether from smart contract to owner address
	function forwardETHToOwner() internal {
		owner.transfer(msg.value); 
	}
	
	
	// exchange rate => 1 Token = how many USD in 3 decimals
    function changeTokenUsdPricing(uint256 _tokenPriceUSD) onlyOwner public returns (bool)
    {
        tokenPriceUSD = _tokenPriceUSD;
        return true;
    }



    function setMinimumContribution(uint256 _minimumContribution) onlyOwner public returns (bool)
    {
        minimumContribution = _minimumContribution;
        return true;
    }
    
    
    function updateAzumaContract(address _newAzumaContract) onlyOwner public returns (bool)
    {
        azumaContractAddress = _newAzumaContract;
        return true;
    }
    
	
	function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner returns(string memory){
        // no need for overflow checking as that will be done in transfer function
        tokenInterface(azumaContractAddress).transfer(msg.sender, tokenAmount);
        return "Tokens withdrawn to owner wallet";
    }

    function manualWithdrawEther() public onlyOwner returns(string memory){
        address(owner).transfer(address(this).balance);
        return "Ether withdrawn to owner wallet";
    }
    


}