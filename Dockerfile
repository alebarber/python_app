FROM jenkins/jenkins:2.479.2-jdk17
USER root
# Instalar lsb-release
RUN apt-get update && apt-get install -y lsb-release

# Agregar la clave pública de Docker
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg

# Agregar Docker como repositorio e instalar Docker CLI
RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli


# Crear el grupo 'docker' si no existe
RUN groupadd -f docker

# Agregar el usuario 'jenkins' al grupo 'docker'
RUN usermod -aG docker jenkins

# Cambiar el propietario de /var/run/docker.sock al grupo docker (si se necesita)
# RUN chown root:docker /var/run/docker.sock

# Asegurarse de que el socket de Docker sea accesible por el grupo 'docker'
#RUN chmod 660 /var/run/docker.sock



# Cambiar al usuario jenkins para no usar root
USER jenkins

# Instalar los complementos de Jenkins necesarios
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
