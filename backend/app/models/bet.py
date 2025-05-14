from app import db
import uuid


class Bet(db.Model):
    __tablename__ = "bets"

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36), db.ForeignKey("users.id"), nullable=False)
    game_id = db.Column(db.String(36), db.ForeignKey("games.id"), nullable=False)
    predicted_winner_id = db.Column(
        db.String(36), db.ForeignKey("users.id"), nullable=True
    )
    amount = db.Column(db.Float, nullable=False)
    won = db.Column(db.Boolean, default=False)

    user = db.relationship("User", foreign_keys=[user_id], backref="bets")
    game = db.relationship("Game", foreign_keys=[game_id], backref="bets")
    predicted_winner = db.relationship("User", foreign_keys=[predicted_winner_id])

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "game_id": self.game_id,
            "predicted_winner_id": self.predicted_winner_id,
            "amount": self.amount,
            "won": self.won,
        }

    def __repr__(self):
        return f"<Bet {self.id} - User: {self.user_id}, Game: {self.game_id}, Amount: {self.amount}>"
