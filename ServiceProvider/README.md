# Containerized Shibboleth Service Provider


## Build and Run
```
[PowerShell]

Rocky Linux:
docker build --file rockylinux.dockerfile --tag shibboleth:1.0.0 --progress plain --no-cache . 2>&1 | Tee-Object shibboleth_rocky_build.log

Ubuntu:
docker build --file ubuntu.dockerfile --tag shibboleth:1.0.0 --progress plain --no-cache . 2>&1 | Tee-Object shibboleth_ubuntu_build.log

[Linux Shell]

Rocky Linux:
docker build --file rockylinux.dockerfile --tag shibboleth:1.0.0 --progress plain --no-cache . 2>&1 | tee shibboleth_rocky_build.log

Ubuntu:
docker build --file ubuntu.dockerfile --tag shibboleth:1.0.0 --progress plain --no-cache . 2>&1 | tee shibboleth_ubuntu_build.log

docker run -dit --name shibboleth-sp -p 80:80 -p 443:443 --hostname=YOUR_SHIB_HOSTNAME shibboleth:1.0.0

[Docker Compose]
docker compose up -d
docker compose down -v
```

## Reference Articles and Basic Test

- For installation instructions, refer to [Installing the Shibboleth SP from RPM](https://shibboleth.atlassian.net/wiki/spaces/SP3/pages/2065335566/RPMInstall).
- For basic test and configuration process, refer to University of Washington's articles:
    - [Install Shibboleth Service Provider on Linux and Apache](https://wiki.cac.washington.edu/display/infra/Install+Shibboleth+Service+Provider+on+Linux+and+Apache)
    - [Configure a Shibboleth SP to Use the InCommon Metadata Aggregate File](https://wiki.cac.washington.edu/display/infra/Configure+a+Shibboleth+SP+to+Use+the+InCommon+Metadata+Aggregate+File)
- In the Shibboleth container, run:
    - `shibd -t`, your should get `overall configuration is loadable, check console for non-fatal problems`.
    - `apachectl configtest` in Rocky Linux or `apache2ctl configtest` in Ubuntu, you should get `Syntax OK`.
- Assuming you're running the container on your localhost, visit:
    - `http://localhost`, should show you the default apache landing page.
    - `http://localhost/Shibboleth.sso/Session`, you should see a message `A valid session was not found.`.
    - `http://localhost/Shibboleth.sso/Status`, you should see Shibboleth's default XML page.
- **Persistent Files**
    - A persistent volume is available at `/opt/config`, which can be used to persist changes made to virtual host configs, `shibboleth2.xml`, etc., using symbolic links.

## Troubleshooting

### Generate Keys:
```
# Generate signing keys
shib-keygen
mv /etc/shibboleth/sp-cert.pem /etc/shibboleth/sp-signing-cert.pem
mv /etc/shibboleth/sp-key.pem /etc/shibboleth/sp-signing-key.pem

# Generate encrypt keys
shib-keygen
mv /etc/shibboleth/sp-cert.pem /etc/shibboleth/sp-encrypt-cert.pem
mv /etc/shibboleth/sp-key.pem /etc/shibboleth/sp-encrypt-key.pem
```

### Rocky Linux
- In the `shibboleth2.xml.test` file, the `handlerSSL` is set to `false` so that the basic tests can be performed using HTTP. If it's left as `true`, you'll get an 404 error or the `Not Found The requested URL was not found on this server.` message.
- The `<3>listener failed to initialize` error when trying to restart the `shibd` process.
    - Delete the `shibd.sock` using the `rm /var/run/shibboleth/*` command, and then run `shibd restart`.
- List all loaded and enabled apache modules: `httpd -M`
- Check whether your system is 32 bit or 64 bit (for choosing the 32/64 bit shibboleth package): `uname -m`
- Restart the apache service: `httpd restart`
- Log location:
    - `shibd.log`: /var/log/shibboleth
    - Apache `access_log` and `error_log`: /var/log/httpd

### Ubuntu
- Use `service shibd status` and `service apache2 status` to check service status.
- Use `service shibd restart`, `service apache2 restart` to restart services.
- Use `apache2ctl -M` to list all modules.
- Log location:
    - `shibd.log`: /var/log/shibboleth
    - Apache `access.log` and `error.log`: /var/log/apache2