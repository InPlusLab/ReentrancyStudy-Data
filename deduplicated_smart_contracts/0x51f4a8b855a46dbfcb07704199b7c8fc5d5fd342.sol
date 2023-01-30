/**

 *Submitted for verification at Etherscan.io on 2018-12-09

*/



pragma solidity ^0.4.24;



contract Casher

{

  struct casher

  {

     uint blockPaymentC;

     uint blockPaymentI;

     uint valueC;

     uint valueI;

  }



  mapping (address => uint) private addrToIndex;

  mapping (uint => casher) private indToCasher;

  address private owner;

  uint private currentIndex = 1;



  modifier onlyOwner() 

  {

      require(msg.sender == owner, "access denied");

      _;

  }



   constructor() public 

   {

      owner = msg.sender;

   }



   function insert(address addr, uint blkNum, uint value, bool isCashback) public onlyOwner returns (bool)

   {

      uint index = addrToIndex[addr];

      if(index > 0)

        return false;

      addrToIndex[addr] = currentIndex;

      if(isCashback)

      {

        indToCasher[currentIndex].valueC = value;

        indToCasher[currentIndex].blockPaymentC = blkNum;

      }

      else

      {

        indToCasher[currentIndex].valueI = value;

        indToCasher[currentIndex].blockPaymentI = blkNum;

      }    

      currentIndex++;

      return true;

   }



   function addValue(address addr, uint blkNum, uint value, bool isCashback) public onlyOwner returns (bool)

   {

      uint index = addrToIndex[addr];

      if(index == 0)

        return false;

      if(isCashback)

      {

        indToCasher[index].valueC += value;

        indToCasher[index].blockPaymentC = blkNum;

      }

      else

      {

        indToCasher[index].valueI += value;

      } 

      return true;

   }



   function getCasherIndex(address addr) public view onlyOwner returns (uint)

   {

      return addrToIndex[addr];

   }



  function getCasherBlockC(uint casherIndex) public view onlyOwner returns (uint)

   {

      return indToCasher[casherIndex].blockPaymentC;

   }



   function getCasherBlockI(uint casherIndex) public view onlyOwner returns (uint)

   {

      return indToCasher[casherIndex].blockPaymentI;

   }



   function getCasherValueC(uint casherIndex) public view onlyOwner returns (uint)

   {

      return indToCasher[casherIndex].valueC;

   }



   function getCasherValueI(uint casherIndex) public view onlyOwner returns (uint)

   {

      return indToCasher[casherIndex].valueI;

   }



   function setZeroCasherValueC(uint casherIndex) public onlyOwner

   {

      indToCasher[casherIndex].valueC = 0;

   }



   function setCasherBlockI(uint casherIndex, uint blkNum) public onlyOwner

   {

      indToCasher[casherIndex].blockPaymentI = blkNum;

   }



   function size() public view returns (uint) 

   {

      return currentIndex;

   }



   function contains(address addr) public view returns (bool) 

   {

     return addrToIndex[addr] > 0;

   }

}



library SafeMath 

{

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) 

  {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) 

    {

      return 0;

    }



    uint256 c = _a * _b;

    require(c / _a == _b);



    return c;

  }



  function div(uint256 _a, uint256 _b) internal pure returns (uint256) 

  {

    require(_b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



    return c;

  }



  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) 

  {

    require(_b <= _a);

    uint256 c = _a - _b;



    return c;

  }



  function add(uint256 _a, uint256 _b) internal pure returns (uint256) 

  {

    uint256 c = _a + _b;

    require(c >= _a);



    return c;

  }



  function mod(uint256 a, uint256 b) internal pure returns (uint256) 

  {

    require(b != 0);

    return a % b;

  }

}



library Percent 

{

  // Solidity automatically throws when dividing by 0

  struct percent 

  {

    uint num;

    uint den;

  }



  function mul(percent storage p, uint a) internal view returns (uint) 

  {

    if (a == 0) {

      return 0;

    }

    return a*p.num/p.den;

  }



  function div(percent storage p, uint a) internal view returns (uint) 

  {

    return a/p.num*p.den;

  }



  function sub(percent storage p, uint a) internal view returns (uint) 

  {

    uint b = mul(p, a);

    if (b >= a) return 0;

    return a - b;

  }



  function add(percent storage p, uint a) internal view returns (uint) 

  {

    return a + mul(p, a);

  }

}



