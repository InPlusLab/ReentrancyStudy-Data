/**
 *Submitted for verification at Etherscan.io on 2019-11-05
*/

// File: contracts/EtherMiners/interfaces/IEmPool.sol

pragma solidity >=0.4.22 <0.6.0;

contract IEmPool {
   function deposit() public payable;
   function withdraw(uint256 _value) external;
   function withdrawTo(address _to, uint256 _value) public;
}

// File: contracts/EtherMiners/interfaces/IDebug.sol

pragma solidity >=0.4.22 <0.6.0;

contract IDebug {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function debugger() public pure returns (address){}
    
    function disableDebug() external;
}

// File: contracts/EtherMiners/interfaces/ICaller.sol

pragma solidity >=0.4.22 <0.6.0;
/*
    ICaller is the interface for contract which call other contract(like a data contract).
	The Caller contract *must* implements the calledUpdate function to change its calling contract reference.
*/

contract ICaller {
	function calledUpdate(address _oldCalled, address _newCalled) external;  // debugOnly
	
	event CalledUpdate(address _oldCalled, address _newCalled);
}

// File: contracts/EtherMiners/interfaces/ICalled.sol

pragma solidity >=0.4.22 <0.6.0;



/*
    Called contract interface
*/
contract ICalled {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function callers(address) public pure returns (bool){}

    function appendCaller(address _caller) external;                        // debugOnly
    function removeCaller(address _caller) external;                        // debugOnly
    function modifyCallers(address[] _remove, address[] _append) external;  // debugOnly
    
    event AppendCaller(ICaller _caller);
    event RemoveCaller(ICaller _caller);
}

// File: contracts/EtherMiners/base/Debug.sol

pragma solidity >=0.4.22 <0.6.0;


contract Debug is IDebug {
    address public debugger;

    constructor() public {
        debugger = msg.sender;
    }

    modifier debugOnly {
        assert(msg.sender == debugger);
        _;
    }

    function disableDebug() external debugOnly {
        debugger = address(0);
    }
}

contract Disable is Debug {
	bool public disabled;
	
	modifier enabled {
		require(!disabled);
		_;
	}
	
	function disable(bool _disable) external debugOnly {
		disabled = _disable;
	}
}

// File: contracts/EtherMiners/base/Called.sol

pragma solidity >=0.4.22 <0.6.0;



/*
    Provides support and utilities for contract calling relationship
*/
contract Called is ICalled, Debug {
    mapping(address => bool) public callers;
    
    // allows calling by the callers only
    modifier callerOnly {
        assert(callers[msg.sender] || msg.sender == debugger);
        _;
    }

    function appendCaller(address _caller) external debugOnly {
        callers[_caller] = true;
        emit AppendCaller(ICaller(_caller));
    }
    
    function removeCaller(address _caller) external debugOnly {
        delete callers[_caller];
        emit RemoveCaller(ICaller(_caller));
    }

    function modifyCallers(address[] _remove, address[] _append) external debugOnly {
        uint i;
        for(i=0; i<_remove.length; i++){
            delete callers[_remove[i]];
            emit RemoveCaller(ICaller(_remove[i]));
        }
        
        for(i=0; i<_append.length; i++){
            callers[_append[i]] = true;
            emit AppendCaller(ICaller(_append[i]));
        }
    }
}

// File: contracts/EtherMiners/interfaces/IData.sol

pragma solidity >=0.4.22 <0.6.0;

