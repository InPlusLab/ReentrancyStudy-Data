pragma solidity ^0.4.15;

library TreeLib {
  using IntervalLib for IntervalLib.Interval;
  using ListLib for ListLib.List;
  // TODO: remove need for redefinition here
  uint8 constant SEARCH_DONE = 0x00;
  uint8 constant SEARCH_EARLIER = 0x01;
  uint8 constant SEARCH_LATER = 0x10;

  bool constant TRAVERSED_EARLIER = false;
  bool constant TRAVERSED_LATER = true;

  struct Tree {
    // global table of intervals
    mapping (uint => IntervalLib.Interval) intervals;
    uint numIntervals;

    // tree nodes
    mapping (uint => Node) nodes;
    uint numNodes;

    // pointer to root of tree
    uint rootNode;
  }

  struct Node {
    uint earlier;
    uint later;

    ListLib.List intervals;
  }

  /*
   * adding intervals
   */
  function addInterval(Tree storage tree,
		       uint begin,
		       uint end,
		       bytes32 data)
    internal
  {
    uint intervalID = _createInterval(tree, begin, end, data);

    // if the tree is empty, create the root
    if (tree.rootNode == 0) {
      var nodeID = _createNode(tree);
      tree.rootNode = nodeID;

      tree.nodes[nodeID].intervals.add(begin, end, intervalID);

      return;
    }

    /*
     * depth-first search tree for place to add interval.
     * for each step of the search:
     *   if the new interval contains the current node&#39;s center:
     *     add interval to current node
     *     stop search
     *
     *   if the new interval < center:
     *     recurse "before"
     *   if the new interval > center:
     *     recurse "after"
     */
    uint curID = tree.rootNode;

    bool found = false;
    do {
      Node storage curNode = tree.nodes[curID];


      // track direction of recursion each step, to update correct pointer
      // upon needing to add a new node
      bool recurseDirection;

      if (end <= curNode.intervals.center) {
	// traverse before
	curID = curNode.earlier;
	recurseDirection = TRAVERSED_EARLIER;
      } else if (begin > curNode.intervals.center) {
	// traverse after
	curID = curNode.later;
	recurseDirection = TRAVERSED_LATER;
      } else {
	// found!
	found = true;
	break;
      }

      // if traversing yields null pointer for child node, must create
      if (curID == 0) {
	curID = _createNode(tree);

	// update appropriate pointer
	if (recurseDirection == TRAVERSED_EARLIER) {
	  curNode.earlier = curID;
	} else {
	  curNode.later = curID;
	}

	// creating a new node means we&#39;ve found the place to put the interval
	found = true;
      }
    } while (!found);

    tree.nodes[curID].intervals.add(begin, end, intervalID);
  }

  /*
   * retrieval
   */
  function getInterval(Tree storage tree, uint intervalID)
    constant
    internal
    returns (uint begin, uint end, bytes32 data)
  {
    require(intervalID > 0 && intervalID <= tree.numIntervals);

    var interval = tree.intervals[intervalID];
    return (interval.begin, interval.end, interval.data);
  }

  /*
   * searching
   */
  function search(Tree storage tree, uint point)
    constant
    internal
    returns (uint[] memory intervalIDs)
  {
    // can&#39;t search empty trees
    require(tree.rootNode != 0x0);

    // HACK repeatedly mallocs new arrays of matching interval IDs
    intervalIDs = new uint[](0);
    uint[] memory tempIDs;
    uint[] memory matchingIDs;
    uint i;  // for list copying loops

    /*
     * search traversal
     *
     * starting at root node
     */
    uint curID = tree.rootNode;
    uint8 searchNext;
    do {
      Node storage curNode = tree.nodes[curID];

      /*
       * search current node
       */
      (matchingIDs, searchNext) = curNode.intervals.matching(point);

      /*
       * add matching intervals to results array
       *
       * allocate temp array and copy in both prior and new matches
       */
      if (matchingIDs.length > 0) {
	tempIDs = new uint[](intervalIDs.length + matchingIDs.length);
	for (i = 0; i < intervalIDs.length; i++) {
	  tempIDs[i] = intervalIDs[i];
	}
	for (i = 0; i < matchingIDs.length; i++) {
	  tempIDs[i + intervalIDs.length] = matchingIDs[i];
	}
	intervalIDs = tempIDs;
      }

      /*
       * recurse according to node search results
       */
      if (searchNext == SEARCH_EARLIER) {
	curID = curNode.earlier;
      } else if (searchNext == SEARCH_LATER) { // SEARCH_LATER
	curID = curNode.later;
      }
    } while (searchNext != SEARCH_DONE && curID != 0x0);
  }


  /*
   * data create helpers helpers
   */
  function _createInterval(Tree storage tree, uint begin, uint end, bytes32 data)
    internal
    returns (uint intervalID)
  {
    intervalID = ++tree.numIntervals;

    tree.intervals[intervalID] = IntervalLib.Interval({
      begin: begin,
      end: end,
      data: data
    });
  }

  function _createNode(Tree storage tree) returns (uint nodeID) {
    nodeID = ++tree.numNodes;
    tree.nodes[nodeID] = Node({
      earlier: 0,
      later: 0,
      intervals: ListLib.createNew(nodeID)
    });
  }
}

