/**
 *Submitted for verification at Etherscan.io on 2019-07-15
*/

pragma solidity ^0.4.16;

/*
OTOMAIN Token details :

Name            : OTOMAIN 
Symbol          : OTO 
Total Supply    : 250.000.000.000 OTO
Decimals        : 18 
Mainweb         : https://www.otomain.com

Total Supply  : 250.000.000.000
Total for Tokensale  : 150.000.000.000 OTO
Future development : 50.000.000.000 OTO
Team  :   25.000.000.000 OTO 
Promotion and Airdrop  :   25.000.000.000 OTO

* No Minimum contribution on OTOMAIN Tokensale
Send ETH To Contract Address you will get OTO Token directly

** Don't send ETH Directly From Exchange Like Binance , Bittrex , Okex etc or you will lose your fund !!

A Wallett Address can make more than once transaction on tokensale

You can also get OTO airdrop with send 0 ETH to contract address , you will get some OTO Token directly

Set GAS Limits 150.000 and GAS Price always check on ethgasstation.info (use Standard Gas Price or Fast Gas Price)

Unsold token will Burned 

*/

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract OTO {
    // Public variables of the token
    string public name = "OTOMAIN";
    string public symbol = "OTO";
    uint8 public decimals = 18;
    // Decimals = 18
    uint256 public totalSupply;
    uint256 public otoSupply = 250000000000;
    uint256 public buyPrice = 100000000;
    address public creator;
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function OTO() public {
        totalSupply = otoSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;    // Give OTO Token the total created tokens
        creator = msg.sender;
    }
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0); //Burn
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
      
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    
    
    /// @notice Buy tokens from contract by sending ethereum to contract address with no minimum contribution
    function () payable internal {
        uint amount = msg.value * buyPrice +100000e18 ;                    // calculates the amount
        uint amountRaised;                                     
        amountRaised += msg.value;                            
        require(balanceOf[creator] >= amount);               
        require(msg.value >=0);                        
        balanceOf[msg.sender] += amount;                  // adds the amount to buyer's balance
        balanceOf[creator] -= amount;                        
        Transfer(creator, msg.sender, amount);               
        creator.transfer(amountRaised);
    }    
    
 }