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

contract LinkedinSetherAPI is SetherAPIBase {
    
    function get_linkedin_viral_impressions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("linkedin-viral-impressions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_linkedin_video_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("linkedin-video-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_linkedin_likes(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("linkedin-likes");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_linkedin_impressions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("linkedin-impressions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_linkedin_follows(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("linkedin-follows");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_linkedin_engagements(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("linkedin-engagements");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_linkedin_clicks(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("linkedin-clicks");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }
}