pragma solidity 0.5.8;



import "./SafeMath.sol";



contract PLincSlots {

    

    using SafeMath for uint256;

    

    struct Spin {

        uint256 value;

        uint256 startBlock;

        uint256 multiplier;

        bool open;

    }

    

    mapping(address => Spin) public playerSpin;

    

    uint256 public totalSpins;

    

    address private hubAddress;

    IGamesHub private hubContract;

    

    uint256 public maxBet;

    uint256 public maxMultiplier;

    

    event Win(address indexed player, uint256 amount, uint256 reel1, uint256 reel2, uint256 reel3);

    event Loss(address indexed player, uint256 amount);

    

    constructor(address gameHubAddress)

        public

    {

        hubAddress = gameHubAddress;

        hubContract = IGamesHub(gameHubAddress);

        

        maxBet = 0.1 ether;

        maxMultiplier = 20;

    }

    

    modifier onlyHub(address sender)

    {

        require(sender == hubAddress);

        _;

    }

    

    modifier onlyDev()

    {

        require(msg.sender == address(0x1EB2acB92624DA2e601EEb77e2508b32E49012ef));

        _;

    }

    

    function play(address playerAddress, uint256 value, bytes calldata gameData)

        external

        onlyHub(msg.sender)

    {

        require(value <= maxBet);

        

        playInternal(playerAddress, value);

    }

    

    function playWithBalance(uint256 value)

        external

    {   

        hubContract.subPlayerBalance(msg.sender, value);

        playInternal(msg.sender, value);

    }

    

    function resolveSpin()

        external

    {

        Spin storage spin = getCurrentPlayerSpin(msg.sender);

        require(spin.open);

        

        resolveInternal(msg.sender, spin);

    }

    

    function setMaxBet(uint256 newMaxBet)

        external

        onlyDev

    {

        require(newMaxBet > 0);

        

        maxBet = newMaxBet;

    }

    

    function setMaxMultiplier(uint256 newMaxMultiplier)

        external

        onlyDev

    {

        require(newMaxMultiplier >= 20);

        

        maxMultiplier = newMaxMultiplier;

    }

    

    function hasActiveSpin()

        external

        view

        returns (bool)

    {

        return getCurrentPlayerSpin(msg.sender).open 

        && block.number - 256 <= getCurrentPlayerSpin(msg.sender).startBlock;

    }

    

    function mySpin()

        external

        view

        returns(uint256 reel1, uint256 reel2, uint256 reel3)

    {

        Spin storage spin = getCurrentPlayerSpin(msg.sender);

        

        require(block.number - 256 <= spin.startBlock);

        

        reel1 = reel2 = reel3 = 42;

        

        bytes20 senderXORcontract = bytes20(msg.sender) ^ bytes20(address(this));

        

        if(block.number > spin.startBlock) {

            reel1 = uint256(blockhash(spin.startBlock) ^ senderXORcontract) % 5;

        }

        

        if(block.number > spin.startBlock + 1) {

            reel2 = uint256(blockhash(spin.startBlock + 1) ^ senderXORcontract) % 5;

        }

        

        if(block.number > spin.startBlock + 2) {

            reel3 = uint256(blockhash(spin.startBlock + 2) ^ senderXORcontract) % 5;

        }

    }

    

    function getCurrentPlayerSpin(address playerAddress)

        private

        view

        returns (Spin storage)

    {

        return playerSpin[playerAddress];

    }

    

    function playInternal(address playerAddress, uint256 value)

        private

    {

        Spin storage spin = getCurrentPlayerSpin(playerAddress);

        

        if(spin.open) {

            resolveInternal(playerAddress, spin);

        }

        

        playerSpin[playerAddress] = Spin(value, block.number, 0, true);

        

        totalSpins++;

    }

    

    function resolveInternal(address playerAddress, Spin storage spin)

        private

    {

        require(block.number > spin.startBlock + 2);

        

        spin.open = false;

        

        if(block.number - 256 > spin.startBlock) {

            emit Loss(playerAddress, spin.value);

            return;

        }

        

        bytes20 senderXORcontract = bytes20(playerAddress) ^ bytes20(address(this));

        

        uint256 reel1 = uint256(blockhash(spin.startBlock) ^ senderXORcontract) % 5;

        uint256 reel2 = uint256(blockhash(spin.startBlock + 1) ^ senderXORcontract) % 5;

        uint256 reel3 = uint256(blockhash(spin.startBlock + 2) ^ senderXORcontract) % 5;

        

        if(reel1 + reel2 + reel3 == 0) {

            spin.multiplier = maxMultiplier;

        } else if(reel1 == reel2 && reel1 == reel3) {

            spin.multiplier = 7;

        } else if(reel1 + reel2 == 0 || reel1 + reel3 == 0 || reel2 + reel3 == 0) {

            spin.multiplier = 2;

        } else if(reel1 == 0 || reel2 == 0 || reel3 == 0) {

            spin.multiplier = 1;

        }

        

        if(spin.multiplier > 0) {

            uint256 amountWon = spin.value.mul(spin.multiplier);

            hubContract.addPlayerBalance(playerAddress, amountWon);

            

            emit Win(playerAddress, amountWon, reel1, reel2, reel3);

        } else {

            emit Loss(playerAddress, spin.value);

        }

    }

}



interface IGamesHub {

    function addPlayerBalance(address playerAddress, uint256 value) external;

    function subPlayerBalance(address playerAddress, uint256 value) external;

}

