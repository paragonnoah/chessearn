from app import db
from datetime import datetime
import uuid


class Game(db.Model):
    __tablename__ = "games"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    white_player_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False
    )
    black_player_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=False
    )
    winner_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=True)
    result = db.Column(db.String(20))  # e.g., '1-0', '0-1', 'draw'
    date_played = db.Column(db.DateTime, default=datetime.utcnow)
    bet_amount = db.Column(db.Float, default=0.0)

    white_player = db.relationship(
        "User", foreign_keys=[white_player_id], backref="white_games"
    )
    black_player = db.relationship(
        "User", foreign_keys=[black_player_id], backref="black_games"
    )
    winner = db.relationship("User", foreign_keys=[winner_id], backref="won_games")

    def to_dict(self):
        return {
            "id": self.id,
            "white_player_id": self.white_player_id,
            "black_player_id": self.black_player_id,
            "winner_id": self.winner_id,
            "result": self.result,
            "date_played": self.date_played.isoformat(),
            "bet_amount": self.bet_amount,
        }

    def __repr__(self):
        return f"<Game {self.id}: {self.white_player_id} vs {self.black_player_id} - Result: {self.result}>"
