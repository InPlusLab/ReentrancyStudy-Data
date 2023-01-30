contract AmIOnTheFork {
    bool public forked = false;
    address constant darkDAO = 0x304a554a310c7e546dfe434669c62820b7d83490;
    // Check the fork condition during creation of the contract.
    // This function should be called between block 1920000 and 1921200.
    // Approximately between 2016-07-20 12:00:00 UTC and 2016-07-20 17:00:00 UTC.
    // After that the status will be locked in.
    function update() {
        if (block.number >= 1920000 && block.number <= 1921200) {
            forked = darkDAO.balance < 3600000 ether;
        }
    }
    function() {
        throw;
    }
}