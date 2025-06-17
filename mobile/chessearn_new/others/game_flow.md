Chess Betting App - Game Flow Documentation
This document provides a detailed guide to the game flow of the Chess Betting App, including authentication, game creation, joining, moves, actions, queries, and real-time interactions via SocketIO. Each section includes API endpoints, SocketIO events, example curl commands, and responses to facilitate development and integration.
this base url may change https://api.chessearn.com cause we may test using localhost too, handle it universally for easy changing eg using .env 

🔐 Authentication
Login
Response:{
  "access_token": "JWT_TOKEN",
  "refresh_token": "REFRESH_TOKEN"
}


Note: The access_token is required in the Authorization header for all API requests (e.g., Authorization: Bearer JWT_TOKEN) and as a token field in SocketIO events. get it from the authentication endpoints 

🎮 Game Creation
Create a New Game

Endpoint: POST /game/create
Description: Create a new chess game with optional betting parameters.
Headers: Authorization: Bearer JWT_TOKEN
Request Body:{
  "is_rated": true,
  "base_time": 300,
  "increment": 0,
  "bet_amount": 10.0
}


Response:{
  "message": "Match created",
  "data": {
    "id": "game_id",
    "white_player_id": "user_id",
    "status": "pending",
    "bet_amount": 10.0,
    "is_rated": true,
    "base_time": 300,
    "increment": 0
  }
}


Example:curl -X POST https://api.chessearn.com/game/create \
     -H "Authorization: Bearer JWT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"is_rated": true, "base_time": 300, "increment": 0, "bet_amount": 10.0}'




🤝 Game Joining
Join an Existing Game

Endpoint: POST /game/join/<game_id>
Description: Join a pending game as the black player.
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "Joined match",
  "data": {
    "id": "game_id",
    "white_player_id": "user_id1",
    "black_player_id": "user_id2",
    "status": "active",
    "bet_amount": 10.0
  }
}


Example:curl -X POST https://api.chessearn.com/game/join/game_id \
     -H "Authorization: Bearer JWT_TOKEN"




♟️ Game Moves
Make a Move

Endpoint: POST /game/move/<game_id>
Description: Submit a move in an active game.
Headers: Authorization: Bearer JWT_TOKEN
Request Body:{
  "move": "e4",
  "move_time": 1623456789.0
}


Response:{
  "message": "Move made",
  "data": {
    "game": {
      "id": "game_id",
      "moves": "e4",
      "status": "active"
    },
    "fen": "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
  }
}


Example:curl -X POST https://api.chessearn.com/game/move/game_id \
     -H "Authorization: Bearer JWT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"move": "e4", "move_time": 1623456789.0}'




🛠️ Game Actions
Resign a Game

Endpoint: POST /game/resign/<game_id>
Description: Resign from an active game, ending it with the opponent as the winner.
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "Player resigned",
  "data": {
    "id": "game_id",
    "status": "completed",
    "outcome": "black_win"
  }
}


Example:curl -X POST https://api.chessearn.com/game/resign/game_id \
     -H "Authorization: Bearer JWT_TOKEN"



Cancel a Game

Endpoint: POST /game/cancel/<game_id>
Description: Cancel a pending or active game (if allowed).
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "Game cancelled",
  "data": {
    "id": "game_id",
    "status": "cancelled"
  }
}


Example:curl -X POST https://api.chessearn.com/game/cancel/game_id \
     -H "Authorization: Bearer JWT_TOKEN"



Offer a Draw

Endpoint: POST /game/draw/offer/<game_id>
Description: Propose a draw to the opponent.
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "Draw offered",
  "data": {
    "id": "game_id",
    "draw_offered_by": "user_id"
  }
}


Example:curl -X POST https://api.chessearn.com/game/draw/offer/game_id \
     -H "Authorization: Bearer JWT_TOKEN"



Accept a Draw

Endpoint: POST /game/draw/accept/<game_id>
Description: Accept a pending draw offer, ending the game as a draw.
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "Draw accepted",
  "data": {
    "id": "game_id",
    "status": "completed",
    "outcome": "draw"
  }
}


Example:curl -X POST https://api.chessearn.com/game/draw/accept/game_id \
     -H "Authorization: Bearer JWT_TOKEN"



Decline a Draw

Endpoint: POST /game/draw/decline/<game_id>
Description: Decline a pending draw offer.
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "Draw declined",
  "data": {
    "id": "game_id",
    "draw_offered_by": null
  }
}


Example:curl -X POST https://api.chessearn.com/game/draw/decline/game_id \
     -H "Authorization: Bearer JWT_TOKEN"




📋 Game Queries
Get Open Games

Endpoint: GET /game/open
Description: Retrieve a list of pending games available to join.
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "2 open game(s) found",
  "data": {
    "games": [
      {
        "id": "game_id1",
        "white_player_id": "user_id1",
        "status": "pending",
        "bet_amount": 10.0
      },
      {
        "id": "game_id2",
        "white_player_id": "user_id2",
        "status": "pending",
        "bet_amount": 5.0
      }
    ],
    "pagination": {
      "page": 1,
      "per_page": 20,
      "count": 2,
      "total": 2
    }
  }
}


