/**

 *Submitted for verification at Etherscan.io on 2019-08-11

*/



/**

 *Submitted for verification at Etherscan.io on 2019-08-11

*/



pragma solidity ^0.5.10;



/**

 * @dev Contract module that helps prevent reentrant calls to a function.

 *

 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier

 * available, which can be applied to functions to make sure there are no nested

 * (reentrant) calls to them.

 *

 * Note that because there is a single `nonReentrant` guard, functions marked as

 * `nonReentrant` may not call one another. This can be worked around by making

 * those functions `private`, and then adding `external` `nonReentrant` entry

 * points to them.

 */

contract ReentrancyGuard {

    // counter to allow mutex lock with only one SSTORE operation

    uint256 private _guardCounter;



    constructor () internal {

        // The counter starts at one to prevent changing it from zero to a non-zero

        // value, which is a more expensive operation.

        _guardCounter = 1;

    }



    /**

     * @dev Prevents a contract from calling itself, directly or indirectly.

     * Calling a `nonReentrant` function from another `nonReentrant`

     * function is not supported. It is possible to prevent this from happening

     * by making the `nonReentrant` function external, and make it call a

     * `private` function that does the actual work.

     */

    modifier nonReentrant() {

        _guardCounter += 1;

        uint256 localCounter = _guardCounter;

        _;

        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");

    }

}



// File: contracts/commons/Ownable.sol



pragma solidity ^0.5.10;





contract Ownable {

    address public owner;



    event TransferOwnership(address _from, address _to);



    constructor() public {

        owner = msg.sender;

        emit TransferOwnership(address(0), msg.sender);

    }



    modifier onlyOwner() {

        require(msg.sender == owner, "only owner");

        _;

    }



    function setOwner(address _owner) external onlyOwner {

        emit TransferOwnership(owner, _owner);

        owner = _owner;

    }

}



// File: contracts/commons/StorageUnit.sol



pragma solidity ^0.5.10;





contract StorageUnit {

    address private owner;

    mapping(bytes32 => bytes32) private store;



    constructor() public {

        owner = msg.sender;

    }



    function write(bytes32 _key, bytes32 _value) external {

        /* solium-disable-next-line */

        require(msg.sender == owner);

        store[_key] = _value;

    }



    function read(bytes32 _key) external view returns (bytes32) {

        return store[_key];

    }

}



// File: contracts/utils/IsContract.sol



pragma solidity ^0.5.10;





library IsContract {

    function isContract(address _addr) internal view returns (bool) {

        bytes32 codehash;

        /* solium-disable-next-line */

        assembly { codehash := extcodehash(_addr) }

        return codehash != bytes32(0) && codehash != bytes32(0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);

    }

}



// File: contracts/utils/DistributedStorage.sol



pragma solidity ^0.5.10;









library DistributedStorage {

    function contractSlot(bytes32 _struct) private view returns (address) {

        return address(

            uint256(

                keccak256(

                    abi.encodePacked(

                        byte(0xff),

                        address(this),

                        _struct,

                        keccak256(type(StorageUnit).creationCode)

                    )

                )

            )

        );

    }



    function deploy(bytes32 _struct) private {

        bytes memory slotcode = type(StorageUnit).creationCode;

        /* solium-disable-next-line */

        assembly{ pop(create2(0, add(slotcode, 0x20), mload(slotcode), _struct)) }

    }



    function write(

        bytes32 _struct,

        bytes32 _key,

        bytes32 _value

    ) internal {

        StorageUnit store = StorageUnit(contractSlot(_struct));

        if (!IsContract.isContract(address(store))) {

            deploy(_struct);

        }



        /* solium-disable-next-line */

        (bool success, ) = address(store).call(

            abi.encodeWithSelector(

                store.write.selector,

                _key,

                _value

            )

        );



        require(success, "error writing storage");

    }



    function read(

        bytes32 _struct,

        bytes32 _key

    ) internal view returns (bytes32) {

        StorageUnit store = StorageUnit(contractSlot(_struct));

        if (!IsContract.isContract(address(store))) {

            return bytes32(0);

        }



        /* solium-disable-next-line */

        (bool success, bytes memory data) = address(store).staticcall(

            abi.encodeWithSelector(

                store.read.selector,

                _key

            )

        );



        require(success, "error reading storage");

        return abi.decode(data, (bytes32));

    }

}



