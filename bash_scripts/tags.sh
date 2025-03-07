#!/bin/bash

git for-each-ref --format='%(refname:short) %(subject)' --sort=-taggerdate refs/tags --sort=committerdate
