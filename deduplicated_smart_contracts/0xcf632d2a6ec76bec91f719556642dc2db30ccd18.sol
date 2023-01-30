// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;


contract Lockable {
    bool private _locked;

    constructor() internal {
        _locked = false;
    }

    modifier whenNotLocked() {
        require(!_locked, "Lockable: already locked");
        _;
    }

    modifier whenLocked() {
        require(_locked, "Lockable: not locked yet");
        _;
    }

    function _lock() internal whenNotLocked {
        _locked = true;
    }
}