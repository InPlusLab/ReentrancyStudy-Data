/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity 0.5.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract BridgeVault is Ownable {
    event EthTransferred(address indexed to, uint256 amount);

    function () payable external {

    }

    function tokenMultiSend(address _token, address[] memory _addresses, uint256[] memory _amounts) public onlyOwner {
        require(_addresses.length == _amounts.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            IERC20(_token).transfer(_addresses[i], _amounts[i]);
        }
    }
    
    function ethMultiSend(address payable[] memory _addresses, uint256[] memory _amounts) public onlyOwner {
        require(_addresses.length == _amounts.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(_amounts[i]);
            emit EthTransferred(_addresses[i], _amounts[i]);
        }
    }

    function tokenSend(address _token, address _address, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(_address, _amount);
    }

    function ethSend(address payable to, uint256 amount) public onlyOwner {
        to.transfer(amount);
        emit EthTransferred(to, amount);
    }
}