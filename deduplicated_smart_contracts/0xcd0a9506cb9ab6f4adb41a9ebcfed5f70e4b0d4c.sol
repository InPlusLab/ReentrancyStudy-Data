/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity 0.4.24;



contract HouseChain {

    uint PRICE = 1 ether;

    

    struct Review {

        address reviewer;

        uint score; // max 10

        string review;

    }

    

    struct House {

        string houseName;

        uint houseNum;

        uint price;

        address owner;

        string home_address;

        uint numOfUser;

        mapping(uint => Review) reviewList;

        uint numOfReview;

    }

    

    mapping(uint => House) public houseList;

    mapping(uint => uint) public balances;

    uint[] public houseNumList;

    uint public houseNum;

   

    constructor() public {

        houseNum = 0;

    }

    

    modifier onlyHouseOwner(uint _houseNum) {

        require(msg.sender == houseList[_houseNum].owner);

        _;

    }

    

    modifier enoughBalance(uint _houseNum) {

        uint amount = houseList[_houseNum].price * PRICE;

        require(amount == msg.value);

        _;

    }

    

    function addHouse(string _houseName, uint _price, string _address, uint _numOfUser) public returns(uint) {

        House memory newHouse;

    

        newHouse.houseName = _houseName;

        newHouse.houseNum = houseNum;

        newHouse.price = _price;

        newHouse.owner = msg.sender;

        newHouse.home_address = _address;

        newHouse.numOfUser = _numOfUser;

        newHouse.numOfReview = 0;

        

        houseList[houseNum] = newHouse;

        houseNumList.push(houseNum);

        

        return houseNum++;

    }

    

    function removeHouse(uint _houseNum) onlyHouseOwner(_houseNum) public {

        delete houseList[_houseNum];

        delete houseNumList[_houseNum];

    }

    

    function addReview(uint _houseNum, uint _score, string _review) public {

        Review memory review;

        review.reviewer = msg.sender;

        review.score = _score;

        review.review = _review;

        houseList[_houseNum].reviewList[houseList[_houseNum].numOfReview++] = review;

    }

    

    function getHouseArray() public view returns(uint[]) {

        return houseNumList;

    }

    

    function getHouseInfo(uint _num) public view returns(string, uint, address, string, uint, uint) {

        House memory house = houseList[_num];

        return (

            house.houseName,

            house.price, 

            house.owner, 

            house.home_address, 

            house.numOfUser, 

            house.numOfReview

        );

    }

    

    function getReview(uint _houseNum, uint _reviewNum) public view returns(address, uint, string) {

        Review memory review = houseList[_houseNum].reviewList[_reviewNum];

        return (

            review.reviewer, 

            review.score, 

            review.review

        );

    }

    

    function payHouse(uint _houseNum) enoughBalance(_houseNum) public payable {

        if (balances[_houseNum] > 0) {

            balances[_houseNum] += msg.value;

        } else {

            balances[_houseNum] = msg.value;

        }

    }

    

    function withdraw(uint _houseNum) onlyHouseOwner(_houseNum) public {

        uint amount = balances[_houseNum];

        require(amount > 0);

        balances[_houseNum] = 0;

        msg.sender.transfer(amount);

    }



}