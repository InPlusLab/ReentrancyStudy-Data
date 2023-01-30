pragma solidity 0.5.8;

import "./PermissionService.sol";
import "./IRegulatorService.sol";

contract RegulatedToken is PermissionService {
    string public name = "SCI Equity Token";
    string public symbol = "SCI";
    uint8 public decimals = 8;
    string public CIK = "0001782615";

    IRegulatorService public regulatorService;

    event TokensRecovered(address _from, address _to, uint _amount);

    constructor(address _regulatorService) public {
        regulatorService = IRegulatorService(_regulatorService);
        _totalSupply = 0;
    }

    function replaceRegulatorService(address _newRegulatorService) public onlyReplaceRegulatorServicePermission {
        regulatorService = IRegulatorService(_newRegulatorService);
    }

    function changeSymbol(string memory _newSymbol) public onlyAttributesPermission {
        symbol = _newSymbol;
    }

    function changeCIK(string memory _newCIK) public onlyAttributesPermission {
        CIK = _newCIK;
    }

    function changename(string memory _newName) public onlyAttributesPermission {
        name = _newName;
    }

    function addWhitelisted(address _account, string memory _iso) public onlyAddWhitelistPermission {
        require(regulatorService.canAddToWhitelist(_account, _iso), "Regulator service is not allowed add this account to whitelist");
        super.addWhitelisted(_account, _iso);
    }

    function removeWhitelisted(address _account) public onlyRemoveWhitelistPermission {
        (bool _isWhitelistedAccount, string memory _iso) = isWhitelisted(_account);

        require(_isWhitelistedAccount, "Account is not whitelisted");
        require(regulatorService.canRemoveFromWhitelist(_account, _iso), "Regulator service is not allowed remove this account from whitelist");

        super.removeWhitelisted(_account);
    }

    function transfer(address _to, uint _amount) public onlyUnlocked returns(bool) {
        (bool _isWhitelistedFrom, string memory _isoFrom) = isWhitelisted(msg.sender);
        (bool _isWhitelistedTo, string memory _isoTo) = isWhitelisted(_to);

        require (_isWhitelistedFrom && _isWhitelistedTo, "Sender or recipient is not whitelisted");
        require(regulatorService.canTransfer(msg.sender, _isoFrom, _to, _isoTo, _amount), "Regulator service is not allowed to transfer");

        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint _amount) public onlyUnlocked returns(bool) {
        (bool _isWhitelistedFrom, string memory _isoFrom) = isWhitelisted(_from);
        (bool _isWhitelistedTo, string memory _isoTo) = isWhitelisted(_to);

        require (_isWhitelistedFrom && _isWhitelistedTo, "Sender or recipient is not whitelisted");
        require(regulatorService.canTransfer(_from, _isoFrom, _to, _isoTo, _amount), "Regulator service is not allowed to make the transfer");

        return super.transferFrom(_from, _to, _amount);
    }

    function mint(address _for, uint _amount) public onlyMintablePermission {
        (bool _isWhitelisted, string memory _iso) = isWhitelisted(_for);
        require(_isWhitelisted, "Recipient is not whitelisted");
        require(regulatorService.canMint(_for, _iso, _amount), "Regulator service is not allowed this minting");

        _mint(_for, _amount);
    }

    function recoveryTokens(address _from, address _to) public onlyRecoveryTokensPermission {
        require(regulatorService.canRecoveryTokens(_from, _to), "Regulator service is not allowed this token recovery");

        (bool _isWhitelisted, string memory _iso) = isWhitelisted(_from);
        require(_isWhitelisted, "Account from is not whitelisted");

        uint balance = balanceOf(_from);

        removeWhitelisted(_from);
        addWhitelisted(_to, _iso);

        _burn(_from, balance);
        mint(_to, balance);

        emit TokensRecovered(_from, _to, balance);
    }
}