contract IData
{
    // these function isn't abstract since the compiler emits automatically generated getter functions as external
    function bu(bytes32) public pure returns(uint256){}
    function ba(bytes32) public pure returns(address){}
    //function bi(bytes32) public pure returns(int256){}
    //function bs(bytes32) public pure returns(string){}
    //function bb(bytes32) public pure returns(bytes){}
    
    function bau(bytes32, address) public pure returns(uint256){}
    //function baa(bytes32, address) public pure returns(address){}
    //function bai(bytes32, address) public pure returns(int256){}
    //function bas(bytes32, address) public pure returns(string){}
    //function bab(bytes32, address) public pure returns(bytes){}
    
    function bbu(bytes32, bytes32) public pure returns(uint256){}
    //function bbs(bytes32, bytes32) public pure returns(string memory){}

    function buu(bytes32, uint256) public pure returns(uint256){}
    function bua(bytes32, uint256) public pure returns(address){}
	//function bus(bytes32, uint256) public pure returns(string memory){}
    //function bas(bytes32, address) public pure returns(string memory){}
    //function bui(bytes32, uint256) public pure returns(int256){}
    //function bus(bytes32, uint256) public pure returns(string){}
    //function bub(bytes32, uint256) public pure returns(bytes){}
    
    function bauu(bytes32, address, uint256) public pure returns(uint256){}
	//function baau(bytes32, address, address) public pure returns(uint256){}
    function bbau(bytes32, bytes32, address) public pure returns(uint256){}
    function buuu(bytes32, uint256, uint256) public pure returns(uint256){}
    //function bbaau(bytes32, bytes32, address, address) public pure returns(uint256){}
    
    function setBU(bytes32 _key, uint256 _value) external;
    function setBA(bytes32 _key, address _value) external;
    //function setBI(bytes32 _key, int256 _value) external;
    //function setBS(bytes32 _key, string _value) external;
    //function setBB(bytes32 _key, bytes _value) external;
    
    function setBAU(bytes32 _key, address _addr, uint256 _value) external;
    //function setBAA(bytes32 _key, address _addr, address _value) external;
    //function setBAI(bytes32 _key, address _addr, int256 _value) external;
    //function setBAS(bytes32 _key, address _addr, string _value) external;
    //function setBAB(bytes32 _key, address _addr, bytes _value) external;
    
    function setBBU(bytes32 _key, bytes32 _id, uint256 _value) external;
    //function setBBS(bytes32 _key, bytes32 _id, string calldata _value) external;

    function setBUU(bytes32 _key, uint256 _index, uint256 _value) external;
    function setBUA(bytes32 _key, uint256 _index, address _addr) external;
	//function setBUS(bytes32 _key, uint256 _index, string calldata _str) external;
    //function setBUI(bytes32 _key, uint256 _index, int256 _value) external;
    //function setBUB(bytes32 _key, uint256 _index, bytes _value) external;

	//function setBAAU(bytes32 _key, address _token, address _addr, uint256 _value) external;
	function setBAUU(bytes32 _key, address _addr, uint256 _index, uint256 _value) external;
    function setBBAU(bytes32 _key, bytes32 _id, address _holder, uint256 _value) external;
	function setBUUU(bytes32 _key, uint256 _index,  uint256 _index2, uint256 _value) external;
    //function setBBAAU(bytes32 _key, bytes32 _id, address _from, address _to, uint256 _value) external;
}

// File: contracts/EtherMiners/base/DataCaller.sol

pragma solidity >=0.4.22 <0.6.0;




/*
    DataCaller is the wrapper to visit the IEmData.
*/

contract DataCaller is Debug, ICaller {
    IData public data;
    
    constructor(IData _data) public {
        data = IData(_data);
    }
    
    function calledUpdate(address _oldCalled, address _newCalled) external debugOnly {
        if(data == _oldCalled) {
            data = IData(_newCalled);
            emit CalledUpdate(_oldCalled, _newCalled);
        }
    }
}

contract GetBU is DataCaller {
    function getBU(bytes32 _key) internal view returns(uint256) {
        return data.bu(_key);        
    }
}
contract SetBU is DataCaller {
    function setBU(bytes32 _key, uint256 _value) internal {
        data.setBU(_key, _value);    
    }
}

contract Enabled is Disable, GetBU {
	modifier enabled2 {
        require(!disabled && getBU("dappEnabled") != 0);
        _;
    }
}
contract DisableDapp is SetBU {
	function disableDapp(bool _disable) public debugOnly {
		setBU("dappEnabled", _disable ? 0 : 1);
	}
}
    
contract GetBA is DataCaller {
    function getBA(bytes32 _key) internal view returns(address) {
        return data.ba(_key);        
    }
}
contract SetBA is DataCaller {
    function setBA(bytes32 _key, address _value) internal {
        data.setBA(_key, _value);    
    }
}

contract GetBAU is DataCaller {
    function getBAU(bytes32 _key, address _addr) internal view returns(uint256) {
        return data.bau(_key, _addr);        
    }
}
contract SetBAU is DataCaller {
    function setBAU(bytes32 _key, address _addr, uint256 _value) internal {
        data.setBAU(_key, _addr, _value);    
    }
}

contract GetBBU is DataCaller {
    function getBBU(bytes32 _key, bytes32 _id) internal view returns(uint256) {
        return data.bbu(_key, _id);
    }
}
contract SetBBU is DataCaller {
    function setBBU(bytes32 _key, bytes32 _id, uint256 _value) internal {
        data.setBBU(_key, _id, _value);    
    }
}

//contract GetBBS is DataCaller {
//    function getBBS(bytes32 _key, bytes32 _id) internal view returns(string) {
//        return data.bbs(_key, _id);
//    }
//}
//contract SetBBS is DataCaller {
//    function setBBS(bytes32 _key, bytes32 _id, string _value) internal {
//        data.setBBS(_key, _id, _value);    
//    }
//}

contract GetBUU is DataCaller {
    function getBUU(bytes32 _key, uint256 _index) internal view returns(uint256) {
        return data.buu(_key, _index);        
    }
}
contract SetBUU is DataCaller {
    function setBUU(bytes32 _key, uint256 _index, uint256 _value) internal {
        data.setBUU(_key, _index, _value);    
    }
}

