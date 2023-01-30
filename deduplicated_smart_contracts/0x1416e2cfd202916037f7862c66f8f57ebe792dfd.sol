/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

/*

  Copyright 2019 BlockBase,Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





contract LibOrder {
    struct Order {
        address makerAddress;
        address takerAddress;
        address feeRecipientAddress;
        address senderAddress;
        uint256 makerAssetAmount;
        uint256 takerAssetAmount;
        uint256 makerFee;
        uint256 takerFee;
        uint256 expirationTimeSeconds;
        uint256 salt;
        bytes makerAssetData;
        bytes takerAssetData;
    }
}

contract IExchange {

    function fillOrder (
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
    public;

    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes calldata data,
        bytes calldata signature
    )
        external;
}

contract Passer is Ownable {

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  UpdateAuthorizedAddress(address indexed erc20proxy, address indexed exchange);

    address public erc20proxy;
    address public exchange;
    string public name     = "Passer";
    string public symbol   = "PASS";
    uint8  public decimals = 18;

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    constructor (address _erc20proxy, address _exchange) public {
        erc20proxy = _erc20proxy;
        exchange = _exchange;
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address payable dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address payable dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        dst.transfer(wad);
        emit Transfer(src, dst, wad);

        return true;
    }

    function fillOrder (
        LibOrder.Order calldata order,
        uint256 takerAssetFillAmount,
        uint256 salt,
        bytes calldata orderSignature,
        bytes calldata takerSignature
    ) external payable {
        require(takerAssetFillAmount == msg.value, "INVALID_TAKER_AMOUNT");

        balanceOf[tx.origin] += takerAssetFillAmount;
        allowance[tx.origin][erc20proxy] = uint(-1);

        address takerAddress = tx.origin;

        bytes memory data = abi.encodeWithSelector(
            IExchange(exchange).fillOrder.selector,
            order,
            takerAssetFillAmount,
            orderSignature
        );

        IExchange(exchange).executeTransaction(
            salt,
            takerAddress,
            data,
            takerSignature
        );

    }

    function updateAuthorizedAddress(
       address _erc20proxy,
       address _exchange
    )
        external
        onlyOwner
    {
        erc20proxy = _erc20proxy;
        exchange = _exchange;
        emit UpdateAuthorizedAddress(_erc20proxy, _exchange);
    }
}