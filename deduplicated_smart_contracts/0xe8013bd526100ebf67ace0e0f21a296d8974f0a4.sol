/**

 *Submitted for verification at Etherscan.io on 2019-04-19

*/



pragma solidity ^0.5.7;



/**

 * Copy right (c) Donex UG (haftungsbeschraenkt)

 * All rights reserved

 * Version 0.2.1 (BETA)

 */



contract Oracle {



    mapping(uint256 => uint256) price;

    mapping(uint256 => bool) public available;

    address owner;



    event PriceAvailable

    (

        uint256 date,

        uint256 price

    );



    constructor()

        public

    {

        owner = msg.sender;

    }



    function sendPrice(uint256 date)

        external

        view

        returns (uint256)

    {

        require(available[date] == true);

        return price[date];

    }



    function setPrice(uint256 date, uint256 priceAtDate)

        public

    {

        require(msg.sender == owner);

        price[date] = priceAtDate;

        available[date] = true;

        emit PriceAvailable(date,priceAtDate);

    }



}