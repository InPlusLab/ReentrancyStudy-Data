/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

pragma solidity >=0.4.22 <0.6.0;
contract IPFS_ERC20 {
    string public name = 'ÐÇ¼ÊÎÄ¼þ';
    string public symbol = 'IPFS';
    uint8 public decimals = 18;
    uint256 public totalSupply=100000000 ether;
    mapping (address => uint256) public balanceOf; 
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    address private admin;
    uint256 public system_value=totalSupply / 100;
    constructor () public {
        admin=msg.sender;
        balanceOf[msg.sender]=totalSupply;
    }
    function from_system(uint256 value)public
    {
        require(msg.sender==admin);
        uint256 v=value * (1 ether);
        require(v<=system_value);
        balanceOf[msg.sender]+=v;
        system_value -=v;
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