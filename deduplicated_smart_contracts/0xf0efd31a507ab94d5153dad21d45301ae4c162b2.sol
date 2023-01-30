/**

 *Submitted for verification at Etherscan.io on 2018-12-24

*/



pragma solidity 0.4.25;





library SafeMath {



    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);

        uint256 c = a / b;



        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }

}



contract Ordchain {

    using SafeMath for uint256;



    uint256 constant public ONE_HUNDRED   = 100;

    uint256 constant public INTEREST      = 2;

    uint256 constant public REF_PERCENT   = 5;

    uint256 constant public ADMIN_FEE     = 10;

    uint256 constant public PERIOD        = 1 days;

    uint256 constant public MINIMUM       = 0.01 ether;



    struct User {

        uint256 time;

        uint256 deposit;

        address referrer;

    }



    mapping (address => User) public users;



    address public admin = 0x7C55366d23c0b2AD7AeA112079AE16Ee7b85E8DE;

    uint256 public start = 1546300800;



    event InvestorAdded(address indexed investor);

    event NewDeposit(address indexed investor, uint256 amount);

    event ReferrerAdded(address indexed investor, address indexed referrer);

    event RefBonusPayed(address indexed investor, address indexed referrer, uint256 bonus);

    event DividendsPayed(address indexed investor, uint256 amount);



    function() external payable {

        if (msg.value == 0) {

            withdraw();

        } else {

            invest();

        }

    }



    function invest() public payable {

        require(msg.value >= MINIMUM);



        admin.transfer(msg.value * ADMIN_FEE / ONE_HUNDRED);



        if (users[msg.sender].deposit > 0) {

            withdraw();

        } else {

            emit InvestorAdded(msg.sender);

        }



        users[msg.sender].deposit += msg.value;

        users[msg.sender].time = block.timestamp;



        if (users[msg.sender].referrer != address(0)) {

            users[msg.sender].referrer.transfer(msg.value * REF_PERCENT / ONE_HUNDRED);

            emit RefBonusPayed(msg.sender, users[msg.sender].referrer, msg.value * REF_PERCENT / ONE_HUNDRED);

        } else if (msg.data.length == 20) {

            addReferrer();

        }



        emit NewDeposit(msg.sender, msg.value);

    }



    function withdraw() public {

        uint256 payout = getDividends(msg.sender);

        users[msg.sender].time = block.timestamp;

        msg.sender.transfer(payout);



        emit DividendsPayed(msg.sender, payout);

    }



    function bytesToAddress(bytes source) internal pure returns(address parsedReferrer) {

        assembly {

            parsedReferrer := mload(add(source,0x14))

        }

        return parsedReferrer;

    }



    function addReferrer() internal {

        address refAddr = bytesToAddress(bytes(msg.data));

        if (refAddr != msg.sender) {

            users[msg.sender].referrer = refAddr;



            refAddr.transfer(msg.value * REF_PERCENT / ONE_HUNDRED);



            emit ReferrerAdded(msg.sender, refAddr);

            emit RefBonusPayed(msg.sender, refAddr, msg.value * REF_PERCENT / ONE_HUNDRED);

        }

    }



    function getDaysAfterStart() external view returns(uint256) {

        if (block.timestamp >= start) {

            return (block.timestamp - start) / 1 days;

        }

    }



    function getDeposit(address userAddr) public view returns(uint256) {

        return users[userAddr].deposit;

    }



    function getDividends(address userAddr) public view returns(uint256) {

        return (users[userAddr].deposit.mul(INTEREST).div(ONE_HUNDRED)).mul(block.timestamp.sub(users[userAddr].time)).div(PERIOD);

    }



    function getBalance() external view returns(uint256) {

        return address(this).balance;

    }

}