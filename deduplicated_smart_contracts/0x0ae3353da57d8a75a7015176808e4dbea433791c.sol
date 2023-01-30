pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Capped.sol";

contract MorpheusToken is ERC20, ERC20Detailed, ERC20Capped {
    address public deployerAddress;
    address public gameControllerAddress;

    bool public locked = true;

    // MorpheusGameController will be deployed before the token.
    // We'll deliver the contract game address on deployment of the token
    // Nobody can change this game address after deployment

    constructor(address _deployer, address _gameAddress)
        public
        ERC20Detailed("MorpheusGameToken", "MGT", 18)
        ERC20Capped(500000000 * 1E18)
    {
        deployerAddress = _deployer;
        gameControllerAddress = _gameAddress;
    }

    modifier onlyGameController() {
        require(msg.sender == gameControllerAddress);
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployerAddress);
        _;
    }

    // Function who will be called after the init of gameControllerAddress
    // After this, token won't have any other controller
    function eraseDeployerAddress() public onlyDeployer() {
        deployerAddress = address(0x0);
    }

    // Tokens will be locked untill the liquity added in uniswap
    function unlock() public onlyDeployer {
        locked = false;
    }

    function _isLocked() private view returns (bool) {
        // if crowdsale is finished + 1H ( December 12 - 16h UTC)
        // token are automaticly unlock
        if (now > 1607788800) {
            return true;
        } else {
            return locked;
        }
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        if (_isLocked()) {
            require(
                msg.sender == deployerAddress,
                "Token is locked until December 12 2020 at 16h UTC"
            );
            super.transfer(to, amount);
        } else {
            super.transfer(to, amount);
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        if (_isLocked()) {
            require(
                msg.sender == deployerAddress,
                "Token is locked until December 12 2020 at 16h UTC"
            );
            super.transferFrom(from, to, amount);
        } else {
            super.transferFrom(from, to, amount);
        }
    }

    function burnTokens(uint256 _amount) public {
        _burn(msg.sender, _amount);
    }

    // This is the function used by the gameController Contract for minting token who will be send to the user
    // ONLY GameController can call this function.
    // AND the gameController have only one reference to THIS function (line 288 in GameController.sol):
    // In the __callback()  (line 228 in GameController.sol)
    // This __callback() function can only be called by provableAPI Address. This meens that only return of ORACLE can return a token minting
    function mintTokensForWinner(uint256 _amount) public onlyGameController() {
        _mint(gameControllerAddress, _amount);
    }
}