Example:curl -X GET https://api.chessearn.com/game/open \
     -H "Authorization: Bearer JWT_TOKEN"



Get Game History

Endpoint: GET /game/history
Description: Fetch the authenticated user's past games.
Headers: Authorization: Bearer JWT_TOKEN
Query Params: page=1&per_page=20
Response:{
  "message": "Games fetched",
  "data": {
    "games": [
      {
        "id": "game_id",
        "white_player_id": "user_id",
        "black_player_id": "user_id2",
        "status": "completed",
        "outcome": "white_win"
      }
    ],
    "pagination": {
      "page": 1,
      "per_page": 20,
      "count": 1,
      "total": 1
    }
  }
}


Example:curl -X GET "https://api.chessearn.com/game/history?page=1&per_page=20" \
     -H "Authorization: Bearer JWT_TOKEN"



Get Specific Game

Endpoint: GET /game/<game_id>
Description: Retrieve details of a specific game.
Headers: Authorization: Bearer JWT_TOKEN
Response:{
  "message": "Game retrieved",
  "data": {
    "id": "game_id",
    "white_player_id": "user_id1",
    "black_player_id": "user_id2",
    "status": "active",
    "moves": "e4 e5"
  }
}


Example:curl -X GET https://api.chessearn.com/game/game_id \
     -H "Authorization: Bearer JWT_TOKEN"




🌐 Real-Time Events (SocketIO)
Connect to SocketIO

Event: connect
Description: Establish a real-time connection to the server.
Emission:{
  "type": "connect",
  "data": {},
  "message": "Socket connection established"
}



Disconnect from SocketIO

Event: disconnect
Description: Handle disconnection from the server.
Emission:{
  "type": "disconnect",
  "data": {},
  "message": "Socket disconnected"
}



Join a Game Room

Event: join_room
Description: Join a game-specific room for real-time updates.
Data:{
  "game_id": "game_id"
}


Emission:{
  "type": "join_room",
  "data": {
    "room": "game_id"
  },
  "message": "Room joined"
}



Create a Game (SocketIO)

Event: create_game
Description: Create a new game via SocketIO.
Data:{
  "token": "JWT_TOKEN",
  "is_rated": true,
  "base_time": 300,
  "increment": 0,
  "bet_amount": 10.0
}


Emission:{
  "type": "create_game",
  "data": {
    "id": "game_id",
    "white_player_id": "user_id",
    "status": "pending",
    "bet_amount": 10.0
  },
  "message": "Match created"
}



Join a Game (SocketIO)

Event: join_game
Description: Join an existing game via SocketIO.
Data:{
  "token": "JWT_TOKEN",
  "game_id": "game_id"
}


Emission:{
  "type": "join_game",
  "data": {
    "id": "game_id",
    "white_player_id": "user_id1",
    "black_player_id": "user_id2",
    "status": "active"
  },
  "message": "Joined match"
}



Make a Move (SocketIO)

Event: make_move
Description: Submit a move in real-time.
Data:{
  "token": "JWT_TOKEN",
  "game_id": "game_id",
  "move": "e4"
}


Emission:{
  "type": "make_move",
  "data": {
    "game": {
      "id": "game_id",
      "moves": "e4",
      "status": "active"
    },
    "fen": "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1",
    "move": "e4"
  },
  "message": "Move made"
}



Sync Game State

Event: sync_game
Description: Request the current state of a game for synchronization.
Data:{
  "token": "JWT_TOKEN",
  "game_id": "game_id"
}


Emission:{
  "type": "sync_game",
  "data": {
    "id": "game_id",
    "status": "active",
    "moves": "e4 e5",
    "white_time_remaining": 295.0,
    "black_time_remaining": 300.0
  },
  "message": "Game synced"
}




🏆 Example Game Object
Here’s a sample game object as returned by the API or SocketIO:
{
  "id": "game_id",
  "white_player_id": "user_id1",
  "black_player_id": "user_id2",
  "status": "active",
  "outcome": "incomplete",
  "is_rated": true,
  "moves": "e4 e5 Nf3 Nc6",
  "base_time": 300,
  "increment": 0,
  "white_time_remaining": 295.0,
  "black_time_remaining": 300.0,
  "draw_offered_by": null,
  "start_time": "2025-06-14T06:30:00Z",
  "end_time": null,
  "created_at": "2025-06-14T06:30:00Z",
  "bet_amount": 10.0,
  "bet_locked": true,
  "platform_fee": 0.2,
  "white_bet_txn_id": "txn_id1",
  "black_bet_txn_id": "txn_id2",
  "payout_txn_id": null
}


This documentation covers the full game flow for the Chess Betting App. Use the curl examples to test endpoints, integrate SocketIO for real-time features, and refer to the example game object for data structure reference. For further details, consult the app’s source code or reach out to the development team.
