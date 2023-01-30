pragma solidity ^0.4.24;
 
contract owned {
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "");
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract WisdomMapping is owned {
    struct User {
        string newAddr;
        bool bUpdate;
    }

    struct isExist{
    	bool exist;
    }

    mapping (address => User) private wdc_mapping;
    mapping (string => isExist) private main_address;
    bool isFrozen;
    address[] addarray; 
    uint[] lengths;



    constructor() public {
        isFrozen = false;
    }

    //获取长度
    function getlength() public view returns (uint len){
        return addarray.length;
    }

    //获取所有eth地址
    function getethAddress(uint les) public view returns (address ethAddr){
        return addarray[les];
    }

    //主网地址是否添加
    function mainisExist(string newAddr) public view returns (bool exist){
        return main_address[newAddr].exist;
    }

    function register(string newAddr) public  {
	require(isFrozen == false);
	require(wdc_mapping[msg.sender].bUpdate == false);
	require(main_address[newAddr].exist == false);
	wdc_mapping[msg.sender].newAddr = newAddr;
	wdc_mapping[msg.sender].bUpdate = true;
	addarray.push(msg.sender);
	main_address[newAddr].exist = true;
    }


    function freeze(bool bFreeze) public onlyOwner {
        isFrozen = bFreeze;
    }

    //查询合约是否冻结
    function isfreeze() public view returns (bool bFreeze) {
	return isFrozen;
    }

   //查询映射记录
    function getUserInfo(address ethAddr) public view returns(string) {
        return (wdc_mapping[ethAddr].newAddr);
    }

    //查询是否有映射记录
    function ethisflag(address ethAddr) public view returns (bool bUpdate){
        return wdc_mapping[ethAddr].bUpdate;
    }


 //查询数据
    function selectOne(address ethAddr) public view returns (string){
        return (wdc_mapping[ethAddr].newAddr);
    }
}
