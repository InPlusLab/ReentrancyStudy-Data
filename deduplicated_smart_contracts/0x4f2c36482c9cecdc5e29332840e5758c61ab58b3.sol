// SPDX-License-Identifier: BSD-3-Clause

/** 
*                                                                                                                                  
*       ##### /                                                             #######      /                                         
*    ######  /          #                                                 /       ###  #/                                          
*   /#   /  /          ###                                               /         ##  ##                                          
*  /    /  /            #                                                ##        #   ##                                          
*      /  /                                                               ###          ##                                          
*     ## ##           ###        /###    ###  /###         /###          ## ###        ##  /##      /###    ###  /###       /##    
*     ## ##            ###      / ###  /  ###/ #### /     / #### /        ### ###      ## / ###    / ###  /  ###/ #### /   / ###   
*     ## ##             ##     /   ###/    ##   ###/     ##  ###/           ### ###    ##/   ###  /   ###/    ##   ###/   /   ###  
*     ## ##             ##    ##    ##     ##    ##   k ####                  ### /##  ##     ## ##    ##     ##         ##    ### 
*     ## ##             ##    ##    ##     ##    ##   a   ###                   #/ /## ##     ## ##    ##     ##         ########  
*     #  ##             ##    ##    ##     ##    ##   i     ###                  #/ ## ##     ## ##    ##     ##         #######   
*        /              ##    ##    ##     ##    ##   z       ###                 # /  ##     ## ##    ##     ##         ##        
*    /##/           /   ##    ##    ##     ##    ##   e  /###  ##       /##        /   ##     ## ##    /#     ##         ####    / 
*   /  ############/    ### /  ######      ###   ###  n / #### /       /  ########/    ##     ##  ####/ ##    ###         ######/  
*  /     #########       ##/    ####        ###   ### -    ###/       /     #####       ##    ##   ###   ##    ###         #####   
*  #                                                  w               |                       /                                    
*   ##                                                e                \)                    /                                     
*                                                     b                                     /                                      
*                                                                                          /                                       
*
*
* Lion's Share is the very first true follow-me matrix smart contract ever created.
* Now you can build an organization and earn on up to 15 levels.
* https://www.lionsshare.io
* Get your share, join today!
*/

pragma solidity ^0.6.8;

import './DataStorage.sol';
import './Access.sol';
import './Events.sol';

contract Proxy is DataStorage, Access, Events {
  
  constructor(address _proxied) public {
    owner = msg.sender;
    proxied = _proxied;

    reentryStatus = ENTRY_ENABLED;
    contractEnabled = false;
  }

  fallback() external payable {
    address proxy = proxied;

    assembly {
      calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), proxy, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 { revert(0, returndatasize()) }
        default { return(0, returndatasize()) }
    }
  }

  receive() external payable {
    address proxy = proxied;

    assembly {
      calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), proxy, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 { revert(0, returndatasize()) }
        default { return(0, returndatasize()) }
    }
  }

  function setProxy(address _addr) external isOwner(msg.sender) {
    proxied = _addr;
  }
}