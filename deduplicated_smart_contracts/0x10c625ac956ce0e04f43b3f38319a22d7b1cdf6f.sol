pragma solidity ^0.4.24;

/*
#
#...######..########.##.......########.####.########..######..##.....##....###....####.##....##
#..##....##.##.......##.......##........##..##.......##....##.##.....##...##.##....##..###...##
#..##.......##.......##.......##........##..##.......##.......##.....##..##...##...##..####..##
#...######..######...##.......######....##..######...##.......#########.##.....##..##..##.##.##
#........##.##.......##.......##........##..##.......##.......##.....##.#########..##..##..####
#..##....##.##.......##.......##........##..##.......##....##.##.....##.##.....##..##..##...###
#...######..########.########.##.......####.########..######..##.....##.##.....##.####.##....##
#..............................................................................................
#....................................................................by Daniel Fernando Perosio
#
# @title Selfiechain un contrato para creación de selfies en Ethereum blockchain
# @author Daniel Fernando Perosio (http://danielperosio.com) e-mail daniel@perosio.com - dperosio@gmail.com
# @notice Selfiechain es un conjunto de instrucciones para realizar autorretratos a partir de tu identidad en la red Ethereum (Ethereum Address)
# @dev Compatible con la implementación de OpenZeppelin de la especificación ERC721 Crypto Coleccionables
#
*/

import "./ownable.sol";
import "./ERC721.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

