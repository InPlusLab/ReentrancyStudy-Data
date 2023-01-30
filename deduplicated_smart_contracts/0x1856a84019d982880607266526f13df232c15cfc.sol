/**
 *Submitted for verification at Etherscan.io on 2019-10-12
*/

pragma solidity >=0.5.6 <0.6.0;






/// @title ERC165Interface
/// @dev https://eips.ethereum.org/EIPS/eip-165
interface ERC165Interface {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///      uses less than 30,000 gas.
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// We use a contract and multiple inheritance to expose this constant.
// It's the best that Solidity offers at the moment.
contract DuelResolverInterfaceId {
    /// @notice The erc165 interface ID
    bytes4 internal constant _INTERFACE_ID_DUELRESOLVER = 0x41fc4f1e;
}

/// @notice An interface for contracts that resolve duels between Cheeze Wizards. Abstracting this out
///         into its own interface and instance allows for different tournaments to use
///         different duel mechanics while keeping the core tournament logic unchanged.
contract DuelResolverInterface is DuelResolverInterfaceId, ERC165Interface {
    /// @notice Indicates if the given move set is a valid input for this duel resolver.
    ///         It's important that this method is called before a move set is committed to
    ///         because resolveDuel() will abort if it the moves are invalid, making it
    ///         impossible to resolve the duel.
    function isValidMoveSet(bytes32 moveSet) public pure returns(bool);

    /// @notice Indicates that a particular affinity is a valid input for this duel resolver.
    ///         Should be called before a Wizard is entered into a tournament. As a rule, Wizard
    ///         Affinities don't change, so there's not point in checking for each duel.
    ///
    /// @dev    This method should _only_ return false for affinities that are
    ///         known to cause problems with your duel resolver. If your resolveDuel() function
    ///         can safely work with any affinity value (even if it just ignores the values that
    ///         it doesn't know about), it should return true.
    function isValidAffinity(uint256 affinity) external pure returns(bool);

    /// @notice Resolves the duel between two Cheeze Wizards given their chosen move sets, their
    ///         powers, and each Wizard's affinity. It is the responsibility of the Tournament contract
    ///         to ensure that ALL Wizards in a Tournament have an affinity value that is compatible with
    ///         the logic of this DuelResolver. It must also ensure that both move sets are valid before
    ///         those move sets are locked in, otherwise the duel can never be resolved!
    ///
    ///         Returns the amount of power to be transferred from the first Wizard to the second Wizard
    ///         (which will be a negative number if the second Wizard wins the duel), zero in the case of
    ///         a tie.
    /// @param moveSet1 The move set for the first Wizard. The interpretation and therefore valid
    ///                 values for this are determined by the individual duel resolver.
    /// @param moveSet2 The move set for the second Wizard.
    function resolveDuel(
        bytes32 moveSet1,
        bytes32 moveSet2,
        uint256 power1,
        uint256 power2,
        uint256 affinity1,
        uint256 affinity2)
        public pure returns(int256);
}



contract ThreeAffinityDuelResolver is DuelResolverInterface {
    /// @dev A bitmask that filters all but the bits that are significant as part of a valid move set for this
    /// duel resolver.
    bytes32 public constant MOVE_MASK = 0x0303030303000000000000000000000000000000000000000000000000000000;

    /// @dev The moves come in from the front end as 2, 3, and 4; the logic below is simpler if the valid
    /// moves are 0, 1, 2. Thus, we subtract 2 from each value to put things in the range that works well for us.
    /// See WizardConstants for the element values, to understand where 2, 3 and 4 come from.
    uint256 public constant MOVE_DELTA = 0x0202020202000000000000000000000000000000000000000000000000000000;

    /// @dev The relative weight applied to each round in the duel. We ramp up the weight as the duel progresses
    /// to make the later rounds more impactful, and to minimize the probability of a dead tie (which is super
    /// boring!)
    uint256 public constant WEIGHT_SUM = 78 + 79 + 81 + 86 + 100;

    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///      uses less than 30,000 gas.
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return
            interfaceId == this.supportsInterface.selector || // ERC165
            interfaceId == _INTERFACE_ID_DUELRESOLVER; // DuelResolverInterface
    }

