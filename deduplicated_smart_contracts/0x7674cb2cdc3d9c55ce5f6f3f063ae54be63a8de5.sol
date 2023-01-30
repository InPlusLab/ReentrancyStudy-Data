/**

 *Submitted for verification at Etherscan.io on 2018-10-21

*/



pragma solidity ^0.4.19;



/* Function required from ERC20 main contract */

contract TokenERC20 {

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {}

}



contract MultiSend {

    TokenERC20 public _ERC20Contract;

    address public _multiSendOwner;

    

    function MultiSend () {

        address c = 0x803a145C977C2F2AC26CdbD165A2D873485fdbd0; // set ERC20 contract address

        _ERC20Contract = TokenERC20(c); 

        _multiSendOwner = msg.sender;

    }

    

    /* Make sure you allowed this contract enough ERC20 tokens before using this function

    ** as ERC20 contract doesn't have an allowance function to check how much it can spend on your behalf

    ** Use function approve(address _spender, uint256 _value)

    */

    function dropCoins(address[] dests, uint256 tokens) {

        require(msg.sender == _multiSendOwner);

        uint256 amount = tokens;

        uint256 i = 0;

        while (i < dests.length) {

            _ERC20Contract.transferFrom(_multiSendOwner, dests[i], amount);

            i += 1;

        }

    }

    

}