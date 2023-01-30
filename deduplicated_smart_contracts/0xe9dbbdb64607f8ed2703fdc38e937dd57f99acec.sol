/**
 *Submitted for verification at Etherscan.io on 2019-10-12
*/

/*
    owner.sol v1.0.0
    Owner
    
    This file is part of Screenist [NIS] token project.
    
    Author: Andor 'iFA' Rajci, Fusion Solutions KFT @ contact@fusionsolutions.io
*/
pragma solidity 0.4.26;

contract Owned {
    /* Variables */
    address public owner = msg.sender;
    /* Constructor */
    constructor(address _owner) public {
        if ( _owner == address(0x00000000000000000000000000000000000000) ) {
            _owner = msg.sender;
        }
        owner = _owner;
    }
    /* Externals */
    function replaceOwner(address _owner) external returns(bool) {
        require( isOwner() );
        owner = _owner;
        return true;
    }
    /* Internals */
    function isOwner() internal view returns(bool) {
        return owner == msg.sender;
    }
    /* Modifiers */
    modifier forOwner {
        require( isOwner() );
        _;
    }
}
/*
    safeMath.sol v1.0.0
    Safe mathematical operations
    
    This file is part of Screenist [NIS] token project.
    
    Author: Andor 'iFA' Rajci, Fusion Solutions KFT @ contact@fusionsolutions.io
*/
pragma solidity 0.4.26;

library SafeMath {
    /* Internals */
    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
        assert( c >= a );
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a - b;
        assert( c <= a );
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a * b;
        assert( c == 0 || c / a == b );
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return a / b;
    }
    function pow(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a ** b;
        assert( c % a == 0 );
        return a ** b;
    }
}
/*
    tokenDB.sol v1.0.0
    Token Database
    
    This file is part of Screenist [NIS] token project.
    
    Author: Andor 'iFA' Rajci, Fusion Solutions KFT @ contact@fusionsolutions.io
*/
pragma solidity 0.4.26;

