/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.24;



/**

 * @title EnumerableSetAddress

 * @dev Library containing logic for an enumerable set of address values -- supports checking for presence, adding,

 * removing elements, and enumerating elements (without preserving order between mutable operations).

 */

library EnumerableSetAddress {



    struct Data {

        address[] elements;

        mapping(address => uint160) elementToIndex;

    }



    /**

     * @dev Returns whether the set contains a given element

     *

     * @param self Data storage Reference to set data

     * @param value address Value being checked for existence

     * @return bool

     */

    function contains(Data storage self, address value) external view returns (bool) {

        uint160 mappingIndex = self.elementToIndex[value];

        return (mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value);

    }



    /**

     * @dev Adds a new element to the set.  Element must not belong to set yet.

     *

     * @param self Data storage Reference to set data

     * @param value address Value being added

     */

    function add(Data storage self, address value) external {

        uint160 mappingIndex = self.elementToIndex[value];

        require(!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value)));



        self.elementToIndex[value] = uint160(self.elements.length);

        self.elements.push(value);

    }



    /**

     * @dev Removes an element from the set.  Element must already belong to set.

     *

     * @param self Data storage Reference to set data

     * @param value address Value being removed

     */

    function remove(Data storage self, address value) external {

        uint160 currentElementIndex = self.elementToIndex[value];

        require((currentElementIndex < self.elements.length) && (self.elements[currentElementIndex] == value));



        uint160 lastElementIndex = uint160(self.elements.length - 1);

        address lastElement = self.elements[lastElementIndex];



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

     * @return uint160

     */

    function size(Data storage self) external view returns (uint160) {

        return uint160(self.elements.length);

    }



    /**

     * @dev Gets the N-th element from the set, 0-indexed.  Note that the ordering is not necessarily consistent

     * before and after add, remove operations.

     *

     * @param self Data storage Reference to set data

     * @param index uint160 0-indexed position of the element being queried

     * @return address

     */

    function get(Data storage self, uint160 index) external view returns (address) {

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



    /**

     * @dev Copy all data from a source set to a target set

     *

     * @param source Data storage Reference to source data

     * @param target Data storage Reference to target data

     */

    function copy(Data storage source, Data storage target) external {

        uint160 numElements = uint160(source.elements.length);



        target.elements.length = numElements;

        for (uint160 index = 0; index < numElements; index++) {

            address element = source.elements[index];

            target.elements[index] = element;

            target.elementToIndex[element] = index;

        }

    }



    /**

     * @dev Adds all elements from another set into this set, if they are not already present

     *

     * @param self Data storage Reference to set being edited

     * @param other Data storage Reference to set items are being added from

     */

    function addAll(Data storage self, Data storage other) external {

        uint160 numElements = uint160(other.elements.length);



        for (uint160 index = 0; index < numElements; index++) {

            address value = other.elements[index];



            uint160 mappingIndex = self.elementToIndex[value];

            if (!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value))) {

                self.elementToIndex[value] = uint160(self.elements.length);

                self.elements.push(value);

            }

        }

    }



}