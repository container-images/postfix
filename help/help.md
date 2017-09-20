% POSTFIX(1) Container Image Pages
% Petr Hracek
% September 19, 2017

# NAME
{{ spec.envvars.name }} - {{ spec.short_description }}

# DESCRIPTION
{{ spec.description }}

# USAGE
To get the memcached container image on your local system, run the following:

    docker pull hub.docker.io/modularitycontainers/{{ spec.envvars.name }}

  
# ENVIRONMENT VARIABLES

The image recognizes the following environment variables that you can set
during initialization be passing `-e VAR=VALUE` to the Docker run command.

|    Variable name         |      Description                              |
| :----------------------- | --------------------------------------------- |
|  `POSTFIX_DEBUG_MODE`    | Turn on debug mode                            |  
|  `ENABLE_TLS`            | Enables TLS used in postfix                   |
|  `ENABLE_IMAP`           | Enables IMAP for using together with dovecot  |

        
# SECURITY IMPLICATIONS
Lists of security-related attributes that are opened to the host.

-p 25:10025
    Opens container port 10025 and maps it to the same port on the host.

# SEE ALSO
Postfix page
<https://postfix.org/>
