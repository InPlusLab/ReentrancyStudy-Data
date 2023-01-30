/**

 *Submitted for verification at Etherscan.io on 2019-04-30

*/



pragma solidity >= 0.5.0 < 0.6.0;





/**

 * @title TAF token - Issued by PlusWisdom Corp.

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

contract TAF is IERC20 {

    string public name = "TAF";

    string public symbol = "TAF";

    uint8 public decimals = 18;

    

    uint256 saleAmount;

    uint256 mineAmount;

    uint256 evtAmount;

    uint256 teamAmount;

    uint256 reserveAmount;

    uint256 mined;



    uint256 _totalSupply;

    mapping(address => uint256) balances;



    address public owner;

    address public gamesvr;

    address public sale;

    address public mine;

    address public evt;

    address public team;

    address public reserve;

    

    modifier isOwner {

        require(owner == msg.sender);

        _;

    }

    

    constructor() public {

        owner   = msg.sender;

        gamesvr = 0xD0dD1eDDD16B4203C0985846A950834Cd6f0Fb4D;

        sale    = 0xBc9DbB5763D288b577a531079Faa07F9d91a03dD;

        mine    = 0x2fFbd2656B98cD87Dd043bEe8924dD08A5E85d79;

        evt     = 0xf3fF6B835E02E0DFAAEa6af7902199D225dBc558;

        team    = 0x0FF77e8F233a662c888abd14A3efA2686fC8a694;

        reserve = 0x7854685d5C51945528013ff1004c307fe3929E7f;



        saleAmount    = toWei(200000000);   //200,000,000

        mineAmount    = toWei(200000000);   //200,000,000

        evtAmount     = toWei(100000000);   //100,000,000

        teamAmount    = toWei(100000000);   //100,000,000

        reserveAmount = toWei(400000000);   //400,000,000

        _totalSupply  = toWei(1000000000);  //1,000,000,000

        mined = 0;



        require(_totalSupply == saleAmount + mineAmount + evtAmount + teamAmount + reserveAmount );

        

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, balances[owner]);

        

        transfer(sale, saleAmount);

        transfer(mine, mineAmount);

        transfer(evt, evtAmount);

        transfer(team, teamAmount);

        transfer(reserve, reserveAmount);

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

        require( balances[to] + value >= balances[to] );    // prevent overflow



        if(msg.sender == team) {

            require(now >= 1588258800);     // 10M lock to 2020-05-01

            if(balances[msg.sender] - value < toWei(80000000))

                require(now >= 1619794800);     // 10M lock to 2021-05-01

            if(balances[msg.sender] - value < toWei(60000000))

                require(now >= 1651330800);     // 10M lock to 2022-05-01

            if(balances[msg.sender] - value < toWei(40000000))

                require(now >= 1682866800);     // 10M lock to 2023-05-01

            if(balances[msg.sender] - value < toWei(20000000))

                require(now >= 1714489200);     // 10M lock to 2024-05-01

        }



        if(msg.sender == mine)

            mined += value;

            

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



    function minedAmount() public view returns (uint256) {

        return mined;

    }





    /** @dev private function

     */



    function toWei(uint256 value) private view returns (uint256) {

        return value * (10 ** uint256(decimals));

    }

}