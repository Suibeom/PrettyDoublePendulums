#!/bin/bash
uuid=$(julia vid/pendulum_render.jl 500 10 0.001)
echo $uuid
cp ./* $uuid
echo $uuid/ >> .gitignore
ffmpeg -r 120 -i $uuid/frames/%06d.png -c:v libx265 -crf 16  $uuid/output-$uuid.mp4