#!/bin/bash
curl -X POST http://localhost:8000/store/ -H "Content-Type: application/json" -d @./test_call_ios.json

curl -X POST http://localhost:8000/store/ -H "Content-Type: application/json" -d @./test_call_android.json