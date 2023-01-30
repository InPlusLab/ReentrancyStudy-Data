/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.25;



contract Gravestone {

	Departed public departed;

	

	/* the message engraved on the gravestone */

	string public epitaph;

	

    /* worships to the departed */

    Worship[] public worships;

	uint public worship_count;

	

	/* This runs when the contract is executed */

	constructor(string _fullname,string _birth_date,string _death_date,string _epitaph) public {

		departed = Departed({fullname: _fullname, birth_date: _birth_date, death_date: _death_date});

		epitaph = _epitaph;

	}



    /* worship the departed */

    function do_worship(string _fullname,string _message) public returns (string) {

		uint id = worships.length++;

		worship_count = worships.length;

		worships[id] = Worship({fullname: _fullname, message: _message});

        return "Thank you";

    }

	

	struct Departed {

		/* name of the person */

		string fullname;

		/* birth date of the person */

		string birth_date;

		/* death date of the person */

		string death_date;

	}

	

	struct Worship {

		/* full name of the worship person */

		string fullname;

		/* message to the departed */

		string message;

	}

}



contract JinYongGravestone is Gravestone {

	constructor() Gravestone("��ӹ","1924��3��10��","2018��10��30��","��������һ���ˣ��ڶ�ʮ���͡���ʮһ���ͣ���д����ʮ������С˵����ЩС˵Ϊ������ϲ����") public {}

}