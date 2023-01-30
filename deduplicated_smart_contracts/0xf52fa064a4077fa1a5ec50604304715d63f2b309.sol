/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

/**
 *Submitted for verification at Etherscan.io on 2019-11-10
*/

/**
 *Submitted for verification at Etherscan.io on 2019-10-13
*/

pragma solidity >=0.5.0;
pragma experimental ABIEncoderV2;

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }
  
  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
  }

}

contract ERC20Interface {
  function name() public view returns (string memory);
  function symbol() public view returns (string memory);
  function decimals() public view returns (uint8);
  function balanceOf(address _owner) public view returns (uint256 balance);
}

contract ERC20BadInterface {
  function name() public view returns (bytes32);
  function symbol() public view returns (bytes32);
  function decimals() public view returns (uint8);
  function balanceOf(address _owner) public view returns (uint256 balance);
}

contract RegistryLookup is Ownable{

    mapping (address => bool) public authorisedStatus;
    event AddNewToken(address newToken);
    event RemoveToken(address token);

    address[] public authorisedTokens;

    function addNewTokens(address[] memory _tokens) public onlyOwner {
        for (uint32 i = 0; i < _tokens.length; i++) {
            authorisedStatus[_tokens[i]] = true;
            authorisedTokens.push(_tokens[i]);
            emit AddNewToken(_tokens[i]);
        }
    }

    function removeTokens(address[] memory _tokens) public onlyOwner {
        for (uint32 i = 0; i < _tokens.length; i++) {
            require(authorisedStatus[_tokens[i]] == true, "token already removed");
            authorisedStatus[_tokens[i]] = false;
            emit RemoveToken(_tokens[i]);
        }
    }

    function getAvailableTokens() public view returns(address[] memory tokens) {
        tokens = new address[](authorisedTokens.length);

        for (uint32 i = 0; i < authorisedTokens.length; i++) {
            if (authorisedStatus[authorisedTokens[i]]) {
                tokens[i] = authorisedTokens[i];
            } else {
                tokens[i] = address(0);
            }
        }
    }

    function bytes32ToString(bytes32 x) private pure returns (string memory) {
      bytes memory bytesString = new bytes(32);
      uint charCount = 0;
      for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
          bytesString[charCount] = char;
          charCount++;
        }
      }
      bytes memory bytesStringTrimmed = new bytes(charCount);
      for (uint32 j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
      }
      return string(bytesStringTrimmed);
    }

    function getTokenName(address tokenAddress) private view returns (string memory){
      // check if bytes32 call returns correctly
      string memory name = bytes32ToString(ERC20BadInterface(tokenAddress).name());
      bytes memory nameBytes = bytes(name);
      if(nameBytes.length <= 1){
        name = ERC20Interface(tokenAddress).name();
      }
      return name;
    }

    function getTokenSymbol(address tokenAddress) private view returns (string memory){
      // check if bytes32 call returns correctly
      string memory symbol = bytes32ToString(ERC20BadInterface(tokenAddress).symbol());
      bytes memory symbolBytes = bytes(symbol);
      if(symbolBytes.length <= 1){
        symbol = ERC20Interface(tokenAddress).symbol();
      }
      return symbol;
    }

    // get name, symbol and decimals for multiple tokens
    function getTokenData(address[] memory _tokens) public view returns (
      string[] memory names, string[] memory symbols, uint[] memory decimals
      ) {
      names = new string[](_tokens.length);
      symbols = new string[](_tokens.length);
      decimals = new uint[](_tokens.length);
      for (uint32 i = 0; i < _tokens.length; i++) {
        names[i] = getTokenName(_tokens[i]);
        symbols[i] = getTokenSymbol(_tokens[i]);
        decimals[i] = ERC20Interface(_tokens[i]).decimals();
      }
    }

    // get external balance of multiple tokens
    function getExternalBalances(address trader, address[] memory assetAddresses) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](assetAddresses.length);
        for (uint i = 0; i < assetAddresses.length; i++) {
            balances[i] = ERC20Interface(assetAddresses[i]).balanceOf(trader);
        }
        return balances;
    }

}