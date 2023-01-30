/**

 *Submitted for verification at Etherscan.io on 2018-12-21

*/



pragma solidity ^0.4.25;



// Just like every other safemath library used to Prevent overflow and underflow attacks

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}





// Government agent and administrator is used interchangeably throughout the smart contracts

contract Administrator {

    address public administrator;

    address public newAdministrator;



    event AdministrationTransferred(address indexed _from, address indexed _to);



    constructor() public {

        administrator = msg.sender;

    }



    modifier onlyAdministrator {

        require(msg.sender == administrator);

        _;

    }

    

    // Function allows transfer the ownership of this smart contract

    function transferOwnership(address _newAdministrator) public onlyAdministrator {

        newAdministrator = _newAdministrator;

    }

    

    // The new administrator has to accept the ownership transfer after the previous administrator triggers the transferOwnership function above

    function acceptOwnership() public {

        require(msg.sender == newAdministrator);

        emit AdministrationTransferred(administrator, newAdministrator);

        administrator = newAdministrator;

       newAdministrator = address(0);

    }

}



// The interface of ERC20

// This Interface is an abstract ERC20 token so we can use the transfer and transferFrom functions when we get the token address

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



// The interface of ERC721

// This is not a complete ERC721 because we only adopt the functions that make sense in our specific case

contract ERC721Interface{

   function totalSupply() public view returns (uint256);

   function balanceOf(address _owner) public view returns (uint);



    // Functions that defines ownership

   function ownerOf(uint256 _tokenId) public view returns (address);

   function approve(address _to, uint256 _tokenId) public returns (bool);

   function transfer(address _to, uint256 _tokenId) public returns (bool);

   

   // Events 

   event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

   event Approval(address indexed tokenOwner, address indexed spender, uint _tokenId);

}



