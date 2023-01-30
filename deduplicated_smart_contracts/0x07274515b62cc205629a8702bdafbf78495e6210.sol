/**

 *Submitted for verification at Etherscan.io on 2019-04-07

*/



pragma solidity ^0.4.16;

contract owned {

    address public owner;

    constructor() public {

        owner = msg.sender;

    }

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;

    }

}

contract LuckyCoin is owned {

    string public constant name = "LuckyCoin";

    string public constant symbol = "LC";

    uint public constant decimals = 4;

    uint constant ONETOKEN = 10 ** uint(decimals); 

    uint public totalSupply;

    constructor() public {

        totalSupply = 88888888 * ONETOKEN;                        

        balanceOf[msg.sender] = totalSupply;                            

    }

    mapping (address => uint256) public balanceOf;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    

    function transfer(address _to, uint256 _value) public {

        _transferLC(msg.sender, _to, _value);

    }

    function _transferLC(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    function() payable public { }



    function withdrawEther() onlyOwner public{

        owner.transfer(address(this).balance);

    }

    function mint(address target, uint256 token) onlyOwner public {

        balanceOf[target] += token;

        totalSupply += token;

        emit Transfer(0, this, token);

        emit Transfer(this, target, token);

    }

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   

        balanceOf[msg.sender] -= _value;            

        totalSupply -= _value;

        emit Burn(msg.sender, _value);

        return true;

    }

}