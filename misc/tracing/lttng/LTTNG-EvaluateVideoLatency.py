
# coding: utf-8

# In[81]:

import babeltrace
import pandas as pd
import numpy as np


# In[82]:

def parse_trace(session_name):
    tc1 = babeltrace.TraceCollection()
    tc1.add_trace("/home/jack/lttng-traces/{}/ust/uid/0/64-bit".format(session_name), "ctf")
    msgs_start = {}
    msgs_latency = {}
    gpu_alloc = 0
    cpu_alloc = 0
    gpu_upload = 0
    gpu_download = 0
    for event in tc1.events:
        if event.get("port_field") == "VideoCapture":
            msgs_start[event.get("timestamp_field")] = event.timestamp
        elif event.get("port_field") == "TextureUpdated":
            if event.get("timestamp_field") in msgs_start.keys():
                msgs_latency[event.get("timestamp_field")] = event.timestamp - msgs_start[event.get("timestamp_field")]
        elif event.name == "ubitrack:vision_allocate_gpu":
            gpu_alloc += 1
        elif event.name == "ubitrack:vision_allocate_cpu":
            cpu_alloc += 1
        elif event.name == "ubitrack:vision_gpu_upload":
            gpu_upload += 1
        elif event.name == "ubitrack:vision_gpu_download":
            gpu_download += 1
    allocations = pd.DataFrame([{"cpu_alloc": cpu_alloc, "gpu_alloc": gpu_alloc,
                                "gpu_upload": gpu_upload, "gpu_download": gpu_download}])   
    latency = pd.DataFrame([msgs_latency], index=['duration_ms']).T/10**6 # to milliseconds
    return latency, allocations


# # FreenectGPU-Undistort-4xRotate90-BgImage

# In[83]:

latency_gpu, allocations_gpu = parse_trace("auto-20160715-191046")


# In[84]:

latency_gpu.mean()


# In[85]:

latency_gpu.describe()


# In[86]:

allocations_gpu


# # Freenect-Undistort-4xRotate90-BgImage

# In[87]:

latency_cpu, allocations_cpu = parse_trace("auto-20160715-191330")


# In[88]:

latency_cpu.mean()


# In[89]:

latency_cpu.describe()


# In[90]:

allocations_cpu

