/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity ^0.4.24;



contract PedigreeFactory {



    address public owner;

    

    mapping (address => address[]) list;

    

    constructor() public{

        owner = msg.sender;

    }



    function createPedigreeWithParent(address _father, address _mother, string _name, bool _gender, string _birthday, string _ipfs) public returns ( Pedigree ) {

        Pedigree newPedigree = new Pedigree(msg.sender, _father, _mother, _name, _gender, _birthday, _ipfs);

        list[msg.sender].push(newPedigree);

        return newPedigree;

    }



    function getList() public view returns(address[]){

        return list[msg.sender];

    }

    

    // fallback function

    function () public payable{

    }

    

    function widthdraw() external payable{

        require( msg.sender == owner );

        msg.sender.transfer(address(this).balance);

    }

    

    function getContractBalance() external view returns(uint) {

        return address(this).balance;

    }

}



contract Pedigree {



    address public owner;



    address public father;



    address public mother;

    

    // 이름

    string public name;



    bool public gender;



    // 생일

    string public birthday;



    // 배우자

    address public spouse;



    // 자식

    address[] childs;



    // 사망일

    string public dateOfDead;



    // 개인 정보( DNA, history, image, ...)

    string public ipfs;



    modifier onlyOwner(){

        require( msg.sender == owner );

        _;

    }



    constructor(address _owner, address _father, address _mother, string _name, bool _gender, string _birthday, string _ipfs) public {

        owner = _owner;

        father = _father;

        mother = _mother;

        name = _name;

        gender = _gender;

        birthday = _birthday;

        ipfs = _ipfs;

    }



    function addChild(address _childAddr) external {

        childs.push(_childAddr);

    }



    function getChilds() public view returns (address[]) {

        // require(childs.length > 0 );

        return childs;

    }



    function setSpouse(address _spouseAddr) external onlyOwner {

        spouse = _spouseAddr;

    }



    function getContractBalance() public view returns ( uint ) {

        return address(this).balance;

    }



    function setDateOfDead(string _date) external onlyOwner {

        dateOfDead = _date;

    }

    

    function setIPFS(string _ipfs) external onlyOwner {

        ipfs = _ipfs;

    }

    

}