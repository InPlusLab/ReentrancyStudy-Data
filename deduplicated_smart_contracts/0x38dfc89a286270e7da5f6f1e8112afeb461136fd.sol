/**
 *Submitted for verification at Etherscan.io on 2020-06-29
*/

pragma solidity >=0.4.22 <0.7.0;

contract AuthentoFile {

struct ClaimInfo {
    uint256 clientId;
    string claimTitle;
    bytes32 claimHash;
    string claimCreditCardTransID;
    string clientIp;
    uint claimTimestamp;
    uint minerTimestamp;
}

// Look up ClaimInfo Data by Client Claim ID
// Make private so only Admins can see this data
mapping(uint256 => ClaimInfo) public claimByClientId;

// Look up ClaimInfo Data by Client Document Hash
mapping(bytes32 => ClaimInfo) public claimByHash;

//  The number of property claims
uint256 private claimCount;

// Used to track current contract state
string private contractState;

// Account information (review before we go LIVE)
//Main Net AF Contract Owner (Deployer) 0xaaf66209133056f1f7285d6cdb61cf21d135f300,

address payable private owner;

//Ropsten Admin Account
//address payable private adminAccount  = 0x103E19e47cdc18BefBF7435Aa2A2b6FD30b2942C;
//Main Net Admin Account
address payable private adminAccount =  0xaAF66209133056F1f7285D6cDb61Cf21D135f300;
//address payable private adminAccount =  0xE6b51e1e5A424E719c4A57D4c8f0FAcD87E45012;

// Constructor is fired ONCE when Contract is Deployed to Blockchain
constructor () public  {
    claimCount = 0;
    contractState = "deployed";
    owner = msg.sender;

}

// Modifier to check if msg.sender is Contract Owner
modifier ownerOnly()
    {
        require (
        isOwner() == true, "Security Violation - You are not the AuthentoFile contract owner"
    );
// Do not forget the "_;"! It will
// be replaced by the actual function
// body when the modifier is used.
    _;
}

// Modifier to check if msg.sender is Contract Owner or Defined Admin Account
modifier adminOnly() {
    require (
        isAdmin() == true, "Security Violation - You are not an AuthentoFile admin"
    );
    _;
}

//When we want to deplete Ether from Contract Address
function closeContractFunds() public ownerOnly {
    adminAccount.transfer(address(this).balance);
}

//Only contract owner (AuthentoFle Ccontract Owner) can execute this method
function claimProperty (string memory _titleAsString, bytes32 _artifcactHash, uint _timestamp, string memory _ccTransactionID,
                        string memory _clientIP, string memory _contractState) public ownerOnly
{
    claimCount ++;
    claimByClientId[claimCount] = ClaimInfo(claimCount, _titleAsString, _artifcactHash, _ccTransactionID, _clientIP, _timestamp, now);
    claimByHash[_artifcactHash] = ClaimInfo(claimCount, _titleAsString, _artifcactHash, _ccTransactionID, _clientIP, _timestamp, now);

    contractState = _contractState;
}
//--------------------------------------------------------------
// Public Admin Functions


function getContractState() public adminOnly view returns (string memory) {
	return contractState;
}

function getClaimsProcessed() public adminOnly view returns (uint256)
{
    return claimCount;
}

function getContractBalance() public adminOnly view returns (uint256)
{
  
    return address(this).balance;
}
  
function getContractOwnerBalance() public adminOnly view returns (uint256)
{
    return address(owner).balance;
}

function getContractOwner() public adminOnly view returns(address) {
    return owner;
}

function getContractAdmin() public adminOnly view returns(address) {
    return adminAccount;
}

function setContractState(string memory _value) public adminOnly {
    contractState = _value;
}

//----------------------------------------------------------------
// Private Contract Functions
function isOwner() private view returns (bool) {
    return (msg.sender == owner);
}

//---------------------------------------------------------------
//Internal Functions
function isAdmin() internal view returns (bool) {
    return (msg.sender == owner || msg.sender == adminAccount);
}

// Fallback function to allow contract to receive Ether
function deposit() external payable {}

}