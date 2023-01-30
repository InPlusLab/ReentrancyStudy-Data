pragma solidity ^0.5.0;


import "./ERC20.sol";

/**
 * For full specification of ERC-20 standard see:
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract ZSMNToken is ERC20 {

    string private _name;
	
    string private _symbol;
	
    uint8 private _decimals;
	
	uint256 private _totalSupply;
	
	constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply, address tokenOwnerAddress) public payable {
      _name = name;
      _symbol = symbol;
      _decimals = decimals;
      _totalSupply = initialSupply * 10 ** uint256(decimals);
      
      _mint(tokenOwnerAddress, _totalSupply);

    }
    

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }


   
    // optional functions from ERC20 stardard

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
      return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
      return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
      return _decimals;
    }
}