    /// @notice Checks to see that the given move set is valid for the RPS game. Valid format is 5 set bytes followed by
    /// 27 zero bytes.  Each set byte can be 2, 3, or 4. All other values are rejected as invalid.
    /// @param moveSet the moveset to be validated
    function isValidMoveSet(bytes32 moveSet) public pure returns(bool) { // solium-disable-line security/no-assign-params
        // Map the input values 2, 3, 4 onto 0, 1, 2.
        moveSet = bytes32(uint256(moveSet) - MOVE_DELTA);

        // Fails if any bit is set outside the allowed mask
        if (moveSet != (moveSet & MOVE_MASK)) {
            return false;
        }

        // The previous line ensures that all values are 0, 1, 2, or 3, but
        // 3 isn’t actually valid. The following check ensures that no two
        // adjacent bits are set, which excludes any threes.
        if ((moveSet & (moveSet << 1)) != bytes32(0)) {
            return false;
        }

        return true;
    }

    /// @notice Any affinity value is acceptable with this resolver, we just safely ignore any affinities
    /// that don't match Fire, Air, or Water.
    function isValidAffinity(uint256) public pure returns(bool) {
        return true;
    }

    function resolveDuel(
        bytes32 moveSet1,
        bytes32 moveSet2,
        uint256 power1,
        uint256 power2,
        uint256 affinity1,
        uint256 affinity2)
        public pure returns(int256 power)
    {
        require(isValidMoveSet(moveSet1) && isValidMoveSet(moveSet2), "Invalid moveset");

        int256 score = _duelScore(moveSet1, moveSet2, affinity1, affinity2);
        power = _powerTransfer(score, power1, power2);
    }

    /// @notice Calculate the score for a duel. A positive score means the first wizard
    ///         won the match, a negative score means the second wizard won, and zero
    ///         means they tied (boooooring).
    /// @dev A NOTE ON VARIABLE NAMING: Throughout this file, you will find variables that end with
    /// Qn, where n is 6 or 10. This is used to indicate that these are fixed point fractional
    /// values, with a denominator of 64 (2^6) or 1024 (2^10). Wikipedia has a decent description
    /// of fixed-point arithmetic if you are unfamiliar (https://en.wikipedia.org/wiki/Fixed-point_arithmetic)
    // solium-disable-next-line security/no-assign-params
    function _duelScore(bytes32 moveSet1, bytes32 moveSet2, uint256 affinity1, uint256 affinity2) internal pure returns (int256 score) {
        // Although these values are essentially constants, we have to keep them
        // inside the function for it to be pure.
        int256[5] memory weights = [int256(78), int256(79), int256(81), int256(86), int256(100)];

        // Map the input values 2, 3, 4 onto 0, 1, 2 to make the calculations easier.
        moveSet1 = bytes32(uint256(moveSet1) - MOVE_DELTA);
        moveSet2 = bytes32(uint256(moveSet2) - MOVE_DELTA);
        affinity1 -= 2;
        affinity2 -= 2;

        for (uint256 i = 0; i < 5; i++) {
            // So this bit of casting is a bit weird. Subscripting a bytes32 value gives you a byte object,
            // which seems like something that could be cast into an integer. But the Solidity docs point out
            // that "byte" is actually just an alias for bytes1, which is more like an array type. What Solidity
            // does allow is a cast between a bytesX object and an integer of the same size, so we have to cast
            // to an 8-bit integer before we are allowed to cast to a full word. ¯\_(ツ)_/¯
            int256 move1 = int256(uint8(moveSet1[i]));
            int256 move2 = int256(uint8(moveSet2[i]));
            int256 diff = move1 - move2;

            if (diff == 0) {
                continue;
            }

            // Results in 1 if p1 beats p2, -1 if p2 beats p1
            // 1 (water) beats 0 (fire) = (1)  | 0 (fire) loses to 1 (water) = (-1)
            // 2 (wind) beats 1 (water) = (1)  | 1 (water) loses to 2 (wind) = (-1)
            // 0 (fire) beats 2 (wind)  = (-2) | 2 (wind) loses to 0 (fire)  = (2)
            if (diff*diff == 4) {
                diff = -(diff >> 1);
            }

            // Switch to a fixed-point math with a numerator of 100
            diff *= 100;

            // The result is 30% larger if the a wizard is playing their affinity
            // This effect can compound!
            if (move1 == int256(affinity1)) {
                diff = diff * 130 / 100;
            }

            if (move2 == int256(affinity2)) {
                diff = diff * 130 / 100;
            }

            score += diff * weights[i];
        }

        score /= 100;
    }

