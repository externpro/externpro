# install data source name (DSN)
#  odbcinst: [Action]i:install [Object]s:data_source [Options]h:user_dsn,f:template_file
#  odbcinst creates ~/.odbc.ini
COPY odbc.ini.test /home/${USERNAME}/
RUN odbcinst -i -s -h -f /home/${USERNAME}/odbc.ini.test \
  && rm /home/${USERNAME}/odbc.ini.test
# expose port
EXPOSE 8443