// File: contracts/utils/SafeMath.sol



pragma solidity ^0.5.10;





library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 z = x + y;

        require(z >= x, "Add overflow");

        return z;

    }



    function sub(uint256 x, uint256 y) internal pure returns (uint256) {

        require(x >= y, "Sub underflow");

        return x - y;

    }



    function mult(uint256 x, uint256 y) internal pure returns (uint256) {

        if (x == 0) {

            return 0;

        }



        uint256 z = x * y;

        require(z / x == y, "Mult overflow");

        return z;

    }



    function div(uint256 x, uint256 y) internal pure returns (uint256) {

        require(y != 0, "Div by zero");

        return x / y;

    }



    function divRound(uint256 x, uint256 y) internal pure returns (uint256) {

        require(y != 0, "Div by zero");

        uint256 r = x / y;

        if (x % y != 0) {

            r = r + 1;

        }



        return r;

    }

}



// File: contracts/utils/Math.sol



pragma solidity ^0.5.10;





library Math {

    function orderOfMagnitude(uint256 input) internal pure returns (uint256){

        uint256 counter = uint(-1);

        uint256 temp = input;



        do {

            temp /= 10;

            counter++;

        } while (temp != 0);



        return counter;

    }



    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a < _b) {

            return _a;

        } else {

            return _b;

        }

    }



    function max(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a > _b) {

            return _a;

        } else {

            return _b;

        }

    }

}



// File: contracts/utils/GasPump.sol



pragma solidity ^0.5.10;





contract GasPump {

    bytes32 private stub;



    modifier requestGas(uint256 _factor) {

        if (tx.gasprice == 0 || gasleft() > block.gaslimit) {

            uint256 startgas = gasleft();

            _;

            uint256 delta = startgas - gasleft();

            uint256 target = (delta * _factor) / 100;

            startgas = gasleft();

            while (startgas - gasleft() < target) {

                // Burn gas

                stub = keccak256(abi.encodePacked(stub));

            }

        } else {

            _;

        }

    }

}



// File: contracts/interfaces/IERC20.sol



pragma solidity ^0.5.10;





interface IERC20 {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function balanceOf(address _owner) external view returns (uint256 balance);

}



// File: contracts/commons/AddressMinHeap.sol



pragma solidity ^0.5.10;



/*

    @author Agustin Aguilar <[email protected]>

*/





