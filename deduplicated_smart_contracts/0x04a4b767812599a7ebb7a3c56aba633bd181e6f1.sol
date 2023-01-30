/**
 *Submitted for verification at Etherscan.io on 2019-12-30
*/

pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title ERC20 Standard Interface
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title VIMUSAY implementation
 */
contract VIM is IERC20 {
    string public name = "VIMUSAY";
    string public symbol = "VIM";
    uint8 public decimals = 8;
    
    uint256 companyAmount;

    uint256 _totalSupply;
    mapping(address => uint256) balances;

    // Addresses
    address public owner;
    address public company;

    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;

        company = 0xa90b76a41D7A281112370aB3F30796b76A63F2e6;

        companyAmount  = toWei(3500000000);
        _totalSupply   = toWei(3500000000);  //3,500,000,000

        require(_totalSupply == companyAmount );
        
        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(company, companyAmount);

        require(balances[owner] == 0);
    }
    
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
    
    function transfer(address to, uint256 value) public returns (bool success) {
        require(msg.sender != to);
        require(to != owner);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );    // prevent overflow


        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function burnCoins(uint256 value) public {
        require(balances[msg.sender] >= value);
        require(_totalSupply >= value);
        
        balances[msg.sender] -= value;
        _totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
    }

    function toWei(uint256 value) private view returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}