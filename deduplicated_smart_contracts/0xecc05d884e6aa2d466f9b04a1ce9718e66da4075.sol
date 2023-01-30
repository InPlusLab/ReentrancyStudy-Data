/**
 *Submitted for verification at Etherscan.io on 2019-09-07
*/

/**
 *Submitted for verification at Etherscan.io on 2019-05-07
*/

pragma solidity >= 0.5.0 < 0.6.0;


/**
 * @title VONN token 
 * @author J Kwon
 */


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
 * @title Token implementation
 */
contract VONN is IERC20 {
    string public name = "VONNICON";
    string public symbol = "VONN";
    uint8 public decimals = 18;
    
    uint256 partnerAmount;
    uint256 marketingAmount;
    uint256 pomAmount;
    uint256 companyAmount;
    uint256 kmjAmount;
    uint256 kdhAmount;
    uint256 saleAmount;

    uint256 _totalSupply;
    mapping(address => uint256) balances;

    address public owner;
    address public partner;
    address public marketing;
    address public pom;
    address public company;
    address public kmj;
    address public kdh;
    address public sale;
    
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner   = msg.sender;
        partner = 0x0F0899B751B2b875A1CEFAb30481631108212adD;
        marketing = 0xeEfa861FcE8Be1Dba5D7EF0985F8d577c049CEBC;
        pom = 0x0Aa532f4eDbb2Bed94D10758267B0Af1Ffe40F50;
        company = 0x84ac9629eA3c1F9eA0f6718DAcBE6C17aE4A2319;
        kmj = 0xD1cE512A667e078CbAD3274F71a6a67f249f0945;
        kdh = 0x2951ca22330613f41Ce3CC28b6971C080eb6782b;
        sale = 0x6e1C09Bcc44B9016Ad34f5Cbb340E1F2129c9904;
        
        partnerAmount   = toWei(250000000);
        marketingAmount = toWei(500000000);
        pomAmount       = toWei(1500000000);
        companyAmount   = toWei(1200000000);
        kmjAmount       = toWei(50000000);
        kdhAmount       = toWei(250000000);
        saleAmount      = toWei(1250000000);
        _totalSupply    = toWei(5000000000);  //5,000,000,000

        require(_totalSupply == partnerAmount + marketingAmount + pomAmount + companyAmount + kmjAmount + kdhAmount + saleAmount );
        
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(partner, partnerAmount);
        transfer(marketing, marketingAmount);
        transfer(pom, pomAmount);
        transfer(company, companyAmount);
        transfer(kmj, kmjAmount);
        transfer(kdh, kdhAmount);
        transfer(sale, saleAmount);


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
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );

        if (to == address(0) || to == address(0x1) || to == address(0xdead)) {
             _totalSupply -= value;
        }

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


    /** @dev private function
     */

    function toWei(uint256 value) private view returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}