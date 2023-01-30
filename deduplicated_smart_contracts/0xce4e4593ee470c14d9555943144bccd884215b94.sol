/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
interface OX{function mint(address w,uint256 a)external returns(bool);function burn(address w,uint256 a)external returns(bool);}
contract MARKET{modifier o{require(_o==msg.sender);_;}address private _o;address private st;address public ro;uint256 public rt;
function srt(uint256 i)external o{rt=i;}function sst(address a)external o{st=a;}function sro(address a)external o{ro=a;}
function esc(address w)external payable returns(bool){require(msg.value>=10**15);uint256 g=msg.value*(10**18)/rt;
require(OX(ro).mint(w,g)&&OX(ro).burn(st,g));return true;}function exp()external o{_tp(_o).transfer(address(this).balance);}
function _tp(address a)internal pure returns(address payable){return address(uint160(a));}
fallback()external{revert();}constructor(){_o=msg.sender;rt=3*(10**16);}}