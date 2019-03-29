#!/bin/sh
# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Send calibration data to cros-ec accelerometers and gyroscopes.
# Set up default trigger for cros-ec-accel devices

if [ $# != 1 ]; then
  echo "Usage: $0 iio_device_name"
  exit 1
fi

DEVICE=$1

: ${ACCELEROMETER_UNIT_TEST:=false}

IIO_DEVICES="/sys/bus/iio/devices"
IIO_DEVICE_PATH="${IIO_DEVICES}/${DEVICE}"
IIO_SINGLE_SENSOR_DIR=true
SYSFSTRIG_NAME="sysfstrig0"


trigger=""


# Hook for unit tests: Test script redefines this function to monitor what is
# written to sysfs.
set_sysfs_entry() {
  local name="$1"
  local value="$2"

  echo "${value}" > "${name}"
}

main() {
  local trigger

  # Be sure the sysfs trigger module is present.
  modprobe -q iio_trig_sysfs
  set_sysfs_entry "${IIO_DEVICES}/iio_sysfs_trigger/add_trigger" 0

  # The name of the trigger is "sysfstrig0":
  # sysfstrig are the generic names of iio_sysfs_trigger, 0 is the index passed
  # at creation.
  set_sysfs_entry "${IIO_DEVICE_PATH}/trigger/current_trigger" \
                  "${SYSFSTRIG_NAME}"

  # Find the name of the created trigger.
  for trigger in "${IIO_DEVICES}"/trigger*; do
    if grep -q "${SYSFSTRIG_NAME}" "${trigger}/name"; then
      break
    fi
  done

  set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_timestamp_en" 0

    # Fields for current kernel.
  set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_x_en" 1
  set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_y_en" 1
  set_sysfs_entry "${IIO_DEVICE_PATH}/scan_elements/in_accel_z_en" 1

  # We only fetch 1 sample at a time as Chrome is the only consumer.
  set_sysfs_entry "${IIO_DEVICE_PATH}/buffer/length" 1
  set_sysfs_entry "${IIO_DEVICE_PATH}/buffer/enable" 1

  # Allow chronos to trigger the accelerometer.
  chgrp chronos "${trigger}/trigger_now"
  chmod g+w "${trigger}/trigger_now"

  # Allow powerd to set the keyboard wake angle.
}

# invoke main if not in test mode, otherwise let the test code call.
if ! ${ACCELEROMETER_UNIT_TEST}; then
  main "$@"
fi
