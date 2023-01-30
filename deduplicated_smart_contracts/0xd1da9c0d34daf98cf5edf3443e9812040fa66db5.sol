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

contract YoutubeAnalyticsSetherAPI is SetherAPIBase {
    
    function get_youtube_channel_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-channel-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_channel_subscribers(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-channel-subscribers");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_channel_comments(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-channel-comments");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_channel_likes(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-channel-likes");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_video_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-video-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_video_shares(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-video-shares");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_video_comments(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-video-comments");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_video_likes(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-video-likes");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_youtube_video_dislikes(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("youtube-video-dislikes");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }
}