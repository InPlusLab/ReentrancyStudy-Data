pragma solidity 0.6.3;

import "./AssetSwap.sol";
/**
MIT License
Copyright © 2020 Eric G. Falkenstein

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 OR OTHER DEALINGS IN THE SOFTWARE.
*/


contract ManagedAccount {
/// fee is in basis points. 100 means 1.0% of assets per year is sent to the manager

    constructor(address payable _manager, uint _fee) public {
        manager = _manager;
        investor[msg.sender] = true;
        lastUpdateTime = now;
        managerStatus = true;
        mgmtFee = _fee;
    }

    address payable public manager;
    mapping(address => bool) public approvedSwaps;
    mapping(address => bool) public investor;
    mapping(bytes32 => Takercontract) public takercontracts;
    bytes32[] public ourTakerContracts;
    address[] public ourSwaps;
    uint public lastUpdateTime;
    uint public managerBalance;
    uint public totAUMlag;
    bool public managerStatus;
    uint public mgmtFee;

    event AddedFunds(uint amount, address payor);
    event RemovedFunds(uint amount, address payee);

    struct Takercontract {
        address swapAddress;
        address lp;
        uint index;
    }

    modifier onlyInvestor() {
        require(investor[msg.sender]);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    modifier onlyApproved() {
        if (managerStatus)
            require(msg.sender == manager || investor[msg.sender]);
        else
            require(investor[msg.sender]);
        _;
    }

    receive ()
        external
        payable
    { emit AddedFunds(msg.value, msg.sender);
    }

    function changeManager(address payable _manager)
        external
        onlyInvestor
    {
        updateFee();
        uint manBal = managerBalance;
        managerBalance = 0;
        emit RemovedFunds(manBal, manager);
        manager.transfer(manBal);
        manager = _manager;
    }

    function addInvestor(address payable newInvestor)
        external
        onlyInvestor
    {
        investor[newInvestor] = true;
    }

    function removeInvestor(address payable oldInvestor)
        external
        onlyInvestor
    {
      require(oldInvestor != msg.sender);
      investor[oldInvestor] = false;
    }

    function disableManager(bool _managerStatus)
        external
        onlyInvestor
    {
        if (managerStatus && !_managerStatus)
            generateFee(totAUMlag);
        managerStatus = _managerStatus;
    }

    function adjFee(uint newFee)
        external
        onlyInvestor
    {
        mgmtFee = newFee;
    }

    function addSwap(address swap)
        external
        onlyInvestor
    {
        require(approvedSwaps[swap] == false);
        approvedSwaps[swap] = true;
        ourSwaps.push(swap);
    }
    /// must send 10x the minimum RM to fund a new createBook

    function createBook(uint amount, address swap, uint16 min, uint closefee, int fundingLong, int fundingShort)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        amount = amount * 1 szabo;
        require(amount <= address(this).balance);
        AssetSwap s = AssetSwap(swap);
        s.createBook.value(amount)(min, closefee, fundingLong, fundingShort);
    }

    function fundBookMargin(uint amount, address swap)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        amount = amount * 1 szabo;
        uint totAUM = totAUMlag + amount;
        generateFee(totAUM);
        require(amount < address(this).balance);
        AssetSwap s = AssetSwap(swap);
        s.fundLP.value(amount)(address(this));
    }

    function fundTakerMargin(uint amount, address swap, address lp, bytes32 subkid)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        amount = amount * 1 szabo;
        uint totAUM = totAUMlag + amount;
        generateFee(totAUM);
        require(amount < address(this).balance);
        AssetSwap s = AssetSwap(swap);
        s.fundTaker.value(amount)(lp, subkid);
    }

    function takeFromLP(uint amount, address swap, address lp, uint16 rM, bool takerLong)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        amount = 1 szabo * amount;
        require(amount < address(this).balance);
        uint totAUM = totAUMlag + amount;
        generateFee(totAUM);
        bytes32 subkid = s.take.value(amount)(lp, rM, takerLong);
        Takercontract memory t;
        t.swapAddress = swap;
        t.lp = lp;
        t.index = ourTakerContracts.length;
        takercontracts[subkid] = t;
        ourTakerContracts.push(subkid);

    }

    function cancelSubcontract(address swap, address lp, bytes32 id)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        (, , uint rm) = s.getSubkData1(lp, id);
        uint amount = 5 * rm / 100;
        require(amount < address(this).balance);
        s.cancel.value(amount)(lp, id, false);
    }

    function fund()
        external
        payable
        onlyApproved
    {
        emit AddedFunds(msg.value, msg.sender);
    }

    function activateEndBook(address swap)
        external
        payable
        onlyApproved
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.closeBook.value(msg.value)(address(this));
    }

    function adjMinReqMarg(uint16 amount, address swap)
        external
        onlyInvestor
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.adjustMinRM(amount);
    }

    function setFees(address swap, uint close, int longFR, int shortFR)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.updateFees(close, longFR, shortFR);
    }

    function investorWithdraw(uint amount)
        external
        onlyInvestor
    {
        require(subzero(address(this).balance, amount) > managerBalance);
        emit RemovedFunds(amount, msg.sender);
        msg.sender.transfer(amount);
    }

    function managerWithdraw()
        external
        onlyManager
    {
        uint manBal = managerBalance;
        managerBalance = 0;
        emit RemovedFunds(manBal, manager);
        msg.sender.transfer(manBal);
    }

    function withdrawLPToAS(address swap, uint16 amount)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        /// fund in gwei, or 1/1000 of the unit of denomination
        /// adjust to finney when applied for real use (1e15)
        s.withdrawLP(amount);
    }

    function withdrawTakerToAS(address swap, uint16 amount, address lp, bytes2 subkid)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        /// adjust this to finney for real use
        s.withdrawTaker(amount, lp, subkid);
    }

    function withdrawFromAS(address swap)
        external
        onlyApproved
    {
        require(approvedSwaps[swap]);
        AssetSwap s = AssetSwap(swap);
        s.withdrawFromAssetSwap();
    }

    function seeAUM()
        external
        view
        returns (uint totTakerBalance, uint totLPBalance, uint thisAccountBalance, uint _managerBalance)
    {
        totLPBalance = 0;
        uint lpMargin = 0;
        for (uint i = 0; i < ourSwaps.length; i++) {
            address ourswap = ourSwaps[i];
            AssetSwap s = AssetSwap(ourswap);
            (, lpMargin, , , , , , , , ) = s.getBookData(address(this));
            totLPBalance += lpMargin;
        }
        totTakerBalance = 0;
        uint takerMargin = 0;
        for (uint i = 0; i < ourTakerContracts.length; i++) {
            Takercontract storage k = takercontracts[ourTakerContracts[i]];
            AssetSwap s = AssetSwap(k.swapAddress);
            (, takerMargin, ) = s.getSubkData1(k.lp, ourTakerContracts[i]);
            totTakerBalance += takerMargin;
        }
        thisAccountBalance = address(this).balance;
        _managerBalance = managerBalance;
    }

    function updateFee()
        public
        onlyApproved
        {
        uint totAUM = 0;
        uint lpMargin;
        for (uint i = 0; i < ourSwaps.length; i++) {
            AssetSwap s = AssetSwap(ourSwaps[i]);
            (, lpMargin, , , , , , , , ) = s.getBookData(address(this));
            totAUM += lpMargin;
        }
        uint takerMargin = 0;
        for (uint i = 0; i < ourTakerContracts.length; i++) {
            Takercontract storage k = takercontracts[ourTakerContracts[i]];
            AssetSwap s = AssetSwap(k.swapAddress);
            (, takerMargin, ) = s.getSubkData1(k.lp, ourTakerContracts[i]);
            totAUM += takerMargin;
        }
        generateFee(totAUM);
    }

    function generateFee(uint newAUM)
    internal
    {
      /// this applies the management fee to to assets under management. The fee is in
      /// basis points, so dividing by 10000 turns 100 into 0.01.
        uint mgmtAccrual = (now - lastUpdateTime) * totAUMlag * mgmtFee / 10000 / 365 / 86400;
        lastUpdateTime = now;
        totAUMlag = newAUM;
        managerBalance += mgmtAccrual;
    }

    function subzero(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        if (_b >= _a) {
            return 0;
        }
        return _a - _b;
    }


}
