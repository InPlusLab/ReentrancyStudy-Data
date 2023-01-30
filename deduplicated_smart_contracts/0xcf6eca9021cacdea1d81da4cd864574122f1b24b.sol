/**

 *Submitted for verification at Etherscan.io on 2018-11-30

*/



pragma solidity ^0.4.24;





/// @title ERC-20 interface

/// @dev Full ERC-20 interface is described at https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md.

interface ERC20 {



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);



    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

}





/// @title SafeMath

/// @dev Math operations with safety checks that throw on error.

library SafeMath {



    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}





/// @title SafeOwnable

/// @dev The SafeOwnable contract has an owner address, and provides basic authorization control

/// functions, this simplifies the implementation of "user permissions".

contract SafeOwnable {



    // EVENTS



    event OwnershipProposed(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    // PUBLIC FUNCTIONS



    /// @dev The SafeOwnable constructor sets the original `owner` of the contract to the sender account.

    constructor() internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /// @dev Allows the current owner to propose control of the contract to a new owner.

    /// @param newOwner The address to propose ownership to.

    function proposeOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0) && newOwner != _owner);

        _ownerCandidate = newOwner;

        emit OwnershipProposed(_owner, _ownerCandidate);

    }



    /// @dev Allows the current owner candidate to accept proposed ownership and set actual owner of a contract.

    function acceptOwnership() public onlyOwnerCandidate {

        emit OwnershipTransferred(_owner, _ownerCandidate);

        _owner = _ownerCandidate;

        _ownerCandidate = address(0);

    }



    /// @dev Returns the address of the owner.

    function owner() public view returns (address) {

        return _owner;

    }



    /// @dev Returns the address of the owner candidate.

    function ownerCandidate() public view returns (address) {

        return _ownerCandidate;

    }



    // MODIFIERS



    /// @dev Throws if called by any account other than the owner.

    modifier onlyOwner() {

        require(msg.sender == _owner);

        _;

    }



    /// @dev Throws if called by any account other than the owner candidate.

    modifier onlyOwnerCandidate() {

        require(msg.sender == _ownerCandidate);

        _;

    }



    // FIELDS



    address internal _owner;

    address internal _ownerCandidate;

}





/// @title TokenVesting

/// @dev A token holder contract that can release its token balance gradually like a typical

/// vesting scheme, with a cliff and vesting period. Optionally revocable by the owner.

contract TokenVesting is SafeOwnable {

    using SafeMath for uint256;



    // EVENTS



    event Released(uint256 amount);

    event Revoked();



    // PUBLIC FUNCTIONS



    /// @dev Creates a vesting contract that vests its balance of any ERC20 token to the

    /// _beneficiary, gradually in a linear fashion until _start + _duration. By then all

    /// of the balance will have vested.

    /// @param _beneficiary The address of the beneficiary to whom vested tokens are transferred.

    /// @param _cliff The duration in seconds of the cliff in which tokens will begin to vest.

    /// @param _start The time (as Unix time) at which point vesting starts.

    /// @param _duration The duration in seconds of the period in which the tokens will vest.

    /// @param _revocable The flag indicating if the vesting is revocable or not.

    constructor(

        address _beneficiary,

        uint256 _start,

        uint256 _cliff,

        uint256 _duration,

        bool _revocable

    )

        public

    {

        require(_beneficiary != address(0));

        require(_cliff <= _duration);

        beneficiary = _beneficiary;

        start = _start;

        cliff = _start.add(_cliff);

        duration = _duration;

        revocable = _revocable;

    }



    /// @notice Transfers vested tokens to beneficiary.

    /// @param _token The address of ERC20 token which is being vested.

    function release(ERC20 _token) public {

        uint256 unreleased = releasableAmount(_token);

        require(unreleased > 0);

        released[_token] = released[_token].add(unreleased);

        require(_token.transfer(beneficiary, unreleased));

        emit Released(unreleased);

    }



    /// @notice Allows the owner to revoke the vesting. Tokens already vested

    /// remain in the contract, the rest are returned to the owner.

    /// @param _token The address of ERC20 token which is being vested.

    function revoke(ERC20 _token) public onlyOwner {

        require(revocable);

        require(!revoked[_token]);

        uint256 balance = _token.balanceOf(address(this));

        uint256 unreleased = releasableAmount(_token);

        uint256 refund = balance.sub(unreleased);

        revoked[_token] = true;

        require(_token.transfer(_owner, refund));

        emit Revoked();

    }



    /// @dev Calculates the amount that has already vested but hasn't been released yet.

    /// @param _token The address of ERC20 token which is being vested.

    function releasableAmount(ERC20 _token) public view returns (uint256) {

        return vestedAmount(_token).sub(released[_token]);

    }



    /// @dev Calculates the amount that has already vested.

    /// @param _token The address of ERC20 token which is being vested.

    function vestedAmount(ERC20 _token) public view returns (uint256) {

        uint256 currentBalance = _token.balanceOf(address(this));

        uint256 totalBalance = currentBalance.add(released[_token]);

        if (block.timestamp < cliff) {

            return 0;

        } else if (block.timestamp >= start.add(duration) || revoked[_token]) {

            return totalBalance;

        } else {

            return totalBalance.mul(block.timestamp.sub(start)).div(duration);

        }

    }



    // FIELDS



    address public beneficiary;



    uint256 public start;

    uint256 public cliff;

    uint256 public duration;



    bool public revocable;



    mapping (address => uint256) public released;

    mapping (address => bool) public revoked;

}