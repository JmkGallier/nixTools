#!/bin/bash

#### Option Input
while [ -n "${1-}" ]; do
  case "$1" in
  -mic) MIC_test="$2"
    if [[ "$MIC_test" =~ .*",".* ]]; then
      MIC_address="${MIC_test}"
      echo "MICROPHONE SET TO: $MIC_address"
    fi
    ;;
  -speaker) SPEAKER_test="$2"
    if [[ "$SPEAKER_test" =~ .*",".* ]]; then
      SPEAKER_address="${SPEAKER_test}"
      echo "SPEAKER SET TO: $SPEAKER_address"
    fi
    ;;
    --client-secret) CLIENT_SECRET="$2"
      echo "${CLIENT_SECRET}"
    ;;
  --) shift ; break ;;
  esac
  shift
done

install_GA_DEP() {
  apt -qq update
  apt -qq install portaudio19-dev libffi-dev libssl-dev python3-dev python3-venv -y
}

install_GA() {
  python3 -m venv env
  env/bin/python3 -m pip install --upgrade pip setuptools wheel
  source env/bin/activate
  python3 -m pip install --upgrade google-assistant-sdk[samples]
  python3 -m pip install --upgrade google-auth-oauthlib[tool]
  google-oauthlib-tool --scope https://www.googleapis.com/auth/assistant-sdk-prototype --save --headless --client-secrets "${CLIENT_SECRET}"
}

config_Speaker() {
  rm -rf ~/.asoundrc
  touch ~/.asoundrc
  echo "pcm.!default {
  type asym
  capture.pcm 'mic'
  playback.pcm 'speaker'
  }
  pcm.mic {
    type plug
    slave {
      pcm 'hw:${MIC_address}'
      }
    }
  pcm.speaker {
    type plug
    slave {
    pcm 'hw:${SPEAKER_address}'
      rate 16000
    }
  }" >> ~/.asoundrc
  amixer set Master 70%
}

install_GA_DEP
install_GA
config_Speaker