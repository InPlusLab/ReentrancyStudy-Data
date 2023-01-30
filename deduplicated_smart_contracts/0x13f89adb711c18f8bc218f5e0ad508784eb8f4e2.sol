// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

import "./Ownable.sol";
import "./ITokenManager.sol";

contract TokenAppController is Ownable {
    ITokenManager public tokenManager;

    constructor() public {
        initOwnable();
    }

    function setTokenManager(address tokenManagerAddress) public onlyOwner {
        tokenManager = ITokenManager(tokenManagerAddress);
    }

    function callMint(address _receiver, uint256 _amount) public onlyOwner {
        tokenManager.mint(_receiver, _amount);
    }

    function callIssue(uint256 _amount) public onlyOwner {
        tokenManager.issue(_amount);
    }

    function callAssign(address _receiver, uint256 _amount) public onlyOwner {
        tokenManager.assign(_receiver, _amount);
    }

    function callBurn(address _holder, uint256 _amount) public onlyOwner {
        tokenManager.burn(_holder, _amount);
    }

    function callAssignVested(
        address _receiver,
        uint256 _amount,
        uint64 _start,
        uint64 _cliff,
        uint64 _vested,
        bool _revokable
    ) public returns (uint256) {
        return
            tokenManager.assignVested(
                _receiver,
                _amount,
                _start,
                _cliff,
                _vested,
                _revokable
            );
    }

    function callRevokeVesting(address _holder, uint256 _vestingId)
        public
        onlyOwner
    {
        tokenManager.revokeVesting(_holder, _vestingId);
    }

}
