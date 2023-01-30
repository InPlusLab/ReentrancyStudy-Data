/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

pragma solidity ^0.5.9;

contract CryptoKingdoms
{
    uint public constant gameNumber = 8;
    
    address public constant previousGameAddress = 0x2c8dc01FB73c7079cC8A9e7a339C172Bbf2d3EbC;
    
    address public nextGameAddress;
    
    enum Race
    {
        None,
        Humane
    }

    struct Kingdom
    {
        Race race;

        string name;

        uint actions;
        
        uint gold;
        
        uint soldiers;
        uint spies;
        uint wizards;
        uint dragons;
        
        uint hovels;
        uint miningCamps;
        uint banks;
        uint barracks;
        uint castles;
    }
    
    Kingdom public winner;
    uint winnerPrize;
    
    uint constant defaultJoinDuration = 26 days;
    uint constant defaultGameDuration = 33 days;
    uint constant defaultTurnTime = 11 hours;
    
    uint constant joinGameCost = 0.0225 ether;
    
    uint constant soldierCost = 3;
    uint constant spyCost = 100;
    uint constant wizardCost = 250;
    uint constant dragonCost = 3000;
    uint constant hovelCost = 100;
    uint constant miningCampCost = 1000;
    uint constant bankCost = 1500;
    uint constant barracksCost = 300;
    uint constant castleCost = 15000;
    
    uint constant soldierAttack = 1;
    uint constant spyAttack = 5;
    uint constant wizardAttack = 100;
    uint constant dragonAttack = 500;
    
    uint constant barracksDefence = 5;
    uint constant castleDefence = 1000;
    
    uint constant wizardGoldPerTurn = 20;
    uint constant hovelGoldPerTurn = 5;
    uint constant miningCampGoldPerTurn = 150;

    uint constant bankedGoldPerUnitGoldPerTurn = 50;
    uint constant bankLimit = 15;
    
    uint constant barracksSoldiersPerTurn = 25;
    uint constant castleSoldiersPerTurn = 50;
    
    uint constant hovelCapacity = 3;
    
    uint constant espionageCost = 25;
    
    address payable[] private players;
    address payable private host;
    
    mapping (address => Kingdom) private kingdoms;
    
    uint gameTurnTime = defaultTurnTime;
    uint gameDuration = defaultGameDuration;
    uint gameJoinDuration = defaultJoinDuration;
    uint gameTotalTurns;
    uint gameStartTime;
    uint gameEndTime;
    
    uint hostFees;
    
    uint currentTurnNumber;
    uint leaderPlayerIndex;
    uint espionageInformationType;
    
    event turnCompleted();
    event newPlayerJoined(string playerName);
    event attackCompleted(uint goldExchanged, uint soldierDeaths, uint wizardDeaths, uint dragonDeaths);
    event spyReported(string name, uint detail, uint info, uint moreInfo);
    event sabotaged(uint sabotagedGold, uint sabotagedDragons, uint sabotagedHovels, uint sabotagedMiningCamps, uint sabotagedBanks, uint dragonsKilled);
    event hostMessage(string message);
    event gameEnded();
    
    constructor (uint joinTimeSeconds, uint gameTimeSeconds, uint turnTimeSeconds) public
    {
        if (joinTimeSeconds > 0)
        {
            gameJoinDuration = joinTimeSeconds;
        }
        
        if (gameTimeSeconds > 0)
        {
            gameDuration = gameTimeSeconds;
        }
        
        if (turnTimeSeconds > 0)
        {
            gameTurnTime = turnTimeSeconds;
        }
        
        gameStartTime = block.timestamp + gameJoinDuration;
        gameEndTime = gameStartTime + gameDuration;
        gameTotalTurns = (gameDuration / gameTurnTime) + 1; // +1 for the last turn
        host = msg.sender;
    }
    
    function gameStats() public view returns (uint version,
                                              uint numberPlayers,
                                              uint totalGold,
                                              uint totalPrizePool,
                                              uint gameStartTimeSeconds,
                                              uint gameDurationSeconds,
                                              uint gameTurns,
                                              uint gameTurnTimeSeconds,
                                              uint gameCurrentTurn,
                                              uint gameLeaderIndex)
    {
        for (uint playerIndex = 0; playerIndex < players.length; playerIndex++)
        {
            address playerAddress = players[playerIndex];
            Kingdom storage kingdom = kingdoms[playerAddress];
            totalGold += kingdom.gold;
        }
        return (gameNumber, players.length, totalGold, winnerPrize,
                gameStartTime, gameDuration,
                gameTotalTurns, gameTurnTime,
                currentTurnNumber,
                leaderPlayerIndex);
    }
    
    
    //  === Host Functions ===
    
    modifier onlyHost()
    {
        require(msg.sender == host);
        _;
    }
    
    modifier onlyIfGameStarted()
    {
        require(block.timestamp > gameStartTime);
        _;
    }
    
    modifier onlyIfTurnTime()
    {
        if (block.timestamp < gameEndTime)
        {
            uint time = block.timestamp;
            uint turnsRemaining = ((gameEndTime - time) / gameTurnTime) + 1; // For game start turn.
            uint blocktimeTurnNumber = gameTotalTurns - turnsRemaining;
            require(currentTurnNumber < blocktimeTurnNumber);
        }
        else
        {
            require(currentTurnNumber < gameTotalTurns);
        }
        _;
    }
    
    // Called by the game host (at most) every gameTurnTime to update the game state and to allow players to progress.
    function turn() public onlyIfGameStarted() onlyIfTurnTime()
    {
        uint turnsToUpdate = 0;
        if (block.timestamp < gameEndTime)
        {
            uint turnsRemaining = ((gameEndTime - block.timestamp) / gameTurnTime) + 1;
            uint blocktimeTurnNumber = gameTotalTurns - turnsRemaining;
            turnsToUpdate = blocktimeTurnNumber - currentTurnNumber;
        }
        else
        {
            turnsToUpdate = gameTotalTurns - currentTurnNumber;
        }
        
        leaderPlayerIndex = 0;
        uint maxPlayerRank = 0;
        
        for (uint playerIndex = 0; playerIndex < players.length; playerIndex++)
        {
            address player = players[playerIndex];
            Kingdom storage kingdom = kingdoms[player];
            kingdom.actions += turnsToUpdate;
            kingdom.gold += (kingdom.hovels * hovelGoldPerTurn
                           + kingdom.miningCamps * miningCampGoldPerTurn
                           + kingdom.wizards * wizardGoldPerTurn
                           + (kingdom.banks * (kingdom.gold / bankedGoldPerUnitGoldPerTurn))) * turnsToUpdate;
            kingdom.soldiers += (kingdom.barracks * barracksSoldiersPerTurn + kingdom.castles * castleSoldiersPerTurn) * turnsToUpdate;
            
            uint estimatedPlayerRank = kingdom.gold * ((currentTurnNumber * 100) / (gameTotalTurns * 100))
                                   + ((kingdom.soldiers * soldierCost) + (kingdom.wizards * wizardCost) + (kingdom.dragons * dragonCost)
                                    + (kingdom.hovels * hovelCost) + (kingdom.miningCamps * miningCampCost) + (kingdom.banks * bankCost)
                                    + (kingdom.barracks * barracksCost)) * (gameTotalTurns / 4);
            if (estimatedPlayerRank > maxPlayerRank)
            {
                maxPlayerRank = estimatedPlayerRank;
                leaderPlayerIndex = playerIndex;
            }
        }
        
        currentTurnNumber += turnsToUpdate;
        
        if (currentTurnNumber == gameTotalTurns)
        {
            endGame();
        }
        
        emit turnCompleted();
    }
    
    function endGame() private
    {
        uint largestGoldAmount = 0;
        address payable winnerAddress;
        for (uint playerIndex = 0; playerIndex < players.length; playerIndex++)
        {
            address payable playerAddress = players[playerIndex];
            Kingdom storage kingdom = kingdoms[playerAddress];
            if (kingdom.gold > largestGoldAmount)
            {
                largestGoldAmount = kingdom.gold;
                winnerAddress = playerAddress;
            }
        }
        
        winner = kingdoms[winnerAddress];
        winnerAddress.transfer(winnerPrize);
        host.transfer(hostFees);
    }
    
    function setNextGame(address gameAddress) public onlyHost()
    {
        nextGameAddress = gameAddress;
    }
    
    // The game host reserves the right to modify abusive kingdom names.
    function changeKingdomName(uint kingdomIndex, string memory newName) public onlyHost()
    {
        address payable playerAddress = players[kingdomIndex];
        Kingdom storage kingdom = kingdoms[playerAddress];
        kingdom.name = newName;
    }
    
    function message(string memory s) public onlyHost()
    {
        emit hostMessage(s);
    }
    
    
    //  === Player Functions ===

    modifier onlyIfNewPlayer()
    {
        // No existing kingdom for sender address.
        require(kingdoms[msg.sender].race == Race.None);
        require(currentTurnNumber < gameTotalTurns);
        require(msg.value == joinGameCost);
        _;
    }
    
    modifier onlyIfTurnsRemaining()
    {
        require(currentTurnNumber < gameTotalTurns);
        _;
    }
    
    modifier onlyIfValidPlayerIndex(uint playerIndex)
    {
        require(playerIndex < players.length);
        _;
    }
    
    modifier onlyIfOtherPlayerIndex(uint otherPlayerIndex)
    {
        address otherPlayer = players[otherPlayerIndex];
        require(msg.sender != otherPlayer);
        _;
    }
    
    modifier onlyIfActions()
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        require(kingdom.actions > 0);
        _;
    }
    
    modifier onlyIfGold(uint goldCost)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        require(kingdom.gold >= goldCost);
        _;
    }
    
    modifier onlyIfHovels(uint amount)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        require(kingdom.hovels >= ((kingdom.spies + kingdom.wizards + amount) / hovelCapacity));
        _;
    }

    modifier onlyIfUnderBankLimit(uint amount)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        require((kingdom.banks + amount) <= bankLimit);
        _;
    }

    modifier onlyIfSpies()
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        require(kingdom.spies > 0);
        _;
    }
    
    modifier onlyIfWizards(uint number)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        require(kingdom.wizards > 0);
        _;
    }
    
    modifier onlyIfDragons()
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        require(kingdom.dragons > 0);
        _;
    }
    
    function joinGame(string memory playerName) public payable onlyIfNewPlayer() onlyIfTurnsRemaining()
    {
        winnerPrize += (msg.value * 7) / 10;
        hostFees += (msg.value * 3) / 10;
        
        kingdoms[msg.sender] = Kingdom({
            race: Race.Humane,
            name: playerName,
            actions: currentTurnNumber,
            gold: 1320 + (currentTurnNumber * hovelGoldPerTurn * 5),
            soldiers: 25,
            spies: 0,
            wizards: 0,
            dragons: 0,
            hovels: 3,
            miningCamps: 1,
            banks: 0,
            barracks: 0,
            castles: 0
        });
        
        players.push(msg.sender);
        
        emit newPlayerJoined(playerName);
    }

    function playerStats() public view
             returns (Race race, string memory kingdomName, uint actions, uint gold,
                      uint soldiers, uint spies, uint wizards, uint dragons,
                      uint hovels, uint miningCamps, uint banks, uint barracks, uint castles)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        return (kingdom.race, kingdom.name, kingdom.actions, kingdom.gold,
                kingdom.soldiers, kingdom.spies, kingdom.wizards, kingdom.dragons,
                kingdom.hovels, kingdom.miningCamps, kingdom.banks, kingdom.barracks, kingdom.castles);
    }
    
    function playerAtIndex(uint playerIndex) public view
             onlyIfValidPlayerIndex(playerIndex)
             returns (string memory playerName)
    {
        address playerAddress = players[playerIndex];
        Kingdom storage kingdom = kingdoms[playerAddress];
        return kingdom.name;
    }
    
    // === Player Actions ===

    function recruitSoldiers(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * soldierCost)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * soldierCost;
        kingdom.soldiers += amount;
        kingdom.actions -= 1;
    }

    function recruitSpies(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * spyCost) onlyIfHovels(amount)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * spyCost;
        kingdom.spies += amount;
    }
    
    function summonWizards(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * wizardCost) onlyIfHovels(amount)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * wizardCost;
        kingdom.wizards += amount;
        kingdom.actions -= 1;
    }
    
    function trainDragons(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * dragonCost)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * dragonCost;
        kingdom.dragons += amount;
        kingdom.actions -= 1;
    }

    function buildHovels(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * hovelCost)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * hovelCost;
        kingdom.hovels += amount;
        kingdom.actions -= 1;
    }

    function buildBarracks(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * barracksCost)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * barracksCost;
        kingdom.barracks += amount;
        kingdom.actions -= 1;
    }

    function buildMiningCamps(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * miningCampCost)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * miningCampCost;
        kingdom.miningCamps += amount;
        kingdom.actions -= 1;
    }
    
    function buildBanks(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * bankCost) onlyIfUnderBankLimit(amount)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * bankCost;
        kingdom.banks += amount;
        kingdom.actions -= 1;
    }

    function buildCastles(uint amount) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfGold(amount * castleCost)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= amount * castleCost;
        kingdom.castles += amount;
        kingdom.actions -= 1;
    }

    function attack(uint targetPlayerIndex, uint numberOfSoldiers) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfOtherPlayerIndex(targetPlayerIndex)
    {
        Kingdom storage attackingKingdom = kingdoms[msg.sender];
        require(attackingKingdom.soldiers >= numberOfSoldiers);
        
        address targetPlayer = players[targetPlayerIndex];        
        Kingdom storage defendingKingdom = kingdoms[targetPlayer];
        
        uint goldExchanged = 0;
        
        uint randomValue = (uint(keccak256(abi.encodePacked(block.timestamp))) << 2) >> ((block.timestamp / 9753) % 7);

        uint attackForce = numberOfSoldiers         * soldierAttack
                         + attackingKingdom.spies   * spyAttack
                         + attackingKingdom.wizards * wizardAttack
                         + attackingKingdom.dragons * dragonAttack
                         + 1;
        attackForce *= 100 + (randomValue % 10);
        attackForce /= 100;

        uint defenceForce = defendingKingdom.soldiers * soldierAttack
                          + defendingKingdom.spies    * spyAttack
                          + defendingKingdom.wizards  * wizardAttack
                          + defendingKingdom.dragons  * dragonAttack
                          + defendingKingdom.barracks * barracksDefence
                          + defendingKingdom.castles  * castleDefence
                          + 1;
        
        uint attackingArmySoldierDeaths = 0;
        uint attackingArmyWizardDeaths = 0;
        uint attackingArmyDragonsDeaths = 0;
        
        if (attackForce > defenceForce)
        {
            // Victory
            
            goldExchanged = (defenceForce * defendingKingdom.gold * 1000000) / (attackForce * 2000000);
            
            attackingArmySoldierDeaths = (defenceForce * numberOfSoldiers * 1000000) / (attackForce * 3000000);
            
            if (defendingKingdom.gold < goldExchanged)
            {
                goldExchanged = defendingKingdom.gold;
            }
            defendingKingdom.gold -= goldExchanged;
            defendingKingdom.soldiers -= (defenceForce * defendingKingdom.soldiers * 1000000) / (attackForce * 4000000);
            
            goldExchanged += randomValue % (currentTurnNumber * 3); // We found this along the way!
            attackingKingdom.gold += goldExchanged;
            attackingKingdom.soldiers -= attackingArmySoldierDeaths;
        }
        else
        {
            // Defeat
            
            defendingKingdom.soldiers -= (attackForce * defendingKingdom.soldiers * 250000) / (defenceForce * 1000000);
            
            if (numberOfSoldiers > 0)
            {
                attackingArmySoldierDeaths = randomValue % numberOfSoldiers;
                attackingKingdom.soldiers -= attackingArmySoldierDeaths;
            }
        }
        
        if (goldExchanged > 0 || attackingArmySoldierDeaths > 0)
        {
            if ((numberOfSoldiers * soldierAttack) < // Whirlwind Attack
                ((attackingKingdom.spies * spyAttack) + (attackingKingdom.wizards * wizardAttack) + (attackingKingdom.dragons * dragonAttack)))
            {
                attackingArmyWizardDeaths = attackingKingdom.wizards / ((randomValue % 5) + 4);
                attackingArmyDragonsDeaths = attackingKingdom.dragons / ((randomValue % 3) + 3);
            }
            else
            {
                attackingArmyWizardDeaths = attackingKingdom.wizards / ((randomValue % 6) + 6);
                attackingArmyDragonsDeaths = attackingKingdom.dragons / ((randomValue % 9) + 7);
            }
            attackingKingdom.wizards -= attackingArmyWizardDeaths;
            attackingKingdom.dragons -= attackingArmyDragonsDeaths;
        
            defendingKingdom.wizards -= defendingKingdom.wizards  / ((randomValue % 7) + 6);
            defendingKingdom.dragons -= defendingKingdom.dragons / ((randomValue % 9) + 9);
        }
        
        attackingKingdom.actions -= 1;
        
        emit attackCompleted(goldExchanged, attackingArmySoldierDeaths, attackingArmyWizardDeaths, attackingArmyDragonsDeaths);
    }

    function espionage(uint targetPlayerIndex) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfSpies() onlyIfActions() onlyIfGold(espionageCost) onlyIfOtherPlayerIndex(targetPlayerIndex)
    {
        Kingdom storage kingdom = kingdoms[msg.sender];
        kingdom.gold -= espionageCost;
        
        address targetPlayer = players[targetPlayerIndex];        
        Kingdom storage defendingKingdom = kingdoms[targetPlayer];
        
        if (kingdom.spies * 2 > defendingKingdom.spies)
        {
            // Success
            
            uint infoType = (currentTurnNumber + espionageInformationType) % 3;
            if (infoType == 0)
            {
                emit spyReported(defendingKingdom.name, 1, defendingKingdom.gold, defendingKingdom.dragons);
            }
            else if (infoType == 1)
            {
                emit spyReported(defendingKingdom.name, 2, defendingKingdom.soldiers, defendingKingdom.banks);
            }
            else if (infoType == 2)
            {
                emit spyReported(defendingKingdom.name, 3, defendingKingdom.miningCamps, defendingKingdom.castles);
            }
            
            espionageInformationType++;
        }
        else
        {
            // Failure
            
            emit spyReported(defendingKingdom.name, 0, kingdom.spies, 0);
        }
    }

    function sabotage(uint targetPlayerIndex) public
             onlyIfGameStarted() onlyIfTurnsRemaining() onlyIfActions() onlyIfDragons() onlyIfOtherPlayerIndex(targetPlayerIndex)
    {
        Kingdom storage attackingKingdom = kingdoms[msg.sender];

        address targetPlayer = players[targetPlayerIndex];
        Kingdom storage defendingKingdom = kingdoms[targetPlayer];
        
        uint attackForce = attackingKingdom.dragons;
        uint defenceForce = defendingKingdom.dragons + defendingKingdom.castles;
        if (attackForce > defenceForce)
        {
            // Victory
            
            uint sabotagedFraction = ((attackForce * 3) / (defenceForce + 1)) + 2;
            uint sabotagedGold = defendingKingdom.gold / (sabotagedFraction * 3);
            uint sabotagedDragons = defendingKingdom.dragons / (sabotagedFraction * 4);
            uint sabotagedHovels = defendingKingdom.hovels / (sabotagedFraction * 5);
            uint sabotagedMiningCamps = defendingKingdom.miningCamps / sabotagedFraction;
            uint sabotagedBanks = defendingKingdom.banks / (sabotagedFraction * 5);
            defendingKingdom.gold -= sabotagedGold;
            defendingKingdom.dragons -= sabotagedDragons;
            defendingKingdom.hovels -= sabotagedHovels;
            defendingKingdom.miningCamps -= sabotagedMiningCamps;
            defendingKingdom.banks -= sabotagedBanks;
            
            uint dragonsKilled = sabotagedDragons * 3 + 2;
            if (dragonsKilled > attackingKingdom.dragons)
            {
                dragonsKilled = attackingKingdom.dragons;
            }
            attackingKingdom.dragons -= dragonsKilled;
            
            emit sabotaged(sabotagedGold, sabotagedDragons, sabotagedHovels, sabotagedMiningCamps, sabotagedBanks, dragonsKilled);
        }
        else
        {
            // Defeat
            
            uint dragonsKilled = attackingKingdom.dragons / 20 + 1;
            attackingKingdom.dragons -= dragonsKilled;
            
            if (defendingKingdom.dragons < dragonsKilled)
            {
                defendingKingdom.dragons = 0;
            }
            else
            {
                defendingKingdom.dragons -= dragonsKilled;
            }
            
            emit sabotaged(0, dragonsKilled, 0, 0, 0, dragonsKilled);
        }
        
        attackingKingdom.actions -= 1;
    }
}