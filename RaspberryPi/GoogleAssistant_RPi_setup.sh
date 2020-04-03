#!/bin/bash

CLIENT_SECRET=${1}

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

resolve_SPEAKER() {
  local CONFIRM_STATE=0

  while [ "${CONFIRM_STATE}" == 0 ]; do
    for i in "${!SPEAKER_address[@]}" ; do
      SPEAKER_CARD_DEVICE="${SPEAKER_address[i]}"

    done

  done
}

config_Audio_IO() {
  local SPEAKER_card_array=() SPEAKER_device_array=() SPEAKER_address=()
  local MIC_card_array=() MIC_device_array=() MIC_address=()
  local MIC_CARD_DEVICE SPEAKER_CARD_DEVICE

  mapfile -t SPEAKER_card_array < <(aplay -l | grep -oP '(?<=card )[0-9]+')
  mapfile -t SPEAKER_device_array < <(aplay -l | grep -oP '(?<=device )[0-9]+')
  mapfile -t MIC_card_array < <(arecord -l | grep -oP '(?<=card )[0-9]+')
  mapfile -t MIC_device_array < <(arecord -l | grep -oP '(?<=device )[0-9]+')

  for i in "${!SPEAKER_card_array[@]}"; do
    SPEAKER_address+=( "${SPEAKER_card_array[i]},${SPEAKER_device_array[i]}" )
  done

  for i in "${!MIC_card_array[@]}"; do
    MIC_address+=( "${MIC_card_array[i]},${MIC_device_array[i]}" )
  done

  echo "${SPEAKER_address[@]}"
  echo "${MIC_address[@]}"

  case "${#SPEAKER_address[@]}" in
  0)
    SPEAKER_CARD_DEVICE="0,0"
    ;;
  1)
    SPEAKER_CARD_DEVICE="${SPEAKER_address[0]}"
    ;;
  *)
    resolve_SPEAKER "${SPEAKER_address[0]}"
  ;;
  esac
}

config_Speaker() {

  echo "pcm.!default {
  type asym
  capture.pcm 'mic'
  playback.pcm 'speaker'
  }
  pcm.mic {
    type plug
    slave {
      pcm 'hw:${MIC_CARD},${MIC_DEVICE}'
      }
    }
  pcm.speaker {
    type plug
    slave {
    pcm 'hw:${SOUND_CARD},${SOUND_DEVICE}'
      rate 16000
    }
  }" >>.asoundrc

  amixer set Master 70%

}



config_Audio_IO