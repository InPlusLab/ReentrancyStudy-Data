/**
 *Submitted for verification at Etherscan.io on 2020-07-24
*/

// Henry Harder (2020) -- use at your peril

pragma solidity ^0.5.0;

contract GST {
	function freeFromUpTo(address from, uint256 value) public returns (uint256 freed);
}

contract Token {
    function transfer(address _to, uint256 _value) public returns (bool ok);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool ok);
    function balanceOf(address _wad) public returns (uint256 balance);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

contract GasWallet {
    
    event Spawned(address me);      // Emitted on construction
    event UserChanged(address who); // User is changed to new address
    
    // Maximum ERC-20 allowance
    uint256 public constant MAX_ALLOWANCE = (2 ** 256) - 1;
    
    // In emergencies, can be disabled and only the excape functions will work
    bool public enabled = true;
    
    // Admin doesn't change
    // Escaped funds go to admin
    address payable constant admin = 0xBb4068bac37ef5975210fA0cf03C0984f2D1542c;
    
    // User can call authorized methods and can be changed by the user or the admin
    address payable user = 0xA916B82Ff122591cC88AaC0D64cE30A8e3e16081;
    
    // Gas token (CHI) doesn't change
    GST constant chi = GST(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    
    // Wallet to burn gas tokens from (defaults to self)
    address public gasHolder;
    
    // Burn CHI gas tokens, if possible
    modifier discount {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        chi.freeFromUpTo(address(this), (gasSpent + 14154) / 41947);
    }
    
    // Allow the user or the admin to call the function
    modifier auth {
        require(msg.sender == admin || msg.sender == user, "auth");
        _;
    }
    
    // Require the contract is enabled
    modifier notDisabled {
        require(enabled, "notDisabled");
        _;
    }
    
    constructor() public {
        gasHolder = address(this);
        
        emit Spawned(address(this));
        emit UserChanged(user);
    }
    
    // Burn gas tokens from the contract or abitrary wallet (allowance must be set)
    function setGasHolder(address holder) public auth discount notDisabled {
        gasHolder = holder;
    }
    
    // Set an ERC-20 approval for who to spend amt of tkn.
    // If amt is 0, an "unlimited" approval will be set.
    // To remove an allowance, use revokeTokenApproval
    function setTokenApproval(address tkn, address who, uint256 amt) public auth discount notDisabled {
        if (amt == 0) {
            amt = MAX_ALLOWANCE;
        }
        Token token = Token(tkn);
        token.approve(who, amt);
    }
    
    // Remove allowance for who to spend tkn from this
    function revokeTokenApproval(address tkn, address who) public auth discount notDisabled {
        Token token = Token(tkn);
        token.approve(who, 0);
    }
    
    // Change the user to a new address
    function setUser(address payable who) public auth discount notDisabled {
        emit UserChanged(who);
        user = who;
    }

    // Send the full contracts balance of any ERC-20 token back to the admin    
    function escapeToken(address tkn) public auth discount {
        Token token = Token(tkn);
        token.transfer(admin, token.balanceOf(address(this)));
    }
    
    // Send the admin all ETH in the contract
    function escapeEther() public auth discount {
        admin.transfer(address(this).balance);
    }
    
    // Disable further proxy transactions (cannot be re-enabled)
    // Funds can still be escaped once disabled
    function disable() public auth notDisabled {
        enabled = false;
    }
    
    // Deploy a contract (discount costs with CHI)
    function deploy(bytes memory dta) public auth discount returns(address ctc) {
        assembly {
            ctc := create(0, add(dta, 32), mload(dta))
        }
    }
    
    // Execute a transaction from the gas wallet
    // tgt: the target address to call
    // val: the wei value to include with the transaction
    // dat: calldata to include with the transaction
    function execute(
        address tgt,
        uint256 val,
        bytes memory dat
    ) payable public auth discount notDisabled returns (bytes memory){
         (bool ok, bytes memory ret) = tgt.call.value(val)(dat);
        require(ok, "tx_revert");
        return ret;
    }
    
    // Allow the contract to receive ETH from anyone
    function() payable external {}
}