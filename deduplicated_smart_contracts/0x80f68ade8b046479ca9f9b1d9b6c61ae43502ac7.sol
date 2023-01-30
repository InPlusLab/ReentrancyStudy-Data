/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

// File: contracts/ApostleBaseAuthorityV2.sol


// File: contracts/LandResourceAuthorityV3.sol

pragma solidity ^0.4.24;

contract IAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}


contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

/**
 * @title DSAuth
 * @dev The DSAuth contract is reference implement of https://github.com/dapphub/ds-auth
 * But in the isAuthorized method, the src from address(this) is remove for safty concern.
 */
contract DSAuth is DSAuthEvents {
    IAuthority   public  authority;
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

    function setAuthority(IAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == owner) {
            return true;
        } else if (authority == IAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}


pragma solidity ^0.4.24;

contract ApostleBaseAuthorityV2 is DSAuth{
    mapping (address => bool) public whiteList;

    constructor(address[] _whitelists) public {
        for (uint i = 0; i < _whitelists.length; i ++) {
            whiteList[_whitelists[i]] = true;
        }
    }

    function canCall(
        address _src, address _dst, bytes4 _sig
    ) public view returns (bool) {
        return ( whiteList[_src] && _sig == bytes4(keccak256("createApostle(uint256,uint256,uint256,uint256,uint256,address)")) ) ||
               ( whiteList[_src] && _sig == bytes4(keccak256("breedWithInAuction(uint256,uint256)")) ) ||
               ( whiteList[_src] && _sig == bytes4(keccak256("activityAdded(uint256,address,address)"))) ||
                ( whiteList[_src] && _sig == bytes4(keccak256("activityRemoved(uint256,address,address)"))) ||
                ( whiteList[_src] && _sig == bytes4(keccak256("updateGenesAndTalents(uint256,uint256,uint256)"))) ||
                ( whiteList[_src] && _sig == bytes4(keccak256("batchUpdate(uint256[],uint256[],uint256[])"))) ||
                ( whiteList[_src] && _sig == bytes4(keccak256("activityStopped(uint256)")));
    }
    
        
    function addWhiteList(address whiteAddress) public auth{
        whiteList[whiteAddress] = true;
    }
}