/**

 *Submitted for verification at Etherscan.io on 2018-11-26

*/



pragma solidity ^0.4.24;



library SafeMath {

    function add(uint256 a, uint256 b)

        internal

        pure

        returns (uint256 c) 

    {

        c = a + b;

        require(c >= a, "SafeMath add failed");

        return c;

    }

}



contract RandomNumber {

	using SafeMath for *;



	address _owner;

	uint24 private _number;

	uint256 private _id;

    event onNewNumber

    (

        uint24 number,

        uint256 id

    );

	

	constructor() 

		public 

	{

		_owner = msg.sender;

		_id = 0;

		_number = 0;

	}

	

	function getNumber() 

		public 

		view 

		returns (uint24) 

	{

		return _number;

	}



	function getId() 

		public 

		view 

		returns (uint256) 

	{

		return _id;

	}





	function genNumber(uint256 id) 

		public 

		returns (uint24) 

	{

		_id = id;

		_number = random();

		emit RandomNumber.onNewNumber (

			_number,

			_id

		);

		return _number;

	}



    function random()  

    	private 

    	view 

    	returns (uint24)

    {

        uint256 randnum = uint256(keccak256(abi.encodePacked(

            

            (block.timestamp).add

            (block.difficulty).add

            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add

            (block.gaslimit).add

            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add

            (block.number)

            

        )));

        randnum = (randnum%1000000);

        if(randnum<100000 || randnum>999999){

            random();

        }

        else return uint24(randnum);

    }

    

}