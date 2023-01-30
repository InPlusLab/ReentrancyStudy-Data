/**
 *Submitted for verification at Etherscan.io on 2020-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.7.2;

contract $RedBalloons{
	Pyramid PiZZa = Pyramid(0x91683899ed812C1AC49590779cb72DA6BF7971fE);//0x91683899ed812C1AC49590779cb72DA6BF7971fE
	MagicLamp lamp = MagicLamp(0x2b9Fb63d3768a0fEF2e0F802B0d93c150b41607f);//0x9Fe88B7c973e94391db5EF94f1011cB07813c501
	uint constant $ = 1e18;

	//priorities
	ERC20 balloonToken = ERC20(0x6523203BD28d399068AcC14Db6B7f31D9bF43f1a);//0x6523203bd28d399068acc14db6b7f31d9bf43f1a
	ERC20 spamToken = ERC20(0xe888730325620bCaB4dF7852222D3b041c8479A8);//0xe888730325620bCaB4dF7852222D3b041c8479A8
	ERC20 MVT = ERC20(0x3D46454212c61ECb7b31248047Fa033120B88668);//0x3d46454212c61ecb7b31248047fa033120b88668
	ERC20 MDT = ERC20(0x32A087D5fdF8c84eC32554c56727a7C81124544E);//0x32a087d5fdf8c84ec32554c56727a7c81124544e
	ERC20 XYO = ERC20(0x55296f69f40Ea6d20E478533C15A6B08B654E758);//0x55296f69f40ea6d20e478533c15a6b08b654e758
	ERC20 SENT = ERC20(0xa44E5137293E855B1b7bC7E2C6f8cD796fFCB037);//0xa44e5137293e855b1b7bc7e2c6f8cd796ffcb037

	//other
	ERC20 x_moonday = ERC20(0x1ad606ADDe97c0C28bD6ac85554176bC55783c01);//0x1ad606adde97c0c28bd6ac85554176bc55783c01
	ERC20 x_drc = ERC20(0xb78B3320493a4EFaa1028130C5Ba26f0B6085Ef8);//0xb78b3320493a4efaa1028130c5ba26f0b6085ef8
	ERC20 x_barnbond = ERC20(0x0391D2021f89DC339F60Fff84546EA23E337750f);//0x0391D2021f89DC339F60Fff84546EA23E337750f
	ERC20 x_wetstuff = ERC20(0xEa319e87Cf06203DAe107Dd8E5672175e3Ee976c);//0xea319e87cf06203dae107dd8e5672175e3ee976c
	ERC20 x_BCO = ERC20(0x865D176351f287fE1B0010805b110d08699C200A);//0x865d176351f287fe1b0010805b110d08699c200a
	ERC20 x_CID = ERC20(0x4599836c212CD988EAccc54C820Ee9261cdaAC71);//0x4599836c212CD988EAccc54C820Ee9261cdaAC71
	ERC20 x_RFOX = ERC20(0xa1d6Df714F91DeBF4e0802A542E13067f31b8262);//0xa1d6df714f91debf4e0802a542e13067f31b8262
	ERC20 x_GLM = ERC20(0x7DD9c5Cba05E151C895FDe1CF355C9A1D5DA6429);//0x7dd9c5cba05e151c895fde1cf355c9a1d5da6429
	ERC20 x_BRD = ERC20(0x558EC3152e2eb2174905cd19AeA4e34A23DE9aD6);//0x558ec3152e2eb2174905cd19aea4e34a23de9ad6
	ERC20 x_OCTO = ERC20(0x7240aC91f01233BaAf8b064248E80feaA5912BA3);//0x7240ac91f01233baaf8b064248e80feaa5912ba3
	ERC20 x_UNI = ERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);//0x1f9840a85d5af5bf1d1762f925bdaddc4201f984
	ERC20 x_PEPE = ERC20(0x4D2eE5DAe46C86DA2FF521F7657dad98834f97b8);//0x4d2ee5dae46c86da2ff521f7657dad98834f97b8
	ERC20 x_BZZZ = ERC20(0xC483ad6F9B80B38691E95b708DE1d46721366ce3);//0xc483ad6f9b80b38691e95b708de1d46721366ce3
	//


	address THIS = address(this);
	address address0 = address(0);
	mapping(uint => address) rugTokenList;
	uint rugTokenListSize;
	address payable Haley;

	uint genesis;
	uint timeLastBalloonPopped;
	uint totalEthContributed;

	address feather;
	address cattle;
	address panda;
	address penguin;
	address gold;
	address water;
	address fox;
	address bat;
	address wheat;
	address skull;
	address shootingStar;
	address deer;
	address crane;
	address wolf;
	address moon;
	address bee;
	address monkey;
	address eye;
	address golem;
	address pawPrints;
	address goat;
	address lion;
	address unicorn;
	address octopus;
	address frog;
	address forest;
	address snake;
	address spider;
	address rose;
	address sunflower;
	address palmTree;
	address dragonFly;
	address shroom;

	uint redBalloonsLeftOnTheWall = 99;
	bool public redBalloonOnTheLoose;
	address redBalloonLocation;

	mapping(address => uint8) token_R;
	mapping(address => uint8) token_G;
	mapping(address => uint8) token_B;
	mapping(address => uint) token_Color;
	
	address balloonGiver;
	uint rationCost = 0.0002 ether;
	
	Token spamJerky;
	Token R99;

	mapping( address => bool) ofBalloons;


	function ofBalloon(address addr) public view returns(bool){
		return ofBalloons[addr];
	}

	function ofRug(address addr) public view returns(bool){
		return ofBalloon(addr) || lamp.ofRug(addr);
	}
	function tokenRGB(address token) public view returns(uint R,uint G,uint B, uint C){
		if( ofBalloon(token) || token == address(spamJerky) )
			return (token_R[token], token_G[token], token_B[token], token_Color[token]);
		else if( lamp.ofRug(token) ){
			( R, G, B ) = RugToken(token)._RGB();
			return ( R,G,B , 1 );
		}
		revert();
	}
	constructor(){
		spamJerky = newCard("Spam Jerky", "SpJ", 2, 1, 1, 5);
		R99 = newCard("Red Balloon", "R99", 3, 0, 0, 99);// this should be pretty fucking high forever
		rubixFractal = newCard("Rubix Fractal", "fraX", 4, 4, 4, 7);
		
		Haley = msg.sender;
		balloonGiver = Haley;
		genesis = block.timestamp;
		moreShares(Haley, 1e18);//just so we can kick things off without having to wait.
	}

	Token snowman;
	Token jack_o_lantern;
	Token blackSwan;
	Token haleysArrow;
	Token moonHowler;
	Token vampire;
	Token miracleMilk;
	Token beeHive;
	Token surfBoard;
	Token canoe;
	Token boat;
	Token submarine;
	Token apeIn;
	Token teleporter;
	Token thirdEye;
	Token hourglassStarDust;
	Token manyPlace;
	Token chimeraGargoyle;
	Token kyuubi;
	Token ironGiant;
	Token bread;
	Token kraken;
	Token pegasus;
	Token tyrone;
	Token honey;
	Token sniperDrone;
	Token rubixFractal;
	Token[] cards;

	function newCard(string memory name, string memory symbol, uint8 R, uint8 G, uint8 B, uint C) internal returns(Token){
		Token newToken = new Token(name, symbol);
		address rBT = address(newToken);
		ofBalloons[rBT] = true;
		token_R[rBT] = R;
		token_G[rBT] = G;
		token_B[rBT] = B;
		token_Color[rBT] = C; 
		cards.push(newToken);
		return newToken;
	}

/*
██╗███╗░░██╗██╗████████╗██╗░█████╗░██╗░░░░░██╗███████╗███████╗
██║████╗░██║██║╚══██╔══╝██║██╔══██╗██║░░░░░██║╚════██║██╔════╝
██║██╔██╗██║██║░░░██║░░░██║███████║██║░░░░░██║░░███╔═╝█████╗░░
██║██║╚████║██║░░░██║░░░██║██╔══██║██║░░░░░██║██╔══╝░░██╔══╝░░
██║██║░╚███║██║░░░██║░░░██║██║░░██║███████╗██║███████╗███████╗
╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚═╝╚═╝░░╚═╝╚══════╝╚═╝╚══════╝╚══════╝*/
	function init(uint X) public{
		require(rugTokenListSize < 65);
		address[] memory kingdoms = new address[](65);
		uint[] memory uints;
		(kingdoms, uints) = lamp.allKingdoms(address0);
		uint R;
		uint G;
		uint B;
		address K;
		uint rubixBonus = 0;
		for(uint i = rugTokenListSize; i < 65 && i < rugTokenListSize+X; i+=1){
			K = kingdoms[i];
			rugTokenList[i] = K;
			R = uints[i+65*12];
			G = uints[i+65*13];
			B = uints[i+65*14];
			rubixBonus += 1;
			if(R == 2 && G == 3 && B == 3){ feather = K; snowman = newCard("Christmas","FRoST",3,3,3,3); }
			if(R == 2 && G == 1 && B == 1){ cattle = K; jack_o_lantern = newCard("Jack-O-Lantern","JaCK",3,1,0,4);}
			if(R == 2 && G == 3 && B == 2){ panda = K; blackSwan = newCard("Black Swan","SWaN",0,0,0, 7);}
			if(R == 3 && G == 2 && B == 0){ gold = K; haleysArrow = newCard("Haley's Arrow","ARTMS",3,3,2, 4);}
			if(R == 1 && G == 3 && B == 3){ penguin = K; moonHowler = newCard("Shadow Wolf","WoLF",6,6,6, 6);}
			if(R == 3 && G == 1 && B == 0){ fox= K; vampire = newCard("Dracula","VaMP",2,0,0, 5);}
			if(R == 1 && G == 0 && B == 1){ bat = K; miracleMilk = newCard("Miracle Milk","Moo",3,3,3, 2);}
			if(R == 2 && G == 2 && B == 1){ wheat = K; beeHive = newCard("Bee Hive","HiVE",3,3,0, 3); }
			if(R == 0 && G == 0 && B == 0){ skull = K; surfBoard = newCard("Surf Board","SuRF",0,1,3, 1);}
			if(R == 1 && G == 2 && B == 3){ crane = K; canoe = newCard("Canoe","PaDDl",1,2,3, 2);}
			if(R == 0 && G == 1 && B == 1){ shootingStar = K; boat = newCard("Boat","SaIL",0,0,3, 4);}
			if(R == 3 && G == 2 && B == 1){ deer = K; submarine = newCard("Submarine","SuB",0,0,1, 6);}
			if(R == 0 && G == 1 && B == 0){ forest = K; apeIn = newCard("Fomo Ape","FoMo",2,2,0, 7);}
			if(R == 6 && G == 6 && B == 6){ wolf = K; teleporter = newCard("Teleporter","XY0",2,0,1, 5);}
			if(R == 1 && G == 1 && B == 1){ moon = K; thirdEye = newCard("Third Eye","3rd",2,0,2, 9);}
			if(R == 3 && G == 3 && B == 0){ bee = K; kyuubi = newCard("PsyKyuubi","PsyK",3,1,0, 1);}
			if(R == 2 && G == 0 && B == 3){ goat = K; manyPlace = newCard("Many Place","MPl",2,0,3, 13);}
			if(R == 2 && G == 2 && B == 0){ monkey = K; bread = newCard("Cake","LIE",2,2,1, 3);}
			if(R == 1 && G == 3 && B == 0){ frog = K; kraken = newCard("Kraken","KRKn",0,0,2, 6);}
			if(R == 2 && G == 0 && B == 2){ eye = K; tyrone = newCard("President of KeKistan","B_M_T",0,2,0, 8);}
			if(R == 2 && G == 2 && B == 2){ golem = K; pegasus = newCard("Pegasus","UNi",2,3,3, 3);}
			if(R == 2 && G == 0 && B == 1){ pawPrints = K; ironGiant = newCard("Iron Giant","IRoN",6,6,6, 6);}
			if(R == 3 && G == 3 && B == 2){ lion = K; hourglassStarDust = newCard("Seconds","2nd",0,1,1, 1);}
			if(R == 2 && G == 2 && B == 3){ water = K; honey = newCard("Honey","H0NEY",3,2,0, 2);}
			if(R == 3 && G == 0 && B == 1){ unicorn = K;}
			if(R == 0 && G == 3 && B == 0){ snake = K;}
			if(R == 1 && G == 0 && B == 2){ spider = K;}
			if(R == 3 && G == 1 && B == 2){ rose = K;}
			if(R == 1 && G == 3 && B == 2){ palmTree = K;}
			if(R == 1 && G == 2 && B == 1){ shroom = K;}
			if(R == 0 && G == 3 && B == 1){ dragonFly = K; sniperDrone = newCard("Diving Sniper","DSn",1,2,0, 3);}
			if(R == 3 && G == 3 && B == 1){ sunflower = K;}
			if(R == 1 && G == 0 && B == 3){ octopus = K; chimeraGargoyle = newCard("Chimera Gargoyle","ChG",2,2,2, 8);}
		}

		rubixFractal.mint(msg.sender, rubixBonus*100);
		rugTokenListSize += X;
		if (rugTokenListSize>65) rugTokenListSize = 65;
		if(rugTokenListSize == 65){
			timeLastBalloonPopped = block.timestamp;
			if(floatingCastle() != panda)
				redBalloonLocation = panda;
			else
				redBalloonLocation = feather;
		}
	}

