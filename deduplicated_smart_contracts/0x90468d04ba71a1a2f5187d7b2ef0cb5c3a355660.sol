/**

 *Submitted for verification at Etherscan.io on 2019-06-13

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

    

    //level-commend bili /1000

    function getBiliBylevel(uint level) public view returns(uint){

        if(level == 1){ 

            return 5;

        }if(level == 2){

            return 7;

        }if(level == 3) {

            return 10;

        }

        return 0;

    }

    

    //level fire bili   /10

    function getFireBiliBylevel(uint level) public view returns(uint){

        if(level == 1){

            return 3;

        }if(level == 2){

            return 6;

        }if(level == 3) {

            return 10;

        }return 0;

    }

    

    //level and dai => invite bili /100

    function getRecommendBiliBylevelandDai(uint level,uint dai) public view returns(uint){

        if(level == 1 && dai == 1){ 

            return 50;

        }if(level == 2 && dai == 1){

            return 70;

        }if(level == 2 && dai == 2){

            return 50;

        }if(level == 3) {

            if(dai == 1){

                return 100;

            }if(dai == 2){

                return 70;

            }if(dai == 3){

                return 50;

            }if(dai >= 4 && dai <= 10){

                return 10;

            }if(dai >= 11 && dai <= 20){

                return 5;

            }if(dai >= 21){

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