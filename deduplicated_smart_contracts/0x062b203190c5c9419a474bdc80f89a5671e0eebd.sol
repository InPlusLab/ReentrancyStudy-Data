/**
 *Submitted for verification at Etherscan.io on 2019-10-11
*/

pragma solidity ^0.4.24;

contract UtilFairWin  {
    uint ethWei = 1 ether;
    //getlevel
    function getlevel(uint value) public view returns(uint){
        if(value>=1*ethWei && value<=5*ethWei){
            return 1;
        }if(value>=6*ethWei && value<=10*ethWei){
            return 2;
        }if(value>=11*ethWei && value<=15*ethWei){
            return 3;
        }
            return 0;
    }
    //getLinelevel
    function getLineLevel(uint value) public view returns(uint){
        if(value>=1*ethWei && value<=5*ethWei){
            return 1;
        }if(value>=6*ethWei && value<=10*ethWei){
            return 2;
        }if(value>=11*ethWei){
            return 3;
        }
    }
    
    //level-commend  /1000
    function getScBylevel(uint level) public view returns(uint){
        if(level == 1){ 
            return 5;
        }if(level == 2){
            return 7;
        }if(level == 3) {
            return 10;
        }
        return 0;
    }
    
    //level fire scale   /10
    function getFireScBylevel(uint level) public view returns(uint){
        if(level == 1){
            return 3;
        }if(level == 2){
            return 6;
        }if(level == 3) {
            return 10;
        }return 0;
    }
    
    //level and times => invite scale /100
    function getRecommendScaleBylevelandTim(uint level,uint times) public view returns(uint){
        if(level == 1 && times == 1){ 
            return 50;
        }if(level == 2 && times == 1){
            return 70;
        }if(level == 2 && times == 2){
            return 50;
        }if(level == 3) {
            if(times == 1){
                return 100;
            }if(times == 2){
                return 70;
            }if(times == 3){
                return 50;
            }if(times >= 4 && times <= 10){
                return 10;
            }if(times >= 11 && times <= 20){
                return 5;
            }if(times >= 21){
                return 1;
            }
        } return 0;
    }
    
    function compareStr (string _str,string str) public view returns(bool) {
         bool checkResult = false;
        if(keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
            checkResult = true;
        }
        return checkResult;
    }
}