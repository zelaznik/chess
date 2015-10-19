# Ruby Chess
- A game which follows Ruby object-oriented best practices which allows two human players to play each other in Chess.
[checkmate]: https://raw.githubusercontent.com/zelaznik/chess/master/images/checkmate.gif
  -  - ![Starting Sreenshot For Chess][checkmate]


## Summary
  - At each step the player can use the keyboard to select a piece to move, and then uses a cursor to walk toward the place where he’d like to move the piece.

  - When the cursor hovers over a particular piece, all the available moves for that piece are highlighted in blue.

  - If a move is invalid, the board will not let you move the piece.  This includes but is not limited to: trying to move a piece off the board.  Trying to move into check.  Not moving out of check.  Trying to move a piece over another one.

  - When a person is in check, a notification will display on the console, same things happens when a person is in checkmate

## Setup Instructions
  - If you don't have Ruby 2.0 or later, install it.
  - Browse to the directory you want in the terminal, for example:
  - Clone the Git Repo in your computer
  - Make sure to have the colorize gem

  ```bash
  $ sudo install ruby
  $ cd desktop
  $ git clone https://github.com/zelaznik/chess.git  
  $ gem install colorize
  ```

## Playing Instructions
#### Starting The Game
  - Browse to the directory and start the game

  ```bash
  $ cd chess
  $ ruby game.rb
  ```

  - Your screen should now look like this:
[start_game]: https://raw.githubusercontent.com/zelaznik/chess/master/images/start_game.gif
  -  ![Starting Sreenshot For Chess][start_game]


## Mixins

|Item Type|Item Name|Rook|Knight|Queen|King|Bishop|Pawn|
|---------|--------------------|--------|--------|--------|--------|--------|--------|
|Method|diagonal_directions|-|-|TRUE|TRUE|-|-|
|Method|row_col_directions|TRUE|-|TRUE|TRUE|-|-|
|Module|MAGNITUDE_UNLIMITED|TRUE|-|TRUE|-|TRUE|-|
|Module|MAGNITUDE_ONE|-|TRUE|-|TRUE|-|-|
|Module|DIAGONAL_MOVES|-|-|-|-|TRUE|-|
