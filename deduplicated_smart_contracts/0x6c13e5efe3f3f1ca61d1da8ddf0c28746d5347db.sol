/**

 *Submitted for verification at Etherscan.io on 2018-12-19

*/



pragma solidity ^0.4.2;





contract DataPost{



    function () {

        //if ether is sent to this address, send it back.

        throw;

    }

    event dataPosted(

    	address poster,

    	string data,

    	string hash_algorithm,

    	string signature,

    	string signature_spec

    );

  	function postData(string data, string hash_algorithm,string signature,string signature_spec){

  		emit dataPosted(msg.sender,data,hash_algorithm,signature,signature_spec);

  	}

   

}