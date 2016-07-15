#!/bin/bash

lttng create
lttng enable-event --userspace ubitrack:*
lttng start && sleep 120 && lttng stop
sudo chgrp -R jack /home/jack/lttng-traces/
sudo chmod -R g+w /home/jack/lttng-traces/
