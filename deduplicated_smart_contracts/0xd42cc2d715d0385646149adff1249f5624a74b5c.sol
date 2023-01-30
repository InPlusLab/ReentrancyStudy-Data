/**
 *Submitted for verification at Etherscan.io on 2019-09-11
*/

pragma solidity ^0.5.5;

contract SafeMath { 
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;  
    }
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {  
    return a/b;   
    }
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;  
    }
  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
    }  
  function safePower(uint a, uint b) internal pure returns (uint256 result) {       
      assert(a >= 0); //edited this later!
      result = 1;
      for (uint256 i = 0; i < b; i++){
          result *= a;
          assert(result >= a);
      }
    }
}
contract Token {
  function totalSupply() public view returns (uint256 supply) {}
  function balanceOf(address _owner) public view returns (uint256 balance) {}
  function transfer(address _to, uint256 _value) public returns (bool success) {}
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}
  function approve(address _spender, uint256 _value) public returns (bool success) {}
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {}  
  function burn(uint256 _value) public returns (bool success){}
  function mintToken(address _target, uint256 _mintedAmount) public returns (bool success) {}
  function share(address _token) external payable {}
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  uint public decimals;
  string public name;
  uint256 public totalSupplyLimit;
}
interface tokenRecipient {function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }
contract UNIONDAOISSUE is SafeMath{     
    address payable public owner;
    address public manager;
    address public tokenAddress;
    uint256 public upTotalSupply;
    address public share;
    uint256 public tokenNumber;/*Number of assets*/    
    uint256 public blocksPeriod;
    bool public pauseIssue;
    uint256 public baseBlock;
    address public operator;
    mapping (uint256 => address) public investToken;
    mapping (uint256 => mapping (address => mapping (uint256 => uint256))) public investAmount;/*The investment amount of the investor of a certain type in each period*/
    mapping (uint256 => mapping (address => mapping (uint256 => address))) public investAddress;/*List of investors in each issue*/
    mapping (uint256 => mapping (address => uint256)) public investRate;/*Investment price ratio for each period*/    
    mapping (uint256 => mapping (address => uint256)) public investTotalAmount;/*Total investment in each period*/    
    mapping (uint256 => mapping (address => uint256)) public investorTotal;/*Number of investors in each issue*/    
    mapping (uint256 => mapping (address => uint256)) public SaleTotal;/*Sales volume of each period*/    
    mapping (address => uint256) public upAmount;/*The total amount rate of this token exchange per day,Defaults:1000000000000000*/ 
    mapping (address => uint256) public maxInvestRate;/*max invest rate*/                               
    mapping (address => uint8) public tokenDecimals;
    mapping (address => uint256) public newPrice;
    mapping (uint256 => uint256) public distributionInvestI;
    mapping (uint256 => uint256) public distributionInvestJ;

    event SetManager(address add);
    event ChangeOwner(address add);
    event SetShare(address add);
    event SetOperator(address add);
    event SetPauseIssue(bool pause);
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor (uint256 limitSupply,address incomeShare,uint256 blocks,address monetaryTokenAddress) public{
        upTotalSupply = limitSupply;        
        owner = msg.sender;
        manager = msg.sender;
        share = incomeShare;                
        blocksPeriod = blocks;              
        tokenAddress = monetaryTokenAddress;    
        baseBlock = block.number;       
        operator = msg.sender;          
    }
    
    /*Setup administrator*/
    function setManager(address _add)public returns (bool success) {
        require (msg.sender == owner) ;
        require (_add != address(0x0)) ;
        manager = _add ;                
        emit SetManager(_add);
        return true;    
    }  

    /*change Owner*/  
    function changeOwner(address payable _add)public returns (bool success) {
        require (msg.sender == owner) ;
        require (_add != address(0x0)) ;
        owner = _add ;              
        emit ChangeOwner(_add);
        return true;
    }  

    /*Set the revenue receiving address*/
    function setShare(address _add)public returns (bool success) {
        require (msg.sender == owner) ;
        require (_add != address(0x0)) ;
        share = _add ;              
        emit SetShare(_add);
        return true;
    }

    /*Set the distributionInvest operator address*/
    function setOperator(address _add)public returns (bool success) {       
        require (msg.sender == owner) ;
        require (_add != address(0x0)) ;
        operator = _add ;           
        emit SetOperator(_add);
        return true;
    }

    /*Pause Issue*/
    function setPauseIssue(bool _pause)public     {   
        require (msg.sender == manager) ; 
        pauseIssue = _pause; 
        emit SetPauseIssue(_pause);
    }                   

    /*set InvestToken*/
    function setInvestToken(address _token,uint256 _value,uint8 _tokenDecimals,uint256 _maxInvestRate)public returns (bool success) {
        require (msg.sender == owner) ; 
        require (_token != address(0x0)) ;
        require (_value > 0 && _value <= 10000000000000000) ;       
        if (upAmount[_token] == 0) {
            investToken[tokenNumber] = _token ;
            upAmount[_token] = _value ;
            tokenDecimals[_token] = _tokenDecimals;
            maxInvestRate[_token] = _maxInvestRate;
            tokenNumber = safeAdd(tokenNumber,1) ;        }     
        else{
            upAmount[_token] = _value ;
            tokenDecimals[_token] = _tokenDecimals;
            maxInvestRate[_token] = _maxInvestRate;        }
        return true;    
    }

    /*Set the latest price*/
    function setNewPrice(address _token,uint256 _amount)public returns (bool success) { 
        require (msg.sender == manager) ;
        require (_token != address(0x0)) ;
        newPrice[_token] = _amount ;
        return true;
    }

    // can accept ether
    function() external payable  {}
    // transfer Ether balance to owner
    function withdrawEther(uint amount) public{// transfer balance to owner
      require(msg.sender == owner);
      owner.transfer(amount); 
    }

    /*Get current sales*/
     function getThisTimesSaleAmount(address _token) public view returns (uint256 ) {
        return safeDiv(safeMul(safeSub(upTotalSupply , Token(tokenAddress).totalSupply()) , upAmount[_token]),safePower(10,18));
    }   

    //Assemble the address bytecode. If there is a bytecode, then _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
      uint length;
      assembly { length := extcodesize(_addr) }    
      return (length>0);
    }    

    /*Buy UDAO,receiveApproval*/
    function _buy(address _mgsSender,address _token,uint256 _amount) private  returns (bool success){   
        require(isContract(_mgsSender) == false && !pauseIssue);        
        require(_token != address(0x0));
        require(_amount >= safeMul(newPrice[_token],safeDiv(getThisTimesSaleAmount(_token),safeMul(10000,safePower(10,18)))));      
        require(upAmount[_token] > 0);                               
        require (Token(_token).transferFrom(_mgsSender, address(this), _amount)) ;   
        uint256 n = safeDiv(block.number , blocksPeriod);   
        investAddress[n][_token][investorTotal[n][_token]] = _mgsSender; 
        investAmount[n][_token][investorTotal[n][_token]] = _amount;        
        investTotalAmount[n][_token] = safeAdd(investTotalAmount[n][_token],_amount);
        investorTotal[n][_token] = safeAdd(investorTotal[n][_token],1);     
        return true;    
    }    
    
    /*Buy UDAO*/
    function buy(address _token,uint256 _amount) external payable  returns (bool success)    {   
        return _buy(msg.sender,_token,_amount);    }
    
    //This method implements the service contract function. _from: original sender, _value: send value, _token: token contract address, _extraData: extended data
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public    {   
        uint256 loadSize;uint256 load;
        assembly {
          loadSize := mload(_extraData)
          load := mload(add(_extraData, 0x20))}
        load = load >> 8*(32 - loadSize);
        if(load == 0x31){_buy(_from,_token,_value);}
    }

    /*Get GrowthRate*/
    function getGrowthRate(uint256 _base) public view returns (uint256 _rate) {
        _rate = (block.number - _base) * 1000000000000000000 / 600000;          
        if(_rate > 10000000000000000000)        
            _rate = 10000000000000000000;       
        return _rate;
    }

    /*End n round of auction, assign token*/
    function distributionInvest(uint256 _periods,uint256 _batchsize) public returns (bool success)    {
        require(msg.sender == operator);
        require( _periods < safeDiv(block.number , blocksPeriod) && !pauseIssue);       
        uint256 n = _periods;
        for (uint256 j = distributionInvestJ[_periods]; j < tokenNumber; j++){
            if (investTotalAmount[n][investToken[j]] >= 1){     
                if(distributionInvestI[_periods] == 0){
                    investRate[n][investToken[j]] = safeDiv(safeMul(getThisTimesSaleAmount(investToken[j]) , safePower(10,18)) , investTotalAmount[n][investToken[j]]);     
                }
                if(investRate[n][investToken[j]] > safeDiv( safeMul( maxInvestRate[investToken[j]] , 1000000000000000000) , safeAdd(1000000000000000000 , getGrowthRate(baseBlock)) )){     
                    investRate[n][investToken[j]] = safeDiv( safeMul( maxInvestRate[investToken[j]] , 1000000000000000000) , safeAdd(1000000000000000000 , getGrowthRate(baseBlock)) );     
                }
                if(distributionInvestI[_periods] == 0){
                    SaleTotal[n][investToken[j]] = safeDiv(safeMul(investTotalAmount[n][investToken[j]],investRate[n][investToken[j]]),safePower(10,18));   
                    newPrice[investToken[j]] = safeDiv(safePower(10,36),investRate[n][investToken[j]]);   
                    if (share != address(this)){
                        require(Token(investToken[j]).transfer(share, investTotalAmount[n][investToken[j]]));
                    }
                    Token(tokenAddress).mintToken(address(this),SaleTotal[n][investToken[j]]);
                }   
                uint256 _temp;
                for (uint256 i = distributionInvestI[_periods]; i < investorTotal[n][investToken[j]]; i++){
                    if(Token(tokenAddress).balanceOf(address(this)) < safeDiv(safeMul(investAmount[n][investToken[j]][i],investRate[n][investToken[j]]),safePower(10,18))){
                        Token(tokenAddress).mintToken(address(this),safeSub(safeDiv(safeMul(investAmount[n][investToken[j]][i],investRate[n][investToken[j]]),safePower(10,18)),Token(tokenAddress).balanceOf(address(this))));
                    }
                    Token(tokenAddress).transfer(investAddress[n][investToken[j]][i],safeDiv(safeMul(investAmount[n][investToken[j]][i],investRate[n][investToken[j]]),safePower(10,18))) ;
                    _temp = _temp + 1;
                    distributionInvestI[_periods] = i+1;
                    if(_temp >= _batchsize && i < investorTotal[n][investToken[j]] - 1){
                        distributionInvestJ[_periods] = j;
                        return false;
                    } 
                    if (i >= investorTotal[n][investToken[j]]-1 && j != tokenNumber-1 ){
                        distributionInvestI[_periods] = 0;
                        distributionInvestJ[_periods] = j+1;
                    }
                }                
            }
        }        
        return true;
    }
}