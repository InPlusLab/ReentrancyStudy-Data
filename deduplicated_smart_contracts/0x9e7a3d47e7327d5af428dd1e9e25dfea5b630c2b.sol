/**
 *Submitted for verification at Etherscan.io on 2020-04-29
*/

pragma solidity =0.5.16;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
}

contract TokenStaticCallProxy {
    // _fakeValue forces constant: false abi while avoiding warnings
    // No actual TX expected to be called against this contract, just testing
    uint256 _fakeValue;
    function balanceOf(IERC20 _token, address _owner) external returns (uint) {
        _fakeValue = 1;
        return _token.balanceOf(_owner);
    }    

    function allowance(IERC20 _token, address _owner, address _spender) external returns (uint) {
        _fakeValue = 1;
        return _token.allowance(_owner, _spender);
    }
    
    function balanceOfRead(IERC20 _token, address _owner) external view returns (uint) {
        return _token.balanceOf(_owner);
    }    

    function allowanceRead(IERC20 _token, address _owner, address _spender) external view returns (uint) {
        return _token.allowance(_owner, _spender);
    }    
}