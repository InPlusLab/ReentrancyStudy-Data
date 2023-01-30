/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

pragma solidity 0.5.11;

library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address payable public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract ERC20BasicInterface {
    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals;
}

contract WisePass is Ownable {

    using SafeMath for uint256;
    
    address[] arrToken;
    
    uint256 public Percen = 1000;
    // Fee percent commission take
    uint public commissionRatio = 100;
    address public ethAddress = address(0x0000000000000000000000000000000000000000);
    address payable public commissionAddress = address(0x326C12A55df2c4b1C2783D29F3B4f6Ab74c3A1be);
    address payable public ceoAddress = address(0xD4a520a0448FC3FF493f115c6a369bACb46bE959);

    struct Transaction {
        address payable PayAddress;
        address tokenAddress;
        uint256 amount;
        uint timeTrackBuy;
        uint256 Percent_Comission;
    }

    struct Buyer {
        string Email;
        Transaction[] TxList;
    }
    
    mapping(string => Buyer) Buyers;

    constructor() public {
         arrToken = [
          0x039B5649A59967e3e936D7471f9c3700100Ee1ab,
          0xb3104b4B9Da82025E8b9F8Fb28b3553ce2f67069,
          0xA849EaaE994fb86Afa73382e9Bd88c2B6b18Dc71,
          0x77761e63C05aeE6648FDaeaa9B94248351AF9bCd
         ];
    }
    
    modifier onlyCeoAddress() {
        require(msg.sender == ceoAddress);
        _;
    }
    
    function listToken() public view returns(address[] memory _arrToken){
        address[]memory tokenList = arrToken;
        return tokenList;
    }
    
    function getTxsInfo(string memory email,uint idxTxs) public view returns(address payAddress,
        address tokenAddress,
        uint256 amount,
        uint timeTrackBuy,uint256 Percent_Commission){
        Transaction memory _transaction = Buyers[email].TxList[idxTxs];
            
        return (_transaction.PayAddress,_transaction.tokenAddress,_transaction.amount,_transaction.timeTrackBuy,_transaction.Percent_Comission);
    }
    
    function getCountTxs(string memory email) public view returns(uint countTxs){
        return Buyers[email].TxList.length;
    }
    
    function getLatest(string memory email) public view returns(address payAddress,
        address tokenAddress,
        uint256 amount,
        uint timeTrackBuy,uint256 Percent_Commission){
        Transaction memory _transaction = Buyers[email].TxList[Buyers[email].TxList.length-1];
            
        return (_transaction.PayAddress,_transaction.tokenAddress,_transaction.amount,_transaction.timeTrackBuy,_transaction.Percent_Comission);
    }

    function addToken(address tokenAddress) public{
        bool flag = false;
        for(uint i = 0; i< arrToken.length; i++) {
            if(arrToken[i] == tokenAddress) flag = true;
        }
        if(!flag) arrToken.push(tokenAddress);
    }
    
    function removeToken(address tokenAddress) public {
        for(uint i = 0; i< arrToken.length; i++) {
            if(arrToken[i] == tokenAddress){
                delete arrToken[i];
                arrToken.length--;
            }
        }
    }

    function buy(string memory email) payable public {
        require(msg.value>0);
        
        // Send comission
        uint256 comissionBalance = msg.value.mul(commissionRatio).div(Percen);
        address payable _comissionAddress= commissionAddress;
        
        _comissionAddress.transfer(comissionBalance);
        
        Transaction memory txsData =Transaction(msg.sender,ethAddress,msg.value,block.timestamp,comissionBalance);
        Buyers[email].TxList.push(txsData);
    }
    
   function buyByToken(string memory email,address tokenAddress,uint256 price) public {
        require(isValidToken(tokenAddress));
        ERC20BasicInterface tokenPay = ERC20BasicInterface(tokenAddress);
        require(tokenPay.transferFrom(msg.sender, address(this), price));
        
        // Send comission
        uint256 comissionBalance = price.mul(commissionRatio).div(Percen);
        tokenPay.transfer(commissionAddress, comissionBalance);
        
        Transaction memory txsData =Transaction(msg.sender,tokenAddress,price,block.timestamp,comissionBalance);
        Buyers[email].TxList.push(txsData);
    }
    
    function isValidToken(address tokenAddress) public view returns (bool){
        bool flag = false;
        for(uint i = 0; i< arrToken.length; i++) {
            if(arrToken[i] == tokenAddress) flag = true;
        }
        return flag;
    }
    
    function changeComissionAddress(address payable _address) public onlyCeoAddress {
        require(_address != address(0));
        commissionAddress = _address;
    }
    
    function withdrawETH() public onlyCeoAddress{
        owner.transfer(address(this).balance);
    }
    
    function changeComissionRatio(uint _comissionRatio) onlyOwner public{
        commissionRatio = _comissionRatio;
    }

    function withdraw(ERC20BasicInterface[] memory tokens, uint256[] memory amounts) public onlyCeoAddress{
        for(uint i = 0; i< tokens.length; i++) {
            tokens[i].transfer(owner, amounts[i]);
        }
    }

    function changeCeo(address payable _address) public onlyCeoAddress {
        require(_address != address(0));
        ceoAddress = _address;
    }
    
	// can accept ether
	function() external payable {
    }

}