library IntervalLib {
  struct Interval {
    uint begin;
    uint end;
    bytes32 data;
  }
}

library GroveLib {
        /*
         *  Indexes for ordered data
         *
         *  Address: 0x7c1eb207c07e7ab13cf245585bd03d0fa478d034
         */
        struct Index {
                bytes32 root;
                mapping (bytes32 => Node) nodes;
        }

        struct Node {
                bytes32 id;
                int value;
                bytes32 parent;
                bytes32 left;
                bytes32 right;
                uint height;
        }

        function max(uint a, uint b) internal returns (uint) {
            if (a >= b) {
                return a;
            }
            return b;
        }

        /*
         *  Node getters
         */
        /// @dev Retrieve the unique identifier for the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeId(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].id;
        }

        /// @dev Retrieve the value for the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeValue(Index storage index, bytes32 id) constant returns (int) {
            return index.nodes[id].value;
        }

        /// @dev Retrieve the height of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeHeight(Index storage index, bytes32 id) constant returns (uint) {
            return index.nodes[id].height;
        }

        /// @dev Retrieve the parent id of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeParent(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].parent;
        }

        /// @dev Retrieve the left child id of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeLeftChild(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].left;
        }

        /// @dev Retrieve the right child id of the node.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNodeRightChild(Index storage index, bytes32 id) constant returns (bytes32) {
            return index.nodes[id].right;
        }

        /// @dev Retrieve the node id of the next node in the tree.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getPreviousNode(Index storage index, bytes32 id) constant returns (bytes32) {
            Node storage currentNode = index.nodes[id];

            if (currentNode.id == 0x0) {
                // Unknown node, just return 0x0;
                return 0x0;
            }

            Node memory child;

            if (currentNode.left != 0x0) {
                // Trace left to latest child in left tree.
                child = index.nodes[currentNode.left];

                while (child.right != 0) {
                    child = index.nodes[child.right];
                }
                return child.id;
            }

            if (currentNode.parent != 0x0) {
                // Now we trace back up through parent relationships, looking
                // for a link where the child is the right child of it&#39;s
                // parent.
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.right == child.id) {
                        return parent.id;
                    }

                    if (parent.parent == 0x0) {
                        break;
                    }
                    child = parent;
                    parent = index.nodes[parent.parent];
                }
            }

            // This is the first node, and has no previous node.
            return 0x0;
        }

        /// @dev Retrieve the node id of the previous node in the tree.
        /// @param index The index that the node is part of.
        /// @param id The id for the node to be looked up.
        function getNextNode(Index storage index, bytes32 id) constant returns (bytes32) {
            Node storage currentNode = index.nodes[id];

            if (currentNode.id == 0x0) {
                // Unknown node, just return 0x0;
                return 0x0;
            }

            Node memory child;

            if (currentNode.right != 0x0) {
                // Trace right to earliest child in right tree.
                child = index.nodes[currentNode.right];

                while (child.left != 0) {
                    child = index.nodes[child.left];
                }
                return child.id;
            }

            if (currentNode.parent != 0x0) {
                // if the node is the left child of it&#39;s parent, then the
                // parent is the next one.
                Node storage parent = index.nodes[currentNode.parent];
                child = currentNode;

                while (true) {
                    if (parent.left == child.id) {
                        return parent.id;
                    }

                    if (parent.parent == 0x0) {
                        break;
                    }
                    child = parent;
                    parent = index.nodes[parent.parent];
                }

                // Now we need to trace all the way up checking to see if any parent is the
            }

            // This is the final node.
            return 0x0;
        }


        /// @dev Updates or Inserts the id into the index at its appropriate location based on the value provided.
        /// @param index The index that the node is part of.
        /// @param id The unique identifier of the data element the index node will represent.
        /// @param value The value of the data element that represents it&#39;s total ordering with respect to other elementes.
        function insert(Index storage index, bytes32 id, int value) public {
                if (index.nodes[id].id == id) {
                    // A node with this id already exists.  If the value is
                    // the same, then just return early, otherwise, remove it
                    // and reinsert it.
                    if (index.nodes[id].value == value) {
                        return;
                    }
                    remove(index, id);
                }

                bytes32 previousNodeId = 0x0;

                if (index.root == 0x0) {
                    index.root = id;
                }
                Node storage currentNode = index.nodes[index.root];

                // Do insertion
                while (true) {
                    if (currentNode.id == 0x0) {
                        // This is a new unpopulated node.
                        currentNode.id = id;
                        currentNode.parent = previousNodeId;
                        currentNode.value = value;
                        break;
                    }

                    // Set the previous node id.
                    previousNodeId = currentNode.id;

                    // The new node belongs in the right subtree
                    if (value >= currentNode.value) {
                        if (currentNode.right == 0x0) {
                            currentNode.right = id;
                        }
                        currentNode = index.nodes[currentNode.right];
                        continue;
                    }

                    // The new node belongs in the left subtree.
                    if (currentNode.left == 0x0) {
                        currentNode.left = id;
                    }
                    currentNode = index.nodes[currentNode.left];
                }

                // Rebalance the tree
                _rebalanceTree(index, currentNode.id);
        }

        /// @dev Checks whether a node for the given unique identifier exists within the given index.
        /// @param index The index that should be searched
        /// @param id The unique identifier of the data element to check for.
        function exists(Index storage index, bytes32 id) constant returns (bool) {
            return (index.nodes[id].height > 0);
        }

        /// @dev Remove the node for the given unique identifier from the index.
        /// @param index The index that should be removed
        /// @param id The unique identifier of the data element to remove.
        function remove(Index storage index, bytes32 id) public {
            bytes32 rebalanceOrigin;

            Node storage nodeToDelete = index.nodes[id];

            if (nodeToDelete.id != id) {
                // The id does not exist in the tree.
                return;
            }

            if (nodeToDelete.left != 0x0 || nodeToDelete.right != 0x0) {
                // This node is not a leaf node and thus must replace itself in
                // it&#39;s tree by either the previous or next node.
                if (nodeToDelete.left != 0x0) {
                    // This node is guaranteed to not have a right child.
                    Node storage replacementNode = index.nodes[getPreviousNode(index, nodeToDelete.id)];
                }
                else {
                    // This node is guaranteed to not have a left child.
                    replacementNode = index.nodes[getNextNode(index, nodeToDelete.id)];
                }
                // The replacementNode is guaranteed to have a parent.
                Node storage parent = index.nodes[replacementNode.parent];

                // Keep note of the location that our tree rebalancing should
                // start at.
                rebalanceOrigin = replacementNode.id;

                // Join the parent of the replacement node with any subtree of
                // the replacement node.  We can guarantee that the replacement
                // node has at most one subtree because of how getNextNode and
                // getPreviousNode are used.
                if (parent.left == replacementNode.id) {
                    parent.left = replacementNode.right;
                    if (replacementNode.right != 0x0) {
                        Node storage child = index.nodes[replacementNode.right];
                        child.parent = parent.id;
                    }
                }
                if (parent.right == replacementNode.id) {
                    parent.right = replacementNode.left;
                    if (replacementNode.left != 0x0) {
                        child = index.nodes[replacementNode.left];
                        child.parent = parent.id;
                    }
                }

                // Now we replace the nodeToDelete with the replacementNode.
                // This includes parent/child relationships for all of the
                // parent, the left child, and the right child.
                replacementNode.parent = nodeToDelete.parent;
                if (nodeToDelete.parent != 0x0) {
                    parent = index.nodes[nodeToDelete.parent];
                    if (parent.left == nodeToDelete.id) {
                        parent.left = replacementNode.id;
                    }
                    if (parent.right == nodeToDelete.id) {
                        parent.right = replacementNode.id;
                    }
                }
                else {
                    // If the node we are deleting is the root node update the
                    // index root node pointer.
                    index.root = replacementNode.id;
                }

                replacementNode.left = nodeToDelete.left;
                if (nodeToDelete.left != 0x0) {
                    child = index.nodes[nodeToDelete.left];
                    child.parent = replacementNode.id;
                }

                replacementNode.right = nodeToDelete.right;
                if (nodeToDelete.right != 0x0) {
                    child = index.nodes[nodeToDelete.right];
                    child.parent = replacementNode.id;
                }
            }
            else if (nodeToDelete.parent != 0x0) {
                // The node being deleted is a leaf node so we only erase it&#39;s
                // parent linkage.
                parent = index.nodes[nodeToDelete.parent];

                if (parent.left == nodeToDelete.id) {
                    parent.left = 0x0;
                }
                if (parent.right == nodeToDelete.id) {
                    parent.right = 0x0;
                }

                // keep note of where the rebalancing should begin.
                rebalanceOrigin = parent.id;
            }
            else {
                // This is both a leaf node and the root node, so we need to
                // unset the root node pointer.
                index.root = 0x0;
            }

            // Now we zero out all of the fields on the nodeToDelete.
            nodeToDelete.id = 0x0;
            nodeToDelete.value = 0;
            nodeToDelete.parent = 0x0;
            nodeToDelete.left = 0x0;
            nodeToDelete.right = 0x0;
            nodeToDelete.height = 0;

            // Walk back up the tree rebalancing
            if (rebalanceOrigin != 0x0) {
                _rebalanceTree(index, rebalanceOrigin);
            }
        }

        bytes2 constant GT = ">";
        bytes2 constant LT = "<";
        bytes2 constant GTE = ">=";
        bytes2 constant LTE = "<=";
        bytes2 constant EQ = "==";

        function _compare(int left, bytes2 operator, int right) internal returns (bool) {
            require(
                operator == GT || operator == LT || operator == GTE ||
                operator == LTE || operator == EQ
            );

            if (operator == GT) {
                return (left > right);
            }
            if (operator == LT) {
                return (left < right);
            }
            if (operator == GTE) {
                return (left >= right);
            }
            if (operator == LTE) {
                return (left <= right);
            }
            if (operator == EQ) {
                return (left == right);
            }
        }

        function _getMaximum(Index storage index, bytes32 id) internal returns (int) {
                Node storage currentNode = index.nodes[id];

                while (true) {
                    if (currentNode.right == 0x0) {
                        return currentNode.value;
                    }
                    currentNode = index.nodes[currentNode.right];
                }
        }

        function _getMinimum(Index storage index, bytes32 id) internal returns (int) {
                Node storage currentNode = index.nodes[id];

                while (true) {
                    if (currentNode.left == 0x0) {
                        return currentNode.value;
                    }
                    currentNode = index.nodes[currentNode.left];
                }
        }


        /** @dev Query the index for the edge-most node that satisfies the
         *  given query.  For >, >=, and ==, this will be the left-most node
         *  that satisfies the comparison.  For < and <= this will be the
         *  right-most node that satisfies the comparison.
         */
        /// @param index The index that should be queried
        /** @param operator One of &#39;>&#39;, &#39;>=&#39;, &#39;<&#39;, &#39;<=&#39;, &#39;==&#39; to specify what
         *  type of comparison operator should be used.
         */
        function query(Index storage index, bytes2 operator, int value) public returns (bytes32) {
                bytes32 rootNodeId = index.root;

                if (rootNodeId == 0x0) {
                    // Empty tree.
                    return 0x0;
                }

                Node storage currentNode = index.nodes[rootNodeId];

                while (true) {
                    if (_compare(currentNode.value, operator, value)) {
                        // We have found a match but it might not be the
                        // *correct* match.
                        if ((operator == LT) || (operator == LTE)) {
                            // Need to keep traversing right until this is no
                            // longer true.
                            if (currentNode.right == 0x0) {
                                return currentNode.id;
                            }
                            if (_compare(_getMinimum(index, currentNode.right), operator, value)) {
                                // There are still nodes to the right that
                                // match.
                                currentNode = index.nodes[currentNode.right];
                                continue;
                            }
                            return currentNode.id;
                        }

                        if ((operator == GT) || (operator == GTE) || (operator == EQ)) {
                            // Need to keep traversing left until this is no
                            // longer true.
                            if (currentNode.left == 0x0) {
                                return currentNode.id;
                            }
                            if (_compare(_getMaximum(index, currentNode.left), operator, value)) {
                                currentNode = index.nodes[currentNode.left];
                                continue;
                            }
                            return currentNode.id;
                        }
                    }

                    if ((operator == LT) || (operator == LTE)) {
                        if (currentNode.left == 0x0) {
                            // There are no nodes that are less than the value
                            // so return null.
                            return 0x0;
                        }
                        currentNode = index.nodes[currentNode.left];
                        continue;
                    }

                    if ((operator == GT) || (operator == GTE)) {
                        if (currentNode.right == 0x0) {
                            // There are no nodes that are greater than the value
                            // so return null.
                            return 0x0;
                        }
                        currentNode = index.nodes[currentNode.right];
                        continue;
                    }

                    if (operator == EQ) {
                        if (currentNode.value < value) {
                            if (currentNode.right == 0x0) {
                                return 0x0;
                            }
                            currentNode = index.nodes[currentNode.right];
                            continue;
                        }

                        if (currentNode.value > value) {
                            if (currentNode.left == 0x0) {
                                return 0x0;
                            }
                            currentNode = index.nodes[currentNode.left];
                            continue;
                        }
                    }
                }
        }

        function _rebalanceTree(Index storage index, bytes32 id) internal {
            // Trace back up rebalancing the tree and updating heights as
            // needed..
            Node storage currentNode = index.nodes[id];

            while (true) {
                int balanceFactor = _getBalanceFactor(index, currentNode.id);

                if (balanceFactor == 2) {
                    // Right rotation (tree is heavy on the left)
                    if (_getBalanceFactor(index, currentNode.left) == -1) {
                        // The subtree is leaning right so it need to be
                        // rotated left before the current node is rotated
                        // right.
                        _rotateLeft(index, currentNode.left);
                    }
                    _rotateRight(index, currentNode.id);
                }

                if (balanceFactor == -2) {
                    // Left rotation (tree is heavy on the right)
                    if (_getBalanceFactor(index, currentNode.right) == 1) {
                        // The subtree is leaning left so it need to be
                        // rotated right before the current node is rotated
                        // left.
                        _rotateRight(index, currentNode.right);
                    }
                    _rotateLeft(index, currentNode.id);
                }

                if ((-1 <= balanceFactor) && (balanceFactor <= 1)) {
                    _updateNodeHeight(index, currentNode.id);
                }

                if (currentNode.parent == 0x0) {
                    // Reached the root which may be new due to tree
                    // rotation, so set it as the root and then break.
                    break;
                }

                currentNode = index.nodes[currentNode.parent];
            }
        }

        function _getBalanceFactor(Index storage index, bytes32 id) internal returns (int) {
                Node storage node = index.nodes[id];

                return int(index.nodes[node.left].height) - int(index.nodes[node.right].height);
        }

        function _updateNodeHeight(Index storage index, bytes32 id) internal {
                Node storage node = index.nodes[id];

                node.height = max(index.nodes[node.left].height, index.nodes[node.right].height) + 1;
        }

        function _rotateLeft(Index storage index, bytes32 id) internal {
            Node storage originalRoot = index.nodes[id];

            // Cannot rotate left if there is no right originalRoot to rotate into
            // place.
            assert(originalRoot.right != 0x0);

            // The right child is the new root, so it gets the original
            // `originalRoot.parent` as it&#39;s parent.
            Node storage newRoot = index.nodes[originalRoot.right];
            newRoot.parent = originalRoot.parent;

            // The original root needs to have it&#39;s right child nulled out.
            originalRoot.right = 0x0;

            if (originalRoot.parent != 0x0) {
                // If there is a parent node, it needs to now point downward at
                // the newRoot which is rotating into the place where `node` was.
                Node storage parent = index.nodes[originalRoot.parent];

                // figure out if we&#39;re a left or right child and have the
                // parent point to the new node.
                if (parent.left == originalRoot.id) {
                    parent.left = newRoot.id;
                }
                if (parent.right == originalRoot.id) {
                    parent.right = newRoot.id;
                }
            }


            if (newRoot.left != 0) {
                // If the new root had a left child, that moves to be the
                // new right child of the original root node
                Node storage leftChild = index.nodes[newRoot.left];
                originalRoot.right = leftChild.id;
                leftChild.parent = originalRoot.id;
            }

            // Update the newRoot&#39;s left node to point at the original node.
            originalRoot.parent = newRoot.id;
            newRoot.left = originalRoot.id;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.id;
            }

            // TODO: are both of these updates necessary?
            _updateNodeHeight(index, originalRoot.id);
            _updateNodeHeight(index, newRoot.id);
        }

        function _rotateRight(Index storage index, bytes32 id) internal {
            Node storage originalRoot = index.nodes[id];

            // Cannot rotate right if there is no left node to rotate into
            // place.
            assert(originalRoot.left != 0x0);

            // The left child is taking the place of node, so we update it&#39;s
            // parent to be the original parent of the node.
            Node storage newRoot = index.nodes[originalRoot.left];
            newRoot.parent = originalRoot.parent;

            // Null out the originalRoot.left
            originalRoot.left = 0x0;

            if (originalRoot.parent != 0x0) {
                // If the node has a parent, update the correct child to point
                // at the newRoot now.
                Node storage parent = index.nodes[originalRoot.parent];

                if (parent.left == originalRoot.id) {
                    parent.left = newRoot.id;
                }
                if (parent.right == originalRoot.id) {
                    parent.right = newRoot.id;
                }
            }

            if (newRoot.right != 0x0) {
                Node storage rightChild = index.nodes[newRoot.right];
                originalRoot.left = newRoot.right;
                rightChild.parent = originalRoot.id;
            }

            // Update the new root&#39;s right node to point to the original node.
            originalRoot.parent = newRoot.id;
            newRoot.right = originalRoot.id;

            if (newRoot.parent == 0x0) {
                index.root = newRoot.id;
            }

            // Recompute heights.
            _updateNodeHeight(index, originalRoot.id);
            _updateNodeHeight(index, newRoot.id);
        }
}

