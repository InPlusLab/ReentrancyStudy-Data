/**
 *Submitted for verification at Etherscan.io on 2020-08-01
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-29
*/

pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

interface Bank {
    function index() external view returns (uint256);

    function accounts(uint256) external view returns (address);

    function indexes(address) external view returns (uint256);

    function accountSupplySnapshot(address, address)
        external
        view
        returns (uint256);

    function accountBorrowSnapshot(address, address)
        external
        view
        returns (uint256);
}

contract CallHelper is Initializable {
    address public admin;

    address public proposedAdmin;

    Bank public bank;

    struct User {
        address addr;
        uint256 balance;
    }

    function initialize(address _bank) public initializer {
        admin = msg.sender;
        bank = Bank(_bank);
    }

    function setBank(address _bank) public onlyAdmin {
        bank = Bank(_bank);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can do this!");
        _;
    }

    function proposeNewAdmin(address admin_) external onlyAdmin {
        proposedAdmin = admin_;
    }

    function claimAdministration() external {
        require(msg.sender == proposedAdmin, "Not proposed admin.");
        admin = proposedAdmin;
        proposedAdmin = address(0);
    }

    function getAccountSupplyState(address token)
        public
        view
        returns (User[] memory)
    {
        uint256 index = bank.index();
        User[] memory res = new User[](index - 1);
        for (uint256 i = 1; i < index; ++i) {
            address addr = bank.accounts(i);
            uint256 balance = bank.accountSupplySnapshot(token, addr);
            res[i - 1] = User({addr: addr, balance: balance});
        }

        return res;
    }

    function getAccountSupplyStatePaging(
        address token,
        uint256 start,
        uint256 end
    ) public view returns (User[] memory) {
        require(start > 0, "start must be greater than 0");
        require(start < end, "start must be less than end");
        uint256 index = bank.index();
        uint256 last = min(index, end);
        User[] memory res = new User[](last - start);
        for (uint256 i = start; i < last; ++i) {
            address addr = bank.accounts(i);
            uint256 balance = bank.accountSupplySnapshot(token, addr);
            res[i - start] = User({addr: addr, balance: balance});
        }
        return res;
    }

    function getAccountBorrowState(address token)
        public
        view
        returns (User[] memory)
    {
        uint256 index = bank.index();
        User[] memory res = new User[](index - 1);
        for (uint256 i = 1; i < index; ++i) {
            address addr = bank.accounts(i);
            uint256 balance = bank.accountBorrowSnapshot(token, addr);
            res[i - 1] = User({addr: addr, balance: balance});
        }

        return res;
    }

    function getAccountBorrowStatePaging(
        address token,
        uint256 start,
        uint256 end
    ) public view returns (User[] memory) {
        require(start > 0, "start must be greater than 0");
        require(start < end, "start must be less than end");
        uint256 index = bank.index();
        uint256 last = min(index, end);
        User[] memory res = new User[](last - start);
        for (uint256 i = start; i < last; ++i) {
            address addr = bank.accounts(i);
            uint256 balance = bank.accountBorrowSnapshot(token, addr);
            res[i - start] = User({addr: addr, balance: balance});
        }
        return res;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }
}