/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

pragma solidity ^0.5.17;

library SafeMath
{
    function mul(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        assert(b <= a);

        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        uint256 c = a + b;

        assert(c >= a);

        return c;
    }
}

contract Ownable
{
    address public owner;
    address public signerAddress;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SignerAddressTransferred(address indexed previousOwner, address indexed newSignerAddress);

    constructor() public {
        owner = msg.sender;
        signerAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function transferSignerAddress(address newSignerAddress) public onlyOwner {
        require(newSignerAddress != address(0));
        emit OwnershipTransferred(signerAddress, newSignerAddress);
        signerAddress = newSignerAddress;
    }
}

contract TokenERC20 is Ownable {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) public;
    function approve(address _spender, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public;
}


library ECRecovery {

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }
    
    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}

contract PayTalexnet is Ownable {
    using ECRecovery for bytes32;
    
    mapping(bytes32 => bool) public payList;

    event Trade(uint8 _vendor, bytes32 _tradeID);
    event Pay(uint8 _vendor, address _coin, uint256 _value, bytes32 _tradeID);
    event Multisended(address _token, uint256 _total);
    event Withdraw(address _to, address _token, uint256 _value);
    
    /**
     * Pay functions
    */
    function pay(uint8 _vendor, bytes32 _tradeID, uint256 _value, bytes calldata _sign) 
    payable external
    {
        require(msg.value > 0);
        require(msg.value == _value);
        bytes32 _hashPay = keccak256(abi.encodePacked(_vendor, _tradeID, _value));
        
        verifySign(_hashPay, _sign, _tradeID);
        payList[_tradeID] = true;
    
        emit Pay(_vendor, address(0x0), _value, _tradeID);
    }

    function payAltCoin(uint8 _vendor, address _coin, bytes32 _tradeID, uint256 _value, bytes calldata _sign) 
    external
    {
        bytes32 _hashPay = keccak256(abi.encodePacked(_vendor, _coin, _tradeID, _value));
        verifySign(_hashPay, _sign, _tradeID);
        payList[_tradeID] = true;
        
        require(safeTransferFrom(_coin, msg.sender, address(this), _value));
        emit Pay(_vendor, _coin, _value, _tradeID);
    }

    function verifySign(bytes32 _hashSwap, bytes memory _sign, bytes32 _tradeID) 
    private view
    {
        require(_hashSwap.recover(_sign) == signerAddress);
        require(!payList[_tradeID]);
    }
    
    /**
     * withdraw functions
    */
    function withdraw(address _token, address payable _to, uint256 _amount) 
    external onlyOwner
    {
        if (_token == address(0x0)) {
            _to.transfer(_amount);
        } else {
            require(safeTransfer(_token, _to, _amount));
        }
        emit Withdraw(_to, _token, _amount);
    }
    
    function multiTransfer(address _token, address payable[] calldata _addresses, uint256[] calldata _amounts)
    external onlyOwner
    {
        uint256 total = 0;
        uint8 i = 0;
        if (_token == address(0x0)) {
            for (i; i < _addresses.length; i++) {
                _addresses[i].transfer(_amounts[i]);
                total += _amounts[i];
            }
        } else {
            for (i; i < _addresses.length; i++) {
                require(safeTransfer(_token, _addresses[i], _amounts[i]));
                total += _amounts[i];
            }
        }
        
        emit Multisended(_token, total);
    }
    
    /**
     * secondary functions
    */
    function safeTransfer(address token, address to , uint value) private returns (bool result) 
    {
        TokenERC20(token).transfer(to,value);

        assembly {
            switch returndatasize()   
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        require(result);
    }
    
    function safeTransferFrom(address token, address _from, address to, uint value) private returns (bool result) 
    {
        TokenERC20(token).transferFrom(_from, to, value);

        assembly {
            switch returndatasize()   
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32) 
                    result := mload(0)
                }
                default {
                    revert(0, 0) 
                }
        }
        require(result);
    }
}