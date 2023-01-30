pragma solidity ^0.4.24;

contract HelloWorldContact {
	string word = "Hello World";
	address owner;
	
	function HelloWorldContract() {
		owner = msg.sender;
	}

	function getWord() constant returns(string) {
		return word;
	}

	function setWord(string newWord) constant returns(string) {
		if (owner !=msg.sender) {
			return 'You shall not pass';
		}
		word = newWord;
		return 'You successfully changed the variable word';
	}
}