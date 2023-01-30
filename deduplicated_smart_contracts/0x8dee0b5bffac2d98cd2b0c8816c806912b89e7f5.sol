/**
 *Submitted for verification at Etherscan.io on 2020-02-24
*/

pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract Ownable {

    address public owner;

    event OwnershipRenounced( address indexed previousOwner );
    event OwnershipTransferred( address indexed previousOwner, address indexed newOwner );

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract CryptomillionsWinnersOne is Ownable
{
    struct DrawList
    {
        string drawId;
        string content;
    }

    event DrawEvent(DrawList wd);

    mapping(string => DrawList) private drawslist;
    mapping(string => bool) private JoinedDraw;
    
    event joinDraws (DrawList draws);
    
    DrawList[] public listDraw;
    
    function drawJoined(string memory drawId) private view returns (bool) {
        return JoinedDraw[drawId];
    }

    function joinDraw (string memory drawId, string memory content) public onlyOwner returns (bool)
    {
        bytes memory tempDrawId = bytes(drawId);
        if(tempDrawId.length == 0)
            return false;
            
        if (!drawJoined(drawId))
        {
            DrawList storage dl = drawslist[drawId];
            dl.drawId = drawId;
            dl.content = content;
            JoinedDraw[drawId] = true;
            listDraw.push(DrawList(drawId, content));
            emit joinDraws(dl);
            return true;
        }
        else
            return false;
    }

    function getDraw(string memory drawId) public view returns (string memory, string memory){
        if (drawJoined(drawId)) {
            DrawList storage dl = drawslist[drawId];
         
            return (dl.drawId, dl.content);
        }
    }
    
    function drawsJoined(string memory drawId) private view returns (bool) {
        return JoinedDraw[drawId];
    }
 
    function showDraw() public view returns (DrawList[] memory){
        return(listDraw);
    }
    
    function total() public view returns (uint){
        return(listDraw.length);
    }
	
	function kill() public onlyOwner {
       if (owner == msg.sender) {
          selfdestruct(msg.sender);
       }
    }
}