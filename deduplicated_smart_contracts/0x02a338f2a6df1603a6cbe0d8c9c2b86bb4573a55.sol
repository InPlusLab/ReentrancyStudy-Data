// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract Nuggets_PreSale is Ownable {
    
    using SafeMath for uint256;
 
    IERC20 public token;
    
    address payable preSaleWallet;
    
    // Starting time of contract
    uint256 public startsAt = 0;
    // Ending time of contract
    uint256 public endsAt = 7 days;
    uint256 public price = 250000000; // 0.025 ETH Per Nuggets
    uint256 public maxBuy = 5 ether; // A Buyer can Maxmium buy of 5 ETH

    // Pool hardCap
    uint256 public hardCap = 17000 * 10**8;

    // the number of wei raised through this contract
    uint256 public weiRaised = 0;
    // Total tokens sold
    uint256 public tokensSold = 0;

    struct userStr {
        bool isExist;
        uint id;
        uint weis;
        uint tokens;
    }

    uint256 public noOfBuyer = 0;
    mapping (address => userStr) public buyer;
    
    // Buy event
    event Buy(address _investor, uint256 _amount, uint256 _tokenAmount);
    event Updated(uint _startsAt, uint _endsAt, uint _price, uint _maxBuy, uint _hardCap);

    constructor(address _token, address payable _preSaleWallet, uint256 _startsAt, uint256 _endsAt) public {
        token = IERC20(_token);
        preSaleWallet = _preSaleWallet;
        startsAt = _startsAt;
        endsAt = _endsAt;
    }

    receive() external payable {
        buy();
    }

    function buy() public payable returns (bool) {
        require(buyer[_msgSender()].weis < maxBuy, "Max Buy Reached");
        require(startsAt < block.timestamp && endsAt > block.timestamp && tokensSold < hardCap, "PreSale not running");

        uint tokensAmount = 0;
        uint weiAmount = msg.value;

        tokensAmount = uint(weiAmount).div(price);

        if(uint(tokensSold).add(tokensAmount) > hardCap){
            tokensAmount = uint(hardCap).sub(tokensSold);
            weiAmount = tokensAmount.mul(price);
            _msgSender().transfer(uint(msg.value).sub(weiAmount));
        }

        if(uint(buyer[_msgSender()].weis).add(weiAmount) > maxBuy){
            weiAmount = uint(maxBuy).sub(buyer[_msgSender()].weis);
            tokensAmount = weiAmount.div(price);
            _msgSender().transfer(uint(msg.value).sub(weiAmount));
        }

        if(!buyer[_msgSender()].isExist){
            userStr memory buyerInfo;
            
            noOfBuyer++;

            buyerInfo = userStr({
                isExist: true,
                id: noOfBuyer,
                weis: weiAmount,
                tokens: tokensAmount
            });

            buyer[_msgSender()] = buyerInfo;
        }else{
            buyer[_msgSender()].weis += weiAmount;
            buyer[_msgSender()].tokens += tokensAmount;
        }

        weiRaised += weiAmount;
        tokensSold += tokensAmount;

        token.transferFrom(preSaleWallet, _msgSender(), tokensAmount);

         // Emit an event that shows Buy successfully
        emit Buy(_msgSender(), msg.value, tokensAmount);

        return true;
    }

    function withdrawal() public returns (bool) {
        // Transfer Fund to owner's address
        preSaleWallet.transfer(address(this).balance);
        return true;
    }

    function updateSale(uint _startsAt, uint _endsAt, uint _price, uint _maxBuy, uint _hardCap) public returns (bool) {
        startsAt = _startsAt;
        endsAt = _endsAt;
        price = _price;
        maxBuy = _maxBuy;
        hardCap = _hardCap;
        emit Updated(_startsAt, _endsAt, _price, _maxBuy, _hardCap);
        return true;
    }
}