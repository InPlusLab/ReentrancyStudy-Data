/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



contract test {



        uint _multiplier;



        constructor (uint multiplier) public {

             _multiplier = multiplier;

        }



        function multiply(uint a) public view returns(uint d)  

        {

             return a * _multiplier;

        }

    }