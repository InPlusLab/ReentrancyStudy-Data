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

pragma solidity 0.5.12;

import "./lib.sol";

// Ceiling
// Implements a ward that only allows minting of tokens if the `roof` has not
// been reached. The roof is set at deployment and can not be changed after.
// This is an effective way of implementing a fixed supply token without
// requiring to mint all tokens at once.
//
contract Ceiling {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) public auth { wards[usr] = 1; }
    function deny(address usr) public auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- Data ---
    MintLike public tkn;
    uint public     roof;

    constructor(address tkn_, uint roof_) public {
        wards[msg.sender] = 1;
        tkn = MintLike(tkn_);
        roof = roof_;
    }

    // --- Math ---
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

    // --- Ceiling ---
    function mint(address usr, uint wad) public auth {
        require(add(tkn.totalSupply(), wad) <= roof, "cent/reached-roof");
        tkn.mint(usr, wad);
    }
}
