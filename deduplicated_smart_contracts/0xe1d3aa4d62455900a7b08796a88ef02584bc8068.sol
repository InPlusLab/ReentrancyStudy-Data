/**

 _______   ________  __    __   ______   __       __   ______   __    __ 
/       \ /        |/  \  /  | /      \ /  \     /  | /      \ /  \  /  |
$$$$$$$  |$$$$$$$$/ $$  \ $$ |/$$$$$$  |$$  \   /$$ |/$$$$$$  |$$  \ $$ |
$$ |__$$ |$$ |__    $$$  \$$ |$$ |__$$ |$$$  \ /$$$ |$$ |  $$ |$$$  \$$ |
$$    $$< $$    |   $$$$  $$ |$$    $$ |$$$$  /$$$$ |$$ |  $$ |$$$$  $$ |
$$$$$$$  |$$$$$/    $$ $$ $$ |$$$$$$$$ |$$ $$ $$/$$ |$$ |  $$ |$$ $$ $$ |
$$ |__$$ |$$ |_____ $$ |$$$$ |$$ |  $$ |$$ |$$$/ $$ |$$ \__$$ |$$ |$$$$ |
$$    $$/ $$       |$$ | $$$ |$$ |  $$ |$$ | $/  $$ |$$    $$/ $$ | $$$ |
$$$$$$$/  $$$$$$$$/ $$/   $$/ $$/   $$/ $$/      $$/  $$$$$$/  $$/   $$/ 
 

Telegram: https://t.me/benamongame

Twitter: https://twitter.com/benamongame

Website: https://benamon.net
 
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.3;

import "./ERC20.sol";
import "./Address.sol";

contract Benamon is ERC20 {

  mapping(address => uint256) private _blockNumberByAddress;
    uint256 private _initialSupply = 100000000  * 10**18;
  
  constructor() ERC20("Benamon NFT Game", "BENA") {
    
    _totalSupply += _initialSupply;
    _balances[msg.sender] += _initialSupply;
    emit Transfer(address(0), msg.sender, _initialSupply);
  }
    
  function burn(address account, uint256 amount) external onlyOwner {
    _burn(account, amount);
  }
}