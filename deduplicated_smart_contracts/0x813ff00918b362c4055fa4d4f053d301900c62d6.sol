/**

 *Submitted for verification at Etherscan.io on 2018-11-13

*/



pragma solidity ^0.4.24;





contract DSAuthEvents {

    event LogSetAuthority (address indexed authority);

    event LogSetOwner     (address indexed owner);

}



contract DSAuth is DSAuthEvents {

    mapping(address => bool)  public  authority;

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



    function setAuthority(address authority_)

        public

        auth

    {

        authority[authority_] = true;

        emit LogSetAuthority(authority_);

    }



    modifier auth {

        require(isAuthorized(msg.sender));

        _;

    }



    function isAuthorized(address src) internal view returns (bool) {

        if (src == address(this)) {

            return true;

        } else if (src == owner) {

            return true;

        } else if (authority[src] == true) {

            return true;

        } else {

            return false;

        }

    }

}



contract KYCVerification is DSAuth{

    

    mapping(address => bool) public kycAddress;

    

    event LogKYCVerification(address _kycAddress,bool _status);

    

    function addVerified(address[] _kycAddress,bool _status) auth public

    {

        for(uint tmpIndex = 0; tmpIndex <= _kycAddress.length; tmpIndex++)

        {

            kycAddress[_kycAddress[tmpIndex]] = _status;

        }

    }

    

    function updateVerifcation(address _kycAddress,bool _status) auth public

    {

        kycAddress[_kycAddress] = _status;

        

        emit LogKYCVerification(_kycAddress,_status);

    }

    

    function isVerified(address _user) view public returns(bool)

    {

        return kycAddress[_user] == true; 

    }

}