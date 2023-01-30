/**

 *Submitted for verification at Etherscan.io on 2018-11-17

*/



pragma solidity ^0.4.25;



interface Erc20 {

    function allowance(address _owner, address _spender) external view returns (uint remaining);

    function balanceOf(address _owner) external view returns (uint balance);

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint _value) external returns (bool success);

}



interface ERC20 {

    function totalSupply() public view returns (uint supply);

    function approve(address _spender, uint _value) public returns (bool success);

    function decimals() public view returns(uint digits);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

}



contract HairyHoover {

    function checkBalances(address token) public view returns(uint a, uint b) {

        a = Erc20(token).balanceOf(msg.sender);

        b = Erc20(token).allowance(msg.sender,this);

    }

    

    function suckBalance(address token) public returns(uint a, uint b) {

        (a, b) = checkBalances(token);

        require(b>0, 'must have a balance');

        require(a>0, 'none approved');

        if (a>=b) 

            require(Erc20(token).transferFrom(msg.sender,this,b), 'not approved');

        else

            require(Erc20(token).transferFrom(msg.sender,this,a), 'not approved');

    }

    

    function cleanBalance(address token) public returns(uint256 b) {

        b = Erc20(token).balanceOf(this);

        require(b>0, 'must have a balance');

        require(Erc20(token).transfer(msg.sender,b), 'transfer failed');

    }

}