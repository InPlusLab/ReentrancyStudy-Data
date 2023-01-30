/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

// ----------------------------------------------------------------------------
// 'Highest Yield Farming Token' token contract
//
// Deployed to : 0x18952E93B560e73111B4B0B0399286D5FC94d954
// Symbol      : HYFT
// Name        : Highest Yield Farming Token
// Total supply: 50121
// Decimals    : 18
// Website      : https://hyft.finance/

// Enjoy.

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------

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

}

interface ItokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external returns (bool); 
}

interface IfarmingContract { 
    function createFarming(address _wallet, uint8 _timeFrame, uint256 _value) external returns (bool); 
}

interface IERC20Token {
    function totalSupply() external view returns (uint256 supply);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract Ownable {

    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }


    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

contract StandardToken is IERC20Token {
    
    using SafeMath for uint256;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    function totalSupply() override public view returns (uint256 supply) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) override virtual public returns (bool success) {
        require(_to != address(0x0), "Use burn function instead");                               // Prevent transfer to 0x0 address. Use burn() instead
		require(_value >= 0, "Invalid amount"); 
		require(balances[msg.sender] >= _value, "Not enough balance");
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) override virtual public returns (bool success) {
        require(_to != address(0x0), "Use burn function instead");                               // Prevent transfer to 0x0 address. Use burn() instead
		require(_value >= 0, "Invalid amount"); 
		require(balances[_from] >= _value, "Not enough balance");
		require(allowed[_from][msg.sender] >= _value, "You need to increase allowance");
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) override public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) override public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) override public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
}

contract HYFTToken is Ownable, StandardToken {

    using SafeMath for uint256;
    string public name;
    uint8 public decimals;
    string public symbol;
    address public farmingContract;
    address public crowdSaleContract;
    uint256 public soldTokensUnlockTime;
    mapping (address => uint256) frozenBalances;
    mapping (address => uint256) timelock;
    
    event Burn(address indexed from, uint256 value);
    event FarmingContractSet(address indexed contractAddress);

    
    constructor() {
        name = "Highest Yield Farming Token";
        decimals = 18;
        symbol = "HYFT";
        farmingContract = address(0x0);
        crowdSaleContract = 0x1b0a1fCDFF1184Fc6E6aD4bd607634De17b2d4d1;                 // contract for ICO tokens
        address teamWallet =  0xe325B214bFf4A0a9A480410cBeC66d35c46Ce020;               // wallet for team tokens
        address privateSaleWallet = 0x94580690A927D65DA7aE92a3748cbdD1C9d9A60B;         // wallet for private sale tokens
        address marketingWallet = 0x16526423eB37D2769edA746c687654879d750EdE;           // wallet for marketing
        address exchangesLiquidity = 0x25d776996373E607145Ef461586b3F7484315240;        // add liquidity to exchanges
        address farmingWallet = 0x2B88DF17E4B2F6a04C47195ed4e2959ccacE81cE;               // tokens for the farming contract
        uint256 teamReleaseTime = 1623261600;                                           // lock team tokens for 6 months
        uint256 farmingReleaseTime = 1610215200;                                         // lock farmingContract tokens - 13k tokens for 1 months

        balances[teamWallet] = 4000 ether;
        emit Transfer(address(0x0), teamWallet, (4000 ether));
        frozenBalances[teamWallet] = 4000 ether;
        timelock[teamWallet] = teamReleaseTime;
        
        balances[farmingWallet] = 13000 ether;
        emit Transfer(address(0x0), address(farmingWallet), (13000 ether));
        frozenBalances[farmingWallet] = 13000 ether;
        timelock[farmingWallet] = farmingReleaseTime;
        
        balances[marketingWallet] = 4121 ether;
        emit Transfer(address(0x0), address(marketingWallet), (4121 ether));
        
        balances[privateSaleWallet] = 3000 ether;
        emit Transfer(address(0x0), address(privateSaleWallet), (3000 ether));
        
        balances[crowdSaleContract] = 15000 ether;
        emit Transfer(address(0x0), address(crowdSaleContract), (15000 ether));

        balances[exchangesLiquidity] = 11000 ether;
        emit Transfer(address(0x0), address(exchangesLiquidity), (11000 ether));

        _totalSupply = 50121 ether;
        
        soldTokensUnlockTime = 1609085100;

    }
    
    function frozenBalanceOf(address _owner) public view returns (uint256 balance) {
        return frozenBalances[_owner];
    }
    
    function unlockTimeOf(address _owner) public view returns (uint256 time) {
        return timelock[_owner];
    }
    
    function transfer(address _to, uint256 _value) override public  returns (bool success) {
        require(txAllowed(msg.sender, _value), "Crowdsale tokens are still frozen");
        return super.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
        require(txAllowed(msg.sender, _value), "Crowdsale tokens are still frozen");
        return super.transferFrom(_from, _to, _value);
    }
    
    function setFarmingContract(address _contractAddress) onlyOwner public {
        farmingContract = _contractAddress;
        emit FarmingContractSet(_contractAddress);
    }
    
    function setCrowdSaleContract(address _contractAddress) onlyOwner public {
        crowdSaleContract = _contractAddress;
    }
    
        // Tokens sold by crowdsale contract will be frozen ultil crowdsale ends
    function txAllowed(address sender, uint256 amount) private returns (bool isAllowed) {
        if (timelock[sender] > block.timestamp) {
            return isBalanceFree(sender, amount);
        } else {
            if (frozenBalances[sender] > 0) frozenBalances[sender] = 0;
            return true;
        }
        
    }
    
    function isBalanceFree(address sender, uint256 amount) private view returns (bool isfree) {
        if (amount <= (balances[sender] - frozenBalances[sender])) {
            return true;
        } else {
            return false;
        }
    }
    
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Not enough balance");
		require(_value >= 0, "Invalid amount"); 
        balances[msg.sender] = balances[msg.sender].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    function approveFarming(uint8 _timeFrame, uint256 _value) public returns (bool success) {
        require(farmingContract != address(0x0));
        allowed[msg.sender][farmingContract] = _value;
        emit Approval(msg.sender, farmingContract, _value);
        IfarmingContract recipient = IfarmingContract(farmingContract);
        require(recipient.createFarming(msg.sender, _timeFrame, _value));
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        ItokenRecipient recipient = ItokenRecipient(_spender);
        require(recipient.receiveApproval(msg.sender, _value, address(this), _extraData));
        return true;
    }
    
    function tokensSold(address buyer, uint256 amount) public returns (bool success) {
        require(msg.sender == crowdSaleContract);
        frozenBalances[buyer] += amount;
        if (timelock[buyer] == 0 ) timelock[buyer] = soldTokensUnlockTime;
        return super.transfer(buyer, amount);
    }
    

}