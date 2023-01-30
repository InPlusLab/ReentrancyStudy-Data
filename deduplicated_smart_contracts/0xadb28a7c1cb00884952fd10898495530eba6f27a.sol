pragma solidity ^0.5.11;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Token is Ownable, ERC20 {

    using SafeMath for uint;

    string public constant name = "Illuminat token";
    string public constant symbol = "LUM";
    uint public constant decimals = 18;

    uint public advisorsAmount;
    uint public bountyAmount;
    uint public teamAmount;

    address public depositAddress;
    uint private deployTime;
    uint private lockTime = 2 * 365 days;

    event PayService(string indexed _service, uint indexed _toDepositAddress);

    constructor() public {
        deployTime = now;

        advisorsAmount = 1000000 * 10 ** decimals;
        bountyAmount = 2000000 * 10 ** decimals;
        teamAmount = 15000000 * 10 ** decimals;

        _mint(address(this), 100000000 * 10 ** decimals);
    }

    function() external {
        revert();
    }

    function setDepositAddress(address _depositAddress) public onlyOwner {
        depositAddress = _depositAddress;
    }

    function payService(string memory service, address _to, uint amount) public {
        uint tenPercents = amount.div(10);
        transfer(depositAddress, tenPercents);
        _burn(msg.sender, tenPercents);
        transfer(_to, amount.sub(tenPercents.mul(2)));

        emit PayService(service, tenPercents);
    }

    function sendTokens(address[] memory _receivers, uint[] memory _amounts) public onlyOwner {
        require(_receivers.length == _amounts.length, "The length of the arrays must be equal");

        for (uint i = 0; i < _receivers.length; i++) {
            _transfer(address(this), _receivers[i], _amounts[i]);
        }
    }

    function transferTokens(address to, uint amount) public onlyOwner {
        _transfer(address(this), to, amount);
    }

    function sendTeamTokens(address teamAddress, uint amount) public onlyOwner {
        if(now < deployTime.add(lockTime)){
            require(teamAmount.sub(10000000*10**decimals) >= amount, "Not enough unlocked tokens amount");
        } else {
            require(teamAmount >= amount, "Not enough tokens amount");
        }
        teamAmount = teamAmount.sub(amount);
        _transfer(address(this), teamAddress, amount);
    }

    function sendAdvisorsTokens(address advisorsAddress, uint amount) public onlyOwner {
        if(now < deployTime.add(lockTime)){
            require(advisorsAmount.sub(650000*10**decimals) >= amount, "Not enough unlocked tokens amount");
        } else {
            require(advisorsAmount >= amount, "Not enough tokens amount");
        }
        advisorsAmount = advisorsAmount.sub(amount);
        _transfer(address(this), advisorsAddress, amount);
    }

    function sendBountyTokens(address bountyAddress, uint amount) public onlyOwner {
        require(bountyAmount >= amount, "Not enough tokens amount");
        bountyAmount = bountyAmount.sub(amount);
        _transfer(address(this), bountyAddress, amount);
    }
}