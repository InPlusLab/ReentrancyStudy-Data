pragma solidity ^0.4.21;


contract Platform
{
    address public platform = 0x709a0A8deB88A2d19DAB2492F669ef26Fd176f6C;

    modifier onlyPlatform() {
        require(msg.sender == platform);
        _;
    }

    function isPlatform() public view returns (bool) {
        return platform == msg.sender;
    }
}


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract BeneficiaryInterface
{
    function getAvailableWithdrawInvestmentsForBeneficiary() public view returns (uint);
    function withdrawInvestmentsBeneficiary(address withdraw_address) public returns (bool);
}


//§ª§ß§ä§Ö§â§æ§Ö§Û§ã §Õ§Ý§ñ ICO §Ü§à§ß§ä§â§Ñ§Ü§ä§à§Ó, §é§ä§à§Ò§í §ä§Ö §Þ§à§Ô§Ý§Ú §Ô§à§Ó§à§â§Ú§ä§î CNRToken-§å
//§à §ä§à§Þ §é§ä§à §Ö§Þ§å §á§Ö§â§Ö§Ó§Ö§Ý§Ú §Ò§Ñ§Ò§Ü§Ú
contract CNRAddBalanceInterface
{
    function addTokenBalance(address, uint) public;
}


//§ª§ß§ä§Ö§â§æ§Ö§Û§ã §Õ§Ý§ñ §æ§Ñ§Ò§â§Ú§Ü§Ú, §é§ä§à§Ò§í §à§ß§Ñ §Þ§à§Ô§Ý§Ñ §Õ§à§Ò§Ñ§Ó§Ý§ñ§ä§î §ä§à§Ü§Ö§ß§í
contract CNRAddTokenInterface
{
    function addTokenAddress(address) public;
}

