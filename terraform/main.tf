terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

# Configuración del proveedor Docker
provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

# Crear red para el contenedor Jenkins (si no existe)
resource "docker_network" "jenkins_network" {
  name = "jenkins"
}

resource "docker_container" "jenkins" {
  name  = "jenkins-blueocean"
  image = "jenkins-custom"  # Utiliza la imagen personalizada que creaste con Dockerfile

  restart = "on-failure"  # Reinicia el contenedor si falla

  # Conectar a la red Docker llamada "jenkins"
  network_mode = docker_network.jenkins_network.name

  # Variables de entorno
  env = [
    "DOCKER_HOST=unix:///var/run/docker.sock"
  ]

  # Mapeo de puertos
  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }

  # Conectar el contenedor de Jenkins al socket de Docker del host
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"  # Esto monta el socket Docker para Jenkins
  }

  # Volumen persistente para los datos de Jenkins
  volumes {
    container_path = "/var/jenkins_home"
    read_only      = false
  }


  # Habilitar privilegios si es necesario (por ejemplo, para ejecutar Docker dentro del contenedor)
  privileged = true
}

resource "docker_container" "docker_in_docker" {
  name  = "docker_in_docker"
  image = "docker:20.10.12-dind"
  privileged = true
  ports {
    internal = 5000
    external = 5000
  }
  # Conectar el contenedor DinD a la misma red Docker que Jenkins
  network_mode = docker_network.jenkins_network.name
  env = [
    "DOCKER_TLS_CERTDIR="  # Esto desactiva TLS si no es necesario.
  ]
}
