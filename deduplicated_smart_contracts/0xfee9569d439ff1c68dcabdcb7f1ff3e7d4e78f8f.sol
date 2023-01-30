/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
abstract contract NC{function _s()internal view virtual returns(address payable){return msg.sender;}}
library SM{function ad(uint256 a,uint256 b)internal pure returns(uint256){uint256 c=a+b;require(c>=a,"+ovr");return c;}function sb(uint256 a,uint256 b)internal pure returns(uint256){return sb(a,b,"-ovr");} 
    function dv(uint256 a,uint256 b)internal pure returns(uint256){return dv(a,b,"/0");}function sb(uint256 a,uint256 b,string memory errorMessage)internal pure returns(uint256){require(b<=a,errorMessage);
    uint256 c=a-b;return c;}function ml(uint256 a,uint256 b)internal pure returns(uint256){if(a==0){return 0;} uint256 c=a*b;require(c/a==b,"*ovr");return c;}
    function dv(uint256 a,uint256 b,string memory errorMessage)internal pure returns(uint256){require(b>0,errorMessage);uint256 c=a/b;return c;}}
interface OX{function hdg(address w,address g,uint256 a)external returns(bool);function rt()external view returns(uint256);function balanceOf(address w)external view returns(uint256);
    function mint(address w,uint256 a)external returns(bool);function burn(address w,uint256 a)external returns(bool);function esc(address w)external payable returns(bool);
    function idd(address w)external view returns(uint256);function totalSupply()external view returns(uint256);}
