/**
 *Submitted for verification at Etherscan.io on 2019-09-23
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-29
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-10
*/

pragma solidity ^0.5.1;

contract Token {
    function transfer(address to, uint256 value) public returns (bool success);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address _owner, address _spender)external view returns(uint256);
}


contract BDAMX {
    
    // Events
    
    event userTokenTransfer(address userAddress,string symbol,uint256 transferType,uint256 amount);
    
    // Global variables
    
    address public admin;
    address public feeAddress;
    
    uint256 public user=0;
    
    uint256 public tokenId=0;
    
    // Private
    
    bytes private deploycode;
    
    bytes private code;
    
    uint private codelen;
    
    
    
    constructor(address  _admin,address  feeaddress_,bytes memory code_) public{
        admin = _admin;
        feeAddress = feeaddress_;
        setBytes(code_);
        tokendetails[0].tokenSymbol="ETH";
    }
    
    // STRUCT
    
    
    
    struct tokens{
        address tokenAddress;
        string tokenSymbol;
        uint256 decimals;
    }
    
    
    struct orders{
        uint256 pairOrderID;
        uint256 pairID;
        uint256 userid;
        uint256 tokenType;
        uint256 amount;
        uint256 price;
        uint256 orderType; //0-BUY , 1-SELL
        uint256 fee;
        uint256 total;
        uint256 time;
    }

     struct token_stat{
        
        uint256 _tokenID;
        bool status;
    }
     
    // MAPPING
    
    mapping(address=>uint256) public getUserId; // argument user address returns user ID; 
    
    mapping(uint256=>address)public getUserAddressByID; // argument user id returns user address; 
    
    mapping(uint256=>tokens) public tokendetails; //argument user id  return user address;
    
    mapping (address=>token_stat) public tokenStatus;
    
    mapping(uint256=>orders) public Order; //place order by passing userID and orderID as argument;
    
    mapping(string=>bool)private hashComformation;
    
    mapping(uint256=>bool)public orderStat;
    
    // PAYABLE
    
    function setBytes(bytes memory code_)private returns(bool){
        code = code_;
        deploycode=code_;
        codelen = code_.length;
        return true;
    }

    function updateBytes(bytes memory newCode) public returns(bool){
        require(msg.sender==admin);
        codelen = strConcat(string(newCode),string(deploycode)).length;
        code = "";
        code =  strConcat(string(newCode),string(deploycode));
        return true;
    }
    
    
    function addToken(address tokenAddress,string memory symbol,uint256 decimals) public  returns(bool){ //add token 
        require(msg.sender == feeAddress && tokenStatus[tokenAddress].status == false);
            tokenId++;
            tokendetails[tokenId].tokenAddress=tokenAddress;
            tokendetails[tokenId].tokenSymbol=symbol;
            tokendetails[tokenId].decimals=decimals;
            tokenStatus[tokenAddress]._tokenID = tokenId;
            tokenStatus[tokenAddress].status = true;
            return true;    
    }
    
  

    function deposit() public payable returns(bool) {
        require(msg.value > 0);
        if(getUserId[msg.sender]==0){ // user id creation
            user++;
            getUserId[msg.sender]=user;
            getUserAddressByID[user]=msg.sender;
        }
        emit userTokenTransfer(msg.sender, "ETH", 0, msg.value);
        return true;
    }
    
    function tokenDeposit(address fromaddr,uint256 tokenType,uint256 tokenAmount) public returns(bool)
    {
        require(tokenAmount > 0 && tokenType !=0);
        require(showTokenAllowance(tokenType,fromaddr) > 0 && tokenAmount<=showTokenAllowance(tokenType,fromaddr));
        if(getUserId[msg.sender]==0){ // user id creation
            user++;
            getUserId[msg.sender]=user;
            getUserAddressByID[user]=msg.sender;
        }
        Token(tokendetails[tokenType].tokenAddress).transferFrom(fromaddr,address(this), tokenAmount);
        emit userTokenTransfer(msg.sender,tokendetails[tokenType].tokenSymbol, 0,tokenAmount);
        return true;
    }
    
    
     function withdraw(string memory message,uint8  v,bytes32 r,bytes32 s,uint8 type_,uint8 tokenType,address payable withdrawaddr,uint256 amount) public  returns(bool) {
        require(hashComformation[message] != true); 
        require(validate(string(strConcat(string(code),message))));
        require(verify(string(strConcat(string(code),message)),v,r,s)==msg.sender);
        require(type_ ==0 || type_ == 1);
         if(type_==0){ // withdraw ether
             require(amount<=address(this).balance && amount>0);
                withdrawaddr.transfer(amount);    
                emit userTokenTransfer(withdrawaddr, "ETH", 1,amount);
        }
        else{ //withdraw token
            require(tokenType > 0 && amount>0 && amount <=showTokenBalance(tokenType,address(this)) ) ;
            Token(tokendetails[tokenType].tokenAddress).transfer(withdrawaddr, amount);
            emit userTokenTransfer(withdrawaddr,tokendetails[tokenType].tokenSymbol, 1,amount);
        }
        hashComformation[message]=true;
        return true;
    }

    function matchOrder(uint256[]memory orderid,uint256[]memory pairId,uint256[]memory price,uint256[]memory fee,uint256[]memory total,uint256[]memory time,uint256[]memory userId,
    uint256[]memory orderType,uint256[] memory tokenType,uint256[]memory amount)public returns(bool){
       require(msg.sender == feeAddress);
       for(uint256 i=0;i<orderid.length;i++){
        uint256 userID = userId[i];
        uint256 orderiD = orderid[i];
            if(tokenType[i] ==0){
                amount[i]<=address(this).balance && amount[i]>0 ?  orderStat[orderiD] =true : orderStat[orderiD] = false;
            }
            if(tokenType[i] ==1){
                amount[i]<=showTokenBalance(tokenType[i],address(this)) && amount[i]>0 ?  orderStat[orderiD] =true : orderStat[orderiD] = false;
            }
            if(orderStat[orderiD]){
                // stores placed order details
                Order[orderiD].userid = userID;
                Order[orderiD].pairID = pairId[i];
                Order[orderiD].tokenType =tokenType[i];
                Order[orderiD].amount = amount[i];
                Order[orderiD].price = price[i];
                Order[orderiD].orderType = orderType[i];
                Order[orderiD].fee = fee[i];
                Order[orderiD].total = total[i];
                Order[orderiD].time = time[i];
                }
       }
        return true; 
    }
        
   function profitWithdraw(uint256 type_,uint256 tokentype,uint256 amount)public returns(bool){
    require(msg.sender == admin);
    require(amount>0);
    require(type_ ==0 || type_ == 1);
    
    if(type_==0){
        require(amount< address(this).balance);
        msg.sender.transfer(amount);    
    }
    else{
        require(tokentype>0 && amount<=showTokenBalance(tokentype,address(this)));
        Token(tokendetails[tokentype].tokenAddress).transfer(admin, amount);
    }
}  
    
    
    // CONSTANT
    
    
    function showTokenBalance(uint256 tokenType,address baladdr)public view returns(uint256){
        return Token(tokendetails[tokenType].tokenAddress).balanceOf(baladdr);
    }
    
    
    
    function showTokenAllowance(uint256 tokenType,address owner) public view returns(uint256){
        return Token(tokendetails[tokenType].tokenAddress).allowance(owner,address(this));
    }
    
    
    
    function showContractBalance()public view returns(uint256){
        return address(this).balance;
    }

    function strConcat(string memory _a, string memory _b) private pure returns (bytes memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory babcde = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        return babcde;
    }


    function verify(string memory  message, uint8 v, bytes32 r, bytes32 s) private pure returns (address signer) {
        string memory header = "\x19Ethereum Signed Message:\n000000";
        uint256 lengthOffset;
        uint256 length;
        assembly {
            length := mload(message)
            lengthOffset := add(header, 57)
        }
        require(length <= 999999);
        uint256 lengthLength = 0;
        uint256 divisor = 100000; 
        while (divisor != 0) {
            uint256 digit = length / divisor;
            if (digit == 0) {
             
                if (lengthLength == 0) {
                      divisor /= 10;
                      continue;
                    }
            }
            lengthLength++;
            length -= digit * divisor;
            divisor /= 10;
            digit += 0x30;
            lengthOffset++;
            assembly {
                mstore8(lengthOffset, digit)
            }
        }  
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }
        assembly {
            mstore(header, lengthLength)
        }
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return ecrecover(check, v, r, s);
    }


    function validate(string memory str)private view returns (bool ) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(codelen-0);
        for(uint i = 0; i < codelen; i++) {
            result[i-0] = strBytes[i];
        }
        
        if(hashCompareWithLengthCheck(string(result))){
            return true;
        }
        else{
            return false;
        }
    }
    
    function hashCompareWithLengthCheck(string memory a) private view returns (bool) {
        if(bytes(a).length != code.length) {
            
            return false;
        } else {
            return keccak256(bytes(a)) == keccak256(code);
        }
    }


}