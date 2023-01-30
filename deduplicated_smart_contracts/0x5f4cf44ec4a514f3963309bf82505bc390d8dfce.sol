/**
 *Submitted for verification at Etherscan.io on 2019-09-23
*/

pragma solidity >=0.4.24;
contract LUKTokenStore {
    /** 精度，推荐是 8 */
    uint8 public decimals = 8;
    /** 代币总量 */
    uint256 public totalSupply;
    /** 查看某一地址代币余额 */
    mapping (address => uint256) private tokenAmount;
    /** 代币交易代理人授权列表 */
    mapping (address => mapping (address => uint256)) private allowanceMapping;
    //合约所有者
    address private owner;
    //写授权
    mapping (address => bool) private authorization;
    
    /**
     * Constructor function
     * 
     * 初始合约
     * @param initialSupply 代币总量
     */
    constructor (uint256 initialSupply) public {
        //** 是幂运算
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        tokenAmount[msg.sender] = totalSupply;                // Give the creator all initial tokens
        owner = msg.sender;
    }
    
    //定义函数修饰符，判断消息发送者是否是合约所有者
    modifier onlyOwner() {
        require(msg.sender == owner,"Illegal operation.");
        _;
    }
    
    modifier checkWrite() {
        require(authorization[msg.sender] == true,"Illegal operation.");
        _;
    }
    
    //写授权，合约调用合约时调用者为父合约地址
    function writeGrant(address _address) public onlyOwner {
        authorization[_address] = true;
    }
    function writeRevoke(address _address) public onlyOwner {
        authorization[_address] = false;
    }
    
    /**
     * 设置代币消费代理人，代理人可以在最大可使用金额内消费代币
     *
     * @param _from 资金所有者地址
     * @param _spender 代理人地址
     * @param _value 最大可使用金额
     */
    function approve(address _from,address _spender, uint256 _value) public checkWrite returns (bool) {
        allowanceMapping[_from][_spender] = _value;
        return true;
    }
    
    function allowance(address _from, address _spender) public view returns (uint256) {
        return allowanceMapping[_from][_spender];
    }
    
    /**
     * Internal transfer, only can be called by this contract
     */
    function transfer(address _from, address _to, uint256 _value) public checkWrite returns (bool) {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0),"Invalid address");
        // Check if the sender has enough
        require(tokenAmount[_from] >= _value,"Not enough balance.");
        // Check for overflows
        require(tokenAmount[_to] + _value > tokenAmount[_to],"Target account cannot be received.");

        // 转账
        // Subtract from the sender
        tokenAmount[_from] -= _value;
        // Add the same to the recipient
        tokenAmount[_to] += _value;

        return true;
    }
    
    function transferFrom(address _from,address _spender, address _to, uint256 _value) public checkWrite returns (bool) {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_from != address(0x0),"Invalid address");
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0),"Invalid address");
        
        // Check if the sender has enough
        require(allowanceMapping[_from][_spender] >= _value,"Insufficient credit limit.");
        // Check if the sender has enough
        require(tokenAmount[_from] >= _value,"Not enough balance.");
        // Check for overflows
        require(tokenAmount[_to] + _value > tokenAmount[_to],"Target account cannot be received.");
        
        // 转账
        // Subtract from the sender
        tokenAmount[_from] -= _value;
        // Add the same to the recipient
        tokenAmount[_to] += _value;
        
        allowanceMapping[_from][_spender] -= _value; 
    }
    
    function balanceOf(address _owner) public view returns (uint256){
        require(_owner != address(0x0),"Address can't is zero.");
        return tokenAmount[_owner] ;
    }
}