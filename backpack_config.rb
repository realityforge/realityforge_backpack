Backpack.context.add_hook(BackpackPlus::TravisHook.new)

Backpack.organization('realityforge') do |o|
  o.is_user_account = true

  o.repository('realityforge_backpack', :description => 'Project for managing realityforge repositories.')

  o.repository('buildr_plus', :description => 'A simple set of extensions that patch and customize buildr to our requirements.', :tags => %w(notify:stock))
  o.repository('dbt', :description => 'A simple tool designed to simplify the creation, migration and deletion of databases.', :homepage => 'http://realityforge.github.io/dbt', :tags => %w(notify:stock travis))
  o.repository('noft', :description => 'A tool to extract svg icons from icon fonts and generate helpers to render the icons.', :tags => %w(notify:stock travis))
  o.repository('domgen', :description => 'Domgen generates code from a simple domain model leaving the developer to focus on implementing high-value features of the application.', :homepage => 'http://realityforge.org/domgen/', :tags => %w(notify:stock))
  o.repository('kinjen', :description => 'A library of groovy scripts to use from a Jenkinsfile', :tags => %w(notify:stock))
  o.repository('redfish', :description => 'A lightweight library for configuring GlassFish/Payara servers.', :tags => %w(notify:stock travis))
  o.repository('rptman', :description => 'This tool includes code and a suite of rake tasks for uploading SSRS reports to a server. The tool can also generate project files for the "SQL Server Business Intelligence Development Studio".', :tags => %w(notify:stock))
  o.repository('resgen', :description => 'A tool to generate resource descriptors from resource assets.', :tags => %w(notify:stock travis))
  o.repository('swung_weave', :description => 'Bytecode weaving of annotated UI classes to ensure all UI updates occur in the Event Dispatch Thread', :tags => %w(notify:stock))
  o.repository('zim', :description => 'Simple tool that performs mass transformations across codebases')

  o.repository('assets-font-awesome', :description => 'An extraction of all the icons from font-awesome.')

  o.repository('guiceyloops', :description => 'GuiceyLoops is a minimalistic library for aiding the testing of JEE applications using Guice.', :tags => %w(notify:stock travis))

  o.repository('keycloak-converger', :description => 'Converge the state of a keycloak realm', :tags => %w(travis))
  o.repository('keycloak-domgen-support', :description => 'KeyCloak Domgen Support', :tags => %w(travis))
  o.repository('glassfish-domain-patcher', :description => 'GlassFish Domain Patcher', :tags => %w(travis))
  o.repository('glassfish-timers', :description => 'GlassFish timers database sql', :tags => %w(travis))

  o.repository('backpack', :description => 'A simple tool to manage GitHub organisations using declarative DSL')

  o.repository('dbdiff', :description => 'List differences between databases', :tags => %w(travis))
  o.repository('gelf4j', :description => 'Library for sending log messages using the GELF protocol using CLI, Log4j, JDK Logging and Logback', :homepage => 'https://github.com/realityforge/gelfj', :tags => %w(travis))
  o.repository('geolatte-geom-jpa', :description => 'Converter for mapping Geolatte geometry types to JPA attributes', :tags => %w(travis))
  o.repository('getopt4j', :description => 'A library to parse command line arguments according to the GNU style', :tags => %w(travis))

  o.repository('gwt-appcache', :description => 'GWT AppCache Support Library', :homepage => 'http://realityforge.github.io/gwt-appcache/', :tags => %w(travis), :issues => true)
  o.repository('gwt-appcache-example', :description => 'A simple application demonstrating the use of the gwt-appcache library')
  o.repository('gwt-cache-filter', :description => 'A servlet filter that adds the appropriate http caching headers to GWT generated files based on *.cache.* and *.nocache.* naming patterns.', :issues => true)
  o.repository('gwt-cache-filter-example', :description => 'A simple application demonstrating the use of the gwt-cache-filter library')
  o.repository('gwt-contacts', :description => 'A version of the gwt "contacts" example from google')
  o.repository('gwt-datatypes', :description => 'A simple library that consolidates the common data types and associated infrastructure used across a range of GWT projects.')
  o.repository('gwt-eventsource', :description => 'GWT EventSource Library', :issues => true)
  o.repository('gwt-eventsource-example', :description => 'A simple application demonstrating the use of the gwt-eventsource library', :issues => true)
  o.repository('gwt-ga', :description => 'A simple GWT library for interacting with Google Analytics')
  o.repository('gwt-keycloak', :description => 'A simple library to provide keycloak support to GWT', :issues => true)
  o.repository('gwt-lognice', :description => 'A super simple gwt library that makes the log messages nicer.')
  o.repository('gwt-mmvp', :description => 'A micro MVP library that enhances the Activities and Places library.')
  o.repository('gwt-gin-extensions', :description => 'Simple utilities when using gin injection framework.')
  o.repository('gwt-online', :description => 'A gwt wrapper to determine when the browser is online')
  o.repository('gwt-online-example', :description => 'A simple application demonstrating the use of the gwt-online library')
  o.repository('gwt-packetio-example', :description => 'A sample application that demonstrates the use of the gwt-packetio library.')
  o.repository('gwt-property-source', :description => 'Provides a convenient way of compiling GWT property values into your module.', :issues => true)
  o.repository('gwt-property-source-example', :description => 'A sample application that demonstrates the use of the gwt-property-source', :issues => true)
  o.repository('gwt-webpoller', :description => 'A gwt library to simplify periodic polling and long-poll based transport layers', :issues => true)
  o.repository('gwt-webpoller-example', :description => 'A simple application demonstrating the use of the gwt-webpoller library', :issues => true)
  o.repository('gwt-websockets', :description => 'GWT WebSocket Library', :issues => true)
  o.repository('gwt-websockets-example', :description => 'A simple application demonstrating the use of the gwt-websockets library', :issues => true)
  o.repository('housekeeping-scripts', :description => 'Sets of scripts used to perform housekeeping at home and in the wild')
  o.repository('idea-configuration', :description => 'A repository containing configuration for IntelliJ IDEA')

  o.repository('jndikit', :description => 'a toolkit designed to help with the construction of JNDI providers')
  o.repository('napts', :description => 'Quiz application that records and tracks students progress across a number of subjects')
  o.repository('proxy-servlet', :description => 'A servlet for creating proxy services')
  o.repository('reality-core', :description => 'Basic classes used to help defining libraries.')
  o.repository('reality-facets', :description => 'A basic toolkit for binding facets or extensions to model objects.')
  o.repository('reality-generators', :description => 'A basic toolkit for abstracting the generation of files from model objects.')
  o.repository('reality-mash', :description => 'A library providing the mash data type.')
  o.repository('reality-model', :description => 'Utility classes for defining a domain model.')
  o.repository('reality-naming', :description => 'A library to convert names between different naming conventions.')
  o.repository('reality-orderedhash', :description => 'A library providing a hash with preserved order and some array-like extensions.')
  o.repository('realityforge.github.io', :description => 'My personal website and blog', :homepage => 'https://realityforge.github.io')
  o.repository('replicant', :description => 'Client-side state representation infrastructure for GWT')
  o.repository('replicant-example', :description => 'A simple application demonstrating the use of the replicant library')
  o.repository('rest-criteria', :description => 'A simple library for parsing criteria in rest services')
  o.repository('rest-field-filter', :description => 'A simple library parsing field filters in rest APIs.')
  o.repository('simple-session-filter', :description => 'A simple servlet filter for implementing custom session management')
  o.repository('simple-keycloak-service', :description => 'A simple service interface and base classes to be used by keycloak secured services')
  o.repository('sqlshell', :description => 'A simple cross platform shell used to automate databases')
  o.repository('ssrs-api', :description => 'Generated SOAP interface to SSRS server')

  # Chef related code still in use until we get rid of chef
  o.repository('chef-archive', :description => 'Chef cookbook that provides utility LWRPs to download and unpack archives.')
  o.repository('chef-authbind', :description => 'A chef cookbook that installs/configures authbind and defines resources for managing authorization')
  o.repository('chef-cutlery', :description => 'Cutlery is a Chef cookbook containing a collection useful library code.')
  o.repository('chef-dbt', :description => 'Simple cookbook that aids in database migrations through dbt')
  o.repository('chef-glassfish', :description => 'A cookbook for managing GlassFish')
  o.repository('chef-glassfish-example', :description => 'A simple chef repository that demonstrates the use of the chef-glassfish cookbook')
  o.repository('chef-hosts', :description => 'Chef cookbook to manage /etc/hosts file')
  o.repository('chef-kibana', :description => 'A chef cookbook that installs/configures kibana (the logstash UI)')
  o.repository('chef-sqlshell', :description => 'Simple cookbook to aid in automating database contents')
  o.repository('chef-winrm', :description => 'Simple winrm cookbook for chef')
  o.repository('chef-xymon', :description => 'A cookbook that installs the xymon monitoring software.')
  o.repository('cookbook-reusability-presentation', :description => 'Presentation on cookbook reusability')
  o.repository('em-winrm', :description => 'EventMachine based, asynchronous parallel client for Windows Remote Management (WinRM).')
  o.repository('knife-cookbook-doc', :description => 'Knife plugin to document cookbooks', :homepage => 'http://realityforge.github.com/knife-cookbook-doc')
  o.repository('knife-windows', :description => 'Plugin for Chef''s knife tool for working with Windows nodes', :homepage => 'http://tickets.opscode.com/browse/KNIFE_WINDOWS')
  o.repository('ohai-system_packages')

  # External projects that have been forked to submit pull requests
  o.repository('keycloak', :description => 'Open Source Identity and Access Management For Modern Applications and Services', :homepage => 'http://www.keycloak.org', :tags => %w(external))
  o.repository('docker-keycloak', :description => 'Docker image for Keycloak project', :tags => %w(external))
  o.repository('Payara', :description => 'Payara Server is derived from GlassFish Server Open Source Edition and 100% open source', :homepage => 'http://www.payara.fish', :tags => %w(external))

  # External projects that have been forked to submit pull requests but we never intend to use
  o.repository('mgwt', :description => 'Clone of master branch of mgwt', :homepage => 'http://www.m-gwt.com', :tags => %w(external historic))
  o.repository('mgwt.showcase', :tags => %w(external historic))

  # Deprecated: rails projects that are unfortunately still in use
  o.repository('rails-active-form', :description => 'A rails plugin for model objects that support validations but are not backed by database tables', :tags => %w(deprecated))
  o.repository('rails-assert-valid-asset', :description => 'A rails plugin to help validate your CSS and (X)HTML in functional tests', :tags => %w(deprecated))
  o.repository('rails-db_purge', :description => 'Clean the database prior to tests with db-purge', :tags => %w(deprecated))
  o.repository('rails-debug-view-helper', :description => 'Rails plugin to add a pop debug button useful during development', :tags => %w(deprecated))
  o.repository('rails-no-cache', :description => 'Simple rails plugin to disable browser caching', :tags => %w(deprecated))
  o.repository('rails-raaa', :description => 'Simple rails authentication plugin', :tags => %w(deprecated))
  o.repository('rails-system-settings', :description => 'A rails plugin that makes it easy to store application settings in the database as key-value pairs', :tags => %w(deprecated))

  # Deprecated: Buildr extension that only used for rails projects
  o.repository('itest', :description => 'Improved test tasks for ruby tests under rake or Buildr', :tags => %w(deprecated))

  # Deprecated: May still be used by some old ant projects but should not use it or ant anymore
  o.repository('antix', :description => 'A set of ant tasks that are used across a range of projects', :tags => %w(deprecated))

  # Deprecated: Still used by iris but should be decomissioned
  o.repository('panmx', :description => 'A java library that builds JMX beans at runtime using annotations', :tags => %w(deprecated))

  # Deprecated: Only useful if you are still on EE6
  o.repository('geolatte-geom-eclipselink', :description => 'Converter for mapping Geolatte geometry types to eclipselink JPA provider', :tags => %w(deprecated))

  # Historic: Old chef related code
  o.repository('knife-spoon', :description => 'A knife extension supporting cookbook workflow', :tags => %w(historic))
  o.repository('chef-blank', :description => 'A blank chef repository', :tags => %w(historic))
  o.repository('chef-jenkins', :description => 'Heavywater modifications to the Jenkins cookbook for Chef', :tags => %w(historic))
  o.repository('chef-logstash', :description => 'A chef cookbook that installs/configures logstash', :tags => %w(historic))
  o.repository('chef-postgis', :description => 'A cookbook for installing and managing Postgis', :tags => %w(historic))
  o.repository('chef-psql', :description => 'A Chef cookbook that provides a set of LWRPs for interacting with postgres using the CLI.', :tags => %w(historic))
  o.repository('chef-slack_handler', :description => 'Chef handler for SlackHQ', :tags => %w(historic))
  o.repository('chef-smbfs', :description => 'A recipe that installs smbfs on linux hosts. It also includes a recipe for adding managed mounts.', :tags => %w(historic))
  o.repository('chef-spydle', :description => 'Cookbook for installing Spydle Monitoring Server on system', :tags => %w(historic))
  o.repository('chef-tomcat', :tags => %w(historic))
  o.repository('chef-graphite', :description => 'Installs/Configures graphite', :tags => %w(historic))
  o.repository('chef-graphite_handler', :description => 'Push chef reporting data to graphite', :tags => %w(historic))
  o.repository('chef-graylog2', :description => 'Installs and configures a Graylog2 server on Ubuntu systems', :tags => %w(historic))
  o.repository('chef-elasticsearch', :description => 'A chef cookbook that installs/configures elasticsearch', :tags => %w(historic))
  o.repository('chef-gdash', :description => 'Cookbook to automatically deploy the Gdash web interface for Graphite.', :tags => %w(historic))
  o.repository('chef-bonita', :description => 'A cookbook for installing the Bonita BPM software', :tags => %w(historic))
  o.repository('chef-collectd', :description => 'A collectd cookbook for chef', :tags => %w(historic))
  o.repository('chef-gelf_handler', :description => 'A Chef handler that reports to Graylog2 servers.', :tags => %w(historic))

  # Historic: Various experiments
  o.repository('gwt-presenter', :tags => %w(historic))
  o.repository('jsyslog-message', :description => 'A tiny library for parsing syslog messages', :tags => %w(historic))
  o.repository('eyelook', :description => 'Eyelook - a minimalistic rails Image Gallery', :tags => %w(historic))
  o.repository('fade', :description => 'An initial prototype Java .class file reader aimed at the JikesRVM', :tags => %w(historic))
  o.repository('jasm', :description => 'Assemblers and disassemblers written in Java', :tags => %w(historic))
  o.repository('jeo', :description => 'Java Geojson library', :tags => %w(historic))
  o.repository('jml', :description => 'A library to ease routing JMS messages between destinations, transforming and validating the message content', :tags => %w(historic))
  o.repository('spydle', :description => 'Spydle collects metrics from your services and feeds it to your metric collection system.', :tags => %w(historic))

  # Historic: Never got to production
  o.repository('glassfish-bonita', :description => 'A repackaging of bonita to work under glassfish', :tags => %w(historic))
  o.repository('glassfish-guvnor', :description => 'A script to build a glassfish version of the Drools Guvnor war', :tags => %w(historic))

  # Historic: Braid has been merged back upstream
  o.repository('braid', :description => 'Simple tool to help track git vendor branches in a git repository. WARNING: Changes integrated to upstream', :homepage => 'http://realityforge.github.io/braid', :tags => %w(historic))

  # Historic - Replaced by guiceyloops
  o.repository('guiceyfruit', :description => 'A collection of utilities for working with Guice (Fork)', :homepage => 'http://code.google.com/p/guiceyfruit/', :tags => %w(historic))

  # Historic - Replaced by braid
  o.repository('piston', :description => 'Piston is a utility that eases vendor branch management in subversion. This is a fork based off the 1.4 version of Piston', :tags => %w(historic))

  # Historic - Not needed since PhD days
  o.repository('packetspy', :description => 'Java wrapper for packet capture library', :tags => %w(historic))

  # Historic: Experiments that were either aborted or migrated elsewhere
  o.repository('repository', :description => 'A maven repository containing binaries from various projects', :tags => %w(historic))
  o.repository('docker-alpine-java', :description => 'Oracle Java8 over AlpineLinux with glibc 2.21', :tags => %w(historic))
  o.repository('docker-busybox-glassfish', :description => 'A minimal docker for running Payara/GlassFish or OpenMQ', :tags => %w(historic))
  o.repository('docker-busybox-glassfish-domain', :description => 'A minimal docker image that defines a single domain in the GlassFish application server.', :tags => %w(historic))
  o.repository('docker-busybox-java', :description => 'A minimal docker image containing designed to run java applications.', :tags => %w(historic))
  o.repository('vagrant-windows', :tags => %w(historic))
  o.repository('workstation-infrastructure', :description => 'A chef project for managing the workstations infrastructure', :tags => %w(historic))
  o.repository('emacs.d', :description => 'Basic emacs configuration', :tags => %w(historic))

  # Historic buildr extensions
  o.repository('buildr-bnd', :description => 'A Buildr extension for packaging OSGi bundles using Bnd. WARNING: Integrated into buildr as of version 1.4.5', :tags => %w(historic))
  o.repository('buildr-examples', :description => 'A set of example buildr projects', :tags => %w(historic))
  o.repository('buildr-iidea', :description => 'Intellij IDEA project-file generation tasks for buildr. WARNING: Integrated into buildr as of version 1.4.5', :tags => %w(historic))
  o.repository('buildr-ipojo', :description => 'A Buildr extension for processing OSGi bundles using IPojo ', :tags => %w(historic))
  o.repository('buildr-jaxb-xjc', :description => 'Buildr extension to execute the XJC binding compiler. WARNING: Integrated into buildr as of version 1.4.5', :tags => %w(historic))
  o.repository('buildr-osgi-assembler', :description => 'A Buildr extension for packaging osgi applications', :tags => %w(historic))

  o.repositories.each do |repository|
    repository.private = false

    if repository.tags.include?('notify:stock')
      repository.email_hook('dse-iris-scm@stocksoftware.com.au')
      repository.tags << 'protect=master'
    end

    repository.tag_values('protect').each do |branch|
      repository.branch(branch, :require_reviews => true)
    end

    travis_projects = %w(braid chef-archive chef-authbind chef-blank chef-bonita chef-collectd chef-cutlery chef-dbt chef-elasticsearch chef-gdash chef-gelf_handler chef-glassfish chef-graphite chef-graphite_handler chef-graylog2 chef-hosts chef-jenkins chef-kibana chef-logstash chef-postgis chef-psql chef-smbfs chef-spydle chef-sqlshell chef-tomcat chef-winrm chef-xymon dbdiff dbt gelf4j geolatte-geom-eclipselink geolatte-geom-jpa getopt4j glassfish-domain-patcher glassfish-timers guiceyloops gwt-appcache gwt-appcache-example gwt-cache-filter gwt-cache-filter-example gwt-contacts gwt-datatypes gwt-eventsource gwt-eventsource-example gwt-ga gwt-keycloak gwt-lognice gwt-mmvp gwt-online gwt-online-example gwt-packetio-example gwt-presenter gwt-property-source gwt-property-source-example gwt-webpoller gwt-webpoller-example gwt-websockets gwt-websockets-example jeo jml jndikit jsyslog-message keycloak-converger keycloak-domgen-support knife-cookbook-doc proxy-servlet reality-core reality-facets reality-generators reality-mash reality-model reality-naming reality-orderedhash redfish replicant replicant-example resgen rest-criteria rest-field-filter simple-session-filter spydle sqlshell ssrs-api)
    repository.tags << 'travis' if travis_projects.include?(repository.name)

    repository.tags << 'chef' if repository.name =~ /^chef-/
    repository.tags << 'chef' if repository.name =~ /^knife-/
    repository.tags << 'docker-hub' if repository.name =~ /^docker-/
    repository.tags << 'travis' if repository.tags.include?('docker-hub')

    repository.docker_hook if repository.tags.include?('docker-hub')

    # GITHUB_TOKEN is an environment variable that should be defined in `_backpack.rb` file
    repository.travis_hook('realityforge', ENV['GITHUB_TOKEN']) if repository.tags.include?('travis')
  end
end
