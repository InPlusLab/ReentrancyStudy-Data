/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.5.6;

contract IBooking {

    enum Status {
        New, Requested, Confirmed, Rejected, Canceled, Booked, Started,
        Finished, Arbitration, ArbitrationFinished, ArbitrationPossible
    }
    enum CancellationPolicy {Soft, Flexible, Strict}


    // methods
    function calculateCancel() external view returns(bool, uint, uint, uint);
    function cancel() external;

    function setArbiter(address _arbiter) external;
    function submitToArbitration(int _ticket) external;

    function arbitrate(uint depositToHostPpm, uint cleaningToHostPpm, uint priceToHostPpm, bool useCancellationPolicy) external;

    function calculateHostWithdraw() external view returns (bool isPossible, uint zangllTokenAmountToPut, uint hostPart);
    function hostWithdraw() external;

    function calculateGuestWithdraw() external view returns (bool isPossible, uint guestPart);
    function guestWithdraw() external;

    // fields
    function bookingId() external view returns(uint128);
    function dateFrom() external view returns(uint32);
    function dateTo() external view returns(uint32);
    function dateCancel() external view returns(uint32);
    function host() external view returns(address);
    function guest() external view returns(address);
    function cancellationPolicy() external view returns (IBooking.CancellationPolicy);

    function guestCoin() external view returns(address);
    function hostCoin() external view returns(address);
    function withdrawalOracle() external view returns(address);

    function price() external view returns(uint256);
    function cleaning() external view returns(uint256);
    function deposit() external view returns(uint256);

    function guestAmount() external view returns (uint256);

    function feeBeneficiary() external view returns(address);

    function ticket() external view returns(int);

    function arbiter() external view returns(address);

    function balance() external view returns (uint);
    function balanceToken(address) external view returns (uint);
    function status() external view returns(Status);
}

interface IWithdrawalOracle {
    function get(address coinAddress) external view returns (bool, uint, uint);
    function set(address coinAddress, bool _isEnabled, uint _currencyAmount, uint _zangllTokenAmount) external;
}

