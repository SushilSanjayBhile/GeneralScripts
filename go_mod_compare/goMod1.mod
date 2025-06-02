module gitlab.eng.diamanti.com/software/main.git

go 1.23.0

replace gitlab.eng.diamanti.com/software/mcm.git/dmc => ./dmc

replace gitlab.eng.diamanti.com/software/upgrade-controller.git => ./upgrade-controller

require (
	github.com/BurntSushi/toml v1.0.0
	github.com/apparentlymart/go-cidr v1.1.0
	github.com/boj/redistore v0.0.0-20180917114910-cd5dcc76aeff
	github.com/boltdb/bolt v1.3.1
	github.com/codeclysm/extract v2.2.0+incompatible
	github.com/codegangsta/cli v1.20.0
	github.com/containernetworking/cni v1.1.2
	github.com/containernetworking/plugins v1.2.0
	github.com/coopernurse/gorp v1.6.1
	github.com/coreos/go-iptables v0.6.0
	github.com/coreos/go-systemd v0.0.0-20191104093116-d3cd4ed1dbcf
	github.com/docker/engine-api v0.4.0
	github.com/docker/libcontainer v2.2.1+incompatible
	github.com/dyson/certman v0.3.0
	github.com/fsnotify/fsnotify v1.7.0
	github.com/fsouza/go-dockerclient v1.9.7
	github.com/ghodss/yaml v1.0.0
	github.com/go-martini/martini v0.0.0-20170121215854-22fa46961aab
	github.com/go-ping/ping v1.1.0
	github.com/godbus/dbus v0.0.0-00010101000000-000000000000
	github.com/golang/glog v1.2.4	// vulnerability working
	github.com/golang/groupcache v0.0.0-20210331224755-41bb18bfe9da
	github.com/golang/protobuf v1.5.4
	github.com/google/goexpect v0.0.0-20210430020637-ab937bf7fd6f
	github.com/google/gofuzz v1.2.0
	github.com/google/uuid v1.3.0
	github.com/gorilla/context v1.1.1
	github.com/gorilla/mux v1.8.0
	github.com/gorilla/securecookie v1.1.1
	github.com/gorilla/sessions v1.2.1
	github.com/hashicorp/vault/api v1.9.1
	github.com/howeyc/gopass v0.0.0-20210920133722-c8aef6fb66ef
	github.com/imdario/mergo v0.3.13
	github.com/juju/persistent-cookiejar v1.0.0
	github.com/koding/websocketproxy v0.0.0-20181220232114-7ed82d81a28c
	github.com/kubernetes-csi/external-snapshotter/client/v4 v4.2.0
	github.com/lib/pq v1.10.9
	github.com/martini-contrib/binding v0.0.0-20160701174519-05d3e151b6cf
	github.com/martini-contrib/cors v0.0.0-20141016003011-553b9208d353
	github.com/martini-contrib/render v0.0.0-20150707142108-ec18f8345a11
	github.com/martini-contrib/sessionauth v0.0.0-20140402121541-3c15d8cae6c3
	github.com/martini-contrib/sessions v0.0.0-20140630231722-fa13114fbcf0
	github.com/mattn/go-sqlite3 v1.14.16
	github.com/minio/minio-go/v7 v7.0.48
	github.com/onsi/ginkgo/v2 v2.15.0
	github.com/onsi/gomega v1.31.0
	github.com/pborman/uuid v1.2.1
	github.com/prometheus/client_golang v1.17.0
	github.com/prometheus/common v0.45.0
	github.com/sethvargo/go-password v0.2.0
	github.com/sirupsen/logrus v1.9.0
	github.com/spf13/pflag v1.0.5
	github.com/vishvananda/netlink v1.2.1-beta.2
	gitlab.eng.diamanti.com/software/mcm.git/dmc v0.0.0-00010101000000-000000000000
	gitlab.eng.diamanti.com/software/upgrade-controller.git v0.0.0-00010101000000-000000000000
	go.etcd.io/etcd/api/v3 v3.5.10
	go.etcd.io/etcd/client/pkg/v3 v3.5.10
	go.etcd.io/etcd/client/v3 v3.5.10
	go.etcd.io/etcd/server/v3 v3.5.10
	go.uber.org/zap v1.26.0
	golang.org/x/crypto v0.21.0		// changing package to v0.31.0 causing problem in tidy
	golang.org/x/net v0.23.0 // changing package to 0.36.0 causing problem in tidy
	google.golang.org/grpc v1.58.3
	gopkg.in/gcfg.v1 v1.2.3
	gopkg.in/ldap.v3 v3.1.0
	gopkg.in/yaml.v2 v2.4.0
	k8s.io/api v0.30.1
	k8s.io/apiextensions-apiserver v0.18.0
	k8s.io/apimachinery v0.30.1
	k8s.io/apiserver v0.30.1
	k8s.io/client-go v0.30.1
	k8s.io/component-base v0.30.1
	k8s.io/component-helpers v0.30.0
	k8s.io/cri-api v0.30.0
	k8s.io/kube-aggregator v0.30.0
	k8s.io/kube-proxy v0.0.0
	k8s.io/kube-scheduler v0.0.0
	k8s.io/kubelet v0.0.0
	k8s.io/kubernetes v0.0.0-00010101000000-000000000000
	k8s.io/utils v0.0.0-20230726121419-3b25d923346b
	sigs.k8s.io/controller-runtime v0.4.0
	sigs.k8s.io/yaml v1.3.0
)

