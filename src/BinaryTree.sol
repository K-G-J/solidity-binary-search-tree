//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title BinaryTree
 * @dev This contract implements a Binary Search Tree data structure.
 *
 * A Binary Search Tree (BST) is a node-based binary tree data structure that has the following properties:
 * The left subtree of a node contains only nodes with values less than the node’s value.
 * The right subtree of a node contains only nodes with valuess greater than the node’s value.
 * Both the left and right subtrees must also be Binary Search Trees.
 *
 * For this implementation, duplicate values will be allowed, and nodes with values that are the same as the root node’s will be in the root node’s right subtree.
 */

contract BinaryTree {
    //===================== ERRORS ===================//

    error TreeIsEmpty();
    error ValueNotInTree();

    //===================== TYPES ===================//

    struct Node {
        uint256 value;
        bytes32 left;
        bytes32 right;
    }

    //===================== STATE VARIABLES ===================//

    mapping(bytes32 nodeAddress => Node) public tree;

    bytes32 private rootAddress;

    //===================== MODIFIERS ===================//

    modifier treeNotEmpty() {
        if (tree[rootAddress].value == 0 && tree[rootAddress].left == 0 && tree[rootAddress].right == 0) {
            revert TreeIsEmpty();
        }
        _;
    }

    //===================== INSERTION ===================//

    /**
     * @notice Inserts a node into the Binary Tree
     *
     *  Insertion (average log(n), worst case O(n)):
     *      - Start at the root node (rootAddress)
     *      - If the value is less than the current node's value, go left.
     *      - If the value is greater than the current node's value, go right.
     *      - Generate ID for the new node.
     *      - Insert the new node into the tree via the ID.
     *
     * @param value The value to be inserted
     * @return The address of the new node
     */
    function insert(uint256 value) external returns (bytes32) {
        Node memory root = tree[rootAddress];
        // If the tree is empty insert the value as the root
        if (root.value == 0 && root.left == 0 && root.right == 0) {
            root.value = value;
            root.left = 0;
            root.right = 0;
            tree[0] = root;
            rootAddress = generateId(value, 0);
            tree[rootAddress] = root;
            return rootAddress;
        } else {
            // If the tree is not empty find the correct place to insert the value
            bytes32 nodeId = insertHelper(value, rootAddress);
            return nodeId;
        }
    }

    /**
     * @notice Recursive helper function for inserting a node into the tree
     * @param value The value to be inserted
     * @param nodeAddress The address of the current node
     */
    function insertHelper(uint256 value, bytes32 nodeAddress) internal returns (bytes32 nodeId) {
        // Parent node
        Node memory node = tree[nodeAddress];

        // If the value is less than the current node, insert it to the left
        if (value < node.value) {
            // If the value is less than the current node, check if the left node is empty
            if (node.left == 0) {
                // If the left node is empty, insert the value
                nodeId = insertNode(value, nodeAddress, 0);
            } else {
                // If the left node is not empty, recursively call the function moving to the left
                insertHelper(value, node.left);
            }

            // Else the value is greater than the current node, insert it to the right
        } else {
            // If the value is greater than the current node, check if the right node is empty
            if (node.right == 0) {
                // If the right node is empty, insert the value
                nodeId = insertNode(value, nodeAddress, 1);
            } else {
                // If the right node is not empty, recursively call the function moving to the right
                insertHelper(value, node.right);
            }
        }
    }

    /**
     * @notice Internal function that inserts a node into the tree
     * @param value Value of the node
     * @param nodeAddress Address of the parent node
     * @param location Location of the node insertion in relation to the parent node (left = 0 or right = 1)
     */
    function insertNode(uint256 value, bytes32 nodeAddress, uint256 location) internal returns (bytes32 nodeId) {
        Node memory parentNode = tree[nodeAddress];
        nodeId = generateId(value, nodeAddress);
        if (location == 0) {
            // If the value is less than the current node insert it to the left
            parentNode.left = nodeId;
        } else {
            // If the value is greater than the current node insert it to the right
            parentNode.right = nodeId;
        }

        // Update the tree
        tree[nodeAddress] = parentNode;
        tree[nodeId] = Node(value, 0, 0);
    }

    /**
     * @notice Generates a unique id for the node
     * @param value Value of the node
     * @param parentAddress Address of the parent node
     */
    function generateId(uint256 value, bytes32 parentAddress) internal view returns (bytes32) {
        // Generate a unique hash id for the node
        return keccak256(abi.encodePacked(value, parentAddress, block.timestamp));
    }

    //===================== DELETION ===================//

    /**
     *  @notice Deletes a node from the Binary Tree
     *
     *  Deletion (average log(n), worst case O(n)):
     *      - Start at the root node (rootAddress)
     *      - If the value is less than the current node's value, go left.
     *      - If the value is greater than the current node's value, go right.
     *      - If the value is equal to the current node's value, start node deletion.
     *      - If the node has children, replace the node with the child.
     *      - If the leaf has no children, delete the leaf.
     *      - Have right preference over left when deleting.
     *
     * @param value The value to be deleted
     */
    function deleteNode(uint256 value) external treeNotEmpty returns (Node memory removedNode) {
        removedNode = deleteNodeHelper(value, "", rootAddress);
    }

    /**
     * @notice Recursive helper function for deleting a node from the tree
     * @param value The value to be deleted
     * @param parentAddress The address of the parent node
     * @param nodeAddress The address of the current node
     */
    function deleteNodeHelper(uint256 value, bytes32 parentAddress, bytes32 nodeAddress)
        internal
        returns (Node memory removedNode)
    {
        Node memory node = tree[nodeAddress];
        // If the value is equal to the current node's value, start node deletion
        if (node.value == value) {
            removedNode = deleteLeaf(parentAddress, nodeAddress);

            // If the value is less than the current node's value, go left
        } else if (value < node.value) {
            // If the left node is empty the value is not in the tree
            if (node.left == 0) {
                revert ValueNotInTree();
            } else {
                // If the left node is not empty, recursively call the function moving to the left
                // The current node becomes the parent node
                deleteNodeHelper(value, nodeAddress, node.left);
            }

            // Else the value is greater than the current node's value, go right
        } else {
            // If the right node is empty the value is not in the tree
            if (node.right == 0) {
                revert ValueNotInTree();
            } else {
                // If the right node is not empty, recursively call the function moving to the right
                // The current node becomes the parent node
                deleteNodeHelper(value, nodeAddress, node.right);
            }
        }
    }

    /**
     * @notice Deletes a node from the tree
     * @param parentAddress The address of the parent node
     * @param nodeAddress The address of the node to be deleted
     */
    function deleteLeaf(bytes32 parentAddress, bytes32 nodeAddress) internal returns (Node memory node) {
        Node memory parent = tree[parentAddress];
        node = tree[nodeAddress];

        // If the node has two children, replace the node with the maximum left subtree value
        if (node.left != 0 && node.right != 0) {
            // Find the minimum value in the right subtree
            uint256 minRightValue = findMin(node.right);
            // Delete the leaf with the minimum value from the right subtree
            deleteNodeHelper(minRightValue, nodeAddress, node.left);
            // Update the node to have the minimum value from the right subtree
            node.value = minRightValue;
            tree[nodeAddress] = node;

            // If the node has only a left child, update so parent points to left child and set the node to null (0)
        } else if (node.left != 0) {
            bytes32 leftChild = node.left;
            if (parent.left == nodeAddress) {
                parent.left = leftChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            } else {
                parent.right = leftChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            }

            // If the node has only a right child, update so parent points to right child and set the node to null (0)
        } else if (node.right != 0) {
            bytes32 rightChild = node.right;
            if (parent.left == nodeAddress) {
                parent.left = rightChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            } else {
                parent.right = rightChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            }

            // If the leaf has no children, delete the leaf and set the parent's child pointer to null (0)
        } else {
            if (parent.left == nodeAddress) {
                parent.left = 0;
                tree[parentAddress] = parent;
            } else {
                parent.right = 0;
                tree[parentAddress] = parent;
            }
            // Set the node to null (0)
            tree[nodeAddress] = Node(0, 0, 0);
        }
    }

    //===================== TRAVERSAL ===================//

    /**
     * @notice Displays the values in the tree preorder
     * @return An array of the values in the tree preorder
     */
    function displayPreorder() external treeNotEmpty returns (uint256[] memory) {
        return displayPreorderHelper(rootAddress, 0);
    }

    /**
     * @notice Recursive helper function for preorder traversal
     *
     *  Preorder traversal (O(n)):
     *      - Visit the root
     *      - Traverse the left subtree, i.e., call Preorder(left->subtree)
     *      - Traverse the right subtree, i.e., call Preorder(right->subtree)
     *
     * @param nodeAddress The address of the current node
     * @param index The index of the current node value in return array
     * @return An array of the values in the tree in preorder
     */
    function displayPreorderHelper(bytes32 nodeAddress, uint256 index) internal returns (uint256[] memory) {
        Node memory node = tree[nodeAddress];
        uint256 size = getTreeSize();
        uint256[] memory values = new uint256[](size);
        // Add the current node value to the array (0 will be the root)
        values[index] = node.value;
        // Keep traversing the left subtrees
        if (node.left != 0) {
            displayPreorderHelper(node.left, index + 1);
        }
        // After, traverse the right subtrees
        if (node.right != 0) {
            displayPreorderHelper(node.right, index + 1);
        }
        return values;
    }

    /**
     * @notice Displays the values in the tree inorder
     * @dev Values are displayed in sorted order from the smallest to the largest value.
     * @return An array of the values in the tree inorder
     */
    function displayInorder() external treeNotEmpty returns (uint256[] memory) {
        return displayInorderHelper(rootAddress, 0);
    }

    /**
     * @notice A recursive helper function for displaying the values in the tree inorder
     *
     *  Inorder traversal (O(n)):
     *      - Traverse the left subtree, i.e., call Inorder(left->subtree)
     *      - Visit the root
     *      - Traverse the right subtree, i.e., call Inorder(right->subtree)
     *
     * @param nodeAddress The address of the current node
     * @param index The index of the current node value in return array
     * @return An array of the values in the tree inorder
     */
    function displayInorderHelper(bytes32 nodeAddress, uint256 index) internal returns (uint256[] memory) {
        Node memory node = tree[nodeAddress];
        uint256 size = getTreeSize();
        uint256[] memory values = new uint256[](size);
        // Keep traversing the left subtrees
        if (node.left != 0) {
            displayInorderHelper(node.left, index + 1);
        }
        // Add the current node value to the array
        values[index - 1] = node.value;
        // After, traverse the right subtrees
        if (node.right != 0) {
            displayInorderHelper(node.right, index + 1);
        }
        return values;
    }

    /**
     * @notice Displays the values in the tree postorder
     * @return An array of the values in the tree postorder
     */
    function displayPostorder() external treeNotEmpty returns (uint256[] memory) {
        return displayPostorderHelper(rootAddress, 0);
    }

    /**
     * @notice A recursive helper function for displaying the values in the tree postorder
     *
     *  Postorder traversal (O(n)):
     *      - Traverse the left subtree, i.e., call Postorder(left->subtree)
     *      - Traverse the right subtree, i.e., call Postorder(right->subtree)
     *      - Visit the root
     *
     * @param nodeAddress The address of the current node
     * @param index The index of the current node value in return array
     * @return An array of the values in the tree postorder
     */
    function displayPostorderHelper(bytes32 nodeAddress, uint256 index) internal returns (uint256[] memory) {
        Node memory node = tree[nodeAddress];
        uint256 size = getTreeSize();
        uint256[] memory values = new uint256[](size);
        // Keep traversing the left subtrees
        if (node.left != 0) {
            displayPostorderHelper(node.left, index + 1);
        }
        // After, traverse the right subtrees
        if (node.right != 0) {
            displayPostorderHelper(node.right, index + 1);
        }
        // Add the current node value to the array
        values[index - 1] = node.value;
        return values;
    }

    //===================== SEARCHING ===================//

    /**
     * @notice Searches for a value in the tree
     * @param value The value to be searched for
     * @return True if the value is in the tree
     * @return The node if the value is in the tree
     */
    function findElement(uint256 value) external view treeNotEmpty returns (bool, Node memory) {
        return findElementHelper(value, rootAddress);
    }

    /**
     * @notice Recursive helper function for searching for a value in the tree
     *
     *      - Search for a value in the tree (average log(n), worst case O(n)):
     *      - Start at the root node (rootAddress)
     *      - If the value is less than the current node, traverse the left subtree
     *      - If the value is greater than the current node, traverse the right subtree
     *      - If the value is equal to the current node, return true and the node
     *      - If the value is not in the tree, revert
     *
     * @param value The value to be searched for
     * @param nodeAddress The address of the current node
     * @return True if the value is in the tree
     * @return The node if the value is in the tree
     */
    function findElementHelper(uint256 value, bytes32 nodeAddress) internal view returns (bool, Node memory) {
        Node memory node = tree[nodeAddress];
        // If the value is equal to the current node, return true and the node
        if (node.value == value) {
            return (true, node);

            // If the value is less than the current node, traverse the left subtree
        } else if (value < node.value) {
            if (node.left == 0) {
                revert ValueNotInTree();
            } else {
                return findElementHelper(value, node.left);
            }

            // If the value is greater than the current node, traverse the right subtree
        } else {
            if (node.right == 0) {
                revert ValueNotInTree();
            } else {
                return findElementHelper(value, node.right);
            }
        }
    }

    //===================== GETTERS ===================//

    /**
     * @notice Returns the minimum value in the tree
     */
    function getMin() external view treeNotEmpty returns (uint256) {
        return findMin(rootAddress);
    }

    /**
     * @notice Recursive helper function for finding the minimum value in the tree from a given node
     * @param nodeAddress The address of the current node
     * @return The minimum value in the tree
     */
    function findMin(bytes32 nodeAddress) public view treeNotEmpty returns (uint256) {
        Node memory node = tree[nodeAddress];
        // If the left node is empty, the current node is the minimum value
        if (node.left == 0) {
            return node.value;
            // Else keep traversing the left subtrees
        } else {
            return findMin(node.left);
        }
    }

    /**
     * @notice Returns the maximum value in the tree
     */
    function getMax() external view treeNotEmpty returns (uint256) {
        return findMax(rootAddress);
    }

    /**
     * @notice Recursive helper function for finding the maximum value in the tree from a given node
     * @param nodeAddress The address of the current node
     * @return The maximum value in the tree
     */
    function findMax(bytes32 nodeAddress) public view treeNotEmpty returns (uint256) {
        Node memory node = tree[nodeAddress];
        // If the right node is empty, the current node is the maximum value
        if (node.right == 0) {
            return node.value;
            // Else keep traversing the right subtrees
        } else {
            return findMax(node.right);
        }
    }

    /**
     * @notice Constructs a string consisting of parenthesis and values from the binary tree with preorder traversal (root, left subtree, right subtree)
     * @dev Omits all the empty parenthesis pairs that do not affect the one-to-one mapping relationship between the string and the original binary tree.
     * @return The tree as a string with () for empty nodes
     */
    function getTree() external view treeNotEmpty returns (string memory) {
        return treeToString(rootAddress);
    }

    /**
     * @notice Recursive helper function for converting the tree to a string with preorder traversal
     *
     *      - Preorder traverse all nodes of the tree following a depth-first search pattern (O(n))
     *      - For each non-null node, append the node value to the string
     *      - For each non-leaf node append a pair of parentheses that encloses the preorder
     *        string of its child nodes.
     *      - If a node has a right child but no left child, include a pair of parentheses for
     *        the left null child.
     *
     * @param nodeAddress The address of the current node
     * @return The tree as a string with () for empty nodes
     */
    function treeToString(bytes32 nodeAddress) internal view returns (string memory) {
        // If only root, return the root value as a string
        if (getTreeSize() == 1) {
            uint256 rootValue = tree[rootAddress].value;
            return Strings.toString(rootValue);
        }
        // Else recursively add the left and right children to the string in parenthesis
        Node memory node = tree[nodeAddress];
        string memory treeString = Strings.toString(node.value);
        // If the node has a left child, add the left child to the string in parenthesis recursively
        if (node.left != 0) {
            treeString = string(abi.encodePacked(treeString, "(", treeToString(node.left), ")"));
        }
        // If the node has a right child, add the right child to the string in parenthesis recursively
        if (node.right != 0) {
            // If the node has a right child but no left child, add empty parenthesis to the string
            if (node.left == 0) {
                treeString = string(abi.encodePacked(treeString, "()"));
            }
            // Add the right child to the string in parenthesis recursively
            treeString = string(abi.encodePacked(treeString, "(", treeToString(node.right), ")"));
        }
        return treeString;
    }

    /**
     * @notice Returns the root node of the tree
     */
    function getRoot() external view treeNotEmpty returns (Node memory) {
        return tree[rootAddress];
    }

    /**
     * @notice Calculates the size of the tree (number of nodes)
     * @return The size of the tree
     */
    function getTreeSize() public view treeNotEmpty returns (uint256) {
        return getSizeHelper(rootAddress);
    }

    /**
     * @notice Recursive helper function for finding the size of the tree
     *
     *      - Preorder traverse all nodes of the tree following a depth-first search pattern (O(n))
     *      - If the node is a leaf return 1 else check for the presence of left and right children
     *      - If the node has a right child but no left child, sum nodes on right subtree
     *      - If the node has a left child but no right child, sum nodes on left subtree
     *      - If the node has both left and right children, sum nodes on both subtrees
     *
     * @param nodeAddress The address of the current node
     */
    function getSizeHelper(bytes32 nodeAddress) public view treeNotEmpty returns (uint256) {
        Node memory node = tree[nodeAddress];
        // If leaf node, having no children, return 1 representing this single node.
        if (node.left == 0 && node.right == 0) {
            return 1;
            // Else recursively call the function on the left and right subtrees
        } else {
            // If no left child, add 1 for current node to the count of nodes in the right subtree.
            if (node.left == 0) {
                return 1 + getSizeHelper(node.right);
                // If no right child, add 1 for current node to the count of nodes in the left subtree.
            } else if (node.right == 0) {
                return 1 + getSizeHelper(node.left);
                // If both left and right children, add 1 for current node to the count of nodes in both subtrees
            } else {
                return 1 + getSizeHelper(node.left) + getSizeHelper(node.right);
            }
        }
    }

    /**
     * @notice Calculates the height (maximum depth) of the tree
     *
     *  The height of a binary tree is equal to the largest number of edges from the root to the
     *  most distant leaf node.
     *
     * @return The height of the tree
     */

    function getTreeHeight() external view treeNotEmpty returns (uint256) {
        return getHeightHelper(rootAddress);
    }

    /**
     * @notice Recursive helper function for finding the height of the tree
     *
     *  The height of a node is the largest number of path edges from a leaf node to a target node:
     *      - Postorder traverse all nodes of the tree following a depth-first search pattern (O(n))
     *      - As the function returns from each recursive call, compare the heights received from
     *        the left and right children and return the greater of the two values plus 1 for the
     *        current node.
     *      - Leaf nodes return 0, any node that has at least one child will return a value greater
     *        representing the maximum height of the tree below that node, including the node.
     *
     * @param nodeAddress The address of the current node
     * @return The height of the tree from given node
     */

    function getHeightHelper(bytes32 nodeAddress) public view treeNotEmpty returns (uint256) {
        Node memory node = tree[nodeAddress];
        // If leaf node, having no children, return 0 representing this single node.
        if (node.left == 0 && node.right == 0) {
            return 0;
            // Else recursively call the function on the left and right subtrees
        } else {
            // Compute the depth of each subtree
            uint256 leftDepth = getHeightHelper(node.left);
            uint256 rightDepth = getHeightHelper(node.right);
            // Height is the larger depth plus the current node
            if (leftDepth > rightDepth) {
                return leftDepth + 1;
            } else {
                return rightDepth + 1;
            }
        }
    }

    /**
     * @notice Calculates the depth of a node in the tree
     *
     *  The depth of a node is the number of path edges from the root of a tree to that node.
     *
     * @param value The value of the node to find the depth of
     * @return The depth of the node
     */

    function getDepth(uint256 value) external view treeNotEmpty returns (int256) {
        return getDepthHelper(rootAddress, value);
    }

    /**
     * @notice Recursive helper function for finding the depth of a node in the tree
     *
     *      - Preorder traverse nodes following a depth-first search pattern (O(n))
     *      - If the value is equal to the current node, return 0
     *      - Search the left sub-tree of the current node for the target value
     *      - Move down a level in the tree, and each time the function finds the target value
     *        within a child subtree, add 1 to the current dist value, which is returned from the
     *        recursive call.
     *      - If the target value wasn't found in the left sub-tree, search the right sub-tree with
     *        the same process.
     *      - If value not found in either subtree revert
     *
     * @param nodeAddress The address of the current node
     * @param value The value of the node to find the depth of
     */

    function getDepthHelper(bytes32 nodeAddress, uint256 value) public view treeNotEmpty returns (int256) {
        Node memory node = tree[nodeAddress];
        // Initialize distance as -1
        int256 dist = -1;

        // Check if value is current node
        if (node.value == value) {
            return dist + 1;
        }
        // Search the left sub-tree of the current node for the target value.
        dist = getDepthHelper(node.left, value);
        // If the target node is found in the left sub-tree, return the distance from the current node to the target node.
        if (dist >= 0) {
            return dist + 1;
        }
        // If the target value wasn't found in the left sub-tree, Search the right sub-tree of the current node for the target value.
        dist = getDepthHelper(node.right, value);
        // If the target node is found in the right sub-tree, return the distance from the current node to the target node.
        if (dist >= 0) {
            return dist + 1;
        }
        // If the target value wasn't found in either subtree, revert.
        if (dist == -1) {
            revert ValueNotInTree();
        }

        return dist;
    }

    //===================== VALIDATION ===================//

    /**
     * @notice Checks if the tree is a valid Binary Search Tree
     *
     *  A valid BST is defined as follows:
     *      - The left subtree of a node contains only nodes with keys less than the node's key.
     *      - The right subtree of a node contains only nodes with keys greater than the node's key
     *      - Both the left and right subtrees must also be binary search trees.
     *
     * @return True if the tree is a valid Binary Search Tree
     */
    function isValidBST() external view returns (bool) {
        return isValidBSTHelper(rootAddress);
    }

    /**
     * @notice Recursive helper function for checking if the tree is a valid Binary Search Tree
     *
     *      - Validate the tree using depth-first search (O(n))
     *      - If node is empty, considered valid BST
     *      - If the node has left child, check if max of left is great than the current node
     *      - If the node has right child, check if min of right is less than the current node
     *      - If either of these conditions is met, it's a violation of the BST property, and the
     *        function returns false.
     *      - Recursively call function on the left and right child nodes. If either of these calls
     *        returns false, it means the left or right subtree is not a valid BST.
     *      - If all conditions are met, return true
     *
     * @param nodeAddress The address of the current node
     * @return True if the tree is a valid Binary Search Tree
     */

    function isValidBSTHelper(bytes32 nodeAddress) public view returns (bool) {
        Node memory node = tree[nodeAddress];
        // If the node is empty, considered valid BST, return true
        if (node.value == 0 && node.left == 0 && node.right == 0) {
            return true;
        }
        // If the node has left child, check if max of left is great than the current node
        if (node.left != 0 && findMax(node.left) > node.value) {
            // If it is, return false
            return false;
        }
        // If the node has right child, check if min of right is less than the current node
        if (node.right != 0 && findMin(node.right) < node.value) {
            // If it is, return false
            return false;
        }
        // Return false if recursive calls on left or right are not valid BSTs
        if (!isValidBSTHelper(node.left) || !isValidBSTHelper(node.right)) {
            return false;
        }
        // If all conditions are met, return true
        return true;
    }

    //===================== INVERSRION ===================//

    // TODO: INVERT TREE FUNCTION

    /**
     * An inverted form of a Binary Tree is another Binary Tree with left and right children of all non-leaf nodes interchanged. You may also call it the mirror of the input tree.
     * If you invert a Binary Search Tree is will no longer be a valid Binary Search Tree.
     */

    /*
        * These are inversion functions.
            - Invert the tree (average log(n)), worst case O(n)):
                - Start at the root node (rootAddress)
                - Invert the left subtree
                - Invert the right subtree
                - Swap the left and right pointers
    */
}
