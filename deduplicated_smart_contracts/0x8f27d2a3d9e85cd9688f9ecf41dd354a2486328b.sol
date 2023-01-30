/**

 *Submitted for verification at Etherscan.io on 2019-01-16

*/



pragma solidity ^0.5.0;



contract DerivedAddressCalc {

    

    function derivedAddress(address _origin, uint256 _nonce) public pure returns (string memory) {

        bytes memory packed;

        

        if (_nonce == 0x00) {

            packed = abi.encodePacked(byte(0xd6), byte(0x94), _origin, byte(0x80));

        } else if (_nonce <= 0x7f) {

            packed = abi.encodePacked(byte(0xd6), byte(0x94), _origin, uint8(_nonce));

        } else if (_nonce <= 0xff) {

            packed = abi.encodePacked(byte(0xd7), byte(0x94), _origin, byte(0x81), uint8(_nonce));

        } else if (_nonce <= 0xffff) {

            packed = abi.encodePacked(byte(0xd8), byte(0x94), _origin, byte(0x82), uint16(_nonce));

        } else if (_nonce <= 0xffffff) {

            packed = abi.encodePacked(byte(0xd9), byte(0x94), _origin, byte(0x83), uint24(_nonce));

        } else {

            packed = abi.encodePacked(byte(0xda), byte(0x94), _origin, byte(0x84), uint32(_nonce));

        }

        

        bytes32 addressBytes32 = keccak256(packed);

        return addressBytes32ToString(addressBytes32);

    }



    function addressBytes32ToString(bytes32 _value) private pure returns (string memory) {

        bytes memory alphabet = "0123456789abcdef";

        bytes memory resultBytes = new bytes(42);



        resultBytes[0] = '0';

        resultBytes[1] = 'x';

        

        for (uint256 i = 0; i < 20; i++) {

            resultBytes[i * 2 + 2] = alphabet[uint8(_value[i + 12] >> 4)];

            resultBytes[i * 2 + 3] = alphabet[uint8(_value[i + 12] & 0x0f)];

        }

        

        return string(resultBytes);

    }



}