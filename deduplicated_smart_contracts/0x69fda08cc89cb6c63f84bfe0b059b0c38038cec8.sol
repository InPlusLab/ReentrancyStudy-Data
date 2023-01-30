pragma solidity ^0.4.8;


// Metrumcoin Ltd. www.metrumcoin.com 

// &#39;interface&#39;:
//  this is expected from another contract,
//  if it wants to spend tokens (shares) of behalf of the token owner
//  in our contract
contract tokenRecipient {
    function receiveApproval(address _from, // sharehoder
    uint256 _value, // number of shares
    address _share, // - will be this contract
    bytes _extraData); //
}


contract MetrumcoinShares {

    /* Standard public variables of the token */

    // string public standard = &#39;ERC20 Token&#39;; // https://github.com/ethereum/EIPs/issues/20

    string public name = "Metrumcoin Ltd.";

    string public symbol = "Shares";

    uint8 public decimals = 0;

    uint256 public totalSupply = 50000;

    /* ------------------- Corporate Stock Ledger ---------- */
    // Shares, shareholders, balances ect.

    // list of all shareholders (represented by Ethereum accounts)
    // in this Corporation&#39;s history, # is ID
    address[] public shareholder;

    // this helps to find address by ID without loop
    mapping (address => uint256) public shareholderID;

    // list of addresses, who currently own at least one share
    address[] public activeShareholdersArray;

    // makes possible to iterate through an array from Dapp
    uint256 public activeShareholdersArrayLength;

    // balances:
    mapping (address => uint256) public balanceOf;

    // shares that have to be managed by external contract
    mapping (address => mapping (address => uint256)) public allowance;

    /* ------- Utilities:  */
    // universal events
    event Result(address transactionInitiatedBy, string message);

    event Message(string message);

    /*  --------------- Constructor --------- */
    // Initializes contract with initial supply tokens to the creator of the contract
    function MetrumcoinShares() {// - truffle compiles only no args Constructor
        balanceOf[msg.sender] = totalSupply;
        // Give the creator all initial
        // -- start corporate stock ledger
        // (push - returns the new length);
        shareholderID[this] = shareholder.push(this) - 1;
        // # 0
        shareholderID[msg.sender] = shareholder.push(msg.sender) - 1;
        // #1
        activeShareholdersArray.push(msg.sender);
        // add to active shareholders
        // update ActiveShareholdersArray (array of shareholders having at least one share)
        refreshActiveShareholdersArray();

    }

    /* --------------- Shares management ------ */

    event Transfer(address indexed from, address indexed to, uint256 value);

    function refreshActiveShareholdersArray() returns (address[]) {
        delete activeShareholdersArray;
        for (uint256 i = 0; i < shareholder.length; i++) {
            if (balanceOf[shareholder[i]] > 0) {
                activeShareholdersArray.push(shareholder[i]);
            }
        }
        activeShareholdersArrayLength = activeShareholdersArray.length;
        return activeShareholdersArray;
    }

    // constant
    function getShareholderArray() constant returns (address[]){
        return shareholder;
    }

    function getShareholderArrayLength() constant returns (uint){
        return shareholder.length;
    }

    /* ---- Transfer shares to another address ----*/
    // see: https://github.com/ethereum/EIPs/issues/20
    function transfer(address _to, uint256 _value) returns (bool success) {
        // check arguments:
        if (_value < 1) throw;
        if (this == _to) throw;
        // do not send shares to contract itself;
        if (balanceOf[msg.sender] < _value) throw;
        // Check if the sender has enough

        // make transaction
        balanceOf[msg.sender] -= _value;
        // Subtract from the sender
        balanceOf[_to] += _value;
        // Add the same to the recipient

        // if new address, add it to shareholders history (stock ledger):
        if (shareholderID[_to] == 0) {// ----------- check if works
            shareholderID[_to] = shareholder.push(_to) - 1;
        }

        // update ActiveShareholdersArray (array of shareholders having at least one share)
        refreshActiveShareholdersArray();

        // Notify anyone listening that this transfer took place
        Transfer(msg.sender, _to, _value);
        return true;

    } // end of transfer()

    /* Allow another contract to spend some shares in your behalf
    (shareholder calls this) */
    function approveAndCall(address _spender, // another contract&#39;s adress
    uint256 _value, // number of shares
    bytes _extraData) // data for another contract
    returns (bool success) {
        // msg.sender - account owner who gives allowance
        // _spender   - address of another contract
        // it writes in "allowance" that this owner allows another
        // contract (_spender) to spend this amount (_value) of shares
        // in his behalf
        allowance[msg.sender][_spender] = _value;
        // &#39;spender&#39; is another contract that implements code
        //  prescribed in &#39;shareRecipient&#39; above
        tokenRecipient spender = tokenRecipient(_spender);
        // this contract calls &#39;receiveApproval&#39; function
        // of another contract to send information about
        // allowance
        spender.receiveApproval(msg.sender, // shares owner
        _value, // number of shares
        this, // this contract&#39;s adress
        _extraData);
        // data from shares owner
        return true;
    }

    /* this function can be called from another contract, after it
    have allowance to transfer shares in behalf of shareholder  */
    function transferFrom(address _from,
    address _to,
    uint256 _value)
    returns (bool success) {

        // Check arguments:
        // should one share or more
        if (_value < 1) throw;
        // do not send shares to this contract itself;
        if (this == _to) throw;
        // Check if the sender has enough
        if (balanceOf[_from] < _value) throw;

        // Check allowance
        if (_value > allowance[_from][msg.sender]) throw;

        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;

        // Change allowances correspondingly
        allowance[_from][msg.sender] -= _value;

        // if transfer to new address -- add him to ledger
        if (shareholderID[_to] == 0) {
            shareholderID[_to] = shareholder.push(_to) - 1;
            // push function returns the new length
        }

        // update ActiveShareholdersArray (array of shareholders having at least one share)
        refreshActiveShareholdersArray();

        // Notify anyone listening that this transfer took place
        Transfer(_from, _to, _value);

        return true;
    }

    /*  --------- Voting  --------------  */
    // we only count &#39;yes&#39; votes, not voting &#39;yes&#39;
    // considered as voting &#39;no&#39; (as stated in Bylaws)

    // each proposal should contain it&#39;s text
    // index of text in this array is a proposal ID
    string[] public proposalText;

    // proposalID => (shareholder => "if already voted for this proposal")
    mapping (uint256 => mapping (address => bool)) voted;

    // proposalID => addresses voted &#39;yes&#39;
    // exact number of votes according to shares will be counted
    // after deadline
    mapping (uint256 => address[]) public votes;

    // proposalID => deadline
    mapping (uint256 => uint256) public deadline;

    // proposalID => final &#39;yes&#39; votes
    mapping (uint256 => uint256) public results;

    // proposals of every shareholder
    mapping (address => uint256[]) public proposalsByShareholder;

    // useful for Dapp, to get array using loop
    function getProposalTextArrayLength() constant returns (uint){
        return proposalText.length;
    }

    event ProposalAdded(uint256 proposalID,
    address initiator,
    string description,
    uint256 deadline);

    event VotingFinished(uint256 proposalID, uint256 votes);

    function makeNewProposal(string _proposalDescription,
    uint256 _debatingPeriodInMinutes)
    returns (uint256){
        // only shareholder with one or more shares can make a proposal
        // !!!! can be more then one share required
        if (balanceOf[msg.sender] < 1) throw;

        if (_debatingPeriodInMinutes < 1) throw;

        uint256 id = proposalText.push(_proposalDescription) - 1;
        deadline[id] = now + _debatingPeriodInMinutes * 1 minutes;

        // add to proposals of this shareholder:
        proposalsByShareholder[msg.sender].push(id);

        // initiator always votes &#39;yes&#39;
        votes[id].push(msg.sender);
        voted[id][msg.sender] = true;

        ProposalAdded(id, msg.sender, _proposalDescription, deadline[id]);

        return id;
        // returns proposal id
    }

    // >>> not from Wallet (needs msg.sender), from Dapp
    function getMyProposals() constant returns (uint256[]){
        return proposalsByShareholder[msg.sender];
    }

    function voteForProposal(uint256 _proposalID) returns (string) {

        // if no shares currently owned - no right to vote
        if (balanceOf[msg.sender] < 1) return "no shares, vote not accepted";

        // if already voted - throw, else voting can be spammed
        if (voted[_proposalID][msg.sender]) {
            return "already voted, vote not accepted";
        }

        // no votes after deadline
        if (now > deadline[_proposalID]) {
            return "vote not accepted after deadline";
        }

        // add to list of voted &#39;yes&#39;
        votes[_proposalID].push(msg.sender);
        voted[_proposalID][msg.sender] = true;
        return "vote accepted";
    }

    // to count votes this transaction should be started manually
    // from _any_ Ethereum address after deadline
    function countVotes(uint256 _proposalID) returns (uint256){

        // if not after deadline - throw
        if (now < deadline[_proposalID]) throw;

        // if already counted return result;
        if (results[_proposalID] > 0) return results[_proposalID];

        // else should count results and store in public variable
        uint256 result = 0;
        for (uint256 i = 0; i < votes[_proposalID].length; i++) {

            address voter = votes[_proposalID][i];
            result = result + balanceOf[voter];
        }
        // ----->>> !!! important
        // store result
        results[_proposalID] = result;

        // Log and notify anyone listening that this voting finished
        // with &#39;result&#39; - number of &#39;yes&#39; votes
        VotingFinished(_proposalID, result);

        return result;
    }

}