/**

 *Submitted for verification at Etherscan.io on 2019-01-17

*/



pragma solidity ^0.5.2;



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}



// ----------------------------------------------------------------------------

// ���ؼ�¼��Լ

// ----------------------------------------------------------------------------

contract IMCPool is Owned{



    // ���ؼ�¼�����־

    event PoolRecordAdd(bytes32 _chainId, bytes32 _hash, uint _depth, string _data, string _fileFormat, uint _stripLen);



    // Token����ͳ�Ƽ�¼

    struct RecordInfo {

        bytes32 chainId; // ����ID

        bytes32 hash; // hashֵ

        uint depth; // �㼶

        string data; // ��������

        string fileFormat; // ������֤���ļ���ʽ

        uint stripLen; // ������֤���ļ�����

    }



    // ִ���ߵ�ַ

    address public executorAddress;

    

    // ���˼�¼

    mapping(bytes32 => RecordInfo) public poolRecord;

    

    constructor() public{

        // ��ʼ����Լִ����

        executorAddress = msg.sender;

    }

    

    /**

     * �޸�executorAddress��ֻ��owner�ܹ��޸�

     * @param _addr address ��ַ

     */

    function modifyExecutorAddr(address _addr) public onlyOwner {

        executorAddress = _addr;

    }

    

     

    /**

     * ���ؼ�¼���

     * @param _chainId bytes32 ����ID

     * @param _hash bytes32 hashֵ

     * @param _depth uint �����׶�:1 ����������2�������

     * @param _data string ��������

     * @param _fileFormat string ������֤���ļ���ʽ

     * @param _stripLen uint ������֤���ļ�����

     * @return success ��ӳɹ�

     */

    function poolRecordAdd(bytes32 _chainId, bytes32 _hash, uint _depth, string memory _data, string memory _fileFormat, uint _stripLen) public returns (bool) {

        // ���������Owner���õ�ִ���ߵ�ַһ��

        require(msg.sender == executorAddress);

        // ��ֹ�ظ���¼

        require(poolRecord[_chainId].chainId != _chainId);



        // ��¼������Ϣ

        poolRecord[_chainId] = RecordInfo(_chainId, _hash, _depth, _data, _fileFormat, _stripLen);



        // ������־��¼

        emit PoolRecordAdd(_chainId, _hash, _depth, _data, _fileFormat, _stripLen);

        

        return true;

        

    }



}