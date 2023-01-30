/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity 0.5.10;

contract CXTContract {
    
    function transfer(address to, uint256 value) external returns (bool);
    function newArt(string calldata _id, string calldata _regReport) external returns (bool);
    function setArtIdt(string calldata _id, string calldata _idtReport) external returns (bool);
    function setArtEvt(string calldata _id, string calldata _evtReport) external returns (bool);
    function setArtEsc(string calldata _id, string calldata _escReport) external returns (bool);
    function issue(address _addr, uint256 _amount, uint256 _timestamp) external returns (bool);
    // function distribute(address _to, uint256 _amount, uint256 _timestamp, address[] calldata _addressLst, uint256[] calldata _amountLst) external returns(bool);
    function release(address[] calldata _addressLst, uint256[] calldata _amountLst) external returns (bool);
    // function bonus(uint256 _sum, address[] calldata _addressLst, uint256[] calldata _amountLst) external returns (bool);
}

contract CXTCManager {
    
    address public systemAcc;
    CXTContract public CXTCInstance;
    event UpdateSystemAcc(address indexed previousAcc, address indexed newAcc);

    /**
     * @dev Throws if called by any account other than the systemAcc.
     */
    modifier onlySys() {
        require(msg.sender == systemAcc, "CXTCManager: the caller must be systemAcc");
        _;
    }

    function updateSysAcc(address _newAcc) public onlySys {
        require(_newAcc != address(0), "CXTCManager: the new system account cannot be a zero address");
        emit UpdateSystemAcc(systemAcc, _newAcc);
        systemAcc = _newAcc;
    }

    /**
     * @dev Constructor.
     * @param _systemAcc The system account for CXTContract.
     * @param _cxtcAddr Managed contract address.
     */
    constructor(address _systemAcc, address _cxtcAddr) public {
        systemAcc = _systemAcc;
        CXTCInstance = CXTContract(_cxtcAddr);
    }


    function newArt(string memory _id, string memory _regReport) public onlySys returns (bool) {
        return CXTCInstance.newArt(_id, _regReport);
    }
    
    function setArtIdt(string memory _id, string memory _idtReport) public onlySys returns (bool) {
        return CXTCInstance.setArtIdt(_id, _idtReport);
    }
    
    function setArtEvt(string memory _id, string memory _evtReport) public onlySys returns (bool) {
        return CXTCInstance.setArtEvt(_id, _evtReport);
    }
    
    function setArtEsc(string memory _id, string memory _escReport) public onlySys returns (bool) {
        return CXTCInstance.setArtEsc(_id, _escReport);
    }
    
    function issue(address _addr, uint256 _amount, uint256 _timestamp) public onlySys returns (bool) {
        return CXTCInstance.issue(_addr, _amount, _timestamp);
    }
        
    // function distribute(address _to, uint256 _amount, uint256 _timestamp, address[] memory _addressLst, uint256[] memory _amountLst) public onlySys returns (bool) {
    //    return CXTCInstance.distribute(_to, _amount, _timestamp, _addressLst, _amountLst);
    // }
    
    function release(address[] memory _addressLst, uint256[] memory _amountLst) public onlySys returns (bool) {
        return CXTCInstance.release(_addressLst, _amountLst);
    }
    
    
    function withdrawToken(address _addr, uint256 _amount) public onlySys returns (bool) {
        return CXTCInstance.transfer(_addr, _amount);
    }

    // function bonus(uint256 _sum, address[] memory _addressLst, uint256[] memory _amountLst) public onlySys returns (bool) {
    //     return CXTCInstance.bonus(_sum, _addressLst, _amountLst);
    // }
}