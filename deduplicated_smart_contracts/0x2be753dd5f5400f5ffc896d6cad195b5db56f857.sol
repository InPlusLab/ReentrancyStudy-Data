pragma solidity ^0.4.24;
import { AuthModule } from "AuthModule.sol";

import "Address.sol";

contract Proxy {
    using Address for address;

    mapping(string => address) moduleMap;
    mapping(address => bool) insideContracts;   // all internal contract address, used to make sure only called from inside

    event AddInsideContract(address _contract);
    event AddInsideContracts(address[] _contracts);
    event RemoveInsideContract(address _contract);
    event UpdateModule(string _moduleName, address _preModule, address _newModule);

    modifier onlyAdmin() {
        AuthModule auth = AuthModule(getModule("AuthModule"));
        require(auth.isAdmin(msg.sender), "Need be admin");
        _;
    }
    
    constructor(address authModule) public {
        _updateModule("AuthModule", authModule, true);
    }

    function addInsideContract(address _contract) public onlyAdmin {
        _addInsideContract(_contract);
    }

    function _addInsideContract(address _contract) private {
        // require(insideContracts[_contract] == false, "Inside contract already exists");
        insideContracts[_contract] = true;
        emit AddInsideContract(_contract);
    }
    
    function addInsideContracts(address[] _contracts) public onlyAdmin {
        for(uint i = 0; i < _contracts.length; i++) {
            // require(insideContracts[_contracts[i]] == false, "Inside contract already exists");
            insideContracts[_contracts[i]] = true;
        }
        emit AddInsideContracts(_contracts);
    }

    function removeInsideContract(address _contract) public onlyAdmin {
        _removeInsideContract(_contract);
    }

    function _removeInsideContract(address _contract) private {
        delete insideContracts[_contract];
        emit RemoveInsideContract(_contract);
    }

    // TODO: need to check if the address is a contract
    function isInsideContract(address _contract) public view returns (bool) {
        return _contract.isContract() && insideContracts[_contract] == true;
    }

    function updateModule(string _moduleName, address _module, bool _insideContract) public onlyAdmin {
        _updateModule(_moduleName, _module, _insideContract);
    }

    function _updateModule(string _moduleName, address _module, bool _insideContract) private {
        address preModule = moduleMap[_moduleName];
        if(preModule != address(0))
            _removeInsideContract(preModule);
        moduleMap[_moduleName] = _module;
        if(_insideContract && _module != address(0))
            _addInsideContract(_module);
        emit UpdateModule(_moduleName, preModule, _module);
    }

    function getModule(string _moduleName) public view returns (address) {
        return moduleMap[_moduleName];
    } 
    
}