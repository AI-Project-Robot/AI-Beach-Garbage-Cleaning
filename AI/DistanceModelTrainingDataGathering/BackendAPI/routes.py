from flask import Blueprint, request, jsonify
from datetime import datetime
from database import db
from models import Signal
import time

# Create blueprint for signal routes
signals_bp = Blueprint('signals', __name__, url_prefix='/api')

# In-memory signal flag state
signal_flag = {'is_active': False, 'signal_id': 0}


def parse_timestamp(ts_value):
    """Parse timestamp - accepts nanoseconds (int) or datetime string."""
    if isinstance(ts_value, int):
        return ts_value  # Already in nanoseconds
    try:
        # Parse datetime string and convert to nanoseconds
        dt = datetime.fromisoformat(ts_value.replace('Z', '+00:00'))
        return int(dt.timestamp() * 1_000_000_000)
    except:
        dt = datetime.strptime(ts_value, '%Y-%m-%d %H:%M:%S')
        return int(dt.timestamp() * 1_000_000_000)


@signals_bp.route('/signals/<int:signal_id>', methods=['PUT'])
def update_signal(signal_id):
    """Update an existing signal record. Returns true on success, false on failure.
    ---
    tags:
      - Signals
    parameters:
      - in: path
        name: signal_id
        type: integer
        required: true
        description: The signal ID to update
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            t1_send_timestamp:
              type: string
              format: date-time
              example: "2026-01-21 10:30:00"
              description: When the signal was sent to T1
            t2_send_timestamp:
              type: string
              format: date-time
              example: "2026-01-21 10:30:00"
              description: When the signal was sent to T2
            t1_receive_timestamp:
              type: string
              format: date-time
              example: "2026-01-21 10:30:01"
              description: When T1 received the signal
            t2_receive_timestamp:
              type: string
              format: date-time
              example: "2026-01-21 10:30:01"
              description: When T2 received the signal
            t1_distance:
              type: number
              format: float
              example: 150.5
              description: Distance calculated by T1
            t2_distance:
              type: number
              format: float
              example: 152.3
              description: Distance calculated by T2
            t1_time_diff:
              type: number
              format: float
              example: 0.001
              description: Time difference for T1
            t2_time_diff:
              type: number
              format: float
              example: 0.0012
              description: Time difference for T2
            actual_distance:
              type: number
              format: float
              example: 151.0
              description: The actual measured distance
    responses:
      200:
        description: Update result
        schema:
          type: boolean
          description: true if successful, false if failed or signal not found
    """
    try:
        signal = Signal.query.get(signal_id)
        
        if not signal:
            return jsonify(False), 200
        
        data = request.get_json()
        
        # Update fields if provided
        if 't1_send_timestamp' in data:
            signal.t1_send_timestamp = parse_timestamp(data['t1_send_timestamp'])
        if 't2_send_timestamp' in data:
            signal.t2_send_timestamp = parse_timestamp(data['t2_send_timestamp'])
        if 't1_receive_timestamp' in data:
            signal.t1_receive_timestamp = parse_timestamp(data['t1_receive_timestamp'])
        if 't2_receive_timestamp' in data:
            signal.t2_receive_timestamp = parse_timestamp(data['t2_receive_timestamp'])
        if 't1_distance' in data:
            signal.t1_distance = float(data['t1_distance'])
        if 't2_distance' in data:
            signal.t2_distance = float(data['t2_distance'])
        if 't1_time_diff' in data:
            signal.t1_time_diff = float(data['t1_time_diff'])
        if 't2_time_diff' in data:
            signal.t2_time_diff = float(data['t2_time_diff'])
        if 'actual_distance' in data:
            signal.actual_distance = float(data['actual_distance'])
        
        db.session.commit()
        
        return jsonify(True), 200
        
    except:
        db.session.rollback()
        return jsonify(False), 200


