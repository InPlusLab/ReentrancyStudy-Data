/**

 *Submitted for verification at Etherscan.io on 2018-11-04

*/



pragma solidity 0.4.24;



// File: contracts/IAccounting.sol



interface IAccounting {

  function contribute(

    address contributor,

    uint128 amount,

    uint128 feeNumerator

  ) external returns(uint128 deposited, uint128 depositedFees);



  function withdrawContribution(address contributor) external returns(

    uint128 withdrawn,

    uint128 withdrawnFees

  );



  function finalize(uint128 amountDisputed) external;



  function getOwner() external view returns(address);



  function isFinalized() external view returns(bool);



  /**

   * Return value is how much REP and dispute tokens the contributor is entitled to.

   *

   * Does not change the state, as accounting is finalized at that moment.

   *

   * In case of partial fill, we round down, leaving some dust in the contract.

   */

  function calculateProceeds(address contributor) external view returns(

    uint128 rep,

    uint128 disputeTokens

  );



  /**

   * Calculate fee that will be split between contract admin and

   * account that triggered dispute transaction.

   *

   * In case of partial fill, we round down, leaving some dust in the contract.

   */

  function calculateFees() external view returns(uint128);



  function addFeesOnTop(

    uint128 amount,

    uint128 feeNumerator

  ) external pure returns(uint128);

}



// File: contracts/Accounting.sol



/**

 * Keeps track of all contributions, and calculates how much each contributor

 * is entitled to.

 *

 * Doesn't actually hold any funds, just keeps records.

 */