/*
██╗░░██╗██╗███╗░░██╗░██████╗░░░░░░░██████╗░░░░░░░██╗░░██╗██╗███╗░░██╗░██████╗░
██║░██╔╝██║████╗░██║██╔════╝░░░░░░░╚════██╗░░░░░░██║░██╔╝██║████╗░██║██╔════╝░
█████═╝░██║██╔██╗██║██║░░██╗░█████╗░░███╔═╝█████╗█████═╝░██║██╔██╗██║██║░░██╗░
██╔═██╗░██║██║╚████║██║░░╚██╗╚════╝██╔══╝░░╚════╝██╔═██╗░██║██║╚████║██║░░╚██╗
██║░╚██╗██║██║░╚███║╚██████╔╝░░░░░░███████╗░░░░░░██║░╚██╗██║██║░╚███║╚██████╔╝
╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░░░░░░░╚══════╝░░░░░░╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░
*/
	/*function kings2kings(uint X, uint offset) public view returns(uint[] memory imports2Imports){
		imports2Imports = new uint[](65*X);

		uint[] memory imports;

		for(uint i=0; i<X; i+=1){
			(,,,,,,,,,imports) = lamp.globalData(address0, rugTokenList[i+offset] );
			for(uint j=0; j<65; j+=1){
				imports2Imports[j+i*65] = imports[j];
			}
		}
	}*/
