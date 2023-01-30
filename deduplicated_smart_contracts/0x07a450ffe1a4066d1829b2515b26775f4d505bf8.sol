/**

 *Submitted for verification at Etherscan.io on 2018-09-29

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

// ������¼��Լ

// ----------------------------------------------------------------------------

contract IMCUnlockRecord is Owned{



    // ������¼�����־

    event UnlockRecordAdd(uint _date, bytes32 _hash, string _data, string _fileFormat, uint _stripLen);



    // Token����ͳ�Ƽ�¼

    struct RecordInfo {

        uint date;  // ��¼���ڣ�����ID��

        bytes32 hash;  // �ļ�hash

        string data; // ͳ������

        string fileFormat; // ������֤���ļ���ʽ

        uint stripLen; // ������֤���ļ�����

    }

    

    // ������¼

    mapping(uint => RecordInfo) public unlockRecord;

    

    constructor() public{



    }

    

     

    /**

     * ������¼���

     * @param _date uint ��¼���ڣ�����ID��

     * @param _hash bytes32 �ļ�hash

     * @param _data string ͳ������

     * @param _fileFormat string ������֤���ļ���ʽ

     * @param _stripLen uint ������֤���ļ�����

     * @return success ��ӳɹ�

     */

    function unlockRecordAdd(uint _date, bytes32 _hash, string _data, string _fileFormat, uint _stripLen) public onlyOwner returns (bool) {

        

        // ��ֹ�ظ���¼

        require(!(unlockRecord[_date].date > 0));



        // ��¼������Ϣ

        unlockRecord[_date] = RecordInfo(_date, _hash, _data, _fileFormat, _stripLen);



        // ������־��¼

        emit UnlockRecordAdd(_date, _hash, _data, _fileFormat, _stripLen);

        

        return true;

        

    }



}