library ToAddress {

  function toAddr(uint source) internal pure returns(address) {

    return address(source);

  }



  function toAddr(bytes source) internal pure returns(address addr) {

    assembly { addr := mload(add(source,0x14)) }

    return addr;

  }

}



contract CashBack 

{

  using Percent for Percent.percent;

  using SafeMath for uint;

  using ToAddress for *;



  Casher private cashers;



  address public commissionAddr;

  uint public txCount;

  uint constant blockPeriod = 5900;

  uint public volume;

  uint public startBlock;

  uint public constant minInvesment = 30 finney;



  Percent.percent private m_sendPercent = Percent.percent(2, 100);



  Percent.percent private m_payPercentC = Percent.percent(4, 100); 

  Percent.percent private m_payPercentI = Percent.percent(3, 100);



  Percent.percent private m_commissionPercentC = Percent.percent(1, 100); 

  Percent.percent private m_commissionPercentI = Percent.percent(8, 100); 



  constructor() public 

  {

    commissionAddr = 0xBC7e6445d8C099aD6b3eB2FAE695F309B8379f74;

    newCycle();

  }



  function cashersNumber() public view returns(uint) 

  {

    return cashers.size() - 1;

  }



  function balanceETH() public view returns(uint)

   {

    return address(this).balance;

  }



  function() public payable 

  {

    if (msg.value == 0) 

    {

      getMyCash();

      return;

    }



    address addr = msg.data.toAddr();

    if ((addr != address(0)) && (addr != address(this)))

    {

      doCash(addr, true); 

    } 

    else

    {

      doCash(addr, false);

    }

    

  }



  function getMyCash() private 

  {

    require(cashers.contains(msg.sender));

    uint indexCasher = cashers.getCasherIndex(msg.sender);



    //check cashback

    uint indexBlock = cashers.getCasherBlockC(indexCasher);

    uint value = cashers.getCasherValueC(indexCasher);



    if((indexBlock + blockPeriod <= block.number) && (value > 0))

    {

      value = m_payPercentC.mul(value);

  

      if (address(this).balance < value) 

      {

          newCycle();

          return;

      }



      cashers.setZeroCasherValueC(indexCasher);

      msg.sender.transfer(value);

    }



    //check dividents

    indexBlock = cashers.getCasherBlockI(indexCasher);

    value = cashers.getCasherValueI(indexCasher);

    if((indexBlock + blockPeriod <= block.number) && (value > 0))

    {

      if(value < 1)

        m_payPercentI = Percent.percent(3, 100);

      if(value > 1 && value <= 2)

        m_payPercentI = Percent.percent(4, 100);

      if(value > 2)

        m_payPercentI = Percent.percent(5, 100);

      

      uint times = block.number.sub(indexBlock).div(blockPeriod);

      value = m_payPercentI.mul(value).mul(times);

      

      if (address(this).balance < value) 

      {

          newCycle();

          return;

      }



      cashers.setCasherBlockI(indexCasher, block.number);

      msg.sender.transfer(value);

    }

  }



  function doCash(address recipient, bool isCashBack) private 

  {

    require(msg.value >= minInvesment, "msg.value must be >= minInvesment");

    

    if(isCashBack)

    {

      //statistic

      volume += msg.value;

      txCount++;



      //commission

      commissionAddr.transfer(m_commissionPercentC.mul(msg.value));



      //retransfer

      uint value = m_sendPercent.sub(msg.value);

      recipient.transfer(value); 

    }

    else

    {

      commissionAddr.transfer(m_commissionPercentI.mul(msg.value));

    }

      

    //write to casher

    if (cashers.contains(msg.sender)) 

    {

      assert(cashers.addValue(msg.sender, block.number, msg.value, isCashBack));

    }

    else 

    {

      assert(cashers.insert(msg.sender, block.number, msg.value, isCashBack));

    }

  }



  function newCycle() private 

  {

    cashers = new Casher();

    txCount = 0;

    volume = 0;

    startBlock = block.number;

  }

}