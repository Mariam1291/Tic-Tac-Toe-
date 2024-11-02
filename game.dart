import 'dart:io';
import 'dart:math';

void main() {
  print('Choose game mode:');
  print('1 : for Two Players');
  print('2 : for Easy Computer');
  print('3 : for Hard Computer');

  int? mode = int.tryParse(stdin.readLineSync() ?? '1'); // Default to mode 1 if input is invalid or null

  List<List<String>> board = [
    [' ', ' ', ' '],
    [' ', ' ', ' '],
    [' ', ' ', ' ']
  ];

  String player1 = "x";  // Player 1 will always be 'x'
  String player2 = "o";  // Player 2 or computer will be 'o'

  bool playerTurn = true; // True means player1's turn, false means player2's turn

  while (true) {
    printPositionBoard();  // Print the board with positions 1-9
    printGameBoard(board);  // Print the current game state

    if (checkWin(board, player1)) {
      print('Player 1 (x) wins!');
      break;
    } else if (checkWin(board, player2)) {
      print('Player 2 (o) wins!');
      break;
    } else if (isBoardFull(board)) {
      print('It\'s a draw!');
      break;
    }

    if (mode == 1) { // Two-player mode
      if (playerTurn) {
        print("Player 1's turn (x): ");
        playerMove(board, player1);
      } else {
        print("Player 2's turn (o): ");
        playerMove(board, player2);
      }
    } else { // Computer vs Player mode
      if (playerTurn) {
        playerMove(board, player1);
      } else {
        if (mode == 2) {
          easyComputerMove(board, player2);
        } else if (mode == 3) {
          hardComputerMove(board, player2, player1);
        }
      }
    }

    playerTurn = !playerTurn; // Switch turns
  }
}

// Print the board with numbers from 1 to 9
void printPositionBoard() {
  List<int> positions = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    print('-' * 12);
  for (int i = 0; i < 3; i++) {
    print(' ${positions[i * 3]} | ${positions[i * 3 + 1]} | ${positions[i * 3 + 2]} ');
    print('-' * 12);
  }
}

// Print the actual game state board
void printGameBoard(List<List<String>> board) {
  print('Current Game State:');
    print('-' * 12);
  for (var row in board) {
    print(' ${row[0]} | ${row[1]} | ${row[2]} ');
    print('-' * 12);
  }
}

// Map 1-9 input to row and column
List<int> mapPositionToRowCol(int position) {
  return [
    (position - 1) ~/ 3,  // row (0-based)
    (position - 1) % 3    // column (0-based)
  ];
}

// Player makes a move using numbers 1 to 9
void playerMove(List<List<String>> board, String player) {
  int position;
  List<int> rowCol;
  do {
    stdout.write('Enter position (1-9): ');
    position = int.parse(stdin.readLineSync() ?? '1'); // Default to 1 if null

    rowCol = mapPositionToRowCol(position); // Map 1-9 input to row and column
  } while (board[rowCol[0]][rowCol[1]] != ' ');

  board[rowCol[0]][rowCol[1]] = player;
}

// Easy computer makes a random move
void easyComputerMove(List<List<String>> board, String computer) {
  Random rand = Random();
  int position;
  List<int> rowCol;
  do {
    position = rand.nextInt(9) + 1; // Random position from 1 to 9
    rowCol = mapPositionToRowCol(position); // Map to row and column
  } while (board[rowCol[0]][rowCol[1]] != ' ');

  board[rowCol[0]][rowCol[1]] = computer;
  print('Computer (Easy) moves at: $position');
}

// Minimax algorithm for hard computer move
void hardComputerMove(List<List<String>> board, String computer, String player) {
  int bestScore = -1000;
  int bestRow = -1, bestCol = -1;

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      // Check if cell is empty
      if (board[i][j] == ' ') {
        board[i][j] = computer;
        int score = minimax(board, 0, false, computer, player);
        board[i][j] = ' ';
        if (score > bestScore) {
          bestScore = score;
          bestRow = i;
          bestCol = j;
        }
      }
    }
  }

  board[bestRow][bestCol] = computer;
  int position = bestRow * 3 + bestCol + 1; // Map back to position 1-9
  print('Computer (Hard) moves at: $position');
}

// Minimax algorithm
int minimax(List<List<String>> board, int depth, bool isMaximizing, String computer, String player) {
  if (checkWin(board, computer)) return 10 - depth;
  if (checkWin(board, player)) return depth - 10;
  if (isBoardFull(board)) return 0;

  if (isMaximizing) {
    int bestScore = -1000;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == ' ') {
          board[i][j] = computer;
          int score = minimax(board, depth + 1, false, computer, player);
          board[i][j] = ' ';
          bestScore = max(score, bestScore);
        }
      }
    }
    return bestScore;
  } else {
    int bestScore = 1000;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == ' ') {
          board[i][j] = player;
          int score = minimax(board, depth + 1, true, computer, player);
          board[i][j] = ' ';
          bestScore = min(score, bestScore);
        }
      }
    }
    return bestScore;
  }
}

// Check if someone has won
bool checkWin(List<List<String>> board, String player) {
  // Check rows, columns, and diagonals
  for (int i = 0; i < 3; i++) {
    if (board[i][0] == player && board[i][1] == player && board[i][2] == player) return true;
    if (board[0][i] == player && board[1][i] == player && board[2][i] == player) return true;
  }
  if (board[0][0] == player && board[1][1] == player && board[2][2] == player) return true;
  if (board[0][2] == player && board[1][1] == player && board[2][0] == player) return true;
  return false;
}

// Check if the board is full (draw)
bool isBoardFull(List<List<String>> board) {
  for (var row in board) {
    if (row.contains(' ')) return false;
  }
  return true;
}