/*
██████╗░░█████╗░░██████╗██╗░█████╗░░██████╗
██╔══██╗██╔══██╗██╔════╝██║██╔══██╗██╔════╝
██████╦╝███████║╚█████╗░██║██║░░╚═╝╚█████╗░
██╔══██╗██╔══██║░╚═══██╗██║██║░░██╗░╚═══██╗
██████╦╝██║░░██║██████╔╝██║╚█████╔╝██████╔╝
╚═════╝░╚═╝░░╚═╝╚═════╝░╚═╝░╚════╝░╚═════╝░
*/


	function floatingCastle() public view returns(address _floatingCastle){
		(,,,,,,_floatingCastle,) = lamp.XY(address0);
	}
	function isCaravan(address kingdom) public view returns(bool IS){
		(,,,,,,,IS) = lamp.XY(kingdom);
	}

/*
░██████╗░███████╗████████╗  ██╗░░██╗██╗░░░██╗
██╔════╝░██╔════╝╚══██╔══╝  ╚██╗██╔╝╚██╗░██╔╝
██║░░██╗░█████╗░░░░░██║░░░  ░╚███╔╝░░╚████╔╝░
██║░░╚██╗██╔══╝░░░░░██║░░░  ░██╔██╗░░░╚██╔╝░░
╚██████╔╝███████╗░░░██║░░░  ██╔╝╚██╗░░░██║░░░
░╚═════╝░╚══════╝░░░╚═╝░░░  ╚═╝░░╚═╝░░░╚═╝░░░
*/

	function getXY(address kingdom) public view returns(uint X, uint Y){
		(X,Y,,,,,,) = lamp.XY(kingdom);
	}


/*
██████╗░██████╗░░█████╗░██╗░░██╗██╗███╗░░░███╗██╗████████╗██╗░░░██╗
██╔══██╗██╔══██╗██╔══██╗╚██╗██╔╝██║████╗░████║██║╚══██╔══╝╚██╗░██╔╝
██████╔╝██████╔╝██║░░██║░╚███╔╝░██║██╔████╔██║██║░░░██║░░░░╚████╔╝░
██╔═══╝░██╔══██╗██║░░██║░██╔██╗░██║██║╚██╔╝██║██║░░░██║░░░░░╚██╔╝░░
██║░░░░░██║░░██║╚█████╔╝██╔╝╚██╗██║██║░╚═╝░██║██║░░░██║░░░░░░██║░░░
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚═╝░░░╚═╝░░░░░░╚═╝░░░*/
	function proximity(address one, address two, bool _4_8) public view returns(bool){
		(uint x1, uint y1) = getXY(one);
		(uint x2, uint y2) = getXY(two);
		
		uint distance = (x1<x2?(x2-x1):(x1-x2)) + (y1<y2?(y2-y1):(y1-y2));
		address _floatingCastle = floatingCastle();
		return ( (distance == 1) || ( _4_8 && (distance == 2 && x1 != x2 && y1 !=y2) )  ) && one != _floatingCastle && two != _floatingCastle;
	}

	function RGB(address rug) public view returns(uint8 R, uint8 G, uint8 B){
		return RugToken(rug)._RGB();
	}


	/*
	Freeze Spam
	for Shares on PiZZa dividends that come from whatever valid kingdom the balloon is floating over
	balloon giver gets 5%
	dev gets 5%
	

	Give a fraction of spam to those who buy Rations
	The % of new eth compared to input eth. (yes, it becomes increasingly difficult to get 100% of spam.)


	the buyer that causes the kingdom to become the floating kingdom pops the balloon.
	or the buyer that buys while the kingdom with the balloon is floating
	*/

