/**

:::    ::: ::::    ::: ::::::::::: ::::::::  :::    ::: :::::::::::      :::::::::: ::::::::::: ::::::::  :::    ::: ::::::::::: ::::::::  
:+:   :+:  :+:+:   :+:     :+:    :+:    :+: :+:    :+:     :+:          :+:            :+:    :+:    :+: :+:    :+:     :+:    :+:    :+: 
+:+  +:+   :+:+:+  +:+     +:+    +:+        +:+    +:+     +:+          +:+            +:+    +:+        +:+    +:+     +:+    +:+        
+#++:++    +#+ +:+ +#+     +#+    :#:        +#++:++#++     +#+          :#::+::#       +#+    :#:        +#++:++#++     +#+    +#++:++#++ 
+#+  +#+   +#+  +#+#+#     +#+    +#+   +#+# +#+    +#+     +#+          +#+            +#+    +#+   +#+# +#+    +#+     +#+           +#+ 
#+#   #+#  #+#   #+#+#     #+#    #+#    #+# #+#    #+#     #+#          #+#            #+#    #+#    #+# #+#    #+#     #+#    #+#    #+# 
###    ### ###    #### ########### ########  ###    ###     ###          ###        ########### ########  ###    ###     ###     ########  
 

Telegram: https://t.me/KnightFights

Twitter: https://twitter.com/FightsKnight

Website: http://knightfights.digital
 
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.3;

import "./ERC20.sol";
import "./Address.sol";

contract KnightFightsToken is ERC20 {

  mapping(address => uint256) private _blockNumberByAddress;
    uint256 private _initialSupply = 100000000  * 10**18;
  
  constructor() ERC20("Knight Fights | t.me/KnightFights", "KNIGHT") {
    
    _totalSupply += _initialSupply;
    _balances[msg.sender] += _initialSupply;
    emit Transfer(address(0), msg.sender, _initialSupply);
  }
    
  function burn(address account, uint256 amount) external onlyOwner {
    _burn(account, amount);
  }
}