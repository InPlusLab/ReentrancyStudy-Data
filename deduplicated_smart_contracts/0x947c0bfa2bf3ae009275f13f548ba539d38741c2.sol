// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ITransparentUpgradeableProxy.sol";

contract ProxyController is Ownable {
    using SafeMath for uint256;

    ITransparentUpgradeableProxy private nftxProxy;
    address public implAddress;

    constructor(address nftx) public {
        initOwnable();
        nftxProxy = ITransparentUpgradeableProxy(nftx);
    }

    function getAdmin() public returns (address) {
        return nftxProxy.admin();
    }

    function fetchImplAddress() public {
        implAddress = nftxProxy.implementation();
    }

    function changeProxyAdmin(address newAdmin) public onlyOwner {
        nftxProxy.changeAdmin(newAdmin);
    }

    function upgradeProxyTo(address newImpl) public onlyOwner {
        nftxProxy.upgradeTo(newImpl);
    }
}
