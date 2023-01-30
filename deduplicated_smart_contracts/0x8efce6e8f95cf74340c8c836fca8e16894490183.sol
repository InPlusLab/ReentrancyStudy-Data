// sendblocker
// prevent any funds from incoming
// @authors:
// Cody Burns <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="47232829333726292e24072428233e3025323529346924282a">[email&#160;protected]</a>>
// license: Apache 2.0
// version:

pragma solidity ^0.4.19;

// Intended use:  
// cross deploy to prevent unintended chain getting funds
// Status: functional
// still needs:
// submit pr and issues to https://github.com/realcodywburns/
//version 0.1.0

contract sendblocker{
 function () public {assert(0>0);}
    
}