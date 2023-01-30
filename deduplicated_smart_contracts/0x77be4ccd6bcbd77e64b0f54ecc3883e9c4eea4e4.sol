/**
 *Submitted for verification at Etherscan.io on 2019-09-17
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.8;


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Integer division of two numbers, rounding up and truncating the quotient
  */
  function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }

    return ((_a - 1) / _b) + 1;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract UserContract {
    address public owner;
    mapping (address => bool) public controllers;

    constructor(
        address _owner,
        address[] memory _controllerList)
        public
    {
        owner = _owner;

        for(uint256 i=0; i < _controllerList.length; i++) {
            controllers[_controllerList[i]] = true;
        }
    }

    function transferAsset(
        address asset,
        address payable to,
        uint256 amount)
        public
        returns (uint256 transferAmount)
    {
        require(controllers[msg.sender] || msg.sender == owner);

        bool success;
        if (asset == address(0)) {
            transferAmount = amount == 0 ?
                address(this).balance :
                amount;
            (success, ) = to.call.value(transferAmount)("");
            require(success);
        } else {
            bytes memory data;
            if (amount == 0) {
                (,data) = asset.call(
                    abi.encodeWithSignature(
                        "balanceOf(address)",
                        address(this)
                    )
                );
                assembly {
                    transferAmount := mload(add(data, 32))
                }
            } else {
                transferAmount = amount;
            }
            (success,) = asset.call(
                abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    to,
                    transferAmount
                )
            );
            require(success);
        }
    }

    function setControllers(
        address[] memory _controllerList,
        bool[] memory _toggle)
        public
    {
        require(msg.sender == owner && _controllerList.length == _toggle.length);

        for (uint256 i=0; i < _controllerList.length; i++) {
            controllers[_controllerList[i]] = _toggle[i];
        }
    }
}

contract UserContractRegistry is Ownable {

    mapping (address => bool) public controllers;
    mapping (address => UserContract) public userContracts;

    function setControllers(
        address[] memory controller,
        bool[] memory toggle)
        public
        onlyOwner
    {
        require(controller.length == toggle.length, "count mismatch");

        for (uint256 i=0; i < controller.length; i++) {
            controllers[controller[i]] = toggle[i];
        }
    }

    function setContract(
        address user,
        UserContract userContract)
        public
    {
        require(controllers[msg.sender], "unauthorized");
        userContracts[user] = userContract;
    }
}

interface ENSSimple {
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
}

interface ResolverSimple {
    function setAddr(bytes32 node, address addr) external;
    function addr(bytes32 node) external view returns (address);
}

contract ENSLoanOpenerStorage is Ownable {
    // tokenloan.eth
    bytes32 internal constant tokenloanHash = 0x412c2f8803a30232df76357316f10634835ba4cd288f6002d1d70cb72fac904b;

    address public bZxContract;
    address public bZxVault;
    address public loanTokenLender;
    address public loanTokenAddress;
    address public wethContract;

    UserContractRegistry public userContractRegistry;

    address[] public controllerList;

    uint256 public initialLoanDuration = 7884000; // approximately 3 months

    // ENS
    ENSSimple public ENSContract;
    ResolverSimple public ResolverContract;
}

contract ENSLoanOpenerProxy is ENSLoanOpenerStorage {

    address internal target_;

    constructor(
        address _newTarget)
        public
    {
        _setTarget(_newTarget);
    }

    function()
        external
        payable
    {
        address target = target_;
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function setTarget(
        address _newTarget)
        public
        onlyOwner
    {
        _setTarget(_newTarget);
    }

    function _setTarget(
        address _newTarget)
        internal
    {
        require(_isContract(_newTarget), "target not a contract");
        target_ = _newTarget;
    }

    function _isContract(
        address addr)
        internal
        view
        returns (bool)
    {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}