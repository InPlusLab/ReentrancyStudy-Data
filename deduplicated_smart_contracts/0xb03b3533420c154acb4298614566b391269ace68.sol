/**
 *Submitted for verification at Etherscan.io on 2019-10-16
*/

// File: contracts/v5/Reversi.sol

pragma solidity ^0.5.9;

library Reversi {
    // event DebugBool(bool boolean);
    // event DebugBoard(bytes16 board);
    // event DebugUint(uint u);
    uint8 constant BLACK = 1; //0b01 //0x1
    uint8 constant WHITE = 2; //0b10 //0x2
    uint8 constant EMPTY = 3; //0b11 //0x3

    struct Game {
        bool error;
        bool complete;
        bool symmetrical;
        bool RotSym;
        bool Y0Sym;
        bool X0Sym;
        bool XYSym;
        bool XnYSym;
        bytes16 board;
        bytes28 first32Moves;
        bytes28 lastMoves;

        uint8 currentPlayer;
        uint8 moveKey;
        uint8 blackScore;
        uint8 whiteScore;
        // string msg;
    }


    function isValid (bytes28[2] memory moves) public pure returns (bool) {
        Game memory game = playGame(moves);
        if (game.error) {
            return false;
        } else if (!game.complete) {
            return false;
        } else {
            return true;
        }
    }

    function getGame (bytes28[2] memory moves) public pure returns (
        bool error,
        bool complete,
        bool symmetrical,
        bytes16 board,
        uint8 currentPlayer,
        uint8 moveKey
    // , string memory msg
    ) {
        Game memory game = playGame(moves);
        return (
            game.error,
            game.complete,
            game.symmetrical,
            game.board,
            game.currentPlayer,
            game.moveKey
            // , game.msg
        );
    }

    function showColors () public pure returns(uint8, uint8, uint8) {
        return (EMPTY, BLACK, WHITE);
    }

    function emptyBoard() public pure returns (bytes16) {
        // game.board = bytes16(10625432672847758622720); // completely empty board
        return bytes16(uint128(340282366920938456379662753540715053055)); // empty board except for center pieces
    }

    function playGame (bytes28[2] memory moves) internal pure returns (Game memory)  {
        Game memory game;

        game.first32Moves = moves[0];
        game.lastMoves = moves[1];
        game.moveKey = 0;
        game.blackScore = 2;
        game.whiteScore = 2;

        game.error = false;
        game.complete = false;
        game.currentPlayer = BLACK;

        game.board = emptyBoard();

        bool skip;
        uint8 move;
        uint8 col;
        uint8 row;
        uint8 i;
        bytes28 currentMoves;

        for (i = 0; i < 60 && !skip; i++) {
            currentMoves = game.moveKey < 32 ? game.first32Moves : game.lastMoves;
            move = readMove(currentMoves, game.moveKey % 32, 32);
            (col, row) = convertMove(move);
            skip = !validMove(move);
            if (i == 0 && (col != 2 || row != 3)) {
                skip = true; // this is to force the first move to always be C4 to avoid repeatable boards via mirroring translations
                game.error = true;
            }
            if (!skip && col < 8 && row < 8 && col >= 0 && row >= 0) {
                // game.msg = "make a move";
                game = makeMove(game, col, row);
                game.moveKey = game.moveKey + 1;
                if (game.error) {
                    if (!validMoveRemains(game)) {
                        // player has no valid moves and must pass
                        game.error = false;
                        if (game.currentPlayer == BLACK) {
                            game.currentPlayer = WHITE;
                        } else {
                            game.currentPlayer = BLACK;
                        }
                        game = makeMove(game, col, row);
                        if (game.error) {
                            game.error = true;
                            skip = true;
                        }
                    }
                }
            }
        }
        if (!game.error) {
            game = isComplete(game);
            game = isSymmetrical(game);
        }
        return game;
    }

    function validMoveRemains (Game memory game) internal pure returns (bool) {
        bool validMovesRemain = false;
        bytes16 board = game.board;
        uint8 i;
        for (i = 0; i < 64 && !validMovesRemain; i++) {
            uint8[2] memory move = [((i - (i % 8)) / 8), (i % 8)];
            uint8 tile = returnTile(game.board, move[0], move[1]);
            if (tile == EMPTY) {
                game.error = false;
                game.board = board;
                game = makeMove(game, move[0], move[1]);
                if (!game.error) {
                    validMovesRemain = true;
                }
            }
        }
        return validMovesRemain;
    }

    function makeMove (Game memory game, uint8 col, uint8 row) internal pure returns (Game memory)  {
        // square is already occupied
        if (returnTile(game.board, col, row) != EMPTY){
            game.error = true;
            // game.msg = "Invalid Game (square is already occupied)";
            return game;
        }
        int8[2][8] memory possibleDirections;
        uint8  possibleDirectionsLength;
        (possibleDirections, possibleDirectionsLength) = getPossibleDirections(game, col, row);
        // no valid directions
        if (possibleDirectionsLength == 0) {
            game.error = true;
            // game.msg = "Invalid Game (doesnt border other tiles)";
            return game;
        }

        bytes28 newFlips;
        uint8 newFlipsLength;
        uint8 newFlipCol;
        uint8 newFlipRow;
        uint8 j;
        bool valid = false;
        for (uint8 i = 0; i < possibleDirectionsLength; i++) {
            delete newFlips;
            delete newFlipsLength;
            (newFlips, newFlipsLength) = traverseDirection(game, possibleDirections[i], col, row);
            for (j = 0; j < newFlipsLength; j++) {
                if (!valid) valid = true;
                (newFlipCol, newFlipRow) = convertMove(readMove(newFlips, j, newFlipsLength));
                game.board = turnTile(game.board, game.currentPlayer, newFlipCol, newFlipRow);
                if (game.currentPlayer == WHITE) {
                    game.whiteScore += 1;
                    game.blackScore -= 1;
                } else {
                    game.whiteScore -= 1;
                    game.blackScore += 1;
                }
            }
        }

        //no valid flips in directions
        if (valid) {
            game.board = turnTile(game.board, game.currentPlayer, col, row);
            if (game.currentPlayer == WHITE) {
                game.whiteScore += 1;
            } else {
                game.blackScore += 1;
            }
        } else {
            game.error = true;
            // game.msg = "Invalid Game (doesnt flip any other tiles)";
            return game;
        }

        // switch players
        if (game.currentPlayer == BLACK) {
            game.currentPlayer = WHITE;
        } else {
            game.currentPlayer = BLACK;
        }
        return game;
    }

    function getPossibleDirections (Game memory game, uint8 col, uint8 row) internal pure returns(int8[2][8] memory, uint8){

        int8[2][8] memory possibleDirections;
        uint8 possibleDirectionsLength = 0;
        int8[2][8] memory dirs = [
            [int8(-1), int8(0)], // W
            [int8(-1), int8(1)], // SW
            [int8(0), int8(1)], // S
            [int8(1), int8(1)], // SE
            [int8(1), int8(0)], // E
            [int8(1), int8(-1)], // NE
            [int8(0), int8(-1)], // N
            [int8(-1), int8(-1)] // NW
        ];
        int8 focusedRowPos;
        int8 focusedColPos;
        int8[2] memory dir;
        uint8 testSquare;

        for (uint8 i = 0; i < 8; i++) {
            dir = dirs[i];
            focusedColPos = int8(col) + dir[0];
            focusedRowPos = int8(row) + dir[1];

            // if tile is off the board it is not a valid move
            if (!(focusedRowPos > 7 || focusedRowPos < 0 || focusedColPos > 7 || focusedColPos < 0)) {
                testSquare = returnTile(game.board, uint8(focusedColPos), uint8(focusedRowPos));

                // if the surrounding tile is current color or no color it can"t be part of a capture
                if (testSquare != game.currentPlayer) {
                    if (testSquare != EMPTY) {
                        possibleDirections[possibleDirectionsLength] = dir;
                        possibleDirectionsLength++;
                    }
                }
            }
        }
        return (possibleDirections, possibleDirectionsLength);
    }

    function traverseDirection (Game memory game, int8[2] memory dir, uint8 col, uint8 row) internal pure returns(bytes28, uint8) {
        bytes28 potentialFlips;
        uint8 potentialFlipsLength = 0;
        uint8 opponentColor;
        if (game.currentPlayer == BLACK) {
            opponentColor = WHITE;
        } else {
            opponentColor = BLACK;
        }

        // take one step at a time in this direction
        // ignoring the first step look for the same color as your tile
        bool skip = false;
        int8 testCol;
        int8 testRow;
        uint8 tile;
        for (uint8 j = 1; j < 9; j++) {
            if (!skip) {
                testCol = (int8(j) * dir[0]) + int8(col);
                testRow = (int8(j) * dir[1]) + int8(row);
                // ran off the board before hitting your own tile
                if (testCol > 7 || testCol < 0 || testRow > 7 || testRow < 0) {
                    delete potentialFlips;
                    potentialFlipsLength = 0;
                    skip = true;
                } else{

                    tile = returnTile(game.board, uint8(testCol), uint8(testRow));

                    if (tile == opponentColor) {
                        // if tile is opposite color it could be flipped, so add to potential flip array
                        (potentialFlips, potentialFlipsLength) = addMove(potentialFlips, potentialFlipsLength, uint8(testCol), uint8(testRow));
                    } else if (tile == game.currentPlayer && j > 1) {
                        // hit current players tile which means capture is complete
                        skip = true;
                    } else {
                        // either hit current players own color before hitting an opponent"s
                        // or hit an empty space
                        delete potentialFlips;
                        delete potentialFlipsLength;
                        skip = true;
                    }
                }
            }
        }
        return (potentialFlips, potentialFlipsLength);
    }

    function isComplete (Game memory game) internal pure returns (Game memory) {
        if (game.moveKey == 60) {
            // game.msg = "good game";
            game.complete = true;
            return game;
        } else {
            uint8 i;
            bool validMovesRemains = false;
            bytes16 board = game.board;
            for (i = 0; i < 64 && !validMovesRemains; i++) {
                uint8[2] memory move = [((i - (i % 8)) / 8), (i % 8)];
                uint8 tile = returnTile(game.board, move[0], move[1]);
                if (tile == EMPTY) {
                    game.currentPlayer = BLACK;
                    game.error = false;
                    game.board = board;
                    game = makeMove(game, move[0], move[1]);
                    if (!game.error) {
                        validMovesRemains = true;
                    }
                    game.currentPlayer = WHITE;
                    game.error = false;
                    game.board = board;
                    game = makeMove(game, move[0], move[1]);
                    if (!game.error) {
                        validMovesRemains = true;
                    }
                }
            }
            if (validMovesRemains) {
                game.error = true;
                // game.msg = "Invalid Game (moves still available)";
            } else {
                // game.msg = "good game";
                game.complete = true;
                game.error = false;
            }
        }
        return game;
    }

    function isSymmetrical (Game memory game) internal pure returns (Game memory) {
        bool RotSym = true;
        bool Y0Sym = true;
        bool X0Sym = true;
        bool XYSym = true;
        bool XnYSym = true;
        for (uint8 i = 0; i < 8 && (RotSym || Y0Sym || X0Sym || XYSym || XnYSym); i++) {
            for (uint8 j = 0; j < 8 && (RotSym || Y0Sym || X0Sym || XYSym || XnYSym); j++) {

                // rotational symmetry
                if (returnBytes(game.board, i, j) != returnBytes(game.board, (7 - i), (7 - j))) {
                    RotSym = false;
                }
                // symmetry on y = 0
                if (returnBytes(game.board, i, j) != returnBytes(game.board, i, (7 - j))) {
                    Y0Sym = false;
                }
                // symmetry on x = 0
                if (returnBytes(game.board, i, j) != returnBytes(game.board, (7 - i), j)) {
                    X0Sym = false;
                }
                // symmetry on x = y
                if (returnBytes(game.board, i, j) != returnBytes(game.board, (7 - j), (7 - i))) {
                    XYSym = false;
                }
                // symmetry on x = -y
                if (returnBytes(game.board, i, j) != returnBytes(game.board, j, i)) {
                    XnYSym = false;
                }
            }
        }
        if (RotSym || Y0Sym || X0Sym || XYSym || XnYSym) {
            game.symmetrical = true;
            game.RotSym = RotSym;
            game.Y0Sym = Y0Sym;
            game.X0Sym = X0Sym;
            game.XYSym = XYSym;
            game.XnYSym = XnYSym;
        }
        return game;
    }



    // Utilities

    function returnSymmetricals (bool RotSym, bool Y0Sym, bool X0Sym, bool XYSym, bool XnYSym) public pure returns (uint256) {
        uint256 symmetries = 0;
        if(RotSym) symmetries |= 16;
        if(Y0Sym) symmetries |= 8;
        if(X0Sym) symmetries |= 4;
        if(XYSym) symmetries |= 2;
        if(XnYSym) symmetries |= 1;
        return symmetries;
    }


    function returnBytes (bytes16 board, uint8 col, uint8 row) internal pure returns (bytes16) {
        uint128 push = posToPush(col, row);
        return (board >> push) & bytes16(uint128(3));
    }

    function turnTile (bytes16 board, uint8 color, uint8 col, uint8 row) internal pure returns (bytes16){
        if (col > 7) revert("can't turn tile outside of board col");
        if (row > 7) revert("can't turn tile outside of board row");
        uint128 push = posToPush(col, row);
        bytes16 mask = bytes16(uint128(3)) << push;// 0b00000011 (ones)

        board = ((board ^ mask) & board);

        return board | (bytes16(uint128(color)) << push);
    }

    function returnTile (bytes16 board, uint8 col, uint8 row) public pure returns (uint8){
        uint128 push = posToPush(col, row);
        bytes16 tile = (board >> push ) & bytes16(uint128(3));
        return uint8(uint128(tile)); // returns 2
    }

    function posToPush (uint8 col, uint8 row) internal pure returns (uint128){
        return uint128(((64) - ((8 * col) + row + 1)) * 2);
    }

    function readMove (bytes28 moveSequence, uint8 moveKey, uint8 movesLength) public pure returns(uint8) {
        bytes28 mask = bytes28(uint224(127));
        uint8 push = (movesLength * 7) - (moveKey * 7) - 7;
        return uint8(uint224((moveSequence >> push) & mask));
    }

    function addMove (bytes28 moveSequence, uint8 movesLength, uint8 col, uint8 row) internal pure returns (bytes28, uint8) {
        uint256 foo = col + (row * 8) + 64;
        bytes28 move = bytes28(uint224(foo));
        moveSequence = moveSequence << 7;
        moveSequence = moveSequence | move;
        movesLength++;
        return (moveSequence, movesLength);
    }

    function validMove (uint8 move) internal pure returns(bool) {
        return move >= 64;
    }

    function convertMove (uint8 move) public pure returns(uint8, uint8) {
        move = move - 64;
        uint8 col = move % 8;
        uint8 row = (move - col) / 8;
        return (col, row);
    }

}