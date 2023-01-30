/**
 *Submitted for verification at Etherscan.io on 2020-07-19
*/

pragma solidity >=0.4.22 <0.6.0;
contract UBS_ERC20 {
    string public name = 'UBS flgures(ÈðÒøÊý×Ö)';
    string public symbol = 'UBS';
    uint8 public decimals = 18;
    uint256 public totalSupply=30000000 ether;
    mapping (address => uint256) public balanceOf; 
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor () public {
        balanceOf[msg.sender]=5000000 ether;
        balanceOf[0x4943b3996Bba5446C5F1770Ea456413303d6d607]=25000000 ether;
    }
    function _transfer(address _from, address _to, uint _value) internal {

        require(_to !=address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to]; 
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value); 
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value); 
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); 
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value; 
        return true;
    }
}