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

contract GoogleAnalyticsSetherAPI is SetherAPIBase {
    
    function get_google_website_users(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-website-users");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_google_website_time_on_site(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-website-time-on-site");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_google_website_sessions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-website-sessions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_google_website_page_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-website-page-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_google_website_new_users(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-website-new-users");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_google_website_new_sessions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-website-new-sessions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }

    function get_google_website_bounce_rate(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-website-bounce-rate");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, "", requestID);
    }
}