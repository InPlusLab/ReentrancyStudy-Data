/**
 * Copyright (c) 2019 blockimmo AG [email protected]
 * No license
 */

pragma solidity 0.5.7;

import "./Ownable.sol";
import "./ERC20Detailed.sol";

import "./DividendDistributingToken.sol";

contract LandRegistryInterface {
  function getProperty(string memory _eGrid) public view returns (address property);
}

contract LandRegistryProxyInterface {
  function owner() public view returns (address);
  function landRegistry() public view returns (LandRegistryInterface);
}

contract WhitelistInterface {
  function checkRole(address _operator, string memory _permission) public view;
}

contract WhitelistProxyInterface {
  function whitelist() public view returns (WhitelistInterface);
}

/**
 * @title TokenizedProperty
 * @dev An asset-backed security token (a property as identified by its E-GRID (a UUID) in the (Swiss) land registry).
 *
 * Ownership of `this` must be transferred to `ShareholderDAO` before blockimmo will verify `this` as legitimate in `LandRegistry`.
 * Until verified legitimate, transferring tokens is not possible (locked).
 *
 * Tokens can be freely listed on exchanges (especially decentralized / 0x).
 *
 * `this.owner` can make two suggestions that blockimmo will always (try) to take: `setManagementCompany` and `untokenize`.
 * `this.owner` can also transfer or rescind ownership.
 * See `ShareholderDAO` documentation for more information...
 *
 * Our legal framework requires a `TokenizedProperty` must be possible to `untokenize`.
 * Un-tokenizing is also the first step to upgrading or an outright sale of `this`.
 *
 * For both:
 *   1. `owner` emits an `UntokenizeRequest`
 *   2. blockimmo removes `this` from the `LandRegistry`
 *
 * Upgrading:
 *   3. blockimmo migrates `this` to the new `TokenizedProperty` (ie perfectly preserving `this.balances`)
 *   4. blockimmo attaches `owner` to the property (1)
 *   5. blockimmo adds the property to `LandRegistry`
 *
 * Outright sale:
 *   3. blockimmo deploys a new `TokenizedProperty` and adds it to the `LandRegistry`
 *   4. blockimmo configures and deploys a `TokenSale` for the property with `TokenSale.wallet == address(this)`
 *      (raised Ether distributed to current token holders as a dividend payout)
 *        - if the sale is unsuccessful, the new property is removed from the `LandRegistry`, and `this` is added back
 */
contract TokenizedProperty is DividendDistributingToken, ERC20Detailed, Ownable {
  LandRegistryProxyInterface public registryProxy = LandRegistryProxyInterface(0xe72AD2A335AE18e6C7cdb6dAEB64b0330883CD56);  // 0x0f5Ea0A652E851678Ebf77B69484bFcD31F9459B;
  WhitelistProxyInterface public whitelistProxy = WhitelistProxyInterface(0x7223b032180CDb06Be7a3D634B1E10032111F367);  // 0xEC8bE1A5630364292E56D01129E8ee8A9578d7D8;

  uint256 public constant NUM_TOKENS = 1000000;

  modifier isValid() {
    LandRegistryInterface registry = LandRegistryInterface(registryProxy.landRegistry());
    require(registry.getProperty(name()) == address(this), "invalid TokenizedProperty");
    _;
  }

  modifier onlyBlockimmo() {
    require(msg.sender == blockimmo(), "onlyBlockimmo");
    _;
  }

  constructor(string memory _eGrid, string memory _grundstuck) public ERC20Detailed(_eGrid, _grundstuck, 18) {
    uint256 totalSupply = NUM_TOKENS.mul(uint256(10) ** decimals());
    _mint(msg.sender, totalSupply);

    _approve(address(this), blockimmo(), ~uint256(0));  // enable blockimmo to issue `unissued` tokens in the future
  }

  function blockimmo() public view returns (address) {
    return registryProxy.owner();
  }

  function burn(uint256 _value) public isValid {  // buyback
    creditAccount(msg.sender);
    _burn(msg.sender, _value);
  }

  function mint(address _to, uint256 _value) public isValid onlyBlockimmo returns (bool) {  // equity dilution
    creditAccount(_to);
    _mint(_to, _value);
    return true;
  }

  function _transfer(address _from, address _to, uint256 _value) internal isValid {
    whitelistProxy.whitelist().checkRole(_to, "authorized");

    creditAccount(_from);  // required for dividends...
    creditAccount(_to);

    super._transfer(_from, _to, _value);
  }
}
