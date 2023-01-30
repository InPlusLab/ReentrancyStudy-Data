/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity ^0.5.10;

contract FiatContract {
  function USD(uint _id) public view returns (uint256);
  function updatedAt(uint _id) public view returns (uint);
}

contract MacQueen {

    bool private initialized = false;
    bool private manualPurchase = false;
    FiatContract private price;

    mapping(address => uint256) internal balances;
    
    uint256 internal totalSupply_;
    string public constant name = "MacQueen Token O"; 
    string public constant symbol = "MQSO"; 
    uint8 public constant decimals = 18;
    uint256 public TokenPrice = 9000000;
    uint256 public tokenSold;

    mapping (address => mapping (address => uint256)) internal allowed;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Purchase(address indexed user, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    event SupplyIncreased(address indexed to, uint256 value);
    event SupplyDecreased(address indexed from, uint256 value);
    
    constructor () public {
        require(!initialized, "already initialized");
        owner = msg.sender;
        totalSupply_ =  100000e18;
        balances[owner] = totalSupply_;
        initialized = true;
        price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
 
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "cannot transfer to address zero");
        require(_value <= balances[msg.sender], "insufficient funds");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _addr) public view returns (uint256) {
        return balances[_addr];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "cannot transfer to address zero");
        require(_value <= balances[_from], "insufficient funds");
        require(_value <= allowed[_from][msg.sender], "insufficient allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }
    
    
    function setPrice(uint256 _price) onlyOwner public returns(bool success){
        TokenPrice =  _price;
        return true;
    }
    
    function getEthPrice() public view returns(uint256){
        uint256 USDcent = price.USD(0);
        return USDcent * 100;
    }

    function purchase(address _to, uint256 _value, uint256 _ethValue) public payable returns (bool success) {
        require(_ethValue == msg.value);
        uint256 ethCent = price.USD(0);
        uint256 priceInEth = (ethCent  * TokenPrice) / 1000000;
        uint256 totalPayableAmt = priceInEth * (_value / 1e18);
        require(totalPayableAmt <= msg.value);
        _mint(_value);
        require(balances[owner] >= _value);
        balances[owner] -= _value;
        balances[_to] += _value;
        tokenSold += _value;
        emit Purchase(_to, _value); 
        return true;
    }

    function purchaseToken(address _to, uint256 _value, uint256 _ethValue) public payable returns (bool success) {
        require(manualPurchase == true);
        require(_ethValue == msg.value);
        _mint(_value);
        require(balances[owner] >= _value);
        balances[owner] -= _value;
        balances[_to] += _value;
        tokenSold += _value;
        emit Purchase(_to, _value);  
        return true;
    }
    

    function transfertoAll(address [] memory recievers,uint256 [] memory values) public onlyOwner returns(uint256 ){
        uint256 totalTransferAmmount=0;
        for(uint256 iCount = 0; iCount <= values.length-1; iCount++){
            totalTransferAmmount = totalTransferAmmount + values[iCount];
        }
        _mint(totalTransferAmmount);
        require(balances[owner] >= totalTransferAmmount);
        require(values.length == recievers.length,
        "please confirm addresses and values are equal");
        for(uint256 iCount1 = 0; iCount1 <= recievers.length-1; iCount1++){
            balances[owner] -= values[iCount1];
            balances[recievers[iCount1]] += values[iCount1];
            tokenSold += values[iCount1];
            emit Purchase(recievers[iCount1], values[iCount1]);
        }
        return totalTransferAmmount;
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }


    function withdraw(uint amount) public onlyOwner returns(bool) {
        require(amount <= address(this).balance);
        msg.sender.transfer(amount);
        return true;
    }
    
    function _mint(uint256 _value) internal returns(bool success){
        totalSupply_ += _value;
        balances[owner] += _value;
        emit SupplyIncreased(owner, _value);
        return true;
    }

    function increaseSupply(uint256 _value) public onlyOwner returns (bool success) {
        totalSupply_ += _value;
        balances[owner] += _value;
        emit SupplyIncreased(owner, _value);
        return true;
    }


    function decreaseSupply(uint256 _value) public onlyOwner returns (bool success) {
        require(_value <= balances[owner], "not enough supply");
        balances[owner] -= _value;
        totalSupply_ -= _value;
        emit SupplyDecreased(owner, _value);
        return true;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner returns(bool success) {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
        return true;
    }
    
    function startManualPurchase() public onlyOwner returns(bool success){
        manualPurchase = true;
        return true;
    }
    
    function setOracleContract(address _contract) public onlyOwner returns(bool success){
        price = FiatContract(_contract);
        return true;
    }
}