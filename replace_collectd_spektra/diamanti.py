import httplib
import os
import urllib2
import logging
import subprocess
from urlparse import urlparse

import time
import collectd
import json
import urllib

#import etcd3
import prometheus_client
#from etcd3.exceptions import ConnectionFailedError
from prometheus_client.parser import text_string_to_metric_families
from prometheus_client import CollectorRegistry, write_to_textfile

# when debug == True it is able to run manually on the MAC
#debug = True
debug = False

# usec in ms conversion factor
usecInMs = 1000
ioSize = 8

config = {}
# lastVol contains stats related to volumes keyed by UDID
# nextVol is an in-progress build out of lastVol for the next cycle
lastVol = {}
nextVol = {}
def myconfig(conf):
    collectd.info('Configuring to collect container stats')
    for node in conf.children:
        key = node.key.lower()
        val = node.values[0]
        collectd.info('Config {} value {}'.format(key, val))
        if key == 'storage_url':
            config['storage_url'] = val
        elif key == 'cadvisor_url':
            config['cadvisor_url'] = val
        elif key == 'etcd_url':
            config['etcd_url'] = val
        elif key == 'collectd_url':
            config['collectd_url'] = val
        else:
            collectd.warning('diamanti plugin: Unknown config key: %s' % key)
            continue

volInfoByVolName = None
volInfoByDevPath = None
projectMap = None
appMap = None

def myinit():
    collectd.info('Initing to collect container stats')

# return json or whole file
def urlOpenErrorHandling(urlToOpen, local=False, return_json=True):
    try:
        if local == True:
            response = urllib.urlopen(urlToOpen)
        else:
            # curl all metrics to a local file for processing
            tmpFile = "/metrics/"+urlToOpen
            os.system("curl -s "+config[urlToOpen]+" > "+tmpFile)
            # os.system("curl -s "+config[urlToOpen]+" | grep -e container_cpu_usage_seconds_total -e container_memory_usage_bytes -e container_network_receive_bytes_total -e  container_network_transmit_bytes_total > "+tmpFile)
            response = urllib.urlopen(tmpFile)
        if return_json == True:
            return json.load(response)
        else:
            return response
    except urllib2.HTTPError, e:
        collectd.warning('HTTPError ='+ str(e.code))
    except urllib2.URLError, e:
        collectd.warning('URLError ='+str(e.reason))
    except httplib.HTTPException, e:
        collectd.warning('HTTPException')
    except Exception, e:
        #collectd.warning('generic exception: ' + traceback.format_exc())
        print e.message

def getudidmap():
	nvmearr = []
	udidmap = {}

	physfunc = subprocess.Popen(["export LD_LIBRARY_PATH=\"/usr-lib64\"; lspci | grep \"Non-Volatile memory controller\" | awk 'NR == 1 {print $1}'"], stdout=subprocess.PIPE, shell=True)
	physfn = physfunc.communicate()[0].strip("\n")

	if physfn == '':
		#print("physical function not found")
		return udidmap

	# finding all nvme devices
	for ctrl in range(1,65):
		cmd = "/sys/bus/pci/devices/0000:" + physfn + "/virtfn" + str(ctrl - 1)

		drivercmd = cmd + "/driver"
		isDriver = os.path.isdir(drivercmd)
		if not isDriver:
			continue

		blockcmd = cmd + "/block"
		isBlock = os.path.isdir(blockcmd)
		if isBlock:
			blockdevices = subprocess.Popen(["ls " + blockcmd + " | grep nvme"], stdout=subprocess.PIPE, shell=True)
			dev = blockdevices.communicate()[0].strip()
			nvmearr.append(dev)

		nvmecmd = cmd + "/nvme"
		isNvme = os.path.isdir(nvmecmd)
		if isNvme:
			nvmedevices = subprocess.Popen(["ls " + nvmecmd + " | grep nvme"], stdout=subprocess.PIPE, shell=True)
			dev = nvmedevices.communicate()[0].strip()
			nvmearr.append(dev)

	# mapping all devices with udid
	for dev in nvmearr:
		dev = "/dev/" + dev + "n1"
		udid_cmd = "/usr/bin/nvme id-ns " + dev + " | grep nguid"
		udid = subprocess.Popen([udid_cmd], stdout=subprocess.PIPE, shell=True)
		udid = udid.communicate()[0]
		udid = udid.split(":")[1].strip()
		udidmap[udid] = dev

	#print(udidmap)
	return udidmap

