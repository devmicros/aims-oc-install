# Instalador de la aplicación AIMSv2 en OpenShift v4.12
AIMSv2 gestiona los dispositivos en línea de chapas randómicas.
Este es un instalador del proyecto AIMSv2 en una instancia de Openshift.

## Prerrequisitos

1. Terminal GNU/Linux con las herramientas sed, awk y grep.
2. Asignar los permisos necesarios a los archivos de instalación.
3. Tener instalado el binario OpenShift CLI (oc) versión 4.12 en GNU/Linux.
4. Estar conectado como usuario con rol de Cluster Admin.

### Descripción del instalador
    Crea un nuevo proyecto llamado [aimsv2] con el nombre visible de [AIMSv2]
    Dentro de la aplicación se crean:
        -8 Deployments
        -8 Pods
        -4 PersistentVolumeClaims
        -8 Services
        -3 Routes
    
### Consideraciones al instalar en un proyecto ya existente.
    Para reemplazar el nombre del proyecto por defecto, debe usar un argumento en el instalador.
    
### Descripción de archivos de instalación y permisos necesarios

**install.sh**:     Script Bash con instrucciones para la instalación en un cluster de Openshift.
					Permisos: [Permisos de ejecución]
**aims-db**:        Directorio con script de la base de datos de la aplicación.
					Permisos: [Permisos de lectura]
**comm-db**:        Directorio con script de la base de datos del sistema de encolamiento de la aplicación.
					Permisos: [Permisos de lectura]
**aims.yaml**:      Configuración del proyecto de la aplicación AIMSv2.
					Permisos: [Permisos de escritura]
**oc**:             Binario de OpenShift CLI de la versión 4.12.
					Permisos: [Permisos de ejecución]

### Asignar permisos de ejecución al script [install.sh]
		chmod +x install.sh

#### Instalación

1. Inicie sesión en Openshift con un rol Cluster Admin desde la terminal linux.
    Ejemplo:
        oc login https://192.168.0.115:5555 --token=J08qdaXBipKif9qbjtneni0Dq47feMm3ayuoc
        
2. Ejecute el script del instalador para crear o cambiarse al proyecto [aimsv2]:

        ./install.sh
        
   En caso de usar un proyecto diferente a [aimsv2], use el nombre de su proyecto como argumento.
   Por ejemplo para crear o usar el proyecto [miproyecto], ejecute el siguiente comando:
    
        ./install.sh miproyecto


