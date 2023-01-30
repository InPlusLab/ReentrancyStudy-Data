/**
 *Submitted for verification at Etherscan.io on 2020-03-31
*/

pragma solidity ^0.6.0;

contract XHT {
    string constant public name = "Hypercube's Token";
    string constant public symbol = "XHT";
    uint8 constant public decimals = 4;
    uint256 public totalSupply;
    address public owner = msg.sender;
    address public deprecated;
    uint256 public last_mint_block = block.number;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function mint() public {
        uint256 _value = (block.number - last_mint_block) * 2;
        last_mint_block = block.number;
        _transfer(address(0), owner, _value);
    }

    function transfer_ownership(address _to) public {
        require(msg.sender == owner, "Permission denied.");
        owner = _to;
    }

    function deprecate(address _to) public {
        require(msg.sender == owner, "Permission denied.");
        deprecated = _to;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance.");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        if (_from == address(0)) {
            // mint
            totalSupply += _value;
        } else {
            // transfer from
            require(balanceOf[_from] >= _value, "Insufficient balance.");
            balanceOf[_from] -= _value;
        }
        if (_to == address(0)) {
            // burn
            totalSupply -= _value;
        } else {
            // transfer into
            balanceOf[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
    }
}

contract Exchange {
    XHT private token = XHT(0xa0DDAa9779a3F237095338b6546aABaAD7AbeaeE);
    uint256 public start_block = block.number;

    function buy_price() public view returns (uint256) {
        return 2e7 * (block.number - start_block);
    }

    function sell_price() public view returns (uint256) {
        return 1e7 * (block.number - start_block);
    }

    function buy() public payable {
        uint256 eth_value = msg.value;
        uint256 xht_value = eth_value / buy_price();
        require(token.balanceOf(address(this)) >= xht_value, "I cannot sell this much now.");
        token.transfer(msg.sender, xht_value);
    }

    function sell(uint256 xht_value) public {
        uint256 eth_value = xht_value * sell_price();
        require(address(this).balance >= eth_value, "I cannot buy this much now.");
        if (token.transferFrom(msg.sender, address(this), xht_value))
            msg.sender.transfer(eth_value);
    }

    receive() external payable {}
}