/*
░██████╗████████╗░█████╗░░█████╗░██╗░░██╗  ██████╗░░█████╗░██╗░░░░░██╗░░░░░░█████╗░░█████╗░███╗░░██╗
██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██║░██╔╝  ██╔══██╗██╔══██╗██║░░░░░██║░░░░░██╔══██╗██╔══██╗████╗░██║
╚█████╗░░░░██║░░░██║░░██║██║░░╚═╝█████═╝░  ██████╦╝███████║██║░░░░░██║░░░░░██║░░██║██║░░██║██╔██╗██║
░╚═══██╗░░░██║░░░██║░░██║██║░░██╗██╔═██╗░  ██╔══██╗██╔══██║██║░░░░░██║░░░░░██║░░██║██║░░██║██║╚████║
██████╔╝░░░██║░░░╚█████╔╝╚█████╔╝██║░╚██╗  ██████╦╝██║░░██║███████╗███████╗╚█████╔╝╚█████╔╝██║░╚███║
╚═════╝░░░░╚═╝░░░░╚════╝░░╚════╝░╚═╝░░╚═╝  ╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝░╚════╝░░╚════╝░╚═╝░░╚══╝*/
	mapping( uint => mapping(address=>uint) ) stockedBalloons;
	mapping( uint => address ) recordSetter;
	function stockBalloonToken() public{
		require(rugTokenListSize == 65);
		address sender = msg.sender;
		uint amount = balloonToken.allowance(sender, THIS);
		require( 0<amount && PiZZa.balanceOf(sender) >= 10e18 );
		balloonToken.transferFrom(sender, THIS, amount);
		stockedBalloons[redBalloonsLeftOnTheWall][sender] += amount;
		uint newCount = stockedBalloons[redBalloonsLeftOnTheWall][sender];
		//divided by 1million because we're giving them something for risking their tokens
		//but not giving them as much as spam.
		//That makes 1000 shares possible from BalloonX in total (which is nothing)
		moreShares(sender, amount/1000000);
		if( stockedBalloons[redBalloonsLeftOnTheWall][ recordSetter[redBalloonsLeftOnTheWall] ] < newCount ){
			recordSetter[redBalloonsLeftOnTheWall] = sender;
		}
	}
/*
██████╗░███████╗██╗░░░░░███████╗░█████╗░░██████╗███████╗  ██████╗░░█████╗░██╗░░░░░██╗░░░░░░█████╗░░█████╗░███╗░░██╗
██╔══██╗██╔════╝██║░░░░░██╔════╝██╔══██╗██╔════╝██╔════╝  ██╔══██╗██╔══██╗██║░░░░░██║░░░░░██╔══██╗██╔══██╗████╗░██║
██████╔╝█████╗░░██║░░░░░█████╗░░███████║╚█████╗░█████╗░░  ██████╦╝███████║██║░░░░░██║░░░░░██║░░██║██║░░██║██╔██╗██║
██╔══██╗██╔══╝░░██║░░░░░██╔══╝░░██╔══██║░╚═══██╗██╔══╝░░  ██╔══██╗██╔══██║██║░░░░░██║░░░░░██║░░██║██║░░██║██║╚████║
██║░░██║███████╗███████╗███████╗██║░░██║██████╔╝███████╗  ██████╦╝██║░░██║███████╗███████╗╚█████╔╝╚█████╔╝██║░╚███║
╚═╝░░╚═╝╚══════╝╚══════╝╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝  ╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝░╚════╝░░╚════╝░╚═╝░░╚══╝*/
	function releaseBalloon() public{
		require(rugTokenListSize == 65);
		address sender = msg.sender;
		address theNewGuy = recordSetter[redBalloonsLeftOnTheWall];
		require(
			( timeLastBalloonPopped+86400 < block.timestamp || sender == theNewGuy )
			&& theNewGuy != address0//we need to keep this so that the balloonGiver is not null. giving money to null address
			&& redBalloonsLeftOnTheWall > 0
			&& panda != floatingCastle()
			&& !redBalloonOnTheLoose
		);
		balloonGiver = theNewGuy;
		redBalloonsLeftOnTheWall -= 1;
		redBalloonLocation = panda;
		redBalloonOnTheLoose = true;
	}

/*
░██████╗████████╗░█████╗░██╗░░██╗███████╗  ░██████╗██████╗░░█████╗░███╗░░░███╗
██╔════╝╚══██╔══╝██╔══██╗██║░██╔╝██╔════╝  ██╔════╝██╔══██╗██╔══██╗████╗░████║
╚█████╗░░░░██║░░░███████║█████═╝░█████╗░░  ╚█████╗░██████╔╝███████║██╔████╔██║
░╚═══██╗░░░██║░░░██╔══██║██╔═██╗░██╔══╝░░  ░╚═══██╗██╔═══╝░██╔══██║██║╚██╔╝██║
██████╔╝░░░██║░░░██║░░██║██║░╚██╗███████╗  ██████╔╝██║░░░░░██║░░██║██║░╚═╝░██║
╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝  ╚═════╝░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░░░░╚═╝*/
	function steakSpam(uint amount) public{
		require(rugTokenListSize == 65);
		//stack up shares
		address sender = msg.sender;
		require(  amount<=spamToken.allowance(sender, THIS) && (PiZZa.balanceOf(sender) >= (100-redBalloonsLeftOnTheWall)*$) && balloonOrGiftBoxOnBoard() );
		spamToken.transferFrom(sender, THIS, amount);
		moreShares(sender, amount*9/10);
		moreShares(/*for the current balloon giver*/balloonGiver, amount/20);
		moreShares(/* operational */ Haley, amount/20);
	}

