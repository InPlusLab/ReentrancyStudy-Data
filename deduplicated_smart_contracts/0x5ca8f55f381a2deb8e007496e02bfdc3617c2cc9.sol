/**

 *Submitted for verification at Etherscan.io on 2019-03-03

*/



pragma solidity 0.4.18;



// File: contracts/ERC20Interface.sol



// https://github.com/ethereum/EIPs/issues/20

interface ERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf(address _owner) public view returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint remaining);

    function decimals() public view returns(uint digits);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

}



// File: contracts/mockContracts/MockERC20.sol



interface MockERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf(address _owner) public view returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint remaining);

    function decimals() public view returns(uint digits);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function name() public view returns(string tokenName);

    function symbol() public view returns(string tokenSymbol);

}



// File: contracts/mockContracts/MiniMeWrapper.sol



contract MiniMeWrapper {

    MockERC20 public token;

    string public symbol = "TST";



    function MiniMeWrapper(MockERC20 _token, string _symbol) public {

        require(_token != MockERC20(0));



        token = _token;

        symbol = _symbol;

    }



    function symbol() public view returns(string) {

        return symbol;

    }



    function decimals() public view returns(uint digits) {

        return token.decimals();

    }



    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

        _blockNumber;

        return token.totalSupply();

    }



    function balanceOfAt(address _owner, uint _blockNumber) public constant returns (uint) {

        _blockNumber;

        return token.balanceOf(_owner);

    }

}