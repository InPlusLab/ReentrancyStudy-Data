/**

 *Submitted for verification at Etherscan.io on 2019-03-19

*/



pragma solidity >=0.4.21 < 0.6.0;



library BloomFilter {

    struct Filter {

        uint256 bitmap;

        uint8 hashCount;

    }

    

    function getHashCount(uint _itemNum) public pure returns(uint8) {

        uint numOfHash = (256 * 144) / (_itemNum * 100) + 1;

        if(numOfHash < 256) return uint8(numOfHash);

        else return 255;

    }



    function addToBitmap(uint256 _bitmap,  uint8 _hashCount, bytes32 _item) public pure returns(uint256) {

        require(_hashCount > 0);

        for(uint i = 0; i < _hashCount; i++) {

            uint256 position = uint256(keccak256(abi.encodePacked(_item, i))) % 256;

            require(position < 256);

            uint256 digest = 1 << position;

            _bitmap = _bitmap | digest;

        }

        return _bitmap;

    }



    function falsePositive(uint256 _bitmap,  uint8 _hashCount, bytes32 _item) public pure returns(bool _probablyPresent){

        require(_hashCount > 0);

        for(uint i = 0; i < _hashCount; i++) {

            uint256 position = uint256(keccak256(abi.encodePacked(_item, i))) % 256;

            require(position < 256);

            uint256 digest = 1 << position;

            if(_bitmap != _bitmap | digest) return false;

        }

        return true;

    }



    function init(Filter storage _filter, uint _itemNum) internal {

        _filter.hashCount = getHashCount(_itemNum);

    }



    function add(Filter storage _filter, bytes32 _item) internal {

        _filter.bitmap = addToBitmap(_filter.bitmap, _filter.hashCount, _item);

    }



    function check(Filter storage _filter, bytes32 _item) internal view returns(bool) {

        return falsePositive(_filter.bitmap, _filter.hashCount, _item);

    }

}