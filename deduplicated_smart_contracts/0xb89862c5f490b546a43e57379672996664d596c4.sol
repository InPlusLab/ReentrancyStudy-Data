pragma solidity ^0.5.0;



import "./ERC20.sol";

import "./ERC20Detailed.sol";

import "./ERC20Mintable.sol";



contract dlToken is ERC20, ERC20Detailed, ERC20Mintable {



    constructor(

        string memory name,

        string memory symbol,

        uint8 decimals

    )

        ERC20Mintable()

        ERC20Detailed(name, symbol, decimals)

        ERC20()

        public

    {}

}