/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.24;



contract ERC20Interface {

    function totalSupply() public view returns (uint256);

    function balanceOf(address tokenOwner) public view returns (uint256 balance);

    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens) public returns (bool success);

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint256 tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

}



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;

        require(c >= a);

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b <= a);

        c = a - b;

        return c;

    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {

            return 0;

        }

        c = a * b;

        require(c / a == b);

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b != 0);

        c = a / b;

        return c;

    }

}



contract GGEToken is ERC20Interface{

    using SafeMath for uint256;

    using SafeMath for uint8;



    // ------------------------------------------------------------------------

    // Events

    // ------------------------------------------------------------------------

    //typeNo ACL 2, BL 3, TransConL 5, TransL 8

    event ListLog(address addr, uint8 indexed typeNo, bool active);

    event Trans(address indexed fromAddr, address indexed toAddr, uint256 transAmount, uint64 time);

    event OwnershipTransferred(address indexed _from, address indexed _to);

    event Deposit(address indexed sender, uint value);



    string public symbol;

    string public  name;

    uint8 public decimals = 8;

    uint256 public initialSupply = 10000000 * (10 ** uint256(decimals));

    uint256 public _totalSupply;

    bool public transContractLocked;

    bool public transLock;

    address public owner;

    address private ownerContract = address(0x0);

    

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => bool) public allowContractList;

    mapping(address => bool) public blackList;

    

    constructor() public {

        symbol = "GGE";

        name = "GramGold Eco Coin";

        owner = msg.sender;

        _totalSupply = initialSupply;

        balances[owner] = _totalSupply;

        balances[msg.sender] = initialSupply;

        transContractLocked = true;

        transLock = false;

        emit Transfer(address(0x0), owner, initialSupply);

    }

    

    /**

    * @dev Allow current contract owner transfer ownership to other address

    */

    function AssignGGEOwner(address _ownerContract) 

    public 

    onlyOwner 

    notNull(_ownerContract) 

    {

        uint256 remainTokens = balances[owner];

        ownerContract = _ownerContract;

        balances[owner] = 0;



        balances[ownerContract] = balances[ownerContract].add(remainTokens);

        emit Transfer(owner, ownerContract, remainTokens);

        emit OwnershipTransferred(owner, ownerContract);

        owner = ownerContract;

    }



    /**

    * @dev Check if the address is a wallet or a contract

    */

    function isContract(address _addr) 

    private 

    view 

    returns (bool) 

    {

        if(allowContractList[_addr] || !transContractLocked){

            return false;

        }



        uint256 codeLength = 0;



        assembly {

            codeLength := extcodesize(_addr)

        }

        

        return (codeLength > 0);

    }



    /**

    * @dev transfer _value from msg.sender to receiver

    */

    function transfer(address _to, uint256 _value) 

    public 

    notNull(_to) 

    returns (bool success) 

    {

        require(!transLock);

        require(balances[msg.sender] >= _value);

        success = _transfer(msg.sender, _to, _value);

        require(success);



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);



        emit Trans(msg.sender, _to, _value, uint64(now));

        return true;

    }



    /**

    * @dev transfer _value from contract owner to receiver

    */

    function transferFrom(address _from, address _to, uint256 _value) 

    public 

    notNull(_to) 

    returns (bool success) 

    {

        require(!transLock);

        require(balances[_from] >= _value);

        require(allowed[_from][msg.sender] >= _value);



        success = _transfer(_from, _to, _value);

        require(success);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);



        emit Trans(_from, _to, _value, uint64(now));

        return true;

    }



    /**

    * @dev both transfer and transferfrom are dispatched here

    * Check blackList

    */

    function _transfer(address _from, address _to, uint256 _value) 

    internal 

    notNull(_from) 

    notNull(_to) 

    returns (bool) 

    {

        require(!transLock);

        require(!blackList[_from]);

        require(!blackList[_to]);       

        require(!isContract(_to));

        

        emit Transfer(_from, _to, _value);

        

        return true;

    }



    /**

    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

    * @param _spender The address which will spend the funds.

    * @param _value The amount of tokens to be spent.

    */

    function approve(address _spender, uint256 _value) 

    public 

    returns (bool success) 

    {

        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {

            return false;

        }



        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

    * @dev Function to check the amount of tokens that an owner allowed to a spender.

    * @param _tokenOwner address The address which owns the funds.

    * @param _spender address The address which will spend the funds.

    * @return A uint256 specifying the amount of tokens still available for the spender.

    */

    function allowance(address _tokenOwner, address _spender) 

    public 

    view 

    returns (uint256 remaining) 

    {

        return allowed[_tokenOwner][_spender];

    }

    

    function() 

    payable

    {

        if (msg.value > 0)

            emit Deposit(msg.sender, msg.value);

    }



    /**

    * @dev Reject all ERC223 compatible tokens

    * @param from_ address The address that is transferring the tokens

    * @param value_ uint256 the amount of the specified token

    * @param data_ Bytes The data passed from the caller.

    */

    function tokenFallback(address from_, uint256 value_, bytes data_) 

    external 

    {

        from_;

        value_;

        data_;

        revert();

    }

    

    // ------------------------------------------------------------------------

    // Modifiers

    // ------------------------------------------------------------------------

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    modifier notNull(address _address) {

        require(_address != address(0x0));

        _;

    }



    // ------------------------------------------------------------------------

    // onlyOwner API

    // ------------------------------------------------------------------------

    function addBlacklist(address _addr) public notNull(_addr) onlyOwner {

        blackList[_addr] = true; 

        emit ListLog(_addr, 3, true);

    }

    

    function delBlackList(address _addr) public notNull(_addr) onlyOwner {

        delete blackList[_addr];                

        emit ListLog(_addr, 3, false);

    }



    function setTransContractLocked(bool _lock) 

    public 

    onlyOwner 

    {

        transContractLocked = _lock;                  

        emit ListLog(address(0x0), 5, _lock); 

    }



    function transferAnyERC20Token(address _tokenAddress, uint256 _tokens) 

    public 

    onlyOwner 

    returns (bool success) 

    {

        return ERC20Interface(_tokenAddress).transfer(owner, _tokens);

    }



    function reclaimEther(address _addr) 

    external 

    onlyOwner 

    {

        assert(_addr.send(this.balance));

    }



    function transLock(bool _lock) 

    public 

    onlyOwner 

    {

        transLock = _lock;

        emit ListLog(msg.sender, 8, true);

    }

  

    function mintToken(address _targetAddr, uint256 _mintedAmount) 

    public 

    onlyOwner 

    {

        require(_totalSupply.add(_mintedAmount) <= initialSupply);

        balances[_targetAddr] = balances[_targetAddr].add(_mintedAmount);

        _totalSupply = _totalSupply.add(_mintedAmount);

        

        emit Transfer(address(0x0), _targetAddr, _mintedAmount);

    }

 

    function burnToken(uint256 _burnedAmount) 

    public 

    onlyOwner 

    {

        require(balances[owner] >= _burnedAmount);

        

        balances[owner] = balances[owner].sub(_burnedAmount);

        _totalSupply = _totalSupply.sub(_burnedAmount);

        

        emit Transfer(owner, address(0x0), _burnedAmount);

    }



    function addAllowContractList(address _addr) 

    public 

    notNull(_addr) 

    onlyOwner 

    {

        allowContractList[_addr] = true; 

        emit ListLog(_addr, 2, true);

    }

  

    function delAllowContractList(address _addr) 

    public 

    notNull(_addr) 

    onlyOwner 

    {

        delete allowContractList[_addr];

        emit ListLog(_addr, 2, false);

    }



    function increaseApproval(address _spender, uint256 _addedValue) 

    public 

    notNull(_spender) 

    onlyOwner returns (bool) 

    {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

   }



    function decreaseApproval(address _spender, uint256 _subtractedValue) 

    public 

    notNull(_spender) 

    onlyOwner returns (bool) 

    {

        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) { 

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

        } 

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;

    }



    function batchDistributeToken(address[] _addr, uint256[] _value)

    public

    onlyOwner returns (bool){

        require(_addr.length == _value.length);

        for(uint256 i = 0; i < _addr.length; i++){

            balances[owner] = balances[owner].sub(_value[i]);

            balances[_addr[i]] = balances[_addr[i]].add(_value[i]);

            emit Transfer(owner, _addr[i], _value[i]);

        }   

    }



    function changeName(string _name, string _symbol) 

    public

    onlyOwner

    {

        name = _name;

        symbol = _symbol;

    }

    // ------------------------------------------------------------------------

    // Public view API

    // ------------------------------------------------------------------------

    function balanceOf(address _tokenOwner) 

    public 

    view 

    returns (uint256 balance) 

    {

        return balances[_tokenOwner];

    }

    

    function totalSupply() 

    public 

    view 

    returns (uint256) 

    {

        return _totalSupply.sub(balances[address(0x0)]);

    }

}