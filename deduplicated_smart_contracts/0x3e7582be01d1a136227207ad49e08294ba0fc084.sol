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

contract InstagramSetherAPI is SetherAPIBase {
    
    function get_instagram_reach(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-reach");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_impressions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-impressions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_clicks(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-clicks");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_account_reach(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-account-reach");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_account_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-account-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_account_impressions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-account-impressions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_account_followers(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-account-followers");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_post_reach(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-post-reach");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_post_impressions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-post-impressions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_post_engagements(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-post-engagements");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_post_3s_video_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-post-3s-video-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_instagram_post_replies(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("instagram-post-replies");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }
}