    /// @dev Returns the amount of power to be transferred from the first wizard to the second wizard. The value
    /// is negative if power is actually transferred from second to first.
    /// @param score The result of the RPS minigame, a positive score means the first wizard
    /// won the match, a negative score means the second wizard won.
    // solium-disable-next-line security/no-assign-params
    function _powerTransfer(int256 score, uint256 power1, uint256 power2) private pure returns(int256) {
        // if the score is negative, switch the positions of the wizards so that the rest of the
        // logic in this function only has to handle the case where the first wizard is the winner,
        // and the power transfer is positive. We do this before verifying the inputs so they
        // are not verified twice.
        if (score < 0) {
            return -_powerTransfer(-score, power2, power1);
        }

        // Cap the power of each player so the arithmetic cannot possibly overflow.
        require((power1 < (1<<245)) && power2 < (1<<245), "Invalid power value");

        // Wizard power values must be strictly positive or something has gone very wrong.
        require(power1 > 0 && power2 > 0, "Invalid power value");

        if (score == 0) {
            // Handle the simple case of a tie first
            return 0;
        }

        // From here on out in the function, we can assume that the first wizard is the winner, and the
        // power transfer will be > 0.

        // Convert the score into a number 0-1
        uint256 normalizedScoreQ10 = 1024 * uint256(score) / WEIGHT_SUM;

        // Because elemental wizards get a bonus (or penalty) when using their affinity spells, there is
        // a chance that the total score for an Elemental Wizard will exceed 100%. We cap it at 100%...
        if (normalizedScoreQ10 > 1024) {
            normalizedScoreQ10 = 1024;
        }

        // The base transfer ratio is the square root of the normalized score. We use our fakePow
        // function to get an approximation of the square root. x^(1/2) == sqrt(x)
        uint256 baseTransferRatioQ10 = _fakePowQ10(normalizedScoreQ10, 1024 * 1/2);

        // The base transfer ratio (BTR) is now, more or less, the inverse of the linearized probability
        // of the outcome. By "inverse probability", we mean the BTR will be small if the outcome was
        // quite likely (winning by a little), and large if the outcome was unlikely (winning by a lot).
        // By "linearized" we mean that if the outcome was twice as unlikely, the BTR will be doubled.
        // (Please don't ignore the phrase "more or less" here! The true probability distribution depends
        // on the wizard alignments and is close to a gaussian density curve. Approximating this curve
        // using a parabola makes it feasible to compute on-chain, and has an error term we can live with...)
        //
        // However, this BTR computed above is only appropriate in a "fair fight"; that is, when the
        // wizards have equal power. When one wizard has more power than the other, we have to do something
        // a bit different!
        //
        // The goal here is to keep the fight fair (in that neither the stronger nor weaker wizard has
        // a systemic advantage), but to have as much power as possible to be at stake for both wizards. This
        // seems like a paradox! If we're playing a symmetric game akin to RPS, and each player has the same
        // probability distribution for the outcomes, how can keep the match fair while having one player have
        // more value at risk?
        //
        // The answer is to "bend" the odds so that small wins (which are much more common) favour the stronger
        // wizard, since large wins will favour the weaker wizard. The math below is more magic than science (appropriate
        // for wizards, I suppose!), but has the impact that -- even though the stronger wizards has "more to
        // lose" -- the fight is still balanced. Most of the time, the winning margin will be small, and stronger
        // wizard will get a bigger reward than the weaker wizard would get from winning with the same margin.
        // BUT, if they win by a large enough margin, the weak wizard can drain a wizard even 7 times more powerful!
        //
        // We do cap the "at risk" power of the stronger wizard to 7x the weaker wizard, otherwise the
        // probability curves get WAAAAY out of whack (basically, the battle quickly devolves into an "all or
        // nothing" exchange with next to zero odds of winning anything for the weaker wizard).

        if (power2 > power1 * 7) {
            power2 = power1 * 7;
        } else if (power1 > power2 * 7) {
            power1 = power2 * 7;
        }

        // Use our power function to bend the curve to something very close to a zero EV for each player.
        uint256 transferRatioQ10 = _fakePowQ10(baseTransferRatioQ10, 1024 * power2 / power1);

        // Return the actual power transferred, which is determined as a fraction of the loser's power
        // in the preceding math.
        return int256((power2 * transferRatioQ10) >> 10);
    }