def getVolumeMap():
    volInfoByDevPath = {}
    volInfoByVolName = {}

    # TO BE DONE: add device_path in the output of bosun endpoint below
    # Get information of all volumes scheduled on current node (Node on which collectd pod is deployed)

    convoysvc = "KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token); curl -sSk -H \"Authorization: Bearer $KUBE_TOKEN\" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/diamanti-system/services/convoy"
    convoy = subprocess.Popen([convoysvc], stdout=subprocess.PIPE, shell=True)
    convoy = convoy.communicate()[0].strip()

    try:
        convoy = json.loads(convoy)
        convoy_vip = convoy["spec"]["clusterIP"]
        cmd = "curl -k --silent " + str(convoy_vip) + ":12346/api/v1/volumes > volumeInfo.json"
        os.system(cmd)
        volumeList = json.loads(open("volumeInfo.json").read())
    except:
        logging.error("Convoy is not running. skipping volume stat collection...")
        return volInfoByVolName, volInfoByDevPath

    # return empty maps if no volume found on cluster
    if "items" not in volumeList:
        return volInfoByVolName, volInfoByDevPath

    # generating following values for each volume on node:
    # volume_usage, volume_size, device_path, pod_name, namespace
    for volume in volumeList["items"]:
        volume_name = volume["name"]

        if volume["kind"] != "Volume":
            continue
        if ("labels" not in volume):
            continue
        if (volume["status"]["state"] != "Attached"):
            continue

        volumeUsage = 0
        volumeTotal = volume["status"]["size"]

        # volume usage calculation
        if 'lds' in volume["status"]["layout"]["plexes"][0]["status"]["svs"][0].keys():
          lds = volume["status"]["layout"]["plexes"][0]["status"]["svs"][0]["lds"]
          for ld in lds:
            if "allocLength" in ld:
                volumeUsage = volumeUsage + (ld["allocLength"] * ld["blockSize"])

        # default variables
        pathFlag = 0
        pod_name = ""
        namespace = ""
        attached_host = volume["status"]["attachHost"]
        attached_host = attached_host.replace(".", "_")
        device_path = volume["status"]["devicePath"]

        if ("labels" in volume) and ("diamanti.com/pod-name" in volume["labels"]):
            podInfo = volume["labels"]["diamanti.com/pod-name"]
            pod_name = podInfo.split("/")[1]
            namespace = podInfo.split("/")[0]

        # creating dictionaries with generated values
        if attached_host not in volInfoByDevPath:
             volInfoByDevPath[attached_host] = {}

        volInfoByDevPath[attached_host][device_path] = {"pod_name": pod_name, "namespace": namespace, "volume_name": volume_name}
        volInfoByVolName[volume_name] = {"pod_name" : pod_name, "namespace": namespace, "device_path": device_path, "storage_usage": volumeUsage, "volume_size": volumeTotal, "attached_host": attached_host}

    return volInfoByVolName, volInfoByDevPath

