/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract prescriptionwaste {

    uint256 recordId;
    address owner;

    struct Record  {
        uint256 id;
        address ownerAddress;
        uint64 ndc;
        string lot;
        string serial;
        uint expirationDate;
        uint16 quantity;
        uint donationDate;
        string donationPostalCode;
        string terminalPostalCode;
        bool individual;
    }
    
    
    
    constructor () public {
        owner = msg.sender;
        recordId = 0;
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _; 
    } 

    mapping(uint256 => Record) public records;
    
    function AddRecord(uint64 ndc, string memory lot, string memory serial, uint expirationDate, uint16 quantity, uint donationDate,
                            string memory donationPostalCode, string memory terminalPostalCode, bool individual) public returns (uint256) {
        
        require(ndc>0);
        require(quantity>0);
        
        recordId++;
        records[recordId] = Record(recordId, msg.sender, ndc, lot, serial, expirationDate, quantity, donationDate, donationPostalCode, terminalPostalCode, individual);
        return recordId;
    }
    

    function CountRecords() private view returns(uint256) {
        return recordId;
    }
    
    function DeleteRecord(uint256 id) public isOwner {
        delete records[id];
    }
    
    function GetNDCCount(uint64 ndc) private view returns(uint64) {
        uint64 len = 0;
        for (uint256 i = 1; i <= recordId; i++) {
            if (ndc == records[i].ndc){
                len++;
            }
        }
        return len;
    }
    
    function SeachByNDC(uint64 ndc) public view returns(Record[] memory) {
        
        uint64 len = GetNDCCount(ndc);

        Record[] memory tmpRecords = new Record[](len);
        len = 0;
        for (uint256 i = 1; i <= recordId; i++) {
            if (ndc == records[i].ndc){
                tmpRecords[len] = records[i];
                len++;
            }
        }
        return tmpRecords;
    }
    
}