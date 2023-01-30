pragma solidity ^0.6.0;

import "./IMVDFunctionalityProposal.sol";
import "./IMVDProxy.sol";
import "./IERC20.sol";

contract MVDFunctionalityProposal is IMVDFunctionalityProposal{

    bool private _collateralDataSet;

    address private _proxy;
    address private _token;
    string private _codeName;
    bool private _emergency;
    address private _sourceLocation;
    uint256 private _sourceLocationId;
    address private _location;
    bool private _submitable;
    string private _methodSignature;
    string private _returnAbiParametersArray;
    bool private _isInternal;
    bool private _needsSender;
    string private _replaces;
    uint256 private _surveyEndBlock;
    uint256 private _surveyDuration;
    bool private _terminated;
    address private _proposer;
    bool private _disabled;

    mapping(address => uint256) private _accept;
    mapping(address => uint256) private _refuse;
    uint256 private _totalAccept;
    uint256 private _totalRefuse;
    mapping(address => bool) private _withdrawed;

    uint256 private _votesHardCap;
    bool private _votesHardCapReached;

    constructor(string memory codeName, address location, string memory methodSignature, string memory returnAbiParametersArray,
        string memory replaces, address proxy) public {
        init(codeName, location, methodSignature, returnAbiParametersArray, replaces, proxy);
    }

    function init(string memory codeName, address location, string memory methodSignature, string memory returnAbiParametersArray,
        string memory replaces, address proxy) public override {
        require(_proxy == address(0), "Already initialized!");
        _token = IMVDProxy(_proxy = proxy).getToken();
        _codeName = codeName;
        _location = location;
        _methodSignature = methodSignature;
        _returnAbiParametersArray = returnAbiParametersArray;
        _replaces = replaces;
    }

    function setCollateralData(bool emergency, address sourceLocation, uint256 sourceLocationId, bool submitable, bool isInternal, bool needsSender, address proposer, uint256 votesHardCap) public override {
        require(!_collateralDataSet, "setCollateralData already called!");
        require(_proxy == msg.sender, "Only Original Proxy can call this method!");
        _sourceLocation = sourceLocation;
        _sourceLocationId = sourceLocationId;
        _submitable = submitable;
        _isInternal = isInternal;
        _needsSender = needsSender;
        _proposer = proposer;
        _surveyDuration = toUint256(IMVDProxy(_proxy).read((_emergency = emergency) ? "getMinimumBlockNumberForEmergencySurvey" : "getMinimumBlockNumberForSurvey", bytes("")));
        _votesHardCap = votesHardCap;
        _collateralDataSet = true;
    }

    function getProxy() public override view returns(address) {
        return _proxy;
    }

    function getCodeName() public override view returns(string memory) {
        return _codeName;
    }

    function isEmergency() public override view returns(bool) {
        return _emergency;
    }

    function getSourceLocation() public override view returns(address) {
        return _sourceLocation;
    }

    function getSourceLocationId() public override view returns(uint256) {
        return _sourceLocationId;
    }

    function getLocation() public override view returns(address) {
        return _location;
    }

    function isSubmitable() public override view returns(bool) {
        return _submitable;
    }

    function getMethodSignature() public override view returns(string memory) {
        return _methodSignature;
    }

    function getReturnAbiParametersArray() public override view returns(string memory) {
        return _returnAbiParametersArray;
    }

    function isInternal() public override view returns(bool) {
        return _isInternal;
    }

    function needsSender() public override view returns(bool) {
        return _needsSender;
    }

    function getReplaces() public override view returns(string memory) {
        return _replaces;
    }

    function getProposer() public override view returns(address) {
        return _proposer;
    }

    function getSurveyEndBlock() public override view returns(uint256) {
        return _surveyEndBlock;
    }

    function getSurveyDuration() public override view returns(uint256) {
        return _surveyDuration;
    }

    function getVote(address addr) public override view returns(uint256 accept, uint256 refuse) {
        accept = _accept[addr];
        refuse = _refuse[addr];
    }

    function getVotes() public override view returns(uint256, uint256) {
        return (_totalAccept, _totalRefuse);
    }

    function isTerminated() public override view returns(bool) {
        return _terminated;
    }

    function isDisabled() public override view returns(bool) {
        return _disabled;
    }

    function isVotesHardCapReached() public override view returns(bool) {
        return _votesHardCapReached;
    }

    function getVotesHardCapToReach() public override view returns(uint256) {
        return _votesHardCap;
    }

    function start() public override {
        require(_collateralDataSet, "Still waiting for setCollateralData to be called!");
        require(msg.sender == _proxy, "Only Proxy can call this function!");
        require(_surveyEndBlock == 0, "Already started!");
        require(!_disabled, "Already disabled!");
        _surveyEndBlock = block.number + _surveyDuration;
    }

    function disable() public override {
        require(_collateralDataSet, "Still waiting for setCollateralData to be called!");
        require(msg.sender == _proxy, "Only Proxy can call this function!");
        require(_surveyEndBlock == 0, "Already started!");
        _disabled = true;
        _terminated = true;
    }

    function toJSON() public override view returns(string memory) {
        return string(abi.encodePacked(
            '{',
            getFirstJSONPart(_sourceLocation, _sourceLocationId, _location),
            '","submitable":',
            _submitable ? "true" : "false",
            ',"emergency":',
            _emergency ? "true" : "false",
            ',"isInternal":',
            _isInternal ? "true" : "false",
            ',"needsSender":',
            _needsSender ? "true" : "false",
            ',',
            getSecondJSONPart(),
            ',"proposer":"',
            toString(_proposer),
            '","endBlock":',
            toString(_surveyEndBlock),
            ',"terminated":',
            _terminated ? "true" : "false",
            ',"accepted":',
            toString(_totalAccept),
            ',"refused":',
            toString(_totalRefuse),
            ',"disabled":',
            _disabled ? 'true' : 'false',
            '}')
        );
    }

    function getSecondJSONPart() private view returns (string memory){
        return string(abi.encodePacked(
            '"codeName":"',
            _codeName,
            '","methodSignature":"',
            _methodSignature,
            '","returnAbiParametersArray":',
            formatReturnAbiParametersArray(_returnAbiParametersArray),
            ',"replaces":"',
            _replaces,
            '"'));
    }

    modifier duringSurvey() {
        require(_collateralDataSet, "Still waiting for setCollateralData to be called!");
        require(!_disabled, "Survey disabled!");
        require(!_terminated, "Survey Terminated!");
        require(!_votesHardCapReached, "Votes Hard Cap reached!");
        require(_surveyEndBlock > 0, "Survey Not Started!");
        require(block.number < _surveyEndBlock, "Survey ended!");
        _;
    }

    modifier onSurveyEnd() {
        require(_collateralDataSet, "Still waiting for setCollateralData to be called!");
        require(!_disabled, "Survey disabled!");
        require(_surveyEndBlock > 0, "Survey Not Started!");
        if(!_votesHardCapReached) {
            require(block.number >= _surveyEndBlock, "Survey is still running!");
        }
        _;
    }

    function _checkVotesHardCap() private {
        if(_votesHardCap == 0 || (_totalAccept < _votesHardCap && _totalRefuse < _votesHardCap)) {
            return;
        }
        _votesHardCapReached = true;
        terminate();
    }

    function accept(uint256 amount) external override duringSurvey {
        IERC20(_token).transferFrom(msg.sender, address(this), amount);
        uint256 vote = _accept[msg.sender];
        vote += amount;
        _accept[msg.sender] = vote;
        _totalAccept += amount;
        emit Accept(msg.sender, amount);
        _checkVotesHardCap();
    }

    function retireAccept(uint256 amount) external override duringSurvey {
        require(_accept[msg.sender] >= amount, "Insufficient funds!");
        IERC20(_token).transfer(msg.sender, amount);
        uint256 vote = _accept[msg.sender];
        vote -= amount;
        _accept[msg.sender] = vote;
        _totalAccept -= amount;
        emit RetireAccept(msg.sender, amount);
    }

    function moveToAccept(uint256 amount) external override duringSurvey {
        require(_refuse[msg.sender] >= amount, "Insufficient funds!");
        uint256 vote = _refuse[msg.sender];
        vote -= amount;
        _refuse[msg.sender] = vote;
        _totalRefuse -= amount;

        vote = _accept[msg.sender];
        vote += amount;
        _accept[msg.sender] = vote;
        _totalAccept += amount;
        emit MoveToAccept(msg.sender, amount);
        _checkVotesHardCap();
    }

    function refuse(uint256 amount) external override duringSurvey {
        IERC20(_token).transferFrom(msg.sender, address(this), amount);
        uint256 vote = _refuse[msg.sender];
        vote += amount;
        _refuse[msg.sender] = vote;
        _totalRefuse += amount;
        emit Refuse(msg.sender, amount);
        _checkVotesHardCap();
    }

    function retireRefuse(uint256 amount) external override duringSurvey {
        require(_refuse[msg.sender] >= amount, "Insufficient funds!");
        IERC20(_token).transfer(msg.sender, amount);
        uint256 vote = _refuse[msg.sender];
        vote -= amount;
        _refuse[msg.sender] = vote;
        _totalRefuse -= amount;
        emit RetireRefuse(msg.sender, amount);
    }

    function moveToRefuse(uint256 amount) external override duringSurvey {
        require(_accept[msg.sender] >= amount, "Insufficient funds!");
        uint256 vote = _accept[msg.sender];
        vote -= amount;
        _accept[msg.sender] = vote;
        _totalAccept -= amount;

        vote = _refuse[msg.sender];
        vote += amount;
        _refuse[msg.sender] = vote;
        _totalRefuse += amount;
        emit MoveToRefuse(msg.sender, amount);
        _checkVotesHardCap();
    }

    function retireAll() external override duringSurvey {
        require(_accept[msg.sender] + _refuse[msg.sender] > 0, "No votes!");
        uint256 acpt = _accept[msg.sender];
        uint256 rfs = _refuse[msg.sender];
        IERC20(_token).transfer(msg.sender, acpt + rfs);
        _accept[msg.sender] = 0;
        _refuse[msg.sender] = 0;
        _totalAccept -= acpt;
        _totalRefuse -= rfs;
        emit RetireAll(msg.sender, acpt + rfs);
    }

    function withdraw() external override onSurveyEnd {
        if(!_terminated && !_disabled) {
            terminate();
            return;
        }
        _withdraw(true);
    }

    function terminate() public override onSurveyEnd {
        require(!_terminated, "Already terminated!");
        IMVDProxy(_proxy).setProposal();
        _withdraw(false);
    }

    function _withdraw(bool launchError) private {
        require(!launchError || _accept[msg.sender] + _refuse[msg.sender] > 0, "Nothing to Withdraw!");
        require(!launchError || !_withdrawed[msg.sender], "Already Withdrawed!");
        if(_accept[msg.sender] + _refuse[msg.sender] > 0 && !_withdrawed[msg.sender]) {
            IERC20(_token).transfer(msg.sender, _accept[msg.sender] + _refuse[msg.sender]);
            _withdrawed[msg.sender] = true;
        }
    }

    function set() public override onSurveyEnd {
        require(msg.sender == _proxy, "Unauthorized Access!");
        require(!_terminated, "Already terminated!");
        _terminated = true;
    }

    function toUint256(bytes memory bs) public pure returns(uint256 x) {
        if(bs.length >= 32) {
            assembly {
                x := mload(add(bs, add(0x20, 0)))
            }
        }
    }

    function toString(address _addr) public pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function toString(uint _i) public pure returns(string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function getFirstJSONPart(address sourceLocation, uint256 sourceLocationId, address location) public pure returns(bytes memory) {
        return abi.encodePacked(
            '"sourceLocation":"',
            toString(sourceLocation),
            '","sourceLocationId":',
            toString(sourceLocationId),
            ',"location":"',
            toString(location)
        );
    }

    function formatReturnAbiParametersArray(string memory m) public pure returns(string memory) {
        bytes memory b = bytes(m);
        if(b.length < 2) {
            return "[]";
        }
        if(b[0] != bytes1("[")) {
            return "[]";
        }
        if(b[b.length - 1] != bytes1("]")) {
            return "[]";
        }
        return m;
    }
}
pragma solidity ^0.6.0;

interface IMVDProxy {

    function init(address votingTokenAddress, address functionalityProposalManagerAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalitiesManagerAddress, address walletAddress) external;

    function getDelegates() external view returns(address,address,address,address,address,address);
    function getToken() external view returns(address);
    function getMVDFunctionalityProposalManagerAddress() external view returns(address);
    function getStateHolderAddress() external view returns(address);
    function getMVDFunctionalityModelsManagerAddress() external view returns(address);
    function getMVDFunctionalitiesManagerAddress() external view returns(address);
    function getMVDWalletAddress() external view returns(address);
    function setDelegate(uint256 position, address newAddress) external returns(address oldAddress);
    function changeProxy(address newAddress, bytes calldata initPayload) external;
    function isValidProposal(address proposal) external view returns (bool);
    function isAuthorizedFunctionality(address functionality) external view returns(bool);
    function newProposal(string calldata codeName, bool emergency, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnParametersJSONArray, bool isInternal, bool needsSender, string calldata replaces) external returns(address proposalAddress);
    function startProposal(address proposalAddress) external;
    function disableProposal(address proposalAddress) external;
    function transfer(address receiver, uint256 value, address token) external;
    function transfer721(address receiver, uint256 tokenId, bytes calldata data, bool safe, address token) external;
    function setProposal() external;
    function read(string calldata codeName, bytes calldata data) external view returns(bytes memory returnData);
    function submit(string calldata codeName, bytes calldata data) external payable returns(bytes memory returnData);
    function callFromManager(address location, bytes calldata payload) external returns(bool, bytes memory);
    function emitFromManager(string calldata codeName, address proposal, string calldata replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address location, bool submitable, string calldata methodSignature, bool isInternal, bool needsSender, address proposalAddress) external;

    function emitEvent(string calldata eventSignature, bytes calldata firstIndex, bytes calldata secondIndex, bytes calldata data) external;

    event ProxyChanged(address indexed newAddress);
    event DelegateChanged(uint256 position, address indexed oldAddress, address indexed newAddress);

    event Proposal(address proposal);
    event ProposalCheck(address indexed proposal);
    event ProposalSet(address indexed proposal, bool success);
    event FunctionalitySet(string codeName, address indexed proposal, string replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address indexed replacedLocation, bool replacedWasSubmitable, string replacedMethodSignature, bool replacedWasInternal, bool replacedNeededSender, address indexed replacedProposal);

    event Event(string indexed key, bytes32 indexed firstIndex, bytes32 indexed secondIndex, bytes data);
}
pragma solidity ^0.6.0;

interface IMVDFunctionalityProposal {

    function init(string calldata codeName, address location, string calldata methodSignature, string calldata returnAbiParametersArray, string calldata replaces, address proxy) external;
    function setCollateralData(bool emergency, address sourceLocation, uint256 sourceLocationId, bool submitable, bool isInternal, bool needsSender, address proposer, uint256 votesHardCap) external;

    function getProxy() external view returns(address);
    function getCodeName() external view returns(string memory);
    function isEmergency() external view returns(bool);
    function getSourceLocation() external view returns(address);
    function getSourceLocationId() external view returns(uint256);
    function getLocation() external view returns(address);
    function isSubmitable() external view returns(bool);
    function getMethodSignature() external view returns(string memory);
    function getReturnAbiParametersArray() external view returns(string memory);
    function isInternal() external view returns(bool);
    function needsSender() external view returns(bool);
    function getReplaces() external view returns(string memory);
    function getProposer() external view returns(address);
    function getSurveyEndBlock() external view returns(uint256);
    function getSurveyDuration() external view returns(uint256);
    function isVotesHardCapReached() external view returns(bool);
    function getVotesHardCapToReach() external view returns(uint256);
    function toJSON() external view returns(string memory);
    function getVote(address addr) external view returns(uint256 accept, uint256 refuse);
    function getVotes() external view returns(uint256, uint256);
    function start() external;
    function disable() external;
    function isDisabled() external view returns(bool);
    function isTerminated() external view returns(bool);
    function accept(uint256 amount) external;
    function retireAccept(uint256 amount) external;
    function moveToAccept(uint256 amount) external;
    function refuse(uint256 amount) external;
    function retireRefuse(uint256 amount) external;
    function moveToRefuse(uint256 amount) external;
    function retireAll() external;
    function withdraw() external;
    function terminate() external;
    function set() external;

    event Accept(address indexed voter, uint256 amount);
    event RetireAccept(address indexed voter, uint256 amount);
    event MoveToAccept(address indexed voter, uint256 amount);
    event Refuse(address indexed voter, uint256 amount);
    event RetireRefuse(address indexed voter, uint256 amount);
    event MoveToRefuse(address indexed voter, uint256 amount);
    event RetireAll(address indexed voter, uint256 amount);
}
pragma solidity ^0.6.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.6.0;

interface IMVDFunctionalitiesManager {

    function getProxy() external view returns (address);
    function setProxy() external;

    function init(address sourceLocation,
        uint256 getMinimumBlockNumberSourceLocationId, address getMinimumBlockNumberFunctionalityAddress,
        uint256 getEmergencyMinimumBlockNumberSourceLocationId, address getEmergencyMinimumBlockNumberFunctionalityAddress,
        uint256 getEmergencySurveyStakingSourceLocationId, address getEmergencySurveyStakingFunctionalityAddress,
        uint256 checkVoteResultSourceLocationId, address checkVoteResultFunctionalityAddress) external;

    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender) external;
    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender, uint256 position) external;
    function removeFunctionality(string calldata codeName) external returns(bool removed, uint256 position);
    function isValidFunctionality(address functionality) external view returns(bool);
    function isAuthorizedFunctionality(address functionality) external view returns(bool);
    function setCallingContext(address location) external returns(bool);
    function clearCallingContext() external;
    function getFunctionalityData(string calldata codeName) external view returns(address, uint256, string memory, address, uint256);
    function hasFunctionality(string calldata codeName) external view returns(bool);
    function getFunctionalitiesAmount() external view returns(uint256);
    function functionalitiesToJSON() external view returns(string memory);
    function functionalitiesToJSON(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);
    function functionalityNames() external view returns(string memory);
    function functionalityNames(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);
    function functionalityToJSON(string calldata codeName) external view returns(string memory);

    function preConditionCheck(string calldata codeName, bytes calldata data, uint8 submitable, address sender, uint256 value) external view returns(address location, bytes memory payload);

    function setupFunctionality(address proposalAddress) external returns (bool);
}