library AddressMinHeap {

    using AddressMinHeap for AddressMinHeap.Heap;



    struct Heap {

        uint256[] entries;

        mapping(address => uint256) index;

    }



    function initialize(Heap storage _heap) internal {

        require(_heap.entries.length == 0, "already initialized");

        _heap.entries.push(0);

    }



    function encode(address _addr, uint256 _value) internal pure returns (uint256 _entry) {

        /* solium-disable-next-line */

        assembly {

            _entry := not(or(and(0xffffffffffffffffffffffffffffffffffffffff, _addr), shl(160, _value)))

        }

    }



    function decode(uint256 _entry) internal pure returns (address _addr, uint256 _value) {

        /* solium-disable-next-line */

        assembly {

            let entry := not(_entry)

            _addr := and(entry, 0xffffffffffffffffffffffffffffffffffffffff)

            _value := shr(160, entry)

        }

    }



    function decodeAddress(uint256 _entry) internal pure returns (address _addr) {

        /* solium-disable-next-line */

        assembly {

            _addr := and(not(_entry), 0xffffffffffffffffffffffffffffffffffffffff)

        }

    }



    function top(Heap storage _heap) internal view returns(address, uint256) {

        if (_heap.entries.length < 2) {

            return (address(0), 0);

        }



        return decode(_heap.entries[1]);

    }



    function has(Heap storage _heap, address _addr) internal view returns (bool) {

        return _heap.index[_addr] != 0;

    }



    function size(Heap storage _heap) internal view returns (uint256) {

        return _heap.entries.length - 1;

    }



    function entry(Heap storage _heap, uint256 _i) internal view returns (address, uint256) {

        return decode(_heap.entries[_i + 1]);

    }



    // RemoveMax pops off the root element of the heap (the highest value here) and rebalances the heap

    function popTop(Heap storage _heap) internal returns(address _addr, uint256 _value) {

        // Ensure the heap exists

        uint256 heapLength = _heap.entries.length;

        require(heapLength > 1, "The heap does not exists");



        // take the root value of the heap

        (_addr, _value) = decode(_heap.entries[1]);

        _heap.index[_addr] = 0;



        if (heapLength == 2) {

            _heap.entries.length = 1;

        } else {

            // Takes the last element of the array and put it at the root

            uint256 val = _heap.entries[heapLength - 1];

            _heap.entries[1] = val;



            // Delete the last element from the array

            _heap.entries.length = heapLength - 1;



            // Start at the top

            uint256 ind = 1;



            // Bubble down

            ind = _heap.bubbleDown(ind, val);



            // Update index

            _heap.index[decodeAddress(val)] = ind;

        }

    }



    // Inserts adds in a value to our heap.

    function insert(Heap storage _heap, address _addr, uint256 _value) internal {

        require(_heap.index[_addr] == 0, "The entry already exists");



        // Add the value to the end of our array

        uint256 encoded = encode(_addr, _value);

        _heap.entries.push(encoded);



        // Start at the end of the array

        uint256 currentIndex = _heap.entries.length - 1;



        // Bubble Up

        currentIndex = _heap.bubbleUp(currentIndex, encoded);



        // Update index

        _heap.index[_addr] = currentIndex;

    }



    function update(Heap storage _heap, address _addr, uint256 _value) internal {

        uint256 ind = _heap.index[_addr];

        require(ind != 0, "The entry does not exists");



        uint256 can = encode(_addr, _value);

        uint256 val = _heap.entries[ind];

        uint256 newInd;



        if (can < val) {

            // Bubble down

            newInd = _heap.bubbleDown(ind, can);

        } else if (can > val) {

            // Bubble up

            newInd = _heap.bubbleUp(ind, can);

        } else {

            // no changes needed

            return;

        }



        // Update entry

        _heap.entries[newInd] = can;



        // Update index

        if (newInd != ind) {

            _heap.index[_addr] = newInd;

        }

    }



    function bubbleUp(Heap storage _heap, uint256 _ind, uint256 _val) internal returns (uint256 ind) {

        // Bubble up

        ind = _ind;

        if (ind != 1) {

            uint256 parent = _heap.entries[ind / 2];

            while (parent < _val) {

                // If the parent value is lower than our current value, we swap them

                (_heap.entries[ind / 2], _heap.entries[ind]) = (_val, parent);



                // Update moved Index

                _heap.index[decodeAddress(parent)] = ind;



                // change our current Index to go up to the parent

                ind = ind / 2;

                if (ind == 1) {

                    break;

                }



                // Update parent

                parent = _heap.entries[ind / 2];

            }

        }

    }



    function bubbleDown(Heap storage _heap, uint256 _ind, uint256 _val) internal returns (uint256 ind) {

        // Bubble down

        ind = _ind;



        uint256 lenght = _heap.entries.length;

        uint256 target = lenght - 1;



        while (ind * 2 < lenght) {

            // get the current index of the children

            uint256 j = ind * 2;



            // left child value

            uint256 leftChild = _heap.entries[j];



            // Store the value of the child

            uint256 childValue;



            if (target > j) {

                // The parent has two childs 👨‍👧‍👦



                // Load right child value

                uint256 rightChild = _heap.entries[j + 1];



                // Compare the left and right child.

                // if the rightChild is greater, then point j to it's index

                // and save the value

                if (leftChild < rightChild) {

                    childValue = rightChild;

                    j = j + 1;

                } else {

                    // The left child is greater

                    childValue = leftChild;

                }

            } else {

                // The parent has a single child 👨‍👦

                childValue = leftChild;

            }



            // Check if the child has a lower value

            if (_val > childValue) {

                break;

            }



            // else swap the value

            (_heap.entries[ind], _heap.entries[j]) = (childValue, _val);



            // Update moved Index

            _heap.index[decodeAddress(childValue)] = ind;



            // and let's keep going down the heap

            ind = j;

        }

    }

}