contract IOperationalWallet2 {
    function setTrustedToggler(address _trustedToggler) external;
    function toggleTrustedWithdrawer(address _withdrawer, bool isEnabled) external;
    function withdrawCoin(address coin, address to, uint256 amount) external returns (bool);
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library BookingLib {

    struct Booking {
        uint128 bookingId;
        uint32 dateFrom;
        uint32 dateTo;
        uint32 dateCancel;

        address withdrawalOracle;
        address operationalWallet2;

        address guestCoin;
        address hostCoin;
        address znglToken;

        // prices in host currency
        uint256 price;
        uint256 cleaning;
        uint256 deposit;

        // total amount in guest currency
        uint256 guestAmount;

        address host;
        address guest;
        address feeBeneficiary;
        IBooking.Status status;
        IBooking.CancellationPolicy cancellationPolicy;
        address factory;
        address arbiter;
        int ticket;

        bool guestFundsWithdriven; // false by default
        bool hostFundsWithdriven;  // false by default

        uint256 guestWithdrawAllowance; // deposit (by default)
        uint256 hostWithdrawAllowance;  // price + cleaning (by default)
    }

    // STATUS HELPERS AND FUNCTIONS---------------------------------------------------------------------------
    event StatusChanged (
        IBooking.Status indexed _from,
        IBooking.Status indexed _to
    );

    function getStatus(Booking storage booking)
    internal view returns (IBooking.Status) {
        if (booking.dateCancel == 0) {
            // normal flow
            if (booking.status == IBooking.Status.Booked) {
                if (now < booking.dateFrom) {
                    return IBooking.Status.Booked;
                } else if (now < booking.dateTo) {
                    return IBooking.Status.Started;
                } else if (now < booking.dateTo + 24 * 60 * 60) {
                    return IBooking.Status.ArbitrationPossible;
                } else {
                    return IBooking.Status.Finished;
                }
            } else {
                return booking.status;
            }
        } else {
            // canceled flow
            if (booking.status == IBooking.Status.ArbitrationFinished) {
                return booking.status;
            }
            if (now < booking.dateCancel + 24 * 60 * 60) {
                return IBooking.Status.ArbitrationPossible;
            } else {
                return IBooking.Status.Canceled;
            }
        }
    }

    function setStatus(Booking storage booking, IBooking.Status newStatus)
    internal {
        emit StatusChanged(booking.status, newStatus);
        booking.status = newStatus;
    }
    // -------------------------------------------------------------------------------------------------------

    // WITHDRAWAL FUNCTIONS ----------------------------------------------------------------------------------
    function isStatusAllowsWithdrawal(Booking storage booking)
    internal view returns (bool) {
        IBooking.Status currentStatus = getStatus(booking);
        return (
            currentStatus == IBooking.Status.Finished ||
            currentStatus == IBooking.Status.ArbitrationFinished ||
            currentStatus == IBooking.Status.Canceled
        );
    }

    function calculateGuestWithdraw(Booking storage booking)
    internal view returns (bool, uint) {
        if (!booking.guestFundsWithdriven &&
            isStatusAllowsWithdrawal(booking) &&
            IERC20(booking.hostCoin).balanceOf(booking.operationalWallet2) >= booking.guestWithdrawAllowance
        ) {
            return (true, booking.guestWithdrawAllowance);
        } else {
            return (false, 0);
        }
    }

    function guestWithdraw(Booking storage booking) internal {
        (bool isPossible, uint guestPart) = calculateGuestWithdraw(booking);
        require(isPossible);

        bool isWithdrawSuccessful = IOperationalWallet2(booking.operationalWallet2)
            .withdrawCoin(booking.hostCoin, booking.guest, guestPart);
        require(isWithdrawSuccessful);
        booking.guestFundsWithdriven = true;
    }

    function calculateHostWithdraw(Booking storage booking) internal view
    returns (bool isPossible, uint zangllTokenAmountToPut, uint hostPart) {
        (bool isCoinEnabled, uint currencyAmount, uint zangllTokenAmount) =
            IWithdrawalOracle(booking.withdrawalOracle).get(booking.hostCoin);

        if (!booking.hostFundsWithdriven &&
            isStatusAllowsWithdrawal(booking) &&
            isCoinEnabled &&
            IERC20(booking.hostCoin).balanceOf(booking.operationalWallet2) >= booking.hostWithdrawAllowance
        ) {
            isPossible = true;
            zangllTokenAmountToPut = booking.hostWithdrawAllowance * zangllTokenAmount / currencyAmount;
            hostPart = booking.hostWithdrawAllowance;
        } else {
            isPossible = false;
            zangllTokenAmountToPut = 0;
            hostPart = 0;
        }
    }

    function hostWithdraw(Booking storage booking) internal {
        (bool isPossible, uint zangllTokenAmountToPut, uint hostPart) = calculateHostWithdraw(booking);
        require(isPossible);

        bool isZnglTokenWithdrawSuccessful = IERC20(booking.znglToken)
            .transferFrom(booking.host, booking.feeBeneficiary, zangllTokenAmountToPut);
        require(isZnglTokenWithdrawSuccessful);

        bool isWithdrawSuccessful = IOperationalWallet2(booking.operationalWallet2)
            .withdrawCoin(booking.hostCoin, booking.host, hostPart);
        require(isWithdrawSuccessful);
        booking.hostFundsWithdriven = true;
    }
    // -------------------------------------------------------------------------------------------------------

    // CANCELLATION FUNCTIONS --------------------------------------------------------------------------------
    function calculateCancel(Booking storage booking)
    internal view returns (bool isPossible, uint depositToHostPpm, uint cleaningToHostPpm, uint priceToHostPpm) {

        // initialization
        isPossible = false;
        IBooking.Status currentStatus = getStatus(booking);

        (uint nightsAlreadyOccupied, uint nightsTotal) = getNights(booking);

        // checking
        if ((currentStatus != IBooking.Status.Booked && currentStatus != IBooking.Status.Started) ||
            (nightsTotal == 0 || nightsAlreadyOccupied >= nightsTotal) ||
            (currentStatus == IBooking.Status.Started && msg.sender == booking.host)) {
            return (false, 0, 0, 0);
        }

        depositToHostPpm = 0;
        cleaningToHostPpm = nightsAlreadyOccupied == 0 ? 0 : 1000000;
        priceToHostPpm = currentStatus == IBooking.Status.Booked && (msg.sender == booking.host || msg.sender == booking.feeBeneficiary)
            ? 0
            : getPriceToHostPpmByCancellationPolicy(booking, nightsAlreadyOccupied, nightsTotal, now);

        isPossible = true;
    }

    function cancel(Booking storage booking)
    internal {
        bool isPossible; uint depositToHostPpm; uint cleaningToHostPpm; uint priceToHostPpm;
        (isPossible, depositToHostPpm, cleaningToHostPpm, priceToHostPpm) = calculateCancel(booking);
        require(isPossible);

        booking.dateCancel = uint32(now);
        splitAllBalance(booking, depositToHostPpm, cleaningToHostPpm, priceToHostPpm);
        emit StatusChanged(booking.status, IBooking.Status.ArbitrationPossible);
    }
    // -------------------------------------------------------------------------------------------------------

    // ARBITRATION FUNCTIONS ---------------------------------------------------------------------------------
    function setArbiter(Booking storage booking, address _arbiter)
    internal {
        require(msg.sender == booking.factory);
        booking.arbiter = _arbiter;
    }

    function submitToArbitration(Booking storage booking, int _ticket)
    internal {
        IBooking.Status currentStatus = getStatus(booking);
        require(
            currentStatus == IBooking.Status.Booked ||
            currentStatus == IBooking.Status.Started ||
            currentStatus == IBooking.Status.ArbitrationPossible
        );
        require(!booking.guestFundsWithdriven && !booking.hostFundsWithdriven);
        booking.ticket = _ticket;
        setStatus(booking, IBooking.Status.Arbitration);
    }

    function arbitrate(Booking storage booking,
        uint depositToHostPpm, uint cleaningToHostPpm, uint priceToHostPpm, bool useCancellationPolicy)
    internal {
        require (booking.status == IBooking.Status.Arbitration && depositToHostPpm <= 1000000 &&
            cleaningToHostPpm <= 1000000 && priceToHostPpm <= 1000000);

        if (useCancellationPolicy) {
            (uint nightsAlreadyOccupied, uint nightsTotal) = getNights(booking);
            priceToHostPpm = getPriceToHostPpmByCancellationPolicy(booking, nightsAlreadyOccupied, nightsTotal, now);
        }

        splitAllBalance(booking, depositToHostPpm, cleaningToHostPpm, priceToHostPpm);
        setStatus(booking, IBooking.Status.ArbitrationFinished);
    }
    // -------------------------------------------------------------------------------------------------------

    // FUNCTIONS THAT SPLIT ALL BALANCE AND RETURN MONEY TO THE GUEST ----------------------------------------
    function splitAllBalance(Booking storage booking,
        uint depositToHostPpm, uint cleaningToHostPpm, uint priceToHostPpm)
    internal {
        uint priceToHost = booking.price * priceToHostPpm / 1000000;
        uint depositToHost = booking.deposit * depositToHostPpm / 1000000;
        uint cleaningToHost = booking.cleaning * cleaningToHostPpm / 1000000;

        booking.hostWithdrawAllowance = priceToHost + cleaningToHost + depositToHost;
        booking.guestWithdrawAllowance =
            (booking.price - priceToHost) +
            (booking.deposit - depositToHost) +
            (booking.cleaning - cleaningToHost);
    }

    // HELPERS FOR SPLITTING FUNDS ---------------------------------------------------------------------------
    function getNights(Booking storage booking)
    internal view returns (uint nightsAlreadyOccupied, uint nightsTotal) {
        nightsTotal = (12 * 60 * 60 + booking.dateTo - booking.dateFrom) / (24 * 60 * 60);
        if (now <= booking.dateFrom) {
            nightsAlreadyOccupied = 0;
        } else {
            // first night is occupied when 1 second is passed after check-in, and so on
            nightsAlreadyOccupied = (24 * 60 * 60 - 1 + now - booking.dateFrom) / (24 * 60 * 60);
        }
        if (nightsAlreadyOccupied > nightsTotal) {
            nightsAlreadyOccupied = nightsTotal;
        }
    }

    function getPriceToHostPpmByCancellationPolicy(
        Booking storage booking, uint nightsAlreadyOccupied, uint nightsTotal, uint _now)
    internal view returns (uint priceToHostPpm) {
        if (booking.cancellationPolicy == IBooking.CancellationPolicy.Flexible) {
            uint nightsToPay = _now < booking.dateFrom - 24 * 60 * 60
                ? 0
                : nightsAlreadyOccupied >= nightsTotal ? nightsTotal : nightsAlreadyOccupied + 1;
            priceToHostPpm = 1000000 * nightsToPay / nightsTotal;
        } else if (booking.cancellationPolicy == IBooking.CancellationPolicy.Strict) {
            priceToHostPpm = _now < booking.dateFrom - 5 * 24 * 60 * 60
                ? 0
                : (nightsTotal - (nightsTotal - nightsAlreadyOccupied) / 2) * 1000000;
        } else {// IBooking.CancellationPolicy.Soft
            priceToHostPpm = 1000000 * nightsAlreadyOccupied / nightsTotal;
        }
    }
    // -------------------------------------------------------------------------------------------------------
}