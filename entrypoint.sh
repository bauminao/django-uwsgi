#!/bin/bash
. bin/activate
python webapp/manage.py runserver 0:8000

#exec "$@"
