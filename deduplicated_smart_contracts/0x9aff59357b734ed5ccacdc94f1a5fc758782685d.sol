pragma solidity ^0.5.0;



import "./ERC20Detailed.sol";



import "./ERC20.sol";



contract BuildCoin is ERC20, ERC20Detailed {



    uint8 public constant DECIMALS = 18;



    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(DECIMALS));



        constructor() public ERC20Detailed("Build Coin", "BILDX", DECIMALS) {



        _mint(msg.sender, INITIAL_SUPPLY);



    }



}