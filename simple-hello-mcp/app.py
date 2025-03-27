#!/usr/bin/env python3
from flask import Flask, request, jsonify
import time
import os

app = Flask(__name__)

# Set up logging
if not os.path.exists('logs'):
    os.makedirs('logs')

@app.route('/', methods=['GET'])
def info():
    """Root endpoint providing API information"""
    return jsonify({
        "name": "Simple Hello World MCP",
        "version": "0.1.0",
        "description": "A minimal MCP for testing Claude integration",
        "status": "operational",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "version": "0.1.0",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "components": {
            "app": {
                "status": "operational",
                "info": {"uptime": "N/A"}
            }
        }
    })

@app.route('/process', methods=['POST'])
def process():
    """Process a single request"""
    data = request.json
    query = data.get('query', '')
    
    # Simple processing
    result = f"Hello! You said: {query}"
    
    return jsonify({
        "result": result,
        "token_usage": {
            "input_tokens": len(query.split()),
            "output_tokens": len(result.split()),
            "total_tokens": len(query.split()) + len(result.split())
        },
        "processing_time_ms": 50,  # Fixed value for demo
        "model": {
            "name": "hello-world-model",
            "version": "0.1.0"
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3500)