/**
 *Submitted for verification at Etherscan.io on 2020-07-28
*/

/*
�����[     ���������������[�����[  �����[                         
�����U     �����X�T�T�T�T�a�^�����[�����X�a                         
�����U     �����������[   �^�������X�a                          
�����U     �����X�T�T�a   �����X�����[                          
���������������[���������������[�����X�a �����[                         
�^�T�T�T�T�T�T�a�^�T�T�T�T�T�T�a�^�T�a  �^�T�a                         
 �������������[ �����[   �����[�����[�����[     �������������[             
�����X�T�T�T�T�a �����U   �����U�����U�����U     �����X�T�T�����[            
�����U  �������[�����U   �����U�����U�����U     �����U  �����U            
�����U   �����U�����U   �����U�����U�����U     �����U  �����U            
�^�������������X�a�^�������������X�a�����U���������������[�������������X�a            
 �^�T�T�T�T�T�a  �^�T�T�T�T�T�a �^�T�a�^�T�T�T�T�T�T�a�^�T�T�T�T�T�a             
�����[      �������������[  �������������[�����[  �����[���������������[�������������[ 
�����U     �����X�T�T�T�����[�����X�T�T�T�T�a�����U �����X�a�����X�T�T�T�T�a�����X�T�T�����[
�����U     �����U   �����U�����U     �����������X�a �����������[  �������������X�a
�����U     �����U   �����U�����U     �����X�T�����[ �����X�T�T�a  �����X�T�T�����[
���������������[�^�������������X�a�^�������������[�����U  �����[���������������[�����U  �����U
�^�T�T�T�T�T�T�a �^�T�T�T�T�T�a  �^�T�T�T�T�T�a�^�T�a  �^�T�a�^�T�T�T�T�T�T�a�^�T�a  �^�T�a
DEAR MSG.SENDER(S):

/ LXGL is a project in beta.
// Please audit and use at your own risk.
/// Entry into LXGL shall not create an attorney/client relationship.
//// Likewise, LXGL should not be construed as legal advice or replacement for professional counsel.
///// STEAL THIS C0D3SL4W 

~presented by Open, ESQ || LexDAO LLC
*/

pragma solidity 0.5.17;

