#!/bin/bash
aimsproject=aimsv2

searchpod=""
podname=""

if [ ! -z "$1" ]; then
	aimsproject=$1
fi

echo "Install on project ${aimsproject}"

pod_status()
{
  status=""
  podname=""
  retries=0
  while [ -z "${podname}" ]
  do
    status="$(oc get pods | grep ${searchpod} |  awk -F ' ' '{print $3}')"
    if [ "${status}" == "Running" ]; then
    	podname="$(oc get pods | grep ${searchpod} |  awk -F ' ' '{print $1}')"
    else
    	retries=$((retries+1))	
		echo -e "\nWaiting for the pod to start ${searchpod}... \n"    
    	read -t 8 -p "Retries ${retries}/10"
    	if [[ "$retries" == '10' ]]; then
                break
        fi
    fi
  done

  if [ -z "${podname}" ]; then
	echo -e "\nNot running pod ${searchpod}.\n"
  else
    echo -e "\nRunning pod ${podname}.\n"
  fi
}


project="$(oc projects 2>/dev/null |  grep 'You have')"
if [ ! -z "${project}" ]; then
  
  app="$(oc projects | grep '\"'${aimsproject}'\"')"
  #echo "Project aims: ${app}"
  if [ -z "${app}" ]; then
  	echo -e "Creating project ${aimsproject}\n"
  	oc new-project ${aimsproject} --display-name 'AIMSv2'
  elif [ "${project}" != "${aimsproject}" ]; then  
  	echo -e "Switching to project ${aimsproject}\n"
  	oc project ${aimsproject}
  fi
    
  project="$(oc project 2>/dev/null |  awk -F '"' '{print $2}')"  
  echo "On project: ${project}"
  
  if [ "${project}" == "${aimsproject}" ]; then
  
    oc adm policy add-scc-to-user privileged -z default -n ${project}
    
    cp aims.yaml aimsv2.yaml
    
    sg='s/app-name/'${project}'/g'
    sed -i ${sg} aimsv2.yaml
        
    suppgrp="$(oc describe project ${project} | grep 'supplemental-groups' | awk -F '=' '{print $2}' | awk -F '/' '{print $1}')"
        
	if [ ! -z "${suppgrp}" ]; then
		sg='s/supp-group/'${suppgrp}'/g'
	else
		sg='s/[supp-group]//g'
    fi
    
	sed -i ${sg} aimsv2.yaml
	
    oc create -f aimsv2.yaml       
    
    searchpod='aims\-db\-' 
    pod_status
    aimsdb=${podname}
    searchpod='comm\-db\-' 
    pod_status
    commdb=${podname}
  
	if [ ! -z "${podname}" ]; then
      echo -e "\nSynchronizing database:\n"
      oc rsync aims-db/init ${aimsdb}:/docker-entrypoint-initdb.d
      oc rsync comm-db/init ${commdb}:/docker-entrypoint-initdb.d
      echo -e "\nRenew database pods:\n"
      oc delete pods ${aimsdb}
      oc delete pods ${commdb}
  
      searchpod='aims\-db\-' 
      pod_status
      searchpod='comm\-db\-' 
      pod_status
  

      echo -e "\nSynchronizing routes:\n"
    
      aimshttp="$(oc get routes 2>/dev/null | grep 'aims-http' | awk -F ' ' '{print $2}')"
      aimsws="$(oc get routes 2>/dev/null | grep 'aims-ws' | awk -F ' ' '{print $2}')"
      aimsgql="$(oc get routes 2>/dev/null | grep 'aims-gql' | awk -F ' ' '{print $2}')"
    
      echo ${aimshttp}
      echo ${aimsws}
      echo -e "${aimsgql} \n"
    
      oc get -o yaml  deployment/aims-http > aimsv2-http.yaml
      oc get -o yaml  deployment/aims-ws > aimsv2-ws.yaml
    
      sg='s/aims-gql.microsafe.com.mx/'${aimsgql}'/g'
      sed -i ${sg} aimsv2-http.yaml    
      sg='s/aims-ws.microsafe.com.mx/'${aimsws}'/g'
      sed -i ${sg} aimsv2-http.yaml    
      sg='s/aims-http.microsafe.com.mx/'${aimshttp}'/g'
      sed -i ${sg} aimsv2-ws.yaml
           
      oc replace  deployment/aims-http -f aimsv2-http.yaml
      oc replace  deployment/aims-ws -f aimsv2-ws.yaml
    
      searchpod='aims\-http\-' 
      pod_status
      searchpod='aims\-ws\-' 
      pod_status
    
      echo -e "\nStatus of project ${project}:\n"
      oc status  
      rm aimsv2*.yaml
    else
  	  echo "Not found pods:\n"
  	  oc get pods
  	fi
  else
  	echo "Project not found: ${aimsproject}."
  fi
else
 echo -e "\n Not logged in."
fi

