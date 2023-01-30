/**

 *Submitted for verification at Etherscan.io on 2019-01-29

*/



pragma solidity ^0.4.25;



// ----------------------------------------------------------------------------------------------

// Sample fixed supply token contract

// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.

// ----------------------------------------------------------------------------------------------



// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/issues/20

contract ERC20Interface {



    uint256 public totalSupply;

    // 获取其他地址的余额

    function balanceOf(address _owner) public view returns (uint256 balance);



    // 向其他地址发送token

    function transfer(address _to, uint256 _value) public returns (bool success);



    // 从一个地址想另一个地址发送余额

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    //允许_spender从你的账户转出_value的余额，调用多次会覆盖可用量。某些DEX功能需要此功能

    function approve(address _spender, uint256 _value) public returns (bool success);



    // 返回_spender仍然允许从_owner退出的余额数量

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);



    // token转移完成后出发

    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    // approve(address _spender, uint256 _value)调用后触发

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



//继承接口后的实例

contract PDAToken is ERC20Interface {



    string public name = "Parking Digital Alliance Token";                   //名称，例如"My test token"

    uint8 public decimals = 18;               //返回token使用的小数点后几位。比如如果设置为3，就是支持0.001表示.

    string public symbol = "PDAT";               //token简称,like MTT

    //发行量

    uint private initAmount = 134000000;



    // 智能合约的所有者

    address public owner;



    // 每个账户的余额

    mapping(address => uint256) balances;



    // 帐户的所有者批准将金额转入另一个帐户。从上面的说明我们可以得知allowed[被转移的账户][转移钱的账户]

    mapping(address => mapping(address => uint256)) allowed;







    // 构造函数

    constructor() public {



        totalSupply = initAmount * 10 ** uint256(decimals);

        // 设置初始总量

        balances[msg.sender] = totalSupply;



    }





    // 特定账户的余额

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }



    // 转移余额到其他账户

    function transfer(address _to, uint256 _value) public returns (bool success) {

        //默认totalSupply 不会超过最大值 (2^256 - 1).

        //如果随着时间的推移将会有新的token生成，则可以用下面这句避免溢出的异常

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(_to != address (0x0));

        balances[msg.sender] -= _value;

        //从消息发送者账户中减去token数量_value

        balances[_to] += _value;

        //往接收账户增加token数量_value

        emit Transfer(msg.sender, _to, _value);

        //触发转币交易事件

        return true;

    }





    //从一个账户转移到另一个账户，前提是需要有允许转移的余额

    function transferFrom(address _from, address _to, uint256 _value) public returns

    (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;

        //接收账户增加token数量_value

        balances[_from] -= _value;

        //支出账户_from减去token数量_value

        allowed[_from][msg.sender] -= _value;

        //消息发送者可以从账户_from中转出的数量减少_value

        emit Transfer(_from, _to, _value);

        //触发转币交易事件

        return true;

    }





    //允许账户从当前用户转移余额到那个账户，多次调用会覆盖

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        allowed[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);

        return true;

    }





    //返回被允许转移的余额数量

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

}