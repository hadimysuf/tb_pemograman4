#!/bin/bash
git config credential.helper store
git add .
git commit -m "HADI: $1"
git pull
git push