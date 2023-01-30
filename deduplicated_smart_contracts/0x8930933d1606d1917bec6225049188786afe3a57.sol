/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

//  Created by: Ingenia - URL: https://ingenia.la

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract GoElevateCertificates is Ownable {

	enum Status {Active, Inactive }
	bytes32 constant NULL = "";

	struct Course{
		bytes32 courseId;
		string courseName;
		uint256 startDate;
		uint256 endDate;
		Status status;
	}

	struct Certificate {
		bytes32 certId;
		bytes32 courseId;
		uint256 score;
		uint256 studentId;
		string studentName;
		Status status;
	}

	mapping (bytes32 => Course) courses;
	mapping (bytes32 => Certificate) certificates;

	string public name;     

	event CourseCreated(bytes32 indexed courseId, string courseName, uint256 startDate, uint256 endDate);
	event CourseDisabled(bytes32 indexed courseId);
	event CourseEnabled(bytes32 indexed courseId);
	event CertificateIssued(bytes32 indexed certificateId, bytes32 indexed courseId, string studentName, uint256 score);
	event CertificateDisabled(bytes32 indexed certificateId);
	event CertificateEnabled(bytes32 indexed certificateId);

    constructor(string memory contractName) {
        name = contractName;
    }

	function createCourse( bytes32 courseId, string memory courseName, uint256 startDate, uint256 endDate) public onlyOwner returns (bool) {
		require(courseId.length  > 0 , "Invalid course id");
		require(startDate  > 0, "Invalid start date");
		require(endDate > startDate, "Invalid end date");
		bytes memory courseNameTest = bytes(courseName);
		require(courseNameTest.length > 0, "Course name should be provided");

		require(courses[courseId].courseId == NULL, "Duplicated Key");

		courses[courseId] = Course(courseId,courseName, startDate, endDate, Status.Active);
		emit CourseCreated(courseId,courseName, startDate, endDate);
		return true;
	}

	function issueCertificate( bytes32 certificateId, bytes32 courseId, uint256 score, uint256 studentId, string memory studentName) public onlyOwner returns (bool) {
		require(certificateId.length  > 0  , "Invalid certificate id");
		require(courseId  > 0 && courses[courseId].startDate  > 0 && courses[courseId].status == Status.Active, "Invalid course id");
		bytes memory studentNameTest = bytes(studentName);
		require(studentNameTest.length > 2, "Student name should be provided");
		require(certificates[certificateId].certId == NULL , "Duplicated Key");
		
		certificates[certificateId] = Certificate(certificateId, courseId, score, studentId, studentName, Status.Active);
		emit CertificateIssued(certificateId, courseId, studentName, score);
		return true;
	}

	function changeCertStatus( bytes32 certId, Status status) public onlyOwner returns (bool) {
		require(certificates[certId].status != status , "No change");
		certificates[certId].status = status;
		if(status == Status.Active){
			emit CertificateEnabled(certId);
		} else {
			emit CertificateDisabled(certId);
		}
		return true;
	}

	function changeCourseStatus( bytes32 courseId, Status status) public onlyOwner returns (bool) {
		require(courses[courseId].status != status , "No change");
		courses[courseId].status = status;
			if(status == Status.Active){
			emit CourseEnabled(courseId);
		} else {
			emit CourseDisabled(courseId);
		}
		return true;
	}

	function getCourse(bytes32 courseId) public view returns(
		string memory courseName,
		Status courseStatus,
		uint256 startDate,
		uint256 endDate)
	{
		courseName = courses[courseId].courseName;
		courseStatus = courses[courseId].status;
		startDate = courses[courseId].startDate;
		endDate = courses[courseId].endDate;
	}

	function getCertificateInfo(bytes32 certId) public view  
		returns(
			string memory courseName,
			Status courseStatus,
			uint256 startDate,
			uint256 endDate,
			bytes32 courseId,
			uint256 score,
			uint256 studentId,
			string memory studentName,
			Status certificateStatus) {
		
			courseName = courses[certificates[certId].courseId].courseName;
			courseStatus = courses[certificates[certId].courseId].status;
			startDate = courses[certificates[certId].courseId].startDate;
			endDate = courses[certificates[certId].courseId].endDate;
			courseId = certificates[certId].courseId;
			score = certificates[certId].score;
			studentId = certificates[certId].studentId;
			studentName = certificates[certId].studentName;
			certificateStatus = certificates[certId].status;
		}
}