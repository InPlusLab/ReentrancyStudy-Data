/**

 *Submitted for verification at Etherscan.io on 2019-01-21

*/



pragma solidity ^0.4.24;

/*

 * �X�T�[���������������Щ��Щ������������������Щ�  �X�T�[���������Щ������� ������������������������                       

 * �U  �� �������� �� ���Щ������ȩ�   ��   �U  �� �� ��������  �� Inventor ��                      

 * �^�T�a������������ �� �ة����� �ة����� ��   �^�T�a���������ة������� ������������������������                      

 *===========================================================================================*

 *                                ��������������������������������������������

 *                                �� Usage Instructions ��

 *                                ��������������������������������������������

 * whenever your contract needs to send eth to the corp bank, simply use the 

 * the following command:

 *

 *    Jekyll_Island_Inc.deposit.value(amount)()

 * 

 * OPTIONAL:

 * if you need to be checking wither the transaction was successful, the deposit function returns 

 * a bool indicating wither or not it was successful.  so another way to call this function 

 * would be:

 * 

 *    require(Jekyll_Island_Inc.deposit.value(amount)() == true, "Jekyll Island deposit failed");

 * 

 */



interface JIincInterfaceForForwarder {

    function deposit(address _addr) external payable returns (bool);

    function migrationReceiver_setup() external returns (bool);

}



contract JIincForwarder {

    string public name = "JIincForwarder";

    JIincInterfaceForForwarder private currentCorpBank_;

    address private newCorpBank_;

    bool needsBank_ = true;

    

    constructor() 

        public

    {

        //constructor does nothing.

    }

    

    function()

        public

        payable

    {

        // done so that if any one tries to dump eth into this contract, we can

        // just forward it to corp bank.

        currentCorpBank_.deposit.value(address(this).balance)(address(currentCorpBank_));

    }

    

    function deposit()

        public 

        payable

        returns(bool)

    {

        require(msg.value > 0, "Forwarder Deposit failed - zero deposits not allowed");

        require(needsBank_ == false, "Forwarder Deposit failed - no registered bank");

        if (currentCorpBank_.deposit.value(msg.value)(msg.sender) == true)

            return(true);

        else

            return(false);

    }

//==============================================================================

//     _ _ . _  _ _ _|_. _  _   .

//    | | ||(_|| (_| | |(_)| |  .

//===========_|=================================================================    

    function status()

        public

        view

        returns(address, address, bool)

    {

        return(address(currentCorpBank_), address(newCorpBank_), needsBank_);

    }



    function startMigration(address _newCorpBank)

        external

        returns(bool)

    {

        // make sure this is coming from current corp bank

        require(msg.sender == address(currentCorpBank_), "Forwarder startMigration failed - msg.sender must be current corp bank");

        

        // communicate with the new corp bank and make sure it has the forwarder 

        // registered 

        if(JIincInterfaceForForwarder(_newCorpBank).migrationReceiver_setup() == true)

        {

            // save our new corp bank address

            newCorpBank_ = _newCorpBank;

            return (true);

        } else 

            return (false);

    }

    

    function cancelMigration()

        external

        returns(bool)

    {

        // make sure this is coming from the current corp bank (also lets us know 

        // that current corp bank has not been killed)

        require(msg.sender == address(currentCorpBank_), "Forwarder cancelMigration failed - msg.sender must be current corp bank");

        

        // erase stored new corp bank address;

        newCorpBank_ = address(0x0);

        

        return (true);

    }

    

    function finishMigration()

        external

        returns(bool)

    {

        // make sure its coming from new corp bank

        require(msg.sender == newCorpBank_, "Forwarder finishMigration failed - msg.sender must be new corp bank");



        // update corp bank address        

        currentCorpBank_ = (JIincInterfaceForForwarder(newCorpBank_));

        

        // erase new corp bank address

        newCorpBank_ = address(0x0);

        

        return (true);

    }

//==============================================================================

//    . _ ._|_. _ |   _ _ _|_    _   .

//    || || | |(_||  _\(/_ | |_||_)  .  (this only runs once ever)

//==============================|===============================================

    function setup(address _firstCorpBank)

        external

    {

        require(needsBank_ == true, "Forwarder setup failed - corp bank already registered");

        currentCorpBank_ = JIincInterfaceForForwarder(_firstCorpBank);

        needsBank_ = false;

    }

}