/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

/**
 *Submitted for verification at Etherscan.io on 2020-04-21
*/

/**
 *Submitted for verification at Etherscan.io on 2020-04-16
*/

pragma solidity ^0.4.26;

contract ERC20Interface {
    // token总量，默认会为public变量生成一个getter函数接口，名称为totalSupply().
    function totalSupply() public constant returns (uint);
    //获取账tokenOwner拥有token的数量 
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    //从消息发送者账户中往_to账户转数量为_value的token（就是从创建合约账户往to账户转数量tokens的token）
    function transfer(address to, uint tokens) public returns (bool success);
    //消息发送账户设置账户spender能从发送账户中转出数量为tokens的token
    function approve(address spender, uint tokens) public returns (bool success);
    //从账户from中往账户to转数量为tokens的token，与approve方法配合使用
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    //获取账户_spender可以从账户_owner中转出token的数量
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event ReportFormEvent(address indexed spender,string content);
}

contract Ownable {
  address public owner;  
  
  mapping (address => bool) public finances;
  
  event addFinanceEvent(address indexed newFinance, bool success);
  event delFinanceEvent(address indexed newFinance, bool success);
  
   /**
   * @dev 构造函数将合同的原始所有者设置为发送方
   */
  constructor() public payable {
    owner = msg.sender;
    finances[msg.sender] = true;
  }
  
  /**
   * @dev 如果被除所有者之外的任何帐户调用，则抛出。
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
      
    modifier onlyFinance() {
        require(finances[msg.sender] == true);
        _;
    }
  
    /**
    * @dev 允许当前所有者将合同的控制权转移给新所有者。
    * @param newOwner 将所有权转移到的地址.
    */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        owner = newOwner;
    }
  
  
    function addFinance(address newFinance) onlyOwner public returns (bool success){
        require(newFinance != address(0));
        require(finances[newFinance] != true);
        
        finances[newFinance] = true;
        
        bool isSuccess = finances[newFinance];
        emit addFinanceEvent(newFinance, isSuccess);
        return isSuccess;
    }
    
    function delFinance(address finance) onlyOwner public returns (bool success){
        require(finance != address(0));
        require(finances[finance] == true);
        
        delete finances[finance];
        emit delFinanceEvent(finance, finances[finance]);
        return true;
    }
}


contract MDACXToken is ERC20Interface, Ownable {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;


  mapping (address => uint256) public balanceOf;

  mapping (address => mapping (address => uint256)) public allowanceOf;

   constructor(string _tokenName,string _tokenSymbol,uint8 _tokenDecimals,uint256 _tokenTotalSupply) public payable {
      name = _tokenName;// token名称
      symbol = _tokenSymbol;// token简称
      decimals = _tokenDecimals;// 小数位数
      totalSupply = _tokenTotalSupply * 10 ** uint256(decimals);// 设置初始总量
      balanceOf[msg.sender] = totalSupply;// 初始token数量给予消息发送者
   }
   
    function _transfer(address _from, address _to, uint _value) internal {
       require(_to != 0x0);
       require(balanceOf[_from] >= _value);
       require(balanceOf[_to] + _value > balanceOf[_to]);
       uint previousBalances = balanceOf[_from] + balanceOf[_to];
       balanceOf[_from] -= _value;
       balanceOf[_to] += _value;
       assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
       emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
       _transfer(msg.sender, _to, _value);
       return true;
    }

    function financeReportForm(string content) public onlyFinance returns (bool success) {
       emit ReportFormEvent(msg.sender, content);
       return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       require(allowanceOf[_from][msg.sender] >= _value);
       allowanceOf[_from][msg.sender] -= _value;
       _transfer(_from, _to, _value);
       return true;
   }

    function approve(address _spender, uint256 _value) public returns (bool success) {
       allowanceOf[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);
       return true;
   }

   function allowance(address _owner, address _spender) view public returns (uint remaining){
     return allowanceOf[_owner][_spender];
   }

  function totalSupply() public constant returns (uint totalsupply){
      return totalSupply;
  }

  function balanceOf(address tokenOwner) public constant returns(uint balance){
      return balanceOf[tokenOwner];
  }
}