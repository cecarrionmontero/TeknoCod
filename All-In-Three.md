# Deploy en AIT (All-In-Three)

<figure><img src="https://3667390847-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FqQ4bFJhI3nNWFv4zXBw2%2Fuploads%2FnBmpk3Bh3Tg9lcB0hoAA%2Fimage.png?alt=media&#x26;token=350e7075-6187-4534-b4c4-2ea76c570df4" alt=""><figcaption></figcaption></figure>

## OMniLeads en un Cluster Horizontal <a href="#aio-deploy" id="aio-deploy"></a>

Mediante este método de instalación, es posible desplegar la Suite de OMniLeads en una disposición de Cluster Horizontal, agrupando contenedores según el siguiente esquema:

<figure><img src="https://3667390847-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FqQ4bFJhI3nNWFv4zXBw2%2Fuploads%2Fe0GBYDn3oRMN8wLOVc0d%2Fimage.png?alt=media&#x26;token=17bc0341-6b77-4186-8aeb-2311036432ed" alt=""><figcaption></figcaption></figure>

Para ello, se requiren de tres instancias de Linux (con cualquier sistema operativo moderno) con acceso a Internet. Dado que Ansible utiliza un proceso de conexión SSH (secure shell) para acceder a la instancia y ejecutar su playbook, es requisito obligatorio contar con la llave pública SSH y el archivo known\_hosts configurado oportunamente en cada host.

### Comprendiendo el Archivo de Inventario <a href="#pstn_emulator" id="pstn_emulator"></a>

Debajo se especifica un archivo de inventario genérico para un típico despliegue en el esquema AIT. **En su primera sección** se listan los diferentes hosts por tenant y por tipo de deployment a ejecutar (cluster\_instances):

<figure><img src="https://3667390847-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FqQ4bFJhI3nNWFv4zXBw2%2Fuploads%2FIFoXjZmxfZjAq75xgbYg%2Fimage.png?alt=media&#x26;token=727a9c56-7e1d-41b4-bc43-9c6ca4545fcf" alt=""><figcaption></figcaption></figure>

**En su segunda sección**, el archivo de inventario permite parametrizar variables de entorno necesarias para la acción. <mark style="color:red;">Nota: Por default, todas ellas afectan de manera directa a TODAS las instancias declaradas, a menos que una variable (o grupo de variables) sea especificada en la sección del host (o grupo de hosts) en cuestión.</mark>

Finalmente, **la última sección** comprende a la agrupación de hosts en función de la arquitectura seleccionada. En nuestro caso, bajo las etiquetas *omnileads\_data, omnileads\_voice y omnileads\_app* se listarian los hosts correspondientes a la/s instancia/s que se pretende/n deployar.

Debajo se muestra un ejemplo:

```
#############################################################################################################
# -- In this section the hosts are grouped based on the type of deployment (AIO, Cluster & Cluster HA).     #
#############################################################################################################

omnileads_aio: 
  hosts:
    #tenant_example_1:
    #tenant_example_2:
    #tenant_example_3:
    #tenant_example_4:
    #tenant_example_7_aio_A:
    #tenant_example_7_aio_B:

################################################    
omnileads_data:   ####### <<<<<<<<<<<< USTED ESTA AQUI! <<<<<<<<<<<<<<<
  hosts:
    #tenant_example_5_data:  
    
omnileads_voice:
  hosts:
    #tenant_example_5_voice:

omnileads_app:
  hosts:
    #tenant_example_5_app:

################################################
ha_omnileads_sql:
  hosts:
    #tenant_example_7_sql_A:
    #tenant_example_7_sql_B:

```

### Ahora sí, manos a la Obra! <a href="#pstn_emulator" id="pstn_emulator"></a>

Como primer paso, procedemos a crear la carpeta **instances** en el directorio raíz. Seguido a ello, en su interior crearemos una subcarpeta donde alojaremos el archivo de inventario de ejemplo provisto por el repositorio:

<mark style="color:red;">Nota: Si bien estamos dentro de un repositorio versionado, el nombre "instances" está reservado y es ignorado por el repositorio a partir del archivo .gitignore.</mark>

<pre><code><strong>mkdir instances
</strong>mkdir instances/omlcluster
cp inventory.yml instances/omlcluster
</code></pre>

De acuerdo a lo comprendido en las secciones del archivo de inventario, declararemos nuestra futura instancia de OMniLeads en AIT en la sección de cluster. En nuestro caso, usaremos el nombre de ejemplo "tala" para definir el tenant:

```
cluster_instances:
  children:
    tala:
      hosts:
        tala_data:
          ansible_host: 172.16.101.41
          omni_ip_lan: 172.16.101.41
          ansible_ssh_port: 22
        tala_voice:
          ansible_host: 172.16.101.42
          omni_ip_lan: 172.16.101.42
          ansible_ssh_port: 22
        tala_app:
          ansible_host: 172.16.101.43
          omni_ip_lan: 172.16.101.43
          ansible_ssh_port: 22
      vars:
        tenant_id: tala
        data_host: 172.16.101.41
        voice_host: 172.16.101.42
        application_host: 172.16.101.43
        infra_env: lan

```

Es importante especificar el escenario en el que se trabajará. Si usaremos un VPS, el entorno a configurar será "cloud", y será "lan" si se usa una Virtual Machine. Definiremos para ello la variable de entorno **infra\_env** según sea el caso: "cloud" (por default) o "lan".

Las variables **tenant\_id** (nombre del tenant), **ansible\_host** (dirección IP que deberá alcanzar Ansible para ejecutar la Playbook) y **omni\_ip\_lan** (dirección IP privada de la interface lan) son mandatorias para especificar al tenant. A su vez, las variables **bucket\_url** y **postgres\_host** deben quedar comentadas, de manera tal que tanto PostgreSQL como MinIO Object Storage sean instaladas dentro de la instancia \_data.

Finalmente, debemos asegurarnos de que la última sección contenga al tenant dentro de sus grupos correspondientes (\_*data, \_*&#x76;oice y \_app). Debajo un ejemplo sobre nuestro tenant "tala":

```
#############################################################################################################
# -- In this section the hosts are grouped based on the type of deployment (AIO, Cluster & Cluster HA).     #
#############################################################################################################

omnileads_aio:
  hosts:
    #tenant_example_1:
    #tenant_example_2:
    #tenant_example_3:
    #tenant_example_4:

omnileads_data:
  hosts:
    tala_data:    
    
omnileads_voice:
  hosts:
    tala_voice:

omnileads_app:
  hosts:
    tala_app:
```

Con el archivo de inventario configurado, procedemos a ejecutar la acción de instalación del nuevo tenant:

```
./deploy.sh --action=install --tenant=omlcluster
```

En el apartado de [First Login](https://docs.omnileads.net/instalacion-de-omnileads/first-login), se pueden revisar los pasos necesarios para obtener el primer acceso a la UI con usuario Administrador.

Para mayor información, sugerimos visitar la documentación expuesta en el [repositorio oficial del proyecto](https://gitlab.com/omnileads/omldeploytool).
