/**
 *Submitted for verification at Etherscan.io on 2019-09-11
*/

pragma solidity ^0.5.11;

contract TeamManage {    
    address public  owner;
    mapping (address => bool) public  status; //状态
    mapping (address => address) public  referee; //上级介绍人
    mapping (address => mapping (uint256 => address)) public  teamMembers; //团队成员
    mapping (address => uint256) public  teamMembersNumber; //直接团队规模
    uint256 public numbers; //成员总人数

    /* Initializes contract*/
    constructor () public {  
        owner = msg.sender;
        referee[owner] = address(0x0);
        status[owner] = true;
        numbers = 1;
    }

    //添加推荐记录,记录本人的推荐人
    function addReferee(address _add) public returns (bool success) {
        require (_add != address(0x0) && status[_add] == true && status[msg.sender] == false) ;
        referee[msg.sender] = _add ;
        status[msg.sender] = true;
        teamMembers[_add][teamMembersNumber[_add]] = msg.sender;
        teamMembersNumber[_add] = teamMembersNumber[_add] + 1;
        numbers = numbers + 1;
        return true;
    }


    //修改所有者
    function changeOwner(address payable _add) public returns (bool success) {
        require (msg.sender == owner) ;
        require (_add != address(0x0)) ;
        owner = _add ;
        return true;
    }

    //查询团队成员,一次返回最多1000个._start默认从0开始,如果超过了就多次调用多次返回
    function queryTeamMembers(uint256 _start,address _add) public view returns (address[1000] memory _address) {
        for (uint i = _start; i < _start + 1000 && i < teamMembersNumber[_add]; i++) {
            _address[i - _start] = teamMembers[_add][i];
        }
        return  _address;
    }
}