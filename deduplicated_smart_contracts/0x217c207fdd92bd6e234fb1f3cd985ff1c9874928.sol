/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.6.6;

contract MagicLamp{
	Pyramid PiZZa = Pyramid(0x91683899ed812C1AC49590779cb72DA6BF7971fE); // Color Token Contract We all know and love
	BlackRock ogBlack = BlackRock(0x429A63F0ccAE3D3f36A6f06eFb5580B0FF66d1e5); // ???
	address THIS = address(this);
	uint wishes; // life of the Genie... no wishes,,, actually granted
	address carpetRider; // stays afloat with a colored kingdom
	uint carpetRiderHP; // health of the carpet rider
	address GENIE; // did a lot of work, and sits back and earns money... burn rugs
	uint GENIE_g; // The generation the genie is on
	ERC20 colorToken;
	address address0 = address(0);
	mapping(address => address) gateway; // this is affiliate uplink thing.
	mapping(address => uint) pocket; // what you earn through affiliates
	mapping(address => bool) initiated;
	mapping(address => bool) ofRugs; // address that belong to rug tokens

	// need 7s for 6s
	address[7][7][7] rugTokens; //for identifying rugToken when buying colored pizza
	mapping(uint8 => mapping(uint8 => mapping(uint8 => bool))) rugsInitiated;

	address the66thCarpetKing; // Dev.

	//LAZY U.I. ... Because we have no events and... yeah
	mapping(uint => address ) rugTokenList;
	uint rugTokenListSize;
	uint genesis;

	constructor() public{
		the66thCarpetKing = msg.sender;
		// Dev starts off as a fragile form of everything.
		GENIE = the66thCarpetKing;
		carpetRider = the66thCarpetKing;
		colorToken = PiZZa.resolveToken();
		gateway[the66thCarpetKing] = the66thCarpetKing;
		initiated[the66thCarpetKing] = true;
		genesis = now;
	}

	function ClaimKingdom___FlyFloatingCastle(uint8 r, uint8 g, uint8 b) external{
		address sender = msg.sender;
		if((
			(r>=0 && r<=3 && g>=0 && g<=3 && b>=0 && b<=3)
			||(rugTokenListSize == 0)
		)&& !rugsInitiated[r][g][b]
		){
			RugToken newRugSource = new RugToken(r, g, b, weight(sender), PiZZa);
			address rugAddress = address(newRugSource);
			rugTokens[r][g][b] = rugAddress;
			timerEnds[rugAddress] = genesis;
			rugTokenList[rugTokenListSize] = rugAddress;
			ofRugs[rugAddress] = true;
			
			if( r!=6 ){
				X[rugAddress] = (rugTokenListSize-1)/8+1;
				Y[rugAddress] = (rugTokenListSize-1)%8+1;
				carpetKing[rugAddress] = sender;
			}else{
				floatingCastle = rugAddress;
			}
			if(rugTokenListSize == 1){
				caravan[rugAddress] = true;
			}

			rugsInitiated[r][g][b] = true;
			rugTokenListSize += 1;
		}else{
			address kingdom = rugTokenList[r];
			if( kingdom == floatingCastle && sender == carpetRider && g>=1 && g<=8 && b>=1 && b<=8 && cooldown[floatingCastle] < now){
				X[floatingCastle] = g;
				Y[floatingCastle] = b;
				resetCooldowns(floatingCastle);
				//Floating Phantom Attacks
			}else{
				revert();
			}
		}
	}

	
	function weight(address addr) internal view returns(uint colors){
		return PiZZa.resolveWeight(addr);//crush friction fee and get around exploit of resolves hopping wallets
	}
	function rugsOf(address addr, address rugColor) public view returns(uint rugCount){
		return RugToken(rugColor).balanceOf(addr);
	}
	function ofRug(address addr) public view returns(bool){
		return ofRugs[addr];
	}

	function buy(address _gateway, uint _red, uint _green, uint _blue) public payable returns(uint bondsCreated){
		
		require(rugTokenListSize == 65);//make sure shit doesn't pop off too early
		address sender = msg.sender;

		//keep colors in check
		if(_red>1e18) _red = 1e18;
		if(_green>1e18) _green = 1e18;
		if(_blue>1e18) _blue = 1e18;
		
		(uint R, uint G, uint B) = colorToCluster(_red,  _green,  _blue);

		address rugAddress = rugTokens[ R ][ G ][ B ];

		if( !initiated[sender] ){
			if(weight(_gateway)==0) _gateway = carpetKing[rugAddress];
			gateway[sender] = _gateway;
			initiated[sender] = true;
		}

		uint createdPiZZa = PiZZa.buy{value: msg.value * 934 / 1000}(sender, _red, _green, _blue);

		if( msg.value > 0.001 ether){
			uint power = createdPiZZa/1e18;
			if(carpetRider != sender){
				if(rugAddress != floatingCastle){

					if( carpetRiderHP <= power ){
						carpetRiderHP = power - carpetRiderHP;

						//erect new floating island
						if(caravan[rugAddress]){
							caravan[floatingCastle] = true;
							caravan[rugAddress] = false;
						}
						//Just a little "chaos theory" ...
						//this is dropping the clock pressure of people who bought at higher prices.
						//hard earned clockPressure dropping.
						dropClockPressure(floatingCastle);
						X[floatingCastle] = X[rugAddress];
						Y[floatingCastle] = Y[rugAddress];
						floatingCastle = rugAddress;

						endRound(THIS);//new Caravan Round

						carpetRider = sender;
					}else{		
						carpetRiderHP -= power;
					}
				}
			}else{
				if(rugAddress == floatingCastle){
					carpetRiderHP += power;
				}
			}

			if(wishes > 0)
				wishes -= 1;
			
			uint rugsToMake = createdPiZZa/1e18;
			if(rugsToMake>0)
				RugToken(rugAddress).mint(msg.sender, rugsToMake);

			if(wishes == 0){
				if(rugBurnRecordSetter[GENIE_g] != address0){
					GENIE = rugBurnRecordSetter[GENIE_g];
					wishes = burnCount[ GENIE_g ][rugBurnRecordSetter[GENIE_g]];
					GENIE_g += 1;
				}
			}
		}

		payDownline(rugAddress);
		return createdPiZZa;
	}


	function payLevel(address lvl, uint ETH) internal returns(uint riderRugs){
		address sender = msg.sender;
		if( weight( gateway[lvl] ) > weight(sender) ){
			pocket[ gateway[lvl] ] += ETH;
		}else{
			riderRugs += ETH;
			gateway[lvl] = lvl==sender?carpetRider:sender;
		}
	}

	function payDownline(address rugAddress) internal{
		//Affiliate Payouts
		address sender = msg.sender;
		uint riderRugs;
		uint val = msg.value;
		uint _g = val * 6 / 1000;// Genie & FomoPot earnings*/

		riderRugs += payLevel(sender, val * 3 / 100);
		riderRugs += payLevel(gateway[sender], val * 2 / 100);
		riderRugs += payLevel(gateway[gateway[sender]], val / 100);

		pocket[carpetRider] += riderRugs;
		
		uint _4King_and_Kingdom = _g/2;
		
		pocket[ ( (block.timestamp - genesis) < 2592000 )? the66thCarpetKing: carpetKing[rugAddress] ] += _4King_and_Kingdom/2;
		
		pocket[ rugAddress ] += _4King_and_Kingdom-_4King_and_Kingdom/2;

		pocket[ GENIE ] += _g - _g/2;
	}

	function colorToCluster(uint r, uint g, uint b) public pure returns(uint8 rC, uint8 gC, uint8 bC){
		uint GRAY_BLOCK = 1e18/5;
		if(r/GRAY_BLOCK == 2 && g/GRAY_BLOCK == 2 && b/GRAY_BLOCK == 2){
			rC = 6;
			gC = 6;
			bC = 6;
		}else{
			uint C = (uint)(1e18) / 4;
			uint x = r;
			rC = x>C*3?3:x>C*2?2:x>C?1:0;
			x = g;
			gC = x>C*3?3:x>C*2?2:x>C?1:0;
			x = b;
			bC = x>C*3?3:x>C*2?2:x>C?1:0;
		}

		return (rC, gC, bC);
	}

	function tokenFallback(address from, uint value, bytes calldata _data) external{
		address TOKEN = address( msg.sender );
		require( value > 0 );
		if(TOKEN == address(colorToken) ){
			if( ofRug(from) ){
				//These resolves came from new carpetKings
				address newKing = bytesToAddress(_data);
				if(newKing != address0/* keep this so you can pass in heals */){
					carpetKing[from] = newKing;
				}
				
				uint rugCount = rugsOf(THIS,from);
					
				if( timerEnds[from] > now && rugCount>1){
					timerEnds[from] -= (timerEnds[from] - now) * rugCount / RugToken(from).totalSupply();
					RugToken(from).rugBurn(THIS, from, rugCount/2);
				}

			}
		}else if( ofRug(TOKEN) ){
			if( !ofRug(from) ){
				uint rugMagic = value;
				if(from == carpetRider){
					if(carpetRider != GENIE && caravan[TOKEN] ){

						if(rugMagic >= wishes){
							//kill
							if(wishes>0){
								wishes = 0;
								
								colorToken.transfer( carpetRider, colorToken.balanceOf(THIS) );
							}else{
								//they're already dead
							}
						}else{
							//damage
							wishes -= rugMagic;
						}
					}else{revert();}
				}else{
					revert();
				}
			}else{
				colorImports[from][TOKEN] += value;
				if( ( caravan[from] || from == GENIE /* without (floatingCastle != GENIE) because "Phantom Caravan" */ ) && inRing(from,TOKEN,false)  )
					moreShares(THIS, fomoRound[THIS], bytesToAddress(_data), value);
			}
		}else if( TOKEN == address(PiZZa) ){
			
			address who = bytesToAddress(_data);
			if (who == address0){
				prizePizza[from] += value;
				return;
			}
			
			require( ofRug(from) );

			uint additionalTime = now - RugToken(from).ageOfPiZZa()/scaleFactor;

			//taking this out because... living on the edge
			//require( additionalTime < (now - genesis) );			

			//it's just more fair to add pressure based off of ETH,
			//and not up the exponential diffictulty of the bonding curve
			uint pETH = pizza2ETH(value);

			//the more clock weight, the more shares in fomo.
			uint clocks = additionalTime * pETH;
		
			//makes adding to the timer more and more difficult as more eth comes in.
			//this can become gamable with big players.
			//but that's why we're able to drop the clock pressure in special events
			clockPressureContribution[from] += pETH;
			pizzaClockPressure += pETH;

			
			additionalTime = additionalTime / (pizzaClockPressure / pETH )
			//Give them a few different tools to fight the clock pressure from being gamed by big money.
			*( (caravan[from] || GENIE == from)?( value/1e18 /* YES... */ ):1 );

			require( additionalTime > 0 && value >= 1e18 );
			
			uint fomo_round = fomoRound[from];
			currentLead[from][fomo_round] = who;

			uint timer = timerEnds[from];
			if( fomoInitiated[from][fomo_round]  && now <= timer){
				timer += additionalTime;
			}else{
				fomoInitiated[from][fomo_round] = true;
				timer = now + additionalTime;
			}
			timerEnds[from] = timer;
			
			moreShares(from, fomo_round, who, clocks);
			uint FOMO_PIZZA;
			uint caravanClockWeight = totalClockWeight[THIS][fomoRound[THIS]];

			if( ( caravan[from] || from == GENIE ) && caravanClockWeight > 0){
				FOMO_PIZZA += value/2;
				pizzaPerClock[THIS][fomoRound[THIS]] += (value/4) * scaleFactor / caravanClockWeight;
			}else{
				FOMO_PIZZA += value/4;
				kingsPizza[from] += (value/4);
			}
			prizePizza[from] += FOMO_PIZZA;
			pizzaPerClock[from][fomo_round] += (value - FOMO_PIZZA - (value/4)) * scaleFactor / totalClockWeight[from][fomo_round];
		}else{
			revert();
		}
	}

	function moreShares(address from, uint fomo_round, address who, uint shares) internal{
		totalClockWeight[from][fomo_round] += shares;
		clockWeight[from][fomo_round][who] += shares;
		payouts[from][fomo_round][who] += pizzaPerClock[from][fomo_round]*shares;
	}

	function bytesToAddress(bytes memory bys) internal pure returns (address addr){
		assembly {
		  addr := mload(add(bys,20))
		} 
	}

	mapping(uint => address) rugBurnRecordSetter;
	mapping(uint => mapping(address => uint)) burnCount;

	function countBurnedRugs( address targetColor, address who, uint rugsBurned) external{
		address sender = msg.sender;
		require( ofRug(sender) );

		if(floatingCastle == targetColor || who == THIS){
			
			if(who == THIS){
				who = sender;
				rugsBurned *= 2;
			}

			burnCount[GENIE_g][who] += rugsBurned;
			if( burnCount[GENIE_g][who] > burnCount[GENIE_g][ rugBurnRecordSetter[GENIE_g] ] )
				rugBurnRecordSetter[GENIE_g] = who;
		}
	}

	function dropClockPressure(address kingdom) internal{
		pizzaClockPressure -= clockPressureContribution[kingdom];
		clockPressureContribution[kingdom] = 0;
	}


	function addressPayable(address addr) internal pure returns(address payable){return address( uint160(addr) );}

	uint pizzaClockPressure;
	mapping(address => bool) caravan;
	mapping(address => bool) portals;
	mapping(address => uint) fomoRound;
	mapping(address => uint) timerEnds;
	mapping(address => uint) prizePizza;
	mapping(address => uint) kingsPizza;
	mapping(address => uint) cooldown;
	mapping(address => mapping(uint => bool)) fomoInitiated;
	mapping(address => uint) clockPressureContribution;
	mapping(address => mapping(uint => uint)) pizzaPerClock;
	mapping(address => mapping(uint => address)) currentLead;
	mapping(address => mapping(uint => uint)) totalClockWeight;
	mapping(address => mapping(uint => mapping(address => uint))) clockWeight;
	mapping(address => mapping(uint => mapping(address => uint))) payouts;
    uint256 constant scaleFactor = 0x10000000000000000;

	function dividendsOf(address kingdom, uint _fomoRound, address player) public view returns(uint dividends, uint yourWeight, uint totalWeight){
		return ( ( clockWeight[kingdom][_fomoRound][player] * pizzaPerClock[kingdom][_fomoRound] - payouts[kingdom][_fomoRound][player] ) / scaleFactor  ,clockWeight[kingdom][_fomoRound][player] , totalClockWeight[kingdom][_fomoRound] );  
	}

	function withdrawDividends(address[] memory kingdoms, uint[] memory fomoRounds, address destination) public{
		address sender = msg.sender;
		uint $PIZZA;
		uint _fomoRound;
		if(destination == address0) destination = sender;

		for(uint F; F<fomoRounds.length; F++){
			_fomoRound = fomoRounds[F];
			(uint x,,) = dividendsOf(kingdoms[F],_fomoRound, sender);
			$PIZZA += x;
			payouts[kingdoms[F]][_fomoRound][sender] = clockWeight[kingdoms[F]][_fomoRound][sender] * pizzaPerClock[kingdoms[F]][_fomoRound];
		}

		ogBlack.mine();

		if(destination == address0) destination = sender;

		uint amount = pocket[sender];
		if( $PIZZA>0 )
			PiZZa.transfer( destination, $PIZZA);
		if( amount>0 ){
			pocket[sender] = 0;
			(bool success, ) = destination.call{value:amount}("");
	        require(success);
        }
	}

	function exitScam(address kingdom) public{
		if( now > timerEnds[kingdom] && fomoInitiated[kingdom][fomoRound[kingdom]] ){		
			endRound(kingdom);
		}else{
			revert();
		}
	}

	receive() external payable {}
	function endRound(address kingdom) internal{
		uint winners_pizza = prizePizza[kingdom];
		uint kings = kingsPizza[kingdom];
		prizePizza[kingdom] = 0;
		kingsPizza[kingdom] = 0;
		uint FR = fomoRound[kingdom];
		fomoRound[kingdom] += 1;

		if( kings + winners_pizza >0 ){
			portals[kingdom] = true;
			
			address lastBuyer = currentLead[kingdom][FR];
			dropClockPressure(kingdom);
			(uint ETH,,) = PiZZa.sellBonds(winners_pizza + kings);
			uint FOMO_ETH = ETH * winners_pizza/(kings + winners_pizza);
			pocket[lastBuyer] += FOMO_ETH + pocket[kingdom];
			pocket[kingdom] = 0;
			pocket[carpetKing[kingdom]] += ETH - FOMO_ETH;
		}
	}
	
	function lastXRounds(address perspective, uint R) public view returns(
		address[] memory kingdoms,
		uint[] memory rounds,
		uint totalDividends,
		uint count
	){
		rounds = new uint[](rugTokenListSize*R);
		kingdoms = new address[](rugTokenListSize*R);
		
		address kingdomAddr;
		uint divs;
		uint FR;
		uint j;
		for(uint i; i<rugTokenListSize+1; i+=1){
			if(i == rugTokenListSize){
				kingdomAddr = address0;
			}else{
				kingdomAddr = rugTokenList[i];	
			}
			FR = fomoRound[kingdomAddr];
			for(j=0; j<R; j+=1){
				if(j>FR) break;
				(divs,,) =  dividendsOf(kingdomAddr, FR-j, perspective);
				if(divs> 0){
					totalDividends +=divs;
					rounds[count] = FR-j;
					kingdoms[count] = kingdomAddr;
					count++;
				}
			}
		}
	}

	function allKingdoms(address perspective) public view returns(
		address[] memory address_,
		uint[] memory UINTs_
	){

		uint L = rugTokenListSize;
		UINTs_ = new uint[](L*21);
		address_ = new address[](L*3);
		
		RugToken kingdom;
		address kingdomAddr;
		for(uint i; i<L; i+=1){
			kingdom = RugToken(rugTokenList[i]);
			kingdomAddr = rugTokenList[i];
			(UINTs_[i+L*12], UINTs_[i+L*13], UINTs_[i+L*14]) = kingdom._RGB();

			uint prizePiZZa = prizePizza[kingdomAddr];
			uint kingsPiZZa = kingsPizza[kingdomAddr];
			uint FR = fomoRound[kingdomAddr];
			UINTs_[i] = FR;
			UINTs_[i+L] = timerEnds[kingdomAddr];
			UINTs_[i+L*2] = fomoInitiated[kingdomAddr][FR]?1:0;
			UINTs_[i+L*3] = caravan[kingdomAddr]?1:0;
			UINTs_[i+L*4] = prizePiZZa;
			UINTs_[i+L*5] = pocket[kingdomAddr];
			UINTs_[i+L*6] = kingdom.lifeForce();
			(UINTs_[i+L*7], UINTs_[i+L*17], UINTs_[i+L*18]) = dividendsOf(kingdomAddr, FR, perspective);
			UINTs_[i+L*8] = rugsOf( perspective, kingdomAddr);
			UINTs_[i+L*9] = kingdom.totalSupply();
			UINTs_[i+L*10] = X[kingdomAddr];
			UINTs_[i+L*11] = Y[kingdomAddr];
			UINTs_[i+L*15] = cooldown[kingdomAddr];
			UINTs_[i+L*16] = pizza2ETH(prizePiZZa);
			UINTs_[i+L*19] = pizza2ETH(kingsPiZZa);
			UINTs_[i+L*20] = portals[kingdomAddr]?1:0;
			address_[i] = kingdomAddr;
			address_[i+L] = carpetKing[kingdomAddr];
			address_[i+L*2] = currentLead[kingdomAddr][FR];
		}
	}
	function pizza2ETH(uint x)internal view returns(uint){
		return x>0?PiZZa.calculateEthereumReceived(x):0;
	}

	mapping(address => address) carpetKing;
	address floatingCastle;
	mapping(address => uint) X;
	mapping(address => uint) Y;
	mapping(address => mapping(address => uint)) colorImports;
	

	function proximity(address attacker, address defender)internal view returns(uint){
		uint x1 = X[attacker];
		uint x2 = X[defender];
		uint y1 = Y[attacker];
		uint y2 = Y[defender];
		
		return (x1<x2?(x2-x1):(x1-x2)) + (y1<y2?(y2-y1):(y1-y2));
	}

	function switch_slide(address attacker, address defender, bool s_s, address[] memory kingdoms, bool justSwap)internal{
		require(rugTokenListSize == 65);
		uint dX = X[defender];
		uint dY = Y[defender];
		uint aX = X[attacker];
		uint aY = Y[attacker];
		if(!s_s){
			if(attacker != floatingCastle && defender != floatingCastle){
				X[defender] = aX;
				Y[defender] = aY;
				X[attacker] = dX;
				Y[attacker] = dY;

				if(!justSwap){
					bool temp = caravan[attacker];
					caravan[attacker] = caravan[defender];
					caravan[defender] = temp;
				}
			}
		}else{
			uint i;
			uint j;
			address K;
			//make sure none of the addresses are the same
			require(kingdoms.length==6);
			for( i =0; i<6;i++){
				K = kingdoms[i];
				require( K!=attacker && K!=defender && ofRug(K) && K!=floatingCastle && ( aY == dY )?(Y[K] == aY):(X[K] == aX) );
				for( j=i+1; j<6;j++){
					require(K!=kingdoms[j]);
				}
			}

			bool direction = !(aY > dY || aX > dX );

			loop(aY == dY , attacker, direction );
			loop(aY == dY , defender, direction );
			for(i =0; i<6;i++){
				loop(aY == dY , kingdoms[i], direction );
			}
		}
	}

	function loop(bool XY, address K ,bool direction) internal{
		uint v;
		if(XY) v = X[K]; else v = Y[K];
		if(direction){
			if(v == 8){v=1;}
			else{v++;}
		}else{
			if(v == 1){v=8;}
			else{v--;}
		}
		if(XY) X[K] = v; else Y[K] = v;
	}

	function inRing(address attacker, address defender, bool self)internal returns(bool){
		uint distance = proximity(attacker,defender);
		if(self) cooldown[defender] = now;
		if(
			(distance == 2 && X[attacker] != X[defender] && Y[attacker] != Y[defender])
			||(distance == 1)
			||(self && attacker == defender)
		) return true;
		return false;
	}

	function usePortals(address kingdom, address[] memory swap1, address[] memory swap2) public{
		require(carpetKing[kingdom] == msg.sender && portals[kingdom]);
		uint L = swap1.length;
		//make sure they are close or the current kingdom , part of the game, & unique
		uint i;
		
		portals[kingdom] = false;
		for(i = 0; i<L;i++){
			address s1 = swap1[i];
			address s2 = swap2[i];
			require( 
				   (inRing(kingdom,s1,true))
				&& (inRing(s2,kingdom,true))//flipped this around so that we can get cooldown refreshes to everyone.
				&& s1 != s2
				&& ofRug(s1) 
				&& ofRug(s2)
			);

		}

		for(i = 0; i<L;i++){switch_slide(swap1[i], swap2[i], false, new address[](0), true);}
	}

	function inBox(address kingdom) internal view returns(bool isInBox){
		uint x = X[kingdom];
		uint y = Y[kingdom];
		return 6>=x && x>=3 && 6>=y && y>=3 && floatingCastle!=kingdom;
	}


	function fight( address attacker, address defender) internal returns(uint prizeTakenFromDefender, uint kingsTakenFromDefender,uint prizeTakenFromAttacker, uint kingsTakenFromAttacker, bool weightShift){	
		RugToken Attacker = RugToken(attacker);
		RugToken Defender = RugToken(defender);


		uint ATTACK = colorImports[attacker][defender];
		uint DEFENSE = colorImports[defender][attacker];
		
		if(ATTACK + DEFENSE>0){
			if( inBox(attacker) )
				Attacker.lifeForceDamage(DEFENSE , ATTACK + DEFENSE);
			else{
				prizeTakenFromAttacker = prizePizza[attacker] * DEFENSE / (ATTACK + DEFENSE);
				kingsTakenFromAttacker = kingsPizza[attacker] * DEFENSE / (ATTACK + DEFENSE);
			}

			if( inBox(defender) )
				if(!caravan[defender] && defender != GENIE )//ABSOLUTE DEFENSE!
					Defender.lifeForceDamage(ATTACK , ATTACK + DEFENSE);
			else{
				prizeTakenFromDefender = prizePizza[defender] * ATTACK / (ATTACK + DEFENSE);
				kingsTakenFromDefender = kingsPizza[defender] * ATTACK / (ATTACK + DEFENSE);
			}
		}
		
		weightShift = ATTACK >= DEFENSE;
	}

	function rugpull(address attacker, address defender, address[] memory kingdoms) public{
		address sender = msg.sender;
		if( sender == carpetKing[attacker] && ofRug(attacker) && ofRug(defender) && ( proximity(attacker,defender)==1 || attacker == floatingCastle) && defender!=floatingCastle && now > cooldown[attacker] ){
			
			(uint prizeTakenFromDefender, uint kingsTakenFromDefender, uint prizeTakenFromAttacker, uint kingsTakenFromAttacker, bool weightShift) = fight(attacker, defender);

			resetCooldowns(attacker);
			resetCooldowns(defender);

			if(!caravan[attacker])
				colorImports[attacker][defender] = 0;
			else{
				//A source of clock pressure dropping that will scatter around the board
				//Chaos to prevent big droppers from gaming with large amounts
				dropClockPressure(attacker);

				uint tA = timerEnds[attacker];
				uint tD = timerEnds[defender];
				//to help minimize extreme clock times that can spike from holding lamp
				if( tD > now  && tA > now  ){
					if( tA > tD ){
						timerEnds[attacker] -= (tA-now)/2;
						timerEnds[defender] += (tA-now)/2;
					}
				}
			}

			if(!caravan[defender] && GENIE != defender)
				colorImports[defender][attacker] = 0;


			if(attacker != floatingCastle){
				switch_slide(attacker,defender, weightShift , kingdoms, false);
			}

			//underflow overflow... be mad
			prizePizza[defender] +=  prizeTakenFromAttacker - prizeTakenFromDefender;
			kingsPizza[defender] +=  kingsTakenFromAttacker - kingsTakenFromDefender;
			prizePizza[attacker] +=  prizeTakenFromDefender - prizeTakenFromAttacker;
			kingsPizza[attacker] +=  kingsTakenFromDefender - kingsTakenFromAttacker;
			
		}else{
			revert();
		}
	}
	function resetCooldowns(address kingdom) internal{
		uint timer = timerEnds[kingdom];
		//no singularities
		cooldown[kingdom] = timer<now?(now + (now-timer) ):timer;
	}

	function globalData( address perspective, address kingdom) public view returns(
		address _GENIE,
		uint _wishes,
		uint _generation,
		address _carpetRider,
		uint _carpetRiderHP,
		address _floatingCastle,
		address _gateway, 
		uint _pocket , 
		uint _pizzaClockPressure,
		uint[] memory _UINTs 
	 ){
		_GENIE = GENIE;
		_wishes = wishes;
		_generation = GENIE_g;
		_carpetRider = carpetRider;
		_carpetRiderHP = carpetRiderHP;
		_floatingCastle = floatingCastle;
		_gateway = gateway[perspective];
		_pocket = pocket[perspective];
		_pizzaClockPressure = pizzaClockPressure;
			
		_UINTs = new uint[](66);
		uint i;
		for(i=0; i<65; i+=1){
			_UINTs[i] = colorImports[kingdom][rugTokenList[i]];
		}

		_UINTs[65] = fomoRound[THIS];
	}

}