contract Accounting is IAccounting {

  uint128 public constant FEE_DENOMINATOR = 1000;

  address public m_owner;



  uint128[FEE_DENOMINATOR] public m_contributionPerFeeNumerator;

  mapping(address => uint128) public m_feeNumeratorPerContributor;

  mapping(address => uint128) public m_contributionPerContributor;



  // populated at finalization

  bool public m_isFinalized = false;

  uint128 public m_fundsUsed;

  uint128 public m_boundaryFeeNumerator;

  uint128 public m_fundsUsedFromBoundaryBucket;



  constructor(address owner) public {

    m_owner = owner;

  }



  modifier ownerOnly() {

    require(msg.sender == m_owner, "Not Authorized");

    _;

  }



  modifier beforeFinalizationOnly() {

    require(!m_isFinalized, "Method only allowed before finalization");

    _;

  }



  modifier afterFinalizationOnly() {

    require(m_isFinalized, "Method only allowed after finalization");

    _;

  }



  function contribute(

    address contributor,

    uint128 amount,

    uint128 feeNumerator

  ) external ownerOnly beforeFinalizationOnly returns(

    uint128 depositedLessFees,

    uint128 depositedFees

  ) {

    require(amount > 0, "Gotta have something to contribute");

    require(

      amount % FEE_DENOMINATOR == 0,

      "Amount must be divisible by fee denominator"

    );

    require(

      feeNumerator >= 0 && feeNumerator < FEE_DENOMINATOR,

      "Bad feeNumerator"

    );

    require(

      m_contributionPerContributor[contributor] == 0,

      "One has to withdraw previous contribution before making a new one"

    );



    m_contributionPerContributor[contributor] = amount;

    m_feeNumeratorPerContributor[contributor] = feeNumerator;

    m_contributionPerFeeNumerator[feeNumerator] = safeAdd(

      m_contributionPerFeeNumerator[feeNumerator],

      amount

    );



    return (amount, safeMulDivExact(amount, feeNumerator, FEE_DENOMINATOR));

  }



  function withdrawContribution(

    address contributor

  ) external ownerOnly beforeFinalizationOnly returns(

    uint128 withdrawnLessFees,

    uint128 withdrawnFees

  ) {

    uint128 amount = m_contributionPerContributor[contributor];



    m_contributionPerContributor[contributor] = 0;



    uint128 feeNumerator = m_feeNumeratorPerContributor[contributor];

    m_contributionPerFeeNumerator[feeNumerator] = safeSub(

      m_contributionPerFeeNumerator[feeNumerator],

      amount

    );



    return (amount, safeMulDivExact(amount, feeNumerator, FEE_DENOMINATOR));

  }



  /**

   * Someone may have sent us (by mistake or maliciously) extra dispute tokens.

   * This is not fatal, but we need to be aware that amountDisputed may actually

   * be greater than the REP contributed and not crash.

   */

  function finalize(

    uint128 amountDisputed

  ) external ownerOnly beforeFinalizationOnly {

    m_isFinalized = true;

    m_fundsUsed = amountDisputed;

    (m_boundaryFeeNumerator, m_fundsUsedFromBoundaryBucket) = findBoundaryBucketForAmountDisputed(

      amountDisputed

    );

  }



  function getOwner() external view returns(address) {

    return m_owner;

  }



  function isFinalized() external view returns(bool) {

    return m_isFinalized;

  }



  /**

   * Return value is how much REP and dispute tokens the contributor is entitled to.

   *

   * Does not change the state, as accounting is finalized at that moment.

   *

   * In case of partial fill, we round down, leaving some dust in the contract.

   */

  function calculateProceeds(

    address contributor

  ) external view afterFinalizationOnly returns(

    uint128 rep,

    uint128 disputeTokens

  ) {

    uint128 contributorFeeNumerator = m_feeNumeratorPerContributor[contributor];

    uint128 originalContributionOfContributor = m_contributionPerContributor[contributor];



    if (originalContributionOfContributor == 0) {

      return (0, 0);

    }



    if (contributorFeeNumerator < m_boundaryFeeNumerator) {

      // this contributor didn't make it into dispute round,

      // just refund their contribution with prepaid fees

      disputeTokens = 0;

      rep = addFeesOnTop(

        originalContributionOfContributor,

        contributorFeeNumerator

      );

    } else if (contributorFeeNumerator > m_boundaryFeeNumerator) {

      // this contributor fully got into dispute round,

      // give them dispute tokens in full, and refund unused portion of fee

      disputeTokens = originalContributionOfContributor;

      rep = safeMulDivExact(

        originalContributionOfContributor,

        safeSub(contributorFeeNumerator, m_boundaryFeeNumerator),

        FEE_DENOMINATOR

      );

    } else {

      assert(contributorFeeNumerator == m_boundaryFeeNumerator);

      // most complex case, contributor partially got into dispute rounds

      uint128 usableFundsContributedInBucket = m_contributionPerFeeNumerator[contributorFeeNumerator];

      // assertion gotta be true because contributor admittedly did some

      // contribution

      assert(usableFundsContributedInBucket > 0);

      uint128 fundsUsedInBucket = m_fundsUsedFromBoundaryBucket;

      assert(fundsUsedInBucket <= usableFundsContributedInBucket);



      // award dispute tokens pro rata

      disputeTokens = safeMulDiv(

        originalContributionOfContributor,

        fundsUsedInBucket,

        usableFundsContributedInBucket

      );

      // refund rep for the unused portion of contribution + fees

      rep = safeMulDiv(

        addFeesOnTop(

          originalContributionOfContributor,

          contributorFeeNumerator

        ),

        safeSub(usableFundsContributedInBucket, fundsUsedInBucket),

        usableFundsContributedInBucket

      );

    }

  }



  /**

   * Calculate fee that will be split between contract admin and

   * account that triggered dispute transaction.

   *

   * In case of partial fill, we round down, leaving some dust in the contract.

   */

  function calculateFees() external view afterFinalizationOnly returns(

    uint128

  ) {

    return safeMulDiv(m_fundsUsed, m_boundaryFeeNumerator, FEE_DENOMINATOR);

  }



  function addFeesOnTop(

    uint128 amount,

    uint128 feeNumerator

  ) public pure returns(uint128) {

    return safeMulDivExact(

      amount,

      safeAdd(FEE_DENOMINATOR, feeNumerator),

      FEE_DENOMINATOR

    );

  }



  /**

   * Finds such lowest fee bucket, that all buckets with fee higher than that

   * were fully included in the dispute. From that will also follow that none

   * of the funds from buckets with fee lower than that were included in the

   * dispute.

   *

   * Also calculates how much funds from the boundary bucket were included in

   * the dispute (normally current bucket participated partially).

   *

   * The returned index will always be a valid feeNumerator.

   */

  function findBoundaryBucketForAmountDisputed(

    uint128 amountDisputed

  ) internal view returns(

    uint128 feeNumerator,

    uint128 fundsUsedFromBoundaryBucket

  ) {

    // initialize with one-past-last bucket; loop will do at least one iteration

    uint128 tentativeBoundaryBucket = FEE_DENOMINATOR;

    uint128 usableFundsInCurrentBucket;

    uint128 usableFundsWithCurrentBucket = 0;

    uint128 usableFundsInBucketsWithHigherFee;



    // length of the loop constrained by constant FEE_DENOMINATOR

    assert(

      tentativeBoundaryBucket > 0 && usableFundsWithCurrentBucket <= amountDisputed

    );

    while (tentativeBoundaryBucket > 0 && usableFundsWithCurrentBucket <= amountDisputed) {

      tentativeBoundaryBucket -= 1;

      usableFundsInBucketsWithHigherFee = usableFundsWithCurrentBucket;

      // TODO: consider skipping executions if usableFundsInCurrentBucket = 0

      // Not skipping now to make it more evident that 1000 iterations of full

      // loop body (worst case) is OK gas-wise. I.e. we make sure that

      // worst-case is triggered frequently enough to not become a surprise.

      usableFundsInCurrentBucket = m_contributionPerFeeNumerator[tentativeBoundaryBucket];

      usableFundsWithCurrentBucket = safeAdd(

        usableFundsInBucketsWithHigherFee,

        usableFundsInCurrentBucket

      );

    }



    // this is needed to protect against corner cases if someone sent dispute

    // tokens into this contract directly in excess from what contributors funded

    uint128 cappedAmountDisputed = amountDisputed <= usableFundsWithCurrentBucket ? amountDisputed : usableFundsWithCurrentBucket;



    assert(cappedAmountDisputed >= usableFundsInBucketsWithHigherFee);



    feeNumerator = tentativeBoundaryBucket;

    fundsUsedFromBoundaryBucket = safeSub(

      cappedAmountDisputed,

      usableFundsInBucketsWithHigherFee

    );

    assert(fundsUsedFromBoundaryBucket <= usableFundsInCurrentBucket);

  }



  function safeAdd(uint128 a, uint128 b) internal pure returns(uint128) {

    uint128 r = a + b;

    assert(r >= a);

    return r;

  }



  function safeSub(uint128 a, uint128 b) internal pure returns(uint128) {

    assert(a >= b);

    return a - b;

  }



  function safeMulDiv(uint128 a, uint128 b, uint128 c) internal pure returns(

    uint128

  ) {

    assert(c > 0);

    uint256 wa = a;

    uint256 wb = b;

    uint256 wc = c;



    uint256 result = wa * wb / wc;

    uint128 result128 = uint128(result);



    assert(result == result128);

    return result128;

  }



  function safeMulDivExact(

    uint128 a,

    uint128 b,

    uint128 c

  ) internal pure returns(uint128) {

    assert(c > 0);

    uint256 wa = a;

    uint256 wb = b;

    uint256 wc = c;



    assert((wa * wb) % wc == 0);

    uint256 result = wa * wb / wc;

    uint128 result128 = uint128(result);



    assert(result == result128);

    return result128;

  }

}