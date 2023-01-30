/**

 *Submitted for verification at Etherscan.io on 2019-01-16

*/



pragma solidity 0.4.25;



contract ERC20 {

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

}



/**

 * @title ARXLocker

 */

contract ARXLocker {



    address public owner;



    ERC20 public token;

    address public crowdsale;



    address[] addresses;

    uint256[] shares;



    event Added(address addr, uint256 amount);

    event Unlocked(uint256 amount);



    /**

     * @dev Constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor() public {

        owner = msg.sender;

    }



    /**

     * @dev Function sets addresses of the token and crowdsale

     * @param ARXToken Address of the ERC20 token

     * @param ARXCrowdsale Address of the crowdsale

     */

    function init(address ARXToken, address ARXCrowdsale) external onlyOwner {

        require(token == address(0) && crowdsale == address(0));

        token = ERC20(ARXToken);

        crowdsale = ARXCrowdsale;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        owner = newOwner;

    }



    /**

     * @dev Adds address to list of participants of getting unlocked tokens

     * @param addr Address of the participant

     * @param share Share of the participant in percents with 2 additional zeroes (1% = 100)

     */

    function addAddress(address addr, uint256 share) external onlyOwner {

        require(addr != address(0) && share != 0);

        addresses.push(addr);

        shares.push(share);

        emit Added(addr, share);

    }



    /**

     * @dev Adds addresses to list of participants of getting unlocked tokens

     * @param addresses_ An array of addresses of the participant

     * @param shares_ An array of shares of the participants in percents with 2 additional zeroes (1% = 100)

     */

    function addListOfAddresses(address[] addresses_, uint256[] shares_) external onlyOwner {

        require(addresses_.length == shares_.length);

        for (uint256 i = 0; i < addresses_.length; i++) {

            addresses.push(addresses_[i]);

            shares.push(shares_[i]);

            emit Added(addresses_[i], shares_[i]);

        }

    }



    /**

     * @dev Unlocks and transfers respective amount of tokens to participants of this contract

     * @notice This fuction is available only for crowdsale contract

     * @param amount Amount of tokens

     */

    function loose(uint256 amount) public {

        require(msg.sender == crowdsale);

        uint coinBalance = token.balanceOf(address(this));

        if (coinBalance != 0 && addresses.length > 0 && addresses.length == shares.length) {

            if (coinBalance < amount) {

                amount = coinBalance;

            }

            for (uint256 i = 0; i < addresses.length; i++) {

                token.transfer(addresses[i], amount * shares[i] / 10000);

            }

            emit Unlocked(amount);

        }

    }



    /**

     * @dev Allows the current owner to delete every participant of the contract

     */

    function emptyList() external onlyOwner {

        addresses.length = 0;

        shares.length = 0;

    }



    /**

     * @return respective  address and share by his serial number

     * @param id Serial number of the participant of this contract

     */

    function getAddressAndShare(uint256 id) public view returns(address, uint256) {

        return (addresses[id], shares[id]);

    }



    /**

     * @return share of the given address

     */

    function getShare(address addr) external view returns(uint256) {

        for (uint256 i = 0; i < addresses.length; i++) {

            if (addresses[i] == addr) {

                return shares[i];

            }

        }

    }



    /**

     * @return token balance of this contract

     */

    function getBalance() external view returns(uint256) {

        return token.balanceOf(address(this));

    }

}