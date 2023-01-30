/**
 *Submitted for verification at Etherscan.io on 2020-07-07
*/

// File: contracts/token/interfaces/IERC20Token.sol

pragma solidity 0.4.26;

/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {this;}
    function symbol() public view returns (string) {this;}
    function decimals() public view returns (uint8) {this;}
    function totalSupply() public view returns (uint256) {this;}
    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}
    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

// File: contracts/fee-recipient/Owned.sol

pragma solidity 0.4.26;

contract Owned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address _prevOwner, address _newOwner);

    constructor () public { owner = msg.sender; }

    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner) public ownerOnly {
        require(_newOwner != owner && _newOwner != address(0), "Unauthorized");
        emit OwnerUpdate(owner, _newOwner);
        owner = _newOwner;
        newOwner = address(0);
    }

    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner, "Invalid");
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner, "Unauthorized");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

// File: contracts/token-swap/TokenSwap.sol

pragma solidity 0.4.26;



contract TokenSwap is Owned {

    IERC20Token public source; // pegusd
    IERC20Token public target; // usdb

    constructor (
        IERC20Token _source,
        IERC20Token _target
    ) public {
        source = _source;
        target = _target;
    }

    function setTarget(IERC20Token _target) public ownerOnly {
        target = _target;
    }

    function setSource(IERC20Token _source) public ownerOnly {
        source = _source;
    }

    function swap(uint256 _amount) public {
        require(target.balanceOf(address(this)) >= _amount, 'Insufficient balance');
        source.transferFrom(msg.sender, address(this), _amount);
        target.transfer(msg.sender, _amount);
    }

    function transferERC20Token(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        _token.transfer(_to, _amount);
    }

}