require (
	github.com/Azure/go-ansiterm v0.0.0-20210617225240-d185dfc1b5a1 // indirect
	github.com/Microsoft/go-winio v0.6.0 // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/blang/semver/v4 v4.0.0 // indirect
	github.com/cenkalti/backoff/v3 v3.0.0 // indirect
	github.com/cespare/xxhash/v2 v2.2.0 // indirect
	github.com/codegangsta/inject v0.0.0-20150114235600-33e0aa1cb7c0 // indirect
	github.com/containerd/containerd v1.6.18 // indirect
	github.com/coreos/go-semver v0.3.1 // indirect
	github.com/coreos/go-systemd/v22 v22.5.0 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/dgrijalva/jwt-go v3.2.0+incompatible // indirect
	github.com/docker/distribution v2.8.2+incompatible // indirect
	github.com/docker/docker v23.0.2+incompatible // indirect
	github.com/docker/go-connections v0.4.0 // indirect
	github.com/docker/go-units v0.5.0 // indirect
	github.com/dustin/go-humanize v1.0.1 // indirect
	github.com/emicklei/go-restful/v3 v3.11.0 // indirect
	github.com/evanphx/json-patch v5.6.0+incompatible // indirect
	github.com/go-logr/logr v1.4.1 // indirect
	github.com/go-openapi/jsonpointer v0.19.6 // indirect
	github.com/go-openapi/jsonreference v0.20.2 // indirect
	github.com/go-openapi/swag v0.22.3 // indirect
	github.com/go-sql-driver/mysql v1.7.1 // indirect
	github.com/go-task/slim-sprig v0.0.0-20230315185526-52ccab3ef572 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/gomodule/redigo v2.0.0+incompatible // indirect
	github.com/google/gnostic-models v0.6.8 // indirect
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/google/goterm v0.0.0-20190703233501-fc88cf888a3f // indirect
	github.com/google/pprof v0.0.0-20210720184732-4bb14d4b1be1 // indirect
	github.com/gorilla/websocket v1.5.0 // indirect
	github.com/h2non/filetype v1.1.3 // indirect
	github.com/hashicorp/errwrap v1.1.0 // indirect
	github.com/hashicorp/go-cleanhttp v0.5.2 // indirect
	github.com/hashicorp/go-multierror v1.1.1 // indirect
	github.com/hashicorp/go-retryablehttp v0.6.6 // indirect
	github.com/hashicorp/go-rootcerts v1.0.2 // indirect
	github.com/hashicorp/go-secure-stdlib/parseutil v0.1.6 // indirect
	github.com/hashicorp/go-secure-stdlib/strutil v0.1.2 // indirect
	github.com/hashicorp/go-sockaddr v1.0.2 // indirect
	github.com/hashicorp/hcl v1.0.0 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/juju/errors v1.0.0 // indirect
	github.com/juju/go4 v0.0.0-20160222163258-40d72ab9641a // indirect
	github.com/klauspost/compress v1.15.9 // indirect
	github.com/klauspost/cpuid/v2 v2.1.0 // indirect
	github.com/mailru/easyjson v0.7.7 // indirect
	github.com/matttproud/golang_protobuf_extensions/v2 v2.0.0 // indirect
	github.com/minio/md5-simd v1.1.2 // indirect
	github.com/minio/sha256-simd v1.0.0 // indirect
	github.com/mitchellh/go-homedir v1.1.0 // indirect
	github.com/mitchellh/mapstructure v1.5.0 // indirect
	github.com/moby/patternmatcher v0.5.0 // indirect
	github.com/moby/spdystream v0.2.0 // indirect
	github.com/moby/sys/mountinfo v0.6.2 // indirect
	github.com/moby/sys/sequential v0.5.0 // indirect
	github.com/moby/term v0.0.0-20221205130635-1aeaba878587 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/morikuni/aec v1.0.0 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/mxk/go-flowrate v0.0.0-20140419014527-cca7078d478f // indirect
	github.com/nxadm/tail v1.4.8 // indirect
	github.com/onsi/ginkgo v1.16.5 // indirect
	github.com/opencontainers/go-digest v1.0.0 // indirect
	github.com/opencontainers/image-spec v1.0.3-0.20211202183452-c5a74bcca799 // indirect
	github.com/opencontainers/runc v1.1.12 // indirect
	github.com/opencontainers/selinux v1.11.0 // indirect
	github.com/oxtoacart/bpool v0.0.0-20190530202638-03653db5a59c // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/prometheus/client_model v0.4.1-0.20230718164431-9a2bf3000d16 // indirect
	github.com/prometheus/procfs v0.11.1 // indirect
	github.com/rancher/wrangler v0.7.2 // indirect
	github.com/rs/xid v1.4.0 // indirect
	github.com/ryanuber/go-glob v1.0.0 // indirect
	github.com/safchain/ethtool v0.2.0 // indirect
	github.com/spf13/cobra v1.7.0 // indirect
	github.com/vishvananda/netns v0.0.4 // indirect
	github.com/ziutek/mymysql v1.5.4 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	golang.org/x/mod v0.15.0 // indirect
	golang.org/x/oauth2 v0.12.0 // indirect
	golang.org/x/sync v0.6.0 // indirect
	golang.org/x/sys v0.18.0 // indirect
	golang.org/x/term v0.18.0 // indirect
	golang.org/x/text v0.14.0 // indirect
	golang.org/x/time v0.3.0 // indirect
	golang.org/x/tools v0.18.0 // indirect
	golang.org/x/xerrors v0.0.0-20220907171357-04be3eba64a2 // indirect
	gomodules.xyz/jsonpatch/v2 v2.2.0 // indirect
	google.golang.org/appengine v1.6.7 // indirect
	google.golang.org/genproto v0.0.0-20230803162519-f966b187b2e5 // indirect
	google.golang.org/genproto/googleapis/api v0.0.0-20230726155614-23370e0ffb3e // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20230822172742-b8732ec3820d // indirect
	google.golang.org/protobuf v1.33.0 // indirect
	gopkg.in/asn1-ber.v1 v1.0.0-20181015200546-f715ec2f112d // indirect
	gopkg.in/errgo.v1 v1.0.1 // indirect
	gopkg.in/fsnotify.v1 v1.4.7 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/ini.v1 v1.66.6 // indirect
	gopkg.in/retry.v1 v1.0.3 // indirect
	gopkg.in/square/go-jose.v2 v2.6.0 // indirect
	gopkg.in/tomb.v1 v1.0.0-20141024135613-dd632973f1e7 // indirect
	gopkg.in/warnings.v0 v0.1.2 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	k8s.io/cloud-provider v0.0.0 // indirect
	k8s.io/cluster-bootstrap v0.0.0 // indirect
	k8s.io/klog/v2 v2.120.1 // indirect
	k8s.io/kube-openapi v0.0.0-20240228011516-70dd3763d340 // indirect
	k8s.io/mount-utils v0.0.0 // indirect
	sigs.k8s.io/json v0.0.0-20221116044647-bc3834ca7abd // indirect
	sigs.k8s.io/structured-merge-diff/v4 v4.4.1 // indirect
	sigs.k8s.io/testing_frameworks v0.1.2 // indirect
)