// File: contracts/Heap.sol



pragma solidity ^0.5.10;







contract Heap is Ownable {

    using AddressMinHeap for AddressMinHeap.Heap;



    // heap

    AddressMinHeap.Heap private heap;



    // Heap events

    event JoinHeap(address indexed _address, uint256 _balance, uint256 _prevSize);

    event LeaveHeap(address indexed _address, uint256 _balance, uint256 _prevSize);



    uint256 public constant TOP_SIZE = 512;



    constructor() public {

        heap.initialize();

    }



    function topSize() external pure returns (uint256) {

        return TOP_SIZE;

    }



    function addressAt(uint256 _i) external view returns (address addr) {

        (addr, ) = heap.entry(_i);

    }



    function indexOf(address _addr) external view returns (uint256) {

        return heap.index[_addr];

    }



    function entry(uint256 _i) external view returns (address, uint256) {

        return heap.entry(_i);

    }



    function top() external view returns (address, uint256) {

        return heap.top();

    }



    function size() external view returns (uint256) {

        return heap.size();

    }



    function update(address _addr, uint256 _new) external onlyOwner {

        uint256 _size = heap.size();



        // If the heap is empty

        // join the _addr

        if (_size == 0) {

            emit JoinHeap(_addr, _new, 0);

            heap.insert(_addr, _new);

            return;

        }



        // Load top value of the heap

        (, uint256 lastBal) = heap.top();



        // If our target address already is in the heap

        if (heap.has(_addr)) {

            // Update the target address value

            heap.update(_addr, _new);

            // If the new value is 0

            // always pop the heap

            // we updated the heap, so our address should be on top

            if (_new == 0) {

                heap.popTop();

                emit LeaveHeap(_addr, 0, _size);

            }

        } else {

            // IF heap is full or new balance is higher than pop heap

            if (_new != 0 && (_size < TOP_SIZE || lastBal < _new)) {

                // If heap is full pop heap

                if (_size >= TOP_SIZE) {

                    (address _poped, uint256 _balance) = heap.popTop();

                    emit LeaveHeap(_poped, _balance, _size);

                }



                // Insert new value

                heap.insert(_addr, _new);

                emit JoinHeap(_addr, _new, _size);

            }

        }

    }

}



// File: contracts/ShuffleToken.sol



pragma solidity ^0.5.10;

















