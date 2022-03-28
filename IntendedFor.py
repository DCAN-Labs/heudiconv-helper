
#!/usr/bin/python
import json
import os
from glob import glob
import numpy
import subprocess

"""
This script is designed to determine which field maps apply to discrete fMRI scans

Author - Timothy J Hendrickson
"""

def setup(subject_path):
	if "ses" in os.listdir(subject_path)[0]:
		for item in (os.listdir(subject_path)):
			session_path = subject_path + '/'+ item
			IntendedFor(session_path)
	IntendedFor(subject_path)

def IntendedFor(data_path):
    for func in sorted(glob(data_path+'/func/*bold.json')):
        with open(func, 'r') as g:
            func_json = json.load(g)
            g.close()
        shim_func = func_json["ShimSetting"]
        patient_pos_func = func_json["ImageOrientationPatientDICOM"]
        series_num_func = int(func_json["SeriesNumber"])
        func_nii = glob(data_path+'/func/' +func.split('/')[-1].split('.')[0]+".nii*")[0]
        if "ses" in data_path:
            func_nii = "/".join(func_nii.split("/")[-3:])
        else:
            func_nii = "/".join(func_nii.split("/")[-2:])
            
        fmap_list = [] # append fmap path to list if func and fmap have same shim settings
        series_num_list = [] # append series number value to list if func and fmap have same shim settings
        for fmap in sorted(glob(data_path+'/fmap/*.json')):
            # change fmap file permissions to allow write access
            os.system("chmod 660 " + fmap)
            with open(fmap, 'r') as f:
                fmap_json = json.load(f)
                f.close()
            shim_fmap = fmap_json["ShimSetting"]
            patient_pos_fmap = fmap_json["ImageOrientationPatientDICOM"]
            series_num_fmap = int(fmap_json["SeriesNumber"])
            IntendedFor_fmap = fmap_json["IntendedFor"]
            if shim_fmap == shim_func:
                fmap_list.append(fmap)
                series_num_list.append(series_num_fmap)
        series_num_list_np_array = numpy.array(series_num_list)
        min_fmap_distance_idx = numpy.argmin(series_num_list_np_array - series_num_func)
        fmap = 
        entry = {"IntendedFor": func_list}
        fmap_json.update(entry)
        with open(fmap, 'w') as f:
            json.dump(fmap_json, f)
            f.close()
            
        # change file permissions to read only
        os.system("chmod 444 " + fmap)

