pragma solidity ^0.4.4;

contract Token {

    /// @return 返回token的发行量
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner 查询以太坊地址token余额
    /// @return The balance 返回余额
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice msg.sender（交易发送者）发送 _value（一定数量）的 token 到 _to（接受者）  
    /// @param _to 接收者的地址
    /// @param _value 发送token的数量
    /// @return 是否成功
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice 发送者 发送 _value（一定数量）的 token 到 _to（接受者）  
    /// @param _from 发送者的地址
    /// @param _to 接收者的地址
    /// @param _value 发送的数量
    /// @return 是否成功
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice 发行方 批准 一个地址发送一定数量的token
    /// @param _spender 需要发送token的地址
    /// @param _value 发送token的数量
    /// @return 是否成功
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner 拥有token的地址
    /// @param _spender 可以发送token的地址
    /// @return 还允许发送的token的数量
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    /// 发送Token事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    /// 批准事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
