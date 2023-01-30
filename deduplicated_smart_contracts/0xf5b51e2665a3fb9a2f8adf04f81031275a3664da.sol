/**

 *Submitted for verification at Etherscan.io on 2019-04-16

*/



pragma solidity ^0.5.0;



contract KittyCoreInterface {

    

    // from ERC721 contract

    // returns the address of the token owner

    function ownerOf(uint256 _tokenId) external view returns (address owner);

    

    // function from KittyCore contract

    // returns data from a specific kitty

    function getKitty(uint256 _id)

        external

        view

        returns (

        bool isGestating,

        bool isReady,

        uint256 cooldownIndex,

        uint256 nextActionAt,

        uint256 siringWithId,

        uint256 birthTime,

        uint256 matronId,

        uint256 sireId,

        uint256 generation,

        uint256 genes

    );

}



contract KittyTransferCO2 {

    

    // addresses related to a kitty transfer

    address public _from;

    address public _to;

    

    // address of the real CryptoKitties contract to interact with

    KittyCoreInterface public cryptoKittiesInterface;

    

    // here we set on deploy the real CryptoKitties contract to call its functions

    // Mainnet CryptoKitties contract address: 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d

    // Rinkeby CryptoKitties contract address: 0x16baF0dE678E52367adC69fD067E5eDd1D33e3bF

    constructor() public {

        cryptoKittiesInterface = KittyCoreInterface(0x06012c8cf97BEaD5deAe237070F9587f8E7A266d);

    }

    

    function setFromAddress(address _addr) public {

        _from = _addr;

    }

    

    function setToAddress(address _addr) public {

        _to = _addr;

    }

    

    // get addresses of owners of kitty's parents

    function getParentsAddresses(uint256 _id) public view returns (address, address) {

        // call to ownerOf(0) reverts!

        require(_id > 0);

        uint256 matronId;

        uint256 sireId;

        

        (,,,,,, matronId, sireId, ,) = cryptoKittiesInterface.getKitty(_id);

        

        address matron = cryptoKittiesInterface.ownerOf(matronId);

        address sire = cryptoKittiesInterface.ownerOf(sireId);

        

        return (matron, sire);

    }

    

    // get ids of kitty's parents

    function getParentsIds(uint256 _id) public view returns (uint256, uint256) {

        require(_id > 0);

        uint256 matronId;

        uint256 sireId;

        

        (,,,,,, matronId, sireId, ,) = cryptoKittiesInterface.getKitty(_id);

        

        return (matronId, sireId);

    }

    

    // get CO2 emmited for kitty transfer, taking addresses of matron and sire owners

    function getCO2EmittedFromKitty(uint256 _id) public view returns(uint256) {

        address matronId;

        address sireId;

        (matronId, sireId) = getParentsAddresses(_id);

        

        uint256 distance = getDistance(matronId, sireId);

        return distance;

    }

    

    // get CO2 emmited for the kitty transfer

    function getCO2EmittedFromAddresses() public view returns(uint256) {

        uint256 distance = getDistance(_from, _to);

        return distance/100000;

    }

    

    // get distance between addresses

    function getDistance(address account1, address account2) internal pure returns(uint256) {

        uint256 location1 = uint256(uint40(account1));

        uint256 location2 = uint256(uint40(account2));

        if(location1 > location2) {

            return location1 - location2;

        } else {

            return location2 - location1;

        }

    }

    

}