/*
██████╗░██╗░░░██╗██╗░░░██╗  ░██████╗██████╗░░█████╗░███╗░░░███╗  ░░░░░██╗███████╗██████╗░██╗░░██╗██╗░░░██╗
██╔══██╗██║░░░██║╚██╗░██╔╝  ██╔════╝██╔══██╗██╔══██╗████╗░████║  ░░░░░██║██╔════╝██╔══██╗██║░██╔╝╚██╗░██╔╝
██████╦╝██║░░░██║░╚████╔╝░  ╚█████╗░██████╔╝███████║██╔████╔██║  ░░░░░██║█████╗░░██████╔╝█████═╝░░╚████╔╝░
██╔══██╗██║░░░██║░░╚██╔╝░░  ░╚═══██╗██╔═══╝░██╔══██║██║╚██╔╝██║  ██╗░░██║██╔══╝░░██╔══██╗██╔═██╗░░░╚██╔╝░░
██████╦╝╚██████╔╝░░░██║░░░  ██████╔╝██║░░░░░██║░░██║██║░╚═╝░██║  ╚█████╔╝███████╗██║░░██║██║░╚██╗░░░██║░░░
╚═════╝░░╚═════╝░░░░╚═╝░░░  ╚═════╝░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░░░░╚═╝  ░╚════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░*/
	function buySpamJerky() public payable{
		require(rugTokenListSize == 65);
		uint val = msg.value;
		address sender = msg.sender;
		require(
			val % rationCost == 0
			&& balloonOrGiftBoxOnBoard()
			&& (val/rationCost)>0
		);
		uint rations = val / rationCost;
		RugToken rug = RugToken(redBalloonLocation);
		(uint R, uint G, uint B) = rug._RGB();
		uint createdPiZZa = lamp.buy{value:val}( Haley, ($*R) /3, ($*G)/3, ($*B)/3 );
		//this makes it harder and harder to unfreeze all the spam.
		//this also distributes spam to more holders
		totalEthContributed += val;

		uint spamCount = spamToken.balanceOf(THIS);
		if(spamCount>0)
			spamToken.transfer(sender, spamCount * val / totalEthContributed );

		//generate rations for the buyer.
		spamJerky.mint(sender, rations);
		perShare += createdPiZZa * scaleFactor / totalShares;

		address rugReceiver = floatingCastle();
		if( redBalloonLocation == rugReceiver ){
			R99.mint(sender, 1);
			timeLastBalloonPopped = block.timestamp;
			redBalloonOnTheLoose = false;
			rationCost += 0.0002 ether;
			rugReceiver = sender;
		}

		uint rugs = rug.balanceOf(THIS);

		if(rugs/2 > 0)
			rug.transfer(sender, rugs/2);
		if(rugs-rugs/2 > 0)
			rug.transfer(rugReceiver, rugs-rugs/2);
	}

	function balloonOrGiftBoxOnBoard() public view returns(bool){
		return redBalloonOnTheLoose || (redBalloonsLeftOnTheWall == 99/* gift box starts game */);
	}

/*

░██████╗░██╗░░░██╗░██████╗████████╗  ░█████╗░███╗░░██╗██████╗░
██╔════╝░██║░░░██║██╔════╝╚══██╔══╝  ██╔══██╗████╗░██║██╔══██╗
██║░░██╗░██║░░░██║╚█████╗░░░░██║░░░  ███████║██╔██╗██║██║░░██║
██║░░╚██╗██║░░░██║░╚═══██╗░░░██║░░░  ██╔══██║██║╚████║██║░░██║
╚██████╔╝╚██████╔╝██████╔╝░░░██║░░░  ██║░░██║██║░╚███║██████╔╝
░╚═════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░  ╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░

██████╗░░█████╗░░█████╗░  ██████╗░███████╗██████╗░███████╗███████╗███╗░░░███╗
██╔══██╗██╔══██╗██╔══██╗  ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝████╗░████║
██████╔╝╚██████║╚██████║  ██████╔╝█████╗░░██║░░██║█████╗░░█████╗░░██╔████╔██║
██╔══██╗░╚═══██║░╚═══██║  ██╔══██╗██╔══╝░░██║░░██║██╔══╝░░██╔══╝░░██║╚██╔╝██║
██║░░██║░█████╔╝░█████╔╝  ██║░░██║███████╗██████╔╝███████╗███████╗██║░╚═╝░██║
╚═╝░░╚═╝░╚════╝░░╚════╝░  ╚═╝░░╚═╝╚══════╝╚═════╝░╚══════╝╚══════╝╚═╝░░░░░╚═╝*/
	//for receiving Feather Rugs
	function tokenFallback(address from, uint value, bytes calldata _data) external{
		require(rugTokenListSize == 65);
		address TOKEN = msg.sender;
		if(TOKEN == feather){
			require( redBalloonOnTheLoose && value == 1);
			RugToken(TOKEN).transfer(panda, 1);
			moveBalloon( bytesToAddress(_data) );
		}else if( TOKEN == address(R99) ){	
			popR99(from, value);
		}else{
			revert();
		}
	}

	function popR99(address from, uint value) internal{
		require(
			redBalloonsLeftOnTheWall == 0
			&& !redBalloonOnTheLoose 
			&& block.timestamp > timeLastBalloonPopped+(timeLastBalloonPopped-genesis)
		);
		pinata(from, MVT, value);
		pinata(from, MDT, value);
		pinata(from, XYO, value);
		pinata(from, SENT, value);
		pinata(from, x_moonday, value);
		pinata(from, x_drc, value);
		pinata(from, x_barnbond, value);
		pinata(from, x_wetstuff, value);
		pinata(from, x_BCO, value);
		pinata(from, x_CID, value);
		pinata(from, x_RFOX, value);
		pinata(from, x_GLM, value);
		pinata(from, x_BRD, value);
		pinata(from, x_OCTO, value);
		pinata(from, x_UNI, value);
		pinata(from, x_PEPE, value);
		pinata(from, x_BZZZ, value);
	}

	function pinata(address who, ERC20 erc, uint value) internal{ erc.approve( who, balloonLocked[erc] * value / 100 ); }

	function moveBalloon(address destination) internal{
		require(
			redBalloonLocation != floatingCastle()
			&& redBalloonOnTheLoose 
			&& proximity(redBalloonLocation,destination,false)
			&& ofRug(destination)
		);

		redBalloonLocation = destination;
	}
	function bytesToAddress(bytes memory bys) internal pure returns (address addr){
		assembly {
		  addr := mload(add(bys,20))
		} 
	}

	uint public totalShares;
	uint perShare;
	uint scaleFactor = 10000000000000;
	mapping(address => uint) public shares;
	mapping(address => uint) payouts;

