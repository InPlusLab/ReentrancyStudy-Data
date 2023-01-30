/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity 0.5.3;

/** By signing on to this agreement, you agree that any contributions your ETH address makes 
 * to any software, repository, bounty, organization, or any other form of work product
 * are governed by the terms of this License. 
 * 
 * You may opt into or out of this License at any time by using the "sign" or "unsign"
 * functions below. However any contributions in progress or made prior to unsigning may still 
 * be governed by the terms of this License or any other contractual obligations you enter into.
 * 
 * This agreement was sourced from https://opensource.org/licenses/MIT
 * 
 * Copyright <YEAR> <COPYRIGHT HOLDER>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 * and associated documentation files (the "Software"), to deal in the Software without restriction, 
 * including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * End license text.

*/ 

contract License {
    
    mapping (address => bool) signatories;
    
    function sign() public {
        signatories[msg.sender] = true;
    }
        
    function unsign() public {
        signatories[msg.sender] = false;
    }
        
    function did_address_sign(address _address) public view returns (bool) {
        return signatories[_address];
    }
}