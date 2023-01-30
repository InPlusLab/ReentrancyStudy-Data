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

interface ERC20Simple {
    function balanceOf(address _owner) external view returns(uint balance);
    function transfer(address _to, uint _value) external returns(bool success);
}

contract Core{

    //globals
    address public oracleAddress;
    address public converterAddress;
    address public stakingAddress;
    Oracle oracle;
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
    return true;
  }
  function setConverterAddress(address theAddress) public onlyOwner returns(bool){
    converterAddress = theAddress;
    return true;
  }


  function changeOwner(address payable newOwner) onlyOwner public returns (bool){
    owner = newOwner;
    return true;
  }

   function deposit(string memory tier2ContractName, address tokenAddress, uint256 amount) payable public returns (bool){
       (bool succeeded, bytes memory result) = address(stakingAddress).delegatecall(abi.encodeWithSignature("deposit(string,address,uint256)", tier2ContractName, tokenAddress,amount));
       return succeeded;

   }

   function withdraw(string memory tier2ContractName, address tokenAddress, uint256 amount) payable public returns(bool){
       (bool succeeded, bytes memory result) = address(stakingAddress).delegatecall(abi.encodeWithSignature("withdraw(string,address,uint256)", tier2ContractName, tokenAddress,amount));
       return succeeded;
    }
    
    function convert(address sourceToken, address[] memory destinationTokens, uint256 amount) public payable returns(bool){
        (bool succeeded, bytes memory result) = address(converterAddress).delegatecall(abi.encodeWithSignature("wrap(address,address[],uint256)", sourceToken, destinationTokens,amount));
       return succeeded;
    }
    
    //deconverting is mostly for LP tokens back to another token, as these cant be simply swapped on uniswap
   function deconvert(address sourceToken, address destinationToken, uint256 amount) public payable returns(bool){
        (bool succeeded, bytes memory result) = address(converterAddress).delegatecall(abi.encodeWithSignature("unwrap(address,address,uint256)", sourceToken, destinationToken,amount));
       return succeeded;
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
             ERC20Simple tokenToken = ERC20Simple(token);
             require(tokenToken.transfer(destination, amount));
         }

         return true;
     }


}