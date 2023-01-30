/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

pragma solidity ^0.6.0;

/**
 * @title ConnectBasic.
 * @dev Connector to deposit/withdraw assets.
 */

interface ERC20Interface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface AccountInterface {
    function isAuth(address _user) external view returns (bool);
}

interface MemoryInterface {
    function getUint(uint _id) external returns (uint _num);
    function setUint(uint _id, uint _val) external;
}

interface EventInterface {
    function emitEvent(uint64 _connectorID, bytes4 _eventCode, bytes calldata _eventData) external;
}

contract Memory {

    /**
     * @dev Return InstaMemory Address.
     */
    function getMemoryAddr() public pure returns (address) {
        return 0x0000000000000000000000000000000000000000; // InstaMemory Address
    }

    /**
     * @dev Return InstaEvent Address.
     */
    function getEventAddr() public pure returns (address) {
        return 0x0000000000000000000000000000000000000000;
    }

    function connectorID() public pure returns(uint64) {
        return 2;
    }

    /**
     * @dev Get Stored Uint Value From InstaMemory.
     * @param getId Storage ID.
     * @param val if any value.
     */
    function getUint(uint getId, uint val) internal returns (uint returnVal) {
        returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
    }

    /**
     * @dev Store Uint Value In InstaMemory.
     * @param setId Storage ID.
     * @param val Value To store.
     */
    function setUint(uint setId, uint val) internal {
        if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
    }

}

contract BasicResolver is Memory {

    event LogDeposit(address erc20, uint tokenAmt, uint getId, uint setId);
    event LogWithdraw(address erc20, uint tokenAmt, address to, uint getId, uint setId);

    /**
     * @dev ETH Address.
     */
    function getEthAddr() public pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    /**
     * @dev Deposit Assets To Smart Account.
     * @param erc20 Token Address.
     * @param tokenAmt Token Amount.
     * @param getId Get Storage ID.
     * @param setId Set Storage ID.
     */
    function deposit(address erc20, uint tokenAmt, uint getId, uint setId) public payable {
        uint amt = getUint(getId, tokenAmt);
        if (erc20 != getEthAddr()) {
            ERC20Interface token = ERC20Interface(erc20);
            amt = amt == uint(-1) ? token.balanceOf(msg.sender) : amt;
            token.transferFrom(msg.sender, address(this), amt);
        } else {
            require(msg.value == amt, "invalid-ether-amount");
        }
        setUint(setId, amt);
        emit LogDeposit(erc20, amt, getId, setId);
        bytes4 _eventCode = bytes4(keccak256("LogDeposit(address, uint, uint, uint)"));
        bytes memory _eventParam = abi.encode(erc20, amt, getId, setId);
        EventInterface(getEventAddr()).emitEvent(connectorID(), _eventCode, _eventParam);
    }

   /**
     * @dev Withdraw Assets To Smart Account.
     * @param erc20 Token Address.
     * @param tokenAmt Token Amount.
     * @param to Withdraw token address.
     * @param getId Get Storage ID.
     * @param setId Set Storage ID.
     */
    function withdraw(
        address erc20,
        uint tokenAmt,
        address payable to,
        uint getId,
        uint setId
    ) public payable {
        require(AccountInterface(address(this)).isAuth(to), "invalid-to-address");
        uint amt = getUint(getId, tokenAmt);
        if (erc20 == getEthAddr()) {
            amt = amt == uint(-1) ? address(this).balance : amt;
            to.transfer(amt);
        } else {
            ERC20Interface token = ERC20Interface(erc20);
            amt = amt == uint(-1) ? token.balanceOf(address(this)) : amt;
            token.transfer(to, amt);
        }
        setUint(setId, amt);
        emit LogWithdraw(erc20, amt, to, getId, setId);
        bytes4 _eventCode = bytes4(keccak256("LogWithdraw(address, uint, address, uint, uint)"));
        bytes memory _eventParam = abi.encode(erc20, amt, to, getId, setId);
        EventInterface(getEventAddr()).emitEvent(connectorID(), _eventCode, _eventParam);
    }

}


contract ConnectBasic is BasicResolver {
    string public name = "Basic-v1";
}