contract Selfiechain is Ownable, ERC721, Pausable {

    string public name = "Selfiechain";
    string public symbol = "ツ";
    ERC721Metadata public erc721Metadata;
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;
    event NewSelfie(uint selfieId, string _hair, string _forehead, string _eyes, string _nose, string _mouth, string _neck, string _body);
    uint public randNonce = 0;
 
string[104] public array = ["┆","╵","║", "¦","╷","ı", "ﾉ", "つ", "╰", "೨", "ɿ", "╎", "╔", "@", "╯", "/", 
                            "I", "╲","[", "{", "├","ʕ", "|","ʅ", "(", "└", "╱", 
                            "I", "╱","]", "}", "┤", "ʔ","|", "ʃ", ")","┘", "╲",  
                            "J","ʃ","ʖ","^","L","¨","┘","┴","Δ","⌒","Ɔ", "ȷ", "フ","ʌ", "へ", "C",
                            "┅","┉","─", "-", "━", "~" ,"_",   
                            "‿","˽", "▁", "﹏", "︶", "︿","皿", "⺫", "⌂", "⌒", "ヮ", 
                             "o", "￢", "=", "O",
                            "◎","ㆆ","ಥ","°","®","©","ʘ","0","ಠ","Ơ","ø","º","●","Ф","◕", "ϴ", "e" ,
                             "♥" ,"$" ,"•" ,"+" ,"*" ,"×" ,"·" ,"`" ,":" ," " ,"´" ];  

struct Selfie {
      string hair;
      string forehead;
      string eyes;
      string nose;
      string mouth;
      string neck;
      string body;            
    }

    Selfie[] public selfies;

    mapping (uint => address) public selfieToOwner;
    mapping (address => uint) ownerSelfieCount;

    function _createSelf(string _hair, string _forehead, string _eyes, string _nose, string _mouth, string _neck, string _body) internal whenNotPaused {
        uint id = selfies.push(Selfie(_hair, _forehead, _eyes, _nose, _mouth, _neck, _body)) - 1;
        selfieToOwner[id] = msg.sender;
        ownerSelfieCount[msg.sender] = ownerSelfieCount[msg.sender].add(1);
        randNonce = randNonce.add(1);
        emit NewSelfie(id, _hair, _forehead, _eyes, _nose, _mouth, _neck, _body); 
    }

    uint fee = 0 ether;

    function withdraw() external onlyOwner {
        owner().transfer(address(this).balance);
    }

    function setUpFee(uint _feecreate) external onlyOwner {
        fee = _feecreate;
    } 
  
   function _createRand(uint8 j) internal view returns (uint i) {
        uint x = uint(keccak256(abi.encodePacked(msg.sender, randNonce))); 
           i =  x % j;    
    } 

    function _createId(uint8 j) internal view returns (uint i) {
        uint x = uint(keccak256(abi.encodePacked(msg.sender)));  
         i =  x % j;    
    } 
 
    function _trait(uint8 _j, string _l ) internal view returns (string) {
        uint8 _n1 = uint8(_createId(100)); 
        if (_n1 <= _j ){
            string memory x = _l;
            return x; 
        }               
        else  {
            string memory i = ".";
            return i; 
        }       
    } 

    function _createBg( uint8 i) internal view returns (string) {  
        string memory x = string(array[_createRand(8)+95]);
        string memory x8 = string(abi.encodePacked("." ,x ,".",x ,"." ,x ,"." ,x )); //8
        if ( i == 8){ 
          string memory a = string(abi.encodePacked(x8));
          return a;
             } 
           else if (i == 9) {
         string memory b = string(abi.encodePacked(x8,".")); //9
         return b;
           } 
           else if (i == 10) {
         string memory c = string(abi.encodePacked(x8,"." ,x)); //10
         return c;
         
           } 
         else  if (i == 12) {
         string memory d = string(abi.encodePacked(x8,"." ,x,"." ,x)); //12
         return d;
         
           }   
         else   {
         string memory f = string(abi.encodePacked(x8));
         return f;
         
           }   
    } 

    function _createString(uint8 i, string _a, string _b, string _c, string _d) internal view returns (string) {         
        if (i == 0) {
            string memory x = _trait(80,_a);  
            string memory bg = _createBg(10);  
            return string(abi.encodePacked(bg ,x ,_b ,x ,_b ,x ,_b ,x ,bg ));   //10
        } 
        else {
            string memory x1 = _trait(90,_a);  
            string memory x2 = _trait(90,_b);
            string memory bg1 = _createBg(8); 
            return string(abi.encodePacked(bg1 ,x1 ,x2 ,_c , "     " ,_d ,x2 ,x1 ,bg1 )); //8
        }                 
    }   

    function _createStringOne(uint8 i, string _a, string _b, string _c, string _d) internal view returns (string) { 
        if (i == 0){
            string memory x3 = _trait(70,_a); 
            string memory bg2 = _createBg(9);  
            return string(abi.encodePacked(bg2,x3, _b ," "  ,_d ,"  " ,_d ," "  ,_c ,x3 ,bg2 ));  //9            
        }
        else {
            string memory x4 = _trait(60,_d);
            string memory bg3 = _createBg(8);   
            return string(abi.encodePacked(bg3 ,x4 ,_a ,"   " ,_c ,"   " ,_b ,x4 ,bg3 ));  //8
        }                        
    }   

    function _createStringTwo(uint8 i, string _a, string _b, string _c, string _d) internal view returns (string) {       
        if (i == 0) {
            string memory x5 = _trait(50,_d); 
            string memory bg4 = _createBg(9); 
            return string(abi.encodePacked(bg4 ,x5 ,_a ,"  " ,_c ,"  " ,_b ,x5 ,bg4 )); //9
        }
        else if (i == 1) {
         string memory bg5 = _createBg(12); 
         return string(abi.encodePacked(bg5 ,_a ,_b ,_a ,bg5 )); //12
        }
        else {
            string memory bg6 = _createBg(10); 
            uint256 balance = msg.sender.balance;
            if (balance >= 200*1000000000000000000 ){
                 return string(abi.encodePacked(bg6 ,"_.>·<._" ,bg6 )); //10
            }               
            else {
                return string(abi.encodePacked(bg6 ,"_.", _a, "__", _b, "._" ,bg6)); //10
            }         
        }         
    } 

    function takeSelfie() external payable whenNotPaused {
        require(msg.value == fee);
        string memory _a = string(array[_createId(36)]);
        string memory _b = string(array[_createRand(36)]);
        string memory dhair =  _createString(0 ,_a , _b ,"" ,"" );     
        string memory dforehead =  _createString(1, _a, _b, string(array[_createId(9)+18]), string(array[_createId(9)+29]) ); 
        string memory deyes =  _createStringOne(0, _b, string(array[_createId(8)+18]), string(array[_createId(8)+29]), string(array[_createRand(27)+70])); 
        string memory dnose =  _createStringOne(1, string(array[_createId(9)+17]), string(array[_createId(9)+28]), string(array[_createId(16)+38]) ,_a ); 
        string memory dmouth =  _createStringTwo(0, string(array[_createId(7)+17]), string(array[_createId(7)+28]), string(array[_createRand(23)+54]) ,_b ); 
        string memory dneck =  _createStringTwo(1, string(array[_createId(6)+54]) ,string(array[_createId(10)+55]) ,"" ,"" ); 
        string memory dbody =  _createStringTwo(2,string(array[_createRand(10)+16]) ,string(array[_createRand(10)+27]) ,"" ,"" ); 
        _createSelf(dhair, dforehead, deyes, dnose, dmouth, dneck, dbody);
    }

    modifier onlyOwnerOf(uint _selfieId) {
      require(msg.sender == selfieToOwner[_selfieId]);
      _;
    }

    function getSelfieByOwner(address _owner) external view returns(uint[]) {
        uint[] memory result = new uint[](ownerSelfieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < selfies.length; i++) {
          if (selfieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
          }
        }
        return result;
    }

    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }

    /*ERC721*/  

    mapping (uint => address) selfieApprovals;

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerSelfieCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return selfieToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private validDestination(_to) {
        ownerSelfieCount[_to] = ownerSelfieCount[_to].add(1);
        ownerSelfieCount[_from] = ownerSelfieCount[_from].sub(1);
        selfieToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) validDestination(_to) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) validDestination(_to) {
        selfieApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint256 _tokenId) public {
        require(selfieApprovals[_tokenId] == msg.sender);
        address  owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }

    function totalSupply() public view returns (uint) {
        return selfies.length - 1;
    }    
    
}