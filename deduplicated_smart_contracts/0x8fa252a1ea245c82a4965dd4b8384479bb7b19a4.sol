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

contract GoogleAdsSetherAPI is SetherAPIBase {
    
    function get_google_adwords_video_views(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 accountId, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-adwords-video-views");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, accountId, requestID);
    }

    function get_google_adwords_impressions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 accountId, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-adwords-impressions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, accountId, requestID);
    }

    function get_google_adwords_ctr(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 accountId, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-adwords-ctr");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, accountId, requestID);
    }

    function get_google_adwords_conversions(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 accountId, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-adwords-conversions");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, accountId, requestID);
    }

    function get_google_adwords_clicks(
                bytes32 setherToken, 
                string memory authToken, 
                bytes32 date, 
                bytes32 targetId, 
                uint8 level, 
                bytes32 accountId, 
                bytes32 requestID)
                public
    {
        bytes32 kpi_bytes32 = stringToBytes32("google-adwords-clicks");
        emit SetherEvent(kpi_bytes32, setherToken, authToken, 
                date, targetId, level, accountId, requestID);
    }
}