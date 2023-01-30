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

    //��ȡ����
    function getlength() public view returns (uint len){
        return addarray.length;
    }

    //��ȡ����eth��ַ
    function getethAddress(uint les) public view returns (address ethAddr){
        return addarray[les];
    }

    //������ַ�Ƿ����
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

    //��ѯ��Լ�Ƿ񶳽�
    function isfreeze() public view returns (bool bFreeze) {
	return isFrozen;
    }

   //��ѯӳ���¼
    function getUserInfo(address ethAddr) public view returns(string) {
        return (wdc_mapping[ethAddr].newAddr);
    }

    //��ѯ�Ƿ���ӳ���¼
    function ethisflag(address ethAddr) public view returns (bool bUpdate){
        return wdc_mapping[ethAddr].bUpdate;
    }


 //��ѯ����
    function selectOne(address ethAddr) public view returns (string){
        return (wdc_mapping[ethAddr].newAddr);
    }
}
