/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

// 
pragma solidity ^0.4.26;

contract uniswap_exchange_interface {
  // Address of ERC20 token sold on this exchange
  function token_address() external view returns (address token);
  // Address of Uniswap Factory
  function factory_address() external view returns (address factory);
  // Provide liquidity
  function add_liquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
  function remove_liquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
  // Get Prices
  function get_eth_to_token_input_price(uint256 eth_sold) external view returns (uint256 tokens_bought);
  function get_eth_to_token_output_price(uint256 tokens_bought) external view returns (uint256 eth_sold);
  function get_token_to_eth_input_price(uint256 tokens_sold) external view returns (uint256 eth_bought);
  function get_token_to_eth_output_price(uint256 eth_bought) external view returns (uint256 tokens_sold);
  // Trade ETH to ERC20
  function eth_to_token_swap_input(uint256 min_tokens, uint256 deadline) external payable returns (uint256 tokens_bought);
  function eth_to_token_transfer_input(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256 tokens_bought);
  function eth_to_token_swap_output(uint256 tokens_bought, uint256 deadline) external payable returns (uint256 eth_sold);
  function eth_to_token_transfer_output(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256 eth_sold);
  //Trade ERC20 to ETH
  function token_to_eth_swap(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256 eth_bought);
  function token_to_eth_transfer_input(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256 eth_bought);
  function token_to_eth_swap_output(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256 tokens_sold);
  function token_to_eth_transfer_output(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256 tokens_sold);
  // Trade ERC20 to ERC20
  function token_to_token_swap_input(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256 tokens_bought);
  function token_to_token_transfer_input(uint256 tokens_sold, uint256 min_tokens_brought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256 tokens_bought);
  function token_to_token_swap_output(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256 tokens_sold);
  function token_to_token_transfer_output(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256 tokens_sold);
  // Trade ERC20 to Custom Pool
  function token_to_exchange_swap_input(uint256 tokens_sold, uint256 min_tokens_bought, uint256 iin_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256 tokens_bought);
  function token_to_exchange_transfer_input(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256 tokens_bought);
  function token_to_exchange_swap_output(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256 tokens_sold);
  function token_to_exchange_transfer_output(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchnge_addr) external returns (uint256 tokens_sold);
  // ERC20 compatibility for liquidity tokens
  bytes32 public name;
  bytes32 public symbol;
  uint public decimals;
  function transfer(address _to, uint256 _value) external returns (bool);
  function transfer_from(address _from, address _to, uint value) external returns (bool);
  function approve(address _spender, uint256 _value) external returns (bool);
  function allowance(address _owner, address _spender) external view returns (uint256);
  function balance_of(address _owner) external view returns (uint256);
  function total_supply() external view returns (uint256);
}

interface ERC20 {
  function total_supply() public view returns (uint supply);
  function balance_of(address _owner) public view returns (uint balance);
  function transfer(address _to, uint value) public returns (bool success);
  function transfer_from(address _from, address _to, uint _value) public returns (bool success);
  function approve(address _spender, uint _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint remaining);
  function decimals() public view returns(uint digits);
  event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface or_feed_interface {
  function get_exchange_rate(string from_symbol, string to_symbol, string venue, uint256 amount) external view returns(uint256);
  function get_token_decimal_count(address token_address) external view returns (uint256);
  function get_token_address(string symbol) external view returns (address);
  function get_synth_bytes32(string symbol) external view returns (bytes32);
  function get_forex_address(string symbol) external view returns (address);
}

contract uniswap_trade {
  function buy_sai() payable returns(uint256){
    // Buy Tether
    address sai_address = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    uniswap_exchange_interface usi = uniswap_exchange_interface(sai_address);
    uint256 amount_eth = msg.value;
    uint256 amount_back = usi.eth_to_token_swap_input.value(amount_eth)(1, block.timestamp);

    ERC20 sai_token = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    sai_token.transfer(msg.sender, amount_back);
    return amount_back;
  }

//  function get_sai_price() constant returns(uint256){
  //  or_feed_interface orfeed = or_feed_interface()
//  }


}