// tag: kubernetes-1.28
replace (
	github.com/godbus/dbus => github.com/godbus/dbus/v5 v5.0.6
	github.com/kubernetes-csi/external-snapshotter => github.com/kubernetes-csi/external-snapshotter/client/v4 v4.0.0
	github.com/onsi/ginkgo/v2 => github.com/onsi/ginkgo/v2 v2.9.1
	github.com/openshift/api => github.com/openshift/api v0.0.0-20191219222812-2987a591a72c
	github.com/prometheus/client_golang => github.com/prometheus/client_golang v1.17.0
	github.com/prometheus/common => github.com/prometheus/common v0.45.0
	github.com/spf13/cobra => github.com/spf13/cobra v1.6.0
	google.golang.org/grpc => google.golang.org/grpc v1.58.3	// vulnerability working
	k8s.io/api => k8s.io/api v0.30.1
	k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.30.1
	k8s.io/apimachinery => k8s.io/apimachinery v0.30.1
	k8s.io/apiserver => k8s.io/apiserver v0.30.1
	k8s.io/cli-runtime => k8s.io/cli-runtime v0.30.0
	k8s.io/client-go => k8s.io/client-go v0.30.1
	k8s.io/cloud-provider => k8s.io/cloud-provider v0.30.0
	k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.30.0
	k8s.io/code-generator => k8s.io/code-generator v0.30.0
	k8s.io/component-base => k8s.io/component-base v0.30.0
	k8s.io/component-helpers => k8s.io/component-helpers v0.30.0
	k8s.io/controller-manager => k8s.io/controller-manager v0.30.0
	k8s.io/cri-api => k8s.io/cri-api v0.30.0
	k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.30.0
	k8s.io/dynamic-resource-allocation => k8s.io/dynamic-resource-allocation v0.30.0
	k8s.io/kms => k8s.io/kms v0.30.0
	k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.30.0
	k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.30.0
	k8s.io/kube-proxy => k8s.io/kube-proxy v0.30.0
	k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.30.0
	k8s.io/kubectl => k8s.io/kubectl v0.30.0
	k8s.io/kubelet => k8s.io/kubelet v0.30.0
	k8s.io/kubernetes => k8s.io/kubernetes v1.30.0
	k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.30.0
	k8s.io/metrics => k8s.io/metrics v0.30.0
	k8s.io/mount-utils => k8s.io/mount-utils v0.30.0
	k8s.io/pod-security-admission => k8s.io/pod-security-admission v0.30.0
	k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.30.0
	sigs.k8s.io/structured-merge-diff => sigs.k8s.io/structured-merge-diff v0.0.0-20190302045857-e85c7b244fd2
)