//TODO: §Þ§à§Ø§Ö§ä §ã§Õ§Ö§Ý§Ñ§ä§î §Ü§Ý§Ñ§ã§ã TokensCollection, §Ü§å§Õ§Ñ §Ó§í§ß§Ö§ã§ä§Ú §Ó§ã§ð §æ§å§ß§Ü§è§Ú§à§ß§Ñ§Ý§î§ß§à§ã§ä§î §Ú§Ù  tokens_map, tokens_arr §Ú§ä§Õ
contract CNRToken is ERC20, CNRAddBalanceInterface, CNRAddTokenInterface, Platform
{
    using SafeMath for uint256;


    //§´§à§Ü§Ö§ß  ERC20
    string public constant name = "ICO Constructor token";
    string public constant symbol = "CNR";
    uint256 public constant decimals = 18;


    //-------------------------ERC20 interface----------------------------------
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => uint256) balances;
    ////////////////////////////ERC20 interface/////////////////////////////////

    //§¡§Õ§â§Ö§ã §Ô§â§Ñ§ß§Õ §æ§Ñ§Ò§â§Ú§Ü§Ú
    address public grand_factory = address(0);

    //§®§Ñ§á§Ñ §Ú §Þ§Ñ§ã§ã§Ú§Ó §Õ§à§Ò§Ñ§Ó§Ý§Ö§ß§ß§ç §ä§à§Ü§Ö§ß§à§Ó. §¯§å§Ý§Ö§Ó§à§Û §ï§Ý§Ö§Þ§Ö§ß§ä  §Ù§Ñ§â§Ö§Ù§Ö§â§Ó§Ú§â§à§Ó§Ñ§ß §Õ§Ý§ñ
    //§ï§æ§Ú§â§Ñ. §°§ã§ä§Ñ§Ý§î§ß§í§Ö §Õ§Ý§ñ §ä§à§Ü§Ö§ß§à§Ó
    mapping(address => uint256) public  tokens_map;
    TokenInfo[] public                  tokens_arr;

    //§®§Ñ§á§Ñ §ã §Ù§Ñ§Ò§â§Ñ§ß§ß§í§Þ§Ú §ã§å§ë§ß§à§ã§ä§ñ§Þ§Ú (§ï§æ§Ú§â§à§Þ, §ä§à§Ü§Ö§ß§Ñ§Þ§Ú). (§Ñ§Õ§â§Ö§ã §Ü§à§ê§Ö§Ý§î§Ü§Ñ §Ü§Ý§Ú§Ö§ß§ä§Ñ => (§Ú§ß§Õ§Ö§Ü§ã §ä§à§Ü§Ö§ß§Ñ => §ã§Ü§à§Ý§î§Ü§à §å§Ø§Ö §Ù§Ñ§Ò§â§Ñ§Ý))
    //§±§à §Ú§ß§Õ§Ö§Ü§ã§å 0 - §Ó§ã§Ö§Ô§Õ§Ñ §ï§æ§Ú§â.
    mapping(address => mapping(uint => uint)) withdrawns;

    function CNRToken() public
    {
        totalSupply = 10*1000*1000*(10**decimals); // 10 mln
        balances[msg.sender] = totalSupply;

        //§¯§Ñ §ß§å§Ý§Ö§Ó§à§Þ §Ú§ß§Õ§Ö§Ü§ã§Ö §ß§Ñ§ç§à§Õ§Ú§ä§ã§ñ §ï§æ§Ú§â
        tokens_arr.push(
            TokenInfo(
                address(0),
                0));
    }


    //§¶§å§ß§Ü§è§Ú§ñ §á§à§Ý§å§é§Ö§ß§Ú§ñ §Ñ§Õ§â§Ö§ã§à§Ó §Ó§ã§Ö§ç §Õ§à§Ò§Ñ§Ó§Ý§Ö§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó
    function getRegisteredTokens()
    public view
    returns (address[])
    {
        // §ã§Ú§ä§å§Ñ§è§Ú§ñ, §Ü§à§Ô§Õ§Ñ §ß§Ö §Õ§à§Ò§Ñ§Ó§Ý§Ö§ß§í §ä§à§Ü§Ö§ß§í. <= §é§ä§à§Ò§í §å§Ò§â§Ñ§ä§î §á§â§Ö§Õ mythril,
        // §Ü§à§ä§à§â§í§Û §ß§Ö §á§à§ß§Ú§Þ§Ñ§Ö§ä §é§ä§à §Ó §Ü§à§ß§ã§ä§â§å§Ü§ä§à§â§Ö §Ù§Ñ§Ò§Ú§ä §á§Ö§â§Ó§í§Û §ï§Ý§Ö§Þ§Ö§ß§ä
        if (tokens_arr.length <= 1)
            return;

        address[] memory token_addresses = new address[](tokens_arr.length-1);
        for (uint i = 1; i < tokens_arr.length; i++)
        {
            token_addresses[i-1] = tokens_arr[i].contract_address;
        }

        return token_addresses;
    }

    //§¶§å§ß§Ü§Ú§è§ñ §á§à§Ý§å§é§Ö§ß§Ú§ñ §Õ§Ñ§ß§ß§í§ç §à §Ó§ã§Ö§ç §Õ§à§ã§ä§å§á§ß§í§ç §Õ§à§ç§à§Õ§Ñ§ç §Ó ether §ã§à §Ó§ã§Ö§ç
    //§Ù§Ñ§â§Ö§Ô§Ú§ã§ä§â§Ú§â§à§Ó§Ñ§ß§ß§í§ç §Ü§à§ß§ä§â§Ñ§Ü§ä§à§Ó §ä§à§Ü§Ö§ß§à§Ó. §¹§ä§à§Ò§í §Ó§à§ã§á§à§Ý§î§Ù§à§Ó§Ñ§ä§î§ã§ñ §ï§ä§Ú§Þ§Ú
    //§Õ§à§ç§à§Õ§Ñ§Þ§Ú §ß§å§Ø§ß§à §Õ§Ý§ñ §Ü§Ñ§Ø§Ø§à§Ô§à §ä§à§Ü§Ö§ß§Ñ §Ó§í§Ù§Ó§Ñ§ä§î takeICOInvestmentsEtherCommission
    function getAvailableEtherCommissions()
    public view
    returns(
        address[],
        uint[]
    )
    {
        // §ã§Ú§ä§å§Ñ§è§Ú§ñ, §Ü§à§Ô§Õ§Ñ §ß§Ö §Õ§à§Ò§Ñ§Ó§Ý§Ö§ß§í §ä§à§Ü§Ö§ß§í. <= §é§ä§à§Ò§í §å§Ò§â§Ñ§ä§î §á§â§Ö§Õ mythril,
        // §Ü§à§ä§à§â§í§Û §ß§Ö §á§à§ß§Ú§Þ§Ñ§Ö§ä §é§ä§à §Ó §Ü§à§ß§ã§ä§â§å§Ü§ä§à§â§Ö §Ù§Ñ§Ò§Ú§ä §á§Ö§â§Ó§í§Û §ï§Ý§Ö§Þ§Ö§ß§ä
        if (tokens_arr.length <= 1)
            return;

        address[] memory token_addresses = new address[](tokens_arr.length-1);
        uint[] memory available_withdraws = new uint[](tokens_arr.length-1);
        //§©§Õ§Ö§ã§î §Õ§à§Ý§Ø§ß§à §Ò§í§ä§î §à§ä 1-§Ô§à, §á§à§ä§à§Þ§å §é§ä§à §ß§Ñ 0-§à§Þ - §ï§æ§Ú§â
        for (uint i = 1; i < tokens_arr.length; i++)
        {
            token_addresses[i-1] = tokens_arr[i].contract_address;
            available_withdraws[i-1] =
                BeneficiaryInterface(tokens_arr[i].contract_address).getAvailableWithdrawInvestmentsForBeneficiary();
        }

        return (token_addresses, available_withdraws);
    }


    //§¶§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§å§ð §Þ§à§Ø§Ö§ä §Õ§Ö§â§Ô§ß§å§ä§î §Ü§ä§à §å§Ô§à§Õ§ß§à, §é§ä§à§Ò§í §ß§Ñ §Õ§Ñ§ß§ß§í§Û  §Ü§à§ß§ä§â§Ñ§Ü§ä §Ò§í§Ý§Ú §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß
    //§Ü§à§Þ§Ú§ã§ã§Ú§Ú §ã §Ú§ß§Ó§Ö§ã§ä§Ú§è§Ú§Û §Ó §ï§æ§Ú§â§Ö
    function takeICOInvestmentsEtherCommission(address ico_token_address)
    public
    {
        //§±§â§à§Ó§Ö§â§ñ§Ö§Þ §é§ä§à §â§Ñ§ß§Ö§Ö §Ò§í§Ý! §Õ§à§Ò§Ñ§Ó§Ý§Ö§ß §ä§Ñ§Ü§à§Û §ä§à§Ü§Ö§ß
        require(tokens_map[ico_token_address] != 0);

        //§µ§Ù§ß§Ñ§Ö§Þ §ã§Ü§à§Ý§î§Ü§à §Þ§í §Þ§à§Ø§Ö§Þ §Ó§í§Ó§Ö§ã§ä§Ú §Ò§Ñ§Ò§Ý§Ñ
        uint available_investments_commission =
            BeneficiaryInterface(ico_token_address).getAvailableWithdrawInvestmentsForBeneficiary();

        //§©§Ñ§á§à§Þ§Ú§ß§Ñ§Ö§Þ §é§ä§à §Ò§Ñ§Ò§Ü§Ú §Ù§Ñ§Ò§â§Ñ§Ý§Ú
        //§Ù§Ñ§á§à§Þ§Ú§ß§Ñ§Ö§Þ §Õ§à §á§Ö§â§Ö§Ó§à§Õ§Ñ, §ä§Ñ§Ü §Ü§Ñ§Ü §á§à§ä§à§Þ §Õ§Ö§â§Ô§Ñ§Ö§Þ external contract method
        tokens_arr[0].ever_added = tokens_arr[0].ever_added.add(available_investments_commission);

        //§±§Ö§â§Ö§Ó§à§Õ§Ú§Þ §Ò§Ñ§Ò§Ý§à §ß§Ñ §Ñ§Õ§â§Ö§ã §ï§ä§à§Ô§à §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ
        BeneficiaryInterface(ico_token_address).withdrawInvestmentsBeneficiary(
            address(this));
    }


    //§³§á§Ö§è§Ú§Ñ§Ý§î§ß§à §â§Ñ§Ù§â§Ö§ê§Ñ§Ö§Þ §á§à§Ý§å§é§Ö§ß§Ú§Ö §Ò§Ñ§Ò§Ý§Ñ
    function()
    public payable
    {

    }


    //§®§Ö§ä§à§Õ §å§ã§ä§Ñ§ß§à§Ó§Ü§Ú §Ñ§Õ§â§Ö§ã§Ñ grandFactory, §Ü§à§ä§à§â§í§Û §Ò§å§Õ§Ö§ä §Ú§ã§á§à§Ý§î§Ù§à§Ó§Ñ§ß
    function setGrandFactory(address _grand_factory)
    public
        onlyPlatform
    {
        //§±§â§à§Ó§Ö§â§ñ§Ö§Þ §é§ä§à§Ò§í §Ñ§Õ§â§Ö§ã §Ò§í§Ý §á§Ö§â§Ö§Õ§Ñ§ß §ß§à§â§Þ§Ñ§Ý§î§ß§í§Û
        require(_grand_factory != address(0));

        grand_factory = _grand_factory;
    }

    // §Ò§Ñ§Ý§Ñ§ß§ã §â§Ñ§ã§ã§é§Ú§ä§í§Ó§Ñ§Ö§ä§ã§ñ §á§à §æ§à§â§Þ§å§Ý§Ö:
    // §à§Ò§ë§Ö§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ _token_address, §Ü§à§ä§à§â§í§Þ §Ó§Ý§Ñ§Õ§Ö§Ö§ä §Ü§à§ß§ä§â§Ñ§Ü§ä CNR
    // §å§Þ§ß§à§Ø§Ñ§Ö§Þ §ß§Ñ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó CNR §å _owner, §Õ§Ö§Ý§Ú§Þ §ß§Ñ totalSupply (§á§à§Ý§å§é§Ñ§Ö§Þ §Õ§à§Ý§ð)
    // §Ú §à§ä§ß§Ú§Þ§Ñ§Ö§Þ §å§Ø§Ö §Ó§í§Ó§Ö§Õ§Ö§ß§ß§å§ð _owner'§à§Þ §ã§å§Þ§Þ§å §ä§à§Ü§Ö§ß§à§Ó
    //§¥§à§ã§ä§å§á§ß§í§Û §Ü §Ó§í§Ó§à§Õ§å §Ò§Ñ§Ý§Ñ§ß§ã §Ó §ä§à§Ü§Ö§ß§Ñ§ç §ß§Ö§Ü§à§ä§à§â§à§Ô§à ICO
    function balanceOfToken(address _owner, address _token_address)
    public view
    returns (uint256 balance)
    {
        //§±§â§à§Ó§Ö§â§Ü§Ñ §ß§Ñ§Ý§Ú§é§Ú§ñ §ä§Ñ§Ü§à§Ô§à §ä§à§Ü§Ö§ß§Ñ
        require(tokens_map[_token_address] != 0);

        uint idx = tokens_map[_token_address];
        balance =
            tokens_arr[idx].ever_added
            .mul(balances[_owner])
            .div(totalSupply)
            .sub(withdrawns[_owner][idx]);
        }

    // §Ó§ã§Ö §Ü§Ñ§Ü §Ú §Ó balanceOfToken, §ä§à§Ý§î§Ü§à §Ú§ã§á§à§Ý§î§Ù§å§Ö§Þ 0 §ï§Ý§Ö§Þ§Ö§ß§ä §Ó tokens_arr §Ú withdrawns[_owner]
    //§¥§à§ã§ä§å§á§ß§í§Û §Ü §Ó§í§Ó§à§Õ§å §Ò§Ñ§Ý§Ñ§ß§ã §Ó §ï§æ§Ú§â§Ñ§ç
    function balanceOfETH(address _owner)
    public view
    returns (uint256 balance)
    {
        balance =
            tokens_arr[0].ever_added
            .mul(balances[_owner])
            .div(totalSupply)
            .sub(withdrawns[_owner][0]);
    }

    //§¶§å§ß§Ü§è§Ú§ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ §Õ§à§ã§ä§å§á§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó §ß§Ö§Ü§à§ä§à§â§à§Ô§à ICO §ß§Ñ §å§Ü§Ñ§Ù§Ñ§ß§ß§í§Û §Ü§à§ê§Ö§Ý§Ö§Ü
    function withdrawTokens(address _token_address, address _destination_address)
    public
    {
        //§±§â§à§Ó§Ö§â§Ü§Ñ §ß§Ñ§Ý§Ú§é§Ú§ñ §ä§Ñ§Ü§à§Ô§à §ä§à§Ü§Ö§ß§Ñ
        require(tokens_map[_token_address] != 0);

        uint token_balance = balanceOfToken(msg.sender, _token_address);
        uint token_idx = tokens_map[_token_address];
        withdrawns[msg.sender][token_idx] = withdrawns[msg.sender][token_idx].add(token_balance);
        ERC20Basic(_token_address).transfer(_destination_address, token_balance);
    }

    //§¶§å§ß§Ü§Ú§è§ñ §Ù§Ñ§Ò§Ú§â§Ñ§ß§Ú§ñ §Õ§à§ã§ä§å§á§ß§à§Ô§à §ï§æ§Ú§â§Ñ §ß§Ñ §å§Ü§Ñ§Ù§Ñ§ß§ß§í§Û §Ü§à§ê§Ö§Ý§Ö§Ü
    function withdrawETH(address _destination_address)
    public
    {
        uint value_in_wei = balanceOfETH(msg.sender);
        withdrawns[msg.sender][0] = withdrawns[msg.sender][0].add(value_in_wei);
        _destination_address.transfer(value_in_wei);
    }


    //§¥§Ñ§ß§ß§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §Õ§Ý§à§Ø§ß§Ñ §Ó§í§Ù§í§Ó§Ñ§ä§î§ã§ñ §Ú§Ù §Ü§à§ß§ä§â§Ñ§Ü§ä§à§Ó-§ä§à§Ü§Ö§ß§à§Ó, §Ó §ä§à§ä §Þ§à§Þ§Ö§ß§ä §Ü§à§Ô§Õ§Ñ §Ò§Ö§ß§Ö§æ§Ú§è§Ú§Ñ§â§å
    //(§ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä §Ò§Ö§ß§Ö§æ§Ú§è§Ú§Ñ§â§Ñ) §á§Ö§â§Ö§Ó§à§Õ§ñ§ä§ã§ñ §ä§à§Ü§Ö§ß§í
    function addTokenBalance(address _token_contract, uint amount)
    public
    {
        //§±§â§à§Ó§Ö§â§ñ§Ö§Þ §é§ä§à §æ§å§ß§Ü§è§Ú§ñ §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §Ú§Ù §â§Ñ§ß§Ö§Ö §Õ§à§Ò§Ñ§Ó§Ý§Ö§ß§ß§à§ß§à! §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §ä§à§Ü§Ö§ß§Ñ
        require(tokens_map[msg.sender] != 0);

        //§¥§°§Ò§Ñ§Ó§Ý§Ö§ß§Ú§Ö §Õ§Ñ§ß§ß§í§ç §à§Ò§à §Ó§ã§Ö§ç §ä§à§Ü§Ö§ß§Ñ§ç, §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§ß§í§ç §Ò§Ö§ß§Ö§æ§Ú§è§Ú§Ñ§â§å
        tokens_arr[tokens_map[_token_contract]].ever_added = tokens_arr[tokens_map[_token_contract]].ever_added.add(amount);
    }

    //§¶§å§ß§Ü§Ú§è§ñ §Õ§à§Ò§Ñ§Ó§Ý§Ö§ß§Ú§ñ §ß§à§Ó§à§Ô§à §ä§à§Ü§Ö§ß§Ñ. §¥§Ñ§ß§ß§Ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §Õ§à§Ý§Ø§ß§Ñ §Ó§í§Ù§í§Ó§Ñ§ä§î§ã§ñ
    //§ä§à§Ý§î§Ü§à GrandFactory §á§â§Ú §ã§à§Ù§Õ§Ñ§ß§Ú§Ú §ß§à§Ó§à§Ô§à ICO §ä§à§Ü§Ö§ß§Ñ
    function addTokenAddress(address ico_token_address)
    public
    {
        //§±§â§à§Ó§Ö§â§ñ§Ö§Þ §é§ä§à§Ò§í §ï§ä§à §Ò§í§Ý §Ó§í§Ù§à§Ó §Ú§Ù grand_factory
        require(grand_factory == msg.sender);

        //§±§â§à§Ó§Ö§â§ñ§Ö§Þ §é§ä§à §â§Ñ§ß§Ö§Ö §ß§Ö §Ò§í§Ý §Õ§à§Ñ§Ó§Ý§Ö§ß §ä§Ñ§Ü§à§Û §ä§à§Ü§Ö§ß
        require(tokens_map[ico_token_address] == 0);

        tokens_arr.push(
            TokenInfo(
                ico_token_address,
                0));
        tokens_map[ico_token_address] = tokens_arr.length - 1;
    }



    //------------------------------ERC20---------------------------------------

    //§¢§Ñ§Ý§Ñ§ß§ã §Ó §ä§à§Ü§Ö§ß§Ñ§ç
    function balanceOf(address _owner)
    public view
    returns (uint256 balance)
    {
        return balances[_owner];
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        //        uint withdraw_to_transfer = withdrawn[msg.sender] *  _value / balances[msg.sender];

        for (uint i = 0; i < tokens_arr.length; i++)
        {
            //§³§Ü§à§Ý§î§Ü§à §Ù§Ñ§Ò§â§Ñ§ß§ß§í§ç §ã§å§ë§ß§à§ã§ä§Ö§Û §á§Ö§â§Ö§Þ§Ö§ã§ä§Ú§ä§î §ß§Ñ §Õ§â§å§Ô§à§Û §Ñ§Ü§Ü§Ñ§å§ß§ä
            uint withdraw_to_transfer = withdrawns[msg.sender][i].mul(_value).div(balances[msg.sender]);

            //§±§Ö§â§Ó§à§Õ§Ú§Þ §Ù§Ñ§Ò§â§Ñ§ß§ß§í§Û §Õ§à§ç§à§Õ
            withdrawns[msg.sender][i] = withdrawns[msg.sender][i].sub(withdraw_to_transfer);
            withdrawns[_to][i] = withdrawns[_to][i].add(withdraw_to_transfer);
        }


        //§±§Ö§â§Ö§Ó§à§Õ§Ú§Þ §ä§à§Ü§Ö§ß§í
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);


        //§¤§Ö§ß§Ö§â§Ú§Þ §ã§à§Ò§í§ä§Ú§Ö
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        for (uint i = 0; i < tokens_arr.length; i++)
        {
            //§³§Ü§à§Ý§î§Ü§à §Ù§Ñ§Ò§â§Ñ§ß§ß§í§ç §ã§å§ë§ß§à§ã§ä§Ö§Û §á§Ö§â§Ö§Þ§Ö§ã§ä§Ú§ä§î §ß§Ñ §Õ§â§å§Ô§à§Û §Ñ§Ü§Ü§Ñ§å§ß§ä
            uint withdraw_to_transfer = withdrawns[_from][i].mul(_value).div(balances[_from]);

            //§±§Ö§â§Ó§à§Õ§Ú§Þ §Ù§Ñ§Ò§â§Ñ§ß§ß§í§Û §Õ§à§ç§à§Õ
            withdrawns[_from][i] = withdrawns[_from][i].sub(withdraw_to_transfer);
            withdrawns[_to][i] = withdrawns[_to][i].add(withdraw_to_transfer);
        }


        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);


        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    ///////////////////////////////////ERC20////////////////////////////////////

    struct TokenInfo
    {
        //§¡§Õ§â§Ö§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §ä§à§Ü§Ö§ß§Ñ (§Þ§à§Ø§Ö§ä §Ó§í§á§Ý§Ú§ä§î §á§à§ä§à§Þ?)
        address contract_address;

        //§£§Ö§ã§î §Õ§à§ç§à§Õ, §á§Ö§â§Ö§Ó§Ö§Õ§Ö§ß§ß§í§Û §ß§Ñ §Ñ§Õ§â§Ö§ã §Õ§Ñ§ß§ß§à§Ô§à §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §Ó§í§Ù§à§Ó§à§Þ
        //§æ§å§ß§Ü§è§Ú§Ú addTokenBalance
        uint256 ever_added;
    }
}