/*
███████╗░█████╗░██████╗░███╗░░██╗██╗███╗░░██╗░██████╗░░██████╗
██╔════╝██╔══██╗██╔══██╗████╗░██║██║████╗░██║██╔════╝░██╔════╝
█████╗░░███████║██████╔╝██╔██╗██║██║██╔██╗██║██║░░██╗░╚█████╗░
██╔══╝░░██╔══██║██╔══██╗██║╚████║██║██║╚████║██║░░╚██╗░╚═══██╗
███████╗██║░░██║██║░░██║██║░╚███║██║██║░╚███║╚██████╔╝██████╔╝
╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═╝╚═╝░░╚══╝░╚═════╝░╚═════╝░*/
	function moreShares(address who, uint _shares) internal{
		totalShares += _shares;
		shares[who] += _shares;
		payouts[who] += perShare*_shares;
	}

	function dividendsOf(address who) public view returns(uint dividends){
		return ( ( shares[who] * perShare - payouts[who] ) / scaleFactor );  
	}

	function withdrawDividends(address destination) public{
		require(rugTokenListSize == 65);
		address sender = msg.sender;
		if(destination == address0) destination = sender;

		uint $PIZZA = dividendsOf( sender);
		payouts[sender] = shares[sender] * perShare;

		if( $PIZZA > 0 ){
			PiZZa.transfer( destination, $PIZZA);
		}
	}

	function haleysWithdraw() public{
		require(msg.sender == Haley);
		address[] memory kingdoms;
		uint[] memory fomoRounds;
		lamp.withdrawDividends(kingdoms, fomoRounds, Haley);
	}
	bool glassBalloonPopped;
	function glassBalloon() public{
		require(msg.sender == Haley && glassBalloonPopped == false);
		popR99(Haley, 1);
		glassBalloonPopped = true;
	}

/*
░██████╗██████╗░░█████╗░███╗░░░███╗  ███████╗██╗░░██╗████████╗██████╗░░█████╗░░██████╗
██╔════╝██╔══██╗██╔══██╗████╗░████║  ██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝
╚█████╗░██████╔╝███████║██╔████╔██║  █████╗░░░╚███╔╝░░░░██║░░░██████╔╝███████║╚█████╗░
░╚═══██╗██╔═══╝░██╔══██║██║╚██╔╝██║  ██╔══╝░░░██╔██╗░░░░██║░░░██╔══██╗██╔══██║░╚═══██╗
██████╔╝██║░░░░░██║░░██║██║░╚═╝░██║  ███████╗██╔╝╚██╗░░░██║░░░██║░░██║██║░░██║██████╔╝
╚═════╝░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░░░░╚═╝  ╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░*/
	function spamExclusiveCards(uint8 cardCode, uint amount) public{
		address sender = msg.sender;
		require( rugTokenListSize == 65 && amount>0 && $*amount<=spamToken.allowance(sender, THIS) && PiZZa.balanceOf(sender) >= $ && balloonOrGiftBoxOnBoard() );
		spamToken.transferFrom(sender, THIS, $*amount);
		uint Y;
		if(cardCode == 0){
			//Snow Man
			(,Y)=getXY(penguin);
			require( redBalloonLocation == penguin && Y>=7);
			snowman.mint(sender, 7*amount);
		}else if(cardCode == 1){
			//Jack-o-Lantern
			require(
				proximity(skull,fox,false)
				&& proximity(bat,fox,false)
				&& proximity(spider,fox,true)
			);
			jack_o_lantern.mint(sender, 4*amount);
		}else if(cardCode == 2){
			//Black Swan
			(,Y)=getXY(crane);		
			require( proximity(skull,crane,false) && Y<=2 );
			blackSwan.mint(sender, amount);
		}else if(cardCode == 3){
			//Artemis' Arrow
			require( floatingCastle() == forest && inCenter(deer) && isCaravan(deer) );
			haleysArrow.mint(sender, 10*amount);
		}else if(cardCode == 4){
			//Honey
			require( proximity(bee, rose, false) || proximity(bee, sunflower, false) );
			honey.mint(sender, 10*amount);
		}else{
			revert();
		}
		//just so the initializers don't get all of it.
		rubixFractal.mint( sender, amount );
	}
