from database import db
from datetime import datetime


class Signal(db.Model):
    """Signal data model for storing distance training data."""
    
    __tablename__ = 'signals'
    
    signal_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    t1_send_timestamp = db.Column(db.BigInteger, nullable=True)  # Nanoseconds since epoch
    t2_send_timestamp = db.Column(db.BigInteger, nullable=True)  # Nanoseconds since epoch
    t1_receive_timestamp = db.Column(db.BigInteger, nullable=True)  # Nanoseconds since epoch
    t2_receive_timestamp = db.Column(db.BigInteger, nullable=True)  # Nanoseconds since epoch
    t1_distance = db.Column(db.Float, nullable=False)
    t2_distance = db.Column(db.Float, nullable=False)
    t1_time_diff = db.Column(db.Float, nullable=True)
    t2_time_diff = db.Column(db.Float, nullable=True)
    actual_distance = db.Column(db.Float, nullable=False)
    
    def to_dict(self):
        """Convert model instance to dictionary."""
        return {
            'signal_id': self.signal_id,
            't1_send_timestamp': self.t1_send_timestamp,
            't2_send_timestamp': self.t2_send_timestamp,
            't1_receive_timestamp': self.t1_receive_timestamp,
            't2_receive_timestamp': self.t2_receive_timestamp,
            't1_distance': self.t1_distance,
            't2_distance': self.t2_distance,
            't1_time_diff': self.t1_time_diff,
            't2_time_diff': self.t2_time_diff,
            'actual_distance': self.actual_distance
        }
    
    def __repr__(self):
        return f'<Signal {self.signal_id}>'
