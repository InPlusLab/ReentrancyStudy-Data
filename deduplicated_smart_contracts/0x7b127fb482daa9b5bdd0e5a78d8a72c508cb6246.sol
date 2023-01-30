/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.10;


contract LESProxy {
    
    mapping(address => bool) public soci;
    address[] public sociIndex;
    uint public numeroSoci;
    
    struct Statuto {
        address _address;
        uint networkId;
        uint votes;
        mapping(address => bool) votedBy;
        uint _index;
    }
    
    mapping(uint => Statuto) public statuti;
    uint numeroStatuti;
    
    mapping (uint => mapping(address => Statuto)) statutiDaVotare;
    
    address socio1 = 0x61E279Dc78D66bB722E054bE5233381f4e3a6fF5;
    address socio2 = 0x5Eb37c43333F05aB3ad99183Dcf4669022571454;
    address socio3 = 0xe6029C5f7C93f1A261EC4e720DE9E7b29Cdc09a9;
    address socio4 = 0xC537a9453ea1A93EE31175ED7AD31d82B12F9912;
    address socio5 = 0x07bc5B5Fd8e856C44A68D46B2050c02A89deb2b4;
    
    address owner;
    
    event NuovoStatuto(address _address, uint256 _networkId);
    
    constructor () public {
        owner = msg.sender;
        aggiungiSocio(socio1);
        aggiungiSocio(socio2);
        aggiungiSocio(socio3);
        aggiungiSocio(socio4);
        aggiungiSocio(socio5);
        
    }
    
    function close() public {
        require(msg.sender==owner);
        selfdestruct(msg.sender);
    }
    
    function aggiungiSocio(address _address) internal {
        require(!soci[_address], "Gi¨¤ socio");
        soci[_address] = true;
        sociIndex.push(_address);
        numeroSoci++;
    }
    
    function votaNuovoStatuto (address _address, uint networkId) public {
        require(soci[msg.sender], "Solo i soci possono votare");
        require(!statutiDaVotare[networkId][_address].votedBy[msg.sender], "Hai gi¨¤ votato");
        statutiDaVotare[networkId][_address].votedBy[msg.sender] = true;
        statutiDaVotare[networkId][_address].votes++;
        if (statutiDaVotare[networkId][_address].votes == numeroSoci) {
            statuti[numeroStatuti] = statutiDaVotare[networkId][_address];
            statuti[numeroStatuti]._index = numeroStatuti;
            statuti[numeroStatuti]._address = _address;
            statuti[numeroStatuti].networkId = networkId;
            numeroStatuti++;
            emit NuovoStatuto(_address, networkId);
        }
    }
    
    function statuto() public view returns (address _address, uint networkId) {
        require(numeroStatuti>0);
        return(statuti[numeroStatuti-1]._address, statuti[numeroStatuti-1].networkId);
    }
}