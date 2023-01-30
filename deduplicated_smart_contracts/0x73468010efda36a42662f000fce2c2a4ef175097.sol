/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

contract TokenERC20 {
    //令牌的公共变量
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    //十八位是强烈建议的默认值，避免更改它
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    //这将创建一个包含所有余额的数组
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    //这将在区块链上生成一个公共事件，该事件将通知客户端
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    //这将在区块链上生成一个公共事件，该事件将通知客户端
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    //这将通知客户烧毁的数量
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    /**
     * 构造函数
     * Constructor function
     *
     * 使用初始供应令牌初始化契约，以向契约的创建者提供令牌
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) 
    
    public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

    /**
     * 内部转账，只能按本合同调用
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        //防止传输到0x0地址。使用燃烧()
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        //检查寄件人是否有足够的钱
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        //检查溢出
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        //将其保存为将来的断言
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        //减去发送者
        // Subtract from the sender
        balanceOf[_from] -= _value;
        //向收件人添加相同的内容
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        //断言用于使用静态分析来发现代码中的bug。他们不应该失败
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * 传递令牌
     * Transfer tokens
     *
     * 将“_value”令牌从您的帐户发送到“_to”
     * Send `_value` tokens to `_to` from your account
     *
     * _to收件人的地址
     * @param _to The address of the recipient
     * 
     * _value发送的数量
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * 从其他地址转移令牌
     * Transfer tokens from other address
     *
     * 代表“_from”向“_to”发送“_value”令牌
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     *  _from发件人地址
     * @param _from The address of the sender
     * 
     *  _to收件人的地址
     * @param _to The address of the recipient
     * 
     *  _value发送的数量
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * 预留其他地址
     * Set allowance for other address
     * 
     * 允许“_spender”代表您花费不超过“_value”令牌
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * _spender授权使用的地址
     * @param _spender The address authorized to spend
     * 
     * _value他们可以花费的最大金额
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * 预留其他地址及通知
     * Set allowance for other address and notify 
     * 
     *允许“_spender”代表您花费不超过“_value”令牌，然后ping关于它的契约
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it 
     * 
     *_spender授权使用的地址
     * @param _spender The address authorized to spend
     * 
     * _value他们可以花费的最大金额
     * @param _value the max amount they can spend
     * 
     * _ata向批准的合同发送一些额外的信息
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
     * 摧毁令牌
     * Destroy tokens
     *
     * 不可逆地从系统中删除' _value '令牌
     * Remove `_value` tokens from the system irreversibly
     *
     *  _value要烧的钱的数量
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * 销毁来自其他帐户的令牌
     * Destroy tokens from other account
     *
     *代表“_from”不可逆地从系统中删除“_value”令牌。
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     *  _from发件人地址
     * @param _from the address of the sender
     * 
     * _value要烧的钱的数量
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}