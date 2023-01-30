/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity 0.4.24;



contract CellPhones {



    uint public customEventSeq;

    uint public masterEventSeq;



    mapping( address => CellInfo ) public cellInfoes;



    struct CellInfo {

        string myPhoneName;

        string manufacturerName;

        string serialNumber;

        string colorName;

        string description;

        address owner;

        uint grade;

        mapping( uint => CustomEvents ) customEvents;

        uint[] customEventsIdx;

        mapping( uint => MasterEvents ) masterEvents;

        uint[] masterEventsIdx;

    }



    struct CustomEvents {

        address owner;

        string timeYYMMDD;

        string eventCode;

        string eventName;

        string eventDescription;

    }



    struct MasterEvents {

        address owner;

        string timeYYMMDD;

        string eventCode;

        string eventName;

        string eventDescription;

    }



    function getMyCellInfoes() view public returns(string, string, string, string, string){

        return (cellInfoes[msg.sender].myPhoneName,cellInfoes[msg.sender].manufacturerName,cellInfoes[msg.sender].serialNumber,cellInfoes[msg.sender].colorName,cellInfoes[msg.sender].description );

    }



    function getCustomEvent(uint _idx) view public returns(string, string, string, string){

        return (cellInfoes[msg.sender].customEvents[_idx].timeYYMMDD,cellInfoes[msg.sender].customEvents[_idx].eventCode,cellInfoes[msg.sender].customEvents[_idx].eventName, cellInfoes[msg.sender].customEvents[_idx].eventDescription );

    }



    function getMasterEvent(uint _idx) view public returns(string, string, string, string){

        return (cellInfoes[msg.sender].masterEvents[_idx].timeYYMMDD,cellInfoes[msg.sender].masterEvents[_idx].eventCode,cellInfoes[msg.sender].masterEvents[_idx].eventName, cellInfoes[msg.sender].masterEvents[_idx].eventDescription );

    }



    function createCellInfoes( string _myPhoneName, string _manufacturerName, string _serialNumber, string _colorName, string _description ) payable public  {



        require( msg.sender != address(0), "you have no ownership");

        require( msg.value >= 0.0001 ether , "there is no enough ether.");

        require( bytes(_myPhoneName).length != 0, "there is no _myPhoneName data");

        require( bytes(_manufacturerName).length != 0, "there is no _manufacturerName data");

        require( bytes(_serialNumber).length != 0, "there is no _serialNumber data");

        require( bytes(_colorName).length != 0, "there is no _colorName data");





        CellInfo memory cellInfo;

        cellInfo.myPhoneName = _myPhoneName;

        cellInfo.manufacturerName =_manufacturerName;

        cellInfo.serialNumber = _serialNumber;

        cellInfo.colorName = _colorName;

        cellInfo.description = _description;

        cellInfo.owner = msg.sender;

        cellInfo.grade = 0;



        cellInfoes[msg.sender] = cellInfo;



        address(msg.sender).transfer(msg.value - 0.0001 ether);



    }



    function getCustomEventArrays() view public returns(uint[]) {

        return cellInfoes[msg.sender].customEventsIdx;

    }



    function getMasterEventArrays() view public returns(uint[]) {

        return cellInfoes[msg.sender].masterEventsIdx;

    }



    function createCustomEvent(string _date, string _code, string _eventName, string _description) payable public {

        require( bytes(cellInfoes[msg.sender].myPhoneName).length != 0 );

        require( msg.value >= 0.0001 ether);

        require( bytes(_date).length != 0, "there date data");

        require( bytes(_code).length != 0, "there _code data");

        require( bytes(_eventName).length != 0, "there _eventName data");

        require( bytes(_description).length != 0, "there _description data");

        customEventSeq++;



        CustomEvents memory newCustomEvents;

        newCustomEvents.owner = msg.sender;

        newCustomEvents.timeYYMMDD = _date;

        newCustomEvents.eventCode = _code;

        newCustomEvents.eventName = _eventName;

        newCustomEvents.eventDescription = _description;



        cellInfoes[msg.sender].customEventsIdx.push(customEventSeq);

        cellInfoes[msg.sender].customEvents[customEventSeq] = newCustomEvents;



        address(msg.sender).transfer(msg.value - 0.0001 ether);



    }



    function createMasterEvent(string _date, string _code, string _eventName, string _description) public  {



        //require( msg.value >= 0.0001 ether);

        masterEventSeq++;



        MasterEvents memory newMasterEvents;

        newMasterEvents.owner = msg.sender;

        newMasterEvents.timeYYMMDD = _date;

        newMasterEvents.eventCode = _code;

        newMasterEvents.eventName = _eventName;

        newMasterEvents.eventDescription = _description;



        cellInfoes[msg.sender].masterEventsIdx.push(masterEventSeq);

        cellInfoes[msg.sender].masterEvents[masterEventSeq] = newMasterEvents;



        //address(msg.sender).transfer(msg.value - 0.0001 ether);





    }



    function updateGrade (uint _grade) public returns(uint) {



        //require( msg.value >= 0.0001 ether);



        cellInfoes[msg.sender].grade += _grade;



        //address(msg.sender).transfer(msg.value - 0.0001 ether);



        return cellInfoes[msg.sender].grade;

    }



}