contract ShuffleToken is Ownable, GasPump, IERC20 {

    using DistributedStorage for bytes32;

    using SafeMath for uint256;



    // Shuffle events

    event Winner(address indexed _addr, uint256 _value);



    // Managment events

    event SetName(string _prev, string _new);

    event SetExtraGas(uint256 _prev, uint256 _new);

    event SetHeap(address _prev, address _new);

    event WhitelistFrom(address _addr, bool _whitelisted);

    event WhitelistTo(address _addr, bool _whitelisted);



    uint256 public totalSupply;



    bytes32 private constant BALANCE_KEY = keccak256("balance");



    // game

    uint256 public constant FEE = 100;



    // metadata

    string public name = "Shuffle.Monster V3";

    string public constant symbol = "SHUF";

    uint8 public constant decimals = 18;



    // fee whitelist

    mapping(address => bool) public whitelistFrom;

    mapping(address => bool) public whitelistTo;



    // heap

    Heap public heap;



    // internal

    uint256 public extraGas;

    bool inited;



    function init(

        address _to,

        uint256 _amount

    ) external {

        // Only init once

        assert(!inited);

        inited = true;



        // Sanity checks

        assert(totalSupply == 0);

        assert(address(heap) == address(0));



        // Create Heap

        heap = new Heap();

        emit SetHeap(address(0), address(heap));



        // Init contract variables and mint

        // entire token balance

        extraGas = 15;

        emit SetExtraGas(0, extraGas);

        emit Transfer(address(0), _to, _amount);

        _setBalance(_to, _amount);

        totalSupply = _amount;

    }



    ///

    // Storage access functions

    ///



    // Getters



    function _toKey(address a) internal pure returns (bytes32) {

        return bytes32(uint256(a));

    }



    function _balanceOf(address _addr) internal view returns (uint256) {

        return uint256(_toKey(_addr).read(BALANCE_KEY));

    }



    function _allowance(address _addr, address _spender) internal view returns (uint256) {

        return uint256(_toKey(_addr).read(keccak256(abi.encodePacked("allowance", _spender))));

    }



    function _nonce(address _addr, uint256 _cat) internal view returns (uint256) {

        return uint256(_toKey(_addr).read(keccak256(abi.encodePacked("nonce", _cat))));

    }



    // Setters



    function _setAllowance(address _addr, address _spender, uint256 _value) internal {

        _toKey(_addr).write(keccak256(abi.encodePacked("allowance", _spender)), bytes32(_value));

    }



    function _setNonce(address _addr, uint256 _cat, uint256 _value) internal {

        _toKey(_addr).write(keccak256(abi.encodePacked("nonce", _cat)), bytes32(_value));

    }



    function _setBalance(address _addr, uint256 _balance) internal {

        _toKey(_addr).write(BALANCE_KEY, bytes32(_balance));

        heap.update(_addr, _balance);

    }



    ///

    // Internal methods

    ///



    function _isWhitelisted(address _from, address _to) internal view returns (bool) {

        return whitelistFrom[_from]||whitelistTo[_to];

    }



    function _random(address _s1, uint256 _s2, uint256 _s3, uint256 _max) internal pure returns (uint256) {

        uint256 rand = uint256(keccak256(abi.encodePacked(_s1, _s2, _s3)));

        return rand % (_max + 1);

    }



    function _pickWinner(address _from, uint256 _value) internal returns (address winner) {

        // Get order of magnitude of the tx

        uint256 magnitude = Math.orderOfMagnitude(_value);

        // Pull nonce for a given order of magnitude

        uint256 nonce = _nonce(_from, magnitude);

        _setNonce(_from, magnitude, nonce + 1);

        // pick entry from heap

        winner = heap.addressAt(_random(_from, nonce, magnitude, heap.size() - 1));

    }



    function _transferFrom(address _operator, address _from, address _to, uint256 _value, bool _payFee) internal {

        // If transfer amount is zero

        // emit event and stop execution

        if (_value == 0) {

            emit Transfer(_from, _to, 0);

            return;

        }



        // Load sender balance

        uint256 balanceFrom = _balanceOf(_from);

        require(balanceFrom >= _value, "balance not enough");



        // Check if operator is sender

        if (_from != _operator) {

            // If not, validate allowance

            uint256 allowanceFrom = _allowance(_from, _operator);

            // If allowance is not 2 ** 256 - 1, consume allowance

            if (allowanceFrom != uint(-1)) {

                // Check allowance and save new one

                require(allowanceFrom >= _value, "allowance not enough");

                _setAllowance(_from, _operator, allowanceFrom.sub(_value));

            }

        }



        // Calculate receiver balance

        // initial receive is full value

        uint256 receive = _value;

        uint256 burn = 0;

        uint256 shuf = 0;



        // Change sender balance

        _setBalance(_from, balanceFrom.sub(_value));



        // If the transaction is not whitelisted

        // or if sender requested to pay the fee

        // calculate fees

        if (_payFee || !_isWhitelisted(_from, _to)) {

            // Fee is the same for BURN and SHUF

            // If we are sending value one

            // give priority to BURN

            burn = _value.divRound(FEE);

            shuf = _value == 1 ? 0 : burn;



            // Subtract fees from receiver amount

            receive = receive.sub(burn.add(shuf));



            // Burn tokens

            totalSupply = totalSupply.sub(burn);

            emit Transfer(_from, address(0), burn);



            // Shuffle tokens

            // Pick winner pseudo-randomly

            address winner = _pickWinner(_from, _value);

            // Transfer balance to winner

            _setBalance(winner, _balanceOf(winner).add(shuf));

            emit Winner(winner, shuf);

            emit Transfer(_from, winner, shuf);

        }



        // Sanity checks

        // no tokens where created

        assert(burn.add(shuf).add(receive) == _value);



        // Add tokens to receiver

        _setBalance(_to, _balanceOf(_to).add(receive));

        emit Transfer(_from, _to, receive);

    }



    ///

    // Managment

    ///



    function setWhitelistedTo(address _addr, bool _whitelisted) external onlyOwner {

        emit WhitelistTo(_addr, _whitelisted);

        whitelistTo[_addr] = _whitelisted;

    }



    function setWhitelistedFrom(address _addr, bool _whitelisted) external onlyOwner {

        emit WhitelistFrom(_addr, _whitelisted);

        whitelistFrom[_addr] = _whitelisted;

    }



    function setName(string calldata _name) external onlyOwner {

        emit SetName(name, _name);

        name = _name;

    }



    function setExtraGas(uint256 _gas) external onlyOwner {

        emit SetExtraGas(extraGas, _gas);

        extraGas = _gas;

    }



    function setHeap(Heap _heap) external onlyOwner {

        emit SetHeap(address(heap), address(_heap));

        heap = _heap;

    }



    /////

    // Heap methods

    /////



    function topSize() external view returns (uint256) {

        return heap.topSize();

    }



    function heapSize() external view returns (uint256) {

        return heap.size();

    }



    function heapEntry(uint256 _i) external view returns (address, uint256) {

        return heap.entry(_i);

    }



    function heapTop() external view returns (address, uint256) {

        return heap.top();

    }



    function heapIndex(address _addr) external view returns (uint256) {

        return heap.indexOf(_addr);

    }



    function getNonce(address _addr, uint256 _cat) external view returns (uint256) {

        return _nonce(_addr, _cat);

    }



    /////

    // ERC20

    /////



    function balanceOf(address _addr) external view returns (uint256) {

        return _balanceOf(_addr);

    }



    function allowance(address _addr, address _spender) external view returns (uint256) {

        return _allowance(_addr, _spender);

    }



    function approve(address _spender, uint256 _value) external returns (bool) {

        emit Approval(msg.sender, _spender, _value);

        _setAllowance(msg.sender, _spender, _value);

        return true;

    }



    function transfer(address _to, uint256 _value) external requestGas(extraGas) returns (bool) {

        _transferFrom(msg.sender, msg.sender, _to, _value, false);

        return true;

    }



    function transferWithFee(address _to, uint256 _value) external requestGas(extraGas) returns (bool) {

        _transferFrom(msg.sender, msg.sender, _to, _value, true);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) external requestGas(extraGas) returns (bool) {

        _transferFrom(msg.sender, _from, _to, _value, false);

        return true;

    }



    function transferFromWithFee(address _from, address _to, uint256 _value) external requestGas(extraGas) returns (bool) {

        _transferFrom(msg.sender, _from, _to, _value, true);

        return true;

    }

}



