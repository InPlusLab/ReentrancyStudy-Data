pragma solidity ^0.5.7;

import "./Ownable.sol";
import "./IERC20.sol";


contract BnbSwap is Ownable {
    mapping (address => string) public registers;

    event Put(address indexed eth, string indexed bnb);

    function put(string calldata _bnb) external {
        require(bytes(registers[msg.sender]).length == 0, "Already registered");
        registers[msg.sender] = _bnb;
        emit Put(msg.sender, _bnb);
    }

    function transfer(
        IERC20 _token,
        address _to,
        uint256 _value
    )
        external
        onlyOwner
    {
        _token.transfer(_to, _value);
    }

    function approve(
        IERC20 _token,
        address _spender,
        uint256 _value
    )
        external
        onlyOwner
    {
        _token.approve(_spender, _value);
    }

    function transferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    )
        external
        onlyOwner
    {
        token.transferFrom(from, to, value);
    }

    function burn(
        IERC20 token,
        uint256 value
    )
        external
        onlyOwner
    {
        token.burn(value);
    }

    function burnFrom(
        IERC20 token,
        address from,
        uint256 value
    )
        external
        onlyOwner
    {
        token.burnFrom(from, value);
    }
}
