/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity ^0.4.19;
contract BaseToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}
contract CustomToken is BaseToken {
    constructor() public {
        totalSupply =300000000000000000000000000;
        name = '�������о��ֲ�֤ͨ(Global Travel Club Token)';
        symbol = 'GTCT';
        decimals = 18;
        balanceOf[0x63D5AE37c8DBd87a667053B42EFeb6b065cfdbC7] = totalSupply;
        emit Transfer(address(0),0x63D5AE37c8DBd87a667053B42EFeb6b065cfdbC7, totalSupply);
    }

}