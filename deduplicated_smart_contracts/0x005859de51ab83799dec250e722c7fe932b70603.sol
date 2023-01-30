/**

 *Submitted for verification at Etherscan.io on 2019-03-31

*/



pragma solidity ^0.4.11;



/**

 * @title ERC20HELPToken

 * @dev Simpler version of ERC20 interface

 * @dev http://help-coin.net

 */



contract HELPToken {



    string public name = "HELPToken";      //  token name

    string public symbol = "HELP";           //  token symbol

    uint256 public decimals = 18;            //  token digit



    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    uint256 public totalSupply = 210000000000000000000000000;

    bool public stopped = false;



    uint256 constant valueFounder = 210000000000000000000000000;

    address owner = 0xF90011516173E651c9b7025f9304Bf6bF0fB4057;



    modifier isOwner {

        assert(owner == msg.sender);

        _;

    }



    modifier isRunning {

        assert (!stopped);

        _;

    }



    modifier validAddress {

        assert(0x0 != msg.sender);

        _;

    }



    function TronToken(address _addressFounder) {

        owner = msg.sender;

        totalSupply = valueFounder;

        balanceOf[0xF90011516173E651c9b7025f9304Bf6bF0fB4057] = valueFounder;

        Transfer(0xF90011516173E651c9b7025f9304Bf6bF0fB4057, _addressFounder, valueFounder);

    }



    function transfer(address _to, uint256 _value) isRunning validAddress returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        balanceOf[msg.sender] -= _value;

        balanceOf[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) isRunning validAddress returns (bool success) {

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        require(allowance[_from][msg.sender] >= _value);

        balanceOf[_to] += _value;

        balanceOf[_from] -= _value;

        allowance[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) isRunning validAddress returns (bool success) {

        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function stop() isOwner {

        stopped = true;

    }



    function start() isOwner {

        stopped = false;

    }



    function setName(string _name) isOwner {

        name = _name;

    }



    function burn(uint256 _value) {

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;

        balanceOf[0x0] += _value;

        Transfer(msg.sender, 0x0, _value);

    }



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}