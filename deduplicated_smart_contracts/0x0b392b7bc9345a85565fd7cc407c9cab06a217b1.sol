/**

 *Submitted for verification at Etherscan.io on 2018-10-19

*/



pragma solidity ^0.4.24;



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

// �˱���¼��Լ

// ----------------------------------------------------------------------------

contract IMCLedgerRecord is Owned{



    // �˱���¼�����־

    event LedgerRecordAdd(uint _date, bytes32 _hash, uint _depth, string _fileFormat, uint _stripLen, bytes32 _balanceHash, uint _balanceDepth);



    // Token����ͳ�Ƽ�¼

    struct RecordInfo {

        uint date;  // ��¼���ڣ�����ID��

        bytes32 hash;  // �ļ�hash

        uint depth; // ���

        string fileFormat; // ������֤���ļ���ʽ

        uint stripLen; // ������֤���ļ�����

        bytes32 balanceHash;  // ����ļ�hash

        uint balanceDepth;  // ������

    }



    // ִ���ߵ�ַ

    address public executorAddress;

    

    // �˱���¼

    mapping(uint => RecordInfo) public ledgerRecord;

    

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

     * �˱���¼���

     * @param _date uint ��¼���ڣ�����ID��

     * @param _hash bytes32 �ļ�hash

     * @param _depth uint ���

     * @param _fileFormat string ������֤���ļ���ʽ

     * @param _stripLen uint ������֤���ļ�����

     * @param _balanceHash bytes32 ����ļ�hash

     * @param _balanceDepth uint ������

     * @return success ��ӳɹ�

     */

    function ledgerRecordAdd(uint _date, bytes32 _hash, uint _depth, string _fileFormat, uint _stripLen, bytes32 _balanceHash, uint _balanceDepth) public returns (bool) {

        // ���������Owner���õ�ִ���ߵ�ַһ��

        require(msg.sender == executorAddress);

        // ��ֹ�ظ���¼

        require(ledgerRecord[_date].date != _date);



        // ��¼������Ϣ

        ledgerRecord[_date] = RecordInfo(_date, _hash, _depth, _fileFormat, _stripLen, _balanceHash, _balanceDepth);



        // ������־��¼

        emit LedgerRecordAdd(_date, _hash, _depth, _fileFormat, _stripLen, _balanceHash, _balanceDepth);

        

        return true;

        

    }



}