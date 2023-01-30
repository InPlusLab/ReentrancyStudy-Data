// Copyright (C) 2019 lucasvo

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.4.24;

import './lib.sol';
import './radial.sol';
import './ceiling.sol';
import './budget.sol';

// RadialFab deploys the Radial ERC20 token, an instance of Ceiling and Budget
// removing the deployer address from the wards of the Radial and Ceiling
// contracts.
//
// By doing the entire deploy in one transaction, we can simplify auditing of
// the deploy and ensure that no ward was added to any of the Radial and
// Ceiling contract other than the Budget ward.
//
contract RadialFab {
    Radial  public    tkn;
    Ceiling public    ceil;
    Budget  public    bags;

    constructor (uint roof, address ward, uint chainid) public {
        address self = address(this);
        tkn = new Radial(chainid);
        ceil = new Ceiling(address(tkn), roof);
        bags = new Budget(address(ceil));

        tkn.rely(address(ceil));
        tkn.deny(self);
        ceil.rely(address(bags));
        ceil.deny(self);
        bags.rely(ward);
        bags.deny(self);
    }
}