    /// @dev A function that approximates x^y, where x and y are fixed point values with a denominator
    /// of 1024 (10 bits). x must be in the range 0-1 (0-1024 as an int) and y can be any
    /// value > 1/128 (>8 as an int). For efficiency, y values are rounded to the nearest 1/64th
    /// (which seemed in our testing to be the sweet spot between accuracy and efficiency).
    ///
    /// This function will produce wholly accurate results for all integer powers (i.e.
    /// when y is a multiple of 1024 when viewed as an int), and will produce reasonable results
    /// when y has a fractional component. The error term on this approximation isn't tiny, but
    /// over the range 0-1 the errors tend to cancel out, which means the integral of the approximation
    /// is VERY close to the integral of the real power function. This is critical, because we use
    /// this approximation for determining the power transfer after a duel. This approximation can
    /// result in errors, but systemically - across a large number of fights - those errors will
    /// cancel out and result in a system very close to the expected equilibrium.
    ///
    /// tl;dr We fake the power function in a way that means that any error the approximation introduces
    /// is just as likely to help you as hurt you, while saving a butt-ton of gas.
    function _fakePowQ10(uint256 xQ10, uint256 yQ10) private pure returns(uint256) {

        // Round the y value to the nearest 1/64th, while also converting from
        // a denominator of 1024 to a denominator of 64.
        // Apologies for how unclear this is, but it makes for tighter code!
        // A more explicit version would look like this:
        //    float y = float(xQ10) / 1024.0;
        //    y = floor(y + 0.5);
        //    int xQ6 = int(y * 64);
        uint256 yQ6 = (yQ10 + 8) >> 4;

        // Call the recursive internal function to do that actual math
        return _fakePowInternal(xQ10, yQ6, 64, 5);
    }


    /// @dev An internal helper function for the fakePow function. X must be a value between 0-1
    /// expressed as a fixed point value with a denominator of 1024. numerator and denominator
    /// can be any integers. Returns the value x^(n/d).
    function _fakePowInternal(uint256 xQ10, uint256 numerator, uint256 denominator, uint256 iterations) private pure returns (uint256) {
        // Initialize the result to 1 (1024 is 1 in Q10)
        uint256 resultQ10 = 1024;

        // Grab the integer part of the exponent, which we can compute exactly
        uint256 integerExponent = numerator / denominator;

        // We have to be careful with overflow here. We know that x fits in 11 bits, because
        // we require x to be in the range 0-1. We also know that if x fits in n bits, then
        // x^y fits in n*y bits. So, any power <23 will safely fit into 256-bits. Any power
        // >= 23 might not! We can loop over powers >22 (which will be very rare!) and safely
        // compute them in chunks without overflow.
        while (integerExponent >= 22) {
            resultQ10 *= xQ10 ** 22;
            resultQ10 >>= 220; // back out the 22 extra multiples of 1024
            integerExponent -= 22;
        }

        // Handle any remaining integer part of the power function without the possibility
        // of overflow
        if (integerExponent > 0) {
            resultQ10 *= xQ10 ** integerExponent;
            resultQ10 >>= (integerExponent * 10);
        }

        uint256 fractionalExponent = numerator % denominator;

        // If we've run out of iterations, or there is no fractional part, we can
        // just return the value we've computed to this point.
        if ((iterations == 0) || (fractionalExponent == 0)) {
            return resultQ10;
        }

        // This is the magic, and -- I'll be honest -- I don't have much other than some
        // empirical testing to defend it. If we have a fractional power n/d, where n < d
        // we recursively call this function "flipping" everything. We flip the base value
        // x, by using 1-x. And we flip the fractional exponent and use d/n which will
        // result in a power > 1.  And then we flip the result again by using 1-result.
        //
        // The result is a value that is _quite close_ to x^(n/d), but is much cheaper to
        // to compute on a VM that only has an integer unit.
        resultQ10 *= (1024 - _fakePowInternal(1024 - xQ10, denominator, fractionalExponent, iterations - 1));

        return resultQ10 >> 10;
    }
}