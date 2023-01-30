// sendlimiter
// limit funds held on a contract
// @authors:
// Cody Burns <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0c686362787c6d62656f4c6f6368757b6e797e627f226f6361">[email&#160;protected]</a>>
// license: Apache 2.0
// version:

pragma solidity ^0.4.19;

// Intended use:  
// cross deploy to limit funds on a chin identifier
// Status: functional
// still needs:
// submit pr and issues to https://github.com/realcodywburns/
//version 0.1.0


contract sendlimiter{
 function () public payable {
     require(this.balance + msg.value < 100000000);}
}