/**
 *Submitted for verification at Etherscan.io on 2020-07-16
*/

pragma solidity ^0.4.24;

/**
 * @title Ownable
 */
contract Ownable {

    address public owner;
  
    constructor() public {

        owner = msg.sender;

    }
   
    modifier onlyOwner() {

        require(msg.sender == owner);
        _;

    }

    function transferOwnership(address newOwner) onlyOwner public {
        
        if (newOwner != address(0)) {
            owner = newOwner;
        }

    }

}

/**
 * @title SafeMath
 */
library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
       
        assert(b <= a);
        return a - b;

    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
       
        uint256 c = a + b;
        assert(c >= a);
        return c;

    }

}

/**
 * @title tokenRecipient
 */
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }


/**
 * @title TokenERC20
 */
contract TokenERC20 {

    using SafeMath for uint256;

    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    
    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address _owner) view public returns(uint256) {
      
        return balances[_owner];

    }

    function allowance(address _owner, address _spender) view public returns(uint256) {
        
        return allowed[_owner][_spender];

    }

    
    function _transfer(address _from, address _to, uint _value) internal {
       
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer( _from, _to, _value);

    }

  
    function transfer(address _to, uint256 _value) public returns(bool) {
      
        _transfer(msg.sender, _to, _value);
        return true;

    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
       
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;

    }

    
    function approve(address _spender, uint256 _value) public returns(bool) {
       
        // Avoid the front-running attack
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;

    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool) {
       
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
        return false;

    }

    
    function burn(uint256 _value) public returns(bool) {
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;

    }

    
    function burnFrom(address _from, uint256 _value) public returns(bool) {
       
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from, _value);
        return true;

    }

    function transferMultiple(address[] _to, uint256[] _value) returns(bool) {
        
        require(_to.length == _value.length);
        uint256 i = 0;
        while (i < _to.length) {
           _transfer(msg.sender, _to[i], _value[i]);
           i += 1;
        }
        return true;

    }

}

/**
 * @title RICToken
 */
contract RICToken is TokenERC20, Ownable {
    
    using SafeMath for uint256;

    string public constant name = "RICToken";
    string public constant symbol = "RIC";
    uint8 public constant decimals = 6;

    event Mint(address indexed _to, uint256 _amount);

    function mint(address _to, uint256 _amount) public onlyOwner{
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
    }

}


contract RICMiner is  RICToken{
    
    using SafeMath for uint256;
    
    struct Customer{
       uint256 minerAmount; 
       address customerAddr;
       address customerEquity;
       bool flag;  
       uint256 buyGoods;
    }

    struct Good{
       string goodId;
       uint256 price; 
       string desc;
       uint256 power;
       address belong;
    }

    event Records(address user,uint256 value);
    event AddGood(address sender,bool isScuccess,string message);
    event BuyGood(address sender,bool isSuccess,string message);
    event ActiveMiner(address sender,bool isSuccess,string message);
    event Transfer(address _from,address to,uint256);
    
    mapping (string=>Customer) customer;
    mapping (string=>Good) good;
    string[] goods;
    string[] minerAmount; 
    address[] purchasedOfUser; 
    address[] activationMiner; 

    uint256  private rew; 
    uint256 public sellPrice;
    uint256 public buyPrice;

    function () public payable {

        require(msg.sender != 0x0);
        require(msg.value != 0 ether);
        emit Records(msg.sender,msg.value);

    }

    function enter() public  payable{

        require(msg.sender != 0x0);
        require(msg.value != 0 ether);
        emit Records(msg.sender,msg.value);

    }

    function transferETH()public onlyOwner{

        msg.sender.transfer(address(this).balance);

    }

    function  destroy()  public onlyOwner {

        selfdestruct(owner);

    }

    function getContractBalance() public constant returns (uint256) {
       
        return address(this).balance;

     }

     function setRew(uint256 _value) public onlyOwner {

        rew  = _value*10**5;

     }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
  
    function buy() payable public {
        uint amount = msg.value / buyPrice;                 
        _transfer(address(this), msg.sender, amount);      
    }

    function sell(uint256 amount) public {
        address myAddress = address(this);
        require(myAddress.balance >= amount * sellPrice);   
        _transfer(msg.sender, address(this), amount);      
        msg.sender.transfer(amount * sellPrice);           
    }

    function createData(string _minerId,string _desc,uint256 _price,address _belong,uint256 _power)public  onlyOwner returns(bool){

        if(!isGoodAlreadyAdd(_minerId)){

            good[_minerId].goodId = _minerId;
            good[_minerId].price = _price;
            good[_minerId].desc = _desc;
            good[_minerId].power = _power;
            good[_minerId].belong = _belong;
            goods.push(_minerId);
            emit AddGood(msg.sender,true,"Miner added successfully");
            return true;

        }else{

            emit AddGood(msg.sender,false,"The miner has been added!!!");
            return false;

        }


    }

    function isGoodAlreadyAdd(string _minerId) internal returns(bool){
        
       for(uint256 i= 0;i < goods.length;i++){
            
            if(keccak256(goods[i]) == keccak256(_minerId)){
                
                return true;

            }

        }

        return false;

    }

    function buyGood(string _minerId,address _user,uint256 _amount,address _customerEquity) public onlyOwner{

         if(isGoodAlreadyAdd(_minerId)){

            if( _amount != 0 ){
                
                purchasedOfUser.push(_user);
                customer[_minerId].minerAmount = _amount;
                customer[_minerId].customerAddr = _user;
                customer[_minerId].flag = false;
                customer[_minerId].customerEquity = _customerEquity;
                emit BuyGood(customer[_minerId].customerAddr,true,"Successful purchase of miner");
                return;         

            }else{

                emit BuyGood(customer[_minerId].customerAddr,false,"Insufficient balance, failed to purchase miner!!!");
                return;

            }

        }else{

            emit BuyGood(customer[_minerId].customerAddr,false,"The miner is not released");
            return;

        }

    }

  
    function activeMiner(string _minerId,address _user,bool _flag)public  onlyOwner{
     
            customer[_minerId].flag = _flag;
            activationMiner.push(_user);
            minerAmount.push(_minerId);
            emit ActiveMiner(_user,true,"Miner activated");
            return;

    }

    function getMiner() public view returns(address[]){
        
        return purchasedOfUser;

    }

    function getActiveMiner() public view returns(address[]){
        
        return activationMiner; 

    }

    function getPersonPower(address _user,string _minerId) public view returns(uint256){

        uint256 minerIdPower;
        if(customer[_minerId].customerAddr  == _user && customer[_minerId].flag  == true){

            minerIdPower += good[_minerId].power;
            return minerIdPower;

        }
         
    }

    function getPersonPPP(address user) public view returns(uint256){

        uint256 person;

        for(uint256 i = 0;i < minerAmount.length;i++){
           
           if( customer[minerAmount[i]].customerAddr == user ){

             person += good[minerAmount[i]].power;

           }

        }

        return person;

    }

    function getTotalPower() public view returns(uint256){

        uint256 allPower;
        for(uint256 i = 0;i < minerAmount.length;i++){
            uint256 pre = getPersonPower(customer[minerAmount[i]].customerAddr,minerAmount[i]);
            allPower += pre;
        }

        return allPower;

    }

    function minerReward(string _minerId)public onlyOwner {
            
        _transfer(owner,customer[_minerId].customerEquity,rew);
        emit Transfer(owner,customer[_minerId].customerEquity,rew);
                      
    }             
                          
}