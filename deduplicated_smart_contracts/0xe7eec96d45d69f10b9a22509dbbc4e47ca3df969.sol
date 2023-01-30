/**

 *Submitted for verification at Etherscan.io on 2018-12-06

*/



pragma solidity ^0.4.25;



contract ERC20 {

    function balanceOf(address _who) public view returns (uint256);

}



contract DataStorage {

    

    string[] datas;

    mapping(uint => bool) dataExist;

    int datasCounter;

    ERC20 token;



    constructor(ERC20 _token) public {

        require(_token != address(0));

        token = _token;

    }



    function create(string _property) public {

        require(token.balanceOf(msg.sender) > 0, "only members can run this function");

        uint id = datas.length;

        datas.push(_property);

        dataExist[id] = true;

        datasCounter++;

    }



    function getDataCount() public view returns(uint) {

        return datas.length;

    }



    function balanceOf(address _who) public view returns(uint256) {

        return token.balanceOf(_who);

    }



    function read(uint _id) public view returns(string) {

        require(token.balanceOf(msg.sender) > 0, "only members can run this function");

        require(dataExist[_id], "the data doesn't exist");

        return datas[_id];

    }



    function remove(uint _id) public {

        require(token.balanceOf(msg.sender) > 0, "only members can run this function");

        require(dataExist[_id], "the data doesn't exist");

        dataExist[_id] = false;

        datasCounter--;

    }

}