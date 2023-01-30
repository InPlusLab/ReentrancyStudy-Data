pragma solidity ^0.5.5;

import "./ERC20.sol";
import "./Owned.sol";

contract CashPerScan is Owned, ERC20 {
    string public name; // 토큰 이름
    string public symbol; // 토큰 단위
    uint8 public decimals; // 소수점 이하 자릿수
    uint256 public INITIAL_SUPPLY; // 토큰 총량


    // 생성자
    constructor(uint256 _supply, string memory _name, string memory _symbol, uint8 _decimals) public {
        _mint(msg.sender, _supply);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        INITIAL_SUPPLY = _supply;
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public onlyOwner {
        //_burnFrom(account, amount);
        _burn(account, amount);
    }

    function freezeAccount(address account, uint256 releaseTime) public onlyOwner {
        _freezeAccount(account, releaseTime);
    }
}