def getAppMap():
    appMap = {}

    getPods = "KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token); curl -sSk -H \"Authorization: Bearer $KUBE_TOKEN\" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/pods?labelSelector=spektra.diamanti.io/app&limit=500"
    pods = subprocess.Popen([getPods], stdout=subprocess.PIPE, shell=True)
    pods = pods.communicate()[0].strip()

    if pods:
      pods = json.loads(pods)
      for pod in pods["items"]:
        if "spektra.diamanti.io/app" in pod["metadata"]["labels"]:
            app = pod["metadata"]["labels"]["spektra.diamanti.io/app"]
            pod_name = pod["metadata"]["name"]
            pod_namespace = pod["metadata"]["namespace"]

            if pod_namespace not in appMap:
                appMap[pod_namespace] = {}
            appMap[pod_namespace][pod_name] = app

    return appMap

def getProjectMap():
    projectMap = {}

    # hierarchyconfigurations objects are present in namespaces which are under a project indicated by parent field in their spec
    getHierarchy = "KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token); curl -sSk -H \"Authorization: Bearer $KUBE_TOKEN\" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/hnc.x-k8s.io/v1alpha1/hierarchyconfigurations?limit=500"
    out = subprocess.Popen([getHierarchy], stdout=subprocess.PIPE, shell=True)
    hierarchy = out.communicate()[0].strip()
    if hierarchy:
      try:
        hierarchies = json.loads(hierarchy)
        if "items" in hierarchies:
            for item in hierarchies["items"]:
                if "parent" in item["spec"]:
                    parent_link = item["spec"]["parent"]
                    namespace = item["metadata"]["namespace"]
                    if (parent_link.find("project-default-") == -1):
                        project = parent_link.partition('-project-')[2]
                    else:
                        part = parent_link.partition('spektra-')[2].partition('project-')
                        project = part[0] + part[2]
                    projectMap[namespace] = project
                    #print("map type1 namespace: ", namespace, " to project: ", projectMap[namespace])
      except:
        pass

    # Namespaces with label controller-generated=yes corespond to project themselves
    getNs = "KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token); curl -sSk -H \"Authorization: Bearer $KUBE_TOKEN\" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces?labelSelector=controller-generated%3Dyes&limit=500"

    out = subprocess.Popen([getNs], stdout=subprocess.PIPE, shell=True)
    ns = out.communicate()[0].strip()
    if ns:
      try:
        namespaces = json.loads(ns)
        if "items" in namespaces:
            for item in namespaces["items"]:
                namespace = item["metadata"]["name"]
                if (namespace.find("project-default-") == -1):
                    project = namespace.partition('-project-')[2]
                else:
                    part = namespace.partition('spektra-')[2].partition('project-')
                    project = part[0] + part[2]
                projectMap[namespace] = project
                #print("map type2 namespace: ", namespace, " to project: ", project)
      except:
        pass

    return projectMap

