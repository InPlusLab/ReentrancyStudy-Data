/**
 *Submitted for verification at Etherscan.io on 2019-11-16
*/

pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;
/*-
 * Copyright (c) 2019 @secondphonejune
 * All rights reserved.
 *
 * This code is derived by @secondphonejune (Telegram ID)
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * This project is originally created to implement an election for 2019 Hong Kong local elections.
 * Ofcause the Hong Kong government is not going to use it, but we have a chance to show that how an election can be done completely anonymously with blockchain
 * Everyone can use the code provided in this project, but they must keep this statement here unchanged.
 * Fight for freedom, Stand with Hong Kong
 * Five Demands, Not One Less
 */
/*
* Expected workflow, voter get his/her voter ID from contract, this makes sure no one has access to his/her personal data
* Second, the voter registers their voter ID and email (not phone as no money to do SMS) via a vote box and make a vote.
* Email is checked by the voter box to prevent double voting and robot voting, but there should be a better way to do it.
* Now registration will make old registration and votes from the same voter ID invalid
* The vote will then encrypted using a public key and submitted to this contract for record
* After the election, the private key will be made public and people can decrypt the votes and knows who wins
* Currently we let the vote box decides if a new vote should replace the old vote, but there should be a better way to do it
* Also if people can read the private variable voteListByVoter from blockchain, they will know who a person votes after election. 
* The variable is needed for replacing old votes. 
* This variable should be removed when there is a proper way to authenticate a person and replacing vote is not needed. 
*/
contract electionList{
	string public hashHead;
    //This one keeps the council list for easy checking by public
	string[] public councilList;
	uint256 public councilNumber;
}
contract localElection{
    address payable public owner;
    string public encryptionPublicKey; //Just keep record on the vote encryption key
    bool public isRunningElection = false;
	//vote box exists only because most people do not own a crypto account.
	//vote box are needed to encrypt and submit votes for people and do email validations
	//Once the election is over, vote box also need to get votes from the contract and decrypt the votes
	mapping(address => bool) public approvedVoteBox;
	
	//This one is dummy list as the voter list is hidden from public
	//Even in real case, this one only keeps the hash of the voter information, so no private data is leaked
	//With the same name and HKID (voter), a person can only vote in one council
	//The following information is created and verified by government before the election, 
	//but in this 2019 election even voter list is hidden from people. 
	//We setup register function for people to register just before they vote
	mapping(uint256 => bool) public voterList;
	mapping(uint256 => uint256) public usedPhoneNumber;
	mapping(uint256 => mapping(string => bool)) public councilVoterList;
	mapping(string => uint) public councilVoterNumber;
	
	//This one keeps the votes, but arranged by voter so it is easy to check if someone has voted
	//This file must be kept private as it links a person to a vote, 
	//people can find back who a person voted after the election 
	//If there is an electronic way for public to really verify a person to do the voting,
	//there will be no need to setup replaceVote function. 
	//We can safely remove the link between vote and voter
	mapping(uint256 => string) private voteListByVoter; 
	mapping(string => string[]) private votes; //Votes grouped by council
	mapping(address => string[]) private voteByVotebox; //Votes grouped by votebox
	mapping(string => bool) private voteDictionary; //Makre sure votes are unique
	mapping(string => address) public invalidVotes;
	
	address public dbAddress;
	
	constructor(address electionDBaddr,string memory pKey) public{
	    owner = msg.sender;
	    dbAddress = electionDBaddr;
	    encryptionPublicKey = pKey;
	}
	
	function() external payable { 
		//Thank you for donation, it will be sent to the owner. 
		//The owner will send it to ÐÇ»ð after deducting the cost (if they have ETH account)
		if(address(this).balance >= msg.value && msg.value >0) 
            owner.transfer(msg.value);
	}
	//Just in case someone manage to give ETH to this contract
	function withdrawAll() public payable{
	    if(address(this).balance >0) owner.transfer(address(this).balance);
	}
	function addVoteBox(address box) public {
		if(msg.sender != owner) revert();
		approvedVoteBox[box] = true;
	}
	function removeVoteBox(address box) public {
		if(msg.sender != owner) revert();
		approvedVoteBox[box] = false;
		//Also remove all votes in that votebox from the election result
		electionList db = electionList(dbAddress);
		for(uint i=0;i<db.councilNumber();i++){
		    for(uint a=0;a<voteByVotebox[box].length;a++){
		        if(bytes(voteByVotebox[box][a]).length >0){
		            invalidVotes[voteByVotebox[box][a]] = msg.sender;
		        }
		    }
		}
	}
	function getVoteboxVoteCount(address box) public view returns(uint256){
	    return voteByVotebox[box].length;
	}
	function getCouncilVoteCount(string memory council) public view returns(uint256){
	    return votes[council].length;
	}
	function startElection() public {
	    if(msg.sender != owner) revert();
	    isRunningElection = true;
	}
	function stopElection() public {
	    if(msg.sender != owner) revert();
	    isRunningElection = false;
	}
	//This function allows people to generate a voterID to register and vote.
	//Supposingly this ID should be random so that people do not know who it belongs to, 
	//and each person has only one unique ID so they cannot double vote. 
	//It means a public key pair binding with identity / hash of identity. 
	//As most people do not have a wallet, we can only make sure each person has one ID only
	function getVoterID(string memory name, string memory HKID) 
		public view returns(uint256){
		electionList db = electionList(dbAddress);
		if(!checkHKID(HKID)) return 0;
		return uint256(sha256(joinStrToBytes(db.hashHead(),name,HKID)));
	}
	//function getphoneHash(uint number)
	function getEmailHash(string memory email)
		public view returns(uint256){
		//return uint256(sha256(joinStrToBytes(hashHead,uint2str(number),"")));
		electionList db = electionList(dbAddress);
		return uint256(sha256(joinStrToBytes(db.hashHead(),email,"")));
	}
	//function register(uint256 voterID, uint256 hashedPhone, string memory council)
	function register(uint256 voterID, uint256 hashedEmail, string memory council) 
		public returns(bool){
		require(isRunningElection);
		require(approvedVoteBox[msg.sender]);
		//Register happens during election as we do not have the voter list
		//require(now >= votingStartTime);
		//require(now < votingEndTime);
		if(voterList[voterID]) deregister(voterID);
		//if(usedPhoneNumber[hashedPhone] > 0)
			//deregister(usedPhoneNumber[hashedPhone]);
		if(usedPhoneNumber[hashedEmail] > 0)
			deregister(usedPhoneNumber[hashedEmail]);
		voterList[voterID] = true;
		//usedPhoneNumber[hashedPhone] = voterID;
		usedPhoneNumber[hashedEmail] = voterID;
		councilVoterList[voterID][council] = true;
		councilVoterNumber[council]++;
		return true;
	}
	function deregister(uint256 voterID) 
		internal returns(bool){
		require(isRunningElection);
		voterList[voterID] = false;	
		electionList db = electionList(dbAddress);
		for(uint i=0;i<db.councilNumber();i++){
			//deregister them from the other councils
			if(councilVoterList[voterID][db.councilList(i)]){
				councilVoterList[voterID][db.councilList(i)] = false;
				councilVoterNumber[db.councilList(i)]--;
			}
		}
		if(bytes(voteListByVoter[voterID]).length >0){
			invalidVotes[voteListByVoter[voterID]] = msg.sender;
			delete voteListByVoter[voterID];
		}
		return true;
	}
	//function isValidVoter(uint256 voterID, uint256 hashedPhone, string memory council)
	function isValidVoter(uint256 voterID, uint256 hashedEmail, string memory council) 
		public view returns(bool){
		if(!voterList[voterID]) return false;
		//if(usedPhoneNumber[hashedPhone] == 0 || usedPhoneNumber[hashedPhone] != voterID)
		if(usedPhoneNumber[hashedEmail] == 0 || usedPhoneNumber[hashedEmail] != voterID)
			return false;
		if(!councilVoterList[voterID][council]) return false;
		return true;
	}
	function isVoted(uint256 voterID) public view returns(bool){
		if(bytes(voteListByVoter[voterID]).length >0) return true;
		return false;
	}
	//function submitVote(uint256 voterID, uint256 hashedPhone, 
	function submitVote(uint256 voterID, uint256 hashedEmail, 
	    string memory council, string memory singleVote) public returns(bool){
		require(isRunningElection);
		require(approvedVoteBox[msg.sender]);
		//require(now >= votingStartTime);
		//require(now < votingEndTime);
		//require(isValidVoter(voterID,hashedPhone,council));
		require(isValidVoter(voterID,hashedEmail,council));
		require(!isVoted(voterID)); //Voted already
		require(!voteDictionary[singleVote]);
		voteListByVoter[voterID] = singleVote;
		votes[council].push(singleVote);
		voteByVotebox[msg.sender].push(singleVote);
		voteDictionary[singleVote] = true;
		return true;
	}
	
	//function replaceVote(uint256 voterID, uint256 hashedPhone,
	/*function replaceVote(uint256 voterID, uint256 hashedEmail, 
	    string memory council, string memory singleVote) public returns(bool){
		require(isRunningElection);
		require(approvedVoteBox[msg.sender]);
		//require(now >= votingStartTime);
		//require(now < votingEndTime);
		//require(isValidVoter(voterID,hashedPhone,council));
		require(isValidVoter(voterID,hashedEmail,council));
		require(!voteDictionary[singleVote]);
		if(bytes(voteListByVoter[voterID]).length >0){
		    electionList db = electionList(dbAddress);
			for(uint i=0;i<db.councilNumber();i++){
				//reduce the vote count in the previous council
				if(councilVoterList[voterID][db.councilList(i)]){
					councilVoteCount[db.councilList(i)]--;					
				}
			}
			invalidVotes[voteListByVoter[voterID]] = msg.sender;
			delete voteListByVoter[voterID];
		}
		voteListByVoter[voterID] = singleVote;
		votes[council].push(singleVote);
		councilVoteCount[council]++;
		voteDictionary[singleVote] = true;
		return true;
	}*/
	function registerAndVote(uint256 voterID, uint256 hashedEmail, 
	    string memory council, string memory singleVote) public returns(bool){
	    if(register(voterID,hashedEmail,council) 
	        && submitVote(voterID,hashedEmail,council,singleVote))
	        return true;
	    return false;
	}
	
	function getResult(string memory council) public view returns(uint, uint, uint, uint, 
		string[] memory, string[] memory){
		require(!isRunningElection);
		//require(now >= votingEndTime);
		uint totalVoteCount = votes[council].length;
		uint validVoteCount;
		//uint invalidCount;
		for(uint i=0;i<totalVoteCount;i++){
			string memory singleVote = votes[council][i];
			if(invalidVotes[singleVote] == address(0)){
			    validVoteCount++;   
			}
			//else invalidCount++;
		}
		//assert((validVoteCount+invalidCount) == totalVoteCount);
		string[] memory validVoteIndex = new string[](validVoteCount);
		string[] memory invalidVoteIndex = new string[](totalVoteCount-validVoteCount);
		uint a=0;
		for(uint i=0;i<totalVoteCount && (a<validVoteCount || validVoteCount==0);i++){
			string memory singleVote = votes[council][i];
			if(invalidVotes[singleVote] == address(0)){
			    validVoteIndex[a++] = singleVote;
			}else{
			    invalidVoteIndex[i-a] = singleVote;
			}
		}
		return (councilVoterNumber[council],totalVoteCount,validVoteCount,
		    totalVoteCount-validVoteCount,validVoteIndex,invalidVoteIndex);
	}
	
	function joinStrToBytes(string memory _a, string memory _b, string memory _c) 
		internal pure returns (bytes memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
		bytes memory _bc = bytes(_c);
        string memory ab = new string(_ba.length + _bb.length + _bc.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
		for (uint i = 0; i < _bc.length; i++) bab[k++] = _bc[i];		
        //return string(bab);
        return bab;
    }
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
		if (_i == 0) {
			return "0";
		}
		uint j = _i;
		uint len;
		while (j != 0) {
			len++;
			j /= 10;
		}
		bytes memory bstr = new bytes(len);
		uint k = len - 1;
		while (_i != 0) {
			bstr[k--] = byte(uint8(48 + _i % 10));
			_i /= 10;
		}
		return string(bstr);
	}
	//Sample G123456A AB9876543, C1234569 invalid sample AY987654A C668668E
	function checkHKID(string memory HKID) 
		internal pure returns(bool){
		bytes memory b = bytes(HKID);
		if(b.length !=8 && b.length !=9) return false;
		uint256 checkDigit = 0;
		uint256 power = 9;
		if(b.length ==8){
			checkDigit += (36*power);
			power--;
		}
		for(uint i=0;i<b.length;i++){
			uint digit = uint8(b[i]);
			if(i>(b.length-8) && i<(b.length-1)){
				//It should be a number
				if(digit < 48 || digit > 57) return false;
			}
			if(digit >=48 && digit<=57) checkDigit += ((digit-48)*power); //Number
			else if(digit >=65 && digit<=90) checkDigit += ((digit-55)*power); //A-Z
			else return false;
			power--;
		}
		if(checkDigit % 11 == 0) return true;
		return false;
	}
}