/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

// POVCrypto Token
// Made for @TrustlessState and @ck_SNARKs
// Each of these 69 Tokens were lovingly crafted by @nanexcool in Buenos Aires
// Code adapted from https://github.com/makerdao/dss/blob/effdda3657f71fd6efc3465dc661b375d1bacc3e/src/dai.sol

pragma solidity ^0.5.11;

contract POVToken {
    // --- ERC20 Data ---
    string  public constant name     = "POV Crypto";
    string  public constant symbol   = "POV";
    uint8   public constant decimals = 0;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    // --- Math ---
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }

    constructor(uint256 supply) public {
        balanceOf[msg.sender] = supply;
        totalSupply = supply;
        emit Transfer(address(0x0), msg.sender, supply);
    }

    // --- Token ---
    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        public returns (bool)
    {
        require(balanceOf[src] >= wad, "pov/insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "pov/insufficient-allowance");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }

    function approve(address usr, uint wad) external returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }
}