contract Context { // describes current contract execution context (metaTX support) / openzeppelin-contracts/blob/master/contracts/GSN/Context.sol
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath { // wrappers over solidity arithmetic operations with added overflow checks
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}

library Address { // helper for address type / openzeppelin-contracts/blob/master/contracts/utils/Address.sol
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

interface IERC20 { // brief interface for erc20 token txs
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library SafeERC20 { // wrappers around erc20 token txs that throw on failure (when the token contract returns false) / openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   function _callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: erc20 operation did not succeed");
        }
    }
}

interface IWETH { // brief interface for ether wrapping contract 
    function deposit() payable external;
    
    function transfer(address dst, uint wad) external returns (bool);
}

contract LexGuildLocker is Context { // splittable digital deal lockers w/ embedded arbitration tailored for guild raids
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /** <$> LXGL <$> **/
    address private bank = address(this);
    address public wETH = 0xd0A1E359811322d97991E03f863a0C30C2cF029C; // wrapping contract for raw payable ether (kovan)
    uint256 public lockerCount;
    mapping(uint256 => Locker) public lockers; 

    struct Locker {  
        address client; 
        address[] provider;
        address resolver;
        address token;
        uint8 confirmed;
        uint8 locked;
        uint256[] amount;
        uint256 cap;
        uint256 released;
        uint256 termination;
        bytes32 details; 
    }
    
    event RegisterLocker(address indexed client, address[] indexed provider, address indexed resolver, address token, uint256[] amount, uint256 cap, uint256 index, uint256 termination, bytes32 details);	
    event DepositLocker(uint256 indexed index, uint256 indexed sum);  
    event Release(uint256 indexed index, uint256[] indexed milestone); 
    event Withdraw(uint256 indexed index, uint256 indexed remainder);
    event Lock(address indexed sender, uint256 indexed index, bytes32 indexed details);
    event Resolve(address indexed resolver, uint256 indexed clientAward, uint256[] indexed providerAward, uint256 index, uint256 resolutionFee, bytes32 details); 

    /***************
    LOCKER FUNCTIONS
    ***************/
    function registerLocker( // register locker for token deposit and client deal confirmation
        address client,
        address[] calldata provider,
        address resolver,
        address token,
        uint256[] calldata amount, 
        uint256 cap,
        uint256 milestones,
        uint256 termination,
        bytes32 details) external returns (uint256) {
        uint256 sum;
        
        for (uint256 i = 0; i < provider.length; i++) {
            sum = sum.add(amount[i]);
        }
        
        require(sum.mul(milestones) == cap, "deposit milestones mismatch");
        
        lockerCount = lockerCount+1;
        uint256 index = lockerCount;
        
        lockers[index] = Locker( 
            client, 
            provider,
            resolver,
            token,
            0,
            0,
            amount,
            cap,
            0,
            termination,
            details);
        
        emit RegisterLocker(client, provider, resolver, token, amount, cap, index, termination, details); 
        return index;
    }
    
    function depositLocker(uint256 index) payable external { // client confirms deposit of cap and locks in deal
        Locker storage locker = lockers[index];
        
        require(locker.confirmed == 0, "already confirmed");
        require(_msgSender() == locker.client, "not locker client");
        
        uint256 sum = locker.cap;
        
        if (locker.token == wETH && msg.value > 0) {
            require(msg.value == sum, "insufficient ETH");
            IWETH(wETH).deposit();
            (bool success, ) = wETH.call.value(msg.value)("");
            require(success, "transfer failed");
            IWETH(wETH).transfer(bank, msg.value);
        } else {
            IERC20(locker.token).safeTransferFrom(msg.sender, bank, sum);
        }
        
        locker.confirmed = 1;
        
        emit DepositLocker(index, sum); 
    }

    function release(uint256 index) external { // client transfers locker amount(s) (milestone) to provider(s) 
    	Locker storage locker = lockers[index];
	    
	    require(locker.locked == 0, "locker locked");
	    require(locker.confirmed == 1, "locker unconfirmed");
	    require(locker.cap > locker.released, "locker released");
    	require(_msgSender() == locker.client, "not locker client"); 
        
        uint256[] memory milestone = locker.amount;
        
        for (uint256 i = 0; i < locker.provider.length; i++) {
            IERC20(locker.token).safeTransfer(locker.provider[i], milestone[i]);
            locker.released = locker.released.add(milestone[i]);
        }

	    emit Release(index, milestone); 
    }
    
    function withdraw(uint256 index) external { // withdraw locker remainder to client if termination time passes and no lock
    	Locker storage locker = lockers[index];
        
        require(locker.locked == 0, "locker locked");
        require(locker.confirmed == 1, "locker unconfirmed");
        require(locker.cap > locker.released, "locker released");
        require(now > locker.termination, "termination time pending");
        
        uint256 remainder = locker.cap.sub(locker.released); 
        
        IERC20(locker.token).safeTransfer(locker.client, remainder);
        
        locker.released = locker.released.add(remainder); 
        
	    emit Withdraw(index, remainder); 
    }
    
    /************
    ADR FUNCTIONS
    ************/
    function lock(uint256 index, bytes32 details) external { // client or (main) provider can lock remainder for resolution during locker period / update request details
        Locker storage locker = lockers[index]; 
        
        require(locker.confirmed == 1, "locker unconfirmed");
        require(locker.cap > locker.released, "locker released");
        require(now < locker.termination, "termination time passed"); 
        
        for (uint256 i = 0; i < locker.provider.length; i++) {
            require(_msgSender() == locker.client || _msgSender() == locker.provider[i], "not locker party"); 
        }

	    locker.locked = 1; 
	    
	    emit Lock(_msgSender(), index, details);
    }
    
    function resolve(uint256 index, uint256 clientAward, uint256[] calldata providerAward, bytes32 details) external { // resolver splits locked deposit remainder between client and (main) provider
        Locker storage locker = lockers[index];
        
        uint256 remainder = locker.cap.sub(locker.released); 
	    uint256 resolutionFee = remainder.div(20); // calculates dispute resolution fee (5% of remainder)
	    
	    require(locker.locked == 1, "locker not locked"); 
	    require(locker.cap > locker.released, "cap released");
	    require(_msgSender() == locker.resolver, "not locker resolver");
	    require(_msgSender() != locker.client, "cannot be locker client");
	    
	    for (uint256 i = 0; i < locker.provider.length; i++) {
            require(msg.sender != locker.provider[i], "cannot be locker provider");
            require(clientAward.add(providerAward[i]) == remainder.sub(resolutionFee), "resolution must match remainder");
            IERC20(locker.token).safeTransfer(locker.provider[i], providerAward[i]);
        }
  
        IERC20(locker.token).safeTransfer(locker.client, clientAward);
        IERC20(locker.token).safeTransfer(locker.resolver, resolutionFee);
	    
	    locker.released = locker.released.add(remainder); 
	    
	    emit Resolve(_msgSender(), clientAward, providerAward, index, resolutionFee, details);
    }
}