contract PenthouseMillionaire is ERC721Interface, Administrator {

	using SafeMath for uint;

    

    // The variables related to the property

	struct Property {

		uint propertyID;

		address owner;

		string propertyName;

		string propertyStatus;

		string propertyDescription;

		uint price;

        string note;

        bool ifcollateralized; 

        address registeredbuyer;

        address registeredBank;

    }

	

    address payment_coin;

    uint fee; //this fee should be = (1 / percentage of fee)

    string contractname;

    string contractsymbol;

    uint totalRegisteredProperties;

	mapping(address => uint) balances;        //input the owner's address and return the number of property owned by this address

    mapping(uint => Property) id_to_property; //input the id of the property and return the property's details

    mapping(uint => uint) receivable;         //input the property id and return the amount has been received

    mapping(address => bool) buyer_kyc;       //input the buyer's address and return if the buyer passes the kyc verification

    mapping(address => bool) isbank;          //input the bank's address and return if the bank is registered

    mapping(uint => address) approved;        //input the property id and return if any third party can change the ownership of the property. If so, return the address

    

    //Events 

    event UpdatePropertyStatus(uint propertyID, string propertyStatus, uint price);

    event ReceivePayment(address sendFrom, uint propertyID, uint amount);

    event PropertyDescriptionChange(uint propertyID, string name, string description);

    event KYCStatusChanged(address buyer, bool status);

    event BankRegistrationChanged(address bank, bool registered);

    

	constructor(address stable_coin, uint agency_fee, string name, string symbol) public {

	    payment_coin = stable_coin;

        fee = agency_fee;

        contractname = name;

        contractsymbol = symbol;

        totalRegisteredProperties = 0;

    }



    function paymentCoinAddress() public view returns (address){

        return payment_coin;

    }

    

    // Check how much of the price of the property has been received

    function checkreceivable(uint _tokenId) public view returns (uint){

        return receivable[_tokenId];

    }



    function checkApproval(uint _tokenId) public view returns (address){

        return approved[_tokenId];

    }

    

    //check if the address is a bank address

    function checkBank(address bank) public view returns (bool){

        return isbank[bank];

    }

    

    // Check the KYC status of the buyer 

    function checkKYC(address buyer) public view returns (bool){

        return buyer_kyc[buyer];

    }

    

     // Check the numbers of property an address own

    function balanceOf(address _owner) public view returns (uint) {

        return balances[_owner];

    }

    

    // Return the total numbers of properties that registered

    function totalSupply() public view returns (uint) {

        return totalRegisteredProperties;

    }

    

    // Return the property owner's address by the property ID

    function ownerOf(uint _tokenId) public view returns (address) {

         Property storage myproperty = id_to_property[_tokenId];

         return myproperty.owner;

    }

    

    // The Government Agent can call this function to register the property and its information including the owner's public address on blockchain

    // The default paramter for property:

    // price is 0

    // status is "Cleared"

    // if collateralized is false

    // buy and bank address are none (address(0))

    function registerPropertyAndOwner(uint propertyID, string propertyName, string propertyDescription, address owner) public onlyAdministrator returns (bool){

        Property memory newproperty = Property(propertyID, 

                                        owner,

                                        propertyName, 

                                        "Cleared",

                                        propertyDescription,

                                        0,

                                        "none",

                                        false,

                                        address(0),

                                        address(0));

        id_to_property[propertyID] = newproperty;

	    balances[owner] = balances[owner].add(1);

	    totalRegisteredProperties = totalRegisteredProperties.add(1);

	    emit Transfer(address(0), owner, propertyID);

	    return true;

    }

    

    // Pulling the property's information given its ID

    function getPropertyInfo(uint propertyID) public view returns (address, string, string, string, uint, string, bool, address, address){

    	 Property storage myproperty = id_to_property[propertyID];

    	 return (myproperty.owner, 

    	            myproperty.propertyName,

    	            myproperty.propertyStatus,

    	            myproperty.propertyDescription,

    	            myproperty.price,

    	            myproperty.note,

    	            myproperty.ifcollateralized,

    	            myproperty.registeredbuyer,

    	            myproperty.registeredBank);

    }

    

    //check if two strings are equal in values

    function hashCompareWithLengthCheck(string a, string b) internal pure returns (bool) {

        if(bytes(a).length != bytes(b).length) {

            return false;

        } else {

            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));

        }

    }



    // Function to list the property. Only "Cleared" property can be listed, and only owner and approved third party can list the property

    function listProperty(uint propertyID, uint price, string note) public returns (bool)     {

        Property storage myproperty = id_to_property[propertyID];

        require(msg.sender == myproperty.owner || approved[propertyID] == msg.sender);

        require(hashCompareWithLengthCheck(myproperty.propertyStatus, "Cleared"));

        

        myproperty.propertyStatus = "ForSale";

        myproperty.price = price;

        myproperty.note = note;

        emit UpdatePropertyStatus(propertyID, "ForSale", price);

        return true;

    }

    

    // Change the property's status from "ForSale" to "InProcess". It requires the finalized transaction price, the information of buyers, and bank address if applicable 

    function propertyInProcess(uint propertyID, uint price, string note, bool ifcollateralized, address buyer, address bank) public returns (bool) {

        Property storage myproperty = id_to_property[propertyID];

        require(msg.sender == myproperty.owner || approved[propertyID] == msg.sender);

        require(buyer_kyc[buyer]);

        require(hashCompareWithLengthCheck(myproperty.propertyStatus, "ForSale"));

        

        if (ifcollateralized) {

            require(isbank[bank]);

            myproperty.registeredBank = bank;

        }

        myproperty.propertyStatus = "InProcess";

        myproperty.price = price;

        myproperty.note = note;

        myproperty.ifcollateralized = ifcollateralized;

        myproperty.registeredbuyer = buyer;

        emit UpdatePropertyStatus(propertyID, "InProcess", price);

        return true;

    }

    

    // Approve third party the right to transfer ownership or list property on the owner's behalf

    function approve(address _to, uint256 _tokenId) public returns (bool) {

        Property storage myproperty = id_to_property[_tokenId];

        require(msg.sender == myproperty.owner);

        approved[_tokenId] = _to;

        emit Approval(msg.sender, _to, _tokenId);

        return true;

    }

    

    // Function to proceed the payment from the buyer or the bank to the seller. The fee will deducted automatically after the payment is received

    function sendPayment(uint propertyID, uint amount) public returns (bool){

        // Remember to call approve function in the payment coin contract for this contract

        // otherwise this contract will not be able to proceed transfer on your behalf

        Property storage myproperty = id_to_property[propertyID];

        require(hashCompareWithLengthCheck(myproperty.propertyStatus, "InProcess"));

        

        if (isbank[msg.sender]) {

            require(myproperty.ifcollateralized);

            require(myproperty.registeredBank == msg.sender);

        } else {

            // upload register buyer itself already conducted kyc process

            require(myproperty.registeredbuyer == msg.sender); 

        }

        

        //If the owner has not approved this contract to transfer their token this will failed. If they did, this transfer will be executed 

        require(ERC20Interface(payment_coin).transferFrom(msg.sender, this, amount));

        receivable[propertyID] = receivable[propertyID].add(amount); 

        

        emit ReceivePayment(msg.sender, propertyID, amount);

       

         

        uint half_fee = myproperty.price.div(fee);

        uint buyer_total_payment = myproperty.price.add(half_fee);

       

        if (receivable[propertyID] >= buyer_total_payment) {

            receivable[propertyID] = receivable[propertyID].sub(buyer_total_payment);

            

            ERC20Interface(payment_coin).transfer(administrator, half_fee.mul(2)); //pay double fee

            ERC20Interface(payment_coin).transfer(myproperty.owner, myproperty.price.sub(half_fee)); //pay to the seller

            

            string memory newStatus;

            if (myproperty.ifcollateralized) {

                newStatus = "Collateralized";

            } else {

                newStatus = "Cleared";

            }

            myproperty.propertyStatus = newStatus;

            emit UpdatePropertyStatus(propertyID, newStatus, myproperty.price);

            _changeOwnership(myproperty, myproperty.registeredbuyer);

            myproperty.registeredbuyer = address(0); // clear out the buyer

        }

        

        return true;

    }

    

    // Internal helper for changing ownership

    function _changeOwnership(Property myproperty, address newOwner) internal returns(bool) {

            address oldOwner = myproperty.owner;

            myproperty.owner = newOwner;

            balances[oldOwner] = balances[oldOwner].sub(1);

            balances[newOwner] = balances[newOwner].add(1);

            emit Transfer(oldOwner, newOwner, myproperty.propertyID);

    }

    

    // Transfer ownership to somebody else, however, the status has to be "Cleared". "Collaterized", "InProcess" and "ForSale" properties can not be transfered

    function transfer(address _to, uint256 _tokenId) public returns (bool){ 

        Property storage myproperty = id_to_property[_tokenId];

        require(msg.sender == administrator || msg.sender == myproperty.owner || approved[_tokenId] == msg.sender);

        

        if (msg.sender == myproperty.owner) {

            require(hashCompareWithLengthCheck(myproperty.propertyStatus, "Cleared"));

        }

        

        _changeOwnership(myproperty, _to);

        return true;

    }

    

    // Administrator and the relevant bank can change the property's status to "Cleared"

    function clearProperty(uint propertyID, string note) public returns (bool){ 

        require(msg.sender == administrator || isbank[msg.sender]);

        Property storage myproperty = id_to_property[propertyID];

        require(msg.sender == myproperty.registeredBank);

        myproperty.propertyStatus = "Cleared";

        myproperty.note = note;

        myproperty.registeredBank = address(0); // clear out the bank

        emit UpdatePropertyStatus(propertyID, "Cleared", myproperty.price);

        return true;

    }

     

    // Owner can use this function to update the property's name and description

    function changePropertyAttributes(uint propertyID, string name, string description) public returns (bool) {

        Property storage myproperty = id_to_property[propertyID];

        myproperty.propertyName = name;

        myproperty.propertyDescription = description;

        emit PropertyDescriptionChange(propertyID, name, description);

        return true;

    }

    

    // Administrator can use this function to change the KYC status of the buyer (basically to register or unregister the buyer)

    function changeBuyerKYCStatus(address buyer_address, bool status) public onlyAdministrator returns (bool) {

        buyer_kyc[buyer_address] = status;

        emit KYCStatusChanged(buyer_address, status);

        return true;

    }

    

    // Only administrator can register the bank

    function registerBank(address bank, bool registered) public onlyAdministrator returns (bool) {

        isbank[bank] = registered;

        emit BankRegistrationChanged(bank, registered);

        return true;

    }

}