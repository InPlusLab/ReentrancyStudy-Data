/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath{
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) {
        return 0;}
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */ 
interface ERC20Basic {  
    function balanceOf(address who) external view returns (uint256 balance);
    function transfer(address to, uint256 value) external returns (bool trans1);
    function allowance(address owner, address spender) external view returns (uint256 remaining);
    function transferFrom(address from, address to, uint256 value) external returns (bool trans);
    function approve(address spender, uint256 value) external returns (bool hello);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Staker {
    using SafeMath for uint;
    
    ERC20Basic public xDNA;
    uint[] timespans = [2592000, 7776000, 15552000, 31536000];
    uint[] rates = [103, 110, 123, 149];
    mapping(uint => address) public ownerOf;
    struct Stake {
        uint amount;
        uint start;
        uint8 timespan;
        bool withdrawn;
    }
    Stake[] public stakes;

    function stake(uint _amount, uint8 _timespan) public returns (uint _tokenId) {
        require(_amount >= 100000 ether);
        require(_timespan < 4);
        require(xDNA.transferFrom(msg.sender, address(this), _amount));
        Stake memory _stake = Stake({
            amount: _amount,
            start: block.timestamp,
            timespan: _timespan,
            withdrawn: false
        });
        _tokenId = stakes.length;
        stakes.push(_stake);
        ownerOf[_tokenId] = msg.sender;
    }
    
    function unstake(uint _id) public {
        require(msg.sender == ownerOf[_id]);
        Stake storage _s = stakes[_id];
        uint8 _t = _s.timespan;
        require(_s.withdrawn == false);
        require(block.timestamp >= _s.start + timespans[_t]);
        require(xDNA.transfer(msg.sender, _s.amount.mul(rates[_t]).div(100)));
        _s.withdrawn = true;
    }
    
    function tokensOf(address _owner) public view returns (uint[] memory ownerTokens) {
        uint _count = 0;
        for (uint i = 0; i < stakes.length; i++) {
            if (ownerOf[i] == _owner) _count++;
        }
        if (_count == 0) return new uint[](0);
        ownerTokens = new uint[](_count);
        uint _index = 0;        
        for (uint i = 0; i < stakes.length; i++) {
            if (ownerOf[i] == _owner) ownerTokens[_index++] = i;
        }
    }
    
    constructor (ERC20Basic _token) {
        xDNA = ERC20Basic(_token);
    }
}