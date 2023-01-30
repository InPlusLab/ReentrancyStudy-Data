pragma solidity 0.5.0;

import "./Ownable.sol";

contract SuperGlobalReferral is Ownable {
    
    struct MasterWithSlave {
        address payable master;
        address payable slave;
        uint256 masterPercent;
        uint256 slavePercent;
        string investorCode;
        bool isMasterValid;
        bool isSlaveValid;
    }
    
    struct Master {
        address payable master;
        uint256 masterPercent;
        string investorCode;
        bool isMasterValid;
    }
    
    MasterWithSlave[] public masterWithSlaveData;
    Master[] public masterData;
    address payable zeroAddress = 0x0000000000000000000000000000000000000000;
    
    mapping(string => uint256) private investorCodeToMasterWithSlaveIndex;
    mapping(string => uint256) private investorCodeToMasterIndex;
    
   constructor () public {
       
       MasterWithSlave memory newData1 = MasterWithSlave(zeroAddress, zeroAddress,0, 0 ,"null",false ,false);
        masterWithSlaveData.push(newData1);
        investorCodeToMasterWithSlaveIndex["null"] = masterWithSlaveData.length -1;
        
         Master memory newData2 = Master(zeroAddress, 0 , "null" , false );
        
        masterData.push(newData2);
        investorCodeToMasterWithSlaveIndex["null"] = masterData.length -1 ;
    }
    
    // Get index by investor code
    
    function getMasterWithSlaveIndexByInvestorCode(string memory _investorCode) public view returns(uint256){
        return investorCodeToMasterWithSlaveIndex[_investorCode];
    }
       
    function getMasterIndexByInvestorCode(string memory _investorCode) public view returns(uint256){
        return investorCodeToMasterIndex[_investorCode];
    }
    
    // Valid functions
    
    
    function isMasterValid (string memory _investorCode) public view returns (bool){
        uint256 index = investorCodeToMasterIndex[_investorCode];
        return masterData[index].isMasterValid;
    }
    
    function isMasterWithSlaveValid(string memory _investorCode) public view returns(bool){
         uint256 index = investorCodeToMasterWithSlaveIndex[_investorCode];
         return masterWithSlaveData[index].isSlaveValid;
    }
    
    function isSlaveValid(string memory _investorCode) public view returns(bool) {
        uint256 index = investorCodeToMasterWithSlaveIndex[_investorCode];
        return masterWithSlaveData[index].isSlaveValid;
    }
    
    // Address functions
    function getMasterAddress(string memory _investorCode) public view returns(address payable) {
        uint256 index = investorCodeToMasterIndex[_investorCode];
        return masterData[index].master;
    }
    
    function getMasterWithSlaveAddress(string memory _investorCode) public view returns(address payable){
          uint256 index = investorCodeToMasterWithSlaveIndex[_investorCode];
        return masterWithSlaveData[index].master;
    }
    
    function getSlaveAddress(string memory _investorCode) public view returns(address payable) {
        uint256 index = investorCodeToMasterWithSlaveIndex[_investorCode];
        return masterWithSlaveData[index].slave;
    }

    // Percentage Functions
       
    function getMasterPercent(string memory _investorCode) public view returns(uint256) {
        uint256 index = investorCodeToMasterIndex[_investorCode];
        return masterData[index].masterPercent;
    }
    
    function getMasterWithSlavePercent(string memory _investorCode) public view returns(uint256) {
        uint256 index = investorCodeToMasterWithSlaveIndex[_investorCode];
        return masterWithSlaveData[index].masterPercent;
    }
    
    function getSlavePercent(string memory _investorCode) public view returns(uint256) {
       uint256 index = investorCodeToMasterWithSlaveIndex[_investorCode];
        return masterWithSlaveData[index].slavePercent;
    }
    
    // Insert functions 
    
    function addMasterWithSlave(address payable _master, address payable _slave, uint256 _masterPercent, uint256 _slavePercent , string memory _investorCode ) public onlyOwner {
        require(getMasterWithSlaveIndexByInvestorCode(_investorCode) == 0 && getMasterIndexByInvestorCode(_investorCode) == 0 );
        
        MasterWithSlave memory newData = MasterWithSlave(_master, _slave, _masterPercent, _slavePercent , _investorCode  ,true ,true);
        
        masterWithSlaveData.push(newData);
        investorCodeToMasterWithSlaveIndex[_investorCode] = masterWithSlaveData.length -1;
    }
    
    function addMaster(address payable _master , uint256 _masterPercent , string memory _investorCode ) public onlyOwner{
        require(getMasterIndexByInvestorCode(_investorCode) == 0 && getMasterWithSlaveIndexByInvestorCode(_investorCode) == 0);
        
        Master memory newData = Master(_master, _masterPercent , _investorCode , true );
        
        masterData.push(newData);
        investorCodeToMasterIndex[_investorCode] = masterData.length -1 ;
    }
    
    function invalidateMaster(string memory _investorCode) public onlyOwner{
        uint256 index1 = getMasterIndexByInvestorCode(_investorCode);
        uint256 index2 = getMasterWithSlaveIndexByInvestorCode(_investorCode);
        
        masterData[index1].isMasterValid = false;
        masterWithSlaveData[index2].isMasterValid = false;
        masterWithSlaveData[index2].isSlaveValid = false;
    }
    
     function validateMaster(string memory _investorCode) public onlyOwner{
        uint256 index1 = getMasterIndexByInvestorCode(_investorCode);
        uint256 index2 = getMasterWithSlaveIndexByInvestorCode(_investorCode);
        
        masterData[index1].isMasterValid = true;
        masterWithSlaveData[index2].isMasterValid = true;
        masterWithSlaveData[index2].isSlaveValid = true;

    }
    
    
  
}


