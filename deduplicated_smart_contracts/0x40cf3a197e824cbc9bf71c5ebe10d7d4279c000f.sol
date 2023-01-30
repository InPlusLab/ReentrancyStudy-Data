/**
 *Submitted for verification at Etherscan.io on 2020-08-01
*/

pragma solidity ^0.5.0;

interface IChiToken {
    function mint(uint256 value) external;
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IGST {
    function mint(uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract CHIMinter {
    
    constructor() public {
        _owner = msg.sender;
    }
    
    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 *
                           msg.data.length;
        if(chi.balanceOf(address(this)) > 0) {
            chi.freeFromUpTo(address(this), (gasSpent + 14154) / 41947);
        }
        else {
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
        }
    }
    
    IChiToken public constant chi = IChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    IGST public constant gst = IGST(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    
    address _owner;

    function mint() external discountCHI {
        require(_owner == msg.sender, 'Not owner');
        
        chi.mint(45);
        gst.mint(1);
        
        uint chiBalance = chi.balanceOf(address(this));
        uint gstBalance = gst.balanceOf(address(this));
        
        if (chiBalance > 0) chi.transfer(msg.sender, chiBalance);
        if (gstBalance > 0) gst.transfer(msg.sender, gstBalance);
    }
}