/**
 *Submitted for verification at Etherscan.io on 2019-10-11
*/

pragma solidity ^0.5.0;


contract SetherAPIBase {
    event SetherEvent(
        bytes32 setherKPI,
		bytes32 setherToken,
		string 	authToken,
        bytes32 date,
		bytes32 targetId,
		uint8 	level,
		bytes32 accountId,
		bytes32 requestID
	);

	function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}

contract TwitterSetherAPI is SetherAPIBase {
    
    function get_twitter_video_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("twitter-video-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_twitter_retweets(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("twitter-retweets");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_twitter_replies(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("twitter-replies");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_twitter_impressions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("twitter-impressions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_twitter_follows(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("twitter-follows");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_twitter_engagements(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("twitter-engagements");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_twitter_clicks(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("twitter-clicks");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }
}