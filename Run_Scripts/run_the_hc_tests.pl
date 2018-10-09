## See http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Automated+EG+Healthchecks

codedir=/nfs/panda/ensemblgenomes/production/ensj-healthcheck

## screen
## become ensgen
## bshell

sh run_division_check.sh \
    -e epldb \
    -d prunus_persica_core_31_84_1 \
    -g EGCoreIntegrity \
    -T ProteinTranslation \
    -s prod2    

sh run_division_check.sh \
    -e epldb \
    -g EGCoreIntegrity \
    -T ProteinTranslation \
    -s prod2    




__END__



## Run a specific group of tests on a single DB:
$codedir/run_division_check.sh
    
    &> test1.pp

    --production.database ensembl_production \
    --output.host mysql-eg-pan-prod.ebi.ac.uk \
    --output.port 4276 \
    --output.user ensro \
    &> test2.pp


## Run a specific group of tests on all DBs in the division (needs the
## production db and (output) server to be configured). Lets only
## output 'Problems'...
$JAVA_HOME/bin/java \
    -Xmx1500m \
    -Djava.util.logging.config.file=config/logger/logging.properties \
    org.ensembl.healthcheck.ConfigurableTestRunner \
    $(mysql-prod-2 --details script) \
    --reporterType Text \
    -g EGCoreIntegrity \
    --test_divisions EPl \
    --production.database ensembl_production \
    --output.host mysql-eg-pan-prod.ebi.ac.uk \
    --output.port 4276 \
    --output.user ensro \
    --output Problem \
    &> testy.outmc








INFO: The options available are:

[--conf -c value...]  : Name of one or many configuration
        files. Parameters in configuration files override each
        other. If a parameter is provided in more than one file, the
        first occurrence is used.

