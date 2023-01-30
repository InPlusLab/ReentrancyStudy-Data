/**
 *Submitted for verification at Etherscan.io on 2020-12-05
*/

// SPDX-License-Identifier: MIT

 pragma solidity = 0.7 .4;

 abstract contract Context {
   function _msgSender() internal view virtual returns(address payable) {
     return msg.sender;
   }

   function _msgData() internal view virtual returns(bytes memory) {
     this;
     return msg.data;
   }
 }

 contract Ownable is Context {
   address private _owner;

   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   constructor() {
     address msgSender = _msgSender();
     _owner = msgSender;
     emit OwnershipTransferred(address(0), msgSender);
   }

   function owner() public view returns(address) {
     return _owner;
   }

   modifier onlyOwner() {
     require(_owner == _msgSender(), "Ownable: caller is not the owner");
     _;
   }

   function renounceOwnership() public virtual onlyOwner {
     emit OwnershipTransferred(_owner, address(0));
     _owner = address(0);
   }

   function transferOwnership(address newOwner) public virtual onlyOwner {
     require(newOwner != address(0), "Ownable: new owner is the zero address");
     emit OwnershipTransferred(_owner, newOwner);
     _owner = newOwner;
   }
 }

 library SafeMath {

   function add(uint256 a, uint256 b) internal pure returns(uint256) {
     uint256 c = a + b;
     require(c >= a, "SafeMath: addition overflow");

     return c;
   }

   function sub(uint256 a, uint256 b) internal pure returns(uint256) {
     return sub(a, b, "SafeMath: subtraction overflow");
   }

   function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
     require(b <= a, errorMessage);
     uint256 c = a - b;

     return c;
   }

   function mul(uint256 a, uint256 b) internal pure returns(uint256) {
     if (a == 0) {
       return 0;
     }

     uint256 c = a * b;
     require(c / a == b, "SafeMath: multiplication overflow");

     return c;
   }

   function div(uint256 a, uint256 b) internal pure returns(uint256) {
     return div(a, b, "SafeMath: division by zero");
   }

   function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
     require(b > 0, errorMessage);
     uint256 c = a / b;
     // assert(a == b * c + a % b); // There is no case in which this doesn't hold

     return c;
   }

 }

 abstract contract Router {
   function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);
 }

 contract Market is Ownable {

   using SafeMath
   for uint;

   uint private maxSell = 5000000000000000000000000;
   uint private circulatingKrk = 0;
   uint private circulatingEth = 0;
   uint krakintTotalEthEarnings = 0;
   uint investorsCirculatingEthEarnings = 0;
   mapping(address => uint) private userEth;
   mapping(address => uint) private circulatingUserKrk;
   mapping(address => uint) private totalUserFees;
   uint private totalBurnedKRK = 0;
   uint private totalMintedKRK = 0;
   uint private totalDepositedEth = 0;
   uint private totalWithdrawnEth = 0;
   uint private totalFeesPaid = 0;
   uint private totalKrakintEarnings = 0;
   uint private totalInvestorsEarnings = 0;
   uint private totalDepositAfterFees = 0;

   address private routerContract;
   Router private router;
   mapping(address => bool) private mutex;
   mapping(address => uint) private mutexTimeout;

   function purchaseTokens() external payable {
     require(!mutex[msg.sender] || mutexTimeout[msg.sender] < block.number, "Contract safety feature, please wait");
     mutex[msg.sender] = true;
     mutexTimeout[msg.sender] = (block.number).add(1200); //approx. 20 min. assuming 12 seconds per block.

     //get wei amount 
     if (msg.value <= 0) revertWithMutex(msg.sender);
     uint weiAmount = msg.value;

     //project KRK return
     uint krks = getKrkReturn(weiAmount);
     if (circulatingKrk.add(krks) > maxSell) revertWithMutex(msg.sender);

     //calculate fees
     uint fee = getFourPercent(weiAmount);
     uint krakintFee = fee.div(2);
     uint investorFee = fee.sub(krakintFee);
     uint afterFees = weiAmount.sub(fee);

     //update tables 
     circulatingKrk = circulatingKrk.add(krks);
     circulatingEth = circulatingEth.add(weiAmount);
     krakintTotalEthEarnings = krakintTotalEthEarnings.add(krakintFee);
     investorsCirculatingEthEarnings = investorsCirculatingEthEarnings.add(investorFee);

     userEth[msg.sender] = userEth[msg.sender].add(afterFees);
     circulatingUserKrk[msg.sender] = circulatingUserKrk[msg.sender].add(krks);
     totalUserFees[msg.sender] = totalUserFees[msg.sender].add(fee);

     totalMintedKRK = totalMintedKRK.add(krks);
     totalDepositedEth = totalDepositedEth.add(weiAmount);
     totalFeesPaid = totalFeesPaid.add(fee);
     totalKrakintEarnings = totalKrakintEarnings.add(krakintFee);
     totalInvestorsEarnings = totalInvestorsEarnings.add(investorFee);
     totalDepositAfterFees = totalDepositAfterFees.add(afterFees);

     //mint tokens
     mint(krks);
     mutex[msg.sender] = false;

   }

   function purchaseEthereum(uint krkAmount) external returns(bool success) {
     require(!mutex[msg.sender] || mutexTimeout[msg.sender] < block.number, "Contract safety in place, please wait");
     mutex[msg.sender] = true;
     mutexTimeout[msg.sender] = (block.number).add(100); //approx. 20 min.

     if (circulatingKrk <= 0) revertWithMutex(msg.sender);
     if (krkAmount <= 0) revertWithMutex(msg.sender);

     uint ethAmount = getEthReturnNoBonus(krkAmount, msg.sender);

     if (ethAmount <= 0) revertWithMutex(msg.sender);

     uint bonusEth = getEthReturnBonus(krkAmount, msg.sender);
     uint sendAmount = ethAmount.add(bonusEth);

     if (sendAmount <= 0) revertWithMutex(msg.sender);

     //update tables 
     circulatingKrk = circulatingKrk.sub(krkAmount);
     investorsCirculatingEthEarnings = investorsCirculatingEthEarnings.sub(bonusEth);

     userEth[msg.sender] = userEth[msg.sender].sub(ethAmount);
     circulatingUserKrk[msg.sender] = circulatingUserKrk[msg.sender].sub(krkAmount);

     totalBurnedKRK = totalBurnedKRK.add(krkAmount);

     //burn krk
     burn(krkAmount);

     //send eth
     address payable payableAddress = address(uint160(address(msg.sender)));
     payableAddress.transfer(sendAmount);
     totalWithdrawnEth = totalWithdrawnEth.add(sendAmount);
     circulatingEth = circulatingEth.sub(sendAmount);

     mutex[msg.sender] = false;
     return true;
   }

   function mint(uint mintAmount) private returns(bool success) {
     address fromAddress = address(0);
     address[2] memory addresseArr = [fromAddress, msg.sender];
     uint[2] memory uintArr = [mintAmount, 0];

     router.extrenalRouterCall("mint_market", addresseArr, uintArr);

     return true;
   }

   function burn(uint burnAmount) private returns(bool success) {
     address toAddress = address(0);
     address[2] memory addresseArr = [msg.sender, toAddress];
     uint[2] memory uintArr = [burnAmount, 0];

     router.extrenalRouterCall("burn_market", addresseArr, uintArr);

     return true;
   }

   //----------VIEWS START---------------------
   function getEthReturnNoBonus(uint krkAmount, address userAddress) public view virtual returns(uint ethAmount) {
     if (circulatingKrk <= 0) return 0;
     if (circulatingUserKrk[userAddress] <= 0) return 0;
     if (krkAmount <= 0) return 0;
     if (krkAmount > circulatingUserKrk[userAddress]) return 0; 

     uint returnEth = (userEth[userAddress].mul(krkAmount)).div(circulatingUserKrk[userAddress]);
     return returnEth;
   }

   function getEthReturnBonus(uint krkAmount, address userAddress) public view virtual returns(uint bonusAmount) {
     if (circulatingKrk <= 0) return 0;
     if (krkAmount <= 0) return 0;
     if (circulatingUserKrk[userAddress] < krkAmount) return 0;
     
     uint bonusEth = (circulatingUserKrk[userAddress].mul(circulatingUserKrk[userAddress])
                    .mul(investorsCirculatingEthEarnings)).div(circulatingKrk.mul(circulatingKrk));
     
     return bonusEth;
   }

   function getKrkReturn(uint gweiAmount) public view virtual returns(uint krkAmount) {
     uint fee_total = getFourPercent(gweiAmount);

     uint afterFee = gweiAmount.sub(fee_total);
     uint price = getPrice(circulatingKrk);
     require(price > 0, "at: market.sol | function: getKrkReturn | message: Division by zero, at getKrkReturn");
     uint krks = (afterFee.mul(1000000000000000000)).div(price);

     uint stageNumber = getStageNumber(circulatingKrk);
     uint multiplyBy = (uint(1000)).div(stageNumber);

     krks = krks.mul(multiplyBy);

     return krks;
   }

   function getCirculatingKrk() public view virtual returns(uint krkAmount) {
     return circulatingKrk;
   }
   
  function getCirculatingEth() public view virtual returns(uint krkAmount) {
     return circulatingEth;
   }

   function getKrakintTotalEthEarnings() public view virtual returns(uint ethAmount) {
     return krakintTotalEthEarnings;
   }

   function getInvestorsCirculatingEthEarnings() public view virtual returns(uint ethAmount) {
     return investorsCirculatingEthEarnings;
   }

   function getUserEth(address userAddress) public view virtual returns(uint ethAmount) {
     return userEth[userAddress];
   }

   function getCirculatingUserKrk(address userAddress) public view virtual returns(uint ethAmount) {
     return circulatingUserKrk[userAddress];
   }

   function getTotalUserFees(address userAddress) public view virtual returns(uint ethAmount) {
     return totalUserFees[userAddress];
   }

   function getTotalBurnedKRK() public view virtual returns(uint ethAmount) {
     return totalBurnedKRK;
   }

   function getTotalMintedKRK() public view virtual returns(uint ethAmount) {
     return totalMintedKRK;
   }

   function getTotalDepositedEth() public view virtual returns(uint ethAmount) {
     return totalDepositedEth;
   }
   
   function getTotalWithdrawnEth() public view virtual returns(uint ethAmount) {
     return totalWithdrawnEth;
   }

   function getTotalFeesPaid() public view virtual returns(uint ethAmount) {
     return totalFeesPaid;
   }

   function getTotalKrakintEarnings() public view virtual returns(uint ethAmount) {
     return totalKrakintEarnings;
   }

   function getTotalInvestorsEarnings() public view virtual returns(uint ethAmount) {
     return totalKrakintEarnings;
   }

   function getTotalDepositAfterFees() public view virtual returns(uint ethAmount) {
     return totalKrakintEarnings;
   }

   //----------PRIVATE PURE START---------------------

   function getStageNumber(uint x) private pure returns(uint stageNumber) {
     uint ret = 1;
     if (x >= 4500000000000000000000000) {
       ret = 10;
     } else if (x >= 4000000000000000000000000) {
       ret = 9;
     } else if (x >= 3500000000000000000000000) {
       ret = 8;
     } else if (x >= 3000000000000000000000000) {
       ret = 7;
     } else if (x >= 2500000000000000000000000) {
       ret = 6;
     } else if (x >= 2000000000000000000000000) {
       ret = 5;
     } else if (x >= 1500000000000000000000000) {
       ret = 4;
     } else if (x >= 1000000000000000000000000) {
       ret = 3;
     } else if (x >= 500000000000000000000000) {
       ret = 2;
     }
     return ret;
   }

   //returns price per eth in gwei
   function getPrice(uint x) private pure returns(uint retPrice) {

     //uint x = circulatingKrk;

     //stage 10
     //linear equation: y = 5.8579¡Á10^-6 x - 19.2895
     //intercepts (4500000,7.07105) and (5000000,10)
     if (x >= 4500000000000000000000000) {
       return (((x).mul(58579)).div(10000000000)).sub(19289500000000000000);
     }

     //stage 9
     //linear equation: y = 3.8579¡Á10^-6 x - 10.2895
     //intercepts (4000000,5.1421) and (5000000,9)
     if (x >= 4000000000000000000000000) {
       return (((x).mul(38579)).div(10000000000)).sub(10289500000000000000);
     }

     //stage 8
     //linear equation: y = 2.85792¡Á10^-6 x - 6.28958
     //intercepts (3500000,3.713125) and (5000000,8)
     if (x >= 3500000000000000000000000) {
       return (((x).mul(6859)).div(2400000000)).sub(6289583333333333333);
     }

     //stage 7
     //linear equation: y = 2.19125¡Á10^-6 x - 3.95625
     //intercepts (3000000,2.6175) and (5000000,7)
     if (x >= 3000000000000000000000000) {
       return (((x).mul(1753)).div(800000000)).sub(3956250000000000000);
     }

     //stage 6
     //linear equation: y = 1.69125¡Á10^-6 x - 2.45625
     //intercepts (2500000,1.771875) and (5000000,6)
     if (x >= 2500000000000000000000000) {
       return (((x).mul(1353)).div(800000000)).sub(2456250000000000000);
     }

     //stage 5
     //linear equation: y = 1.29125¡Á10^-6 x - 1.45625
     //intercepts (2000000,1.126251) and (5000000,5)
     if (x >= 2000000000000000000000000) {
       return (((x).mul(3873749)).div(3000000000000)).sub(1456248333333333333);
     }

     //stage 4
     //linear equation: y = 9.57917¡Á10^-7 x - 0.789583
     //intercepts (1500000,0.647292) and (5000000,4)
     if (x >= 1500000000000000000000000) {
       return (((x).mul(838177)).div(875000000000)).sub(789582857142857142);
     }

     //stage 3
     //linear equation: y = 6.72202¡Á10^-7 x - 0.361011
     //intercepts (1000000,0.311191) and (5000000,3)
     if (x >= 1000000000000000000000000) {
       return (((x).mul(2688809)).div(4000000000000)).sub(361011250000000000);
     }

     //stage 2
     //linear equation: y = 4.22202¡Á10^-7 x - 0.111011
     //intercepts (500000,0.10009) and (5000000,2)
     if (x >= 500000000000000000000000) {
       return (((x).mul(189991)).div(450000000000)).sub(111011111111111111);
     }

     //stage 1
     //linear equation: y = 1.9998¡Á10^-7 x + 0.0001
     //intercepts (0,0.0001) and (5000000,1)

     return (((x).mul(9999)).div(50000000000)).add(100000000000000);
   }

   function getFourPercent(uint number) private pure returns(uint fivePercent) {
     uint ret = number.div(25);
     return ret;
   }

   function revertWithMutex(address userAddress) private {
     mutex[userAddress] = false;
     require(mutex[userAddress], "at: market.sol | function: revertWithMutex | message: Prevented multiple calls with the mutex, your previous call must end or expire");
   }

   //+++++++++++ONLY OWNER++++++++++++++++
   //----------SETTERS--------------------
   function setNewRouterContract(address newRouterAddress) onlyOwner public virtual returns(bool success) {
     routerContract = newRouterAddress;
     router = Router(newRouterAddress);
     return true;
   }

   function withdrawEthereum() external onlyOwner returns(bool success) {
     address payable payableAddress = address(uint160(address(msg.sender)));
     payableAddress.transfer(krakintTotalEthEarnings);
     krakintTotalEthEarnings = 0;
     return true;
   }

 }