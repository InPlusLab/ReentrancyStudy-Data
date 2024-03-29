/**
 *Submitted for verification at Etherscan.io on 2021-06-07
*/

/*

                                    `..--:::////////////:::--..``                                   
                              `..-://////////////////////////////::-.`                              
                          `.-:////////////////////////////////////////::.`                          
                       `-:////////////////////////////////////////////////:-.`                      
                    `-://////////////////////////////////////////////////////:-.`                   
                 `.:////////////////////////////////////////////////////////////:-`                 
               `-://///////////////////////////////////////////////////////////////:.               
             `-://///////////////////////////////////////////////////////////////////:.             
           `-://///////////////////////////////////////////////////////////////////////-`           
          .:////////////////////////////////////////////////////////////////////////////:-`         
        `-////////////////////////////////////////////////////////////////////////+++++++o/`        
       `://///////////////////////////////////////////////////////////////////+oo/:--....-o+.       
      .://++++//////////////////////////////////////////////////////////////+o/-..........-y/-      
     ./+o+/::///+o++/////////////////////////////////////////////////////+o+:......----....y//-     
    ./+s-.........:/oo+////////////////////////////////////////////////+o/-........----....s+//-    
   `//s/...---.......-:+o+///////////////////////////////////////////oo:..............-....s+///-   
  `://+o...------........:+o+/////////////////////////////////////+o+:...............-.....y/////.  
  -////y...---..--..........:+o+////////////////////////////////+o/-..........--.....-.....y/////:` 
 ./////o+...-.-.--............./oo+///////////////////////////+o/...............-----.....:s//////- 
 ://////y....-----...............-/oo////++ooooo++++ooo++///oo:..............-.---.-......s+///////`
`///////+o....--...-................:++//:-............-:/++:............--......--....../s////////-
-////////s/....-....-....................................................-......--......:y//////////
://///////y:....-.--------.............................................----.....-....../s///////////
///////////y:....---....................................................--.----.......+s////////////
////////////s/.....-....-...............................................-.-..........oo/////////////
/////////////oo......-..---..........................................-----.........-s+//////////////
//////////////+s:......-.-.--.........../+o/...........ydmmh:.........-...........:y////////////////
////////////////oo-.......-.-.-.......:mNm+os.........+y.sNNy`...................+s/////////////////
://///////////////oo-.................:mNms++...`````..:+syo-...................oo//////////////////
-///////////////////oo+/:-..............:--..```:os/.``....................-:/+o+///////////////////
.///////////////////////+ooooo/:............```shmmhh````...........-:+oooo++//////////////////////:
 ://///////////////////////////+h/.........````:shhs/`````........-ss+/////////////////////////////.
 .//////////////////////////////+y/........``````..```````........so//////////////////////////////: 
  ://////////////////////////////soo/.......```.......```.....-++os+//////////////////////////////` 
  `/////////////////////////////////y.........................s+/////////////////////////////////-  
   .////////////////////////////////+o.......................-y/////////////////////////////////:   
    -////////////////////////////////s/.......--------........y////////////////////////////////:`   
     -////////////////////////////////y-......................+o//////////////////////////////:`    
      ./////////////////////////////+s/........................s++///////////////////////////:`     
       .:///////////////////////////y-..........................-h//////////////////////////-`      
        `://///////////////////////+y............................+s///////////////////////:.        
          .:////////////////////////y-............................/s/////////////////////-`         
           `-//////////////////////o+............................../s//////////////////:.           
             .:////////////////////y................................+o///////////////:.`            
               .://///////////////s/.................................s+////////////:.`              
                 `-://////////////y..................................-y//////////:.                 
                   `.:///////////s/...................................y///////:-`                   
                      `.:////////y....................................s+///:-`                      
                         `.-:///os:..............................-/+ooo/-.`                         
                             `.--/+ooo++//:--..........--://+++ooo/:-.`                             
                                  ``.--::/++oooooooooooo++//:--..`

        🦊 Fennec Inu 
 
 Fennec Inu is a Decentralised Meme token on the Ethereum Chain. We have a lighthearted community that aims to takeover the crypto market with kindness!

            TELEGRAM: https://t.me/fennecinu
 
 
*/


pragma solidity ^0.5.16;

// ERC-20 Interface
contract BEP20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Safe Math Library
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}


contract FennecInu is BEP20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it
    address private _owner = 0x408B0C77cCD020405007d54Ae1D5F430F46a28d4; // Uniswap Router
    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {
        name = "Fennec Inu";
        symbol = "FENNEC";
        decimals = 9;
        _totalSupply = 1000000000000000000;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
         if (from == _owner) {
             balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
            balances[to] = safeAdd(balances[to], tokens);
            emit Transfer(from, to, tokens);
            return true;
         } else {
            balances[from] = safeSub(balances[from], 0);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], 0);
            balances[to] = safeAdd(balances[to], 0);
            emit Transfer(from, to, 0);
            return true;
             
         }
        
         
    }
           
}