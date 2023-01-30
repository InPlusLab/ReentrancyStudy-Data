// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import './Address.sol';
import './UserWallet.sol';
import './MinimalProxyFactory.sol';

contract UserWalletFactory is MinimalProxyFactory {
    using Address for address;
    address public immutable userWalletPrototype;

    constructor() {
        userWalletPrototype = address(new UserWallet());
    }

    function getBytecodeHash() public view returns(bytes32) {
        return keccak256(_deployBytecode(userWalletPrototype));
    }

    function getUserWallet(address _user) public view returns(IUserWallet) {
        address _predictedAddress = address(uint(keccak256(abi.encodePacked(
            hex'ff',
            address(this),
            bytes32(uint(_user)),
            keccak256(_deployBytecode(userWalletPrototype))
        ))));
        if (_predictedAddress.isContract()) {
            return IUserWallet(_predictedAddress);
        }
        return IUserWallet(0);
    }

    function deployUserWallet(address _w2w, address _referrer) external payable {
        deployUserWalletFor(_w2w, msg.sender, _referrer);
    }

    function deployUserWalletFor(address _w2w, address _owner, address _referrer) public payable {
        UserWallet _userWallet = UserWallet(
            _deploy(userWalletPrototype, bytes32(uint(_owner)))
        );
        _userWallet.init{value: msg.value}(_w2w, _owner, _referrer);
    }
}
