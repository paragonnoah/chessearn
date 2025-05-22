# app/models/token_blacklist.py
from app import db
from datetime import datetime

class TokenBlacklist(db.Model):
    __tablename__ = "token_blacklist"

    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(36), nullable=False, unique=True, index=True)
    revoked_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<TokenBlacklist jti={self.jti}>"

    @classmethod
    def is_blacklisted(cls, jti: str) -> bool:
        return db.session.query(
            db.exists().where(cls.jti == jti)
        ).scalar()

    @classmethod
    def add(cls, jti: str) -> None:
        if not cls.is_blacklisted(jti):
            db.session.add(cls(jti=jti))
            db.session.commit()
