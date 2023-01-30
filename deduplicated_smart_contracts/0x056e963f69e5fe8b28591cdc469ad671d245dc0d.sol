/**

 *Submitted for verification at Etherscan.io on 2019-05-13

*/



pragma solidity ^0.5.7;



contract Evento {

    

    mapping(address => uint256) private _partecipanti;

    uint8 private _numeroPartecipanti;

    address payable private _organizzatore;

    bool private _registrazioneAperta;

    

    uint constant public prezzo = 0.00001 ether;

    

    constructor() public {

        _organizzatore = msg.sender;

        _registrazioneAperta = false;

    }

    

    modifier onlyOwner() {

        require(msg.sender == _organizzatore, "Non sei autorizzato");

        _ ;

    }

    

    modifier costoBiglietto() {

        require(msg.value >= prezzo, "L'importo non �� corretto");

        _ ;

    }

    

    function controlRegistration(bool status) public onlyOwner {

        _registrazioneAperta = status;

    } 

    

    function registrazione() public payable costoBiglietto {

        require(_registrazioneAperta == true, "La registrazione non �� aperta");

        require(_partecipanti[msg.sender] == 0, "Sei gi�� registrato");

        _partecipanti[msg.sender] = now;

        _numeroPartecipanti = _numeroPartecipanti + 1;

        _organizzatore.transfer(msg.value);

    }

    

    function numberOfAttendees() public view returns (uint8) {

        return _numeroPartecipanti;

    }



    function checkin() public view returns(bool){

        return _partecipanti[msg.sender] > 0;

    }

    

}