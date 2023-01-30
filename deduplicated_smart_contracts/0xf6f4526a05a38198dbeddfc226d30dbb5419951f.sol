/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

// SPDX-License-Identifier: AGPLv3
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

interface Dai {
    function pull(address usr, uint256 wad) external;

    function approve(address usr, uint256 wad) external returns (bool);

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
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

contract DaiVaultPermitDeposit {
    Vault public vault;
    Dai public dai;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    struct Permit {
        address holder;
        address spender;
        uint256 nonce;
        uint256 expiry;
        bool allowed;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor(address _vault) public {
        vault = Vault(_vault);
        dai = Dai(vault.token());
        require(address(dai) == DAI); // dev: wrong vault
        dai.approve(address(vault), type(uint256).max);
    }

    function deposit(uint256 amount, Permit calldata permit)
        public
        returns (uint256)
    {
        dai.permit(
            permit.holder,
            permit.spender,
            permit.nonce,
            permit.expiry,
            permit.allowed,
            permit.v,
            permit.r,
            permit.s
        );
        dai.pull(permit.holder, amount);
        return vault.deposit(amount, permit.holder);
    }
}