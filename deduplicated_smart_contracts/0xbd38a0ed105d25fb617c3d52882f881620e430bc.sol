/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity 		^0.4.21	;							

												

		interface IERC20Token {										

			function totalSupply() public constant returns (uint);									

			function balanceOf(address tokenlender) public constant returns (uint balance);									

			function allowance(address tokenlender, address spender) public constant returns (uint remaining);									

			function transfer(address to, uint tokens) public returns (bool success);									

			function approve(address spender, uint tokens) public returns (bool success);									

			function transferFrom(address from, address to, uint tokens) public returns (bool success);									

												

			event Transfer(address indexed from, address indexed to, uint tokens);									

			event Approval(address indexed tokenlender, address indexed spender, uint tokens);									

		}										

												

		contract	PI_FGRA_P2		{							

												

			address	owner	;							

												

			function	PI_FGRA_P2		()	public	{				

				owner	= msg.sender;							

			}									

												

			modifier	onlyOwner	() {							

				require(msg.sender ==		owner	);					

				_;								

			}									

												

												

												

		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										

												

												

			uint256	Sinistre	=	1000	;					

												

			function	setSinistre	(	uint256	newSinistre	)	public	onlyOwner	{	

				Sinistre	=	newSinistre	;					

			}									

												

			function	getSinistre	()	public	constant	returns	(	uint256	)	{

				return	Sinistre	;						

			}									

												

												

												

		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										

												

												

			uint256	Sinistre_effectif	=	1000	;					

												

			function	setSinistre_effectif	(	uint256	newSinistre_effectif	)	public	onlyOwner	{	

				Sinistre_effectif	=	newSinistre_effectif	;					

			}									

												

			function	getSinistre_effectif	()	public	constant	returns	(	uint256	)	{

				return	Sinistre_effectif	;						

			}									

												

												

												

		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										

												

												

			uint256	Realisation	=	1000	;					

												

			function	setRealisation	(	uint256	newRealisation	)	public	onlyOwner	{	

				Realisation	=	newRealisation	;					

			}									

												

			function	getRealisation	()	public	constant	returns	(	uint256	)	{

				return	Realisation	;						

			}									

												

												

												

		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										

												

												

			uint256	Realisation_effective	=	1000	;					

												

			function	setRealisation_effective	(	uint256	newRealisation_effective	)	public	onlyOwner	{	

				Realisation_effective	=	newRealisation_effective	;					

			}									

												

			function	getRealisation_effective	()	public	constant	returns	(	uint256	)	{

				return	Realisation_effective	;						

			}									

												

												

												

		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										

												

												

			uint256	Ouverture_des_droits	=	1000	;					

												

			function	setOuverture_des_droits	(	uint256	newOuverture_des_droits	)	public	onlyOwner	{	

				Ouverture_des_droits	=	newOuverture_des_droits	;					

			}									

												

			function	getOuverture_des_droits	()	public	constant	returns	(	uint256	)	{

				return	Ouverture_des_droits	;						

			}									

												

												

												

		// IN DATA / SET DATA / GET DATA / UINT 256 / PUBLIC / ONLY OWNER / CONSTANT										

												

												

			uint256	Ouverture_effective	=	1000	;					

												

			function	setOuverture_effective	(	uint256	newOuverture_effective	)	public	onlyOwner	{	

				Ouverture_effective	=	newOuverture_effective	;					

			}									

												

			function	getOuverture_effective	()	public	constant	returns	(	uint256	)	{

				return	Ouverture_effective	;						

			}									

												

												

												

			address	public	User_1		=	msg.sender				;

			address	public	User_2		;//	_User_2				;

			address	public	User_3		;//	_User_3				;

			address	public	User_4		;//	_User_4				;

			address	public	User_5		;//	_User_5				;

												

			IERC20Token	public	Police_1		;//	_Police_1				;

			IERC20Token	public	Police_2		;//	_Police_2				;

			IERC20Token	public	Police_3		;//	_Police_3				;

			IERC20Token	public	Police_4		;//	_Police_4				;

			IERC20Token	public	Police_5		;//	_Police_5				;

												

			uint256	public	Standard_1		;//	_Standard_1				;

			uint256	public	Standard_2		;//	_Standard_2				;

			uint256	public	Standard_3		;//	_Standard_3				;

			uint256	public	Standard_4		;//	_Standard_4				;

			uint256	public	Standard_5		;//	_Standard_5				;

												

			function	Admissibilite_1				(				

				address	_User_1		,					

				IERC20Token	_Police_1		,					

				uint256	_Standard_1							

			)									

				public	onlyOwner							

			{									

				User_1		=	_User_1		;			

				Police_1		=	_Police_1		;			

				Standard_1		=	_Standard_1		;			

			}									

												

			function	Admissibilite_2				(				

				address	_User_2		,					

				IERC20Token	_Police_2		,					

				uint256	_Standard_2							

			)									

				public	onlyOwner							

			{									

				User_2		=	_User_2		;			

				Police_2		=	_Police_2		;			

				Standard_2		=	_Standard_2		;			

			}									

												

			function	Admissibilite_3				(				

				address	_User_3		,					

				IERC20Token	_Police_3		,					

				uint256	_Standard_3							

			)									

				public	onlyOwner							

			{									

				User_3		=	_User_3		;			

				Police_3		=	_Police_3		;			

				Standard_3		=	_Standard_3		;			

			}									

												

			function	Admissibilite_4				(				

				address	_User_4		,					

				IERC20Token	_Police_4		,					

				uint256	_Standard_4							

			)									

				public	onlyOwner							

			{									

				User_4		=	_User_4		;			

				Police_4		=	_Police_4		;			

				Standard_4		=	_Standard_4		;			

			}									

												

			function	Admissibilite_5				(				

				address	_User_5		,					

				IERC20Token	_Police_5		,					

				uint256	_Standard_5							

			)									

				public	onlyOwner							

			{									

				User_5		=	_User_5		;			

				Police_5		=	_Police_5		;			

				Standard_5		=	_Standard_5		;			

			}									

			//									

			//									

												

			function	Indemnisation_1				()	public	{		

				require(	msg.sender == User_1			);				

				require(	Police_1.transfer(User_1, Standard_1)			);				

				require(	Sinistre == Sinistre_effectif			);				

				require(	Realisation == Realisation_effective			);				

				require(	Ouverture_des_droits == Ouverture_effective			);				

			}									

												

			function	Indemnisation_2				()	public	{		

				require(	msg.sender == User_2			);				

				require(	Police_2.transfer(User_1, Standard_2)			);				

				require(	Sinistre == Sinistre_effectif			);				

				require(	Realisation == Realisation_effective			);				

				require(	Ouverture_des_droits == Ouverture_effective			);				

			}									

												

			function	Indemnisation_3				()	public	{		

				require(	msg.sender == User_3			);				

				require(	Police_3.transfer(User_1, Standard_3)			);				

				require(	Sinistre == Sinistre_effectif			);				

				require(	Realisation == Realisation_effective			);				

				require(	Ouverture_des_droits == Ouverture_effective			);				

			}									

												

			function	Indemnisation_4				()	public	{		

				require(	msg.sender == User_4			);				

				require(	Police_4.transfer(User_1, Standard_4)			);				

				require(	Sinistre == Sinistre_effectif			);				

				require(	Realisation == Realisation_effective			);				

				require(	Ouverture_des_droits == Ouverture_effective			);				

			}									

												

			function	Indemnisation_5				()	public	{		

				require(	msg.sender == User_5			);				

				require(	Police_5.transfer(User_1, Standard_5)			);				

				require(	Sinistre == Sinistre_effectif			);				

				require(	Realisation == Realisation_effective			);				

				require(	Ouverture_des_droits == Ouverture_effective			);				

			}									

												

												

												

												

//	1	0										

//	2	0										

//	3	0										

//	4	0										

//	5	0										

//	6	0										

//	7	0										

//	8	0										

//	9	0										

//	10	0										

//	11	0										

//	12	0										

//	13	0										

//	14	0										

//	15	0										

//	16	0										

//	17	0										

//	18	0										

//	19	0										

//	20	0										

//	21	0										

//	22	0										

//	23	0										

//	24	0										

//	25	0										

//	26	0										

//	27	0										

//	28	0										

//	29	0										

//	30	0										

//	31	0										

//	32	0										

//	33	0										

//	34	0										

//	35	0										

//	36	0										

//	37	0										

//	38	0										

//	39	0										

//	40	0										

//	41	0										

//	42	0										

//	43	0										

//	44	0										

//	45	0										

//	46	0										

//	47	0										

//	48	0										

//	49	0										

//	50	0										

//	51	0										

//	52	0										

//	53	0										

//	54	0										

//	55	0										

//	56	0										

//	57	0										

//	58	0										

//	59	0										

//	60	0										

//	61	0										

//	62	0										

//	63	0										

//	64	0										

//	65	0										

//	66	0										

//	67	0										

//	68	0										

//	69	0										

//	70	0										

//	71	0										

//	72	0										

//	73	0										

//	74	0										

//	75	0										

//	76	0										

//	77	0										

//	78	0										

//	79	0										

												

												

												

//	1	0										

//	2	0										

//	3	0										

//	4	0										

//	5	0										

//	6	0										

//	7	0										

//	8	0										

//	9	0										

//	10	0										

//	11	0										

//	12	0										

//	13	0										

//	14	0										

//	15	0										

//	16	0										

//	17	0										

//	18	0										

//	19	0										

//	20	0										

//	21	0										

//	22	0										

//	23	0										

//	24	0										

//	25	0										

//	26	0										

//	27	0										

//	28	0										

//	29	0										

//	30	0										

//	31	0										

//	32	0										

//	33	0										

//	34	0										

//	35	0										

//	36	0										

//	37	0										

//	38	0										

//	39	0										

//	40	0										

//	41	0										

//	42	0										

//	43	0										

//	44	0										

//	45	0										

//	46	0										

//	47	0										

//	48	0										

//	49	0										

//	50	0										

//	51	0										

//	52	0										

//	53	0										

//	54	0										

//	55	0										

//	56	0										

//	57	0										

//	58	0										

//	59	0										

//	60	0										

//	61	0										

//	62	0										

//	63	0										

//	64	0										

//	65	0										

//	66	0										

//	67	0										

//	68	0										

//	69	0										

//	70	0										

//	71	0										

//	72	0										

//	73	0										

//	74	0										

//	75	0										

//	76	0										

//	77	0										

//	78	0										

//	79	0										

												

												

												

//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« naVsA1J90M552d3o49974vHWu42rRHCY27kipV7m25LiSwedhTxjs0Pj0UM41GKw »					

//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« 9XI6y2e6R944jC07aosU74NxA7V3081h090AO54rKbiv8T6k31xaTJmjWZn9PDU6 »					

//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« s350b4J94nObS7QEil1PgC1RTsOR4jX2XYkLwdibKRU75rtKRV6hf32k5ZX82kkb »					

//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« WU9c1Y33i0BGEz9He0K26px6dHaRP80B4DVr3h0273c2f8RR1957Qr25ziUw1XOX »					

//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« lJ2H80aZb6g52MlhKb63Q4mBk61n6RK451q369gv1Om8fJ823jj6f81gPyc2Tlyy »					

//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« 17P4fWQN101OEfgWwllzppEK7dje8wyrKRoZki4Wun9nUw4Tee9fScWQKkrHERaq »					

//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« 8uKJ93UVqqt5wxPdt818GEU53eqIp8QrK35cD1038fieC2iopprrM9r54X28rKl0 »					

//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« TDiflA3vzRh3I61zbIcaLEVOJ30PK5Pe9LtAskx28fK7Pwe0AKO3hvD05uvuF44b »					

//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« 87KkNlrs4MokAkjo9W4DD13xFN6H6C8Up6skhN0Fs63mNkK77S1Plh8RlUly5E9L »					

//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« 2NgyjTr8b22hJwOxh690sLQ8z7503Vw19jG2kV3aBedVi5ysJsogqqYgu7PQ4tj2 »					

//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« d93norUA4RhffeS5Qrt421d9VHx8J53Fgamqbdp1RFJ43sdiYLXV8lr1kZ6lqYz3 »					

//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« TGxhSH6Km268kKvVb0s4pEz32JH1YkocjAGYasCPZr5hA2csFHCJBU2C0Lhn7bwv »					

//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« 7Sa9lT4g3qD4v686H517p22D28OuQv3FAL392X4zI66zp1MPGr5JJb13TU2d6Hnw »					

//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« 0Kn0q37Cg5D5O9Uwob58ymc85G7G9486NXbExNW556a23QBiX6ZiKym7SV9T4zLK »					

//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« 0RW4ho334ajY947wxwTUhig1AP1XI6m2s5V09FOg0g2mu8Em0CzJp5rrzHiQtpw6 »					

//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« 1FWEVOHsi5QLSqnhQrg44cXorNSXCdG1D6Hgs9V3somjCW0xl95UqDhdLNT2c46X »					

//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« nmFNYjSNAO5sN4SKmAFLndz1bZbg6nTbqjz9dlDf45Az6o6u05HeC3FUI4eR8ppN »					

//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« mbhdlXA52e3gt5esyG2TO9L13RwuYWT79NiMj5P9B62IoLKabn2JrIXS88AgeQ5P »					

//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« 86PLqLG8Hq5DQ0zip7U6Hl426awGIQwC1bwMiQwaM5lMW2PI9HkCfYHO4xsCO2zR »					

//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« Jr2Lj3nd0aF27J2RzH9hHOUvvMe04omVC3l8k9u3ZMg1f9ahog8n6z00j0dB980M »					

//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« MmF14Y9TMXSJa5tKhyV43p3AIsTK1mgZHP2E374s4215Dt6Ka3x1OE1KPWOe7X4N »					

//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« 3Y8Z8YL3ZpiNFmpIm2X8YtvyS0orb3x20E3Groa43by3DqgPK77of5pX2lLl90rf »					

//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« 00IdgJ6v02grq1YKvkgUE36Ki6tX3K1gx758uzKO1y6XM1B5bE277Xx04Pk5qY0J »					

//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« a6xK94dZ1Hx7tjW4A3gzBE6T3X75OWZ3clpxZtDP4V9A1omjnG7fp8FqBn7309Bl »					

//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« 1Lwp0fC44jLO8k588QB3IQXq397I0n1NcTj5wa1cfTl7qcbF6h7q1tTpFSbfa037 »					

//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« 6TkkS3VU2qK6UESG5QD3yx6BwAalfMUJP5Numa9U4h2VJ19AP16G2b7Kw203B2f0 »					

//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« DYq72MUo9Y2VxSpFEi15p1SD1XKtyd73ifk6Ls2q824C71U7lZFb6u87HECb80Ac »					

//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« 6oCW771cKvzo0oK0rjlyPI5b9o14Ebpn5f9HHL8417ruX46460mqyaS2chNkfrHB »					

//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« bcUD76i8OLZKpggC3QZrPPq8IyMvjIOYVDR0p8IN6ZJC2yS8E8g3rPPcHwR2KwjZ »					

//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« 9lUyvs27VSBo3wij5jpP7Sd8c4fc9Ya0bucY7OiyvZOuJ3PbxHEvNzr92Yvov0hk »					

//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« cO6z46yk5z9cm7Oow0PNQN3e3I9GKoU1az4334iSpDs5JnVN9XMvxRw5V677cXtF »					

//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« BiY09p4zIy3Y1sB9Y71RFo5LJXjbQzfdx9Vr5t8uljbp3309gZ9YGwYxVt3g27A5 »					

//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« 5hA17fN2Fx3VqiFfl7MdsVCYq53Rl5Qna2BKO3k223t3ul194P70kUnHRtT9Aw40 »					

//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« xRPg7QUjTG8sZ6UJtV2QRxOI9Syd87PP0ed40z7187ZG1iCDYnH8r7bjaCAov1lo »					

//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« UGlCnZ9uA7nKNk5xlF38m8e496bi3G768kX0z6DDN1ltq59n6sSvKO4OgYWBE45j »					

//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« 0AmbJTuNv65w23gHVfJ64uOUD01WitNM0b80ONPkkU1ku4jVjuF96PvBluPLVV8l »					

//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« 34gwF8WGMBFft1tJk3p458aW7sY2bCDHHh6RCTDKkHAMFN4Q6x6QP65Pg88KFau8 »					

//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« FvtyRUMx9600270Ds1wX7Mu6B667H31EV9805xGXi0kp0ccLgGx4P8ic9139vN7e »					

//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« mYpI84NJFpIh5m21j3BAIj2Wx4s7x7TOyIlJXPvL2KM78d66vaf0Cb64tIB60s4l »					

//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« i2Q93X6lTqJ94R9nrZYRVVuE9uDoPc6Yx16Ao3sBt4b1NIfFlhp02W644F98VHMR »					

//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« 926dtt5S93qI1kB36p0xDN8h69wBMY3rzFBui4Zp99rWLgNO5J718E6WN0VlvTjb »					

//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« BmSZxb1CJy8Sip4fuwFKPVF0IstF29f6BBWi5LnkLdp7pbx2FX86qU1679DV8Ph0 »					

//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« 72I6Xjz56FI0j82qjlvOkPHwnXCCn219wvtwxMY7QEA4640PSQODl7eFE4qrI22F »					

//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« 7xCrv10EM0pm6ZZY55aA761AfkK4BU6UBbXlcl9WhuWiMdLXE69pBQZnrmOS33V1 »					

//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« 7TC0P1qoCo9I6217185cbSd02KQ0oB8D1bths5haj8hS7kpIcSr8H7Cdg84m2b4m »					

//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« WW0yUJc3oy4OT71KNl41pS9r0dz3VtCCMFTirntBMk1XztOl7N412pwp58g53Peg »					

//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« PL457qZGgnJ5503Qbx227HhgROG75Fbx7zvbs073pmJ0UKHfE0gt9s44W0uO5V28 »					

//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« adKek963HYQw3v8pjfHl6fNE36b7Fh2unrP7p9vvB30g29Jc2f4482etbmjsLtOi »					

//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« 29RfF87WwW9o3cY6gS5Q4HZW6W3LvuqJ2jyGg0McgiA0NQTO8C76j9sllAZtzFN6 »					

//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« d3zM3hvHKu8w3bNGR7u617jhy5GgGEfjE81jH50b63m3duWhX3Hb43nAG6sV59g4 »					

//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« 3kK5SeqVMTPS0wX5N11UM128IwV5j1vbcEx5sqp83Cy577DUtbQ39Dw07D9x1vDl »					

//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« 8831diAi9W8vXxyGG60mB1O542yYG9mry76x183NNd03wUFa5WhL6htLNtEnR1n1 »					

//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« WX8cgCic3yW8Hs1AZ0G9j29Er31DAS7af39JKoyHJk13Ka92K2U8247Lz0fDLZus »					

//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« QIKOH8OyxaJMK4Or57S76m1KlE76PFclNAz73bSVO0TttJgmd1wijzprc4l402rH »					

//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« IsF686Xy4X6J8Wj8w4980izJfW2ICu1hM3958a0aq72p49E2XmuegDj1u8r7PX69 »					

//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« sl1HUSp8cEs4y2o6vJc2g3SJMyIWvD6qNd0vfkKRTcMp5F5DD437c4J7cUGHfOGF »					

//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« XQGuC42dBTP6z7bo5iQ8lY618WL71aKnqc22g1Jvm4l860kfHYO86e71NOhw3Vd1 »					

//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« j4j5IAeg9C0Q9Tj1UaaVOrn79dL7usvbQmYuFDuatORY8Aj709Brs05cU3M6IC0g »					

//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« gzuTt59MRoBw16LWTrAB1qdOC8mONMV9EYoJ2W7CBLjXC665gB77AZGk5k0AQ7DP »					

//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« 6dEz96C6xzfI7RYW64Wv647V3yyn1kJIhaFYtZCsRPbUw5gNX846OE4Ky3w2UYp3 »					

//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« 3FP8G78d2r3i7n1CrgrGOfSzeXOUU2Vy22WJ61RDG8qT36ycnrXsCMR4ucQZqe6v »					

//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« 5OC94D4DbHDKLJFg17W81L0zmx3rCoPte94n2pLxzJ7Gr48Wy7QcQ1LG1fCvU0Yh »					

//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« V6F0z6Us3fEPpXoX6q32COHqvvsUYtAv4O2h9F2mepd2M6Ss8UB9Wy28qR537Ygf »					

//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« 790Y70FQCzRyE2pr5cz1f74Hss6j139Qc00875OplA8JP380cYFpfOK74K9dWQEK »					

//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« tQ07vMlkJEjWb260374cfsI181Yc72G3cLvp35m0gX1bDTlhDCHnhj5V082y4iMA »					

//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« J4j5w7u1Aar6XobOg5oan0e7Z4kae8B26I8WL19qPZh35oOgD93fF704pHoOD6aE »					

//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« o7cECenk4FB20Ud0s5l26957Fka3JOgZ66nssPQ9XSrQ86En8J17aG619XpoDB75 »					

//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« 6mseYjkEgz1Op72ukEc6U3eAqvSq3cOtI5HT9z0982m0e458ClgoaL1E31IKY8X1 »					

//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« Q0OKt05jLjN4gqz8ccOSla66SGFb3CAvEuH5Iw0686FrrLHnA1qHIR5VR7o6suoh »					

//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« 0tWTs34w9J764w1W89aKO0w8gVlL7N0Ki4nR64ROLbICXL41qK6w8B6S8W65vE3S »					

//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« bmmQ8Bo25FVz61l0zQ6LxRTWQl2kJZXqqhU4EtE0D2hDE9NaH7CJ302pt6qxnv67 »					

//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« 6W0fU585yw9fjmd0jR2z2Y0R3MSo9i27F8eb3BN1dH5F33ddabu82mV2Fs00NwkD »					

//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« xm4jbww399yPGl7W6eQV8e62TQ8Nu15PU7Z3PM7Z64lvs8t2bKmLE1q5WoUf31Al »					

//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« 44x5O1kACMV93Lu3846It23Z59a18aHdC6kTmgG2UTzMD21TIebLEe3qQz7YRbsp »					

//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« 3H67zhucF460sWcvGt6b3NuU1fyN57AoHE7eTlIuVUu8OCn3GLxC65LQq6iVSLQz »					

//	76											

//	77											

//	78											

												

												

												

												

//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« jD1mdgl0WpECUz11rUrg78d3wOnV9613fbqZilPmdLA0213f9dun0VPqh73q74CO »					

//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« V6NC693W41uN0G27FB52ioLJH6H4z5uwJq7689t7AN8RBjrFV0634sY9q01yhsUl »					

//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« 3R07o8mR7dEg4NA0EY8K19XR7Aiym6EFc2P0UOlVu7u3Te48kI4Y6I3wG9Ywk33g »					

//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« 38Agv66H7DZTrCDfbE0uz07u9xeTcMlmHeS3nw8fQ3g9m4m5VFR418d8l16Zm06g »					

//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« 028ybmZFT9GVgL30130sMN8p52MzpF57XOrW0Jzhex8vwG63CFPFyZIpn95kKljW »					

//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« s035gQ5GyA3Y53KBuw1qKOb668EOlw2Y5jQzEW2t88Fh0bMSuN5z8m6DmyfXCCdG »					

//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« 4Ol073Iq31UJw3jjScYJ7Wol19JGgf5arJO1O7QUiHW87C3i284Y1rH9Jbn3Ny5C »					

//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« dO20rOwVNwsO4qD8OG4G4W079vG137Jte3DO6abOb2AYOu4U6ANBlo5us642x1pv »					

//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« 7hS2I8LRXWzdxkN7yVcKw70m9H2j2rwtVp4I05b0Q224t87b0ae8B6c2JssV92iz »					

//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« Yrj0nQ9f84RSn75EIBsK96iQfrVTEgrwb2Gv2JJE5v9kpM32tGd4sY0uKwcnO79y »					

//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« O8WebB6QtCs86t5i62Wg38M7ZQ0kR4Z778PpZY1VB24ROcUWaQs4nzk7Wj5L0g1f »					

//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« 1i0thrSK61R46teOF0ByNEh5bC5iEtO85jrR7vsoMDzb2En857c0J3sd1FZD52ri »					

//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« oL3go04fc6TWh3GgJ8IBxst5xKU8yZ85of9Oc24g52Q7S565ZJ6gB8E7pXgMcW8H »					

//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« 7R3jVac5iG8F3pdO0o2A1585SKmLuvQ8SL5vBOADRvQujOi0Li60S2wL5cyn897m »					

//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« FF4EuCRb99lKssxva08sm816rdD4h377vp5OB802kwgffd9qV7H8iYmV05xxY8FO »					

//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« VF33v160029l2630f8UWyQ0P4qtu87E7S2w7UNaVL7HliCs44E6NJ2D2H6zPLmgR »					

//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« 3bpFMw40QhV4YHBpSlGa33IhEpY004tWx4183t7L1hI4t1U9F9U6ZWq4ds6754MH »					

//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« 758Jz0zkM6sUj97S2N3BF9CI1PESC0636rXeqcoHWOMEy9So5efy04E3u76PpTKt »					

//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« uEHSr87981434jn0nl9444e1b5h0Q789vHmv38HZNwUKxxOr5VcG0q8G8Gc2TXiY »					

//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« FEC5035kvdtWYVYnM17uhRlqY6uG2hMpG0nJ81z6mMkq17R2jSTZsDN81kh6C6Oy »					

//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« gxmhmeo1Fa0bn0xC6tUApZSdur83fc5CL17n3nldqcgB8ZXKqOeF2BtCIrLx966Z »					

//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« 0Eja6Z385l3iwuahaJY3z0G09553a7DsGQit0VzM1Os19ZDTQ78vm720Y2wj5MyH »					

//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« CuYITrK2hsGz52p3541n4hphGkX3omCw1FI3XZbj1jlL5BH2s9UsCI3oKh990U3K »					

//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« 43q04gdB9XpGkt3o52Zmzy221WMZKZ5L3VofIFdsVplT6S9hl9cYc0Tf90B6Ilh1 »					

//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« x5ijv6BAoa56G3TjkQ0Se606vwE348iRfzqenr4HdH3UmW9n1t9e3O271n9Fh7dw »					

//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« 9eadDWI0biMM997pyc33rxS52ct4h1Ni40Kq8c3W7kSTxJxku5sCu17XDLLWuGn0 »					

//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« Lj8bJkjxrWja2mM6U23U9X3nh98mmxs7PIOFMu6bS0NUxsd7v4khWhCQh7rG66Aw »					

//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« 038aHbz6KC62z28t8aamkR5QVPqnGvY62HXZ096AXpg00rW3Djkujx6diSb19daN »					

//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« V5n0MTk7WK46a044lDfY8K25F3yn4Tcp21rP7XbVxARMFYjjU6gZ4IxUA6FfO6fK »					

//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« 8gB4VxS3zY9TR3wFP2gp6HfAWkov3j6Fqbc2n8ia8x80xlCa4y0r5q7a2r8gZxT2 »					

//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« QXQCEFzVKadpJlP5qG70tRT2vvLvwwj9Q95M2VNoBMbgSjOi7qD6as0l2AknY15C »					

//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« 98P06CT441QH46aH0627rq6Px955idq4B730iBPxZe30wq5pg5268fbZrnJS9Hy9 »					

//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« SYXM2qHg07614jq4Sb3kV9mgSj9zn4q6X0i94v32oWC4OeAdk068j6OAyR9iIZJB »					

//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« w4052HAQZkXL0j0X2U7VM7gK9vZWJmTekP8p4JptB8nXM08726I03RAf9v7ER6qo »					

//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« K2CcUCtMSM3seWe1585rf0v85qWoZRTJ6O63hLRLvL47kz62IRc7KUq5lA7qUN75 »					

//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« 1hQAjRcj4ju66I1ugaAWi6vB1rr1X94V6B31Sj2jFdE52NC5Yj3vWV21HF1W43k9 »					

//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« 67n5S2z628we7z5C3ASnY1MRdW2EXx14lu1rn26vTAY58F80BjX5toui2Yb9g01j »					

//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« h525cDAdLg3K3ICkx05ij8szyMJqFFOkzWrE6r9tHeFdS7Fz4lRb93iQtU5O1VJJ »					

//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« b7pS5E0Yz5s6V2EYR84579QsePWGXlVlm42btUsd6kruxBx8pMv09Zy691694XnU »					

//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« B8JRSm4Mm6HeU4ibPd9hS2FhBRCSY0W5J20T86B54Y2XH7YQvHv35L6Blrz47aFY »					

//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« zg76mo6a0yP3atZ092M7CiXlPfymRIM5KtKfK2YGRGi59dhgQq0KF35kTIuR8q9V »					

//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« FOt16rsg9NHAWF2dTUZpE2t7ZkUX0hFz9mb4OG71Kvuy0L2rn5V2m179OGrX60Yr »					

//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« 006NjmOtuU0Z909QIcdoF92vLyXLynSP4hrMxs6p6v3ag7bNyytMA2IwS8G2Tg2C »					

//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« 0Aep5uvEU8phZTo8AVb67IJ44YaR057zX64n28bKwz2950Zo2Ht6cQe89t0t9FtQ »					

//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« KAHbCPkjKUdslL7hTeEhdu4RLFA7bfbFc5l33g8wId8cQha28T3s0Y8qVm376oZo »					

//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« T4xXZcDRYFuZYbk6HnNoYLKL2K1G4312fD7Oeh5Q6ZnOeIvQD5bw9x8E06WRwk01 »					

//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« 2Vx8XeNZ44vi1OL63po22mYx6rlX03PBPfjgLNJ5ob6Xf6V8pp5109xxp79T5U6u »					

//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« Mh9543y5j55X47ypb5Dg3DclYSkosbwCZ3yOXM39IpBI0YlRVRq7HSGbZ4mE3eld »					

//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« 61s7pq8Egmj3686UYVc3tNJJmZHG694N2ccm2A3j590STnU0d8J5c25b9Xg0Q17c »					

//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« 7roBz7825a7H0iYJmj23Jswe1drkSHl5uEl0T20RBBcxm5k88Yh98Cy3IC5pLo47 »					

//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« Kin31zP77i8q088H84PVs43E24OasdF5Z1675p9O1i7ZTFX6W47kOb9vydQZ7xP1 »					

//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« l9i6L11a6l8Ce8lf80m84rg89J993GyZzEI381675I9Bl18MFU7LymC8ruk9B9vL »					

//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« EKe8LPTYu5Q62YWY0y7imS53dMq3YQ3jckChER219O14fE47UjQ7Hr9D7zPxi3Qn »					

//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« wS709RN217EWv90sGIQ7Ti6WE2bp633w9o9r0hr17eyPAHlfnh3DTOb3z48cp0NO »					

//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« lJ24kQv34J9254F7hBTCBhfwV2I0F3XnQqDJC2YmPfTl672cZx904CS6NQa8Nhvk »					

//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« EOZ873yN5338199o7685kjr82nrmSQmC391K92pE11RHWiir8nfOXmo5e6pOn0s4 »					

//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« L1X4kg5Q4PZk8L2x34kUUU79wfi73e7MjXfbT313kBUH9W3Ow0V3ut7Za7AgLJxI »					

//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« 775OopN71QjFa0B0GgCIm309UESlmX7R1RqD2mw41Mx6endLuZ2MRAE9GCInPEpk »					

//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« JOmnf19M1jXj031Jpsg36aqMk7Kv5697j8XAktuI0g8ikN15zWv8rT90P9A3VWd6 »					

//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« 78L32e90mSjURZvRJFuOe41YpV8dUI9635KmlgXlr7Sz8BWNDe6rAmkIx5L82nrj »					

//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« p7eh3z5W92Om58I2BltBCdlwe3j3lza6IW61gLEzC1J2y7eoy4WwU1Q24B06D43Y »					

//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« UXV185o7nNIdN1N2zoi3u130P7286t9UNGnKjYFT72BO45kZ2zM2KYvc8891kfdv »					

//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« ILeI0ig6jQHajkNRMpMtuL61HykYneIOM6949V5jgFGjaUXQ27J6cq1F2H87slgg »					

//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« ym4l1up299ahQBUa4zr2aPdZw1vZQoxz7Oap91Nr1y30DZVPj11mKqi9J5yLO7pC »					

//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« FmNat6sI6ql4Fr68To8efOS2nb4gW3h7tjTjqvX5IbWX4Xvbegse1069yDvdJ7o4 »					

//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« PT9n4OWJFwfy1RGPrXVIYmMAG02nIkZfpj0eCFuONXbZTiMAvnu887q2MT1J47n0 »					

//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« FstIhOKT1XI37013J9N76cG3Xu5Sg1g5BR72Xu5t2X4eeSKALGU2WX08L41D60sH »					

//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« sj3HyQw9OE91lUGu5iU5961O5CuM40zRCEfW4dw00LxSQMLmJevi7m5iV48d6yt7 »					

//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« A35V287eDBelfau38dvq3uJr6oUQftvTggALFaFMGYLFBF25b3y8tOD7Odl24Rvg »					

//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« yvqO1MGC8y8y7DnRHXP8m130AlKX5hpCsX546p36VX1W5220JGNei055fHxT1R52 »					

//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« Q228BF6uT3O6I9P292W3IsldpJGh5PsGJ6qSWHDddo6tg7mIE20QZ64f175BoO3j »					

//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« p3plgsuJ0DgUAMA6Py3Ugh6t32zfEnVg62Xat4y4qDKdNu2N3BskMVZrEkl04e6f »					

//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« Yv14fZ3OM13hAet3O0n6jNibwt0PEoWH6w9W30Uu9QztUzabmFZC0pp77Pn5i43Q »					

//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« 48rhu5ja947KcY6Wn37H9pf3VdMkQi8AvZ3T1ZjNq51ANTq3YZiy8913NBO8N6S0 »					

//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« Q6lwnEBusIkt28TtyiQQz5W9qF4bZCQUky1Jghn0moQ80ejZ5ka08Yt1957SIuZy »					

//	76											

//	77											

//	78											

												

												

		}