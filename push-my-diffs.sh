#!/bin/bash

echo "New start: $(date)"
echo "$DISCORD_WEBHOOK"
cd /opt/git-repos
for f in $(find /opt/git-repos -mindepth 1 -maxdepth 1 -type d); do
  echo "Doing: $f"
  pushd "$f"
  git config --global --add safe.directory "$f"
  git pull

  rm -f /tmp/git-diff.png /tmp/git-diff.svg /tmp/git.diff
  COMMIT=$(git log --since='24 hours ago' | grep -oP '^commit .*$' | tail -n 1 | cut -d' ' -f 2)
  git diff --color "$COMMIT^1" -- . ':!lang'  ':!ecrire/tests' ':!ecrire/lang' > /tmp/git.diff
  if [ $(wc -c /tmp/git.diff | cut -d" " -f 1) -le 10 ]; then
      echo "Empty diff, exiting."
      exit 0
  fi

  # Function to render a chunk of lines
  render_chunk() {
      local start_line=$1
      local end_line=$2
      sed -n "${start_line},${end_line}p" /tmp/git.diff | sed 's/	/    /g' > /tmp/git-diff.chunk
      echo -e "\n\n\n\n\n"
      # cat /tmp/git-diff.chunk
      ansitoimg /tmp/git-diff.chunk /tmp/git-diff.svg
      svgexport /tmp/git-diff.svg /tmp/git-diff.png 100%
      curl -sS "$DISCORD_WEBHOOK" -F file1=@/tmp/git-diff.png
      sleep 1
  }

  # Count the total number of lines in the diff file
  total_lines=$(wc -l < /tmp/git.diff)
  chunk_size=20
  start_line=1
  end_line=$chunk_size

  curl "$DISCORD_WEBHOOK" -d "content=\`\`\`Diffs for $f\`\`\`"

  # Loop through the diff file in chunks
  while [ $start_line -le $total_lines ]; do
      render_chunk $start_line $end_line
      start_line=$((start_line + chunk_size))
      end_line=$((end_line + chunk_size))
  done
done
