/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

pragma solidity 0.6.8;

contract Binar {
    struct User {
        uint256 id;
        address inviter;
        uint256 balance;
        mapping(uint8 => uint40) expires;
        mapping(uint8 => address) uplines;
        mapping(uint8 => address[]) referrals;
    }

    uint40 public LEVEL_TIME_LIFE = 120 days;

    address payable public root;
    uint256 public last_id;

    uint256[] public levels;
    mapping(address => User) public users;
    mapping(uint256 => address) public users_ids;

    event Register(address indexed addr, address indexed inviter, uint256 id);
    event BuyLevel(address indexed addr, address indexed upline, uint8 level, uint40 expires);
    event Profit(address indexed addr, address indexed referral, uint256 value);
    event Lost(address indexed addr, address indexed referral, uint256 value);

    constructor() public {
        levels.push(0.03 ether);
        levels.push(0.05 ether);
        levels.push(0.14 ether);

        levels.push(0.06 ether);
        levels.push(0.10 ether);
        levels.push(0.28 ether);

        levels.push(0.12 ether);
        levels.push(0.20 ether);
        levels.push(0.56 ether);
        
        levels.push(0.24 ether);
        levels.push(0.40 ether);
        levels.push(1.12 ether);
        
        levels.push(0.48 ether);
        levels.push(0.80 ether);
        levels.push(2.24 ether);
        
        levels.push(0.96 ether);
        levels.push(1.60 ether);
        levels.push(4.48 ether);
        
        levels.push(1.92 ether);
        levels.push(3.20 ether);
        levels.push(8.96 ether);
        
        levels.push(3.84 ether);
        levels.push(6.40 ether);
        levels.push(17.92 ether);
        
        levels.push(7.68 ether);
        levels.push(12.80 ether);
        levels.push(35.84 ether);
        
        levels.push(15.26 ether);
        levels.push(25.60 ether);
        levels.push(71.68 ether);

        root = 0xb5Bb9Ce69ce3c5556BCf17Ca8A13abA2229F0405;

        _newUser(root, address(0));

        for(uint8 i = 0; i < levels.length; i++) {
            users[root].expires[i] = uint40(-1);

            emit BuyLevel(root, address(0), i, users[root].expires[i]);
        }
    }

    receive() payable external {
        require(users[msg.sender].id > 0, "User not register");
        
        users[msg.sender].balance += msg.value;

        _autoBuyLevel(msg.sender);
    }

    fallback() payable external {
        _register(msg.sender, bytesToAddress(msg.data), msg.value);
    }

    function _newUser(address _addr, address _inviter) private {
        users[_addr].id = ++last_id;
        users[_addr].inviter = _inviter;
        users_ids[last_id] = _addr;

        emit Register(_addr, _inviter, last_id);
    }

    function _buyLevel(address _user, uint8 _level) private {
        require(levels[_level] > 0, "Invalid level");
        require(users[_user].balance >= levels[_level], "Insufficient funds");
        require(_level == 0 || users[_user].expires[_level - 1] > block.timestamp, "Need previous level");
        
        users[_user].balance -= levels[_level];
        users[_user].expires[_level] = uint40((users[_user].expires[_level] > block.timestamp ? users[_user].expires[_level] : block.timestamp) + LEVEL_TIME_LIFE);
        
        uint8 round = _level / 3;
        uint8 offset = _level % 3;
        address upline = users[_user].inviter;

        if(users[_user].uplines[round] == address(0)) {
            while(users[upline].expires[_level] < block.timestamp) {
                emit Lost(upline, _user, levels[_level]);

                upline = users[upline].inviter;
            }

            upline = this.findFreeReferrer(upline, round);

            users[_user].uplines[round] = upline;
            users[upline].referrals[round].push(_user);
        }
        else upline = users[_user].uplines[round];

        address profiter = this.findUpline(upline, round, offset);

        uint256 value = levels[_level];

        if(_level == 0) {
            uint256 com = value / 10;

            if(payable(users[_user].inviter).send(com)) {
                value -= com;
                
                emit Profit(users[_user].inviter, _user, com);
            }
        }

        users[profiter].balance += value;
        _autoBuyLevel(profiter);
        
        emit Profit(profiter, _user, value);
        emit BuyLevel(_user, upline, _level, users[_user].expires[_level]);
    }

    function _autoBuyLevel(address _user) private {
        for(uint8 i = 0; i < levels.length; i++) {
            if(levels[i] > users[_user].balance) break;

            if(users[_user].expires[i] < block.timestamp) {
                _buyLevel(_user, i);
            }
        }
    }

    function _register(address _user, address _upline, uint256 _value) private {
        require(users[_user].id == 0, "User arleady register");
        require(users[_upline].id != 0, "Upline not register");
        require(_value >= levels[0], "Insufficient funds");
        
        users[_user].balance += _value;

        _newUser(_user, _upline);
        _buyLevel(_user, 0);
    }

    function register(uint256 _upline_id) payable external {
        _register(msg.sender, users_ids[_upline_id], msg.value);
    }

    function buy(uint8 _level) payable external {
        require(users[msg.sender].id > 0, "User not register");
        
        users[msg.sender].balance += msg.value;

        _buyLevel(msg.sender, _level);
    }

    function withdraw(uint256 _value) payable external {
        require(users[msg.sender].id > 0, "User not register");

        _value = _value > 0 ? _value : users[msg.sender].balance;

        require(_value <= users[msg.sender].balance, "Insufficient funds");
        
        users[msg.sender].balance -= _value;

        if(!payable(msg.sender).send(_value)) {
            root.transfer(_value);
        }
    }

    function destruct() external {
        require(msg.sender == root, "Access denied");

        selfdestruct(root);
    }

    function findUpline(address _user, uint8 _round, uint8 _offset) external view returns(address) {
        if(_user == root || _offset == 0) return _user;

        return this.findUpline(users[_user].uplines[_round], _round, _offset - 1);
    }

    function findFreeReferrer(address _user, uint8 _round) external view returns(address) {
        if(users[_user].referrals[_round].length < 2) return _user;

        address[] memory refs = new address[](1024);
        
        refs[0] = users[_user].referrals[_round][0];
        refs[1] = users[_user].referrals[_round][1];

        for(uint16 i = 0; i < 1024; i++) {
            if(users[refs[i]].referrals[_round].length < 2) {
                return refs[i];
            }

            if(i < 511) {
                uint16 n = (i + 1) * 2;

                refs[n] = users[refs[i]].referrals[_round][0];
                refs[n + 1] = users[refs[i]].referrals[_round][1];
            }
        }

        revert("No free referrer");
    }

    function bytesToAddress(bytes memory _data) private pure returns(address addr) {
        assembly {
            addr := mload(add(_data, 20))
        }
    }
}