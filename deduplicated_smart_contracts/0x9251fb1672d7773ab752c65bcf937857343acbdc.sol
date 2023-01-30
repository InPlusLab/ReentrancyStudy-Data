/**
 *Submitted for verification at Etherscan.io on 2020-07-24
*/

pragma solidity 0.5.16;



//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address internal owner;
    address internal newOwner;

    /**
        Signer is deligated admin wallet, which can do sub-owner functions.
        Signer calls following four functions:
            => request fund from game contract
    */
    address internal signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, 'caller must be owner');
        _;
    }

    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }

    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner, 'caller must be new owner');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


interface tokenInterface
{
    function transfer(address to, uint amount) external returns(bool);
}



contract subHex is owned
{
    address private hexContractAddress;
    address private referrerAddress;

    function setHexContractAddress(address _hexContractAddress,address _referrerAddress) public onlyOwner returns(bool)
    {
        hexContractAddress = _hexContractAddress;
        referrerAddress = _referrerAddress;
        return true;
    }

    event payExtraEv(address indexed to, uint indexed bonus, uint indexed entryId );
    function payExtra(address to, uint bonus, uint entryId) public onlySigner  returns(bool)
    {
        tokenInterface(hexContractAddress).transfer(to,bonus/2);
        tokenInterface(hexContractAddress).transfer(referrerAddress, bonus/2);
        emit payExtraEv(to,bonus, entryId);
        return true;
    }

}