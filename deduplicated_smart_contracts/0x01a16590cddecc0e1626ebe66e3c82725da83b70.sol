/**
 *  $$$$$$\  $$\                 $$\                           
 * $$  __$$\ $$ |                $$ |                          
 * $$ /  \__|$$$$$$$\   $$$$$$\  $$ |  $$\  $$$$$$\   $$$$$$\  
 * \$$$$$$\  $$  __$$\  \____$$\ $$ | $$  |$$  __$$\ $$  __$$\ 
 *  \____$$\ $$ |  $$ | $$$$$$$ |$$$$$$  / $$$$$$$$ |$$ |  \__|
 * $$\   $$ |$$ |  $$ |$$  __$$ |$$  _$$<  $$   ____|$$ |      
 * \$$$$$$  |$$ |  $$ |\$$$$$$$ |$$ | \$$\ \$$$$$$$\ $$ |      
 *  \______/ \__|  \__| \_______|\__|  \__| \_______|\__|
 * $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
 * ____________________________________________________________
*/

pragma solidity >=0.4.23 <0.6.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

contract BTCHToken is ERC20, ERC20Detailed {
    address public authorizedContract;
    address public operator;
    uint256 public maxSupply = 36000000 * 10 ** 6;
    
    constructor (address _authorizedContract) public ERC20Detailed("BitCheck DAO", "BTCH", 6) {
        // Decimal is 6
        operator = msg.sender;
        authorizedContract = _authorizedContract;
        // zero pre-mine
    }
    
    modifier onlyOperator {
        require(msg.sender == operator, "Only operator can call this function.");
        _;
    }

    modifier onlyAuthorizedContract {
        require(msg.sender == authorizedContract, "Only authorized contract can call this function.");
        _;
    }

    function mint(address account, uint256 amount) public onlyAuthorizedContract {
        if(_totalSupply.add(amount) > maxSupply) amount = _totalSupply.add(amount).sub(maxSupply);
        if(amount > 0) _mint(account, amount);
    }
    
    function burn(address account, uint256 amount) public onlyAuthorizedContract {
        if(_totalSupply < amount) amount = amount.sub(_totalSupply);
        if(amount > 0) _burn(account, amount);
    }
    
    function updateOperator(address _newOperator) external onlyOperator {
        require(_newOperator != address(0));
        operator = _newOperator;
    }
    
    function updateAuthorizedContract(address _authorizedContract) external onlyOperator {
        require(_authorizedContract != address(0));
        authorizedContract = _authorizedContract;
    }

}