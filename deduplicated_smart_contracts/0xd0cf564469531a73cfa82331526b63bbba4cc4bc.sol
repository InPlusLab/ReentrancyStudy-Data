/**
 *Submitted for verification at Etherscan.io on 2019-12-24
*/

pragma solidity 0.5.12;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

 contract Multisig {
    using SafeMath for uint256;
    address payable public superAdmin;
    address[] public owners;
    uint256 public transactionId;
    uint256 public transactionCount;
    bool public status;

    mapping (address => bool) public newOwner;
    mapping (uint256 => bool) public confirmations;
    mapping (uint256 => bool) public isConfirmed;
    mapping (address => mapping(uint256 => bool)) public setConfirm;
    mapping (uint256 => uint256) public confirmCount;
    mapping (address => mapping(address => bool)) public ownertnx;
    
    event Ownerchange(address indexed owneraddress, address newowner, uint256 indexed tnxid);
    event Mint(address indexed owneraddress, uint256 _time, uint256 indexed tnxid);
    event Vest(address indexed owneraddress, address useraddress, uint256 vestamount, uint256 indexed tnxid);
    event Approved(address indexed owneraddress, uint256 indexed tnxid);

    constructor(bool _status) public {
        superAdmin = msg.sender;
        owners.push(superAdmin);
        newOwner[msg.sender] = true;
        status = _status;
    } 
    
    modifier onlySuperAdmin() {
        require (msg.sender == superAdmin, "onlySuperAdmin");
        _;
    }
    
    modifier isOwner() {
        require (newOwner[msg.sender], "Not a owner");
        _;
    }
    
    modifier contractStatus() {
         require(status, "Contract Inactive");
         _;
    }
    
    /**
     * @dev Change and update Super admin 
     * @param _address New address to be changed 
     */ 
    function changeSuperadmin(address payable _address) public onlySuperAdmin returns(bool) {
        require(_address != address(0), "Null Address");
        superAdmin = _address;
        return true;
    }
    
    /**
     * @dev Add owner
     * @param ownerAddress Address to be added as owner list
     */ 
    function addOwner(address[] memory ownerAddress) public onlySuperAdmin contractStatus returns (bool) {
        for(uint i=0; i < ownerAddress.length; i++) {
            require (!newOwner[ownerAddress[i]],"Already a owner");
            newOwner[ownerAddress[i]] = true;
            owners.push(ownerAddress[i]);
        }
        return true;
    }
    
    /**
     * @dev Remove Owner 
     * @param _address Address to be removed from owner list
     */
    function removeOwner(address _address) public onlySuperAdmin contractStatus returns (bool) {
        require (newOwner[_address], "Not a owner");
        for(uint i=0; i < owners.length; i++) {
            if(owners[i] == _address) {
                owners[i] = owners[owners.length.sub(1)];
                owners.length = owners.length.sub(1);
            }
        }
        newOwner[_address] = false;
        return true;
    }
    
    /**
     * @dev Request submission for owner change in AFX contract 
     * @param currentOwner Current owner address 
     * @param _newOwner New owner address
     */ 
    function requestOwnerChange(address currentOwner, address _newOwner) public contractStatus returns (uint256) {
        require ((currentOwner != address(0)) && (_newOwner != address(0)),"Null address");
        require (newOwner[currentOwner], "Should already be a owner"); 
        require(!newOwner[_newOwner],"Should not be a owner");
        require(!ownertnx[currentOwner][_newOwner], "Transaction submitted already");
        ownertnx[currentOwner][_newOwner] = true;
        transactionId = transactionCount.add(1);
        confirmations[transactionId] = true;
        transactionCount = transactionCount.add(1);
        emit Ownerchange(currentOwner, _newOwner, transactionId);
        return transactionId;
    }
    
    /** @dev Approve Request 
     * _transactionId Id to be approved
     */ 
    function approveRequest(uint256 _transactionId) public isOwner contractStatus returns (bool) {
        require(confirmations[_transactionId], "Invalid Transaction");
        require(_setConfirmation(_transactionId), "Transaction not confirmed");
        return true;
    }
    
    /**
     * @dev Internal function
     */ 
    function _setConfirmation(uint256 _transactionId) internal returns (bool) {
        require (!setConfirm[msg.sender][_transactionId], "Transaction already confirmed");
        setConfirm[msg.sender][_transactionId] = true;
        confirmCount[_transactionId] = confirmCount[_transactionId].add(1);
        if(confirmCount[_transactionId] > (owners.length).div(2)) {
            isConfirmed[_transactionId] = true;
        }
        emit Approved(msg.sender, transactionId);
        return true;
    }
    
    /**
     * @dev Check if request is approved
     * @param _transactionId Id to check 
     */ 
    function executeAdminChange(uint256 _transactionId, address _newaddress) public returns (bool) {
        require(confirmations[_transactionId], "Invalid Transaction");
        newOwner[_newaddress] = true;
        owners.push(_newaddress);
        return isConfirmed[_transactionId];
    }
    
    /**
     * @dev Check if request is approved
     * @param _transactionId Id to check 
     */ 
    function executeChange(uint256 _transactionId) public view returns (bool) {
        require(confirmations[_transactionId], "Invalid Transaction");
        return isConfirmed[_transactionId];
    }

    /**
     * @dev Request submission for vesting in AFX contract 
     * @param _owner Token holder address 
     * @param _address User address 
     * @param _amount Amount to be vest
     */ 
    function vestingTransaction(address _owner, address _address, uint256 _amount) public contractStatus returns (uint256) {
        require (newOwner[_owner],"Not a owner");
        transactionId = transactionCount.add(1);
        confirmations[transactionId] = true;
        transactionCount = transactionCount.add(1);
        emit Vest(_owner, _address, _amount, transactionId);
        return transactionId;
    }
    
    /**
     * @dev Request submission for Minting in AFX contract
     * @param _owner Token holder address 
     * @param _amount Amount to mint 
     * @param _time Requested time
     */ 
    function mintTransaction(address _owner, uint256 _amount, uint256 _time) public contractStatus returns (uint256) {
        require (newOwner[_owner],"Not a owner");
        transactionId = transactionCount.add(1);
        confirmations[transactionId] = true;
        transactionCount = transactionCount.add(1);
        emit Mint(_owner, _amount, _time);
        return transactionId;
    }
    
    /**
     * @dev Return owner count 
     */ 
    function ownerscount() public view returns(uint256) {
        return owners.length;
    }
    
    /**
     * @dev Update Contract status
     * @param _status Status to be updated
     */ 
    function updatecontractStatus(bool _status) public onlySuperAdmin returns(bool) {
        require(status != _status);
        status = _status;
        return true;
    }
    
    /**
     * @dev Selfdestruct
     */ 
    function kill() public onlySuperAdmin {
        selfdestruct(superAdmin);
    }
    
 }