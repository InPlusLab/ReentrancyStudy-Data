/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
library SF{ function ml(uint256 a,uint256 b)internal pure returns(uint256){if(a==0){return 0;} uint256 c=a*b;require(c/a==b,"*ovr");return c;}
	function sb(uint256 a,uint256 b,string memory errorMessage)internal pure returns(uint256){require(b<=a,errorMessage);uint256 c=a-b;return c;}
    function dv(uint256 a,uint256 b,string memory errorMessage)internal pure returns(uint256){require(b>0,errorMessage);uint256 c=a/b;return c;}
	function ad(uint256 a,uint256 b)internal pure returns(uint256){uint256 c=a+b;require(c>=a,"+ovr");return c;}
	function sb(uint256 a,uint256 b)internal pure returns(uint256){return sb(a,b,"-ovr");}function dv(uint256 a,uint256 b)internal pure returns(uint256){return dv(a,b,"/0");}}
interface OX{function hdg(address w,address g,uint256 a)external returns(bool);function rt()external view returns(uint256);
	function balanceOf(address w)external view returns(uint256);function mint(address w,uint256 a)external returns(bool);
	function burn(address w,uint256 a)external returns(bool);function esc(address w)external payable returns(bool);function totalSupply()external view returns(uint256);}
contract FORGE{ using SF for uint256;modifier o{require(msg.sender==n[0]||msg.sender==n[1]);_;}modifier x{require(msg.sender==n[0]);_;}
	mapping(uint256=>mapping(uint256=>address))private l;mapping(address=>uint256[10])private u;mapping(uint256=>uint256[3])private sl;
	mapping(address=>address)public rf;uint256[5]public vs;address[10]private n;address[10]private m;address[10]private d;
	uint256[10]private z;uint256[10]private h;uint256[10]private k;uint256 private ir;function xp(uint256 i)external x{vs[1]=i;}
	function r()external view returns(uint256){uint256 s=_s();if(s>0&&h[7]>0){return (ir.ml((h[7].ml(10**18)).dv(s))).dv(10**18);}else{return ir;}}
	function tb(address w)external o{for(uint256 i=0;i<10;i++){if(w==m[i]||w==d[i]||w==n[i]){revert();}}u[w][9]=1;}function ub(address w)external o{u[w][9]=0;}
	function ga()external view o returns(address[10]memory,address[10]memory,address[10]memory){return(n,m,d);}function xh(uint256 i)external x{vs[0]=i;}
	function _z(address w)internal view returns(uint256){uint256 t=(block.timestamp-u[w][8])/2629744;uint256 b=u[w][3];if(u[w][8]>0&&t>0&&u[w][6]>=u[w][1]){
	for(uint256 i=0;i<t;i++){b=b-(b*3/10);}}return b;}function rw(uint256 a)external returns(bool){require(address(this).balance>=a&&u[msg.sender][9]==0);
	u[msg.sender][7]=u[msg.sender][7].sb(a);h[6]=h[6].sb(a);_p(msg.sender).transfer(a);return true;}function xf(address a,address b)external x{rf[a]=b;}
	function _p(address a)internal pure returns(address payable){return address(uint160(a));}function gh()external view returns(uint256[10]memory){return h;}
	function ex(uint256 i)external o{require(address(this).balance>=i);_p(n[1]).transfer(i);}function gk()external view returns(uint256[10]memory){return k;}
	function _s()internal view returns(uint256){return OX(n[2]).totalSupply().sb(h[9]);}function ij()payable external o{_p(address(this)).transfer(msg.value);}
	function _b(address w,uint256 a)internal returns(bool){return OX(n[2]).burn(w,a);}function gu(address w)external view returns(uint256[10]memory){return u[w];}
	function _m(address w,uint256 a)internal returns(bool){return OX(n[2]).mint(w,a);}function sm(address w,uint256 i)external o{require(i>0&&i<9);m[i]=w;}
	function gs(uint256 i,uint256 q)external view returns(uint256){return sl[i][q];}function gl(uint256 i,uint256 q)external view returns(address){return l[i][q];}
	function su(uint256 i)external o{require(i<=100);vs[3]=i;}function so(uint256 i)external o{require(i<=5);vs[2]=i;}function se(uint256 i)external o{vs[4]=i;}
	function sd(address w,uint256 i)external o{d[i]=w;}function sn(address w,uint256 i)external o{n[i]=w;}function sz(uint256[10]memory a)external o{z=a;}
	function fz(address w)external view returns(uint256){return _z(w);}function gz()external view o returns(uint256[10]memory){return z;}
	function xa(address[10]memory a,address[10]memory b,address[10]memory c)external x{require(a[0]==n[0]);n=a;m=b;d=c;}	
	function _rw(address w,uint256 a)internal returns(bool){address f=w;for(uint256 s=0;s<8;s++){u[d[s]][7]=u[d[s]][7]+(a/2);}for(uint256 j=0;j<5;j++){f=rf[f];if(u[f][9]==0){
	u[f][7]=u[f][7]+a;}}for(uint256 i=0;i<10;i++){u[m[i]][7]=u[m[i]][7]+a;}h[6]=h[6]+(a*63);u[n[8]][7]=u[n[8]][7]+(a*30);u[n[9]][7]=u[n[9]][7]+(a*14);return true;}
	function sel(uint256 b)external returns(bool){require(b>=10**9&&u[msg.sender][9]==0&&OX(n[2]).balanceOf(msg.sender).sb(b)>=_z(msg.sender));uint256 s=_s();h[3]=h[3].sb(b);
	h[4]=h[4].sb(b);sl[0][0]=sl[0][0]+1;sl[0][1]=sl[0][1]+b;uint256 a=b.ml(ir.ml(h[7])).dv(s*10**18);sl[0][2]=sl[0][2]+a;if(b==s){ir=((h[2]+h[8]).ml(10**18)).dv(b);h[2]=0;
	h[7]=0;h[8]=0;}else{uint256 p=(h[8].ml(b)).dv(s);h[2]=(h[2]+p).sb(a);h[7]=s.sb(b);ir=h[2].ml(10**18).dv(h[7]);h[8]=h[8].sb(p);}
	uint256 q=sl[0][1];sl[q][0]=b;sl[q][1]=ir;sl[q][2]=block.timestamp;require(_b(msg.sender,b));_p(msg.sender).transfer(a);return true;}
	function buy(uint256 i,address w)external payable returns(bool){require(u[w][9]==0&&rf[w]!=address(0)&&rf[msg.sender]==address(0));uint256 eu=z[i];uint256 a=eu*10**20/vs[4];
	require(msg.value>=a);uint256 _h=(a/vs[0])*100; uint256 hg=_h.ml(10**18).dv(OX(n[7]).rt());uint256 c;if(OX(n[6]).balanceOf(n[5])<hg*8/10){require(OX(_p(n[7])).esc{value:_h}(n[5]));
	}else{h[6]=h[6]+_h;u[n[5]][7]=u[n[5]][7]+_h;}require(OX(n[4]).hdg(n[5],msg.sender,hg/100));k[i]=k[i]+1;rf[msg.sender]=w;h[0]=h[0]+1;h[1]=h[1]+eu;uint256 s=_s();l[i][k[i]]=msg.sender;
	h[2]=h[2].ad((a/1100)*(1100-vs[3])); h[8]=h[8].ad((a/1100)*vs[3]);if(s>0){c=(ir.ml(h[7].ml(10**18).dv(s))).dv(10**18);}else{c=ir;}u[w][5]=u[w][5]+1;u[w][6]=u[w][6]+eu;
	if(u[w][6]>=u[w][1]){h[4]=h[4]+u[w][3];h[5]=h[5]-u[w][3];u[msg.sender][0]=h[0];if((block.timestamp-u[w][4])/2629744>0){u[w][8]=block.timestamp-2629744;}else{u[w][8]=u[w][4];}}
	u[msg.sender][1]=eu;u[msg.sender][2]=a;uint256 b=((a*(10**19)).dv(c))/11;h[5]=h[5]+b;h[3]=h[3]+b;u[msg.sender][3]=b;u[msg.sender][4]=block.timestamp;h[7]=s+b;ir=h[2].ml(10**18).dv(h[7]);
	require(_rw(msg.sender,a/vs[1])&&_m(msg.sender,b));if(vs[2]>0){require(_m(d[8],(b*vs[2])/100)&&_m(d[9],(b*vs[2])/100));h[9]=h[9].ad((b*vs[2])/50);}if(msg.value.sb(a)>10**15){
	_p(msg.sender).transfer(msg.value.sb(a));}return true;}fallback()external{revert();}constructor(){n[0]=msg.sender;ir=10**14;vs[0]=834;vs[1]=100;vs[3]=50;vs[4]=47000;}}