contract GetBUA is DataCaller {
	function getBUA(bytes32 _key, uint256 _index) internal view returns(address) {
        return data.bua(_key, _index);        
    }
}
contract SetBUA is DataCaller {
	function setBUA(bytes32 _key, uint256 _index, address _addr) internal {
        data.setBUA(_key, _index, _addr);        
    }
}
//contract GetBUS is DataCaller {
//	function getBUS(bytes32 _key, uint256 _index) internal view returns(string) {
//        return data.bus(_key, _index);        
//    }
//}
//contract SetBUS is DataCaller {
//	function setBUS(bytes32 _key, uint256 _index, string _str) internal {
//        data.setBUS(_key, _index, _str);        
//    }
//}

contract GetBAUU is DataCaller {
	function getBAUU(bytes32 _key, address _addr, uint256 _index) internal view returns(uint256) {
        return data.bauu(_key, _addr, _index);        
    }
}
contract SetBAUU is DataCaller {
	function setBAUU(bytes32 _key, address _addr, uint256 _index, uint256 _value) internal {
        data.setBAUU(_key, _addr, _index, _value);    
    }
}

//contract GetBAAU is DataCaller {
//	function getBAAU(bytes32 _key, address _addr, address _addr2) internal view returns(uint256) {
//        return data.baau(_key, _addr, _addr2);        
//    }
//}
//contract SetBAAU is DataCaller {
//	function setBAAU(bytes32 _key, address _addr, address _addr2, uint256 _value) internal {
//        data.setBAAU(_key, _addr, _addr2, _value);    
//    }
//}

contract GetBBAU is DataCaller {
    function getBBAU(bytes32 _key, bytes32 _id, address _holder) internal view returns(uint256) {
        return data.bbau(_key, _id, _holder);
    }
}
contract SetBBAU is DataCaller {
    function setBBAU(bytes32 _key, bytes32 _id, address _holder, uint256 _value) internal {
        data.setBBAU(_key, _id, _holder, _value);    
    }
}

contract GetBUUU is DataCaller {
	function getBUUU(bytes32 _key, uint256 _index, uint256 _index2) internal view returns(uint256) {
        return data.buuu(_key, _index, _index2);        
    }
}
contract SetBUUU is DataCaller {
	function setBUUU(bytes32 _key, uint256 _index, uint256 _index2, uint256 _value) internal {
        data.setBUUU(_key, _index, _index2, _value);    
    }
}

//contract GetBBAAU is DataCaller {
//    function getBBAAU(bytes32 _key, bytes32 _id, address _from, address _to) internal view returns(uint256) {
//        return data.bbaau(_key, _id, _from, _to);        
//    }
//}
//contract SetBBAAU is DataCaller {
//    function setBBAAU(bytes32 _key, bytes32 _id, address _from, address _to, uint256 _value) internal {
//        data.setBBAAU(_key, _id, _from, _to, _value);
//    }
//}

contract BalanceAlign is DataCaller, GetBU {
    //uint256 public constant MAX_UINT = uint256(-1);       // defined in Utils.sol
    function balanceAlign(uint256 _value, uint256 _balance) internal view returns(uint256) {
        if(_value == uint256(-1) || _value * 1 ether < _balance * getBU("balanceAlignHi") && _value * 1 ether > _balance * getBU("balanceAlignLo"))
            return _balance;
        else
            return _value;
    }
}

// File: contracts/EtherMiners/EmPool.sol

pragma solidity >=0.4.22 <0.6.0;





contract EmPool is IEmPool, Disable, Called, GetBA {
   
   event Deposit(address indexed _from, uint256 _value);
   event Withdraw(address indexed _to, uint256 _value);
   
   constructor(IData _data) DataCaller(_data) public {
   
   }
   
   function deposit() public payable {
       emit Deposit(msg.sender, msg.value);
   }
   
   function withdraw(uint256 _value) external {
       withdrawTo(msg.sender, _value);
   }
   function withdrawTo(address _to, uint256 _value) enabled callerOnly public {
       _to.transfer(_value);
       emit Withdraw(_to, _value);
   }
   
   function () external payable {
       deposit();
   }
}

// File: contracts/EtherMiners/EmStaticPool.sol

pragma solidity >=0.4.22 <0.6.0;


contract EmStaticPool is EmPool{
   
   constructor(IData _data) EmPool(_data) public {
   
   }
   function withdrawTo(address _to, uint256 _value) enabled public {
        require(msg.sender == getBA("EmStatic") || msg.sender == getBA("EmLuck") || msg.sender == getBA("EmQueue"));
        _to.transfer(_value);
        emit Withdraw(_to, _value);
   }
}