[--databaseURL value] : Parameter used in
        org.ensembl.healthcheck.testcase.EnsTestCase

        [--dbtype value]                   : If set, this will be used as the type for all databases.

        [--driver value]                   : Parameter used in org.ensembl.healthcheck.testcase.EnsTestCase

        [--driver1 value]                  : Driver for server 1 (support for multiple staging servers in Ensembl)

        [--driver2 value]                  : Driver for server 2 (support for multiple staging servers in Ensembl)

        [--endSession value]               : Flag to run an empty testrunnerUsed to mark the end of a parallel run

        [--exclude_groups -G value...]     : Specify which groups of tests should not be run. Fully qualified class names can be used as well as their short names.

        [--exclude_tests -T value...]      : Specify which tests should not be run. Fully qualified class names can be used as well as their short names.

        [--file.separator value]           : Parameter used in org.ensembl.healthcheck.testcase.EnsTestCase

        [--funcgen_schema.file value]      : Parameter used only in and org.ensembl.healthcheck.testcase.funcgen.CompareFuncgenSchema

        [--help -h]                        : display help

        [--host -h value]                  : The host for the database server you wish to connect to.

        [--host1 value]                    : Host for server 1 (support for multiple staging servers in Ensembl)

        [--host2 value]                    : Host for server 2 (support for multiple staging servers in Ensembl)

        [--ignore.previous.checks value]   : Parameter used only in org.ensembl.healthcheck.testcase.generic.ComparePreviousVersionExonCoords, org.ensembl.healthcheck.testcase.generic.ComparePreviousVersionBase and org.ensembl.healthcheck.testcase.generic.GeneStatus

        [--include_groups -g value...]     : Specify which groups of tests should be run. Fully qualified class names can be used as well as their short names.

        [--include_tests -t value...]      : Specify which tests should be run. Fully qualified class names can be used as well as their short names.

        [--master.funcgen_schema value]    : Parameter used in org.ensembl.healthcheck.testcase.funcgen.CompareFuncgenSchema

        [--master.schema value]            : Parameter used only in org.ensembl.healthcheck.testcase.generic.CompareSchema, and org.ensembl.healthcheck.testcase.funcgen.CompareFuncgenSchema

        [--master.variation_schema value]  : Parameter used only in master.variation_schema

        [--output -o value]                : Specify the level of output that will be used. The allowed options are "All", "None", "Problem", "Current", "Warning" and "Info", .

        [--output.database value]          : The name of the database where the results of the healthchecks are written to, if the database reporter is used.

        [--output.driver value]            : The driver for the database where the results of the healthchecks are written to, if the database reporter is used.

        [--output.host value]              : The name of the database where the results of the healthchecks are written to, if the database reporter is used.

        [--output.password value]          : The password for the database where the results of the healthchecks are written to, if the database reporter is used.

        [--output.port value]              : The port of the database where the results of the healthchecks are written to, if the database reporter is used.

        [--output.release value]           : Gets written into the session table for describing the test session, if the database reporter is used.

        [--output.schemafile value]        : If output.database does not exist, it will be created automatically. This file should have the SQL commands to create the schema. Please remember that hashes (#) are not allowed to start comments in SQL. Use two dashes "--" at the beginning of a line instead. If the configuratble testrunner can't find this file from the current working directory, it will search for it in the classpath.

        [--output.user value]              : The user name for the database where the results of the healthchecks are written to, if the database reporter is used.

        [--password value]                 : Parameter used in org.ensembl.healthcheck.testcase.EnsTestCase

        [--password1 value]                : Password for server 1 (support for multiple staging servers in Ensembl)

        [--password2 value]                : Password for server 2 (support for multiple staging servers in Ensembl)

        [--perl value]                     : Parameter used only in org.ensembl.healthcheck.testcase.AbstractPerlBasedTestCase

        [--port -P value]                  : The port for the database server you wish to connect to.

        [--port1 value]                    : Port for server 1 (support for multiple staging servers in Ensembl)

        [--port2 value]                    : Port for server 2 (support for multiple staging servers in Ensembl)

        [--production.database value]      : The name of the Ensembl production database to use to retrieve division information. Assumed to be on the same server as the output databases.

        [--repair value]                   : Allow the tests to try to repair the database (if they can)

        [--reporterType -R value]          : Specify the reporter type that will be used. The allowed options are "Database" and "Text".

        [--schema.file value]              : Parameter used only in org.ensembl.healthcheck.testcase.generic.CompareSchema,

        [--secondary.database value]       : Some tests require a second database containing the previous release. This configures the database name for the second database server.

        [--secondary.driver value]         : Some tests require a second database containing the previous release. This configures the driver for the second database server.

        [--secondary.host value]           : Some tests require a second database containing the previous release. This configures the hostname of the second database server.

        [--secondary.password value]       : Some tests require a second database containing the previous release. This configures the password for the second database server.

        [--secondary.port value]           : Some tests require a second database containing the previous release. This configures the port of the second database server.

        [--secondary.user value]           : Some tests require a second database containing the previous release. This configures the user name for the second database server.

        [--sessionID value]                : The session to add these results forUsed in parallel run

        [--species value]                  : If set, this will be used as the species for all databases, overriding anything thename or meta table of the database may indicate.

        [--testRegistryType -r value]      : Specify the type of test registry that will be used. The allowed options are "Discoverybased" and "ConfigurationBased"

        [--test_databases -d value...]     : Name of databases that should be tested (e.g.: ensembl_compara_bacteria_5_58). If there is more than one database, separate with spaces. Any configured tests will be run on these databases. Does not support same format as output.databases!

        [--test_divisions -D value...]     : Names of division to which databases to test should belong e.g. EPl or EnsemblPlants. This option requires the production database to be set up.

        [--user value]                     : Parameter used in org.ensembl.healthcheck.testcase.EnsTestCase

        [--user.dir value]                 : Parameter used in org.ensembl.healthcheck.testcase.EnsTestCase

        [--user1 value]                    : User for server 1 (support for multiple staging servers in Ensembl)

        [--user2 value]                    : User for server 2 (support for multiple staging servers in Ensembl)

        [--variation_schema.file value]    : Parameter used only in org.ensembl.healthcheck.testcase.variation.CompareVariationSchema

[dbolser@ebi-003 ensj-healthcheck]$ 

