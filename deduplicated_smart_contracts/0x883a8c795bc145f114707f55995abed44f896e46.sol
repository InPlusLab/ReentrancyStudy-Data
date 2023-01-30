/**

 *Submitted for verification at Etherscan.io on 2019-02-01

*/



pragma solidity ^0.5.0;



contract MinerGame {



    address owner;



    string[] allMines;



    mapping(bytes32 => string) mines;



    mapping(bytes32 => string) miners;



    event NewMineEvent (

        bytes32 md5OfMineName,

        string mineName          

    );



    event DispatchMinersEvent (

        bytes32 md5OfMineName,

        string md5OfMiners

    );



    constructor()

        public 

    {

        owner = msg.sender;

    }



    function newMine (

        bytes32 md5OfMineName,

        string memory mineName       

    )

        public

        onlyOwner()

        onlyWriteMineOnce(md5OfMineName)

    {

       

        allMines.push(mineName);

        mines[md5OfMineName] = mineName;

        emit NewMineEvent(md5OfMineName,mineName);

    }



    function dispatchMiners (

        bytes32 md5OfMineName,

        string memory md5OfMiners

    )

        public 

        onlyOwner()

        onlyWriteMinersOnce(md5OfMineName)

    {

        miners[md5OfMineName] = md5OfMiners;

        emit DispatchMinersEvent(md5OfMineName,md5OfMiners);

    }



    function isOwner (

        address addr

    )

        public

        view

        returns(bool)

    {

        if(addr == owner) {

            return true;

        }

        return false;

    }



    function isNotDuplicateMine  (

        bytes32 md5OfMineName

    )

        public

        view

        returns(bool) 

    {

        string memory mineName = mines[md5OfMineName];

        return isEmptyString(mineName);

    }



    function isNotDuplicateMiners(

        bytes32 md5OfMineName

    )

        public 

        view 

        returns(bool)

    {

        string memory minerHash = miners[md5OfMineName];

        return isEmptyString(minerHash);

    }



    modifier onlyWriteMineOnce (

        bytes32 signature

    ) {

        require(isNotDuplicateMine(signature),"error : duplicate miners of the mine");

        _;

    }



    modifier onlyWriteMinersOnce (

        bytes32 signature

    ) {

        require(isNotDuplicateMiners(signature),"error : duplicate miners");

        _;

    }



    modifier onlyOwner() {

        require(isOwner(msg.sender),"only the owner has the permession");

        _;

    }



    function getMines ()

        public

        view

        returns(byte[] memory) 

    {

        return concat(allMines,0); 

    }



    function getMine (

        bytes32 md5OfMineName

    )

        public

        view 

        returns(string memory)

    {

        return mines[md5OfMineName];

    }



    function getMiners (

        bytes32 md5OfMineName

    )

        public

        view

	    returns(string memory)

	{

        return miners[md5OfMineName];

    }



    // 连接字符串数组

    function concat(

        string[] memory arrs,

        uint256 index

    )

      private 

      pure

      returns(byte[] memory)

    {

        uint256 arrSize = arrs.length;

        if(arrs.length == 0) {

            return new byte[](0);

        }

        uint256 total = count(arrs,index);

        byte[] memory result = new byte[](total); 

        uint256 k = 0;

        for(uint256 i = index; i < arrSize; i++) {

            bytes memory arr = bytes(arrs[i]);

            for(uint j = 0; j < arr.length; j++) {

                result[k] = arr[j];

                k++;

            }

        }

        return result;

    }



    // 统计长度

    function count(

        string[] memory arrs,

        uint256 index

    )

        private

        pure

        returns(uint256) 

    {

        uint256 total = 0;    

        uint256 len1 = arrs.length;

        for(uint256 i = index;i < len1; i++) {

            bytes memory arr = bytes(arrs[i]);

            total = total + arr.length;

        }

        return total;

    }



    function compare(

        string memory _a, 

        string memory _b

    ) 

        private

        pure

        returns (int) 

    {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) minLength = b.length;

        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons

        for (uint i = 0; i < minLength; i ++) {

            if (a[i] < b[i])

                return -1;

            else if (a[i] > b[i])

                return 1;

        }  

        if (a.length < b.length)

            return -1;

        else if (a.length > b.length)

            return 1;

        else

            return 0;

    }

    

    function equal(

        string memory _a, 

        string memory _b

    ) 

        private

        pure

        returns (bool) 

    {

        return compare(_a, _b) == 0;

    }



    function isEmptyString (

        string memory str

    )

        private 

        pure

        returns(bool)

    {

        bytes memory temp = bytes(str);

        if(temp.length == 0) {

            return true;

        }

        return false;

    }

}