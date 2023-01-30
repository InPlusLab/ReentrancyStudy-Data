pragma solidity ^0.4.26;

import "./ESOPTypes.sol";
import "./EmployeesList.sol";
import "./OptionsCalculator.sol";
import './BaseOptionsConverter.sol';

contract ESOP is ESOPTypes, TimeSource
{
	event LogESOPOffered(address indexed employee, address company, uint32 poolOptions, uint32 extraOptions);
	event LogEmployeeSignedToESOP(address indexed employee);
	event LogSuspendEmployee(address indexed employee, uint32 suspendedAt);
	event LogContinueSuspendedEmployee(address indexed employee, uint32 continuedAt, uint32 suspendedPeriod);
	event LogTerminateEmployee(address indexed employee, address company, uint32 terminatedAt, TerminationType termType);
	event LogEmployeeOptionsExercised(address indexed employee, address exercisedFor, uint32 poolOptions, bool disableAcceleratedVesting);
	event LogEmployeeMigrated(address indexed employee, address migration, uint pool, uint extra);

	event LogESOPOpened(address company);
	event LogOptionsConversionOffered(address company, address converter, uint32 convertedAt, uint32 exercisePeriodDeadline);

	enum ESOPState { New, Open, Conversion }
	enum TerminationType { Regular, BadLeaver }

	// COMPANY DATA

	string public companyName;
	string public companyStreet;
	string public companyCity;
	string public companyZip;
	string public companyCountry;
	string public companyRegisterNumber;
	bool public companyDetailsSet;

	// LEGAL DATA
	string public courtCity;
	string public courtCountry;
	bool public legalDetailsSet;

	// CODE REPO
	string public repoURL;
	string public commitId;
	bool public codeDetailsSet;

	//CONFIG
	OptionsCalculator public optionsCalculator;
	uint public totalPoolOptions;	// total poolOptions in The Pool
	bytes public ESOPLegalWrapperIPFSHash;	// ipfs hash of document establishing this ESOP
	address public companyAddress;	// company address
	address public rootOfTrust;	// root of immutable root of trust pointing to given ESOP implementation
	uint32 constant public MINIMUM_MANUAL_SIGN_PERIOD = 2 weeks;	// default period for employee signature

	// STATE
	uint public remainingPoolOptions;	// poolOptions that remain to be assigned
	ESOPState public esopState;	// state of ESOP
	uint32 public esopIssueDate; // timestamp of issue of ESOP
	EmployeesList public employees;	// list of employees
	uint public totalExtraOptions;	// how many extra options inserted
	uint32 public conversionOfferedAt;	// when conversion event happened
	uint32 public exerciseOptionsDeadline;	// employee conversion deadline
	BaseOptionsConverter public optionsConverter;	// option conversion proxy

	modifier hasEmployee(address e)
	{
		require(employees.hasEmployee(e));
		_;
	}

	modifier onlyESOPNew()
	{
		require(esopState == ESOPState.New);
		_;
	}

	modifier onlyESOPOpen()
	{
		require(esopState == ESOPState.Open);
		_;
	}

	modifier onlyESOPConversion()
	{
		require(esopState == ESOPState.Conversion);
		_;
	}

	modifier onlyCompany()
	{
		require(companyAddress == msg.sender);
		_;
	}

	function distributeAndReturnToPool(uint distributedOptions, uint idx) internal returns (uint)
	{
		// enumerate all employees that were offered poolOptions after than fromIdx -1 employee
		Employee memory emp;
		for (uint i = idx; i < employees.size(); i++)
		{
			address ea = employees.addresses(i);
			if (ea != 0)  // address(0) is deleted employee
			{
				emp = _loademp(ea);
				// skip employees with no poolOptions and terminated employees
				if (emp.poolOptions > 0 && ( emp.state == EmployeeState.WaitingForSignature || emp.state == EmployeeState.Employed) )
				{
					uint newoptions = optionsCalculator.calcNewEmployeePoolOptions(distributedOptions);
					emp.poolOptions += uint32(newoptions);
					distributedOptions -= uint32(newoptions);
					_saveemp(ea, emp);
				}
			}
		}
		return distributedOptions;
	}

	function removeEmployeesWithExpiredSignaturesAndReturnFadeout() onlyESOPOpen public
	{
		Employee memory emp;
		uint32 ct = currentTime();
		for (uint i = 0; i < employees.size(); i++)
		{
			address ea = employees.addresses(i);
			if (ea != 0) // address(0) is deleted employee
			{
				uint[9] memory ser = employees.getSerializedEmployee(ea);
				emp = deserializeEmployee(ser);
				// remove employees with expired signatures
				if (emp.state == EmployeeState.WaitingForSignature && ct > emp.timeToSign)
				{
					remainingPoolOptions += distributeAndReturnToPool(emp.poolOptions, i+1);
					totalExtraOptions -= emp.extraOptions;
					employees.removeEmployee(ea);
				}
				// return fadeout to pool
				if (emp.state == EmployeeState.Terminated && ct > emp.fadeoutStarts)
				{
					uint returnedPoolOptions;
					uint returnedExtraOptions;
					(returnedPoolOptions, returnedExtraOptions) = optionsCalculator.calculateFadeoutToPool(ct, ser);
					if (returnedPoolOptions > 0 || returnedExtraOptions > 0)
					{
						employees.setFadeoutStarts(ea, ct);
						remainingPoolOptions += returnedPoolOptions;
						totalExtraOptions -= returnedExtraOptions;
					}
				}
			}
		}
	}

	function setCompanyDetails(string pcompanyName, string pcompanyStreet, string pcompanyCity, string pcompanyZip,
						string pcompanyCountry, string pcompanyRegisterNumber)  external onlyCompany onlyESOPNew returns (bool)
	{
		companyName = pcompanyName;
		companyStreet = pcompanyStreet;
		companyCity = pcompanyCity;
		companyZip = pcompanyZip;
		companyCountry = pcompanyCountry;
		companyRegisterNumber = pcompanyRegisterNumber;

		companyDetailsSet = true;
	}

	function setLegalDetails(string pcourtCity, string pcourtCountry) external onlyCompany onlyESOPNew returns (bool)
	{
		courtCity = pcourtCity;
		courtCountry = pcourtCountry;

		legalDetailsSet = true;
	}

	function setCodeDetails(string prepoURL, string pcommitId) external onlyCompany onlyESOPNew returns (bool)
	{
		repoURL = prepoURL;
		commitId = pcommitId;

		codeDetailsSet = true;
	}

	function openESOP(uint32 pTotalPoolOptions, bytes pESOPLegalWrapperIPFSHash) external onlyCompany onlyESOPNew returns (bool)
	{
		require(companyDetailsSet);
		require(legalDetailsSet);
		require(codeDetailsSet);

		esopState = ESOPState.Open;
		esopIssueDate = currentTime();
		emit LogESOPOpened(companyAddress);

		totalPoolOptions = pTotalPoolOptions;
		remainingPoolOptions = totalPoolOptions;
		ESOPLegalWrapperIPFSHash = pESOPLegalWrapperIPFSHash;

		return true;
	}

	function offerOptionsToEmployee(address e, uint32 issueDate, uint32 timeToSign, uint32 extraOptions, bool noPool) external onlyESOPOpen onlyCompany returns (bool)
	{
		require(!employees.hasEmployee(e));
		require(timeToSign >= currentTime() + MINIMUM_MANUAL_SIGN_PERIOD);

		uint poolOptions;
		if(noPool)
			poolOptions = 0;
		else
			poolOptions = optionsCalculator.calcNewEmployeePoolOptions(remainingPoolOptions);

		require (poolOptions <= 0xFFFFFFFF);

		Employee memory emp = Employee({
									issueDate: issueDate,
									timeToSign: timeToSign,
									terminatedAt: 0,
									fadeoutStarts: 0,
									poolOptions: uint32(poolOptions),
									extraOptions: extraOptions,
									suspendedAt: 0,
									state: EmployeeState.WaitingForSignature,
									idx: 0
								});
		_saveemp(e, emp);
		remainingPoolOptions -= poolOptions;
		totalExtraOptions += extraOptions;

		emit LogESOPOffered(e, companyAddress, uint32(poolOptions), extraOptions);
		return true;
	}

	function increaseEmployeeExtraOptions(address e, uint32 extraOptions) external onlyESOPOpen onlyCompany hasEmployee(e) returns (bool)
	{
		Employee memory emp = _loademp(e);
		require (emp.state == EmployeeState.Employed || emp.state == EmployeeState.WaitingForSignature);

		emp.extraOptions += extraOptions;
		_saveemp(e, emp);
		totalExtraOptions += extraOptions;

		emit LogESOPOffered(e, companyAddress, 0, extraOptions);
		return true;
	}

	function employeeSignsToESOP() external hasEmployee(msg.sender) onlyESOPOpen returns (bool)
	{
		Employee memory emp = _loademp(msg.sender);

		require (emp.state == EmployeeState.WaitingForSignature);

		uint32 t = currentTime();
		if (t > emp.timeToSign)
		{
			remainingPoolOptions += distributeAndReturnToPool(emp.poolOptions, emp.idx);
			totalExtraOptions -= emp.extraOptions;
			employees.removeEmployee(msg.sender);
			return false;
		}

		employees.changeState(msg.sender, EmployeeState.Employed);
		emit LogEmployeeSignedToESOP(msg.sender);
		return true;
	}

	function toggleEmployeeSuspension(address e, uint32 toggledAt) external onlyESOPOpen onlyCompany hasEmployee(e) returns (bool)
	{
		Employee memory emp = _loademp(e);
		require (emp.state == EmployeeState.Employed);
		require (emp.suspendedAt <= toggledAt);

		if (emp.suspendedAt == 0) // not suspended till now
		{
			emp.suspendedAt = toggledAt;
			emit LogSuspendEmployee(e, toggledAt);
		}
		else
		{
			uint32 suspendedPeriod = toggledAt - emp.suspendedAt;
			emp.issueDate += suspendedPeriod;
			emp.suspendedAt = 0;
			emit LogContinueSuspendedEmployee(e, toggledAt, suspendedPeriod);
		}
		_saveemp(e, emp);
		return true;
	}

	function terminateEmployee(address e, uint32 terminatedAt, uint8 terminationType) external onlyESOPOpen onlyCompany hasEmployee(e) returns (bool)
	{
		TerminationType termType = TerminationType(terminationType);
		Employee memory emp = _loademp(e);

		require (terminatedAt >= emp.issueDate);
		require(emp.state == EmployeeState.WaitingForSignature || emp.state == EmployeeState.Employed);

		if (emp.state == EmployeeState.WaitingForSignature)
			termType = TerminationType.BadLeaver;

		uint returnedOptions;
		uint returnedExtraOptions;

		if (termType == TerminationType.Regular) // good leaver -> release vested tokens
		{
			if (emp.suspendedAt > 0 && emp.suspendedAt < terminatedAt)
			{
				emp.issueDate += terminatedAt - emp.suspendedAt;
			}

			// vesting applies
			returnedOptions = emp.poolOptions - optionsCalculator.calculateVestedOptions(terminatedAt, emp.issueDate, emp.poolOptions);
			returnedExtraOptions = emp.extraOptions - optionsCalculator.calculateVestedOptions(terminatedAt, emp.issueDate, emp.extraOptions);
			employees.terminateEmployee(e, emp.issueDate, terminatedAt, terminatedAt);
		}
		else if (termType == TerminationType.BadLeaver) // bad leaver - no Options
		{
			returnedOptions = emp.poolOptions;
			returnedExtraOptions = emp.extraOptions;
			employees.removeEmployee(e);
		}

		remainingPoolOptions += distributeAndReturnToPool(returnedOptions, emp.idx);
		totalExtraOptions -= returnedExtraOptions;
		emit LogTerminateEmployee(e, companyAddress, terminatedAt, termType);
		return true;
	}

	function offerOptionsConversion(uint32 pexerciseOptionsDeadline, BaseOptionsConverter converter) external onlyESOPOpen onlyCompany returns (bool)
	{
		uint32 offerMadeAt = currentTime();
		require(converter.getExercisePeriodDeadline() - offerMadeAt >= MINIMUM_MANUAL_SIGN_PERIOD);

		// exerciseOptions must be callable by us
		require(converter.getESOP() == address(this));

		// return to pool everything we can
		removeEmployeesWithExpiredSignaturesAndReturnFadeout();

		// from now vesting and fadeout stops, no new employees may be added
		conversionOfferedAt = offerMadeAt;
		exerciseOptionsDeadline = pexerciseOptionsDeadline;
		optionsConverter = converter;

		// this is very irreversible
		esopState = ESOPState.Conversion;
		emit LogOptionsConversionOffered(companyAddress, address(converter), offerMadeAt, exerciseOptionsDeadline);
		return true;
	}

	function exerciseOptionsInternal(uint32 calcAtTime, address employee, address exerciseFor, bool disableAcceleratedVesting) internal returns (bool)
	{
		Employee memory emp = _loademp(employee);

		require(emp.state != EmployeeState.OptionsExercised);

		// if we are burning options then send 0
		if (exerciseFor != address(0))
		{
			uint pool;
			uint extra;
			uint bonus;
			(pool, extra, bonus) = optionsCalculator.calculateOptionsComponents(serializeEmployee(emp), calcAtTime, conversionOfferedAt, disableAcceleratedVesting);
		}
		// call before options conversion contract to prevent re-entry
		employees.changeState(employee, EmployeeState.OptionsExercised);
		// exercise options in the name of employee and assign those to exerciseFor
		optionsConverter.exerciseOptions(exerciseFor, pool, extra, bonus, !disableAcceleratedVesting);

		emit LogEmployeeOptionsExercised(employee, exerciseFor, uint32(pool + extra + bonus), !disableAcceleratedVesting);
		return true;
	}

	function employeeExerciseOptions(bool agreeToAcceleratedVestingBonusConditions) external onlyESOPConversion hasEmployee(msg.sender) returns (bool)
	{
		uint32 ct = currentTime();
		require (ct <= exerciseOptionsDeadline);

		return exerciseOptionsInternal(ct, msg.sender, msg.sender, !agreeToAcceleratedVestingBonusConditions);
	}

	function employeeDenyExerciseOptions() external onlyESOPConversion hasEmployee(msg.sender) returns (bool)
	{
		uint32 ct = currentTime();
		require (ct <= exerciseOptionsDeadline);

		// burn the options by sending to 0
		return exerciseOptionsInternal(ct, msg.sender, address(0), true);
	}

	function exerciseExpiredEmployeeOptions(address e, bool disableAcceleratedVesting) external onlyESOPConversion onlyCompany hasEmployee(e) returns (bool)
	{
		uint32 ct = currentTime();
		require (ct > exerciseOptionsDeadline);

		return exerciseOptionsInternal(ct, e, companyAddress, disableAcceleratedVesting);
	}

	function calcEffectiveOptionsForEmployee(address e, uint32 calcAtTime) public constant hasEmployee(e) returns (uint)
	{
		return optionsCalculator.calculateOptions(employees.getSerializedEmployee(e), calcAtTime, conversionOfferedAt, false);
	}

	function _loademp(address e) private constant returns (Employee memory)
	{
		return deserializeEmployee(employees.getSerializedEmployee(e));
	}

	function _saveemp(address e, Employee memory emp) private
	{
		employees.setEmployee(e, emp.issueDate, emp.timeToSign, emp.terminatedAt, emp.fadeoutStarts, emp.poolOptions, emp.extraOptions, emp.suspendedAt, emp.state);
	}

	function() public payable
	{
		revert();
	}

	constructor(address company, address pRootOfTrust, OptionsCalculator pOptionsCalculator, EmployeesList pEmployeesList)  public
	{
		companyAddress = company;
		rootOfTrust = pRootOfTrust;
		optionsCalculator = pOptionsCalculator;
		employees = pEmployeesList;
	}
}
