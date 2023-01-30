pragma solidity 0.5.8;

import "./SafeMath.sol";

contract PLincSlots {
    
    using SafeMath for uint256;
    
    struct Spin {
        uint256 betValue;
        uint256 numberOfBets;
        uint256 startBlock;
        bool open;
    }
    
    mapping(address => Spin) public playerSpin;
    
    uint256 public totalSpins;
    
    address private hubAddress;
    IGamesHub private hubContract;
    
    uint256 public maxBet;
    
    event Win(address indexed player, uint256 amount, uint256 reel1, uint256 reel2, uint256 reel3);
    event Loss(address indexed player, uint256 amount);
    
    constructor(address gameHubAddress)
        public
    {
        hubAddress = gameHubAddress;
        hubContract = IGamesHub(gameHubAddress);
        
        maxBet = 0.1 ether;
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
    
    function play(address playerAddress, uint256 totalBetValue, bytes calldata gameData)
        external
        onlyHub(msg.sender)
    {
        bytes memory data = gameData;
        uint256 betValue;
        assembly {
            betValue := mload(add(data, add(0x20, 0)))
        }
        playInternal(playerAddress, totalBetValue, betValue);
    }
    
    function playWithBalance(uint256 totalBetValue, uint256 betValue)
        external
    {   
        hubContract.subPlayerBalance(msg.sender, totalBetValue);
        playInternal(msg.sender, totalBetValue, betValue);
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
        returns(uint256 numberOfBets, uint256[10] memory reel1, uint256[10] memory reel2, uint256[10] memory reel3)
    {
        Spin storage spin = getCurrentPlayerSpin(msg.sender);
        
        require(block.number - 256 <= spin.startBlock);
        
        numberOfBets = spin.numberOfBets;
        
        initReels(reel1);
        initReels(reel2);
        initReels(reel3);
        
        bytes20 senderXORcontract = bytes20(msg.sender) ^ bytes20(address(this));
        bytes32 hash = blockhash(spin.startBlock) ^ senderXORcontract;
        
        if(block.number > spin.startBlock) {
            uint256 counter = 0;
            for(uint256 i = 0; i < numberOfBets; i++) {
                reel1[i] = uint8(hash[counter++]) % 5;
                reel2[i] = uint8(hash[counter++]) % 5;
                reel3[i] = uint8(hash[counter++]) % 5;
            }
        }
    }
    
    function initReels(uint256[10] memory reel)
        private
        pure
    {
        for(uint256 i = 0; i < 10; i++) {
            reel[i] = 42;
        }
    }
    
    function getCurrentPlayerSpin(address playerAddress)
        private
        view
        returns (Spin storage)
    {
        return playerSpin[playerAddress];
    }
    
    function playInternal(address playerAddress, uint256 totalBetValue, uint256 betValue)
        private
    {
        require(betValue <= maxBet);
        
        uint256 numberOfBets = totalBetValue / betValue;
        require(numberOfBets > 0 && numberOfBets <= 10);
        
        Spin storage spin = getCurrentPlayerSpin(playerAddress);
        
        if(spin.open) {
            resolveInternal(playerAddress, spin);
        }
        
        playerSpin[playerAddress] = Spin(betValue, numberOfBets, block.number, true);
        
        totalSpins+= numberOfBets;
    }
    
    function resolveInternal(address playerAddress, Spin storage spin)
        private
    {
        require(block.number > spin.startBlock);
        
        spin.open = false;
        
        if(block.number - 256 > spin.startBlock) {
            emit Loss(playerAddress, spin.betValue.mul(spin.numberOfBets));
            return;
        }
        
        bytes20 senderXORcontract = bytes20(playerAddress) ^ bytes20(address(this));
        bytes32 hash = blockhash(spin.startBlock) ^ senderXORcontract;
        
        uint256 counter = 0;
        uint256 totalAmountWon = 0;
        for(uint256 i = 0; i < spin.numberOfBets; i++) {
            uint8 reel1 = uint8(hash[counter++]) % 5;
            uint8 reel2 = uint8(hash[counter++]) % 5;
            uint8 reel3 = uint8(hash[counter++]) % 5;
            uint256 multiplier = 0;
            if(reel1 + reel2 + reel3 == 0) {
                multiplier = 20;
            } else if(reel1 == reel2 && reel1 == reel3) {
                multiplier = 7;
            } else if(reel1 + reel2 == 0 || reel1 + reel3 == 0 || reel2 + reel3 == 0) {
                multiplier = 2;
            } else if(reel1 == 0 || reel2 == 0 || reel3 == 0) {
                multiplier = 1;
            }
            
            if(multiplier > 0) {
                uint256 amountWon = spin.betValue.mul(multiplier);
                totalAmountWon = totalAmountWon.add(amountWon);
                emit Win(playerAddress, amountWon, reel1, reel2, reel3);
            } else {
                emit Loss(playerAddress, spin.betValue);
            } 
        }
        
        if(totalAmountWon > 0) {
            hubContract.addPlayerBalance(playerAddress, totalAmountWon);
        }
    }
}

interface IGamesHub {
    function addPlayerBalance(address playerAddress, uint256 value) external;
    function subPlayerBalance(address playerAddress, uint256 value) external;
}
