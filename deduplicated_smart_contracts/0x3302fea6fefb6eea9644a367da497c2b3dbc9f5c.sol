pragma solidity ^0.4.11;

//
// ==== DISCLAIMER ====
//
// ETHEREUM IS STILL AN EXPEREMENTAL TECHNOLOGY.
// ALTHOUGH THIS SMART CONTRACT WAS CREATED WITH GREAT CARE AND IN THE HOPE OF BEING USEFUL, NO GUARANTEES OF FLAWLESS OPERATION CAN BE GIVEN.
// IN PARTICULAR - SUBTILE BUGS, HACKER ATTACKS OR MALFUNCTION OF UNDERLYING TECHNOLOGY CAN CAUSE UNINTENTIONAL BEHAVIOUR.
// YOU ARE STRONGLY ENCOURAGED TO STUDY THIS SMART CONTRACT CAREFULLY IN ORDER TO UNDERSTAND POSSIBLE EDGE CASES AND RISKS.
// DON&#39;T USE THIS SMART CONTRACT IF YOU HAVE SUBSTANTIAL DOUBTS OR IF YOU DON&#39;T KNOW WHAT YOU ARE DOING.
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ====
//
//
// ==== PARANOIA NOTICE ====
// A careful reader will find some additional checks and excessive code, consuming some extra gas. This is intentional.
// Even though the contract should work without these parts, they make the code more secure in production and for future refactoring.
// Also, they show more clearly what we have considered and addressed during development.
// Discussion is welcome!
// ====
//

/// @author ethernian
/// @notice report bugs to: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="74160113073411001c11061a1d151a5a171b19">[email&#160;protected]</a>
/// @title Presaler Voting Contract

interface TokenStorage {
    function balances(address account) public returns(uint balance);
}

contract PresalerVoting {

    string public constant VERSION = "0.0.2";

    /* ====== configuration START ====== */

    uint public VOTING_START_BLOCKNR  = 0;
    uint public VOTING_END_TIME       = 0;

    /* ====== configuration END ====== */

    TokenStorage PRESALE_CONTRACT = TokenStorage(0x4Fd997Ed7c10DbD04e95d3730cd77D79513076F2);

    string[5] private stateNames = ["BEFORE_START",  "VOTING_RUNNING", "CLOSED" ];
    enum State { BEFORE_START,  VOTING_RUNNING, CLOSED }

    mapping (address => uint) public rawVotes;

    uint private constant MAX_AMOUNT_EQU_0_PERCENT   = 1 finney;
    uint private constant MIN_AMOUNT_EQU_100_PERCENT = 1 ether ;

    address owner;

    //constructor
    function PresalerVoting () {
        owner = msg.sender;
    }

    //accept (and send back) voting payments here
    function ()
    onlyPresaler
    onlyState(State.VOTING_RUNNING)
    payable {
        if (msg.value > 1 ether || !msg.sender.send(msg.value)) throw;
        rawVotes[msg.sender] = msg.value;
    }

    /// @notice start voting at `startBlockNr` for `durationHrs`.
    /// Restricted for owner only.
    /// @param startBlockNr block number to start voting; starts immediatly if less than current block number.
    /// @param durationHrs voting duration (from now!); at least 1 hour.
    function startVoting(uint startBlockNr, uint durationHrs) onlyOwner {
        VOTING_START_BLOCKNR = max(block.number, startBlockNr);
        VOTING_END_TIME = now + max(durationHrs,1) * 1 hours;
    }

    function setOwner(address newOwner) onlyOwner {owner = newOwner;}

    /// @notice returns current voting result for given address in percent.
    /// @param voter balance holder address.
    function votedPerCent(address voter) constant external returns (uint) {
        var rawVote = rawVotes[voter];
        if (rawVote<=MAX_AMOUNT_EQU_0_PERCENT) return 0;
        else if (rawVote>=MIN_AMOUNT_EQU_100_PERCENT) return 100;
        else return rawVote * 100 / 1 ether;
    }

    /// @notice return voting remaining time (hours, minutes).
    function votingEndsInHHMM() constant returns (uint16, uint16) {
        var tsec = VOTING_END_TIME - now;
        return VOTING_END_TIME==0 ? (0,0) : (uint16(tsec / 1 hours), uint16(tsec % 1 hours / 1 minutes));
    }

    function currentState() internal constant returns (State) {
        if (VOTING_START_BLOCKNR == 0 || block.number < VOTING_START_BLOCKNR) {
            return State.BEFORE_START;
        } else if (now <= VOTING_END_TIME) {
            return State.VOTING_RUNNING;
        } else {
            return State.CLOSED;
        }
    }

    /// @notice returns current state of the voting.
    function state() public constant returns(string) {
        return stateNames[uint(currentState())];
    }

    function max(uint a, uint b) internal constant returns (uint maxValue) { return a>b ? a : b; }

    modifier onlyPresaler() {
        if (PRESALE_CONTRACT.balances(msg.sender) == 0) throw;
        _;
    }

    modifier onlyState(State state) {
        if (currentState()!=state) throw;
        _;
    }

    modifier onlyOwner() {
        if (msg.sender!=owner) throw;
        _;
    }

}//contract