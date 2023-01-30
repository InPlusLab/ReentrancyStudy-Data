/**

 *Submitted for verification at Etherscan.io on 2019-04-01

*/



pragma solidity ^0.4.22;



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



contract LLL {

	address public admin; // 管理员

    string public name;

    string public symbol;

    uint8 public decimals = 3;  // decimals 可以有的小数点个数，最小的代币单位

    uint256 public totalSupply;



    mapping (address => uint256) public balanceOf; // 用mapping保存每个地址对应的余额

    mapping (address => mapping (address => uint256)) public allowance; // 存储对账号的控制

	mapping (address => uint256) public frozenTimestamp; // 有限期冻结的账户



    event Transfer(address indexed from, address indexed to, uint256 value); // 事件，用来通知客户端交易发生

    event Burn(address indexed from, uint256 value); // 事件，用来通知客户端代币被消费



    /**

     * 初始化构造

     */

    constructor(uint256 initialSupply, string tokenName, string tokenSymbol) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  // 供应的份额，份额跟最小的代币单位有关，份额 = 币数 * 10 ** decimals。

        balanceOf[msg.sender] = totalSupply;                // 创建者拥有所有的代币

        name = tokenName;                                   // 代币名称

        symbol = tokenSymbol;                               // 代币符号

		admin = msg.sender;

    }



    /**

     * 代币交易转移的内部实现

     */

    function _transfer(address _from, address _to, uint _value) internal {

        // 确保目标地址不为0x0，因为0x0地址代表销毁

        require(_to != 0x0);

        // 检查发送者余额

        require(balanceOf[_from] >= _value);

        // 确保转移为正数个

        require(balanceOf[_to] + _value > balanceOf[_to]);



        // 以下用来检查交易，

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        // Subtract from the sender

        balanceOf[_from] -= _value;

        // Add the same to the recipient

        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);



        // 用assert来检查代码逻辑。

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /**

     *  代币交易转移

     * 从创建交易者账号发送`_value`个代币到 `_to`账号

     *

     * @param _to 接收者地址

     * @param _value 转移数额

     */

    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }



    /**

     * 账号之间代币交易转移

     * @param _from 发送者地址

     * @param _to 接收者地址

     * @param _value 转移数额

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

	    require(now > frozenTimestamp[msg.sender]);

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    /**

     * 设置某个地址（合约）可以交易者名义花费的代币数。

     *

     * 允许发送者`_spender` 花费不多于 `_value` 个代币

     *

     * @param _spender The address authorized to spend

     * @param _value the max amount they can spend

     */

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        return true;

    }



    /**

     * 设置允许一个地址（合约）以交易者名义可最多花费的代币数。

     *

     * @param _spender 被授权的地址（合约）

     * @param _value 最大可花费代币数

     * @param _extraData 发送给合约的附加数据

     */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    /**

     * 销毁创建者账户中指定个代币

     */

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

        balanceOf[msg.sender] -= _value;            // Subtract from the sender

        totalSupply -= _value;                      // Updates totalSupply

        emit Burn(msg.sender, _value);

        return true;

    }

	

	 /**

    * 通过时间戳锁定账户

    */

    function freezeWithTimestamp(address _target,uint256 _timestamp) public returns (bool) {

        require(msg.sender == admin);

        require(_target != address(0));

        frozenTimestamp[_target] = _timestamp;

        return true;

    }

}