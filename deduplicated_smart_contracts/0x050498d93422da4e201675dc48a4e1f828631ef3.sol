/**

 *Submitted for verification at Etherscan.io on 2018-09-05

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: contracts/ext/CheckedERC20.sol



library CheckedERC20 {

    using SafeMath for uint;



    function checkedTransfer(ERC20 _token, address _to, uint256 _value) internal {

        if (_value == 0) {

            return;

        }

        uint256 balance = _token.balanceOf(this);

        _token.transfer(_to, _value);

        require(_token.balanceOf(this) == balance.sub(_value), "checkedTransfer: Final balance didn't match");

    }



    function checkedTransferFrom(ERC20 _token, address _from, address _to, uint256 _value) internal {

        if (_value == 0) {

            return;

        }

        uint256 toBalance = _token.balanceOf(_to);

        _token.transferFrom(_from, _to, _value);

        require(_token.balanceOf(_to) == toBalance.add(_value), "checkedTransfer: Final balance didn't match");

    }

}



// File: contracts/interface/IBasicMultiToken.sol



contract IBasicMultiToken is ERC20 {

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);

    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);



    function tokensCount() public view returns(uint256);

    function tokens(uint256 _index) public view returns(ERC20);

    function allTokens() public view returns(ERC20[]);

    function allDecimals() public view returns(uint8[]);

    function allBalances() public view returns(uint256[]);

    function allTokensDecimalsBalances() public view returns(ERC20[], uint8[], uint256[]);



    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;

    function bundle(address _beneficiary, uint256 _amount) public;



    function unbundle(address _beneficiary, uint256 _value) public;

    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;



    function denyBundling() public;

    function allowBundling() public;

}



// File: contracts/interface/IMultiToken.sol



contract IMultiToken is IBasicMultiToken {

    event Update();

    event Change(address indexed _fromToken, address indexed _toToken, address indexed _changer, uint256 _amount, uint256 _return);



    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256 returnAmount);

    function change(address _fromToken, address _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 returnAmount);



    function allWeights() public view returns(uint256[] _weights);

    function allTokensDecimalsBalancesWeights() public view returns(ERC20[] _tokens, uint8[] _decimals, uint256[] _balances, uint256[] _weights);



    function denyChanges() public;

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    require(token.transfer(to, value));

  }



  function safeTransferFrom(

    ERC20 token,

    address from,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transferFrom(from, to, value));

  }



  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    require(token.approve(spender, value));

  }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

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

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

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



// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol



/**

 * @title Contracts that should be able to recover tokens

 * @author SylTi

 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.

 * This will prevent any accidental loss of tokens.

 */

contract CanReclaimToken is Ownable {

  using SafeERC20 for ERC20Basic;



  /**

   * @dev Reclaim all ERC20Basic compatible tokens

   * @param token ERC20Basic The address of the token contract

   */

  function reclaimToken(ERC20Basic token) external onlyOwner {

    uint256 balance = token.balanceOf(this);

    token.safeTransfer(owner, balance);

  }



}



// File: contracts/registry/MultiChanger.sol



contract IBancorNetwork {

    function convert(

        address[] _path,

        uint256 _amount,

        uint256 _minReturn

    ) 

        public

        payable

        returns(uint256);



    function claimAndConvert(

        address[] _path,

        uint256 _amount,

        uint256 _minReturn

    ) 

        public

        payable

        returns(uint256);

}



contract IKyberNetworkProxy {

    function trade(

        address src,

        uint srcAmount,

        address dest,

        address destAddress,

        uint maxDestAmount,

        uint minConversionRate,

        address walletId

    )

        public

        payable

        returns(uint);

}





