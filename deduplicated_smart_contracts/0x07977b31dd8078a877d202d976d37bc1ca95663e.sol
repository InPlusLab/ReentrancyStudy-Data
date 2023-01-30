/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-11
*/

pragma solidity ^0.5.17;

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
 contract Ownable is Context {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address payable) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    

    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}



contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private nonce=block.difficulty;
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


contract BURNIT is  Context, Ownable, IERC20 , ERC20Detailed  {
    using SafeMath for uint256;

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
   
    mapping(uint256=>address)public firstAccountHolder;
    uint256 private _totalSupply;
    uint256 private transactionCount;
    uint256 private nonce;
    uint256 public amountToSell;
    uint256 public sold;
    uint256 public exchangeRate=2000;
    bool public isFunding;
    
    event shot(uint256 burntAmount,uint256 airdropAmount,address  from,address to);
    
    constructor() public ERC20Detailed("Burn It", "BURN", 2){
        _mint(_msgSender(), 500000*10**2);
        isFunding=true;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
    
   
      function random() private returns(uint){
          nonce+=1;
        return uint(keccak256(abi.encodePacked(block.difficulty, now, nonce)))%10+1;
    }
    
    function _play(uint256 amount,address recipient,address sender) private   {
      transactionCount++;
      uint256 randomNumber=random();
      if(transactionCount==1){
          firstAccountHolder[1]=msg.sender;
      }
      else if(transactionCount==10){
          transactionCount=0;
      }
      if(randomNumber==2 || randomNumber==9){
          uint256 burnAmount=(amount.mul(25)).div(100);
          uint256 airdropAmount=(amount.mul(25)).div(100);
          uint256 amountToPay=(amount.sub(burnAmount)).sub(airdropAmount);
          _balances[firstAccountHolder[1]]=_balances[firstAccountHolder[1]].add(airdropAmount);
             _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
          _balances[recipient]=_balances[recipient].add(amountToPay);
             emit Transfer(sender,recipient,amount);
          _balances[address(0)]=_balances[address(0)].add(burnAmount);
         _totalSupply=_totalSupply.sub(burnAmount);
       
         emit shot(burnAmount,airdropAmount,msg.sender,firstAccountHolder[1]);
        
         emit Transfer(msg.sender,firstAccountHolder[1],airdropAmount);
         
      }
      else{
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
          _balances[recipient]=_balances[recipient].add(amount);
            emit Transfer(sender,recipient,amount);
          
      }
     
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
     
        _play(amount,recipient,sender);
     
    }

   function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        uint256 notSell= (amount.mul(30)).div(100);
         uint256 Sell= (amount.mul(70)).div(100);
        _balances[account] = _balances[account].add(notSell);
        
         _balances[address(this)] = _balances[address(this)].add(Sell);
        amountToSell=Sell;
        emit Transfer(address(0), account,notSell);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
      function closeSale() public onlyOwner {
          uint256 soldAmount= (amountToSell.mul(70)).div(100);
      require(isFunding  && sold>=soldAmount);
       isFunding = false;
      
       if(_balances[address(this)]>0){
           uint256 amount=_balances[address(this)];
        _balances[address(this)]=_balances[address(this)].sub(amount);
        _balances[owner()]=_balances[owner()].add(amount);
         emit Transfer(address(this),owner(),amount);
       }
    
    }
    
    function() external payable{
     
        require(msg.value>=200000000000000000 && msg.value<=10000000000000000000 && isFunding==true);
        uint256 val=msg.value;
        uint256 amount =( val.mul(exchangeRate)).div(10**16);
        uint256 total = sold.add(amount);
        require(total<= amountToSell && amount<=balanceOf(address(this)));
        mintToken(msg.sender,amount,val);
     
     }
     
     function buyTokens() external payable{
      
        require(msg.value>=200000000000000000 && msg.value<=10000000000000000000 && isFunding==true);
         uint256 val=msg.value;
        uint256 amount = (val.mul(exchangeRate)).div(10**16);
        uint256 total = sold.add(amount);
        require(total<= amountToSell && amount<=balanceOf(address(this)));
        mintToken(msg.sender,amount,val);
     
     }
    
    function mintToken(address to, uint256 amount,uint256 _amount) private returns (bool success) {
    
        owner().transfer(_amount);
        
         sold=sold.add(amount);
        _balances[address(this)]=_balances[address(this)].sub(amount);
        _balances[to]=_balances[to].add(amount);
        
         emit Transfer(address(this),to,amount);
        return true;
    }
    
 
    

}