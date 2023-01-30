/**

 *Submitted for verification at Etherscan.io on 2018-12-13

*/



pragma solidity ^0.4.24;



contract DepositRegistry {



    function getTokenContract() public view returns(address);

    function getDepositAdmin() public view returns(address);

    function getColdWallet() public view returns(address);



    function changeColdWallet(address _newWallet) public;



    event ColdWalletChanged(address previousWallet, address newWallet);

    event TokenChanged(address previousToken, address newToken);



}



contract DepositRegistryImpl is DepositRegistry {



    address tokenContract;

    address depositAdmin;

    address coldWallet;



    modifier onlyByAdmin() {

        require(msg.sender == depositAdmin, "Transaction sender is not an admin");

        _;

    }



    constructor(address _tokenContract, address _coldWallet, address _depositAdmin) public {

        tokenContract = _tokenContract;

        coldWallet = _coldWallet;

        depositAdmin = _depositAdmin;

    }



    function getTokenContract() public view returns(address) {

        return tokenContract;

    }



    function getDepositAdmin() public view returns(address) {

        return depositAdmin;

    }



    function getColdWallet() public view returns(address) {

        return coldWallet;

    }



    function changeColdWallet(address _newWallet) public onlyByAdmin {

        coldWallet = _newWallet;

        emit ColdWalletChanged(depositAdmin, _newWallet);

    }



}