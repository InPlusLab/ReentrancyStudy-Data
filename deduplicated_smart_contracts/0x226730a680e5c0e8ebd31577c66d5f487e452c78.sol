/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.5.0;



contract testCall {

    bool public state = false;

    

    event logStateChanged(bool state);

    

    function changeState() public returns(bool){

        if (state == false){

            state = true;

        } else {

            state = false;

        }

        

        emit logStateChanged(state);

        

        return true;

    }

}