// File: contracts/utils/SigUtils.sol



pragma solidity ^0.5.10;





library SigUtils {

    /**

      @dev Recovers address who signed the message

      @param _hash operation ethereum signed message hash

      @param _signature message `hash` signature

    */

    function ecrecover2(

        bytes32 _hash,

        bytes memory _signature

    ) internal pure returns (address) {

        bytes32 r;

        bytes32 s;

        uint8 v;



        /* solium-disable-next-line */

        assembly {

            r := mload(add(_signature, 32))

            s := mload(add(_signature, 64))

            v := and(mload(add(_signature, 65)), 255)

        }



        if (v < 27) {

            v += 27;

        }



        return ecrecover(

            _hash,

            v,

            r,

            s

        );

    }

}



// File: contracts/utils/SafeCast.sol



pragma solidity ^0.5.10;





library SafeCast {

    function toUint96(uint256 _a) internal pure returns (uint96) {

        require(_a <= 2 ** 96 - 1, "cast uint96 overflow");

        return uint96(_a);

    }

}



// File: contracts/Airdrop.sol



pragma solidity ^0.5.10;



















contract Airdrop is Ownable, ReentrancyGuard {

    using IsContract for address payable;

    using SafeCast for uint256;

    using SafeMath for uint256;



    ShuffleToken public shuffleToken;



    // Managment

    uint64 public maxClaimedBy = 0;

    uint256 public refsCut;

    mapping(address => uint256) public customMaxClaimedBy;

    bool public paused;



    event SetMaxClaimedBy(uint256 _max);

    event SetCustomMaxClaimedBy(address _address, uint256 _max);

    event SetSigner(address _signer, bool _active);

    event SetMigrator(address _migrator, bool _active);

    event SetFuse(address _fuse, bool _active);

    event SetPaused(bool _paused);

    event SetRefsCut(uint256 _prev, uint256 _new);

    event Claimed(address _by, address _to, address _signer, uint256 _value, uint256 _claimed, bytes _signature);

    event RefClaim(address _ref, uint256 _val);

    event ClaimedOwner(address _owner, uint256 _tokens);



    uint256 public constant MINT_AMOUNT = 1000000 * 10 ** 18;

    uint256 public constant SHUFLE_BY_ETH = 150;

    uint256 public constant MAX_CLAIM_ETH = 10 ether;



    mapping(address => bool) public isSigner;

    mapping(address => bool) public isMigrator;

    mapping(address => bool) public isFuse;



    mapping(address => uint256) public claimed;

    mapping(address => uint256) public numberClaimedBy;



    constructor(ShuffleToken _token) public {

        shuffleToken = _token;

        emit SetMaxClaimedBy(maxClaimedBy);

    }



    // ///

    // Managment

    // ///



    modifier notPaused() {

        require(!paused, "contract is paused");

        _;

    }



    function setMaxClaimedBy(uint64 _max) external onlyOwner {

        maxClaimedBy = _max;

        emit SetMaxClaimedBy(_max);

    }



    function setSigner(address _signer, bool _active) external onlyOwner {

        isSigner[_signer] = _active;

        emit SetSigner(_signer, _active);

    }



    function setMigrator(address _migrator, bool _active) external onlyOwner {

        isMigrator[_migrator] = _active;

        emit SetMigrator(_migrator, _active);

    }



    function setFuse(address _fuse, bool _active) external onlyOwner {

        isFuse[_fuse] = _active;

        emit SetFuse(_fuse, _active);

    }



    function setSigners(address[] calldata _signers, bool _active) external onlyOwner {

        for (uint256 i = 0; i < _signers.length; i++) {

            address signer = _signers[i];

            isSigner[signer] = _active;

            emit SetSigner(signer, _active);

        }

    }



    function setCustomMaxClaimedBy(address _address, uint256 _max) external onlyOwner {

        customMaxClaimedBy[_address] = _max;

        emit SetCustomMaxClaimedBy(_address, _max);

    }



    function setRefsCut(uint256 _val) external onlyOwner {

        emit SetRefsCut(refsCut, _val);

        refsCut = _val;

    }



    function pause() external {

        require(

            isFuse[msg.sender] ||

            msg.sender == owner ||

            isMigrator[msg.sender] ||

            isSigner[msg.sender],

            "not authorized"

        );



        paused = true;

        emit SetPaused(true);

    }



    function start() external onlyOwner {

        emit SetPaused(false);

        paused = false;

    }



    // ///

    // Airdrop

    // ///



    function _selfBalance() internal view returns (uint256) {

        return shuffleToken.balanceOf(address(this));

    }



    function checkFallback(address _to) private returns (bool success) {

        /* solium-disable-next-line */

        (success, ) = _to.call.value(1)("");

    }



    function claim(

        address _to,

        address _ref,

        uint256 _val,

        bytes calldata _sig

    ) external notPaused nonReentrant {

        // Load values

        uint96 val = _val.toUint96();



        // Validate signature

        bytes32 _hash = keccak256(abi.encodePacked(_to, val));

        address signer = SigUtils.ecrecover2(_hash, _sig);

        require(isSigner[signer], "signature not valid");



        // Prepare claim amount

        uint256 balance = _selfBalance();

        uint256 claimVal = Math.min(

            balance,

            Math.min(

                val,

                MAX_CLAIM_ETH

            ).mult(SHUFLE_BY_ETH)

        );



        // Sanity checks

        assert(claimVal <= SHUFLE_BY_ETH.mult(val));

        assert(claimVal <= MAX_CLAIM_ETH.mult(SHUFLE_BY_ETH));

        assert(claimVal.div(SHUFLE_BY_ETH) <= MAX_CLAIM_ETH);

        assert(

            claimVal.div(SHUFLE_BY_ETH) == _val ||

            claimVal.div(SHUFLE_BY_ETH) == MAX_CLAIM_ETH ||

            claimVal == balance

        );



        // Claim, only once

        require(claimed[_to] == 0, "already claimed");

        claimed[_to] = claimVal;



        // External claim checks

        if (msg.sender != _to) {

            // Validate max external claims

            uint256 _numberClaimedBy = numberClaimedBy[msg.sender].add(1);

            require(_numberClaimedBy <= Math.max(maxClaimedBy, customMaxClaimedBy[msg.sender]), "max claim reached");

            numberClaimedBy[msg.sender] = _numberClaimedBy;

            // Check if _to address can receive ETH

            require(checkFallback(_to), "_to address can't receive tokens");

        }



        // Transfer Shuffle token, paying fee

        shuffleToken.transferWithFee(_to, claimVal);



        // Emit events

        emit Claimed(msg.sender, _to, signer, val, claimVal, _sig);



        // Ref links

        if (refsCut != 0) {

            // Only valid for self-claims

            if (msg.sender == _to && _ref != address(0)) {

                // Calc transfer extra

                uint256 extra = claimVal.mult(refsCut).div(10000);

                // Ignore ref fee if Airdrop balance is not enought

                if (_selfBalance() >= extra) {

                    shuffleToken.transferWithFee(_ref, extra);

                    emit RefClaim(_ref, extra);



                    // Sanity checks

                    assert(extra <= MAX_CLAIM_ETH.mult(SHUFLE_BY_ETH));

                    assert(extra <= claimVal);

                    assert(extra == (claimVal * refsCut) / 10000);

                }

            }

        }



        // If contract is empty, perform self destruct

        if (balance == claimVal && _selfBalance() == 0) {

            selfdestruct(address(uint256(owner)));

        }

    }



    // Migration methods



    event Migrated(address _addr, uint256 _balance);

    mapping(address => uint256) public migrated;



    function migrate(address _addr, uint256 _balance, uint256 _require) external notPaused {

        // Check if migrator is a migrator

        require(isMigrator[msg.sender], "only migrator can migrate");



        // Check if expected migrated matches current migrated

        require(migrated[_addr] == _require, "_require prev migrate failed");



        // Save migrated amount

        migrated[_addr] = migrated[_addr].add(_balance);



        // Transfer tokens and emit event

        shuffleToken.transfer(_addr, _balance);

        emit Migrated(_addr, _balance);

    }



    function fund() external payable { }

}