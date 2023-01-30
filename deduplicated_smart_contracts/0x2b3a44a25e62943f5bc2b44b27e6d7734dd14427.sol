// erc-otc.sol
//
// This program is free software: you can redistribute it and/or modify it
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//

pragma solidity ^0.4.18;

import "./math.sol";

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}

contract EventfulMarket {

    event LogMake(
        bytes32  indexed  id,
        address  indexed  maker,
        uint           pay_amt,
        uint           buy_amt,
        address     erc20Address,
        uint64            timestamp,
        uint              escrowType
    );

    event LogTake(
        bytes32           id,
        address  indexed  maker,
        address  indexed  taker,
        uint          take_amt,
        uint           give_amt,
        address     erc20Address,
        uint64            timestamp,
        uint              escrowType
    );

    event LogKill(
        bytes32  indexed  id,
        address  indexed  maker,
        uint           pay_amt,
        uint           buy_amt,
        address     erc20Address,
        uint64            timestamp,
        uint              escrowType
    );
}

contract ERCOTC is EventfulMarket, DSMath {

    address devAddress;
    uint constant devFee = 500; //500 for 0.2%;
    
    uint public last_offer_id;
    uint public last_token_id;
    mapping (uint => OfferInfo) public offers;
    mapping (uint => address) public tokens;
    mapping (address => bool) public validToken;
    
    bool locked;

    struct OfferInfo {
        uint     pay_amt;
        uint     buy_amt;
        address  owner;
        uint64   timestamp;
        bytes32  offerId;
        address  erc20Address;
        uint     escrowType; //0 ERC - 1 ETH
    }

    modifier can_buy(uint id) {
        require(isActive(id), "cannot buy, offer ID not active");
        _;
    }

    modifier can_cancel(uint id) {
        require(isActive(id), "cannot cancel, offer ID not active");
        require(getOwner(id) == msg.sender, "cannot cancel, msg.sender not the same as offer maker");
        _;
    }

    modifier can_offer {
        _;
    }

    modifier synchronized {
        require(!locked, "Sync lock");
        locked = true;
        _;
        locked = false;
    }

    constructor() public{
        devAddress = msg.sender;
    }

    function isActive(uint id) public view returns (bool active) {
        return offers[id].timestamp > 0;
    }

    function getOwner(uint id) public view returns (address owner) {
        return offers[id].owner;
    }

    function getOffer(uint id) public view returns (uint, uint, address, bytes32) {
      var offer = offers[id];
      return (offer.pay_amt, offer.buy_amt, offer.erc20Address, offer.offerId);
    }

    // ---- Public entrypoints ---- //

    function addERC(address erc20Address)
        public
    {
        require(erc20Address != address(0));
        require(isContract(erc20Address));
        require(validToken[erc20Address] == false);
        tokens[_next_token_id()] = erc20Address;
        validToken[erc20Address] = true;
    }
        
    // Transfers funds from caller to
    // offer maker, and from market to caller.
    function buyERC(uint id, address ref)
        public
        payable
        can_buy(id)
        synchronized
        returns (bool)
    {
        OfferInfo memory offer = offers[id];
        ERC20 erc20Interface = ERC20(offers[id].erc20Address);
        require(offer.escrowType == 0, "Incorrect escrow type");
        require(msg.value > 0 && msg.value == offer.buy_amt, "msg.value error");
        require(offer.buy_amt > 0 && offer.pay_amt > 0);

        //calc amounts
        uint ethValue = sub(offer.buy_amt, (offer.buy_amt / devFee));
        uint erc20Value = sub(offer.pay_amt, (offer.pay_amt / devFee));
        uint ethFee;
        uint erc20Fee;
        if(ref == address(0)){//no ref
            ethFee = offer.buy_amt / devFee;//0.2%
            erc20Fee = offer.pay_amt / devFee;//0.2%
            //send
            offer.owner.transfer(ethValue);//send eth to offer maker (seller)
            devAddress.transfer(ethFee);//send eth devfee
            require(erc20Interface.transfer(msg.sender, erc20Value), "Transfer failed"); //send escrowed token from contract to offer taker (buyer)
            require(erc20Interface.transfer(devAddress, erc20Fee), "Dev Transfer failed"); //send token devfee
        }
        else{//ref (50% of devfee)
            ethFee = offer.buy_amt / mul(devFee, 2);//0.1% (send twice)
            erc20Fee = offer.pay_amt / mul(devFee, 2);//0.1% (send twice)
            //send
            offer.owner.transfer(ethValue);//send eth to offer maker (seller)
            devAddress.transfer(ethFee);//send eth devfee
            ref.transfer(ethFee);//send eth to refferer
            require(erc20Interface.transfer(msg.sender, erc20Value), "Transfer failed"); //send escrowed token from contract to offer taker (buyer)
            require(erc20Interface.transfer(devAddress, erc20Fee), "Dev Transfer failed"); //send token devfee
            require(erc20Interface.transfer(ref, erc20Fee), "Ref Transfer failed"); //send token devfee
        }

        //events
        emit LogTake(
            bytes32(id),
            offer.owner,
            msg.sender,
            uint(erc20Value),
            uint(ethValue),
            offer.erc20Address,
            uint64(now),
            offer.escrowType
        );

        //delete offer
        offers[id].pay_amt = 0;
        offers[id].buy_amt = 0;
        delete offers[id];
        
        return true;
    }

    // Transfers funds from caller to
    // offer maker, and from market to caller.
    function buyETH(uint id, address ref)
        public
        can_buy(id)
        synchronized
        returns (bool)
    {
        OfferInfo memory offer = offers[id];
        ERC20 erc20Interface = ERC20(offers[id].erc20Address);
        require(offer.escrowType == 1, "Incorrect escrow type");
        require(erc20Interface.balanceOf(msg.sender) >=  offer.buy_amt, "Balance is less than requested spend amount");
        require(offer.pay_amt > 0 && offer.buy_amt > 0);
        //calc amounts
        uint ethValue = sub(offer.pay_amt, (offer.pay_amt/ devFee));
        uint erc20Value = sub(offer.buy_amt, (offer.buy_amt / devFee));
        uint ethFee;
        uint erc20Fee;
        if(ref == address(0)){//no ref
            ethFee = offer.pay_amt / devFee;//0.2%
            erc20Fee = erc20Fee / devFee;//0.2%
            //send
            require(erc20Interface.transferFrom(msg.sender, offer.owner, erc20Value), "Transfer failed");//send token to offer maker (seller)
            require(erc20Interface.transferFrom(msg.sender, devAddress, erc20Fee), "Dev transfer failed");//send token devfee
            msg.sender.transfer(ethValue);//send ETH to offer taker (buyer)
            devAddress.transfer(ethFee);//send eth devfee
        }
         else{//ref
            ethFee =  offer.pay_amt / mul(devFee, 2);//0.1% (send twice)
            erc20Fee = erc20Fee / mul(devFee, 2);//0.1% (send twice)
            //send
            require(erc20Interface.transferFrom(msg.sender, offer.owner, erc20Value), "Transfer failed");//send token to offer maker (seller)
            require(erc20Interface.transferFrom(msg.sender, devAddress, erc20Fee), "Dev Transfer failed");//send token devfee
            require(erc20Interface.transferFrom(msg.sender, ref, erc20Fee), "Ref transfer failed");//send token devfee
            msg.sender.transfer(ethValue);//send ETH to offer taker (buyer)
            devAddress.transfer(ethFee);//send eth devfee
            ref.transfer(ethFee);//send eth to ref
         }

        //events
        emit LogTake(
            bytes32(id),
            offer.owner,
            msg.sender,
            uint(offer.buy_amt),
            uint(offer.pay_amt),
            offer.erc20Address,
            uint64(now),
            offer.escrowType
        );
        
        //delete offer
        offers[id].pay_amt = 0;
        offers[id].buy_amt = 0;
        delete offers[id];

        return true;
    }

    // cancel an offer, refunds offer maker.
    function cancel(uint id)
        public
        can_cancel(id)
        synchronized
        returns (bool success)
    {
        // read-only offer. Modify an offer by directly accessing offers[id]
        OfferInfo memory offer = offers[id];
        delete offers[id];
        ERC20 erc20Interface = ERC20(offer.erc20Address);
        if(offer.escrowType == 0){ // erc
            require(erc20Interface.transfer(offer.owner, offer.pay_amt), "Transfer failed");
        }
        else{ //eth
            offer.owner.transfer(offer.pay_amt);
        }
        emit LogKill(
            bytes32(id),
            offer.owner,
            uint(offer.pay_amt),
            uint(offer.buy_amt),
            offer.erc20Address,
            uint64(now),
            offer.escrowType
        );

        success = true;
    }

    //cancel
    function kill(bytes32 id)
        public
    {
        require(cancel(uint256(id)), "Error on cancel order.");
    }

    //make
    function make(
        uint  pay_amt,
        uint  buy_amt,
        address erc20Address
    )
        public
        payable
        returns (bytes32 id)
    {
        if(msg.value > 0){
            return bytes32(offerETH(pay_amt, buy_amt, erc20Address));
        }
        else{
            return bytes32(offerERC(pay_amt, buy_amt, erc20Address));
        }
    }

    // make a new offer to sell ETH. Takes ETH funds from the caller into market escrow.
    function offerETH(uint pay_amt, uint buy_amt, address erc20Address) //amounts in wei / token
        public
        payable
        can_offer
        synchronized
        returns (uint id)
    {
        //check amounts
        require(pay_amt > 0, "pay_amt is 0");
        require(buy_amt > 0, "buy_amt is 0");
        require(pay_amt == msg.value, "pay_amt not equal to msg.value");
        //check address
        require(erc20Address != address(0));
        require(isContract(erc20Address));
        require(validToken[erc20Address]);
        //create new offer, no need to call transfer msg.value is escrowed
        newOffer(id, pay_amt, buy_amt, erc20Address, 1);
        emit LogMake(
            bytes32(id),
            msg.sender,
            uint(pay_amt),
            uint(buy_amt),
            erc20Address,
            uint64(now),
            1
        );
    }

    // make a new offer to sell token. Takes token funds from the caller into market escrow.
    function offerERC(uint pay_amt, uint buy_amt, address erc20Address) //amounts in token / wei
        public
        can_offer
        synchronized
        returns (uint id)
    {
        //check amounts
        require(pay_amt > 0, "pay_amt is 0");
        require(buy_amt > 0,  "buy_amt is 0");
        //check address
        require(erc20Address != address(0));
        require(isContract(erc20Address));
        require(validToken[erc20Address]);
        //check erc balance
        ERC20 erc20Interface = ERC20(erc20Address);
        require(erc20Interface.balanceOf(msg.sender) >= pay_amt, "Insufficient balanceOf token");
        //create new offer
        newOffer(id, pay_amt, buy_amt, erc20Address, 0);
        //make transfer to escrow
        require(erc20Interface.transferFrom(msg.sender, address(this), pay_amt), "Transfer failed");

        emit LogMake(
            bytes32(id),
            msg.sender,
            uint(pay_amt),
            uint(buy_amt),
            erc20Address,
            uint64(now),
            0
        );
    }

    //formulate new offer
    function newOffer(uint id, uint pay_amt, uint buy_amt, address erc20Address, uint escrowType)
        internal
    {
        OfferInfo memory info;
        info.pay_amt = pay_amt;
        info.buy_amt = buy_amt;
        info.owner = msg.sender;
        info.timestamp = uint64(now);
        info.erc20Address = erc20Address;
        info.escrowType = escrowType;
        id = _next_id();
        info.offerId = bytes32(id);
        offers[id] = info;
    }

    //take
    function take(bytes32 id, address ref)
        public
        payable
    {
        if(msg.value > 0){
            require(buyERC(uint256(id), ref), "Buy ERC failed");
        }
        else{
            require(buyETH(uint256(id), ref), "Sell ERC failed");
        }

    }

    //is contract? subject to reentrancy attack yet not applicable with currect require checks, just extra security
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    //get next id
    function _next_id()
        internal
        returns (uint)
    {
        last_offer_id++;
        return last_offer_id;
    }

        //get next id
    function _next_token_id()
        internal
        returns (uint)
    {
        last_token_id++;
        return last_token_id;
    }
}