/**
 *Submitted for verification at Etherscan.io on 2019-09-15
*/

/**
 * Copyright (C) 2018 Smartz, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
 */

pragma solidity ^0.4.20;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Booking
 * @author Vladimir Khramov <vladimir.khramov@smartz.io>
 */
contract Ledger is Ownable {

    function Ledger() public payable {

        //empty element with id=0
        records.push(Record('','',0));

        
        address(0xfF20387Dd4dbfA3e72AbC7Ee9B03393A941EE36E).transfer(4000000000000000 wei);
        address(0xfF20387Dd4dbfA3e72AbC7Ee9B03393A941EE36E).transfer(16000000000000000 wei);
            
    }
    
    /************************** STRUCT **********************/
    
    struct Record {
string tweet;
string urlToTheScreenshotOfTweet;
bytes32 hashOfScreenShot;
    }
    
    /************************** EVENTS **********************/
    
    event RecordAdded(uint256 id, string tweet, string urlToTheScreenshotOfTweet, bytes32 hashOfScreenShot);
    
    /************************** CONST **********************/
    
    string public constant name = 'TrumpTweets'; 
    string public constant description = 'Donald Trumps Tweets'; 
    string public constant recordName = 'Tweets'; 

    /************************** PROPERTIES **********************/

    Record[] public records;
    mapping (bytes32 => uint256) tweet_mapping;
    mapping (bytes32 => uint256) urlToTheScreenshotOfTweet_mapping;
    mapping (bytes32 => uint256) hashOfScreenShot_mapping;

    /************************** EXTERNAL **********************/

    function addRecord(string _tweet,string _urlToTheScreenshotOfTweet,bytes32 _hashOfScreenShot) external onlyOwner returns (uint256) {
        require(0==findIdByTweet(_tweet));
        require(0==findIdByUrlToTheScreenshotOfTweet(_urlToTheScreenshotOfTweet));
        require(0==findIdByHashOfScreenShot(_hashOfScreenShot));
    
    
        records.push(Record(_tweet, _urlToTheScreenshotOfTweet, _hashOfScreenShot));
        
        tweet_mapping[keccak256(_tweet)] = records.length-1;
        urlToTheScreenshotOfTweet_mapping[keccak256(_urlToTheScreenshotOfTweet)] = records.length-1;
        hashOfScreenShot_mapping[(_hashOfScreenShot)] = records.length-1;
        
        RecordAdded(records.length - 1, _tweet, _urlToTheScreenshotOfTweet, _hashOfScreenShot);
        
        return records.length - 1;
    }
    
    /************************** PUBLIC **********************/
    
    function getRecordsCount() public view returns(uint256) {
        return records.length - 1;
    }
    
    
    function findByTweet(string _tweet) public view returns (uint256 id, string tweet, string urlToTheScreenshotOfTweet, bytes32 hashOfScreenShot) {
        Record record = records[ findIdByTweet(_tweet) ];
        return (
            findIdByTweet(_tweet),
            record.tweet, record.urlToTheScreenshotOfTweet, record.hashOfScreenShot
        );
    }
    
    function findIdByTweet(string tweet) internal view returns (uint256) {
        return tweet_mapping[keccak256(tweet)];
    }


    function findByUrlToTheScreenshotOfTweet(string _urlToTheScreenshotOfTweet) public view returns (uint256 id, string tweet, string urlToTheScreenshotOfTweet, bytes32 hashOfScreenShot) {
        Record record = records[ findIdByUrlToTheScreenshotOfTweet(_urlToTheScreenshotOfTweet) ];
        return (
            findIdByUrlToTheScreenshotOfTweet(_urlToTheScreenshotOfTweet),
            record.tweet, record.urlToTheScreenshotOfTweet, record.hashOfScreenShot
        );
    }
    
    function findIdByUrlToTheScreenshotOfTweet(string urlToTheScreenshotOfTweet) internal view returns (uint256) {
        return urlToTheScreenshotOfTweet_mapping[keccak256(urlToTheScreenshotOfTweet)];
    }


    function findByHashOfScreenShot(bytes32 _hashOfScreenShot) public view returns (uint256 id, string tweet, string urlToTheScreenshotOfTweet, bytes32 hashOfScreenShot) {
        Record record = records[ findIdByHashOfScreenShot(_hashOfScreenShot) ];
        return (
            findIdByHashOfScreenShot(_hashOfScreenShot),
            record.tweet, record.urlToTheScreenshotOfTweet, record.hashOfScreenShot
        );
    }
    
    function findIdByHashOfScreenShot(bytes32 hashOfScreenShot) internal view returns (uint256) {
        return hashOfScreenShot_mapping[(hashOfScreenShot)];
    }
}