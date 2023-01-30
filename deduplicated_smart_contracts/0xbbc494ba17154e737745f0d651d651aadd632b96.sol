/**

 *Submitted for verification at Etherscan.io on 2018-12-07

*/



pragma solidity 0.4.25;



contract HighwayAcademyCertificates {

    

    event NewCertificate(uint256 indexed certificate_number, string course_name, string student_name, string linkedin, string released_project, string mentor_name_linkedin, string graduation_date, string graduation_place);

    

    struct Certificate {

        

        string course_name;

        string student_name;

        string student_linkedin;

        string released_project;

        string mentor_name_linkedin;

        string graduation_date;

        string graduation_place;

    }

    

    address public owner;

    uint256 public count = 0;

    mapping(uint256 => Certificate) public certificates;

    

    modifier onlyOwner {

        require(msg.sender == owner, "Only owner can use this function");

        _;

    }

    

    constructor() public {

        owner = msg.sender;

    }

    

    function addCertificate(uint256 certificate_number, string course_name, string student_name, string student_linkedin, string released_project, string mentor_name_linkedin, string graduation_date, string graduation_place) public onlyOwner {

        count++;

        require(count == certificate_number, "Wrong certificate number");

        certificates[count] = Certificate(course_name, student_name, student_linkedin, released_project, mentor_name_linkedin, graduation_date, graduation_place);

        emit NewCertificate(certificate_number, course_name, student_name, student_linkedin, released_project, mentor_name_linkedin, graduation_date, graduation_place);

    }

}