#!/bin/bash
pip install --no-cache-dir -r requirements.txt
mkdir -p ./build
g++ -std=c++17 -O3 -o ./build/reduce ./src/reduce.cpp