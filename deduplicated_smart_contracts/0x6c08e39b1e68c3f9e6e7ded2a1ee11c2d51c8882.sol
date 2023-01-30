/*

Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

.*/





pragma solidity ^0.4.21;



import "./TokenInterface.sol";



contract GameToken is TokenInterface {



    uint256 constant private MAX_UINT256 = 2**256 - 1;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    /*

    NOTE:

    The following variables are OPTIONAL vanities. One does not have to include them.

    They allow one to customise the token contract & in no way influences the core functionality.

    Some wallets/interfaces might not even bother to look at this information.

    */

    string public name;                   //fancy name: eg Simon Bucks

    uint8 public decimals;                //How many decimals to show.

    string public symbol;                 //An identifier: eg SBX

    address public owner;

    uint256 public price;

    //uint public expDate;

    uint256 public increment_quantity = 0;    //increase price after this quantity hit

    uint256 public increment_price = 0;       //increase this amount to token price after quantity hit

    uint256 public current_batch_sold;    //track total token sold. reset this value while price increase

    uint256 qty_for_old_price = 0;

    uint256 qty_for_new_price = 0;

    uint256 roundInit = 1 hours;

    uint256 roundIncrease = 30 seconds;

    uint256 roundMax = 24 hours;

    uint256 timeStamp = now + roundInit;

    uint256 roundTimeStamp = now + roundMax;

    uint256 nonce;

    uint256[] player_list;

    uint256[] winner_list;

    string[] user_list;

    string[] uwinner_list;

    

    

    //event Sold(address buyer, uint256 amount);



    function GameToken(

        uint256 _initialAmount,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol,

        uint256 _price,

        uint256 _batch_sold

    ) public {

        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens

        totalSupply = _initialAmount;                        // Update total supply

        name = _tokenName;                                   // Set the name for display purposes

        decimals = _decimalUnits;                            // Amount of decimals for display purposes

        symbol = _tokenSymbol;                               // Set the symbol for display purposes

        owner = msg.sender;   

        price = _price;

        current_batch_sold = _batch_sold;

        increment_quantity = _initialAmount;

    }



    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;

        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        uint256 allowance = allowed[owner][_from];

        require(balances[_from] >= _value && allowance >= _value);

        balances[_to] += _value;

        balances[_from] -= _value;

        allowed[owner][_from] -= _value;

        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars

        return true;

    }



    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }

    

    function tokenBalanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars

        return true;

    }



    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

    

    // Guards against integer overflows

    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        } else {

            uint256 c = a * b;

            assert(c / a == b);

            return c;

        }

    }

    

    //random pick winner from winner list 

    function pick_winner() public returns (uint256 rand_no) {

        uint256 random = uint256(keccak256(now, msg.sender, nonce)) % player_list.length;

        nonce++;

        winner_list.push(player_list[random]);

        delete player_list;

        return winner_list[random];

    }

    

    //random pick winner from winner list 

    function pick_uwinner() public returns (string rand_winner) {

        uint256 random = uint256(keccak256(now, msg.sender, nonce)) % user_list.length;

        nonce++;

        uwinner_list.push(user_list[random]);

        delete user_list;

        return uwinner_list[random];

    }

    

    //store player

    function store_player(uint256 _player) public returns (bool success){

        player_list.push(_player);

    }

    

    //store player name

    function store_player_username(string _player) public returns (bool success){

        user_list.push(_player);

    }

    

    //clear player list before round start

    function clear_user() public returns (bool success){

        delete user_list;

    }

    

    //clear player list before round start

    function clear_player() public returns (bool success){

        delete player_list;

    }

    

    //show current participate players for current round

    function get_player_list() public constant returns (uint256[] result){

        return player_list;

    }

    

    //show all winners 

    function get_winner_list() public constant returns (uint256[] result){

        return winner_list;

    }

    

    //get latest round winner 

    function get_current_round_winner() public constant returns (uint256 result){

        if(winner_list.length > 0){

            return winner_list[winner_list.length - 1];

        }else{

            return 0;

        }

    }

    

    function checking(uint256 _player) public returns (uint256[] result){

        winner_list.push(_player);

        return winner_list;

    }

}

