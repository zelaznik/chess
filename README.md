# Ruby Chess
- A game which follows Ruby object-oriented best practices which allows two human players to play each other in Chess.

## Summary
  - At each step the player can use the keyboard to select a piece to move, and then uses a cursor to walk toward the place where he’d like to move the piece.

  - When the cursor hovers over a particular piece, all the available moves for that piece are highlighted in blue.

  - If a move is invalid, the board will not let you move the piece.  This includes but is not limited to: trying to move a piece off the board.  Trying to move into check.  Not moving out of check.  Trying to move a piece over another one.

  - When a person is in check, a notification will display on the console, same things happens when a person is in checkmate

## Instructions
  - Clone the Git Repo in your computer
  - If you don't have Ruby 2.0 or later, install it.
  - gem install colorize
  - Browse to the directory of your Chess repository.
  - Type into the terminal "ruby game.rb"
  - Enjoy

## Mixins

|Item Type|Item Name|Rook|Knight|Queen|King|Bishop|Pawn|
|---------|--------------------|--------|--------|--------|--------|--------|--------|
|Method|diagonal_directions|-|-|TRUE|TRUE|-|-|
|Method|row_col_directions|TRUE|-|TRUE|TRUE|-|-|
|Module|MAGNITUDE_UNLIMITED|TRUE|-|TRUE|-|TRUE|-|
|Module|MAGNITUDE_ONE|-|TRUE|-|TRUE|-|-|
|Module|DIAGONAL_MOVES|-|-|-|-|TRUE|-|
