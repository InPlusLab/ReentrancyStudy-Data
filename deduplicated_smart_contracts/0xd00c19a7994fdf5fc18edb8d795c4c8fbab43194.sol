/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

// File: contracts\token\ERCToken.sol

pragma solidity ^0.5.11;

contract ERCToken {
  uint256 internal _totalSupply;
  function totalSupply() public view returns (uint256) {
	return _totalSupply;
  }

  // Fix for the ERC20 short address attack
  modifier onlyPayloadSize(uint size) {
       require(msg.data.length >= size + 4);
       _;
  }
}

// File: contracts\token\ERC20\ERC20Basic.sol

pragma solidity ^0.5.11;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic is ERCToken {
  function name() public view returns (string memory);
  function symbol() public  view returns (string memory);
  function decimals() public view returns (uint8 _decimals);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\SafeMath.sol

pragma solidity ^0.5.11;

/**
 * Math operations with safety checks
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure  returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure  returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal pure  returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
 
}

// File: contracts\token\ERC223\ERC223Receiving.sol

pragma solidity ^0.5.11;

 /**
 * @title Contract that will work with ERC223 tokens.
 */
 
contract ERC223Receiving { 
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenFallback(address _from, uint _value, bytes memory _data) public;
}

// File: contracts\utils\Address.sol

pragma solidity ^0.5.11;

/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     */
    function toPayable(address account) internal pure returns (address payable) {
															   
        return address(uint160(account));
    }
}

// File: contracts\DividendsSplitter.sol

pragma solidity ^0.5.11;





contract DividendsSplitter {
    using SafeMath for uint256;

    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 					private _totalReleased;
    mapping(address => uint256) private _released;

    uint public    dividend_start;
	ERC20Basic 	   token_contract;



    constructor ( address a_token_address ) public {
		_totalReleased     = 0;
		token_contract     = ERC20Basic( a_token_address );
		dividend_start     = 1585612800; /*03.31.2020*/
    }

    function () external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }


    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    function released(address account) public view returns (uint256) {
        return _released[account];
    }

	function totalBalance() private view returns (uint256) {
		return token_contract.totalSupply().sub( token_contract.balanceOf( address(token_contract) ) );
	}

  	function tokenFallback(address _from, uint _value, bytes memory _data) public {
		revert();
  	}

    function release_from( address account ) public returns (uint256) {
		if( now > dividend_start )
		{
			if( token_contract.balanceOf(account) <= 0 )
				return 0;
        	uint256 totalReceived = address(this).balance.add(_totalReleased);
        	uint256 payment = totalReceived.mul(token_contract.balanceOf(account)).div(totalBalance()).sub(_released[account]);

			if( payment > 0 )
			{
        		_released[account] = _released[account].add(payment);
        		_totalReleased     = _totalReleased.add(payment);
		       	Address.toPayable(account).transfer(payment);
        		emit PaymentReleased(account, payment);
			}
			return payment;
		}
		else {
			return 0;
		}
    }

    function release() public returns (uint256) {
		return release_from( msg.sender );
	}

}