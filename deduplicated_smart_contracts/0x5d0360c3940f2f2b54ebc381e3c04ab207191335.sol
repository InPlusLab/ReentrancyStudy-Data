/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface yToken {
    function transferOwnership(address newOwner) external;
    function set_new_APR(address _new_APR) external;
    function set_new_FULCRUM(address _new_FULCRUM) external;
    function set_new_COMPOUND(address _new_COMPOUND) external;
    function set_new_DTOKEN(uint256 _new_DTOKEN) external;
    function set_new_AAVE(address _new_AAVE) external;
    function set_new_APOOL(address _new_APOOL) external;
    function set_new_ATOKEN(address _new_ATOKEN) external;
    function recommend() external view returns (uint8);
    function balance() external view returns (uint256);
    function balanceDydxAvailable() external view returns (uint256);
    function balanceDydx() external view returns (uint256);
    function balanceCompound() external view returns (uint256);
    function balanceCompoundInToken() external view returns (uint256);
    function balanceFulcrumAvailable() external view returns (uint256);
    function balanceFulcrumInToken() external view returns (uint256);
    function balanceFulcrum() external view returns (uint256);
    function balanceAaveAvailable() external view returns (uint256);
    function balanceAave() external view returns (uint256);
    function withdrawSomeCompound(uint256 _amount) external;
    function withdrawSomeFulcrum(uint256 _amount) external;
    function withdrawAave(uint amount) external;
    function withdrawDydx(uint256 amount) external;
    function supplyDydx(uint256 amount) external;
    function supplyAave(uint amount) external;
    function supplyFulcrum(uint amount) external;
    function supplyCompound(uint amount) external;
}

interface IIEarnManager {
    function recommend(address _token) external view returns (
      string memory choice,
      uint256 capr,
      uint256 iapr,
      uint256 aapr,
      uint256 dapr
    );
}

contract yTokenProxy is ReentrancyGuard, Ownable {
  using Address for address;
  using SafeMath for uint256;

  yToken public _yToken;

  constructor () public {
     _yToken = yToken(0xC2cB1040220768554cf699b0d863A3cd4324ce32);
  }

  function withdrawAave() public onlyOwner {
    _yToken.withdrawAave(_yToken.balanceAave());
  }

  function withdrawDydx() public onlyOwner {
    _yToken.withdrawDydx(_yToken.balanceDydx());
  }

  function set_new_yToken(yToken _new_yToken) public onlyOwner {
      _yToken = _new_yToken;
  }

  function transferYTokenOwnership(address _newOwner) public onlyOwner {
    _yToken.transferOwnership(_newOwner);
  }

}