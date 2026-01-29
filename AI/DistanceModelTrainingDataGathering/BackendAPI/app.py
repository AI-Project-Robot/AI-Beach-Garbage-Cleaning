from flask import Flask
from flasgger import Swagger
from database import db, init_db
from routes import signals_bp
import os
import pymysql


def create_database_if_not_exists():
    """Create the database if it doesn't exist."""
    db_user = os.getenv('DB_USER', 'root')
    db_password = os.getenv('DB_PASSWORD', 'abcd1234')
    db_host = os.getenv('DB_HOST', 'localhost')
    db_port = int(os.getenv('DB_PORT', '3306'))
    db_name = os.getenv('DB_NAME', 'signal_distance_db')
    
    try:
        # Connect to MySQL server without specifying database
        connection = pymysql.connect(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password
        )
        
        with connection.cursor() as cursor:
            # Create database if it doesn't exist
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
            print(f"Database '{db_name}' is ready.")
        
        connection.close()
    except Exception as e:
        print(f"Error creating database: {e}")
        raise


def create_app():
    """Application factory pattern for creating Flask app."""
    # Create database first
    create_database_if_not_exists()
    
    app = Flask(__name__)
    
    # Configuration
    # MySQL connection: mysql+pymysql://username:password@host:port/database
    db_user = os.getenv('DB_USER', 'root')
    db_password = os.getenv('DB_PASSWORD', 'abcd1234')
    db_host = os.getenv('DB_HOST', 'localhost')
    db_port = os.getenv('DB_PORT', '3306')
    db_name = os.getenv('DB_NAME', 'signal_distance_db')
    
    app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JSON_SORT_KEYS'] = False
    
    # Swagger configuration
    swagger_config = {
        "headers": [],
        "specs": [
            {
                "endpoint": 'apispec',
                "route": '/apispec.json',
                "rule_filter": lambda rule: True,
                "model_filter": lambda tag: True,
            }
        ],
        "static_url_path": "/flasgger_static",
        "swagger_ui": True,
        "specs_route": "/api/docs/"
    }
    
    swagger_template = {
        "swagger": "2.0",
        "info": {
            "title": "Signal Distance API",
            "description": "API for managing signal distance training data",
            "version": "1.0.0"
        },
        "basePath": "/",
        "schemes": ["http", "https"]
    }
    
    Swagger(app, config=swagger_config, template=swagger_template)
    
    # Initialize database
    init_db(app)
    
    # Register blueprints
    app.register_blueprint(signals_bp)
    
    return app


if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=5000)
