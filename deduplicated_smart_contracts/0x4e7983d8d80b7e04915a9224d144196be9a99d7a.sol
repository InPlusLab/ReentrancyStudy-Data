/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

interface Oracle {
  function getTotalValueLockedInternalByToken(address tokenAddress, address tier2Address) external view returns (uint256);
  function getTotalValueLockedAggregated(uint256 optionIndex) external view returns (uint256);
  function getStakableTokens() view external  returns (address[] memory, string[] memory);
  function getAPY ( address tier2Address, address tokenAddress ) external view returns ( uint256 );
  function getAmountStakedByUser(address tokenAddress, address userAddress, address tier2Address) external view returns(uint256);
  function getUserCurrentReward(address userAddress, address tokenAddress, address tier2FarmAddress) view external returns(uint256);
  function getTokenPrice(address tokenAddress) view external returns(uint256);
  function getUserWalletBalance(address userAddress, address tokenAddress) external view returns (uint256);
}
interface Tier1Staking {
  function deposit ( string memory tier2ContractName, address tokenAddress, uint256 amount, address onBehalfOf ) external returns ( bool );
  function withdraw ( string memory tier2ContractName, address tokenAddress, uint256 amount, address onBehalfOf ) external returns ( bool );
}

interface Converter {
  function unwrap ( address sourceToken, address destinationToken, uint256 amount ) external returns ( uint256 );
  function wrap ( address sourceToken, address[] memory destinationTokens, uint256 amount ) external returns ( address, uint256 );
}
interface ERC20 {
    function totalSupply() external view returns(uint supply);

    function balanceOf(address _owner) external view returns(uint balance);

    function transfer(address _to, uint _value) external returns(bool success);

    function transferFrom(address _from, address _to, uint _value) external returns(bool success);

    function approve(address _spender, uint _value) external returns(bool success);

    function allowance(address _owner, address _spender) external view returns(uint remaining);

    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract Core{

    //globals
    address public oracleAddress;
    address public converterAddress;
    address public stakingAddress;
    Oracle oracle;
    Tier1Staking staking;
    Converter converter;
    address public ETH_TOKEN_PLACEHOLDER_ADDRESS  = address(0x0);
    address payable public owner;

    modifier onlyOwner {
           require(
               msg.sender == owner,
               "Only owner can call this function."
           );
           _;
   }

  constructor() public payable {
        owner= msg.sender;
        setStakingAddress(0x9704F876AB1835654583935Ab7e8067CCa27f9a4);
        setConverterAddress(0x1d17F9007282F9388bc9037688ADE4344b2cC49B);
  }

  fallback() external payable {
      //for the converter to unwrap ETH when delegate calling. The contract has to be able to accept ETH for this reason. The emergency withdrawal call is to pick any change up for these conversions.
  }

  function setOracleAddress(address theAddress) public onlyOwner returns(bool){
    oracleAddress = theAddress;
    oracle = Oracle(theAddress);
    return true;
  }

  function setStakingAddress(address theAddress) public onlyOwner returns(bool){
    stakingAddress = theAddress;
    staking = Tier1Staking(theAddress);
    return true;
  }
  function setConverterAddress(address theAddress) public onlyOwner returns(bool){
    converterAddress = theAddress;
    converter = Converter(theAddress);
    return true;
  }


  function changeOwner(address payable newOwner) onlyOwner public returns (bool){
    owner = newOwner;
    return true;
  }

   function deposit(string memory tier2ContractName, address tokenAddress, uint256 amount) payable public returns (bool){
       bool result = staking.deposit(tier2ContractName, tokenAddress, amount, msg.sender);
        return result;

   }

   function withdraw(string memory tier2ContractName, address tokenAddress, uint256 amount) payable public returns(bool){
      bool result = staking.withdraw(tier2ContractName, tokenAddress, amount, msg.sender);
        return result;
    }
    
    function convert(address sourceToken, address[] memory destinationTokens, uint256 amount) public payable returns(address, uint256){
        ( address destinationTokenAddress, uint256 _amount) = converter.wrap(sourceToken, destinationTokens, amount);
        ERC20 token = ERC20(destinationTokenAddress);
        token.transfer(msg.sender, _amount);
        return (destinationTokenAddress, _amount);
        
    }
    
    //deconverting is mostly for LP tokens back to another token, as these cant be simply swapped on uniswap
   function deconvert(address sourceToken, address destinationToken, uint256 amount) public payable returns(uint256){
       uint256 _amount = converter.unwrap(sourceToken, destinationToken, amount);
       ERC20 token = ERC20(destinationToken);
        token.transfer(msg.sender, _amount);
       return _amount;
    }

    function getStakableTokens() view public  returns (address[] memory, string[] memory){

        (address [] memory stakableAddresses, string [] memory stakableTokenNames) = oracle.getStakableTokens();
        return (stakableAddresses, stakableTokenNames);

    }
    
    

   function getAPY(address tier2Address, address tokenAddress) public view returns(uint256){

     uint256 result = oracle.getAPY(tier2Address, tokenAddress);
     return result;
   }

   function getTotalValueLockedAggregated(uint256 optionIndex) public view returns (uint256){
      uint256 result = oracle.getTotalValueLockedAggregated(optionIndex);
      return result;
   }

   function getTotalValueLockedInternalByToken(address tokenAddress, address tier2Address) public view returns (uint256){
      uint256 result = oracle.getTotalValueLockedInternalByToken( tokenAddress, tier2Address);
      return result;
   }

   function getAmountStakedByUser(address tokenAddress, address userAddress, address tier2Address) public view returns(uint256){
        uint256 result = oracle.getAmountStakedByUser(tokenAddress, userAddress,  tier2Address);
        return result;
   }

   function getUserCurrentReward(address userAddress, address tokenAddress, address tier2FarmAddress) view public returns(uint256){
        return oracle.getUserCurrentReward( userAddress,  tokenAddress, tier2FarmAddress);
   }

   function getTokenPrice(address tokenAddress) view public returns(uint256){
        uint256 result = oracle.getTokenPrice(tokenAddress);
        return result;
   }

    function getUserWalletBalance(address userAddress, address tokenAddress) public view returns (uint256){
        uint256 result = oracle.getUserWalletBalance( userAddress, tokenAddress);
        return result;

    }

    function adminEmergencyWithdrawAccidentallyDepositedTokens(address token, uint amount, address payable destination) public onlyOwner returns(bool) {

         if (address(token) == ETH_TOKEN_PLACEHOLDER_ADDRESS) {
             destination.transfer(amount);
         }
         else {
             ERC20 tokenToken = ERC20(token);
             require(tokenToken.transfer(destination, amount));
         }

         return true;
     }


}