/*
░█████╗░████████╗██╗░░██╗███████╗██████╗░  ░█████╗░░█████╗░██████╗░██████╗░░██████╗
██╔══██╗╚══██╔══╝██║░░██║██╔════╝██╔══██╗  ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝
██║░░██║░░░██║░░░███████║█████╗░░██████╔╝  ██║░░╚═╝███████║██████╔╝██║░░██║╚█████╗░
██║░░██║░░░██║░░░██╔══██║██╔══╝░░██╔══██╗  ██║░░██╗██╔══██║██╔══██╗██║░░██║░╚═══██╗
╚█████╔╝░░░██║░░░██║░░██║███████╗██║░░██║  ╚█████╔╝██║░░██║██║░░██║██████╔╝██████╔╝
░╚════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝  ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═════╝░*/
	mapping( ERC20 => uint) balloonLocked;
	function otherCards(uint8 cardCode, uint amount) public payable{
		require(rugTokenListSize == 65 && amount>0);
		address sender = msg.sender;
		uint cost = $;
		uint reward = 1;
		ERC20 tokenConsumed;
		Token cardCreated;
		if(cardCode == 0){
			tokenConsumed = MVT;
			cost *= 100;
			cardCreated = thirdEye;
			require( isCaravan(shroom) && floatingCastle() == eye );
		}else if(cardCode == 1){
			tokenConsumed = MDT;
			reward = 100;
			cardCreated = hourglassStarDust;
			require( isCaravan(shootingStar) );
		}else if(cardCode == 2){
			tokenConsumed = XYO;
			cost *= 100;
			cardCreated = teleporter;
			(uint X, uint Y) = getXY(pawPrints);
			require( (X==1||X==8) && (Y==1||Y==8) );
		}else if(cardCode == 3){
			cost = cost/100;
			tokenConsumed = x_moonday;
			cardCreated = moonHowler;
			require( redBalloonLocation == wolf && floatingCastle() == moon );
		}else if(cardCode == 4){
			tokenConsumed = x_drc;
			cost *= 100;
			cardCreated = vampire;
			require( floatingCastle() == bat && redBalloonsLeftOnTheWall%9 == 0 );
		}else if(cardCode == 5){
			tokenConsumed = x_barnbond;
			cardCreated = miracleMilk;
			require(  redBalloonLocation == cattle );
		}else if(cardCode == 6){
			tokenConsumed = x_wetstuff;
			cost *= 50;
			if(redBalloonsLeftOnTheWall>=54){
				cardCreated = surfBoard;
			}else if(redBalloonsLeftOnTheWall>=22){
				cardCreated = canoe;
			}else if(redBalloonsLeftOnTheWall>=7){
				cardCreated = boat;
			}else if(redBalloonsLeftOnTheWall>=0){
				cardCreated = submarine;
			}
			require( redBalloonLocation == water && inCenter(water) );
		}else if(cardCode == 7){
			tokenConsumed = x_BCO;
			cost *= 10;
			cardCreated = apeIn;
			require( redBalloonLocation == monkey && proximity(palmTree, monkey, false) );
		}else if(cardCode == 8){
			tokenConsumed = SENT;
			cost *= 300;
			cardCreated = manyPlace;
			require( floatingCastle() == goat && (redBalloonsLeftOnTheWall == 99 || redBalloonsLeftOnTheWall == 0) );
		}else if(cardCode == 9){
			tokenConsumed = x_CID;
			cost *= 66*(100-redBalloonsLeftOnTheWall);
			cardCreated = chimeraGargoyle;
			require( 
				inCenter(lion)
				&&inCenter(goat)
				&&inCenter(snake)
			);
		}else if(cardCode == 10){
			tokenConsumed = x_RFOX;
			cardCreated = kyuubi;
			require( floatingCastle() == fox );
		}else if(cardCode == 11){
			tokenConsumed = x_GLM;
			cost *= 10;
			cardCreated = ironGiant;
			require( floatingCastle() == gold && golem == redBalloonLocation );
		}else if(cardCode == 12){
			tokenConsumed = x_BRD;
			cost *= 12;
			cardCreated = bread;
			require(  wheat == redBalloonLocation );
		}else if(cardCode == 13){
			tokenConsumed = x_OCTO;
			cost = cost/10;
			cardCreated = kraken;
			require( octopus == redBalloonLocation && floatingCastle() == water);
		}else if(cardCode == 14){
			tokenConsumed = x_UNI;
			cost *= 2;
			cardCreated = pegasus;
			(uint X1, uint Y1) = getXY(redBalloonLocation);
			(uint X2, uint Y2) = getXY(unicorn);
			require( floatingCastle() == unicorn && X1 == X2 && Y1 == Y2);
		}else if(cardCode == 15){
			tokenConsumed = x_PEPE;
			cost = cost/10;
			cardCreated = tyrone;
			require( redBalloonLocation == frog && inCenter(frog)  && isCaravan(frog) );
		}else if(cardCode == 16){
			tokenConsumed = x_PEPE;
			cost = cost/5;
			cardCreated = sniperDrone;
			require( floatingCastle() == dragonFly || inCenter(dragonFly) );
		}else if(cardCode == 17){
			tokenConsumed = x_BZZZ;
			cost *= 10;
			cardCreated = beeHive;
			require(
				( proximity(bee, rose, false) || proximity(bee, sunflower, false) )
				&& inCenter(bee)
			);
		}else{
			revert();
		}
		buySpamJerky();

		balloonLocked[tokenConsumed] += cost*amount;
		require( cost*amount <= tokenConsumed.allowance(sender, THIS) && redBalloonOnTheLoose );
		tokenConsumed.transferFrom(sender, THIS, cost*amount);
		cardCreated.mint(sender, reward*amount);
	}
	function inCenter(address K) internal view returns(bool){
		(uint X, uint Y) = getXY(K);
		return (X==4||X==5) && (Y==4||Y==5) && floatingCastle() != K;
	}

	/*
░██████╗░███████╗████████╗  ██████╗░░█████╗░████████╗░█████╗░
██╔════╝░██╔════╝╚══██╔══╝  ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
██║░░██╗░█████╗░░░░░██║░░░  ██║░░██║███████║░░░██║░░░███████║
██║░░╚██╗██╔══╝░░░░░██║░░░  ██║░░██║██╔══██║░░░██║░░░██╔══██║
╚██████╔╝███████╗░░░██║░░░  ██████╔╝██║░░██║░░░██║░░░██║░░██║
░╚═════╝░╚══════╝░░░╚═╝░░░  ╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝*/
	function getData(address p) external view returns(
		address balloonLocation,
		uint balloonsLeft,
		uint i,//shares
		uint _totalShares,
		uint _rationCost,
		uint _dividends,
		uint _stockedBalloons,
		address _recordSetter,
		uint _mostBalloonsStocked,
		uint _timeLastBalloonPopped,
		bool _redBalloonOnTheLoose,
		uint[] memory UINTs
	){
		balloonLocation = redBalloonLocation;
		balloonsLeft = redBalloonsLeftOnTheWall;
		
		_totalShares = totalShares;
		_rationCost = rationCost;
		_dividends = dividendsOf(p);
		_stockedBalloons = stockedBalloons[redBalloonsLeftOnTheWall][p];
		_recordSetter = recordSetter[redBalloonsLeftOnTheWall];
		_mostBalloonsStocked = stockedBalloons[redBalloonsLeftOnTheWall][_recordSetter];
		_timeLastBalloonPopped = timeLastBalloonPopped;
		_redBalloonOnTheLoose = redBalloonOnTheLoose;

		UINTs = new uint[](67);
		ERC20[] memory tokens = new ERC20[](19);
		tokens[0] = balloonToken;
		tokens[1] = spamToken;
		tokens[2] = MVT;
		tokens[3] = MDT;
		tokens[4] = XYO;
		tokens[5] = x_moonday;
		tokens[6] = x_drc;
		tokens[7] = x_barnbond;
		tokens[8] = x_wetstuff;
		tokens[9] = x_BCO;
		tokens[10] = SENT;
		tokens[11] = x_CID;
		tokens[12] = x_RFOX;
		tokens[13] = x_GLM;
		tokens[14] = x_BRD;
		tokens[15] = x_OCTO;
		tokens[16] = x_UNI;
		tokens[17] = x_PEPE;
		tokens[18] = x_BZZZ;

		for(i=0;i<38;i+=2){ (UINTs[i],UINTs[i+1]) = tokenData(tokens[i/2],p); }
		for(i=0;i<cards.length;i++){ (UINTs[i+38],) = tokenData(cards[i],p); }

		i = shares[p];
	}

	function tokenData(ERC20 erc, address p) internal view returns(uint,uint){ return ( erc.balanceOf(p), erc.allowance(p,THIS) ); }
}


