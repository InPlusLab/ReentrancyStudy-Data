/**
 *Submitted for verification at Etherscan.io on 2019-10-14
*/

pragma solidity >= 0.4.24 < 0.6.0;


/**
 * @title OBIT - OpenBIT
 * @author Department of develop
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
 * @title OpenBit implementation
 */
contract OpenBIT is IERC20 {
    string public name = "OpenBIT";
    string public symbol = "OBIT";
    uint8 public decimals = 18;
    
    uint256 companyAmount;
    uint256 founderAmount;
    uint256 teamPJMAmount;
    uint256 teamLKSAmount;
    uint256 teamLJHAmount;
    uint256 teamPYGAmount;
    uint256 teamHKJAmount;
    uint256 teamYSTAmount;
    uint256 teamMHSAmount;
    uint256 privAmount;
    uint256 saleAmount;
    uint256 investorAmount;
    uint256 marketingAmount;

    uint256 _totalSupply;
    mapping(address => uint256) balances;

    // Addresses
    address public owner;
    address public company;
    address public founder_kjh;
    address public team_pjm;
    address public team_lks;
    address public team_ljh;
    address public team_pyg;
    address public team_hkj;
    address public team_yst;
    address public team_mhs;
    address public priv;
    address public sale;
    address public investor;
    address public marketing;

    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    constructor() public {
        owner = msg.sender;

        company = 0x2A913F249722F46aC6b45D8c557bb298A0Cf48Dc;
        founder_kjh = 0x0e916E614f1c2367BA8aE160b186AC03F2eE6D53;
        team_pjm = 0x9E2E552D09f403489A33fdB1DF3Bcc112d0Ad9A3;
        team_lks = 0x4c65bA869a9fef6DC77c0B05aC76072dffF2EE42;
        team_ljh = 0x484E5C834f44B547D395b8592E185E54dF5cD770;
        team_pyg = 0x4c1A8d4D6dEc1188eC1418E36B9b403E1ad554d3;
        team_hkj = 0xFbbCA158Bd9C2092ee334799dB87AB385253052F;
        team_yst = 0xB44652Ba75ca89Cf955935eD400B28125414e608;
        team_mhs = 0x6317193920B2317AA4ed4e1eCe4fC6785cCcB64A;
        priv = 0xB6F85467Ac4191B8870fBb9aCBd1751D23906972;
        sale = 0x593e60e68411d441CD1e064e1e11fD6829faE0cC;
        investor = 0xF3486B6D3923C2f6a85f62D73C29e28FdA187935;
        marketing = 0x73021D928d987265af55a9d469E2c027405CF393;

        companyAmount   = toWei(100000000);
        founderAmount   = toWei(100000000);
        teamPJMAmount   = toWei( 50000000);
        teamLKSAmount   = toWei( 50000000);
        teamLJHAmount   = toWei( 50000000);
        teamPYGAmount   = toWei( 10000000);
        teamHKJAmount   = toWei(  7000000);
        teamYSTAmount   = toWei(  7000000);
        teamMHSAmount   = toWei( 26000000);
        privAmount      = toWei( 50000000);
        saleAmount      = toWei(400000000);
        investorAmount  = toWei(100000000);
        marketingAmount = toWei( 50000000);

        _totalSupply   = toWei(1000000000);  //1,000,000,000

        require(_totalSupply == companyAmount + founderAmount + teamPJMAmount + teamLKSAmount +  teamLJHAmount + teamPYGAmount + teamHKJAmount + teamYSTAmount + teamMHSAmount + privAmount + saleAmount + investorAmount + marketingAmount );
        
        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(company, companyAmount);
        transfer(founder_kjh, founderAmount);
        transfer(team_pjm, teamPJMAmount);
        transfer(team_lks, teamLKSAmount);
        transfer(team_ljh, teamLJHAmount);
        transfer(team_pyg, teamPYGAmount);
        transfer(team_hkj, teamHKJAmount);
        transfer(team_yst, teamYSTAmount);
        transfer(team_mhs, teamMHSAmount);
        transfer(priv, privAmount);
        transfer(sale, saleAmount);
        transfer(investor, investorAmount);
        transfer(marketing, marketingAmount);


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

        if(msg.sender == company) {
            require(now >= 1634256000);     // 100% lock to 15-Oct-2021
        }

        if(msg.sender == founder_kjh) {
            require(now >= 1602720000);     // 100% lock to 15-Oct-2020
        }

        if(msg.sender == team_pjm || msg.sender == team_lks || msg.sender == team_ljh || msg.sender == team_pyg || msg.sender == team_hkj || msg.sender == team_yst || msg.sender == team_mhs) {
            require(now >= 1586908800);     // 100% lock to 15-Apr-2020
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

    /** @dev Math function
     */

    function toWei(uint256 value) private view returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
}