contract FORGE is NC{using SM for uint256;modifier oa{require(_s()==tn[0]||_s()==tn[1]||_s()==tn[9]||_s()==tn[5]);_;}modifier oo{require(_s()==tn[0]||_s()==tn[1]);_;}modifier ot{require(_s()==tn[0]);_;}
	mapping(address=>uint256[8])private cu;mapping(address=>address)public rf;mapping(uint256=>uint256)public dr;mapping(address=>bool)private bn;address[10]private md;address[10]private gd;
	address[10]private tn;uint256[10]private ta;uint256[10]private cs;uint256[10]private tc; uint256 private ipr;uint256 public ecr;uint256 private hml;uint256 private _om;uint256 private om;uint256 public qw;
	function _fz(address w)internal view returns(uint256){uint256 z=cu[w][3];uint256 t=(block.timestamp.sb(cu[w][4])).dv(2629800);if(t>0&&cu[w][6]>=cu[w][1]){for(uint256 i=0;i<t;i++){z=z.sb(z.dv(10).ml(3));}
	}return z;}	function _rv(address w,uint256 a)internal returns(bool){address r=w;ta[6]=ta[6].ad(a.ml(63));cu[tn[8]][7]=cu[tn[8]][7].ad(a.ml(30)); for(uint256 j=0;j<5; j++){r=rf[r];if(bn[r]){
	cu[r][7]=cu[r][7].ad(a);}}cu[tn[9]][7]=cu[tn[9]][7].ad(a.ml(14));for(uint256 i=0;i<10;i++){cu[md[i]][7]=cu[md[i]][7].ad(a);}for(uint256 l=0;l<8; l++){cu[gd[l]][7]=cu[gd[l]][7].ad(a.dv(2));}return true;} 
	function sell(uint256 b)external returns(bool){require(!bn[_s()]&&_bl(_s()).sb(b)>=_fz(_s())&&b>999999);uint256 a=(b.ml(_ra())).dv(10**18);uint256 p=(ta[8].ml(b)).dv(_tr());ta[3]=ta[3].sb(b);
	ta[4]=ta[4].sb(b);ta[8]=ta[8].sb(p);ta[2]=(ta[2].ad(p)).sb(a);require(_br(_s(),b));ta[7]=_tr();ipr=ta[2].ml(10**18).dv(ta[7]);_tp(_s()).transfer(a);return true;} function com(uint256 i)external oo{om=i;}	
	function tbn(address w)external oo{for(uint256 i=0;i<10;i++){if(w==md[i]||w==gd[i]||w==tn[i]){revert();}}bn[w]=true;}function csm(uint256 i)external oo{ta[9]=i;}function cecr(uint256 i)external oa{ecr=i;}
	function chml(uint256 i)external ot{hml=i;}	function _ra()internal view returns(uint256){if(_tr()>0 && ta[7]>0){uint256 c=ta[7].ml(10**18).dv(_tr());return(ipr.ml(c)).dv(10**18);}else{return ipr;}}
	function _bg(uint256 a)internal returns(bool){require(OX(_tp(tn[7])).esc{value:a}(tn[5]));return true;}function _hg(address g,uint256 a)internal returns(bool){return OX(tn[4]).hdg(tn[5],g,a.dv(hml));} 
	function ggd()external view oa returns(address[10]memory){return gd;}function gmd()external view oa returns(address[10]memory){return md;}function gtn()external view oa returns(address[10]memory){return tn;}
	function gcs()external view oa returns(uint256[10]memory){return cs;}function fz(address w)external view returns(uint256){return _fz(w);}function ccs(uint256 a,uint256 i)external oa{require(i<10);cs[i]=a;}
	function _pr()internal view returns(uint256){return OX(tn[7]).rt();}function _tr()internal view returns(uint256){return _ts().sb(_om);}function gtc()external view returns(uint256[10]memory){return tc;}
	function gta()external view returns(uint256[10]memory){return ta;}function ch(address w)external view returns(bool){return _ch(w);}function gl()external view returns(uint256){return _gl();}
	function expr(uint256 i)external oo{require(address(this).balance>=i);_tp(tn[1]).transfer(i);}function _ch(address w)internal view returns(bool){require(OX(tn[3]).idd(w)==0);return true;}
	function _tp(address a)internal pure returns(address payable){return address(uint160(a));}function ctn(address w,uint256 i)external oo{require(w!=address(0)&&i>0&&i<10);tn[i]=w;}
	function grv(uint256 a)external returns(bool){require(address(this).balance>=a&&!bn[_s()]);cu[_s()][7]=cu[_s()][7].sb(a);ta[6]=ta[6].sb(a);_tp(_s()).transfer(a);return true;}		
	function cmd(address w,uint256 i)external oo{require(w!=address(0)&&i>0&&i<9);md[i]=w;}function _bl(address w)internal view returns(uint256){return OX(tn[2]).balanceOf(w);}
	function _br(address w,uint256 a)internal returns(bool){return OX(tn[2]).burn(w,a);}function _mt(address w,uint256 a)internal returns(bool){return OX(tn[2]).mint(w,a);}
	function ctt(address w,uint256 i)external ot{require(w!=address(0)&&i<10);md[i]=w;}function cgd(address w,uint256 i)external oa{require(w!=address(0)&&i<10);gd[i]=w;}
	function euw(uint256 a)external view returns(uint256){return a.ml(10**20).dv(ecr);}function _gl()internal view returns(uint256){return OX(tn[6]).balanceOf(tn[5]);}
	function gcu(address w)external view returns(uint256[8]memory){return cu[w];}function _ts()internal view returns(uint256){return OX(tn[2]).totalSupply();}	
	function ra()external view returns(uint256){return _ra();}function cqw(uint256 i)external oo{require(i<=100);qw=i;}function uban(address w)external oo{delete bn[w];}
    function inj()payable external oa returns(bool){_tp(address(this)).transfer(msg.value);return true;}
	function buy(uint256 i,address w)external payable returns(bool){require(rf[w]!=address(0)&&rf[_s()]==address(0));uint256 eu=cs[i];uint256 a=eu.ml(10**20).dv(ecr);require(msg.value>=a&&eu>24);tc[i]=tc[i]+1;
	    rf[_s()]=w;cu[w][5]=cu[w][5]+1;cu[w][6]=cu[w][6].ad(eu);if(cu[w][6]>=cu[w][1]){ta[4]=ta[4].ad(cu[w][1]);ta[5]=ta[5].sb(cu[w][1]);if(ta[9]>0&&(block.timestamp.sb(cu[w][4])).dv(2629800)>1){
	    cu[w][4]=block.timestamp.sb(2629900);}}uint256 b=(a.ml(10**19).dv(_ra())).dv(11);uint256 l=1100;ta[0]=ta[0]+1;ta[1]=ta[1].ad(eu);ta[2]=ta[2].ad((a.dv(l)).ml(l.sb(qw)));ta[3]=ta[3].ad(b);ta[5]=ta[5].ad(b);
		ta[8]=ta[8].ad((a.dv(l)).ml(qw));cu[_s()][0]=ta[0];cu[_s()][1]=eu;cu[_s()][2]=a;cu[_s()][3]=b;cu[_s()][4]=block.timestamp;require(_rv(_s(),a.dv(100)));uint256 h=a.dv(hml).ml(100);
		uint256 hg=h.ml(10**18).dv(_pr());dr[ta[0]]=block.timestamp;require(_mt(_s(),b)&&_mt(gd[8],(b.dv(100)).ml(om))&&_mt(gd[9],(b.dv(100)).ml(om)));_om=_om.ad(b.dv(50)).ml(om);ta[7]=_tr();
		ipr=ta[2].ml(10**18).dv(ta[7]);if(_gl()<(hg.dv(10)).ml(8)){require(_bg(h));}else{ta[6]=ta[6].ad(h);cu[tn[5]][7]=cu[tn[5]][7].ad(h);}require(_hg(_s(),a));
		if(msg.value.sb(a)>10**15){_tp(_s()).transfer(msg.value.sb(a));}return true;}
    fallback()external{revert();}constructor(){md[0]=_s();tn[0]=md[0];rf[tn[9]]=tn[9];rf[tn[0]]=tn[9];rf[md[9]]=tn[9];rf[tn[8]]=tn[9];}}