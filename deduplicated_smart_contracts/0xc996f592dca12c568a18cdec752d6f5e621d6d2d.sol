/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

// File: contracts/EIP20Interface.sol

pragma solidity ^0.5.0;

// Copyright 2018 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
// Common: Standard EIP20 Interface
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Based on the 'final' EIP20 token standard as specified at:
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------

/**
 * @title EIP20Interface.
 *
 * @notice Provides EIP20 token interface.
 */
contract EIP20Interface {

    /* Events */

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );


    /* Public functions */

    /**
     * @notice Public function to get the name of the token.
     *
     * @return tokenName_ Name of the token.
     */
    function name() public view returns (string memory tokenName_);

    /**
     * @notice Public function to get the symbol of the token.
     *
     * @return tokenSymbol_ Symbol of the token.
     */
    function symbol() public view returns (string memory tokenSymbol_);

    /**
     * @notice Public function to get the decimals of the token.
     *
     * @return tokenDecimals Decimals of the token.
     */
    function decimals() public view returns (uint8 tokenDecimals_);

    /**
     * @notice Public function to get the total supply of the tokens.
     *
     * @return totalTokenSupply_ Total token supply.
     */
    function totalSupply()
        public
        view
        returns (uint256 totalTokenSupply_);

    /**
     * @notice Get the balance of an account.
     *
     * @param _owner Address of the owner account.
     *
     * @return balance_ Account balance of the owner account.
     */
    function balanceOf(address _owner) public view returns (uint256 balance_);

    /**
     * @notice Public function to get the allowance.
     *
     * @param _owner Address of the owner account.
     * @param _spender Address of the spender account.
     *
     * @return allowance_ Remaining allowance for the spender to spend from
     *                    owner's account.
     */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256 allowance_);


    /**
     * @notice Public function to transfer the token.
     *
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens to be transferred.
     *
     * @return success_ `true` for a successful transfer, `false` otherwise.
     */
    function transfer(
        address _to,
        uint256 _value
    )
        public
        returns (bool success_);

    /**
     * @notice Public function transferFrom.
     *
     * @param _from Address from which tokens are transferred.
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens transferred.
     *
     * @return success_ `true` for a successful transfer, `false` otherwise.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success_);

    /**
     * @notice Public function to approve an account for transfer.
     *
     * @param _spender Address authorized to spend from the function caller's
     *                 address.
     * @param _value Amount up to which spender is authorized to spend.
     *
     * @return bool `true` for a successful approval, `false` otherwise.
     */
    function approve(
        address _spender,
        uint256 _value
    )
        public
        returns (bool success_);

}

// File: contracts/GatewayInterface.sol

pragma solidity ^0.5.0;

// Copyright 2018 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/**
 * @title GatewayInterface Contract
 *
 * @notice Provides interface for gateway contract.
 */
interface GatewayInterface {

    /* External functions */

    /**
     * @notice Returns bounty amount.
     *
     * @return Amount of ERC20 which needs to be staked by facilitator.
     */
    function bounty()
        external
        returns (uint256);

    /**
     * @notice Initiates the stake process.  In order to stake the staker
     *         needs to approve Gateway contract for stake amount.
     *         Staked amount is transferred from staker address to
     *         Gateway contract. Bounty amount is also transferred from staker.
     *
     * @param _amount Stake amount that will be transferred from the staker
     *                account.
     * @param _beneficiary The address in the auxiliary chain where the utility
     *                     tokens will be minted.
     * @param _gasPrice Gas price that staker is ready to pay to get the stake
     *                  and mint process done.
     * @param _gasLimit Gas limit that staker is ready to pay.
     * @param _nonce Nonce of the staker address.
     * @param _hashLock Hash Lock provided by the facilitator.
     *
     * @return messageHash_ Message hash is unique for each request.
     */
    function stake(
        uint256 _amount,
        address _beneficiary,
        uint256 _gasPrice,
        uint256 _gasLimit,
        uint256 _nonce,
        bytes32 _hashLock
    )
        external
        returns (bytes32 messageHash_);

    /**
     * @notice Revert stake process and get the stake
     *         amount back. Only staker can revert stake by providing
     *         penalty i.e. 1.5 times of bounty amount. On progress revert stake
     *         penalty and facilitator bounty will be burned.
     *
     * @dev To revert the the sender must sign the sha3(messageHash, nonce+1)
     *
     * @param _messageHash Message hash.
     *
     * @return staker_ Staker address
     * @return stakerNonce_ Staker nonce
     * @return amount_ Stake amount
     */
    function revertStake(
        bytes32 _messageHash
    )
        external
        returns
    (
        address staker_,
        uint256 stakerNonce_,
        uint256 amount_
    );
}

// File: contracts/SafeMath.sol

pragma solidity ^0.5.0;


// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
// Common: SafeMath Library Implementation
//
// http://www.simpletoken.org/
//
// Based on the SafeMath library by the OpenZeppelin team.
// Copyright (c) 2016 Smart Contract Solutions, Inc.
// https://github.com/OpenZeppelin/zeppelin-solidity
// The MIT License.
// ----------------------------------------------------------------------------


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error.
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero,
        // but the benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts
     *      on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0.
        require(b > 0);
        uint256 c = a / b;

        // There is no case in which this doesn't hold
        // assert(a == b * c + a % b);

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is
     *      greater than minuend).
     *
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder,
     *      (unsigned integer modulo) reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/EIP20Token.sol

pragma solidity ^0.5.0;

// Copyright 2018 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.




/**
 *  @title EIP20Token contract which implements EIP20Interface.
 *
 *  @notice Implements EIP20 token.
 */
contract EIP20Token is EIP20Interface {

    using SafeMath for uint256;


    /* Storage */

    string internal tokenName;
    string internal tokenSymbol;
    uint8  private tokenDecimals;
    uint256 internal totalTokenSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    /* Special functions */

    /**
     *  @notice Contract constructor.
     *
     *  @param _symbol Symbol of the token.
     *  @param _name Name of the token.
     *  @param _decimals Decimal places of the token.
     */
    constructor(
        string memory _symbol,
        string memory _name,
        uint8 _decimals
    )
        public
    {
        tokenSymbol = _symbol;
        tokenName = _name;
        tokenDecimals = _decimals;
        totalTokenSupply = 0;
    }


    /* Public functions */

    /**
     *  @notice Public view function name.
     *
     *  @return Name of the token.
     */
    function name() public view returns (string memory) {
        return tokenName;
    }

    /**
     *  @notice Public view function symbol.
     *
     *  @return Symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return tokenSymbol;
    }

    /**
     *  @notice Public view function decimals.
     *
     *  @return Decimal places of the token.
     */
    function decimals() public view returns (uint8) {
        return tokenDecimals;
    }

    /**
     *  @notice Public view function balanceOf.
     *
     *  @param _owner Address of the owner account.
     *
     *  @return Account balance of the owner account.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
     *  @notice Public view function totalSupply.
     *
     *  @dev Get totalTokenSupply as view so that child cannot edit.
     *
     *  @return Total token supply.
     */
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalTokenSupply;
    }

    /**
     *  @notice Public view function allowance.
     *
     *  @param _owner Address of the owner account.
     *  @param _spender Address of the spender account.
     *
     *  @return Remaining allowance for the spender to spend from
     *          owner's account.
     */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
     *  @notice Public function transfer.
     *
     *  @dev Fires the transfer event, throws if, _from account does not have
     *       enough tokens to spend.
     *
     *  @param _to Address to which tokens are transferred.
     *  @param _value Amount of tokens to be transferred.
     *
     *  @return success_ True for a successful transfer, false otherwise.
     */
    function transfer(
        address _to,
        uint256 _value
    )
        public
        returns (bool success_)
    {

        // According to the EIP20 spec, "transfers of 0 values MUST be treated
        // as normal transfers and fire the Transfer event".
        // Also, should throw if not enough balance. This is taken care of by
        // SafeMath.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     *  @notice Public function transferFrom.
     *
     *  @dev Allows a contract to transfer tokens on behalf of _from address
     *       to _to address, the function caller has to be pre-authorized
     *       for multiple transfers up to the total of _value amount by
     *       the _from address.
     *
     *  @param _from Address from which tokens are transferred.
     *  @param _to Address to which tokens are transferred.
     *  @param _value Amount of tokens transferred.
     *
     *  @return success_ True for a successful transfer, false otherwise.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool success_)
    {
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    /**
     *  @notice Public function approve.
     *
     *  @dev Allows _spender address to withdraw from function caller's
     *       account, multiple times up to the _value amount, if this
     *       function is called again it overwrites the current allowance
     *       with _value.
     *
     *  @param _spender Address authorized to spend from the function caller's
     *                  address.
     *  @param _value Amount up to which spender is authorized to spend.
     *
     *  @return success_ True for a successful approval, false otherwise.
     */
    function approve(
        address _spender,
        uint256 _value
    )
        public
        returns (bool success_)
    {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }
}

// File: contracts/OrganizationInterface.sol

pragma solidity ^0.5.0;

// Copyright 2018 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------

/**
 *  @title OrganizationInterface provides methods to check if an address is
 *         currently registered as an active participant in the organization.
 */
interface OrganizationInterface {

    /**
     * @notice Checks if an address is currently registered as the organization.
     *
     * @param _organization Address to check.
     *
     * @return isOrganization_ True if the given address represents the
     *                         organization. Returns false otherwise.
     */
    function isOrganization(
        address _organization
    )
        external
        view
        returns (bool isOrganization_);

    /**
     * @notice Checks if an address is currently registered as an active worker.
     *
     * @param _worker Address to check.
     *
     * @return isWorker_ True if the given address is a registered, active
     *                   worker. Returns false otherwise.
     */
    function isWorker(address _worker) external view returns (bool isWorker_);

}

// File: contracts/Organized.sol

pragma solidity ^0.5.0;

// Copyright 2018 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ----------------------------------------------------------------------------
//
// http://www.simpletoken.org/
//
// ----------------------------------------------------------------------------


