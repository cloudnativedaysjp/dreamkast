#!/usr/bin/env bash

set -x

pod=$(kubectl get pod --selector=app=dreamkast,tier=dreamkast -o json | jq -r '.items[0].metadata.name')
RAKE_TASK_FILE=./lib/tasks/render_json_for_website.rake

kubectl -n dreamkast -c dreamkast cp $RAKE_TASK_FILE $pod:$RAKE_TASK_FILE
kubectl -n dreamkast -c dreamkast exec $pod -- bundle exec rake util:render_json_for_website[$EVENT_ABBR]
kubectl -n dreamkast -c dreamkast cp $pod:$EVENT_ABBR\_talks.ts ./src/data/$EVENT_ABBR\_talks.ts
kubectl -n dreamkast -c dreamkast cp $pod:$EVENT_ABBR\_speakers.ts ./src/data/$EVENT_ABBR\_speakers.ts
