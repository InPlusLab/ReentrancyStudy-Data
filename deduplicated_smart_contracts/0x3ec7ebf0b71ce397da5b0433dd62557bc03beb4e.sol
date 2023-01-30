/**

 *Submitted for verification at Etherscan.io on 2018-12-09

*/



pragma solidity 0.4.24;



contract Ownable {



    address public owner;



    constructor() public {

        owner = msg.sender;

    }



    function setOwner(address _owner) public onlyOwner {

        owner = _owner;

    }



    function getOwner() public view returns (address) {

        return owner;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



}



contract Delegate {



    function mint(address _sender, address _to) public returns (bool);



    function approve(address _sender, address _to, uint256 _tokenId) public returns (bool);



    function setApprovalForAll(address _sender, address _operator, bool _approved) public returns (bool);



    function transferFrom(address _sender, address _from, address _to, uint256 _tokenId) public returns (bool);

    

    function safeTransferFrom(address _sender, address _from, address _to, uint256 _tokenId) public returns (bool);



    function safeTransferFrom(address _sender, address _from, address _to, uint256 _tokenId, bytes memory _data) public returns (bool);



}





contract SimpleClaimable is Delegate, Ownable {



    mapping(address => bool) public claimed;

    bool public canClaim = false;



    function setCanClaim(bool can) public onlyOwner {

        canClaim = can;

    }



    function mint(address _sender, address _to) public returns (bool) {

        require(_to.balance >= 0.5 ether, "must have at least 0.5 eth in account");

        require(_sender == _to, "can only claim for yourself");

        require(canClaim, "can't claim");

        require(!claimed[_to], "already claimed");

        claimed[_to] = true;

        return true;

    }



    function approve(address, address, uint256) public returns (bool) {

        return true;

    }



    function setApprovalForAll(address, address, bool) public returns (bool) {

        return true;

    }



    function transferFrom(address, address, address, uint256) public returns (bool) {

        return true;

    }

    

    function safeTransferFrom(address, address, address, uint256) public returns (bool) {

        return true;

    }



    function safeTransferFrom(address, address, address, uint256, bytes memory) public returns (bool) {

        return true;

    }



}