@signals_bp.route('/signals/<int:signal_id>', methods=['GET'])
def get_signal(signal_id):
    """Retrieve a single signal record by ID.
    ---
    tags:
      - Signals
    parameters:
      - in: path
        name: signal_id
        type: integer
        required: true
        description: The signal ID to retrieve
    responses:
      200:
        description: Signal record
        schema:
          type: object
          properties:
            signal_id:
              type: integer
            t1_send_timestamp:
              type: string
            t2_send_timestamp:
              type: string
            t1_receive_timestamp:
              type: string
            t2_receive_timestamp:
              type: string
            t1_distance:
              type: number
            t2_distance:
              type: number
            t1_time_diff:
              type: number
            t2_time_diff:
              type: number
            actual_distance:
              type: number
      404:
        description: Signal not found
    """
    try:
        signal = Signal.query.get(signal_id)
        
        if not signal:
            return jsonify({'error': 'Signal not found'}), 404
        
        return jsonify(signal.to_dict()), 200
        
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@signals_bp.route('/signals', methods=['GET'])
def get_all_signals():
    """Retrieve all signal records.
    ---
    tags:
      - Signals
    responses:
      200:
        description: List of all signal records
        schema:
          type: array
          items:
            type: object
            properties:
              signal_id:
                type: integer
              t1_send_timestamp:
                type: string
              t2_send_timestamp:
                type: string
              t1_receive_timestamp:
                type: string
              t2_receive_timestamp:
                type: string
              t1_distance:
                type: number
              t2_distance:
                type: number
              t1_time_diff:
                type: number
              t2_time_diff:
                type: number
              actual_distance:
                type: number
      500:
        description: Server error
    """
    try:
        signals = Signal.query.all()
        return jsonify([signal.to_dict() for signal in signals]), 200
        
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@signals_bp.route('/signals/<int:signal_id>', methods=['DELETE'])
def delete_signal(signal_id):
    """Delete a signal record.
    ---
    tags:
      - Signals
    parameters:
      - in: path
        name: signal_id
        type: integer
        required: true
        description: The signal ID to delete
    responses:
      200:
        description: Signal deleted successfully
      404:
        description: Signal not found
      500:
        description: Database error
    """
    try:
        signal = Signal.query.get(signal_id)
        
        if not signal:
            return jsonify({'error': 'Signal not found'}), 404
        
        db.session.delete(signal)
        db.session.commit()
        
        return jsonify({'message': 'Signal deleted successfully'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Database error: {str(e)}'}), 500


@signals_bp.route('/init-signal', methods=['POST'])
def init_signal():
    """Initialize signal and create a new signal record.
    ---
    tags:
      - Signal Flag
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - t1_distance
            - t2_distance
            - actual_distance
          properties:
            t1_distance:
              type: number
              format: float
              example: 150.5
              description: Distance calculated by T1
            t2_distance:
              type: number
              format: float
              example: 152.3
              description: Distance calculated by T2
            actual_distance:
              type: number
              format: float
              example: 151.0
              description: The actual measured distance
    responses:
      201:
        description: Signal created and flag initialized successfully
        schema:
          type: integer
          example: 1
          description: The signal_id of the created record
      200:
        description: Failed to create signal
        schema:
          type: integer
          example: 0
          description: Returns 0 on failure
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify(0), 200
        
        # Validate required fields
        required_fields = ['t1_distance', 't2_distance', 'actual_distance']
        
        for field in required_fields:
            if field not in data:
                return jsonify(0), 200
        
        # Create new signal with null values for receive timestamps and time diffs
        # t1_send_timestamp and t2_send_timestamp will be set when /emit-signal is called
        new_signal = Signal(
            t1_send_timestamp=None,
            t2_send_timestamp=None,
            t1_receive_timestamp=None,
            t2_receive_timestamp=None,
            t1_distance=float(data['t1_distance']),
            t2_distance=float(data['t2_distance']),
            t1_time_diff=None,
            t2_time_diff=None,
            actual_distance=float(data['actual_distance'])
        )
        
        db.session.add(new_signal)
        db.session.commit()
        db.session.refresh(new_signal)
        
        # Set signal flag to active and store signal_id
        signal_flag['is_active'] = True
        signal_flag['signal_id'] = new_signal.signal_id
        
        response = jsonify(new_signal.signal_id)
        response.status_code = 201
        return response
        
    except ValueError as e:
        db.session.rollback()
        return jsonify(0), 200
    except Exception as e:
        db.session.rollback()
        return jsonify(0), 200


@signals_bp.route('/trigger-signal', methods=['POST'])
def trigger_signal():
    """Trigger a signal with default distance values (-1.0).
    ---
    tags:
      - Signal Flag
    responses:
      201:
        description: Signal triggered and flag initialized successfully
        schema:
          type: integer
          example: 1
          description: The signal_id of the created record
      200:
        description: Failed to trigger signal
        schema:
          type: integer
          example: 0
          description: Returns 0 on failure
    """
    try:
        # Create new signal with default -1.0 values for distances
        # t1_send_timestamp and t2_send_timestamp will be set when /emit-signal is called
        new_signal = Signal(
            t1_send_timestamp=None,
            t2_send_timestamp=None,
            t1_receive_timestamp=None,
            t2_receive_timestamp=None,
            t1_distance=-1.0,
            t2_distance=-1.0,
            t1_time_diff=None,
            t2_time_diff=None,
            actual_distance=-1.0
        )
        
        db.session.add(new_signal)
        db.session.commit()
        db.session.refresh(new_signal)
        
        # Set signal flag to active and store signal_id
        signal_flag['is_active'] = True
        signal_flag['signal_id'] = new_signal.signal_id
        
        response = jsonify(new_signal.signal_id)
        response.status_code = 201
        return response
        
    except Exception as e:
        db.session.rollback()
        return jsonify(0), 200


@signals_bp.route('/receive-signal/<int:signal_id>', methods=['PUT'])
def receive_signal(signal_id):
    """Record signal receive timestamp and calculate time difference.
    ---
    tags:
      - Signal Flag
    parameters:
      - in: path
        name: signal_id
        type: integer
        required: true
        description: The signal ID to update
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - receiver
          properties:
            receiver:
              type: string
              enum: ["T1", "T2"]
              example: "T1"
              description: The receiver identifier (T1 or T2)
    responses:
      200:
        description: Update result
        schema:
          type: boolean
          description: true if successful, false if failed or signal not found
    """
    try:
        signal = Signal.query.get(signal_id)
        
        if not signal:
            return jsonify(False), 200
        
        data = request.get_json()
        
        if not data or 'receiver' not in data:
            return jsonify(False), 200
        
        receiver = data['receiver'].upper()
        
        if receiver not in ['T1', 'T2']:
            return jsonify(False), 200
        
        # Capture current time in nanoseconds
        receive_time = time.time_ns()
        
        # Update the appropriate fields based on receiver
        if receiver == 'T1':
            signal.t1_receive_timestamp = receive_time
            # Calculate time difference in seconds (as float)
            if signal.t1_send_timestamp:
                signal.t1_time_diff = (receive_time - signal.t1_send_timestamp) / 1_000_000_000.0
        elif receiver == 'T2':
            signal.t2_receive_timestamp = receive_time
            # Calculate time difference in seconds (as float)
            if signal.t2_send_timestamp:
                signal.t2_time_diff = (receive_time - signal.t2_send_timestamp) / 1_000_000_000.0
        
        db.session.commit()
        
        return jsonify(True), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify(False), 200


@signals_bp.route('/emit-signal', methods=['POST'])
def emit_signal():
    """Emit signal for specific receiver. Returns signal_id if last record has incomplete time_diff data for that receiver.
    ---
    tags:
      - Signal Flag
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - receiver
          properties:
            receiver:
              type: string
              enum: ["T1", "T2"]
              example: "T1"
              description: The receiver identifier (T1 or T2)
    responses:
      200:
        description: Signal ID if last record has the corresponding time_diff empty/null (returns signal_id if conditions met, 0 otherwise).
        schema:
          type: integer
          example: 1
    """
    try:
        data = request.get_json()
        
        if not data or 'receiver' not in data:
            return jsonify(0), 200
        
        receiver = data['receiver'].upper()
        
        if receiver not in ['T1', 'T2']:
            return jsonify(0), 200
        
        # Get the last signal record (highest signal_id)
        last_signal = Signal.query.order_by(Signal.signal_id.desc()).first()
        
        if not last_signal:
            return jsonify(0), 200
        
        current_time = time.time_ns()
        
        # Update based on receiver and check corresponding time_diff
        if receiver == 'T1' and last_signal.t1_time_diff is None:
            last_signal.t1_send_timestamp = current_time
            db.session.commit()
            return jsonify(last_signal.signal_id), 200
        elif receiver == 'T2' and last_signal.t2_time_diff is None:
            last_signal.t2_send_timestamp = current_time
            db.session.commit()
            return jsonify(last_signal.signal_id), 200
        
        return jsonify(0), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify(0), 200
