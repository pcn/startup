# hacks

# Pipewire and zoom aren't playing nice together, sometimes we may need to restart it as of 2025-05-18

restart_pipewire() {
  if pgrep -x "pipewire" > /dev/null; then
      echo "Restarting Pipewire..."
      (
          set -x
          systemctl --user restart wireplumber pipewire pipewire-pulse
          rm -r ~/.config/pulse
          set +x
          echo "Pipewire restarted."
      )
  else
      echo "Pipewire is not running."
  fi
}

swamp --version 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    source <(swamp completions bash)
fi
