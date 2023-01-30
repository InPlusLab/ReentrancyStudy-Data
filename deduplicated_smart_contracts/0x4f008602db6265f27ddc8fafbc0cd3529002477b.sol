/**

 *Submitted for verification at Etherscan.io on 2019-05-12

*/



pragma solidity ^0.4.23;



contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");

    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");

    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");

    }



    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;

    }

    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;

    }

    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;

    }

    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;

    }



    uint constant WAD = 10 ** 18;

    uint constant RAY = 10 ** 27;



    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;

    }

    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;

    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;

    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;

    }



    // This famous algorithm is called "exponentiation by squaring"

    // and calculates x^n with x as fixed-point and n as regular unsigned.

    //

    // It's O(log n), instead of O(n) for naive repeated multiplication.

    //

    // These facts are why it works:

    //

    //  If n is even, then x^n = (x^2)^(n/2).

    //  If n is odd,  then x^n = x * x^(n-1),

    //   and applying the equation for even x gives

    //    x^n = x * (x^2)^((n-1) / 2).

    //

    //  Also, EVM division is flooring and

    //    floor[(n-1) / 2] = floor[n / 2].

    //

    function rpow(uint x, uint n) internal pure returns (uint z) {

        z = n % 2 != 0 ? x : RAY;



        for (n /= 2; n != 0; n /= 2) {

            x = rmul(x, x);



            if (n % 2 != 0) {

                z = rmul(z, x);

            }

        }

    }

}



contract DSNote {

    event LogNote(

        bytes4   indexed  sig,

        address  indexed  guy,

        bytes32  indexed  foo,

        bytes32  indexed  bar,

        uint256           wad,

        bytes             fax

    ) anonymous;



    modifier note {

        bytes32 foo;

        bytes32 bar;

        uint256 wad;



        assembly {

            foo := calldataload(4)

            bar := calldataload(36)

            wad := callvalue

        }



        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);



        _;

    }

}



contract DSAuthority {

    function canCall(

        address src, address dst, bytes4 sig

    ) public view returns (bool);

}



contract DSAuthEvents {

    event LogSetAuthority (address indexed authority);

    event LogSetOwner     (address indexed owner);

}





contract DSAuth is DSAuthEvents {

    DSAuthority  public  authority;

    address      public  owner;



    constructor() public {

        owner = msg.sender;

        emit LogSetOwner(msg.sender);

    }



    function setOwner(address owner_)

        public

        auth

    {

        owner = owner_;

        emit LogSetOwner(owner);

    }



    function setAuthority(DSAuthority authority_)

        public

        auth

    {

        authority = authority_;

        emit LogSetAuthority(address(authority));

    }



    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");

        _;

    }



    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == address(this)) {

            return true;

        } else if (src == owner) {

            return true;

        } else if (authority == DSAuthority(0)) {

            return false;

        } else {

            return authority.canCall(src, address(this), sig);

        }

    }

}





contract DSThing is DSAuth, DSNote, DSMath {

    function S(string memory s) internal pure returns (bytes4) {

        return bytes4(keccak256(abi.encodePacked(s)));

    }



}





contract DSValue is DSThing {

    bool    has;

    bytes32 val;

    function peek() public view returns (bytes32, bool) {

        return (val,has);

    }

    function read() public view returns (bytes32) {

        bytes32 wut; bool haz;

        (wut, haz) = peek();

        require(haz, "haz-not");

        return wut;

    }

    function poke(bytes32 wut) public note auth {

        val = wut;

        has = true;

    }

    function void() public note auth {  // unset the value

        has = false;

    }

}





contract DSMessage is DSThing {

    struct Message {

        bool    has;

        bytes32 val;

    }

    

    // 

    Message[] Messages;

    

    uint indexTobePost;

    

    function setPos() public {

        uint lastPos = Messages.length;

        

        for (uint i = lastPos; i == 0; i--) {

            if (Messages[i].has == true) {

                indexTobePost = i;

                break;   

            }

        }

    }

    

    function getPost() public view returns (uint) {

        //overide post message position

        return indexTobePost;

    }

    

    function poke(bytes32 wut) public note auth {

        Messages.push(Message(false, wut));

    }

    

    function lastConfirm() private auth {

        confirm(Messages.length);

    }

    

    function confirm(uint msgNum) private auth {

        Messages[msgNum].has = true;

    }

    

    function unconfirm(uint msgNum) private auth {

        Messages[msgNum].has = false;

    }

    

    function peek(uint msgNum) public view returns (bytes32, bool) {

        return (Messages[msgNum].val, Messages[msgNum].has);

    }

    

}