pragma solidity >=0.5.8 <0.7.0;

import "./MinimeToken.sol";


contract StonToken is MiniMeToken {
    uint256 public constant maxSupply = 370 * 10**6 * 10**8;

    bool public mintingDone = false;

    // whitelist state
    address public whitelistManager;
    mapping(address => bool) public whitelist;

    event WhitelistEdit(address indexed subject, bool indexed status);
    event WhitelistManagerChange(address indexed manager);

    constructor() public MiniMeToken(
        address(0), // no parent token
        0,          // no snapshot block number
        "STON",     // token name
        8,          // decimals
        "STON",     // symbol
        false       // disable transfers for minting
    ) {
        whitelistManager = msg.sender;
        emit WhitelistManagerChange(msg.sender);
    }

    // minting functionality

    function mint(address[] memory _recipients, uint256[] memory _amounts) public onlyOwner {
        require(!mintingDone);
        require(_recipients.length == _amounts.length);
        require(_recipients.length < 255);

        for (uint8 i = 0; i < _recipients.length; i++) {
            address recipient = _recipients[i];
            uint256 amount = _amounts[i];

            require(generateTokens(recipient, amount));
        }
    }

    function finishMinting() public onlyOwner {
        require(!mintingDone);

        // check hard cap
        assert(totalSupply() <= maxSupply);

        enableTransfers(true);
        mintingDone = true;
    }

    // whitelist functionality

    function addWhitelist(address _subject) public returns (bool) {
        return modifyWhitelist(_subject, true);
    }

    function removeWhitelist(address _subject) public returns (bool) {
        return modifyWhitelist(_subject, false);
    }

    function modifyWhitelist(address _subject, bool _status) internal returns (bool) {
        require(msg.sender == whitelistManager, "Only the whitelist manager can edit it.");

        if (_status == whitelist[_subject]) {
            // no change to whitelist
            return false;
        }

        whitelist[_subject] = _status;
        emit WhitelistEdit(_subject, _status);
        return true;
    }

    function modifyWhitelistMultiple(address[] memory _subjects, bool _status) public {
        require(msg.sender == whitelistManager, "Only the whitelist manager can edit it.");
        require(_subjects.length < 255);

        for (uint8 i = 0; i < _subjects.length; i++) {
            address subject = _subjects[i];
            // note: does not check the current whitelist state (like modifyWhitelist)
            //       to save gas - consequently the function always emits an event, even
            //       if the whitelist status of an address does not change
            whitelist[subject] = _status;
            emit WhitelistEdit(subject, _status);
        }
    }

    function changeWhitelistManager(address _manager) public onlyOwner {
        whitelistManager = _manager;
        emit WhitelistManagerChange(_manager);
    }
}