def myread():
    global volInfoByVolName, volInfoByDevPath, projectMap, appMap
    global lastVol, nextVol
    nextVol = {}
    registry = CollectorRegistry()

    node_blocks_read_usec = \
        prometheus_client.Gauge('diamanti_node_blocks_read_usec', '',       ['type_instance', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)
    node_blocks_read = \
        prometheus_client.Gauge('diamanti_node_blocks_read', '',            ['type_instance', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)
    node_blocks_write_usec = \
        prometheus_client.Gauge('diamanti_node_blocks_write_usec', '',      ['type_instance', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)
    node_blocks_written = \
        prometheus_client.Gauge('diamanti_node_blocks_written', '',         ['type_instance', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)

    volume_blocks_read = \
        prometheus_client.Gauge('diamanti_volume_blocks_read', '',          ['volume', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)
    volume_blocks_written = \
        prometheus_client.Gauge('diamanti_volume_blocks_written', '',       ['volume', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)
    storage_usage = \
        prometheus_client.Gauge('diamanti_storage_usage', '',       ['volume', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)
    volume_total = \
        prometheus_client.Gauge('diamanti_volume_total', '',       ['volume', 'project', 'app', 'pod_name', 'namespace', 'volume_name'], registry=registry)

    container_cpu_usage_seconds_total = \
        prometheus_client.Gauge('diamanti_container_cpu_load_average_10s', '',  ['project', 'app', 'container_name', 'pod_name', 'namespace'], registry=registry)
    container_memory_usage_bytes = \
        prometheus_client.Gauge('diamanti_container_memory_usage_bytes', '',    ['project', 'app', 'container_name', 'pod_name', 'namespace'], registry=registry)

    pod_bytes_rx = \
        prometheus_client.Gauge('diamanti_pod_bytes_rx', '',           ['project', 'app', 'pod_name', 'intf_name', 'namespace'], registry=registry)
    pod_bytes_tx = \
        prometheus_client.Gauge('diamanti_pod_bytes_tx', '',           ['project', 'app', 'pod_name', 'intf_name', 'namespace'], registry=registry)

    if appMap is None:
        appMap = {}
    if projectMap is None:
        projectMap = {}
    if volInfoByDevPath is None:
        volInfoByDevPath = {}
    if volInfoByVolName is None:
        volInfoByVolName, volInfoByDevPath = getVolumeMap()

    if os.path.isfile("/metrics/pod-events.logs"):
        if os.stat("/metrics/pod-events.logs").st_size != 0:
            projectMap = getProjectMap()
            appMap = getAppMap()
            open("/metrics/pod-events.logs", "w").close()
    else:
        projectMap = getProjectMap()
        appMap = getAppMap()

    with open("/host/proc/diskstats") as lines:
        for line in lines:
            arr = line.split()
            if len(arr)<10 or arr[2][:4] != "nvme":
                continue
            #collectd.info('Processing line %s ' % arr)
            dict = {}
            dict['reads'] = int(arr[5]) / ioSize
            dict['read_usec'] = int(arr[6]) * usecInMs
            dict['writes'] = int(arr[9]) / ioSize
            dict['write_usec'] = int(arr[10]) * usecInMs
            dev = arr[2]
            #collectd.info('Dev is %s ' % dev)
            nextVol[dev] = dict
            if dev in lastVol:
                myDict = lastVol[dev]
                reads = dict['reads'] - myDict['reads']
                read_usec = (dict['read_usec'] - myDict['read_usec'])
                writes = dict['writes'] - myDict['writes']
                write_usec = (dict['write_usec'] - myDict['write_usec'])

                app = ""
                pod_name = ""
                namespace = ""
                volume_name = ""
                projectName = ""
                dev_path = "/dev/" + dev

                hostname = subprocess.Popen(["hostname"], stdout=subprocess.PIPE, shell=True)
                hostname = hostname.communicate()[0].strip()
                hostname = hostname.replace(".", "_")

                if hostname not in volInfoByDevPath:
                    volInfoByVolName, volInfoByDevPath = getVolumeMap()
                if hostname not in volInfoByDevPath:
                    print("Hostname %s not present in volInfoByDevPath.", hostname)
                    continue

		print("volInfoByDevPath = " , volInfoByDevPath)

                if dev_path in volInfoByDevPath[hostname]:
                    pod_name = volInfoByDevPath[hostname][dev_path]["pod_name"]
                    namespace = volInfoByDevPath[hostname][dev_path]["namespace"]
                    volume_name = volInfoByDevPath[hostname][dev_path]["volume_name"]

                    if namespace in projectMap:
                        projectName = projectMap[namespace]

                    if namespace in appMap:
                        if pod_name in appMap[namespace]:
                            app = appMap[namespace][pod_name]

                    node_blocks_read_usec.labels(type_instance=dev, project = projectName, app = app, pod_name = pod_name, namespace = namespace, volume_name = volume_name).set(read_usec)
                    node_blocks_read.labels(type_instance=dev, project = projectName, app = app, pod_name = pod_name, namespace = namespace, volume_name = volume_name).set(reads)
                    node_blocks_write_usec.labels(type_instance=dev, project = projectName, app = app, pod_name = pod_name, namespace = namespace, volume_name = volume_name).set(write_usec)
                    node_blocks_written.labels(type_instance=dev, project = projectName, app = app, pod_name = pod_name, namespace = namespace, volume_name = volume_name).set(writes)

    lastVol = nextVol
    if debug == True:
        resp = urlOpenErrorHandling('storage.txt', True, True)
    else:
        resp = urlOpenErrorHandling('storage_url', False, True)
    if resp is not None and 'controllerStats' in resp:
        for controller in resp['controllerStats']:
            if controller['controllerType'] != 'Local':
                continue
            for dict in controller['volumeStats']:
                ioStats = dict['ioStats']
                vol = dict['volumeUdid']
                bread = ioStats['blocks_read']
                bwritten = ioStats['blocks_written']

                app = ""
                pod_name = ""
                namespace = ""
                projectName = ""
                volume_name = dict["volumeName"]

                size = 0
                storage_usage_by_vol = 0

                if volume_name not in volInfoByVolName:
                    volInfoByVolName, volInfoByDevPath = getVolumeMap()

                if volume_name in volInfoByVolName:
                    pod_name = volInfoByVolName[volume_name]["pod_name"]
                    namespace = volInfoByVolName[volume_name]["namespace"]
                    size = volInfoByVolName[volume_name]["volume_size"]
                    storage_usage_by_vol = volInfoByVolName[volume_name]["storage_usage"]

                if namespace in projectMap:
                    projectName = projectMap[namespace]

                if namespace in appMap:
                    if pod_name in appMap[namespace]:
                        app = appMap[namespace][pod_name]

                volume_blocks_read.labels(volume=vol, project = projectName, app = app, pod_name=pod_name, namespace=namespace, volume_name = volume_name).set(bread)
                volume_blocks_written.labels(volume=vol, project = projectName, app = app, pod_name=pod_name, namespace=namespace, volume_name = volume_name).set(bwritten)
                storage_usage.labels(volume=vol, project = projectName, app = app, pod_name=pod_name, namespace=namespace, volume_name = volume_name).set(storage_usage_by_vol)
                volume_total.labels(volume=vol, project = projectName, app = app, pod_name=pod_name, namespace=namespace, volume_name = volume_name).set(size)
                #print('storage  type %s   blocks read %d    blocks_written %d' % (dict['volumeUdid'], ioStats['blocks_read'], ioStats['blocks_written']))
    if debug == True:
        resp = urlOpenErrorHandling('cadvisor.txt', True, False)
    else:
        resp = urlOpenErrorHandling('cadvisor_url', False, False)
    if resp is not None:
        mydictlist_cpu = {}
        mydictlist_mem = {}
        mydictlist_rcv = {}
        mydictlist_tx = {}
        for line in resp:
            if line.startswith('container_cpu_usage_seconds_total'):
                for family in text_string_to_metric_families(line):
                    for sample in family.samples:
                        if len(sample) > 1:
                            ns = sample[1]['container_label_io_kubernetes_pod_namespace']
                            pod_name = sample[1]['container_label_io_kubernetes_pod_name']
                            container_name = sample[1]['container_label_io_kubernetes_container_name']
                            #print "Pod Name: {%s} Container: {%s}  NS: {%s}" % (pod_name, container_name, ns)
                            if len(ns) > 0 and len(pod_name) > 0 and len(container_name) > 0 and container_name != 'POD':
                                if pod_name in mydictlist_cpu:
                                    if container_name in mydictlist_cpu[pod_name]:
                                        if ns in mydictlist_cpu[pod_name][container_name]:
                                            mydictlist_cpu[pod_name][container_name][ns] += sample[2]
                                        else:
                                            mydictlist_cpu[pod_name][container_name][ns] = sample[2]
                                    else:
                                        mydictlist_cpu[pod_name][container_name] = {}
                                        mydictlist_cpu[pod_name][container_name][ns] = sample[2]
                                else:
                                    mydictlist_cpu[pod_name] = {}
                                    mydictlist_cpu[pod_name][container_name] = {}
                                    mydictlist_cpu[pod_name][container_name][ns] = sample[2]
                                #print("Name: {0} Labels: {1} Value: {2}".format(*sample))
            elif line.startswith('container_memory_usage_bytes'):
                for family in text_string_to_metric_families(line):
                    for sample in family.samples:
                        if len(sample) > 1:
                            ns = sample[1]['container_label_io_kubernetes_pod_namespace']
                            pod_name = sample[1]['container_label_io_kubernetes_pod_name']
                            container_name = sample[1]['container_label_io_kubernetes_container_name']
                            if len(ns) > 0 and len(pod_name) > 0 and len(container_name) > 0 and container_name != 'POD':
                                if pod_name in mydictlist_mem:
                                    if container_name in mydictlist_mem[pod_name]:
                                        if ns in mydictlist_mem[pod_name][container_name]:
                                            mydictlist_mem[pod_name][container_name][ns] += sample[2]
                                        else:
                                            mydictlist_mem[pod_name][container_name][ns] = sample[2]
                                    else:
                                        mydictlist_mem[pod_name][container_name] = {}
                                        mydictlist_mem[pod_name][container_name][ns] = sample[2]
                                else:
                                    mydictlist_mem[pod_name] = {}
                                    mydictlist_mem[pod_name][container_name] = {}
                                    mydictlist_mem[pod_name][container_name][ns] = sample[2]
                                #print "Pod Name: {%s} Container: {%s}  NS: {%s}" % (pod_name, container_name, ns)
                                #print("Name: {0} Labels: {1} Value: {2}".format(*sample))
            elif line.startswith('container_network_receive_bytes_total'):
                for family in text_string_to_metric_families(line):
                    for sample in family.samples:
                        if len(sample) > 1:
                            pod_name = sample[1]['container_label_io_kubernetes_pod_name']
                            intf_name = sample[1]['interface']
                            ns = sample[1]['container_label_io_kubernetes_pod_namespace']
                            if len(ns) > 0 and len(pod_name)>0 and len(intf_name)>0 and "enp" in intf_name:
                                if pod_name in mydictlist_rcv:
                                    if intf_name in mydictlist_rcv[pod_name]:
                                        if ns in mydictlist_rcv[pod_name][intf_name]:
                                            mydictlist_rcv[pod_name][intf_name][ns] += sample[2]
                                        else:
                                            mydictlist_rcv[pod_name][intf_name][ns] = sample[2]
                                    else:
                                        mydictlist_rcv[pod_name][intf_name] = {}
                                        mydictlist_rcv[pod_name][intf_name][ns] = sample[2]
                                else:
                                    mydictlist_rcv[pod_name] = {}
                                    mydictlist_rcv[pod_name][intf_name] = {}
                                    mydictlist_rcv[pod_name][intf_name][ns] = sample[2]
                            if len(ns) > 0 and len(pod_name)>0 and len(intf_name)>0 and "eth" in intf_name:
                                if pod_name not in mydictlist_rcv:
                                    mydictlist_rcv[pod_name] = {}
                                    mydictlist_rcv[pod_name][intf_name] = {}
                                    mydictlist_rcv[pod_name][intf_name][ns] = sample[2]
                                #print("Name: {0} Labels: {1} Value: {2}".format(*sample))
            elif line.startswith('container_network_transmit_bytes_total'):
                for family in text_string_to_metric_families(line):
                    for sample in family.samples:
                        if len(sample) > 1:
                            pod_name = sample[1]['container_label_io_kubernetes_pod_name']
                            intf_name = sample[1]['interface']
                            ns = sample[1]['container_label_io_kubernetes_pod_namespace']
                            if len(ns)> 0 and len(pod_name)>0 and len(intf_name)>0 and "enp" in intf_name:
                                if pod_name in mydictlist_tx:
                                    if intf_name in mydictlist_tx[pod_name]:
                                        if ns in mydictlist_tx[pod_name][intf_name]:
                                            mydictlist_tx[pod_name][intf_name][ns] += sample[2]
                                        else:
                                            mydictlist_tx[pod_name][intf_name][ns] = sample[2]
                                    else:
                                        mydictlist_tx[pod_name][intf_name] = {}
                                        mydictlist_tx[pod_name][intf_name][ns] = sample[2]
                                else:
                                    mydictlist_tx[pod_name] = {}
                                    mydictlist_tx[pod_name][intf_name] = {}
                                    mydictlist_tx[pod_name][intf_name][ns] = sample[2]
                            if len(ns)> 0 and len(pod_name)>0 and len(intf_name)>0 and "eth" in intf_name:
                                if pod_name not in mydictlist_tx:
                                    mydictlist_tx[pod_name] = {}
                                    mydictlist_tx[pod_name][intf_name] = {}
                                    mydictlist_tx[pod_name][intf_name][ns] = sample[2]
                                #print("Name: {0} Labels: {1} Value: {2}".format(*sample))

        # calculating list of host interfaces to filter out
        filter = []
        for item in mydictlist_tx:
            if item.startswith('collectd-v'):
                for intf in mydictlist_tx[item]:
                    filter.append(intf)
                break;
        for pod in mydictlist_cpu:
            for container in mydictlist_cpu[pod]:
                for ns in mydictlist_cpu[pod][container]:
                    app = ""
                    projectName = ""

                    if ns in projectMap:
                        projectName = projectMap[ns]

                    if ns in appMap:
                        if pod in appMap[ns]:
                            app = appMap[ns][pod]

                    container_cpu_usage_seconds_total.labels(project = projectName, app = app, container_name=container, pod_name=pod, namespace=ns).set(mydictlist_cpu[pod][container][ns])
        for pod in mydictlist_mem:
            for container in mydictlist_mem[pod]:
                for ns in mydictlist_mem[pod][container]:
                    app = ""
                    projectName = ""

                    if ns in projectMap:
                        projectName = projectMap[ns]

                    if ns in appMap:
                        if pod in appMap[ns]:
                            app = appMap[ns][pod]

                    container_memory_usage_bytes.labels(project = projectName, app = app, container_name=container, pod_name=pod, namespace=ns).set(mydictlist_mem[pod][container][ns])
        for pod in mydictlist_rcv:
            for intf in mydictlist_rcv[pod]:
                for ns in mydictlist_rcv[pod][intf]:
                    if intf not in filter:
                        app = ""
                        projectName = ""

                        if ns in projectMap:
                            projectName = projectMap[ns]

                        if ns in appMap:
                            if pod in appMap[ns]:
                                app = appMap[ns][pod]

                        pod_bytes_rx.labels(project = projectName, app = app, pod_name=pod, intf_name=intf, namespace=ns).set(mydictlist_rcv[pod][intf][ns])
        for pod in mydictlist_tx:
            for intf in mydictlist_tx[pod]:
                for ns in mydictlist_tx[pod][intf]:
                    if intf not in filter:
                        app = ""
                        projectName = ""

                        if ns in projectMap:
                            projectName = projectMap[ns]

                        if ns in appMap:
                            if pod in appMap[ns]:
                                app = appMap[ns][pod]

                        pod_bytes_tx.labels(project = projectName, app = app, pod_name=pod, intf_name=intf, namespace=ns).set(mydictlist_tx[pod][intf][ns])
    if debug == True:
        write_to_textfile('diamanti.prom', registry)
        exit(0)
    else:
        write_to_textfile('/metrics/diamanti.prom', registry)

if debug == True:
    myread()
else:
    collectd.register_config(myconfig)
    collectd.register_init(myinit)
    collectd.register_read(myread)