contract TokenDB is Owned {
    /* Declarations */
    using SafeMath for uint256;
    /* Structures */
    struct balances_s {
        uint256 amount;
        bool valid;
    }
    struct vesting_s {
        uint256 amount;
        uint256 startBlock;
        uint256 endBlock;
        uint256 claimedAmount;
        bool    valid;
    }
    /* Variables */
    mapping(address => mapping(address => uint256)) private allowance;
    mapping(address => balances_s) private balances;
    mapping(address => vesting_s) public vesting;
    uint256 public totalSupply;
    address public tokenAddress;
    address public oldDBAddress;
    uint256 public totalVesting;
    /* Constructor */
    constructor(address _owner, address _tokenAddress, address _oldDBAddress) Owned(_owner) public {
        oldDBAddress = _oldDBAddress;
        tokenAddress = _tokenAddress;
    }
    /* Externals */
    function changeTokenAddress(address _tokenAddress) external forOwner {
        tokenAddress = _tokenAddress;
    }
    function mint(address _to, uint256 _amount) external forToken returns(bool _success) {
        uint256 _receiverBalance = _getBalance(_to);
        totalSupply = _getTotalSupply().add(_amount);
        balances[_to].amount = _receiverBalance.add(_amount);
        balances[_to].valid = true;
        return true;
    }
    function transfer(address _from, address _to, uint256 _amount) external forToken returns(bool _success) {
        uint256 _senderBalance = _getBalance(_from);
        uint256 _receiverBalance = _getBalance(_to);
        balances[_from].amount = _senderBalance.sub(_amount);
        balances[_from].valid = true;
        balances[_to].amount = _receiverBalance.add(_amount);
        balances[_to].valid = true;
        return true;
    }
    function bulkTransfer(address _from, address[] memory _to, uint256[] memory _amount) public forToken returns(bool _success) {
        uint256 _senderBalance = _getBalance(_from);
        uint256 _receiverBalance;
        uint256 i;
        for ( i=0 ; i<_to.length ; i++ ) {
            _receiverBalance = _getBalance(_to[i]);
            _senderBalance = _senderBalance.sub(_amount[i]);
            balances[_to[i]].amount = _receiverBalance.add(_amount[i]);
            balances[_to[i]].valid = true;
        }
        balances[_from].amount = _senderBalance;
        balances[_from].valid = true;
        return true;
    }
    function setAllowance(address _owner, address _spender, uint256 _amount) external forToken returns(bool _success) {
        allowance[_owner][_spender] = _amount;
        return true;
    }
    function setVesting(address _owner, uint256 _amount, uint256 _startBlock, uint256 _endBlock, uint256 _claimedAmount) external forToken returns(bool _success) {
        uint256 _tv = _getTotalVesting();
        if ( vesting[_owner].valid ) {
            _tv = _tv.sub( vesting[_owner].amount.sub( vesting[_owner].claimedAmount ) );
        }
        if ( _amount > 0 ) {
            _tv = _tv.add( _amount );
        }
        vesting[_owner].amount = _amount;
        vesting[_owner].startBlock = _startBlock;
        vesting[_owner].endBlock = _endBlock;
        vesting[_owner].claimedAmount = _claimedAmount;
        vesting[_owner].valid = true;
        totalVesting = _tv;
        return true;
    }
    /* Constants */
    function getAllowance(address _owner, address _spender) public view returns(bool _success, uint256 _remaining) {
        return ( true, allowance[_owner][_spender] );
    }
    function getBalance(address _owner) public view returns(bool _success, uint256 _balance) {
        return ( true, _getBalance(_owner) );
    }
    function getTotalSupply() public view returns(bool _success, uint256 _totalSupply) {
        return ( true, _getTotalSupply() );
    }
    function getTotalVesting() public view returns(bool _success, uint256 _totalVesting) {
        return ( true, _getTotalVesting() );
    }
    function getVesting(address _owner) public view returns(bool _success, uint256 _amount, uint256 _startBlock, uint256 _endBlock, uint256 _claimedAmount, bool _valid) {
        bool _subResult;
        if ( ( ! vesting[_owner].valid ) && oldDBAddress != address(0x00000000000000000000000000000000000000) ) {
            ( _subResult, _amount, _startBlock, _endBlock, _claimedAmount, _valid ) = TokenDB(oldDBAddress).getVesting(_owner);
            require( _subResult );
        } else {
            _amount = vesting[_owner].amount;
            _startBlock = vesting[_owner].startBlock;
            _endBlock = vesting[_owner].endBlock;
            _claimedAmount = vesting[_owner].claimedAmount;
            _valid = vesting[_owner].valid;
        }
        _success = true;
    }
    /* Internals */
    function _getBalance(address _owner) internal view returns(uint256 _balance) {
        bool _subResult;
        if ( ( ! balances[_owner].valid ) && oldDBAddress != address(0x00000000000000000000000000000000000000) ) {
            ( _subResult, _balance ) = TokenDB(oldDBAddress).getBalance(_owner);
            require( _subResult );
        } else {
            _balance = balances[_owner].amount;
        }
    }
    function _getTotalSupply() internal view returns(uint256 _totalSupply) {
        bool _subResult;
        if ( totalSupply == 0x00 && oldDBAddress != address(0x00000000000000000000000000000000000000) ) {
            ( _subResult, _totalSupply ) = TokenDB(oldDBAddress).getTotalSupply();
            require( _subResult );
        } else {
            _totalSupply = totalSupply;
        }
    }
    function _getTotalVesting() internal view returns(uint256 _totalVesting) {
        bool _subResult;
        if ( totalVesting == 0x00 && oldDBAddress != address(0x00000000000000000000000000000000000000) ) {
            ( _subResult, _totalVesting ) = TokenDB(oldDBAddress).getTotalVesting();
            require( _subResult );
        } else {
            _totalVesting = totalVesting;
        }
    }
    /* Modifiers */
    modifier forToken {
        require( msg.sender == tokenAddress );
        _;
    }
}