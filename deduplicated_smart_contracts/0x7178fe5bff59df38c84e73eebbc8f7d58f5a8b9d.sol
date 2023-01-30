/**

 *Submitted for verification at Etherscan.io on 2018-09-26

*/



pragma solidity ^0.4.25;



// donate: 0x95CC9E2FE2E2de48A02CF6C09439889d72D5ea78



contract GorgonaKiller {

    // §Ñ§Õ§â§Ö§ã §Ô§à§â§Ô§à§ß§í

    address public GorgonaAddr; 

    

    // §Þ§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§í§Û §Õ§Ö§á§à§Ù§Ú§ä

    uint constant public MIN_DEP = 0.01 ether; 

    

    // §Þ§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§à§Ö §é§Ú§ã§Ý§à §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§Û §á§â§Ú §Ó§í§á§Ý§Ñ§ä§Ö §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§à§Ó

    uint constant public TRANSACTION_LIMIT = 100;

    

    // §Ò§Ñ§Ý§Ñ§ß§ã §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§à§Ó

    uint public dividends;

    

    // id §á§à§ã§Ý§Ö§Õ§ß§Ö§Ô§à §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ, §Ü§à§ä§à§â§à§Þ§å §á§â§à§ê§Ý§Ñ §à§á§Ý§Ñ§ä§Ñ

    uint public last_payed_id;

    

    // §à§Ò§ë§Ñ§ñ §ã§å§Þ§Þ§Ñ §Õ§Ö§á§à§Ù§Ú§ä§à§Ó §à§ä §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó

    uint public deposits; 

    

    // §Ñ§Õ§â§Ö§ã§Ñ §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó

    address[] addresses;



    // §Þ§Ñ§á§Ú§ß§Ô §Ñ§Õ§â§Ö§ã §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ - §ã§ä§â§å§Ü§ä§å§â§Ñ §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ

    mapping(address => Investor) public members;

    

    // id §Ñ§Õ§â§Ö§ã§Ñ §Ó investors, deposit - §ã§å§Þ§Þ§Ñ §Õ§Ö§á§à§Ù§Ú§ä§à§Ó

    struct Investor {

        uint id;

        uint deposit;

    }

    

    constructor() public {

        GorgonaAddr = 0x020e13faF0955eFeF0aC9cD4d2C64C513ffCBdec; 

    }



    // §à§Ò§â§Ñ§Ò§à§ä§Ü§Ñ §á§à§ã§ä§å§á§Ý§Ö§ß§Ú§Û

    function () external payable {



        // §Ö§ã§Ý§Ú §á§â§Ú§ê§Ý§à §ã §Ô§à§â§Ô§à§ß§í §Ó§í§ç§à§Õ§Ú§Þ

        if (msg.sender == GorgonaAddr) {

            return;

        }

        

        // §Ö§ã§Ý§Ú §Ò§Ñ§Ý§Ñ§ß§ã §Ò§Ö§Ù §ä§Ö§Ü§å§ë§Ö§Ô§à §á§à§ã§ä§å§á§Ý§Ö§ß§Ú§ñ > 0 §á§Ú§ê§Ö§Þ §Ó §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§í

        if ( address(this).balance - msg.value > 0 ) {

            dividends = address(this).balance - msg.value;

        }

        

        // §Ó§í§á§Ý§Ñ§é§Ú§Ó§Ñ§Ö§Þ §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§í

        if ( dividends > 0 ) {

            payDividends();

        }

        

        // §Ú§ß§Ó§Ö§ã§ä§Ú§â§å§Ö§Þ §ä§Ö§Ü§å§ë§Ö§Ö §á§à§ã§ä§å§á§Ý§Ö§ß§Ú§Ö

        if (msg.value >= MIN_DEP) {

            Investor storage investor = members[msg.sender];



            // §Õ§à§Ò§Ñ§Ó§Ý§ñ§Ö§Þ §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ, §Ö§ã§Ý§Ú §Ö§ë§Ö §ß§Ö§ä

            if (investor.id == 0) {

                investor.id = addresses.push(msg.sender);

            }



            // §á§à§á§à§Ý§ß§ñ§Ö§Þ §Õ§Ö§á§à§Ù§Ú§ä §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ §Ú §à§Ò§ë§Ú§Û §Õ§Ö§á§à§Ù§Ú§ä

            investor.deposit += msg.value;

            deposits += msg.value;

    

            // §à§ä§á§â§Ñ§Ó§Ý§ñ§Ö§Þ §Ó §Ô§à§â§Ô§à§ß§å

            payToGorgona();



        }

        

    }



    // §à§ä§á§â§Ñ§Ó§Ý§ñ§Ö§Þ §ä§Ö§Ü§å§ë§Ö§Ö §á§à§ã§ä§å§á§Ý§Ö§ß§Ú§Ö §Ó §Ô§à§â§Ô§à§ß§å

    function payToGorgona() private {

        if ( GorgonaAddr.call.value( msg.value )() ) return; 

    }



    // §Ó§í§á§Ý§Ñ§ä§Ñ §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§à§Ó

    function payDividends() private {

        address[] memory _addresses = addresses;

        

        uint _dividends = dividends;



        if ( _dividends > 0) {

            uint num_payed = 0;

            

            for (uint i = last_payed_id; i < _addresses.length; i++) {

                

                // §ã§é§Ú§ä§Ñ§Ö§Þ §Õ§Ý§ñ §Ü§Ñ§Ø§Õ§à§Ô§à §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ §Õ§à§Ý§ð §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§à§Ó

                uint amount = _dividends * members[ _addresses[i] ].deposit / deposits;

                

                // §à§ä§á§â§Ñ§Ó§Ý§ñ§Ö§Þ §Õ§Ú§Ó§Ú§Õ§Ö§ß§Õ§í

                if ( _addresses[i].send( amount ) ) {

                    last_payed_id = i+1;

                    num_payed += 1;

                }

                

                // §Ö§ã§Ý§Ú §Õ§à§ã§ä§Ú§Ô§Ý§Ú §Ý§Ú§Þ§Ú§ä§Ñ §Ó§í§á§Ý§Ñ§ä §Ó§í§ç§à§Õ§Ú§Þ §Ú§Ù §è§Ú§Ü§Ý§Ñ

                if ( num_payed == TRANSACTION_LIMIT ) break;

                

            }

            

            // §à§Ò§ß§å§Ý§ñ§Ö§Þ id §á§à§ã§Ý§Ö§Õ§ß§Ö§Û §Ó§í§á§Ý§Ñ§ä§í, §Ö§ã§Ý§Ú §Ó§í§á§Ý§Ñ§ä§Ú§Ý§Ú §Ó§ã§Ö§Þ

            if ( last_payed_id >= _addresses.length) {

                last_payed_id = 0;

            }

            

            dividends = 0;

            

        }

        

    }

    

    // §ã§Þ§à§ä§â§Ú§Þ §Ò§Ñ§Ý§Ñ§ß§ã §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ö

    function getBalance() public view returns(uint) {

        return address(this).balance / 10 ** 18;

    }



    // §ã§Þ§à§ä§â§Ú§Þ §é§Ú§ã§Ý§à §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó

    function getInvestorsCount() public view returns(uint) {

        return addresses.length;

    }



}