abstract contract  BlackRock{
	function mine() public virtual;
}

abstract contract  ERC20{
	function transfer(address _to, uint _value) public virtual returns (bool);
	function transfer(address _to, uint _value, bytes memory _data) public virtual returns (bool);
	function RGB_Ratio(address addr) public view virtual returns(uint,uint,uint);
	function balanceOf(address _address) public view virtual returns (uint256 balance);
}

abstract contract Pyramid is ERC20{
    function buy(address addr, uint _red, uint _green, uint _blue) public virtual payable returns(uint createdBonds);
    function resolveToken() public view virtual returns(ERC20);
    function average_buyInTimeSum(address addr) public virtual returns(uint);
    function average_ethSpent(address addr) public virtual returns(uint);
    function resolveWeight(address addr) public view virtual returns(uint);
    function red(address addr) public virtual returns(uint);
    function green(address addr) public virtual returns(uint);
    function blue(address addr) public virtual returns(uint);
    function sellBonds(uint amount) public virtual returns(uint returned_eth, uint returned_resolves, uint initialInput_ETH);
    function calculateEthereumReceived(uint256 _tokensToSell) public virtual view returns(uint256);
}

contract RugToken{
	string public name = "Comfy Rugs";
    string public symbol = "_RUG";
    uint8 constant public decimals = 0;
	address payable lampAddress;
	MagicLamp magicLamp;
	uint8[3] RGB;
	uint public ageOfPiZZa;

	function _RGB() public view returns(uint8 _R,uint8 _G,uint8 _B){
		return (RGB[0],RGB[1],RGB[2]);
	}
	address THIS = address(this);

	uint public lifeForce = 0;
	ERC20 colorToken;
	address carpetKing;
	Pyramid PiZZa;

	constructor(uint8 _R, uint8 _G, uint8 _B, uint life, Pyramid _PiZZa) public{
		lampAddress = msg.sender;
		lifeForce = life;
		magicLamp = MagicLamp(lampAddress);
		
		RGB[0] = _R;
		RGB[1] = _G;
		RGB[2] = _B;
		PiZZa = _PiZZa;
		colorToken = PiZZa.resolveToken();
	}

	function rebrand(string  memory _name, string  memory _symbol, bool namingStyle) public{
		require(msg.sender == carpetKing);
		if(namingStyle)
			name = str(_name, " Rugs");
		else
			name = str("Rugs of ",_name);

		symbol = str(_symbol, "_RUG");
	}

	function str(string memory X, string memory Y) internal pure returns(string memory){
		return string(abi.encodePacked( X, Y));
	}

	//event NewCarpetKing(address carpetKing, uint newLife, bytes data);
	function tokenFallback(address from, uint value, bytes calldata _data) external{
		address TOKEN = msg.sender;
		if( TOKEN == address(colorToken) ){
			
			(uint r, uint g, uint b) = colorToken.RGB_Ratio(THIS);
			if( value > lifeForce && colorMatch(r,g,b) ){
				carpetKing = from;
				lifeForce = value;
			}

			this.burnRugs(THIS,0);

		}else if(TOKEN == address( PiZZa )){
			(uint r, uint g, uint b) = PiZZa.RGB_Ratio(THIS);
			if( colorMatch(r,g,b) ){
				ageOfPiZZa = PiZZa.average_buyInTimeSum(THIS) / PiZZa.average_ethSpent(THIS);
				PiZZa.transfer( lampAddress, PiZZa.balanceOf(THIS), abi.encodePacked( from ) );
			}else{
				revert();
			}
		}else if( magicLamp.ofRug(TOKEN) && TOKEN != THIS){
			require(value>0);
			RugToken(TOKEN).transfer( lampAddress, magicLamp.rugsOf(THIS,TOKEN), abi.encodePacked( from ) );
		}else{
			revert();
		}
	}

	function colorMatch(uint r, uint g, uint b) internal view returns(bool){
		(uint8 rC, uint8 gC, uint8 bC) = magicLamp.colorToCluster(r,g,b);
		return (RGB[0] == rC && RGB[1] == gC && RGB[2] == bC);
	}

	modifier authOnly{
	  require( msg.sender == lampAddress || magicLamp.ofRug(msg.sender) );
	  _;
    }


	function mint(address _address, uint _value) external authOnly(){
		balances[_address] += _value;
		_totalSupply += _value;
		this.burnRugs(THIS,0);
	}

	function burnRugs(address _address, uint _value) public authOnly(){
		balances[_address] -= _value;
		_totalSupply -= _value;

		uint PIZZA = PiZZa.balanceOf(THIS);
		if(PIZZA>0)
			PiZZa.transfer( lampAddress, PIZZA );
		
		uint color = colorToken.balanceOf(THIS);
		if(color>0)
			colorToken.transfer(lampAddress,color , abi.encodePacked(carpetKing) );
	}

	function rugBurn(address _target, address rugColor, uint _value) public {
		address sender = msg.sender;

		uint targetsRugs = magicLamp.rugsOf(_target, rugColor);
		require( 
			magicLamp.ofRug(rugColor)
			&& (THIS != rugColor || sender == lampAddress)
			&& _value <= balances[sender] 
			&& _value > 0
		);

		uint damage;
		if( targetsRugs <= _value){
			damage = targetsRugs;
		}else{
			damage = _value;
		}

		burnRugs(sender, damage);
		RugToken(rugColor).burnRugs(_target, damage);
		magicLamp.countBurnedRugs(rugColor, sender, damage);

		emit RugBurn(sender, _target, damage);
	}

	function lifeForceDamage(uint N, uint D) external authOnly(){
		lifeForce = lifeForce * N/D;
	}

	mapping(address => uint256) balances;

	uint _totalSupply;

	mapping(address => mapping(address => uint)) approvals;

	event Transfer(
		address indexed from,
		address indexed to,
		uint256 amount
	);

	event RugBurn(
		address indexed from,
		address indexed to,
		uint256 amount
	);
	
	function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view returns (uint256 balance) {
		return balances[_address];
	}

	function transfer(address _to, uint _value, bytes memory _data) public virtual returns (bool) {
		if( isContract(_to) ){
			return transferToContract(_to, _value, _data);
		}else{
			return transferToAddress(_to, _value);
		}
	}
	// Standard function transfer similar to ERC20 transfer with no _data.
	// Added due to backwards compatibility reasons .
	function transfer(address _to, uint _value) public virtual returns (bool) {
		//standard function transfer similar to ERC20 transfer with no _data
		//added due to backwards compatibility reasons
		bytes memory empty;
		if(isContract(_to)){
			return transferToContract(_to, _value, empty);
		}else{
			return transferToAddress(_to, _value);
		}
	}

	//function that is called when transaction target is an address
	function transferToAddress(address _to, uint _value) private returns (bool) {
		moveTokens(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	//function that is called when transaction target is a contract
	function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool) {
		moveTokens(msg.sender, _to, _value);
		ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
		receiver.tokenFallback(msg.sender, _value, _data);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function moveTokens(address _from, address _to, uint _amount) internal virtual{
		require( _amount <= balances[_from] );
		this.burnRugs(THIS,0);
		balances[_from] -= _amount;
		balances[_to] += _amount;
	}

    function allowance(address src, address guy) public view returns (uint) {
        return approvals[src][guy];
    }
  	
    function transferFrom(address src, address dst, uint amount) public returns (bool){
        address sender = msg.sender;
        require(approvals[src][sender] >=  amount);
        require(balances[src] >= amount);
        approvals[src][sender] -= amount;
        moveTokens(src,dst,amount);
        //bytes memory empty;
        emit Transfer(sender, dst, amount);
        return true;
    }

    event Approval(address indexed src, address indexed guy, uint amount);
    function approve(address guy, uint amount) public returns (bool) {
        address sender = msg.sender;
        approvals[sender][guy] = amount;

        emit Approval( sender, guy, amount );
        return true;
    }

    function isContract(address _addr) public view returns (bool is_contract) {
		uint length;
		assembly {
			//retrieve the size of the code on target address, this needs assembly
			length := extcodesize(_addr)
		}
		if(length>0) {
			return true;
		}else {
			return false;
		}
	}
}

abstract contract ERC223ReceivingContract{
    function tokenFallback(address _from, uint _value, bytes calldata _data) external virtual;
}