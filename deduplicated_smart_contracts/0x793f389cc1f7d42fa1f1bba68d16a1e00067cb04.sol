pragma solidity ^0.6.3;

import "./ZeneKaG16I.sol";
import "./ERC721Full.sol";
import "./Ownable.sol";

contract Adventureth is ERC721Full, Ownable {
    address private zeneka_g16_address = 0x0623d81354051244AB716D1b8F14788d2fb03326;
    address payable private _adventureth_operator;
    uint256 private _tokenCount = 0;
    mapping(bytes32 => address) private _idToOperator;
    mapping(bytes32 => bytes32) private _idToNext;
    mapping(bytes32 => bytes32) private _idToPrev;
    mapping(bytes32 => address) private _idToSolver;
    mapping(bytes32 => string) private _idToIPFS;
    mapping(bytes32 => uint256) private _idToReward;
    mapping(uint256 => bytes32) private _tokenToId;
    mapping(uint256 => address) private _tokenToSolver;
    mapping(bytes32 => uint256) private _idToTotalSolvers;
    mapping(bytes32 => address) private _proofHashToProver;
    mapping(bytes32 => mapping(uint256 => address)) private _idToSolverIdxToSolver;
    mapping(bytes32 => mapping(address => bool)) private _idToAddressToSolved;

    constructor() public ERC721Full("Adventureth", "ADVETH") {
        _adventureth_operator = msg.sender;
    }

    function updateAdventurethOperator(address payable _operator) public {
        require(_adventureth_operator == msg.sender, "Unauthorized");
        _adventureth_operator = _operator;
    }

    function updateZenekaG16Address(address _address) public {
        require(msg.sender == _adventureth_operator, "Unauthorized.");
        zeneka_g16_address = _address;
    }

    function updateOperator(bytes32 _id, address _operator) public {
        require(_idToOperator[_id] == msg.sender, "Unauthorized");
        _idToOperator[_id] = _operator;
    }

    function operator(bytes32 _id)
        public
        view
        returns (address challengeOperator)
    {
        require(_idToOperator[_id] != address(0), "Not found.");
        return _idToOperator[_id];
    }

    function reward(bytes32 _id) public view returns (uint256 amount) {
        return _idToReward[_id];
    }

    function addReward(bytes32 _id) public payable {
        require(_idToSolver[_id] == address(0), "Already solved.");

        _idToReward[_id] += msg.value;
    }

    function setIPFS(bytes32 _id, string memory _ipfsAddress) public {
        require(_idToOperator[_id] == msg.sender, "Unauthorized");
        _idToIPFS[_id] = _ipfsAddress;
    }

    function getIPFS(bytes32 _id)
        public
        view
        returns (string memory ipfsAddress)
    {
        return _idToIPFS[_id];
    }

    function prover(bytes32 _proofHash)
        public
        view
        returns (address commitProver)
    {
        return _proofHashToProver[_proofHash];
    }

    function commit(bytes32 _id, bytes32 _proofHash) public {
        require(_idToOperator[_id] != address(0), "Not found.");
        ZeneKaG16I zeneKaG16 = ZeneKaG16I(zeneka_g16_address);
        zeneKaG16.commitG16(_id, _proofHash);
        _proofHashToProver[_proofHash] = msg.sender;
    }

    function exists(bytes32 _id) public view returns (bool idExists) {
        return _idToOperator[_id] != address(0);
    }

    function withdraw(bytes32 _id) public {
        require(_idToOperator[_id] == msg.sender, "Unauthorized.");

        if (_idToReward[_id] > 0) {
            uint256 _fee = _idToReward[_id] / 40;
            uint256 _reward = _idToReward[_id] - _fee;

            if (_fee > 0) _adventureth_operator.transfer(_fee);
            msg.sender.transfer(_reward);
            _idToReward[_id] = 0;
        }
    }

    function solver(bytes32 _id) public view returns (address solvedBy) {
        return _idToSolver[_id];
    }

    function solverByIndex(bytes32 _id, uint256 _idx)
        public
        view
        returns (address solverAtIndex)
    {
        return _idToSolverIdxToSolver[_id][_idx];
    }

    function solvers(bytes32 _id) public view returns (uint256 totalSolvers) {
        return _idToTotalSolvers[_id];
    }

    function solved(bytes32 _id, address _address)
        public
        view
        returns (bool didSolve)
    {
        return _idToAddressToSolved[_id][_address];
    }

    function solve(
        bytes32 _id,
        uint256[2] memory _a,
        uint256[2][2] memory _b,
        uint256[2] memory _c,
        uint256[] memory _input
    ) public returns (bool didSolve) {
        require(_idToOperator[_id] != address(0), "Not found.");
        ZeneKaG16I zeneKaG16 = ZeneKaG16I(zeneka_g16_address);
        require(
            _input.length > 0 && _input[0] == uint256(address(this)),
            "Invalid public input"
        );
        bytes32 proofHash = keccak256(abi.encodePacked(_a, _b, _c, _input));
        address payable commitProver = address(
            uint160(_proofHashToProver[proofHash])
        );
        require(commitProver == msg.sender, "Unauthorized.");
        bool _didSolve = zeneKaG16.proveG16(_id, _a, _b, _c, _input);

        if (_didSolve) {
            if (_idToSolver[_id] == address(0)) {
                _idToSolver[_id] = commitProver;

                if (_idToReward[_id] > 0) {
                    uint256 _fee = _idToReward[_id] / 40;
                    uint256 _reward = _idToReward[_id] - _fee;

                    if (_fee > 0) _adventureth_operator.transfer(_fee);
                    _idToReward[_id] = 0;
                    commitProver.transfer(_reward);
                }
            }

            if (!_idToAddressToSolved[_id][commitProver]) {
                _mintToken(commitProver, _id);
                _idToSolverIdxToSolver[_id][_idToTotalSolvers[_id]] = commitProver;
                _idToTotalSolvers[_id] += 1;
            }

            _idToAddressToSolved[_id][commitProver] = true;
        }

        return _didSolve;
    }

    function _mintToken(address _to, bytes32 _id) internal {
        _tokenCount += 1;
        _tokenToId[_tokenCount] = _id;
        _tokenToSolver[_tokenCount] = _to;
        _mint(_to, _tokenCount);
    }

    function register(
        bytes32 _prev,
        bytes32[2] memory _a,
        bytes32[2][2] memory _b,
        bytes32[2][2] memory _gamma,
        bytes32[2][2] memory _delta,
        uint256 _gamma_abc_len,
        bytes32[2][] memory _gamma_abc
    ) public payable returns (bool isRegistered) {
        bytes32 id = keccak256(
            abi.encodePacked(_a, _b, _gamma, _delta, _gamma_abc_len, _gamma_abc)
        );

        require(_idToOperator[id] == address(0), "Already registered.");
        _idToOperator[id] = msg.sender;

        if (_prev != 0) {
            require(_idToOperator[_prev] == msg.sender, "Unauthorized");
            _idToNext[_prev] = id;
            _idToPrev[id] = _prev;
        }

        ZeneKaG16I zeneKaG16 = ZeneKaG16I(zeneka_g16_address);
        bool _isRegistered = zeneKaG16.registerG16(
            _a,
            _b,
            _gamma,
            _delta,
            _gamma_abc_len,
            _gamma_abc
        );

        if (_isRegistered) {
            _idToReward[id] += msg.value;
        }
        return _isRegistered;
    }

    function transfer(bytes32 _from, bytes32 _to) public payable {
        require(_idToSolver[_to] == address(0), "Already solved.");
        require(_idToOperator[_from] == msg.sender, "Unauthorized");

        _idToReward[_to] = _idToReward[_from];
        _idToReward[_to] += msg.value;
        _idToReward[_from] = 0;
    }

    function next(bytes32 _id) public view returns (bytes32 nextId) {
        require(_idToOperator[_id] != address(0), "Not found.");
        return _idToNext[_id];
    }

    function prev(bytes32 _id) public view returns (bytes32 nextId) {
        require(_idToOperator[_id] != address(0), "Not found.");
        return _idToPrev[_id];
    }

    function tokenToId(uint256 _tokenId) public view returns (bytes32 id) {
        require(
            _tokenId <= _tokenCount && _tokenToId[_tokenId] != 0,
            "Invalid token"
        );

        return _tokenToId[_tokenId];
    }

    function tokenToSolver(uint256 _tokenId)
        public
        view
        returns (address solvedBy)
    {
        require(_tokenId <= _tokenCount, "Invalid Token");
        require(_tokenToSolver[_tokenId] != address(0), "Invalid Token");

        return _tokenToSolver[_tokenId];
    }
}
