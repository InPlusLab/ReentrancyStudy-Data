pragma solidity ^0.4.11;

import "./SafeMath.sol";

contract LVToken {
    using SafeMath for uint;

    string public constant name = "LivesToken on Chain";
    string public constant symbol = "LVTC";
    uint8 public constant decimals = 18;
    string public constant version = "1.0";

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    bool public freezed = false;
    mapping (address => uint) permits;
    address public constant addr_team = 0xd5a375Dd13abEF145B8183E6C2380BC777614395;
    address public constant addr_miner = 0x22164b69c71DcF12E1dc037BB43933449f342a69;
    address public constant addr_ico = 0xBDC44A4EA8A9640ee5DcF2E0425d7A262C830c62;
    address public constant addr_org = 0x32A3A725895F1BdcFC1FEf8340f9f26d49Af60ab;

    //28 billion total
    uint public totalSupply = 28 * (10**9) * (10**uint(decimals));

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Freeze(address indexed _from, uint _sum);

    function LVToken() public {
        balances[addr_team] = 28 * (10**8) * (10**uint(decimals));              //team, 10%
        balances[addr_miner] = 140 * (10**8) * (10**uint(decimals));             //miner, 50%
        balances[addr_ico] = 56 * (10**8) * (10**uint(decimals));              //pre-ico, 20%
        balances[addr_org] = 56 * (10**8) * (10**uint(decimals));              //organization, 20%

        permits[addr_team] = 0;
        permits[addr_miner] = 0;
        permits[addr_ico] = 0;
        permits[addr_org] = 0;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(!freezed);
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(!freezed);
        require(_value > 0);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function balanceOf(address _owner) constant public returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(!freezed);
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint) {
        return allowed[_owner][_spender];
    }

    /**
     * as we are going to 1:1 swap to LVT-chain in the future, all the transactions in ethereum will be freezed at that time
     */    
    function freeze() public {
        //this function is allowed before freezed
        require(!freezed);
        //only the pre-allocated address can run this function
        require((msg.sender == addr_team) || (msg.sender == addr_miner) || (msg.sender == addr_ico) || (msg.sender == addr_org));
        //set to 1 of the caller
        permits[msg.sender] = 1;
        //sum all the addresses's setting
        uint sum = permits[addr_team] + permits[addr_miner] + permits[addr_ico] + permits[addr_org];
        if (sum >= 2) {
            //the token is freezed if at least 2 address has run this function
            freezed = true;
        }
        emit Freeze(msg.sender, sum);
    }
}
