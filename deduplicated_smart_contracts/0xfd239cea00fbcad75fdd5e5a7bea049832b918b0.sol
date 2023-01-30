/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity 0.5.14;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract ERC20 {
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function transfer(address to, uint256 value) public returns(bool);
    function allowance(address owner, address spender) public view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Etoken is ERC20 {
    
    using SafeMath for uint256;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public burnAddress;
    address public owner;
    address public sigAddress;
    address public etokenLink;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    

    constructor (address _burnAddress, address _sigAddress) public {
        symbol = "Etoken";
        name = "Etoken link";
        decimals = 3;
        burnAddress = _burnAddress;
        owner = msg.sender;
        sigAddress = _sigAddress;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    /**
     * @dev Check balance of the holder
     * @param _owner Token holder address
     */ 
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
     * @dev Transfer token to specified address
     * @param _to Receiver address
     * @param _value Amount of the tokens
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_value <= balances[msg.sender], "Insufficient balance");
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        uint256 burnFee = (_value.mul(0.1 ether)).div(10**20);
        uint256 balanceFee = _value.sub(burnFee);
        balances[burnAddress] = balances[burnAddress].add(burnFee);
        balances[_to] = balances[_to].add(balanceFee);
        
        emit Transfer(msg.sender, _to, balanceFee);
        emit Transfer(msg.sender, burnAddress, burnFee);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from  The holder address
     * @param _to  The Receiver address
     * @param _value  the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_from != address(0), "Invalid from address");
        require(_to != address(0), "Invalid to address");
        require(_value <= balances[_from], "Invalid balance");
        require(_value <= allowed[_from][msg.sender], "Invalid allowance");
        
        balances[_from] = balances[_from].sub(_value);
        uint256 burnFee = (_value.mul(0.1 ether)).div(10**20);
        uint256 balanceFee = _value.sub(burnFee);
        balances[burnAddress] = balances[burnAddress].add(burnFee);
        balances[msg.sender] = balances[msg.sender].add(balanceFee);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        
        emit Transfer(_from, _to, balanceFee);
        emit Transfer(_from, burnAddress, burnFee);
        return true;
    }
    
    /**
     * @dev Approve respective tokens for spender
     * @param _spender Spender address
     * @param _value Amount of tokens to be allowed
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Null address");
        require(_value > 0, "Invalid value");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev To view approved balance
     * @param _owner Holder address
     * @param _spender Spender address
     */ 
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }  
    
    /**
     * @dev To change Owner Address
     * @param _newOwner New owner address
     */ 
    function changeOwnerAddress(address _newOwner) public onlyOwner returns(bool) {
        require(_newOwner != address(0), "Invalid Address");
        owner = _newOwner;
        return true;
    }  
    
    /**
     * @dev To change burn Address
     * @param _newBurn New burn address
     */ 
    function changeBurnAddress(address _newBurn) public onlyOwner returns(bool) {
        require(_newBurn != address(0), "Invalid Address");
        burnAddress = _newBurn;
        return true;
    }
    
    /**
     * @dev To change signature Address
     * @param _newSigAddress New sigOwner address
     */ 
    function changeSigAddress(address _newSigAddress) public onlyOwner returns(bool) {
        require(_newSigAddress != address(0), "Invalid Address");
        sigAddress = _newSigAddress;
        return true;
    }
    
    /**
     * @dev To change etokenlink Address
     * @param _newEtokenLink New etokenlink address
     */ 
    function changeEtokenLink(address _newEtokenLink) public onlyOwner returns(bool) {
        require(_newEtokenLink != address(0), "Invalid Address");
        etokenLink = _newEtokenLink;
        return true;
    }
    
    /**
     * @dev To mint EToken from etokenlink
     * @param _receiver Reciever address
     * @param _amount Amount to mint
     * @param _mrs _mrs[0] - message hash _mrs[1] - r of signature _mrs[2] - s of signature 
     * @param _v  v of signature
     */ 
    function mint(address _receiver, uint256 _amount,bytes32[3] memory _mrs, uint8 _v) public returns (bool) {
        require(_receiver != address(0), "Invalid address");
        require(msg.sender == etokenLink, "only From etokenlink Contract");
        require(_amount >= 0, "Invalid amount");
        require(ecrecover(_mrs[0], _v, _mrs[1], _mrs[2]) == sigAddress, "Invalid Signature");
        totalSupply = totalSupply.add(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(address(0), _receiver, _amount);
        return true;
    }
    
    /**
     * @dev To mint EToken by admin
     * @param _receiver Reciever address
     * @param _amount Amount to mint
     */ 
    function ownerMint(address _receiver, uint256 _amount) public onlyOwner returns (bool) {
        require(_receiver != address(0), "Invalid address");
        require(_amount >= 0, "Invalid amount");
        totalSupply = totalSupply.add(_amount);
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(address(0), _receiver, _amount);
        return true;
    }
}