pragma solidity ^0.6.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./Pausable.sol";


contract HHHToken is ERC20,ERC20Detailed,Ownable,Pausable {

    mapping (address => bool) private _frozenAccount;

    event FrozenFunds(address target, bool frozen);

    constructor (
        uint256 initialSupply,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20Detailed(name, symbol, decimals) {
        uint256 totalSupply = initialSupply * 10 ** uint256(decimals);
        _mint(msg.sender, totalSupply);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function freezeAccount(address account, bool freeze)  public onlyOwner {
        _frozenAccount[account] = freeze;
        emit FrozenFunds(account, freeze);
    }

    function isFreeze(address account) public view returns (bool) {
       return _frozenAccount[account];
    }

    function destroy(address  account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function mint(address  account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

     function batchBurn(address[] memory _to,uint256[] memory _value) public onlyOwner {
        for(uint256 i = 0; i < _to.length; i++){
            _burn(_to[i], _value[i]);
        }
    }

     function batchTransfer(address[] memory _to,uint256[] memory _value) public {
        for(uint256 i = 0; i < _to.length; i++){
            transfer(_to[i], _value[i]);
        }
    }

    function batchMint(address[] memory _to,uint256[] memory _value) public onlyOwner {
         for(uint256 i = 0; i < _to.length; i++){
            _mint(_to[i], _value[i]);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");

        require(!isFreeze(from), "This Address is Freeze");

        require(!isFreeze(to),"This Address is Freeze");

    }

}