# Convert video to open format (with some performance settings)
for i in *.<source_ext>; do ffmpeg -v warning -i "$i" -c:v av1 -c:a flac -crf 30 -preset 8 -cpu-used 4 "${i%.*}.mkv"; done
# Convert audio to open format
for i in *.<source_ext>; do ffmpeg -v warning -i "$i" -"${i%.*}.flac"; done
# Convert image to open format
for i in *.<source_ext>; do ffmpeg -v warning -i "$i" "${i%.*}.exr"; done

