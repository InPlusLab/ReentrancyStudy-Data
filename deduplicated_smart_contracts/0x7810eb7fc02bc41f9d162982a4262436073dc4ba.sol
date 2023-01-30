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

												

		contract	PI_FGCR_P2		{							

												

			address	owner	;							

												

			function	PI_FGCR_P2		()	public	{				

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

												

												

												

//	1	-										

//	2	-										

//	3	-										

//	4	-										

//	5	-										

//	6	-										

//	7	-										

//	8	-										

//	9	-										

//	10	-										

//	11	-										

//	12	-										

//	13	-										

//	14	-										

//	15	-										

//	16	-										

//	17	-										

//	18	-										

//	19	-										

//	20	-										

//	21	-										

//	22	-										

//	23	-										

//	24	-										

//	25	-										

//	26	-										

//	27	-										

//	28	-										

//	29	-										

//	30	-										

//	31	-										

//	32	-										

//	33	-										

//	34	-										

//	35	-										

//	36	-										

//	37	-										

//	38	-										

//	39	-										

//	40	-										

//	41	-										

//	42	-										

//	43	-										

//	44	-										

//	45	-										

//	46	-										

//	47	-										

//	48	-										

//	49	-										

//	50	-										

//	51	-										

//	52	-										

//	53	-										

//	54	-										

//	55	-										

//	56	-										

//	57	-										

//	58	-										

//	59	-										

//	60	-										

//	61	-										

//	62	-										

//	63	-										

//	64	-										

//	65	-										

//	66	-										

//	67	-										

//	68	-										

//	69	-										

//	70	-										

//	71	-										

//	72	-										

//	73	-										

//	74	-										

//	75	-										

//	76	-										

//	77	-										

//	78	-										

//	79	-										

												

												

												

//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« t0pzPXua76Q8w9i3LN21ILYzAq4B62S30B6OKPn7lUO60q9hK6L2mPib60VbX52t »					

//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« 05t1OQ8PzPLY1SdEa8EVKKAgT590P2vG4kj34uHqun13O1GZEJe0Ff383O3fE6jd »					

//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« 6TIertxl789LHOIAgdp324g5Ar98qoFxxi7RZ16tGvwpHO4i1jn0B082ac568n56 »					

//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« 18X5XjblEVzx7g3BgfCV5xzMre99zbyDx1eEA1Ekpb74x00ufPvT7nBT3T66p45E »					

//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« wKlpuZbiu4UC8l65A3i1hZ41sMUd4StJL4itUMQ4WIo1rRjQfyL7wRVw72547NPb »					

//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« zbM8VH418NTcC04G07lF4780G3oEiLcfwJ9RJTowBNV2d14GS6EDC4ZHNdIAB2zg »					

//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« 8GgqsGG203zp50CHa2sob9NF1WSmp1EgT141V1bD9CT4zj50JJ60deBZ4DeMzFZl »					

//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« 7Oo0586XR1XMj9h5SWJTHlsWKajnfT2KO6k3L52dTDK002LYc33xUR03r9y834Py »					

//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« gLRu6BOs4F3ta7l5DKRpE1biBD9tUjb0Pea097W62MT82ydogwLeNlc0d48POc93 »					

//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« NgRC80l0Awff4UmTTB56Fa00MJ3654563g9dL35dE0BzdmMFsJpeKN4q77K6D5vL »					

//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« 8J28GCXZpPhDIIws0rLSPotPn1fBVbdk58ciolJ0GiEAUgW24S1MRDmd6Z642BEj »					

//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« 3PhQV8phS8Um30HTj94sbDX4XoEyhVDV23sk02q7IIfjFHnRH64Ic1R96C177oTa »					

//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« VtXZv183r9vJWBr8Y7PUg8CHK857A3KFo19i94IPLf7yXGRSFSYnt8hnqR27c6tF »					

//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« TDp75AT6an54ZL611rHHVg6IK8swNYf2s9LE1064v6T7M9Q2hco4ibMYYpq9p8f7 »					

//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« 7x4eZDg3u0VvfErZBZW912bnfM1hqCjcC262DBI7P81gOr36DqaTLLU2kNY7uimK »					

//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« ZGp8TWw89k06UAIqm8DOuoOi9R39CPy5eJW4rjedPH4jmRTfi8hTgXt5rtQQJOmJ »					

//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« 5eetaqfeX8o53sMfqY8TN1g8KsB1aJa6A1bPB2A42jeD4L0eDiFtbpL5R9pVilpq »					

//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« X2i3P1Z78NZm27dqfHKT0ekJin1Df7lE5y8psJqucVIFUk24o7v2G57m5b441l3p »					

//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« Flw9nUvX23Fhe1vU96WrZc2V3OzrlYizJlE265k9n0mA0EoeKp5X4CS22ZzSfHix »					

//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« 2RFtI5AzU5l6Z120myfV21WD8C84nnkk916u98sj2Sb69N7mFGmy8ouU668jT614 »					

//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« 36jm8Cw621b398vCnAfCM04mqwAU2Yj0jGa3sSKeCYhgigLwH73zo8078x29U7rO »					

//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« 935k3kU94dxH7MQzmW3730SCvknn2e0OQ2l5GM08HjG1YFBb650gLy8UlUcN2K19 »					

//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« nm0O0MVNsXY01HrTj06CTMPy2M1v9ptS8w44ooz20G964Sr9e775D95X4Z3hDlx5 »					

//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« JD831BFWCgq7MdiXrW4gBd1O34JZmUb3GNZYTDlf1A82HZEzMwU136o8CBBq2C10 »					

//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« 381Pttm9hv7k0Nq5jriW7R4Zk07a10DXioamh84p0PChQc1JNrl1Mp987WNI024t »					

//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« klSVh7z35aw9E4LNoYItF51POTZO7L77I8cP7H383N7E28Kc43Tm30qVloFw8cEq »					

//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« JpqmWj27191S6p1k97Z0kYa5erf80KWF64fUs4JC5l40WrV58Rst4jgO5RxolBrr »					

//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« l81Z9EdfA51ZYMFnyhWl8vbT010KMWJN6d7xMCb68u0Xw7DQwWuv0J446T4wSCYY »					

//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« UvSGcUdCJ98I7407DOBbYaOtMiD2tk8M02TaN4Q49iE8qXD7w4xJg3GsoPs5n8dg »					

//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« Pwl3LgLu91i4dqVeL2Y7XQ0111JaU6ZP78aib2l5dD41i9v6oqekX491facznD29 »					

//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« Ds5kyNBYeQ9vi0tRKv6FXqQPz1XT7t2UYQ6BImd0sD28Xts7Z4wKPOMFmtv490dt »					

//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« 89Iwa9h8pt7Uk2bWU94IY49h12OuzC351gfMuAd0WZbtWM8fQ8BGF2mtE5Zk4zVN »					

//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« 2dGNceh3S71iOW2qdleuf6jyzZ1rvycQX5auvVUd4qNvQ3eZ0Q7ArEI4202zv9Z0 »					

//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« HRQ00B646zni5R2u6i2w6Kjf98HStJ8WX95643Qwx3hl1W02Z7MY9811UovH6bCq »					

//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« me3pK6YW9wsAlv6nVMo9Iwm6DjNvYtX3KNsmQ0HTvIp5O3mHms01726j66asg5K8 »					

//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« 0ioRMj7Qgp0u2cW1ORMC2gdgU73mS618Q6dtb46fWzUV7pYL4PA9yYQ7lt7QJEma »					

//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« nf1eC3v75171GYR1pd7uQhm3EU9t0mQDjymc7fSOoV62d14K7oydMdrwQKeHqnUN »					

//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« TAd051kS46939AlpBx34VRyT26SVw31JK26JVHy0RzXI7u6f8yMD1CKg9TWd65KU »					

//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« r4ALns0SzF88WooJL8aCkUoT621u21d7fZof7U83jmsB5ec2Ru4wMDJR39r5M695 »					

//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« 7HuMM7KBF1TlfPBLDFF18G6f323nA72BK8T6x43B4x4rN8usFN9kM84I5oGola7n »					

//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« j9p8gMR2Q0a52mXluWWmEf8V41UFKdPAil1T8YShfe620ZZIwJ81S2o1HfzDr53u »					

//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« SPGLBly7b4i25K8a7V4hkG92p037vSjT95uWUVvHs1463G018Cj5C85oXjOrP23z »					

//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« 908OQ1k1H96S03Y2V71PG3dTLZKUx247p257NiOnylPGu84jh8bGeGTd8N48xTJ0 »					

//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« f3SvF35ebC4sjGoo1EH110FIb7w14z8q43qoOz802Y28p09bydHb3jp1aZkHbvlK »					

//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« Cca59DJi7I21lq0d7OUosax6O0Vqfiok5nqY963z3tt859mv1aT4JIH2py5ke3um »					

//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« zs2bg7Eyz0c8tssoTi5aFUwoVBEQ9hy2b9VD75C17fNK8p094vLz5hwME0jtiMw8 »					

//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« txyyJrP9eV7CapLxoAYf0CZijgyw7CGfrBwcs6VZCZd7x23j2W1n2gn094izdLXd »					

//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« PWnpsW43d3q0AN0p56dvsue0ZQZaKNxaoNcCyHG5rD9o5vAkM6D0VsjMRazrS1qD »					

//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« Rloe13LzJ9B1507gs3B7NZazD3jvaj4gE1Ss5H4xJKBDEW3296ph8X8e09a1z6Ze »					

//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« JH1vBQH93EuzX1wC3NOXUv7P99zt2o32uL98Qh1VQ252PeHqX1G18gpqT0Ibvg13 »					

//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« 28OLJA8nn9iaVp6KgW83zB6KA60TW0m25K1o0FlKkHdk384FrzH6Tq1X68c1BYDr »					

//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« FEp8zUC8S0cBTHE2PR0eQ9I68d8HxF8NFH6ory5ER4583n7Yu7bo51J5Bl7N8cjK »					

//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« 3Yfj93P0tOi1WP4aKyT03wll9F1Pb788aO34jaAnjxcOM845fs05o3hT5Vz5K4IJ »					

//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« asliZCc0m7RZ0zZV3qc76hMY10mkhdnI697SZe16Ohep1xSGer6iZK6XBqfTI9lJ »					

//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« d2j04bUrRs3Kw1qyKsCl0oCWXa8ulw1MPmVY3Byw2wuG27eTR11h4D8rjx9Skuq1 »					

//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« JIHIEZUdALOOJd6p2BLIkosm7ZwfU1amr1i4x5se3fTm0L4331t9cwe6q9GmFKl7 »					

//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« kWgxMuUJyA1F1G9aUaZ979t4d0bTt427D32ww1E2G41w9CtjVWbz46ba4B1609Lx »					

//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« 9BiggqldLHXtwbIiT1930445d63u7ri2TIOf4Y581HO0a5Gze9i0EaKXatCCbmBD »					

//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« vrw4qq419aLxDGDIP949Rf07R5Q7k3l53yq7XUrBIZciZ3ja8p5U8k7aB719NX4y »					

//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« GCbdU9CWQlb7R4p4Ebs28VqU52pls8n3Jv3SFbK85JGR30ZNZAfGhDeG6fKSLQ56 »					

//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« xN4pzUG744m5FsO8hD5q2q85YnSMahUCIDyB6Sb1mJPanm7B9X45Ljnk26850nTq »					

//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« 6xAA1CrrId547ny47i4Q8f5Jgys8397yMZB8UA1mB9785m8iSDQIrwR7z5fu25H6 »					

//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« 816bYx7arg7BCIODf1xdEI042Wl11Y9tM3NQ00O4d6VxR4o79v8bdixT503JNoh5 »					

//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« 3SZ97KbOD806M8yPyjqc29qY5X8tXil6gpgWm5Fe3CYT3ZVuTv5Xu1MnHw4GR8ed »					

//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« m5xmWqJC201826fJIUw56e9hDNkHxubOk272BbaDG0xFP2bD602R1enW214iP66V »					

//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« Gm7AaH5C3w1z9Aw28k4Qji90P44mzFo0GT5o742G3330LLeUOxPL2EZ2nHgoGY5f »					

//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« qbKiKUKc9vFrz6s4fDyH0M09zcsjg6jwb10uVwvUWfI9a8rBq1I8812Nrpfcwnfy »					

//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« 0l3Cbpt8hE820rQ7C47k4CDzz754wHqiUCag9OidvefYOndFvCA29L2t2qGDMb30 »					

//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« t7dV8ttzh6x0PzSA34MfTOrzZH9YQ2xpk5EplhFgv77mCBgM8T5p1Gwla7ZvAie5 »					

//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« nY01f5iTwWFHL2EhfeR5eD422khu591rybU6P70wU79EVBSs6nXi9xX4Fj9n82E9 »					

//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« l0mb27n0k5Sxz4lU6Elqwx33G4iBzJ4shfnPBbLOCR8l3bHH7W1VfbR13k809GBL »					

//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« 6rer3u8OIiBO0y7mE6z43ZQGBQ2O2Iv1L5mvwT1X4FTwWRZokl3yqAucC2q3Y3OF »					

//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« SHhNGu0Hb8NSQWe6Ksai2OY9rc0jahlUpyCvN72sjNpgu2QkLJ36O818YDbNQHDP »					

//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« eXT7c6G7y1Wxg1tjRDm1642NaM1iKCGR0lH9Dt510b43XJJM83zy96P6m1M3687h »					

//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« sYqIOb79m5efj564H21485P6o0Qx8bRI5EZ9O5RBO3rVq7893u4mvvi2To5gBiXU »					

//	76											

//	77											

//	78											

												

												

												

												

//	1	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.1 »					« S3YSj054APpue12FXyQ34DjFxQ3l7oNv8nc3bSgFmMsGRV2EYAD5vq9J85xEf6wV »					

//	2	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.2 »					« U2Nl9ERy7p9vm6yYO63EAR99ApZ770KYbKE8hzFy7JL3Q5K1cZ2I557p3H0Z5rJP »					

//	3	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.3 »					« pUPbd5F37F1iSZ5Ktx9T39rrj6z6x83Kf66LKxeX905SZpE28BKI0hrH1ic7090y »					

//	4	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.4 »					« Lbb3n2O87q4jRgA2VC8HMm5G1Btz2z1VfquC0071f8ypRo1OhK2sa51H0M1bzVH9 »					

//	5	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.5 »					« 88138VVXr7wJkXduzyEtRX8C3B7UQwEi9qdwg50187GoTex0M7N33XCYL9YRkjW8 »					

//	6	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.6 »					« 2LK1Fvh93tU6Hvj9TgGSM1z61wcCB8dJ0X3sVC2os2l8056T6RcZ0E1nqS735Tgl »					

//	7	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.7 »					« 245xSNHI9aK4nUsK9mWX9rUwew853O0L8QJLx4IYrSdQnzrHQMeI8Yk81tDsSr7h »					

//	8	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.8 »					« q3eCvPgIyWp3qqcT1u76Xe92q06MO9OjdBLfY9Pt6hF03CiOs2I2255R5MHkwVob »					

//	9	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.9 »					« IEJxy3qrh6q9q53A6W6HkC9Kyj6q8291oB3kfDwif306SB47GTgDz7wO6EbE6EA2 »					

//	10	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.10 »					« s9G9X7mIWs1074iSDPIayX1QW7BWFf3h85CoE7y9E6Bbe8gO41Psm9WZa635fe9c »					

//	11	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.11 »					« vJ3038at4vt7RlvMGHS5eP8z0FOFSfciZ39aoiVxuZaZU5k7U34UNfBj2uxd996L »					

//	12	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.12 »					« 2TB8ItMV4oxG5R478vwk1g40F5z13TylOx2o2O2OH7a33mcJ0PVGqkXEF7oKoS19 »					

//	13	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.13 »					« wU5Lshj8aDYIOjTUOe7BZRRS79yhKGX7l9L7325K338m5pEpgOs15a408w308en1 »					

//	14	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.14 »					« 7g33Ffe3pAmcnpRC43XB10p5I8k7LiVnmKpkWHY9iNReDZ8oIgQ31j28xz3MQqO7 »					

//	15	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.15 »					« aWpgnspW2fH4SHa5P09i7arq27Lg0qxg6E7m4IGrv8Z44j648Q0q9w4uiou6Rl37 »					

//	16	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.16 »					« ME3tC957UiY67t041zZS0G2lx9fT6bjsi36UeHP53050Aa43Ij7ngjh71MO2b9MT »					

//	17	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.17 »					« T74q5kSHUbS8RI02K0267488N0ZxOy0H3r3R16tHGRXSqFQDUW619Nfi9CoLBcxt »					

//	18	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.18 »					« yo2L704951UprVx1k3Vl4GSR8UQvCI4Lba0S64Wg7a9B71pzTnyYcACgVwef83r9 »					

//	19	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.19 »					« 7j4yVud9HRf77DAb698v81wiqhGFYtgxQv7xbiUz4Ah3lJ1lUg97f2fRJ2Py4477 »					

//	20	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.20 »					« es42K8Ku2n1J787Ewx5Ws3cMjI0R9r8oT8s2111gUOqRT8rwbvfcA5671DKsqf8U »					

//	21	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.21 »					« M26r30ZZNDC9fY57t84XWIxV22MJwHf3Gb7MLwl14163D3jr1jy4060u1yW6BUC3 »					

//	22	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.22 »					« 1o927k87FTMVy53dK8fGDl6fj5gUa02MQK8d0y0152l19kmz9u8g75bR6cF57BZ8 »					

//	23	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.23 »					« Qk0733yOf1g7ojeha6si2mZY2Nm58Ay5N1cDGC8ePaA4dMH0eUjNxP8Se3DiJ29N »					

//	24	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.24 »					« 5eE0jQx0jl79gKJVbx2kKHed9woz8G2wke7mmXq1TiwT4kUhi3saG63d86Pr3760 »					

//	25	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.25 »					« L815A2700YJp71IJBZo2S5wCo9jI7JDVnnP3qfGQEbmw8IIEcn3NqnNb54A644Vm »					

//	26	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.26 »					« 9So50OAYn5Jbo00kjY9QB4QUqD18LvFcZ5jQ10jiswbqZ9DMkgqpQGEZoJ32R53z »					

//	27	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.27 »					« Hma1qyxcqq9sncciPDh9Lbnq1kW1ywLM14Q8BaJ5aIxZs8ePrR1r15SA0Je6p8yb »					

//	28	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.28 »					« ndv9d07T2n820q1D4m599HnxVO3I9zLs2c29rGX8789D1SFsx1v4655cZBiugG05 »					

//	29	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.29 »					« 18fke025Y9c1UpItGk3ZfFBStro46XjJ939OwPUhKjj6EAl9wWtQ5c0l10qN8loT »					

//	30	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.30 »					« Q0bobt130m6hgYTOJ29BJIdHQu6KdPmBUK9693oHlZFRq7EO4Fu9xKt28c4rK09g »					

//	31	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.31 »					« h03IYlW70r6GdsjpYkmugu64AwcF9CbO37Cg27H0gCDy56h4TKL8S00so01K0kxM »					

//	32	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.32 »					« gk7dH5SpiOs4T9X744R0ltaPI39LO3Q7Enfd47tCfBPekgjAilHsGo3HNAl9X22R »					

//	33	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.33 »					« cDkK8ih09KT6oW9Hh4K3ES1pmiSz8rjJ0sTd1fsQ4d2aEoH7ie50I44Cxv64a1NF »					

//	34	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.34 »					« l4O6Uo79zH777Yx4j30TeQ6by67r0l7wKPx42B390a62ZzpZ6AuhEKSOM1qHU0v5 »					

//	35	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.35 »					« ZLghX6q1W4pS5A3KGU2IemCJDOO2txRnkh60aE8B5pf0O2pJ56TGA5GOF8V2T49b »					

//	36	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.36 »					« h9S2h4N0E23CND53v7Cb4pSi8C4xtdTJ9SoXkONhulNuAA5E7inM4iFjSYAbjwT7 »					

//	37	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.37 »					« Pzpg80aCzS46Rw7tSk4xo2OKI5P3177839r78Xvv9m96044h09855fIj8dMBG3Yb »					

//	38	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.38 »					« 1iRUc3y63wI7u0dh04G9e2AtBzPY4gTp8Q5VV11SRWeDbZSOkMU7D0b6Lhp26X51 »					

//	39	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.39 »					« 048WnN0B0xue07yGXKPoW9WF5nTS24trKJNT3GlxAy7fj78p4ep8qTWIFCym101Z »					

//	40	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.40 »					« u2G1me9nHSYe972BOB52gs6FD7Slvn1u2Dq3iCcW02FkOqYsaWw3vWV47BrF9ENJ »					

//	41	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.41 »					« 7DvHlZy5eX2Nt92448WPG1LWH2ob5H8UKXFp9erql5Eb5lZB597k58T932XraY9W »					

//	42	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.42 »					« 62Z6KmVt11T3lYI17LCamLcb45zRR3uiq8RVVoBMbv77FDBU0O3pm8MPLc24PJ5W »					

//	43	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.43 »					« jD9OW48GS0adrg6N3cvY5kq7A16RcxAd3Rkx1tVaX88iAE0v5eArPoB20Xks8gFW »					

//	44	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.44 »					« fWwkjT45Gii8TQR6Juvm3Ic4Hl6I1i8CyoRi3N3H33p7bI4itTLazKDO92tE67kM »					

//	45	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.45 »					« 0HvxV341udt7bC5K4M6c3K5Fk74yqxLXj3638F4C7fWZjdE0aP2S0W8ft6cemJ1k »					

//	46	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.46 »					« o9g2y7sy81063NF9pP3lr5ebRYqr8f9uQ9Ehj9N42L8m8BWitE3t8A4kxr592tCh »					

//	47	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.47 »					« 1A0AB5TOMwIXdJkOZ31mav6taViCul5jjSOd3S59w7sPl4DkYhZZN5KB28EZep7c »					

//	48	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.48 »					« 76hgvWQWDd900iA5n5g4vA2xDx830G0NV3GB6UcaV27n1517diWlyRRZ4Z30Bsi0 »					

//	49	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.49 »					« ABH79nttr0t01J9hGYD4YG38z6vIfk97rR9ra1C9FuFcrs25B374W0Xs2OLVNVFi »					

//	50	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.50 »					« vjO5iEPb2Ksoij6h02g6oYk8JDGIA9lQA5vkpcsHvI89mslo3Li1513rKAn297O6 »					

//	51	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.51 »					« L2JNwpXXjIg2yHXT9523f5T6jKeFqFlvZtSA73j41hUOJT5SmWhgiotCxM9U4eXa »					

//	52	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.52 »					« jc6Mv2z5o7266kA2TIj52zt4G1kQKmO7X8enJ96A389978Eci52YzVgYU39S0723 »					

//	53	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.53 »					« 97xD74OaCCCBi557rHg0o91pT4YIO7jZnyJhtk1WtY8f4q5O5WUSqgDq0IH3rcA7 »					

//	54	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.54 »					« UQ31kbkm1N084P1A21xW6WHoM23U6QjF1G647rue87tJKRn0N8AEb8KypOkJln0P »					

//	55	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.55 »					« P2TA7RWx2NiYYAhxNsdkcB038v0Hc9B2273dgGW219y9g8JT7AWTG15u4K2Lc2ui »					

//	56	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.56 »					« pRx959KtJ3cKr8uqS1Z7xdZs8JzU6PKlkw5IH5424u6qSbdAF133hfIVM3jcy4w0 »					

//	57	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.57 »					« WmzHw1EB0u16ql6OVdZ5gqb61MkE5yd5I5m5HdI533unBDddh04kD50O7mV5hntl »					

//	58	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.58 »					« 4Os9tq9Ew0Mj922932cvsobYoJuRmyPB3a4E5ixVcZV0abx8BbAWIQDq2D02qyRC »					

//	59	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.59 »					« GP4qoz311hDO5186TGoHEc73sg67Gjms3D2iKDnto9RUBx77Y0J6197BaLdl6bNx »					

//	60	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.60 »					« 2mP11WvT09VpS0BqwpxfwlwBQK9P6ZuFsvF1EYzTU9r2jGM5TBQ4Dk016xySmC10 »					

//	61	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.61 »					« cG5600oFQT2tff1ZsLA5MN23Zk8497RGo2t6cnsjIRgF7R11Ft15a6f8UCfH18a8 »					

//	62	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.62 »					« e4E3s76HF6BxT8xOSF5wdZ3GtFz12Uw23TgyOwEBECV0ThR0DXsAUQ222KMLASxH »					

//	63	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.63 »					« S647aY50uosmURPDOsXW7aNgSB6y19OHG55fyBnqCjgF3OBBIFH3oW3E379kFd90 »					

//	64	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.64 »					« nj6qhftwY22j1c376MJRx80w3ArtZhFk5IV3tI7M0UxSH4rpl5qf1uf93qNQj96v »					

//	65	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.65 »					« SIACD7967Wjp7T7FXy1Vq1zzyALbY9L5LThnvzviyrYGjg7sUr1W6xph64086qmu »					

//	66	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.66 »					« vrSrQgVUW60cA7FbOe9o352JH380305xDwVu1D060jW9XP7Ax7tT4c2QZORX4A1u »					

//	67	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.67 »					« Wl0TrmD17k0An27de544EO5zNzS5Kdhs76dBU5XPnk7yg7NA180wP1GL764R0fUG »					

//	68	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.68 »					« pKW4d8pc7sFkDjsrvWiE5io53WMQ0f2mrf7M21d5ztb7847U39AGp22oHw4dah9p »					

//	69	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.69 »					« VHzV72d3sokUaB6c5bz938UgY398H6KuVmw18jf0N3EiorLtoCQtFz8e8QL9kt8m »					

//	70	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.70 »					« 6bRaOW76L7ZlqXb1E7CuI4lKW7ktk7R9OYy05VdFHvaiiejGs48COIejTercI85M »					

//	71	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.71 »					« gMpADPJ4x7Ph9vY4UU7I6PrExhuWmG64fy3KX3LrI95CN463Uj6E1kZQ4KXtG5m0 »					

//	72	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.72 »					« Dx1X07G7A2786GdoAX8rBxHHPUds1K3OVv250rmy66oW0J9Oa85C748e7i50oUfd »					

//	73	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.73 »					« aRnQR2UAgUqnYK2xY13l0Gy5A6NBm0oEPDARqwlwPkZw45x2cqdBGvrMG55ND4oN »					

//	74	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.74 »					« xc723zXeynnG4UP0GK7AdhmMYOKpTjg87GKHrx3p2O6825czL1pp8BhC3E1700WS »					

//	75	« Adresse / Pool ID de 100 Utilisateurs / 400 Utilisateurs.75 »					« efwXSIG0x840oUK6aJoPssJJcj8G8xQgmjDLS4mr22C05a8OzPDqN6ERYnX0E7zk »					

//	76											

//	77											

//	78											

												

												

		}