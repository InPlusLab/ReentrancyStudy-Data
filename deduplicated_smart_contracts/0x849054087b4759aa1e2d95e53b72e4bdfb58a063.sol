/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.24;



/**

 * @title URIDistribution

 * @dev Library responsible for maintaining a weighted distribution of URIs

 */

library URIDistribution {



    struct Data {

        uint16[] cumulativeWeights;

        mapping(uint16 => string) uris;

    }



    /**

     * @dev Adds a URI to the distribution, with a given weight

     *

     * @param self Data storage Distribution data reference

     * @param weight uint16 Relative distribution weight

     * @param uri string URI to be stored

     */

    function addURI(Data storage self, uint16 weight, string uri) external {

        if (weight == 0) return;



        if (self.cumulativeWeights.length == 0) {

            self.cumulativeWeights.push(weight);

        } else {

            self.cumulativeWeights.push(self.cumulativeWeights[uint16(self.cumulativeWeights.length - 1)] + weight);

        }

        self.uris[uint16(self.cumulativeWeights.length - 1)] = uri;

    }



    /**

     * @dev Gets an URI from the distribution, with the given random seed

     *

     * @param self Data storage Distribution data reference

     * @param seed uint64

     * @return string

     */

    function getURI(Data storage self, uint64 seed) external view returns (string) {

        uint16 n = uint16(self.cumulativeWeights.length);

        uint16 modSeed = uint16(seed % uint64(self.cumulativeWeights[n - 1]));



        uint16 left = 0;

        uint16 right = n;

        uint16 mid;



        while (left < right) {

            mid = uint16((uint24(left) + uint24(right)) / 2);

            if (self.cumulativeWeights[mid] <= modSeed) {

                left = mid + 1;

            } else {

                right = mid;

            }

        }

        return self.uris[left];

    }

}