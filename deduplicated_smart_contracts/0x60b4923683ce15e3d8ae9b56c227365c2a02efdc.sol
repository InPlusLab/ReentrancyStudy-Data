/**

 *Submitted for verification at Etherscan.io on 2018-10-22

*/



pragma solidity ^0.4.24;



// ----------------------------------------------------------------------------

    // TESTING Token contract

    //

    // Deployed to : 0x1f110ae196e7e27b302c2e902ed16b4d3fe07224

    // Symbol      : $Test

    // Name        : TESTING Token

    // Total supply: 10000000000000000

    // Decimals    : 10

    //

    // Enjoy.

    //

    // (c) by Moritz Neto with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.

    // ----------------------------------------------------------------------------





contract SafeMath {

    

    function safeAdd(uint a, uint b) public pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    

    function safeSub(uint a, uint b) public pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }



    function safeMul(uint a, uint b) public pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    

    function safeDiv(uint a, uint b) public pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}





contract ERC20Token is SafeMath {



    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint)) allowed;

    uint _totalSupply;

    

    function totalSupply() public constant returns (uint) {

        return _totalSupply  - balances[address(0)];

    }



    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }



    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = safeSub(balances[msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }



    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }



    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = safeSub(balances[from], tokens);

        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        emit Transfer(from, to, tokens);

        return true;

    }



    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    

}



contract Owned {

    

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);

    

    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}



contract  TESTING_Token is ERC20Token, Owned {



    string public symbol;

    string public  name;

    uint public decimals;

    address public crowdsaleAddress;

    uint public ICOEndTime = 0;



   modifier onlyCrowdsale {

      require(msg.sender == crowdsaleAddress);

      _;

   }



   modifier afterCrowdsale {

      require(now > ICOEndTime || msg.sender == crowdsaleAddress);

      _;

   }

   

  constructor () public {



      symbol = "$Test";

      name = "TESTING Token";

      decimals = 10;

      _totalSupply = 10000000000000000;

      owner = msg.sender;

      balances[msg.sender] = _totalSupply;

   }

   

    function transfer(address to, uint tokens) public afterCrowdsale returns (bool) {

        super.transfer(to,tokens);

    }



    function transferFrom(address from, address to, uint tokens) public afterCrowdsale returns (bool) {

        super.transferFrom(from,to,tokens);

    }



    function emergencyExtract() external onlyOwner {

        owner.transfer(address(this).balance);

    }

    

   function setICOEndtime(uint time) public onlyOwner {

        require(ICOEndTime>0);

        ICOEndTime = time;

   }



   function setCrowdsale(address _crowdsaleAddress) public onlyOwner {

      require(_crowdsaleAddress != address(0));

      crowdsaleAddress = _crowdsaleAddress;

   }



   function releaseTokens(address _receiver, uint256 _amount) public onlyCrowdsale {

      require(_receiver != address(0));

      require(_amount > 0);

      transfer(_receiver, _amount);

   }

}