#!/bin/bash

OC=$(which oc)
test -n "$OC" || exit 1
BACKUPDIR="/var/backups/openshift"
OWNER='root'
MODE='0700'
test -d ${BACKUPDIR} || mkdir -p ${BACKUPDIR} && install -d -m ${MODE} -o ${OWNER} -g ${OWNER} ${BACKUPDIR}

test -x $OC || exit 1
$OC login -u system:admin

for PROJECT in $($OC get projects -o custom-columns=name:.metadata.name --no-headers)
do
  cd ${BACKUPDIR}
  test -d ${BACKUPDIR}/${PROJECT} || install -d -m ${MODE} -o ${OWNER} -g ${OWNER} ${BACKUPDIR}/${PROJECT}
  cd ${BACKUPDIR}/${PROJECT}
  $OC project $PROJECT
  $OC get -o yaml --export all > project.yaml
  for object in rolebindings serviceaccounts secrets imagestreamtags cm egressnetworkpolicies rolebindingrestrictions limitranges resourcequotas pvc templates cronjobs statefulsets hpa deployments replicasets poddisruptionbudget endpoints networkpolicy
  do
    $OC get -o yaml --export $object > $object.yaml
  done
done
