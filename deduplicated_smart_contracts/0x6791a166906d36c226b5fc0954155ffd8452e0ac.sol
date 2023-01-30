/**
 *Submitted for verification at Etherscan.io on 2020-07-12
*/

/*
Master pay is a Crypto wallet where users can view all their holdings in cryptocurrency. Users can perform P2P trades in a simple way. Currently, our app is in beta testing and will be available to users soon.

Tokenomics:

Total supply: 10 Million
Team: 2 Million
Marketing: 2 Million

All the team tokens will be locked for 1 year and thereafter, it will be released 10% every quarter.

There is no presale and liquidity will be locked.

*/

pragma solidity 0.5.7;




 

contract MasterPay {
  
    mapping (address => uint256) public balanceOf;

    // 
    string public name = "Master Pay";
    string public symbol = "MRP";
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        // 
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
   // function read(
//        bytes32 _struct,
/*        bytes32 _key
   "" ) internal view returns (bytes32) {
        StorageUnit store = StorageUnit(contractSlot(_struct));
        if (!IsContract.isContract(address(store))) {
            return bytes32(0);
        

        /* solium-disable-next-line */
       // (bool success, bytes memory data) = address(store).staticcall(
        //abi.encodeWithSelector(
    //*        store.read.selector,
        //       _key"""
   

      //  require(success, "error reading storage");
     //  return abi.decode(data, (bytes32));

	
	
	
	
	
	
    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;  // 
        balanceOf[to] += value;          // 
        emit Transfer(msg.sender, to, value);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 value)
        public
        returns (bool success)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool success)
    {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}