contract MultiChanger is CanReclaimToken {

    using SafeMath for uint256;



    // https://github.com/Arachnid/solidity-stringutils/blob/master/src/strings.sol#L45

    function memcpy(uint dest, uint src, uint len) private pure {

        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }

    }



    function subbytes(bytes _data, uint _start, uint _length) private pure returns(bytes) {

        bytes memory result = new bytes(_length);

        uint from;

        uint to;

        assembly { 

            from := add(_data, _start) 

            to := result

        }

        memcpy(to, from, _length);

    }



    function change(

        bytes _callDatas,

        uint[] _starts // including 0 and LENGTH values

    )

        internal

    {

        for (uint i = 0; i < _starts.length - 1; i++) {

            bytes memory data = subbytes(

                _callDatas,

                _starts[i],

                _starts[i + 1] - _starts[i]

            );

            require(address(this).call(data));

        }

    }



    function sendEthValue(address _target, bytes _data, uint256 _value) external {

        require(_target.call.value(_value)(_data));

    }



    function sendEthProportion(address _target, bytes _data, uint256 _mul, uint256 _div) external {

        uint256 value = address(this).balance.mul(_mul).div(_div);

        require(_target.call.value(value)(_data));

    }



    function approveTokenAmount(address _target, bytes _data, ERC20 _fromToken, uint256 _amount) external {

        if (_fromToken.allowance(this, _target) != 0) {

            _fromToken.approve(_target, 0);

        }

        _fromToken.approve(_target, _amount);

        require(_target.call(_data));

    }



    function approveTokenProportion(address _target, bytes _data, ERC20 _fromToken, uint256 _mul, uint256 _div) external {

        uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);

        if (_fromToken.allowance(this, _target) != 0) {

            _fromToken.approve(_target, 0);

        }

        _fromToken.approve(_target, amount);

        require(_target.call(_data));

    }



    function transferTokenAmount(address _target, bytes _data, ERC20 _fromToken, uint256 _amount) external {

        _fromToken.transfer(_target, _amount);

        require(_target.call(_data));

    }



    function transferTokenProportion(address _target, bytes _data, ERC20 _fromToken, uint256 _mul, uint256 _div) external {

        uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);

        _fromToken.transfer(_target, amount);

        require(_target.call(_data));

    }



    // Bancor Network



    function bancorSendEthValue(IBancorNetwork _bancor, address[] _path, uint256 _value) external {

        _bancor.convert.value(_value)(_path, _value, 1);

    }



    function bancorSendEthProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {

        uint256 value = address(this).balance.mul(_mul).div(_div);

        _bancor.convert.value(value)(_path, value, 1);

    }



    function bancorApproveTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {

        if (ERC20(_path[0]).allowance(this, _bancor) == 0) {

            ERC20(_path[0]).approve(_bancor, uint256(-1));

        }

        _bancor.claimAndConvert(_path, _amount, 1);

    }



    function bancorApproveTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {

        uint256 amount = ERC20(_path[0]).balanceOf(this).mul(_mul).div(_div);

        if (ERC20(_path[0]).allowance(this, _bancor) == 0) {

            ERC20(_path[0]).approve(_bancor, uint256(-1));

        }

        _bancor.claimAndConvert(_path, amount, 1);

    }



    function bancorTransferTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {

        ERC20(_path[0]).transfer(_bancor, _amount);

        _bancor.convert(_path, _amount, 1);

    }



    function bancorTransferTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {

        uint256 amount = ERC20(_path[0]).balanceOf(this).mul(_mul).div(_div);

        ERC20(_path[0]).transfer(_bancor, amount);

        _bancor.convert(_path, amount, 1);

    }



    function bancorAlreadyTransferedTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {

        _bancor.convert(_path, _amount, 1);

    }



    function bancorAlreadyTransferedTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {

        uint256 amount = ERC20(_path[0]).balanceOf(_bancor).mul(_mul).div(_div);

        _bancor.convert(_path, amount, 1);

    }



    // Kyber Network



    function kyberSendEthProportion(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _mul, uint256 _div) external {

        uint256 value = address(this).balance.mul(_mul).div(_div);

        _kyber.trade.value(value)(

            _fromToken,

            value,

            _toToken,

            this,

            1 << 255,

            0,

            0

        );

    }



    function kyberApproveTokenAmount(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _amount) external {

        if (_fromToken.allowance(this, _kyber) == 0) {

            _fromToken.approve(_kyber, uint256(-1));

        }

        _kyber.trade(

            _fromToken,

            _amount,

            _toToken,

            this,

            1 << 255,

            0,

            0

        );

    }



    function kyberApproveTokenProportion(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _mul, uint256 _div) external {

        uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);

        this.kyberApproveTokenAmount(_kyber, _fromToken, _toToken, amount);

    }

}



// File: contracts/registry/MultiSeller.sol



contract MultiSeller is MultiChanger {

    using CheckedERC20 for ERC20;

    using CheckedERC20 for IMultiToken;



    function() public payable {

        require(tx.origin != msg.sender);

    }



    function sellForOrigin(

        IMultiToken _mtkn,

        uint256 _amount,

        bytes _callDatas,

        uint[] _starts // including 0 and LENGTH values

    )

        public

    {

        sell(

            _mtkn,

            _amount,

            _callDatas,

            _starts,

            tx.origin

        );

    }



    function sell(

        IMultiToken _mtkn,

        uint256 _amount,

        bytes _callDatas,

        uint[] _starts, // including 0 and LENGTH values

        address _for

    )

        public

    {

        _mtkn.transferFrom(msg.sender, this, _amount);

        _mtkn.unbundle(this, _amount);

        change(_callDatas, _starts);

        _for.transfer(address(this).balance);

    }

}