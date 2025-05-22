# app/cli.py
from flask.cli import with_appcontext
from app.models.token_blacklist import TokenBlacklist
from app import db
from datetime import datetime, timedelta
import click

@click.command("clear-old-tokens")
@with_appcontext
def clear_old_revoked_tokens():
    cutoff = datetime.utcnow() - timedelta(days=30)
    deleted = TokenBlacklist.query.filter(TokenBlacklist.revoked_at < cutoff).delete()
    db.session.commit()
    click.echo(f"Deleted {deleted} old revoked tokens")
