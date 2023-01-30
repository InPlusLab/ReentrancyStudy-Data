/**

 *Submitted for verification at Etherscan.io on 2019-05-15

*/



pragma solidity 0.5.3;



contract Sample {



    uint public test_num;

    uint[] public test_array;



    constructor() public {

        test_num = 100;

    }



    function increse(uint _val) external {

        test_num += _val;

    }



    function decrease(uint _val) external {

        test_num -= _val;

    }

    

    function get_test_num() public returns (uint){

        return test_num;

    }

    

    function set_test_array(uint _val) public returns (uint){

        test_array.push(_val);

    }

    

    function get_test_array(uint index_num) public view returns(uint){

        return test_array[index_num];

    }



}