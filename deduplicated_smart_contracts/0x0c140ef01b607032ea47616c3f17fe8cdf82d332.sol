/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.24;



/**

 * @title EnumerableSet256

 * @dev Library containing logic for an enumerable set of uint256 values -- supports checking for presence, adding,

 * removing elements, and enumerating elements (without preserving order between mutable operations).

 */

library EnumerableSet256 {



    struct Data {

        uint256[] elements;

        mapping(uint256 => uint256) elementToIndex;

    }



    /**

     * @dev Returns whether the set contains a given element

     *

     * @param self Data storage Reference to set data

     * @param value uint256 Value being checked for existence

     * @return bool

     */

    function contains(Data storage self, uint256 value) external view returns (bool) {

        uint256 mappingIndex = self.elementToIndex[value];

        return (mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value);

    }



    /**

     * @dev Adds a new element to the set.  Element must not belong to set yet.

     *

     * @param self Data storage Reference to set data

     * @param value uint256 Value being added

     */

    function add(Data storage self, uint256 value) external {

        uint256 mappingIndex = self.elementToIndex[value];

        require(!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value)));



        self.elementToIndex[value] = uint256(self.elements.length);

        self.elements.push(value);

    }



    /**

     * @dev Removes an element from the set.  Element must already belong to set yet.

     *

     * @param self Data storage Reference to set data

     * @param value uint256 Value being added

     */

    function remove(Data storage self, uint256 value) external {

        uint256 currentElementIndex = self.elementToIndex[value];

        require((currentElementIndex < self.elements.length) && (self.elements[currentElementIndex] == value));



        uint256 lastElementIndex = uint256(self.elements.length - 1);

        uint256 lastElement = self.elements[lastElementIndex];



        self.elements[currentElementIndex] = lastElement;

        self.elements[lastElementIndex] = 0;

        self.elements.length--;



        self.elementToIndex[lastElement] = currentElementIndex;

        self.elementToIndex[value] = 0;

    }



    /**

     * @dev Gets the number of elements on the set.

     *

     * @param self Data storage Reference to set data

     * @return uint256

     */

    function size(Data storage self) external view returns (uint256) {

        return uint256(self.elements.length);

    }



    /**

     * @dev Gets the N-th element from the set, 0-indexed.  Note that the ordering is not necessarily consistent

     * before and after add, remove operations.

     *

     * @param self Data storage Reference to set data

     * @param index uint256 0-indexed position of the element being queried

     * @return uint256

     */

    function get(Data storage self, uint256 index) external view returns (uint256) {

        return self.elements[index];

    }



    /**

     * @dev Mark the set as empty (not containing any further elements).

     *

     * @param self Data storage Reference to set data

     */

    function clear(Data storage self) external {

        self.elements.length = 0;

    }

}