/**
 * @title Organized contract.
 *
 * @notice The Organized contract facilitates integration of
 *         organization administration keys with different contracts.
 */
contract Organized {

    /* Storage */

    /** Organization which holds all the keys needed to administer the economy. */
    OrganizationInterface public organization;


    /* Modifiers */

    modifier onlyOrganization()
    {
        require(
            organization.isOrganization(msg.sender),
            "Only the organization is allowed to call this method."
        );

        _;
    }

    modifier onlyWorker()
    {
        require(
            organization.isWorker(msg.sender),
            "Only whitelisted workers are allowed to call this method."
        );

        _;
    }


    /* Constructor */

    /**
     * @notice Sets the address of the organization contract.
     *
     * @param _organization A contract that manages worker keys.
     */
    constructor(OrganizationInterface _organization) public {
        require(
            address(_organization) != address(0),
            "Organization contract address must not be zero."
        );

        organization = _organization;
    }

}

// File: contracts/BrandedToken.sol

pragma solidity ^0.5.0;


// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.





/**
 * @title Branded Token.
 *
 * @notice Branded tokens are minted by staking specified value tokens.
 */
contract BrandedToken is Organized, EIP20Token {

    /* Usings */

    using SafeMath for uint256;


    /* Events */

    event StakeRequested(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake,
        uint256 _nonce
    );

    event StakeRequestAccepted(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake
    );

    event StakeRequestRevoked(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake
    );

    event Redeemed(
        address _redeemer,
        uint256 _valueTokens
    );

    event StakeRequestRejected(
        bytes32 indexed _stakeRequestHash,
        address _staker,
        uint256 _stake
    );

    event SymbolSet(string _symbol);

    event NameSet(string _name);


    /* Structs */

    struct StakeRequest {
        address staker;
        uint256 stake;
        uint256 nonce;
    }


    /* Storage */

    /** Address for value tokens staked to mint branded tokens. */
    EIP20Interface public valueToken;

    /** Conversion rate from value tokens to branded tokens. */
    uint256 public conversionRate;

    /** Number of digits to the right of the decimal point in conversionRate. */
    uint8 public conversionRateDecimals;

    /** Global nonce for stake requests. */
    uint256 public nonce;

    /** Flag indicating whether restrictions have been lifted for all actors. */
    bool public allRestrictionsLifted;

    /** Domain separator encoding per EIP 712. */
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(address verifyingContract)"
    );

    /** StakeRequest struct type encoding per EIP 712. */
    bytes32 private constant BT_STAKE_REQUEST_TYPEHASH = keccak256(
        "StakeRequest(address staker,uint256 stake,uint256 nonce)"
    );

    /** Domain separator per EIP 712. */
    bytes32 private DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            address(this)
        )
    );

    /** Maps staker to stakeRequestHashes. */
    mapping(address => bytes32) public stakeRequestHashes;

    /** Maps stakeRequestHash to StakeRequests. */
    mapping(bytes32 => StakeRequest) public stakeRequests;

    /** Maps actor to restriction status. */
    mapping(address => bool) private unrestricted;


    /* Modifiers */

    modifier onlyUnrestricted {
        require(
            allRestrictionsLifted || unrestricted[msg.sender],
            "Msg.sender is restricted."
        );
        _;
    }


    /* Constructor */

    /**
     * @dev Conversion parameters provide the conversion rate and its scale.
     *      For example, if 1 value token is equivalent to 3.5 branded
     *      tokens (1:3.5), _conversionRate == 35 and
     *      _conversionRateDecimals == 1.
     *
     *      Constructor requires:
     *          - valueToken address is not zero
     *          - conversionRate is not zero
     *          - conversionRateDecimals is not greater than 5
     *
     * @param _valueToken The value to which valueToken is set.
     * @param _symbol The value to which tokenSymbol, defined in EIP20Token,
     *                is set.
     * @param _name The value to which tokenName, defined in EIP20Token,
     *              is set.
     * @param _decimals The value to which tokenDecimals, defined in EIP20Token,
     *                  is set.
     * @param _conversionRate The value to which conversionRate is set.
     * @param _conversionRateDecimals The value to which
     *                                conversionRateDecimals is set.
     * @param _organization The value to which organization, defined in Organized,
     *                      is set.
     */
    constructor(
        EIP20Interface _valueToken,
        string memory _symbol,
        string memory _name,
        uint8 _decimals,
        uint256 _conversionRate,
        uint8 _conversionRateDecimals,
        OrganizationInterface _organization
    )
        EIP20Token(_symbol, _name, _decimals)
        Organized(_organization)
        public
    {
        require(
            address(_valueToken) != address(0),
            "ValueToken is zero."
        );
        require(
            _conversionRate != 0,
            "ConversionRate is zero."
        );
        require(
            _conversionRateDecimals <= 5,
            "ConversionRateDecimals is greater than 5."
        );

        valueToken = _valueToken;
        conversionRate = _conversionRate;
        conversionRateDecimals = _conversionRateDecimals;
    }


    /* External Functions */

    /**
     * @notice Transfers value tokens from msg.sender to itself,
     *         stores the amount of branded tokens to mint if request
     *         is accepted, and emits stake request information.
     *
     * @dev It is expected that this contract will have a sufficientallowance
     *      to transfer value tokens from the staker at the time this function
     *      is executed.
     *
     *      Function requires:
     *          - _mint is equivalent to _stake
     *          - msg.sender does not have a stake request hash
     *          - valueToken.transferFrom returns true
     *
     * @param _stake Amount of value tokens to stake.
     * @param _mint Amount of branded tokens to mint.
     *
     * @return stakeRequestHash_ Hash of stake request information calculated per
     *                           EIP 712.
     */
    function requestStake(
        uint256 _stake,
        uint256 _mint
    )
        external
        returns (bytes32 stakeRequestHash_)
    {
        require(
            _mint == convertToBrandedTokens(_stake),
            "Mint is not equivalent to stake."
        );
        require(
            stakeRequestHashes[msg.sender] == bytes32(0),
            "Staker has a stake request hash."
        );

        StakeRequest memory stakeRequest = StakeRequest({
            staker: msg.sender,
            stake: _stake,
            nonce: nonce
        });
        // Calculates hash per EIP 712
        stakeRequestHash_ = hash(stakeRequest);
        stakeRequestHashes[msg.sender] = stakeRequestHash_;
        stakeRequests[stakeRequestHash_] = stakeRequest;

        nonce += 1;

        emit StakeRequested(
            stakeRequestHash_,
            stakeRequest.staker,
            stakeRequest.stake,
            stakeRequest.nonce
        );

        require(
            valueToken.transferFrom(msg.sender, address(this), _stake),
            "ValueToken.transferFrom returned false."
        );
    }

    /**
     * @notice Mints and transfers branded tokens to a staker,
     *         increases the total token supply, and
     *         emits stake request acceptance and transfer information.
     *
     * @dev The function has no access controls, but will only accept
     *      the signature of a worker, as defined in Organization.
     *
     *      Function requires:
     *          - stake request exists
     *          - signature is from a worker
     *
     * @param _stakeRequestHash Stake request hash.
     * @param _r R of the signature.
     * @param _s S of the signature.
     * @param _v V of the signature.
     *
     * @return success_ True.
     */
    function acceptStakeRequest(
        bytes32 _stakeRequestHash,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    )
        external
        returns (bool success_)
    {
        require(
            stakeRequests[_stakeRequestHash].staker != address(0),
            "Stake request not found."
        );

        // To prevent a reentrancy the stake request is copied into the memory
        // and deleted from the storage.
        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];
        delete stakeRequestHashes[stakeRequest.staker];
        delete stakeRequests[_stakeRequestHash];

        require(
            verifySigner(stakeRequest, _r, _s, _v),
            "Signer is not a worker."
        );

        emit StakeRequestAccepted(
            _stakeRequestHash,
            stakeRequest.staker,
            stakeRequest.stake
        );

        uint256 mint = convertToBrandedTokens(stakeRequest.stake);
        balances[stakeRequest.staker] = balances[stakeRequest.staker]
            .add(mint);
        totalTokenSupply = totalTokenSupply.add(mint);

        // Mint branded tokens
        emit Transfer(address(0), stakeRequest.staker, mint);

        return true;
    }

    /**
     * @notice Maps addresses in _restrictionLifted to true in unrestricted.
     *
     * @dev Function requires:
     *          - msg.sender is a worker
     *
     * @param _restrictionLifted Addresses for which to lift restrictions.
     *
     * @return success_ True.
     */
    function liftRestriction(
        address[] calldata _restrictionLifted
    )
        external
        onlyWorker
        returns (bool success_)
    {
        for (uint256 i = 0; i < _restrictionLifted.length; i++) {
            unrestricted[_restrictionLifted[i]] = true;
        }

        return true;
    }

    /**
     * @notice Indicates whether an actor is unrestricted.
     *
     * @param _actor Actor.
     *
     * @return isUnrestricted_ Whether unrestricted.
     */
    function isUnrestricted(address _actor)
        external
        view
        returns (bool isUnrestricted_)
    {
        return unrestricted[_actor];
    }

    /**
     * @notice Lifts restrictions from all actors.
     *
     * @dev Function requires:
     *          - msg.sender is organization
     *
     * @return success_ True.
     */
    function liftAllRestrictions()
        external
        onlyOrganization
        returns (bool success_)
    {
        allRestrictionsLifted = true;

        return true;
    }

    /**
     * @notice Revokes stake request by deleting its information and
     *         transferring staked value tokens back to staker.
     *
     * @dev Function requires:
     *          - msg.sender is staker
     *          - valueToken.transfer returns true
     *
     * @param _stakeRequestHash Stake request hash.
     *
     * @return success_ True.
     */
    function revokeStakeRequest(
        bytes32 _stakeRequestHash
    )
        external
        returns (bool success_)
    {
        require(
            stakeRequests[_stakeRequestHash].staker == msg.sender,
            "Msg.sender is not staker."
        );

        uint256 stake = stakeRequests[_stakeRequestHash].stake;

        delete stakeRequestHashes[msg.sender];
        delete stakeRequests[_stakeRequestHash];

        emit StakeRequestRevoked(
            _stakeRequestHash,
            msg.sender,
            stake
        );

        require(
            valueToken.transfer(msg.sender, stake),
            "ValueToken.transfer returned false."
        );

        return true;
    }

    /**
     * @notice Reduces msg.sender's balance and the total supply by
     *         _brandedTokens and transfers an equivalent amount of
     *         value tokens to msg.sender.
     *
     * @dev Redemption may risk loss of branded tokens.
     *      It is possible to redeem branded tokens for 0 value tokens.
     *
     *      Function requires:
     *          - valueToken.transfer returns true
     *
     * @param _brandedTokens Amount of branded tokens to redeem.
     *
     * @return success_ True.
     */
    function redeem(
        uint256 _brandedTokens
    )
        external
        returns (bool success_)
    {
        balances[msg.sender] = balances[msg.sender].sub(_brandedTokens);
        totalTokenSupply = totalTokenSupply.sub(_brandedTokens);
        uint256 valueTokens = convertToValueTokens(_brandedTokens);

        emit Redeemed(msg.sender, valueTokens);

        // Burn redeemed branded tokens
        emit Transfer(msg.sender, address(0), _brandedTokens);

        require(
            valueToken.transfer(msg.sender, valueTokens),
            "ValueToken.transfer returned false."
        );

        return true;
    }

    /**
     * @notice Rejects stake request by deleting its information and
     *         transferring staked value tokens back to staker.
     *
     * @dev Function requires:
     *          - msg.sender is a worker
     *          - stake request exists
     *          - valueToken.transfer returns true
     *
     * @param _stakeRequestHash Stake request hash.
     *
     * @return success_ True.
     */
    function rejectStakeRequest(
        bytes32 _stakeRequestHash
    )
        external
        onlyWorker
        returns (bool success_)
    {
        require(
            stakeRequests[_stakeRequestHash].staker != address(0),
            "Stake request not found."
        );

        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];

        delete stakeRequestHashes[stakeRequest.staker];
        delete stakeRequests[_stakeRequestHash];

        emit StakeRequestRejected(
            _stakeRequestHash,
            stakeRequest.staker,
            stakeRequest.stake
        );

        require(
            valueToken.transfer(stakeRequest.staker, stakeRequest.stake),
            "ValueToken.transfer returned false."
        );

        return true;
    }

    /**
     * @notice Sets symbol.
     *
     * @dev Function requires:
     *          - msg.sender is a worker
     *
     * @param _symbol The value to which symbol is set.
     *
     * @return success_ True.
     */
    function setSymbol(
        string calldata _symbol
    )
        external
        onlyWorker
        returns (bool success_)
    {
        tokenSymbol = _symbol;

        emit SymbolSet(tokenSymbol);

        return true;
    }

    /**
     * @notice Sets name.
     *
     * @dev Function requires:
     *          - msg.sender is a worker
     *
     * @param _name The value to which name is set.
     *
     * @return success_ True.
     */
    function setName(
        string calldata _name
    )
        external
        onlyWorker
        returns (bool success_)
    {
        tokenName = _name;

        emit NameSet(tokenName);

        return true;
    }


    /* Public Functions */

    /**
     * @notice Overrides EIP20Token.transfer by additionally
     *         requiring msg.sender to be unrestricted.
     *
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens to be transferred.
     *
     * @return success_ Result from EIP20Token transfer.
     */
    function transfer(
        address _to,
        uint256 _value
    )
        public
        onlyUnrestricted
        returns (bool success_)
    {
        return super.transfer(_to, _value);
    }

    /**
     * @notice Overrides EIP20Token.transferFrom by additionally
     *         requiring msg.sender to be unrestricted.
     *
     * @param _from Address from which tokens are transferred.
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens transferred.
     *
     * @return success_ Result from EIP20Token transferFrom.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        onlyUnrestricted
        returns (bool success_)
    {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @notice Returns the amount of branded tokens equivalent to a
     *         given amount of value tokens.
     *
     * @dev Please note there may be a loss of up to 1 indivisible unit of
     *      this token (i.e., assuming 1 value token is equivalent
     *      to 3.5 branded tokens, convert(1) --> 3, not 3.5).
     *
     * @param _valueTokens Amount to convert.
     *
     * @return uint256 Converted amount.
     */
    function convertToBrandedTokens(
        uint256 _valueTokens
    )
        public
        view
        returns (uint256)
    {
        return (
            _valueTokens
            .mul(conversionRate)
            .div(10 ** uint256(conversionRateDecimals))
        );
    }

    /**
     * @notice Returns the amount of value tokens equivalent to a
     *         given amount of branded tokens.
     *
     * @dev Please note there may be a loss of up to 1 indivisible unit of
     *      this token.
     *
     * @param _brandedTokens Amount to convert.
     *
     * @return uint256 Converted amount.
     */
    function convertToValueTokens(
        uint256 _brandedTokens
    )
        public
        view
        returns (uint256)
    {
        return (
            _brandedTokens
            .mul(10 ** uint256(conversionRateDecimals))
            .div(conversionRate)
        );
    }


    /* Private Functions */

    /**
     * @notice Calculates stakeRequestHash according to EIP 712.
     *
     * @param _stakeRequest StakeRequest instance to hash.
     *
     * @return bytes32 EIP 712 hash of _stakeRequest.
     */
    function hash(
        StakeRequest memory _stakeRequest
    )
        private
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                BT_STAKE_REQUEST_TYPEHASH,
                _stakeRequest.staker,
                _stakeRequest.stake,
                _stakeRequest.nonce
            )
        );
    }

    /**
     * @notice Verifies whether signer of stakeRequestHash is a worker.
     *
     * @dev Signing the stakeRequestHash consistent with eth_signTypedData,
     *      as specified by EIP 712, requires signing a hash of encoded data
     *      comprising:
     *          - an initial byte
     *          - the version byte for structured data
     *          - the domain separator
     *          - the stakeRequestHash
     *
     *      See: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
     *
     * @param _stakeRequest Stake request.
     * @param _r R of the signature.
     * @param _s S of the signature.
     * @param _v V of the signature.
     *
     * @return bool True if signer is a worker, false if not.
     */
    function verifySigner(
        StakeRequest memory _stakeRequest,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    )
        private
        view
        returns (bool)
    {
        // See: https://github.com/ethereum/EIPs/blob/master/assets/eip-712/Example.sol
        bytes32 typedData = keccak256(
            abi.encodePacked(
                byte(0x19), // the initial 0x19 byte
                byte(0x01), // the version byte for structured data
                DOMAIN_SEPARATOR,
                hash(_stakeRequest)
            )
        );

        return organization.isWorker(ecrecover(typedData, _v, _r, _s));
    }
}

