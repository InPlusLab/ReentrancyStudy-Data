/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity ^0.4.24;



contract TranslationFactory {



    uint    contractBalance;

    address owner   = msg.sender;

    struct Translator {

        string  name;

        uint    numWork;

        uint    likeCount;

        uint    hateCount;

        bool    isExist;

        bool    isAvailable;

    }



    mapping ( address => Translator ) translators;

    address[] knownTranslators; //this is registed translators(for UI)

    address[] translations;     //this is matched translation contracts



    function createTranslator (string _name) public payable {

        //translator should pay 1 ether register translator

        require(msg.value == 1 ether);

        Translator memory newTranslator;

        newTranslator.name = _name;

        newTranslator.numWork = 0;

        newTranslator.isExist = true;

        newTranslator.isAvailable =true;

        translators[msg.sender] = newTranslator;

        knownTranslators.push(msg.sender);

        contractBalance += msg.value;

    }



    //To get translators List

    function getTranslatorList() public view returns(address[]) {

        return knownTranslators;

    }



    //To get translator's Information

    function getInfoTranslator(address _addressTranslator) public view returns(string, uint, uint, uint, bool, bool) {

        return(translators[_addressTranslator].name, translators[_addressTranslator].numWork, translators[_addressTranslator].likeCount, translators[_addressTranslator].hateCount, translators[_addressTranslator].isExist, translators[_addressTranslator].isAvailable);

    }



    function createTranslateContract(address _addressTranslator, uint _price) public payable returns(address) {

        require(msg.value ==  (_price * 1000000000000000000) +  1 ether);

        require(translators[_addressTranslator].isExist == true);

        //if someone request to Translator, translator's state become 'Not Available'

        translators[_addressTranslator].isAvailable = false;

        Translation translation = new Translation(_addressTranslator, msg.sender, _price);

        translations.push(translation);

        contractBalance += msg.value;

        return translation;

    }



    function getTranlationList() public view returns(address[]) {

        return translations;

    }



    function getIntoTranslationContract(address _translationContractAddress) public view returns(address, address, uint, bool, bool){

        Translation child = Translation(_translationContractAddress);

        return(child.getInfoTranslation());

    }



    function accept(address _translationContractAddress) public {

        Translation child = Translation(_translationContractAddress);

        child.acceptTranslation(msg.sender);

    }



    function finish(address _translationContractAddress, bool _likeYn) public {

        Translation child = Translation(_translationContractAddress);

        child.finishTranlation(msg.sender, _likeYn);

    }



    function finalTransfer(address _addressTranslator, uint _price) public payable {

        contractBalance -= ( _price );

        _addressTranslator.transfer(_price);

    }



    function updateReputaion(address _addressTranslator, bool _likeYn) public {

        translators[_addressTranslator].numWork++;

        translators[_addressTranslator].isAvailable = true;

        if(_likeYn) {

            translators[_addressTranslator].likeCount++;

        }else{

            translators[_addressTranslator].hateCount++;

        }

    }

}



contract Translation {



    address addressFactory = msg.sender; // CA (TranslationFactory contract address)



    address addressTranslator;             //

    address addressRequester;      // EOA

    uint    price;

    bool    isAccepted = false;   // [TODO-C] make enum for state

    bool    isEnd = false;         // [TODO-C] make enum for state



    // requester makes a Translation contract

    constructor(address _addressTranslator, address _addressRequester, uint _price) payable public {

        //require(addressFactory == msg.sender);

        addressTranslator = _addressTranslator;

        addressRequester = _addressRequester;

        price = _price;

    }



    // someone(?) can see Work contract info

    function getInfoTranslation() public view returns(address, address, uint, bool, bool) {

        // [TODO-A] choose which data should be shown.

        return (addressTranslator, addressRequester, price, isAccepted,isEnd);

    }



    // Only translator can accept Translation contract

    function acceptTranslation(address _addressTranslator) public  {

        require( addressTranslator == _addressTranslator);

        require( !isAccepted );

        isAccepted = true;

    }



    // Only Requester can finish own Translation contract

    function finishTranlation(address _addressRequester, bool _likeYn) public {

        require( _addressRequester == addressRequester );

        require( isAccepted );

        require( !isEnd );



        //finish this contract

        isEnd = true;



        TranslationFactory factory = TranslationFactory(addressFactory);

        // transfer to translator

        factory.finalTransfer(addressTranslator, price);

        factory.updateReputaion(addressTranslator, _likeYn);



    }

}