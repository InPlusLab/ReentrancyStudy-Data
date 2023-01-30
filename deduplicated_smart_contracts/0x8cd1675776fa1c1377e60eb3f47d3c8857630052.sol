/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

// SPDX-License-Identifier: AGPLv3
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

interface Usdc {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface Vault {
    function token() external view returns (address);

    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);
}

contract UsdcVaultPermitDeposit {
    Vault public vault;
    Usdc public usdc;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor(address _vault) public {
        vault = Vault(_vault);
        usdc = Usdc(vault.token());
        require(address(usdc) == USDC); // dev: wrong vault
        usdc.approve(address(vault), type(uint256).max);
    }

    function deposit(uint256 amount, Permit calldata permit)
        public
        returns (uint256)
    {
        usdc.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            permit.v,
            permit.r,
            permit.s
        );
        usdc.transferFrom(permit.owner, address(this), amount);
        return vault.deposit(amount, permit.owner);
    }
}