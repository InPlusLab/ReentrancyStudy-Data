/**

 *Submitted for verification at Etherscan.io on 2018-08-21

*/



pragma solidity ^0.4.11;



/// @title DNNToken contract - Main DNN contract

/// @author Dondrey Taylor - <[email protected]>

contract DNNToken {

    enum DNNSupplyAllocations {

        EarlyBackerSupplyAllocation,

        PRETDESupplyAllocation,

        TDESupplyAllocation,

        BountySupplyAllocation,

        WriterAccountSupplyAllocation,

        AdvisorySupplyAllocation,

        PlatformSupplyAllocation

    }

    function issueTokens(address, uint256, DNNSupplyAllocations) public returns (bool) {}

}



/// @title DNNRedemption contract - Issues DNN tokens

/// @author Dondrey Taylor - <[email protected]>

contract DNNRedemption {



    /////////////////////////

    // DNN Token Contract  //

    /////////////////////////

    DNNToken public dnnToken;



    //////////////////////////////////////////

    // Addresses of the co-founders of DNN. //

    //////////////////////////////////////////

    address public cofounderA;

    address public cofounderB;



    /////////////////////////////////////////////////

    // Number of tokens distributed (in atto-DNN) //

    /////////////////////////////////////////////////

    uint256 public tokensDistributed = 0;



    //////////////////////////////////////////////////////////////////

    // Maximum number of tokens for this distribution (in atto-DNN) //

    //////////////////////////////////////////////////////////////////

    uint256 public maxTokensToDistribute = 30000000 * 1 ether;



    ///////////////////////////////////////////////

    // Used to generate number of tokens to send //

    ///////////////////////////////////////////////

    uint256 public seed = 8633926795440059073718754917553891166080514579013872221976080033791214;



    /////////////////////////////////////////////////

    // We'll keep track of who we have sent DNN to //

    /////////////////////////////////////////////////

    mapping(address => uint256) holders;



    /////////////////////////////////////////////////////////////////////////////

    // Event triggered when tokens are transferred from one address to another //

    /////////////////////////////////////////////////////////////////////////////

    event Redemption(address indexed to, uint256 value);





    ////////////////////////////////////////////////////

    // Checks if CoFounders are performing the action //

    ////////////////////////////////////////////////////

    modifier onlyCofounders() {

        require (msg.sender == cofounderA || msg.sender == cofounderB);

        _;

    }



    ///////////////////////////////////////////////////////////////

    // @des DNN Holder Check                                     //

    // @param Checks if we sent DNN to the benfeficiary before   //

    ///////////////////////////////////////////////////////////////

    function hasDNN(address beneficiary) public view returns (bool) {

        return holders[beneficiary] > 0;

    }



    ///////////////////////////////////////////////////

    // Make sure that user did no redeeem DNN before //

    ///////////////////////////////////////////////////

    modifier doesNotHaveDNN(address beneficiary) {

        require(hasDNN(beneficiary) == false);

        _;

    }



    //////////////////////////////////////////////////////////

    //  @des Updates max token distribution amount          //

    //  @param New amount of tokens that can be distributed //

    //////////////////////////////////////////////////////////

    function updateMaxTokensToDistribute(uint256 maxTokens)

      public

      onlyCofounders

    {

        maxTokensToDistribute = maxTokens;

    }



    ///////////////////////////////////////////////////////////////

    // @des Issues bounty tokens                                 //

    // @param beneficiary Address the tokens will be issued to.  //

    ///////////////////////////////////////////////////////////////

    function issueTokens(address beneficiary)

        public

        doesNotHaveDNN(beneficiary)

        returns (uint256)

    {

        // Number of tokens that we'll send

        uint256 tokenCount = (uint(keccak256(abi.encodePacked(blockhash(block.number-1), seed ))) % 1000);



        // If the amount is over 200 then we'll cap the tokens we'll

        // give to 200 to prevent giving too many. Since the highest amount

        // of tokens earned in the bounty was 99 DNN, we'll be issuing a bonus to everyone

        // for the long wait.

        if (tokenCount > 200) {

            tokenCount = 200;

        }



        // Change atto-DNN to DNN

        tokenCount = tokenCount * 1 ether;



        // If we have reached our max tokens then we'll bail out of the transaction

        if (tokensDistributed+tokenCount > maxTokensToDistribute) {

            revert();

        }



        // Update holder balance

        holders[beneficiary] = tokenCount;



        // Update total amount of tokens distributed (in atto-DNN)

        tokensDistributed = tokensDistributed + tokenCount;



        // Allocation type will be Platform

        DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.PlatformSupplyAllocation;



        // Attempt to issue tokens

        if (!dnnToken.issueTokens(beneficiary, tokenCount, allocationType)) {

            revert();

        }



        // Emit redemption event

        Redemption(beneficiary, tokenCount);



        return tokenCount;

    }



    ///////////////////////////////

    // @des Contract constructor //

    ///////////////////////////////

    constructor() public

    {

        // Set token address

        dnnToken = DNNToken(0x9d9832d1beb29cc949d75d61415fd00279f84dc2);



        // Set cofounder addresses

        cofounderA = 0x3Cf26a9FE33C219dB87c2e50572e50803eFb2981;

        cofounderB = 0x9FFE2aD5D76954C7C25be0cEE30795279c4Cab9f;

    }



    ////////////////////////////////////////////////////////

    // @des ONLY SEND 0 ETH TRANSACTIONS TO THIS CONTRACT //

    ////////////////////////////////////////////////////////

    function () public payable {

        if (!hasDNN(msg.sender)) issueTokens(msg.sender);

        else revert();

    }

}