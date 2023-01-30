/**

 *Submitted for verification at Etherscan.io on 2018-08-23

*/



pragma solidity 0.4.24;



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



contract Ownable {

    address public owner;

    mapping(address => bool) admins;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event AddAdmin(address indexed admin);

    event DelAdmin(address indexed admin);





    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor() public {

        owner = msg.sender;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    modifier onlyAdmin() {

        require(isAdmin(msg.sender));

        _;

    }





    function addAdmin(address _adminAddress) external onlyOwner {

        require(_adminAddress != address(0));

        admins[_adminAddress] = true;

        emit AddAdmin(_adminAddress);

    }



    function delAdmin(address _adminAddress) external onlyOwner {

        require(admins[_adminAddress]);

        admins[_adminAddress] = false;

        emit DelAdmin(_adminAddress);

    }



    function isAdmin(address _adminAddress) public view returns (bool) {

        return admins[_adminAddress];

    }

    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param _newOwner The address to transfer ownership to.

     */

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0));

        emit OwnershipTransferred(owner, _newOwner);

        owner = _newOwner;

    }



}







interface tokenRecipient {

    function receiveApproval(address _from, address _token, uint _value, bytes _extraData) external;

    function receiveCreateAuction(address _from, address _token, uint _tokenId, uint _startPrice, uint _duration) external;

    function receiveCreateAuctionFromArray(address _from, address _token, uint[] _landIds, uint _startPrice, uint _duration) external;

}





contract ERC721 {

    function implementsERC721() public pure returns (bool);

    function totalSupply() public view returns (uint256 total);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function ownerOf(uint256 _tokenId) public view returns (address owner);

    function approve(address _to, uint256 _tokenId) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public returns (bool);

    function transfer(address _to, uint256 _tokenId) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);



    // Optional

    // function name() public view returns (string name);

    // function symbol() public view returns (string symbol);

    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);

    // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);

}