library ListLib {
  uint8 constant SEARCH_DONE = 0x00;
  uint8 constant SEARCH_EARLIER = 0x01;
  uint8 constant SEARCH_LATER = 0x10;

  using GroveLib for GroveLib.Index;
  using IntervalLib for IntervalLib.Interval;

  struct List {
    uint length;
    uint center;

    // maps item ID to items
    mapping (uint => IntervalLib.Interval) items;

    GroveLib.Index beginIndex;
    GroveLib.Index endIndex;
    bytes32 lowestBegin;
    bytes32 highestEnd;
  }

  function createNew()
    internal
    returns (List)
  {
    return createNew(block.number);
  }

  function createNew(uint id)
    internal
    returns (List)
  {
    return List({
      length: 0,
      center: 0xDEADBEEF,
      lowestBegin: 0x0,
      highestEnd: 0x0,
      beginIndex: GroveLib.Index(sha3(this, bytes32(id * 2))),
      endIndex: GroveLib.Index(sha3(this, bytes32(id * 2 + 1)))
    });
  }

  function add(List storage list, uint begin, uint end, uint intervalID) internal {
    var _intervalID = bytes32(intervalID);
    var _begin = _getBeginIndexKey(begin);
    var _end = _getEndIndexKey(end);

    list.beginIndex.insert(_intervalID, _begin);
    list.endIndex.insert(_intervalID, _end);
    list.length++;

    if (list.length == 1) {
      list.lowestBegin = list.beginIndex.root;
      list.highestEnd = list.endIndex.root;
      list.center = begin + (end - begin) / 2;

      return;
    }

    var newLowest = list.beginIndex.getPreviousNode(list.lowestBegin);
    if (newLowest != 0x0) {
      list.lowestBegin = newLowest;
    }

    var newHighest = list.endIndex.getNextNode(list.highestEnd);
    if (newHighest != 0x0) {
      list.highestEnd = newHighest;
    }
  }

  /*
   * @dev Searches interval list for:
   *   - matching intervals
   *   - information on how search should proceed
   * @param node The node to search
   * @param point The point to search for
   */
  function matching(List storage list, uint point)
    constant
    internal
    returns (uint[] memory intervalIDs, uint8 searchNext)
  {
    uint[] memory _intervalIDs = new uint[](list.length);
    uint num = 0;

    bytes32 cur;

    if (point == list.center) {
      /*
       * case: point exactly matches the list&#39;s center
       *
       * collect (all) matching intervals (every interval in list, by def)
       */
      cur = list.lowestBegin;
      while (cur != 0x0) {
	_intervalIDs[num] = uint(list.beginIndex.getNodeId(cur));
	num++;
	cur = _next(list, cur);
      }

      /*
       * search is done:
       * no other nodes in tree have intervals containing point
       */
      searchNext = SEARCH_DONE;
    } else if (point < list.center) {
      /*
       * case: point is earlier than center.
       *
       *
       * collect matching intervals.
       *
       * shortcut:
       *
       *   starting with lowest beginning interval, search sorted begin list
       *   until begin is later than point
       *
       *	       point
       *                 :
       *                 :   center
       *                 :     |
       *        (0) *----:-----|----------o
       *        (1)    *-:-----|---o
       *        (-)      x *---|------o
       *        (-)         *--|--o
       *        (-)          *-|----o
       *
       *
       *    this works because intervals contained in an interval list are
       *    guaranteed tocontain `center`
       */
      cur = list.lowestBegin;
      while (cur != 0x0) {
	uint begin = _begin(list, cur);
	if (begin > point) {
	  break;
	}

	_intervalIDs[num] = uint(list.beginIndex.getNodeId(cur));
	num++;

	cur = _next(list, cur);
      }

      /*
       * search should proceed to earlier
       */
      searchNext = SEARCH_EARLIER;
    } else if (point > list.center) {
      /*
       * case: point is later than center.
       *
       *
       * collect matching intervals.
       *
       * shortcut:
       *
       *   starting with highest ending interval, search sorted end list
       *   until end is earlier than or equal to point
       *
       *			    point
       *			    :
       *                     center :
       *                       |    :
       *            *----------|----:-----o (0)
       *                   *---|----:-o     (1)
       *                     *-|----o	    (not matching, done.)
       *               *-------|---o	    (-)
       *                    *--|--o	    (-)
       *
       *
       *    this works because intervals contained in an interval list are
       *    guaranteed to contain `center`
       */
      cur = list.highestEnd;
      while (cur != 0x0) {
	uint end = _end(list, cur);
	if (end <= point) {
	  break;
	}

	_intervalIDs[num] = uint(list.endIndex.getNodeId(cur));
	num++;

	cur = _previous(list, cur);
      }

      /*
       * search proceeds to later intervals
       */
      searchNext = SEARCH_LATER;
    }

    /*
     * return correctly-sized array of intervalIDs
     */
    if (num == _intervalIDs.length) {
      intervalIDs = _intervalIDs;
    } else {
      intervalIDs = new uint[](num);
      for (uint i = 0; i < num; i++) {
	intervalIDs[i] = _intervalIDs[i];
      }
    }
  }

  /*
   * Grove linked list traversal
   */
  function _begin(List storage list, bytes32 indexNode) constant internal returns (uint) {
    return _getBegin(list.beginIndex.getNodeValue(indexNode));
  }

  function _end(List storage list, bytes32 indexNode) constant internal returns (uint) {
    return _getEnd(list.endIndex.getNodeValue(indexNode));
  }

  function _next(List storage list, bytes32 cur) constant internal returns (bytes32) {
    return list.beginIndex.getNextNode(cur);
  }

  function _previous(List storage list, bytes32 cur) constant internal returns (bytes32) {
    return list.endIndex.getPreviousNode(cur);
  }

  /*
   * uint / int conversions for Grove nodeIDs
   */
  function _getBeginIndexKey(uint begin) constant internal returns (int) {
    // convert to signed int in order-preserving manner
    return int(begin - 0x8000000000000000000000000000000000000000000000000000000000000000);
  }

  function _getEndIndexKey(uint end) constant internal returns (int) {
    // convert to signed int in order-preserving manner
    return int(end - 0x8000000000000000000000000000000000000000000000000000000000000000);
  }

  function _getBegin(int beginIndexKey) constant internal returns (uint) {
    // convert to unsigned int in order-preserving manner
    return uint(beginIndexKey) + 0x8000000000000000000000000000000000000000000000000000000000000000;
  }

  function _getEnd(int endIndexKey) constant internal returns (uint) {
    // convert to unsigned int in order-preserving manner
    return uint(endIndexKey) + 0x8000000000000000000000000000000000000000000000000000000000000000;
  }
}