// File: contracts/GatewayComposer.sol

pragma solidity ^0.5.0;

// Copyright 2019 OpenST Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.





/**
 * @title GatewayComposer contract.
 *
 * @notice GatewayComposer is a composition contract which can be used to
 *         optimise the UX flow of the user where the user intends to perform
 *         a single combined action.
 */
contract GatewayComposer {

    /* Struct */

    struct StakeRequest {
        uint256 stakeVT;
        address gateway;
        address beneficiary;
        uint256 gasPrice;
        uint256 gasLimit;
        uint256 nonce;
    }


    /* Storage */

    address public owner;

    /** EIP20Token value token which is staked on the value chain. */
    EIP20Interface public valueToken;

    /**
     * A BrandedToken is an EIP20Token which allows a mainstream application
     * to create a value-backed token designed specifically for its
     * application's context.
     */
    BrandedToken public brandedToken;

    mapping (bytes32 => StakeRequest) public stakeRequests;

    /** Mutex lock status. */
    bool private mutexAcquired;


    /* Modifiers */

    /** Checks that msg.sender is owner address. */
    modifier onlyOwner() {
        require(
            owner == msg.sender,
            "Only owner can call the function."
        );
        _;
    }

    /**
     *  Checks that mutex is acquired or not. If mutex is not acquired,
     *  mutexAcquired is set to true. At the end of function execution,
     *  mutexAcquired is set to false.
     */
    modifier mutex() {
        require(
            !mutexAcquired,
            "Mutex is already acquired."
        );
        mutexAcquired = true;
        _;
        mutexAcquired = false;
    }


    /* Special Functions */

    /**
     * @notice Contract constructor.
     *
     * @dev Function requires:
     *          - owner address should not be zero
     *          - ValueToken address should not be zero
     *          - BrandedToken address should not be zero
     *          - ValueToken address should not be equal to owner address
     *          - BrandedToken address should not be equal to owner address
     *          - ValueToken address should be equal to BrandedToken.valueToken()
     *
     * @param _owner Address of the staker on the value chain.
     * @param _valueToken EIP20Token which is staked.
     * @param _brandedToken It's a value backed minted EIP20Token.
     */
    constructor(
        address _owner,
        EIP20Interface _valueToken,
        BrandedToken _brandedToken
    )
        public
    {
        require(
            _owner != address(0),
            "Owner address is zero."
        );
        require(
            address(_valueToken) != address(0),
            "ValueToken address is zero."
        );
        require(
            address(_brandedToken) != address(0),
            "BrandedToken address is zero."
        );
        require(
            _owner != address(_valueToken),
            "ValueToken address is same as owner address."
        );
        require(
            _owner != address(_brandedToken),
            "BrandedToken address is same as owner address."
        );
        require(
            address(_valueToken) == address(_brandedToken.valueToken()),
            "ValueToken should match BrandedToken.valueToken."
        );

        owner = _owner;
        valueToken = _valueToken;
        brandedToken = _brandedToken;
    }


    /* External Functions */

    /**
     * @notice Transfers value tokens from msg.sender to itself after staker
     *         approves GatewayComposer, approves BrandedToken for value tokens
     *         and calls BrandedToken.requestStake function.
     *
     * @dev Function requires:
     *          - stakeVT can't be 0
     *          - mintBT amount and converted stakeVT amount should be equal
     *          - gateway address can't be zero
     *          - Gateway address should not be equal to owner address
     *          - beneficiary address can't be zero
     *          - successful execution of ValueToken transfer
     *          - successful execution of ValueToken approve
     *
     *      stakeVT can't be 0 because gateway.stake also doesn't allow 0 stake
     *      amount. This condition also helps in validation of in progress
     *      stake requests. See acceptStakeRequest for details.
     *
     *      mintBT is not stored in StakeRequest struct as there was
     *      significant gas cost difference between storage vs dynamic
     *      evaluation from BrandedToken convert function.
     *
     * @param _stakeVT ValueToken amount which is staked.
     * @param _mintBT Amount of BrandedToken amount which will be minted.
     * @param _gateway Gateway contract address.
     * @param _beneficiary The address in the auxiliary chain where the utility
     *                     tokens will be minted.
     * @param _gasPrice Gas price that staker is ready to pay to get the stake
     *                  and mint process done.
     * @param _gasLimit Gas limit that staker is ready to pay.
     * @param _nonce Nonce of the staker address. It can be obtained from
     *               Gateway.getNonce() method.
     *
     * @return stakeRequestHash_ Hash unique for each stake request.
     */
    function requestStake(
        uint256 _stakeVT,
        uint256 _mintBT,
        address _gateway,
        address _beneficiary,
        uint256 _gasPrice,
        uint256 _gasLimit,
        uint256 _nonce
    )
        external
        onlyOwner
        mutex
        returns (bytes32 stakeRequestHash_)
    {
        require(
            _stakeVT > uint256(0),
            "Stake amount is zero."
        );
        require(
            _mintBT == brandedToken.convertToBrandedTokens(_stakeVT),
            "_mintBT should match converted _stakeVT."
        );
        require(
            _gateway != address(0),
            "Gateway address is zero."
        );
        require(
            owner != _gateway,
            "Gateway address is same as owner address."
        );
        require(
            _beneficiary != address(0),
            "Beneficiary address is zero."
        );
        require(
            valueToken.transferFrom(msg.sender, address(this), _stakeVT),
            "ValueToken transferFrom returned false."
        );
        require(
            valueToken.approve(address(brandedToken), _stakeVT),
            "ValueToken approve returned false."
        );

        stakeRequestHash_ = brandedToken.requestStake(_stakeVT, _mintBT);

        stakeRequests[stakeRequestHash_] = StakeRequest({
            stakeVT: _stakeVT,
            gateway: _gateway,
            beneficiary: _beneficiary,
            gasPrice: _gasPrice,
            gasLimit: _gasLimit,
            nonce: _nonce
        });
    }

    /**
     * @notice Approves Gateway for the minted BTs, calls Gateway.stake after
     *         BrandedToken.acceptStakeRequest execution is successful.
     *
     * @dev Function requires:
     *          - stake request hash is valid
     *          - successful execution of ValueToken transferFrom
     *          - successful execution of ValueToken approve
     *          - BrandedToken.acceptStakeRequest execution is successful
     *          - successful execution of BrandedToken approve
     *
     *      As per requirement bounty token currency is same as valueToken.
     *      Bounty flow:
     *          - facilitator approves GatewayComposer for base tokens as bounty
     *          - GatewayComposer approves Gateway for the bounty
     *
     * @param _stakeRequestHash Unique hash for each stake request.
     * @param _r R of the signature.
     * @param _s S of the signature.
     * @param _v V of the signature.
     * @param _hashLock Hash lock provided by the facilitator.
     *
     * @return messageHash_ Message hash unique for each stake request.
     */
    function acceptStakeRequest(
        bytes32 _stakeRequestHash,
        bytes32 _r,
        bytes32 _s,
        uint8 _v,
        bytes32 _hashLock
    )
        external
        returns (bytes32 messageHash_)
    {
        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];

        delete stakeRequests[_stakeRequestHash];

        require(
            stakeRequest.stakeVT > uint256(0),
            "Stake request not found."
        );

        uint256 bounty = GatewayInterface(stakeRequest.gateway).bounty();
        require(
            valueToken.transferFrom(msg.sender, address(this), bounty),
            "ValueToken transferFrom returned false."
        );
        require(
            valueToken.approve(stakeRequest.gateway, bounty),
            "ValueToken approve returned false."
        );

        require(
            brandedToken.acceptStakeRequest(
                _stakeRequestHash,
                _r,
                _s,
                _v
            ),
            "BrandedToken acceptStakeRequest returned false."
        );

        uint256 mintBT = brandedToken.convertToBrandedTokens(
            stakeRequest.stakeVT
        );

        require(
            brandedToken.approve(stakeRequest.gateway, mintBT),
            "BrandedToken approve returned false."
        );

        messageHash_ = GatewayInterface(stakeRequest.gateway).stake(
            mintBT,
            stakeRequest.beneficiary,
            stakeRequest.gasPrice,
            stakeRequest.gasLimit,
            stakeRequest.nonce,
            _hashLock
        );
    }

    /**
     * @notice Revokes stake request by calling BrandedToken.revokeStakeRequest()
     *         and deleting information.
     *
     * @dev Function requires:
     *          - stake request hash is valid
     *          - BrandedToken.revokeStakeRequest() should return true
     *          - ValueToken.transfer() should return true
     *
     *      The method is called after calling requestStake. In this flow
     *      locked ValueToken is transferred to owner. Transfer is done for
     *      convenience. This way extra step of calling transferToken is
     *      avoided.
     *
     * @param _stakeRequestHash Stake request hash.
     *
     * @return success_ True on successful execution.
     */
    function revokeStakeRequest(
        bytes32 _stakeRequestHash
    )
        external
        onlyOwner
        returns (bool success_)
    {
        StakeRequest memory stakeRequest = stakeRequests[_stakeRequestHash];

        delete stakeRequests[_stakeRequestHash];

        require(
            stakeRequest.stakeVT > uint256(0),
            "Stake request not found."
        );
        require(
            brandedToken.revokeStakeRequest(_stakeRequestHash),
            "BrandedToken revokeStakeRequest returned false."
        );
        require(
            valueToken.transfer(owner, stakeRequest.stakeVT),
            "ValueToken transfer returned false."
        );

        success_ = true;
    }

    /**
     * @notice Transfers EIP20 token to destination address.
     *
     * @dev Function requires:
     *          - msg.sender should be owner
     *          - EIP20 token address should not be zero
     *          - token.transfer() execution should be successful
     *
     * @param _token EIP20 token address.
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens to be transferred.
     *
     * @return success_ True on successful execution.
     */
    function transferToken(
        EIP20Interface _token,
        address _to,
        uint256 _value
    )
        external
        onlyOwner
        returns (bool success_)
    {
        require(
            address(_token) != address(0),
            "EIP20 token address is zero."
        );
        require(
            _token.transfer(_to, _value),
            "EIP20Token transfer returned false."
        );

        success_ = true;
    }

    /**
     * @notice Approves EIP20 token to spender address.
     *
     * @dev Function requires:
     *          - msg.sender should be owner
     *          - EIP20 token address should not be zero
     *          - token.approve() execution should be successful
     *
     * @param _token EIP20 token address.
     * @param _spender Address authorized to spend from the function caller's
     *                 address.
     * @param _value Amount up to which spender is authorized to spend.
     *
     * @return success_ True on successful execution.
     */
    function approveToken(
        EIP20Interface _token,
        address _spender,
        uint256 _value
    )
        external
        onlyOwner
        returns (bool success_)
    {
        require(
            address(_token) != address(0),
            "EIP20 token address is zero."
        );
        require(
            _token.approve(_spender, _value),
            "EIP20token approve returned false."
        );

        success_ = true;
    }

    /**
     * @notice Remove storage & code from blockchain.
     *
     * @dev Function requires:
     *          - ValueToken balance should be 0
     *          - BrandedToken balance should be 0
     *          - There should not be any in progress stake requests
     *
     *      BrandedToken contract has mapping stakeRequestHashes which stores
     *      staker vs stakeRequestHash data. In progress stake requests are
     *      validated by doing lookup into the stakeRequestHashes mapping.
     */
    function destroy()
        external
        onlyOwner
    {
        require(
            valueToken.balanceOf(address(this)) == 0,
            "ValueToken balance should be 0."
        );
        require(
            brandedToken.balanceOf(address(this)) == 0,
            "BrandedToken balance should be 0."
        );
        require(
            brandedToken.stakeRequestHashes(address(this)) == bytes32(0),
            "In progress stake requests are present."
        );

        selfdestruct(msg.sender);
    }

    /**
     * @notice Transfers value tokens to itself to pay the revert penalty,
     *         approves Gateway to transfer the value tokens for the penalty,
     *         and calls Gateway.revertStake.
     *
     * @dev Function requires:
     *          - msg.sender is owner
     *          - Gateway address can't be zero
     *          - Gateway address should not be equal to owner address
     *          - successful execution of ValueToken transferFrom
     *          - successful execution of ValueToken approve
     *
     *      As per requirement, penalty is paid in valueToken.
     *      Penalty flow:
     *          - staker approves GatewayComposer for value tokens as penalty
     *          - GatewayComposer approves Gateway for the penalty
     *
     * @param _gateway Gateway contract address.
     * @param _penalty Amount to pay to revert stake.
     * @param _messageHash Message hash unique for each stake request.
     *
     * @return success_ True on successful execution.
     */
    function revertStake(
        address _gateway,
        uint256 _penalty,
        bytes32 _messageHash
    )
        external
        onlyOwner
        returns (bool success_)
    {
        require(
            _gateway != address(0),
            "Gateway address is zero."
        );
        require(
            owner != _gateway,
            "Gateway address is same as owner address."
        );
        require(
            valueToken.transferFrom(msg.sender, address(this), _penalty),
            "ValueToken transferFrom returned false."
        );
        require(
            valueToken.approve(_gateway, _penalty),
            "ValueToken approve returned false."
        );

        GatewayInterface(_gateway).revertStake(_messageHash);

        return true;
    }
}