contract LandBase is ERC721, Ownable {

    using SafeMath for uint;



    event NewLand(address indexed owner, uint256 landId);



    struct Land {

        uint id;

    }





    // Total amount of lands

    uint256 private totalLands;



    // Incremental counter of lands Id

    uint256 private lastLandId;



    //Mapping from land ID to Land struct

    mapping(uint256 => Land) public lands;



    // Mapping from land ID to owner

    mapping(uint256 => address) private landOwner;



    // Mapping from land ID to approved address

    mapping(uint256 => address) private landApprovals;



    // Mapping from owner to list of owned lands IDs

    mapping(address => uint256[]) private ownedLands;



    // Mapping from land ID to index of the owner lands list

    // ��.��. ID �٧֧ާݧ� => �����էܧ�ӧ�� �ߧ�ާ֧� �� ���ڧ�ܧ� �ӧݧѧէ֧ݧ���

    mapping(uint256 => uint256) private ownedLandsIndex;





    modifier onlyOwnerOf(uint256 _tokenId) {

        require(owns(msg.sender, _tokenId));

        _;

    }



    /**

    * @dev Gets the owner of the specified land ID

    * @param _tokenId uint256 ID of the land to query the owner of

    * @return owner address currently marked as the owner of the given land ID

    */

    function ownerOf(uint256 _tokenId) public view returns (address) {

        return landOwner[_tokenId];

    }



    function totalSupply() public view returns (uint256) {

        return totalLands;

    }



    /**

    * @dev Gets the balance of the specified address

    * @param _owner address to query the balance of

    * @return uint256 representing the amount owned by the passed address

    */

    function balanceOf(address _owner) public view returns (uint256) {

        return ownedLands[_owner].length;

    }



    /**

    * @dev Gets the list of lands owned by a given address

    * @param _owner address to query the lands of

    * @return uint256[] representing the list of lands owned by the passed address

    */

    function landsOf(address _owner) public view returns (uint256[]) {

        return ownedLands[_owner];

    }



    /**

    * @dev Gets the approved address to take ownership of a given land ID

    * @param _tokenId uint256 ID of the land to query the approval of

    * @return address currently approved to take ownership of the given land ID

    */

    function approvedFor(uint256 _tokenId) public view returns (address) {

        return landApprovals[_tokenId];

    }



    /**

    * @dev Tells whether the msg.sender is approved for the given land ID or not

    * This function is not private so it can be extended in further implementations like the operatable ERC721

    * @param _owner address of the owner to query the approval of

    * @param _tokenId uint256 ID of the land to query the approval of

    * @return bool whether the msg.sender is approved for the given land ID or not

    */

    function allowance(address _owner, uint256 _tokenId) public view returns (bool) {

        return approvedFor(_tokenId) == _owner;

    }



    /**

    * @dev Approves another address to claim for the ownership of the given land ID

    * @param _to address to be approved for the given land ID

    * @param _tokenId uint256 ID of the land to be approved

    */

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) returns (bool) {

        require(_to != msg.sender);

        if (approvedFor(_tokenId) != address(0) || _to != address(0)) {

            landApprovals[_tokenId] = _to;

            emit Approval(msg.sender, _to, _tokenId);

            return true;

        }

    }





    function approveAndCall(address _spender, uint256 _tokenId, bytes _extraData) public returns (bool) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _tokenId)) {

            spender.receiveApproval(msg.sender, this, _tokenId, _extraData);

            return true;

        }

    }





    function createAuction(address _auction, uint _tokenId, uint _startPrice, uint _duration) public returns (bool) {

        tokenRecipient auction = tokenRecipient(_auction);

        if (approve(_auction, _tokenId)) {

            auction.receiveCreateAuction(msg.sender, this, _tokenId, _startPrice, _duration);

            return true;

        }

    }





    function createAuctionFromArray(address _auction, uint[] _landIds, uint _startPrice, uint _duration) public returns (bool) {

        tokenRecipient auction = tokenRecipient(_auction);



        for (uint i = 0; i < _landIds.length; ++i)

            require(approve(_auction, _landIds[i]));



        auction.receiveCreateAuctionFromArray(msg.sender, this, _landIds, _startPrice, _duration);

        return true;

    }



    /**

    * @dev Claims the ownership of a given land ID

    * @param _tokenId uint256 ID of the land being claimed by the msg.sender

    */

    function takeOwnership(uint256 _tokenId) public {

        require(allowance(msg.sender, _tokenId));

        clearApprovalAndTransfer(ownerOf(_tokenId), msg.sender, _tokenId);

    }



    /**

    * @dev Transfers the ownership of a given land ID to another address

    * @param _to address to receive the ownership of the given land ID

    * @param _tokenId uint256 ID of the land to be transferred

    */

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) returns (bool) {

        clearApprovalAndTransfer(msg.sender, _to, _tokenId);

        return true;

    }





    function ownerTransfer(address _from, address _to, uint256 _tokenId) onlyAdmin public returns (bool) {

        clearApprovalAndTransfer(_from, _to, _tokenId);

        return true;

    }



    /**

    * @dev Internal function to clear current approval and transfer the ownership of a given land ID

    * @param _from address which you want to send lands from

    * @param _to address which you want to transfer the land to

    * @param _tokenId uint256 ID of the land to be transferred

    */

    function clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal {

        require(owns(_from, _tokenId));

        require(_to != address(0));

        require(_to != ownerOf(_tokenId));



        clearApproval(_from, _tokenId);

        removeLand(_from, _tokenId);

        addLand(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);

    }



    /**

    * @dev Internal function to clear current approval of a given land ID

    * @param _tokenId uint256 ID of the land to be transferred

    */

    function clearApproval(address _owner, uint256 _tokenId) private {

        require(owns(_owner, _tokenId));

        landApprovals[_tokenId] = address(0);

        emit Approval(_owner, address(0), _tokenId);

    }



    /**

    * @dev Internal function to add a land ID to the list of a given address

    * @param _to address representing the new owner of the given land ID

    * @param _tokenId uint256 ID of the land to be added to the lands list of the given address

    */

    function addLand(address _to, uint256 _tokenId) private {

        require(landOwner[_tokenId] == address(0));

        landOwner[_tokenId] = _to;



        uint256 length = ownedLands[_to].length;

        ownedLands[_to].push(_tokenId);

        ownedLandsIndex[_tokenId] = length;

        totalLands = totalLands.add(1);

    }



    /**

    * @dev Internal function to remove a land ID from the list of a given address

    * @param _from address representing the previous owner of the given land ID

    * @param _tokenId uint256 ID of the land to be removed from the lands list of the given address

    */

    function removeLand(address _from, uint256 _tokenId) private {

        require(owns(_from, _tokenId));



        uint256 landIndex = ownedLandsIndex[_tokenId];

        //        uint256 lastLandIndex = balanceOf(_from).sub(1);

        uint256 lastLandIndex = ownedLands[_from].length.sub(1);

        uint256 lastLand = ownedLands[_from][lastLandIndex];



        landOwner[_tokenId] = address(0);

        ownedLands[_from][landIndex] = lastLand;

        ownedLands[_from][lastLandIndex] = 0;

        // Note that this will handle single-element arrays. In that case, both landIndex and lastLandIndex are going to

        // be zero. Then we can make sure that we will remove _tokenId from the ownedLands list since we are first swapping

        // the lastLand to the first position, and then dropping the element placed in the last position of the list



        ownedLands[_from].length--;

        ownedLandsIndex[_tokenId] = 0;

        ownedLandsIndex[lastLand] = landIndex;

        totalLands = totalLands.sub(1);

    }





    function createLand(address _owner, uint _id) onlyAdmin public returns (uint) {

        require(_owner != address(0));

        uint256 _tokenId = lastLandId++;

        addLand(_owner, _tokenId);

        //store new land data

        lands[_tokenId] = Land({

            id : _id

            });

        emit Transfer(address(0), _owner, _tokenId);

        emit NewLand(_owner, _tokenId);

        return _tokenId;

    }



    function createLandAndAuction(address _owner, uint _id, address _auction, uint _startPrice, uint _duration) onlyAdmin public

    {

        uint id = createLand(_owner, _id);

        require(createAuction(_auction, id, _startPrice, _duration));

    }





    function owns(address _claimant, uint256 _tokenId) public view returns (bool) {

        return ownerOf(_tokenId) == _claimant && ownerOf(_tokenId) != address(0);

    }





    function transferFrom(address _from, address _to, uint256 _tokenId) public returns (bool) {

        require(_to != address(this));

        require(allowance(msg.sender, _tokenId));

        clearApprovalAndTransfer(_from, _to, _tokenId);

        return true;

    }



}





contract ArconaDigitalLand is LandBase {

    string public constant name = " Arcona Digital Land";

    string public constant symbol = "ARDL";



    function implementsERC721() public pure returns (bool)

    {

        return true;

    }



    function() public payable{

        revert();

    }

}