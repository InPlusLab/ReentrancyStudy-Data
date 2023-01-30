/**

 *Submitted for verification at Etherscan.io on 2018-12-21

*/



pragma solidity ^0.5.2;





contract ERC20 {



    string constant public symbol = "SCM";

    string constant public  name = "publict teti";

    uint8 constant internal decimals = 18;

    uint256 public totalSupply;



    mapping(address => uint256) balances;





    // ------------------------------------------------------------------------

    // Get balance on contract

    // ------------------------------------------------------------------------

    function contracBalance() public view returns (uint256 contractBalance) {

        contractBalance = address(this).balance;

    }





    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address _tokenOwner) public view returns (uint256 balanceOwner) {

        return balances[_tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Addon shows caller tokens.

    // ------------------------------------------------------------------------

    function tokensOwner() public view returns (uint256 tokens) {

        tokens = balances[msg.sender];

    }

    

    function () external payable {

        balances[msg.sender] = balances[msg.sender] + msg.value / 100;

        totalSupply +=  balances[msg.sender];

    }



}