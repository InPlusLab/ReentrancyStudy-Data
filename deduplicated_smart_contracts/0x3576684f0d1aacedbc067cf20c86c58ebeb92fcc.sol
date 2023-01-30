pragma solidity ^0.4.24;

import "./ERC20.sol";
import "./Ownable.sol";
import "./ERC20Detailed.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";
import "./ERC20Mintable.sol";

contract ReceiveApprovalInterface {
  function receiveApproval(address buyer, uint256 _value, address _coinAddress, bytes32 _data) public returns (bool success);
}

contract StanCoin is ERC20, ERC20Detailed, Ownable, ERC20Pausable, ERC20Burnable, ERC20Mintable {
    string public name = 'Stan World';
    string public symbol = 'STAN';
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 1000000000000000000000000000;

    constructor() public ERC20Detailed(name, symbol, decimals) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function stringToBytes32(string memory source) pure private returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

      assembly {
          result := mload(add(source, 32))
      }
    }

    function approveAndCall(address _spender, uint256 _value, bytes32 data) public returns (bool) {
        if (approve(_spender, _value)) {
            if (_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes32)"))), msg.sender, _value, address(this), data)) {
                return true;
            }
            return false;
        }
    }
}