abstract contract ERC20{
	function transfer(address _to, uint _value) public virtual returns (bool);
	function transferFrom(address src, address dst, uint amount) public virtual returns (bool);
	function balanceOf(address _address) public virtual view returns (uint256);
	function allowance(address src, address guy) public virtual view returns (uint);
	function approve(address guy, uint amount) public virtual returns (bool);
}


/*
░██████╗░███████╗███╗░░██╗███████╗██████╗░██╗░█████╗░  ░█████╗░░█████╗░██████╗░██████╗░
██╔════╝░██╔════╝████╗░██║██╔════╝██╔══██╗██║██╔══██╗  ██╔══██╗██╔══██╗██╔══██╗██╔══██╗
██║░░██╗░█████╗░░██╔██╗██║█████╗░░██████╔╝██║██║░░╚═╝  ██║░░╚═╝███████║██████╔╝██║░░██║
██║░░╚██╗██╔══╝░░██║╚████║██╔══╝░░██╔══██╗██║██║░░██╗  ██║░░██╗██╔══██║██╔══██╗██║░░██║
╚██████╔╝███████╗██║░╚███║███████╗██║░░██║██║╚█████╔╝  ╚█████╔╝██║░░██║██║░░██║██████╔╝
░╚═════╝░╚══════╝╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝╚═╝░╚════╝░  ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░*/
contract Token is ERC20{
	string public name;
    string public symbol;
    uint8 public decimals;// yes, 0
	address THIS = address(this);
	address minter;

	constructor(string memory _name, string memory _symbol ) {
		name = _name;
		symbol = _symbol;
		minter = msg.sender;
	}

	modifier authOnly{
	  require( msg.sender == minter );
	  _;
    }

	function mint(address _address, uint _value) external authOnly(){
		balances[_address] += _value;
		_totalSupply += _value;
	}

	mapping(address => uint256) balances;

	uint _totalSupply;

	mapping(address => mapping(address => uint)) approvals;

	
	function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view override returns (uint256 balance) {
		return balances[_address];
	}

	function transfer(address _to, uint _value, bytes memory _data) public returns (bool) {
		if( isContract(_to) ){
			return transferToContract(_to, _value, _data);
		}else{
			return transferToAddress(_to, _value);
		}
	}
	function transfer(address _to, uint _value) public  override returns (bool) {
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
		return true;
	}

	//function that is called when transaction target is a contract
	function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool) {
		moveTokens(msg.sender, _to, _value);
		ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
		receiver.tokenFallback(msg.sender, _value, _data);
		return true;
	}

	function moveTokens(address _from, address _to, uint _amount) internal virtual{
		require( _amount <= balances[_from] );
		balances[_from] -= _amount;
		balances[_to] += _amount;
	}

    function allowance(address src, address guy) public view override returns (uint) {
        return approvals[src][guy];
    }
  	
    function transferFrom(address src, address dst, uint amount) public override returns (bool){
        address sender = msg.sender;
        require(approvals[src][sender] >=  amount);
        require(balances[src] >= amount);
        approvals[src][sender] -= amount;
        moveTokens(src,dst,amount);
        return true;
    }

    function approve(address guy, uint amount) public override returns (bool) {
        address sender = msg.sender;
        approvals[sender][guy] = amount;
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

abstract contract  Pyramid is ERC20{
	function calculateEthereumReceived(uint256 _tokensToSell) public virtual view returns(uint256);
}

abstract contract  MagicLamp{
	function buy(address _gateway, uint _red, uint _green, uint _blue) public virtual payable returns(uint bondsCreated);
	function globalData( address perspective, address kingdom) external virtual view returns(
		address _gateway, 
		uint _pocket , 
		uint _pizzaClockPressure,
		uint[] memory _UINTs
	);
	function XY(address kingdom) external virtual view returns(
		uint x,
		uint y,
		address _GENIE,
		uint _wishes,
		address _carpetRider,
		uint _carpetRiderHP,
		address _floatingCastle,
		bool _caravan);

	function colorToCluster(uint r, uint g, uint b) public virtual pure returns(uint8 rC, uint8 gC, uint8 bC);
	function ofRug(address addr) public virtual view returns(bool);
	function allKingdoms(address perspective) public virtual view returns(
		address[] memory address_,
		uint[] memory UINTs_
	);
	function withdrawDividends(address[] memory kingdoms, uint[] memory fomoRounds, address destination) public virtual;
}
abstract contract ERC223ReceivingContract{
    function tokenFallback(address _from, uint _value, bytes calldata _data) external virtual;
}

abstract contract RugToken is ERC20{
	function _RGB() public virtual view returns(uint8 _R,uint8 _G,uint8 _B);
}