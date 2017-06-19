require 'belt'

Belt.scope('realityforge') do |o|
  o.project('realityforge_backpack', :description => 'Project for managing realityforge repositories.')

  o.project('buildr_plus', :description => 'A simple set of extensions that patch and customize buildr to our requirements.', :tags => %w(notify:stock))
  o.project('dbt', :description => 'A simple tool designed to simplify the creation, migration and deletion of databases.', :tags => %w(notify:stock travis pages))
  o.project('noft', :description => 'A tool to extract svg icons from icon fonts and generate helpers to render the icons.', :tags => %w(notify:stock travis))
  o.project('domgen', :description => 'Domgen generates code from a simple domain model leaving the developer to focus on implementing high-value features of the application.', :tags => %w(notify:stock pages))
  o.project('kinjen', :description => 'A library of groovy scripts to use from a Jenkinsfile', :tags => %w(notify:stock))
  o.project('redfish', :description => 'A lightweight library for configuring GlassFish/Payara servers.', :tags => %w(notify:stock travis))
  o.project('rptman', :description => 'This tool includes code and a suite of rake tasks for uploading SSRS reports to a server. The tool can also generate project files for the "SQL Server Business Intelligence Development Studio".', :tags => %w(notify:stock))
  o.project('resgen', :description => 'A tool to generate resource descriptors from resource assets.', :tags => %w(notify:stock travis))
  o.project('swung_weave', :description => 'Bytecode weaving of annotated UI classes to ensure all UI updates occur in the Event Dispatch Thread', :tags => %w(notify:stock))
  o.project('zim', :description => 'Simple tool that performs mass transformations across codebases')

  o.project('assets-font-awesome', :description => 'An extraction of all the icons from font-awesome.', :tags => %w(travis))
  o.project('assets-glyphicons-halflings-regular', :description => 'An extraction of all the icons from glyphicons font included in bootstrap.', :tags => %w(travis))

  o.project('guiceyloops', :description => 'GuiceyLoops is a minimalistic library for aiding the testing of JEE applications using Guice.', :tags => %w(notify:stock travis))

  o.project('keycloak-jaxrs-client-authfilter', :description => 'Filter for accessing keycloak secured services', :tags => %w(travis))
  o.project('keycloak-converger', :description => 'Converge the state of a keycloak realm', :tags => %w(travis))
  o.project('keycloak-domgen-support', :description => 'KeyCloak Domgen Support', :tags => %w(travis))
  o.project('glassfish-domain-patcher', :description => 'GlassFish Domain Patcher', :tags => %w(travis))
  o.project('glassfish-timers', :description => 'GlassFish timers database sql', :tags => %w(travis))

  o.project('backpack', :description => 'A simple tool to manage GitHub organisations using declarative DSL')

  o.project('dbdiff', :description => 'List differences between databases', :tags => %w(travis))
  o.project('gelf4j', :description => 'Library for sending log messages using the GELF protocol using CLI, Log4j, JDK Logging and Logback', :tags => %w(travis))
  o.project('geolatte-geom-jpa', :description => 'Converter for mapping Geolatte geometry types to JPA attributes', :tags => %w(travis))
  o.project('getopt4j', :description => 'A library to parse command line arguments according to the GNU style', :tags => %w(travis))

  o.project('gwt-appcache', :description => 'GWT AppCache Support Library', :tags => %w(travis issues pages))
  o.project('gwt-appcache-example', :description => 'A simple application demonstrating the use of the gwt-appcache library', :tags => %w(travis))
  o.project('gwt-cache-filter', :description => 'A servlet filter that adds the appropriate http caching headers to GWT generated files based on *.cache.* and *.nocache.* naming patterns.', :tags => %w(travis issues))
  o.project('gwt-cache-filter-example', :description => 'A simple application demonstrating the use of the gwt-cache-filter library', :tags => %w(travis))
  o.project('gwt-datatypes', :description => 'A simple library that consolidates the common data types and associated infrastructure used across a range of GWT projects.', :tags => %w(travis))
  o.project('gwt-eventsource', :description => 'GWT EventSource Library', :tags => %w(travis issues))
  o.project('gwt-eventsource-example', :description => 'A simple application demonstrating the use of the gwt-eventsource library', :tags => %w(travis issues))
  o.project('gwt-ga', :description => 'A simple GWT library for interacting with Google Analytics', :tags => %w(travis))
  o.project('gwt-keycloak', :description => 'A simple library to provide keycloak support to GWT', :tags => %w(travis issues))
  o.project('gwt-lognice', :description => 'A super simple gwt library that makes the log messages nicer.', :tags => %w(travis))
  o.project('gwt-mmvp', :description => 'A micro MVP library that enhances the Activities and Places library.', :tags => %w(travis))
  o.project('gwt-gin-extensions', :description => 'Simple utilities when using gin injection framework.', :tags => %w(travis))
  o.project('gwt-webpoller', :description => 'A gwt library to simplify periodic polling and long-poll based transport layers', :tags => %w(travis issues))
  o.project('gwt-webpoller-example', :description => 'A simple application demonstrating the use of the gwt-webpoller library', :tags => %w(travis issues))
  o.project('gwt-websockets', :description => 'GWT WebSocket Library', :tags => %w(travis issues))
  o.project('gwt-websockets-example', :description => 'A simple application demonstrating the use of the gwt-websockets library', :tags => %w(travis issues))
  o.project('housekeeping-scripts', :description => 'Sets of scripts used to perform housekeeping at home and in the wild')
  o.project('idea-configuration', :description => 'A repository containing configuration for IntelliJ IDEA', :tags => %w(zim=no))

  o.project('jndikit', :description => 'a toolkit designed to help with the construction of JNDI providers', :tags => %w(travis))
  o.project('napts', :description => 'Quiz application that records and tracks students progress across a number of subjects')
  o.project('proxy-servlet', :description => 'A servlet for creating proxy services', :tags => %w(travis))
  o.project('reality-mda', :description => 'The glue that blends reality-core, reality-model, reality-generators and reality-facets into an model driven application.', :tags => %w(travis))
  o.project('reality-core', :description => 'Basic classes used to help defining libraries.', :tags => %w(travis))
  o.project('reality-facets', :description => 'A basic toolkit for binding facets or extensions to model objects.', :tags => %w(travis))
  o.project('reality-generators', :description => 'A basic toolkit for abstracting the generation of files from model objects.', :tags => %w(travis))
  o.project('reality-mash', :description => 'A library providing the mash data type.', :tags => %w(travis))
  o.project('reality-model', :description => 'Utility classes for defining a domain model.', :tags => %w(travis))
  o.project('reality-naming', :description => 'A library to convert names between different naming conventions.', :tags => %w(travis))
  o.project('reality-orderedhash', :description => 'A library providing a hash with preserved order and some array-like extensions.', :tags => %w(travis))
  o.project('reality-belt', :description => 'A super simple domain model to represent projects.')
  o.project('realityforge.github.io', :description => 'My personal website and blog', :tags => %w(homepage=https://realityforge.github.io))
  o.project('replicant', :description => 'Client-side state representation infrastructure for GWT', :tags => %w(travis))
  o.project('replicant-example', :description => 'A simple application demonstrating the use of the replicant library', :tags => %w(travis))
  o.project('rest-criteria', :description => 'A simple library for parsing criteria in rest services', :tags => %w(travis))
  o.project('rest-field-filter', :description => 'A simple library parsing field filters in rest APIs.', :tags => %w(travis))
  o.project('simple-keycloak-service', :description => 'A simple service interface and base classes to be used by keycloak secured services', :tags => %w(travis))
  o.project('sqlshell', :description => 'A simple cross platform shell used to automate databases', :tags => %w(travis))
  o.project('ssrs-api', :description => 'Generated SOAP interface to SSRS server', :tags => %w(travis))
  o.project('gwt-router', :description => 'Experiments building a router for GWT', :tags => %w(travis))

  # Chef related code still in use until we get rid of chef
  o.project('chef-archive', :description => 'Chef cookbook that provides utility LWRPs to download and unpack archives.', :tags => %w(travis))
  o.project('chef-authbind', :description => 'A chef cookbook that installs/configures authbind and defines resources for managing authorization', :tags => %w(travis))
  o.project('chef-cutlery', :description => 'Cutlery is a Chef cookbook containing a collection useful library code.', :tags => %w(travis))
  o.project('chef-dbt', :description => 'Simple cookbook that aids in database migrations through dbt', :tags => %w(travis))
  o.project('chef-glassfish', :description => 'A cookbook for managing GlassFish', :tags => %w(travis))
  o.project('chef-glassfish-example', :description => 'A simple chef repository that demonstrates the use of the chef-glassfish cookbook')
  o.project('chef-hosts', :description => 'Chef cookbook to manage /etc/hosts file', :tags => %w(travis))
  o.project('chef-kibana', :description => 'A chef cookbook that installs/configures kibana (the logstash UI)')
  o.project('chef-sqlshell', :description => 'Simple cookbook to aid in automating database contents', :tags => %w(travis))
  o.project('chef-winrm', :description => 'Simple winrm cookbook for chef', :tags => %w(travis))
  o.project('chef-xymon', :description => 'A cookbook that installs the xymon monitoring software.', :tags => %w(travis))
  o.project('cookbook-reusability-presentation', :description => 'Presentation on cookbook reusability', :tags => %w(historic))
  o.project('em-winrm', :description => 'EventMachine based, asynchronous parallel client for Windows Remote Management (WinRM).')
  o.project('knife-cookbook-doc', :description => 'Knife plugin to document cookbooks', :tags => %w(travis pages))
  o.project('knife-windows', :description => "Plugin for Chef's knife tool for working with Windows nodes", :tags => %w(homepage=http://tickets.opscode.com/browse/KNIFE_WINDOWS))
  o.project('ohai-system_packages')

  # Projects created during learning of new technology
  o.project('course-advanced-react-and-redux', :description => 'Coursework for Advanced React and Redux course')
  o.project('course-graphql-with-react', :description => 'Coursework for GraphQL with React course')
  o.project('course-modern-react-with-redux', :description => 'Coursework for Modern React with Redux course', :tags => %w(historic))
  o.project('footprints', :description => 'A project to prototype ideas in JEE6', :tags => %w(historic))
  o.project('gae-guestbook', :description => 'Sample Google App Engine application', :tags => %w(historic))
  o.project('ios', :description => 'A repository containing the simple iOS applications developed when working through the course', :tags => %w(historic))
  o.project('gwttle', :description => 'GWT Training test applications', :tags => %w(historic))
  o.project('jamex', :description => 'A test bed for OSGi, git, buildr and jms code', :tags => %w(historic))
  o.project('primefaces-starter', :description => 'A primefaces/JSF application used to learn about the framework', :tags => %w(historic))
  o.project('Bootstrap-JSF2.2', :description => 'Twitter Bootstrap integration with JSF 2.2 on Java EE 7', :tags => %w(historic))

  # External projects that have been forked to submit pull requests
  o.project('schmooze', :description => 'Schmooze lets Ruby and Node.js work together intimately.', :tags => %w(external))
  o.project('keycloak', :description => 'Open Source Identity and Access Management For Modern Applications and Services', :tags => %w(external homepage=http://www.keycloak.org))
  o.project('docker-keycloak', :description => 'Docker image for Keycloak project', :tags => %w(external))
  o.project('Payara', :description => 'Payara Server is derived from GlassFish Server Open Source Edition and 100% open source', :tags => %w(external homepage=http://www.payara.fish))

  # External projects that have been forked to submit pull requests but we never intend to use
  o.project('gwt-leaflet', :description => 'GWT library for Leaflet', :tags => %w(external historic))
  o.project('mgwt', :description => 'Clone of master branch of mgwt', :tags => %w(external historic homepage=http://www.m-gwt.com))
  o.project('mgwt.showcase', :tags => %w(external historic))

  # Deprecated: rails projects that are unfortunately still in use
  o.project('rails-active-form', :description => 'A rails plugin for model objects that support validations but are not backed by database tables', :tags => %w(deprecated))
  o.project('rails-assert-valid-asset', :description => 'A rails plugin to help validate your CSS and (X)HTML in functional tests', :tags => %w(deprecated))
  o.project('rails-db_purge', :description => 'Clean the database prior to tests with db-purge', :tags => %w(deprecated))
  o.project('rails-debug-view-helper', :description => 'Rails plugin to add a pop debug button useful during development', :tags => %w(deprecated))
  o.project('rails-no-cache', :description => 'Simple rails plugin to disable browser caching', :tags => %w(deprecated))
  o.project('rails-raaa', :description => 'Simple rails authentication plugin', :tags => %w(deprecated))
  o.project('rails-system-settings', :description => 'A rails plugin that makes it easy to store application settings in the database as key-value pairs', :tags => %w(deprecated))

  # Deprecated: Buildr extension that only used for rails projects
  o.project('itest', :description => 'Improved test tasks for ruby tests under rake or Buildr', :tags => %w(deprecated))

  # Deprecated: May still be used by some old ant projects but should not use it or ant anymore
  o.project('antix', :description => 'A set of ant tasks that are used across a range of projects', :tags => %w(deprecated))

  # Deprecated: Still used by iris but should be decomissioned
  o.project('panmx', :description => 'A java library that builds JMX beans at runtime using annotations', :tags => %w(deprecated))

  # Deprecated: Only useful if you are still on EE6
  o.project('geolatte-geom-eclipselink', :description => 'Converter for mapping Geolatte geometry types to eclipselink JPA provider', :tags => %w(deprecated travis))

  # Deprecated: Example project is no longer representative of the way we build GWT apps.
  o.project('gwt-contacts', :description => 'A version of the gwt "contacts" example from google', :tags => %w(travis deprecated))

  # Historic: Moved to using a simpler + GWT 3.0 compatible strategy of System.getProperty() instead
  o.project('gwt-property-source', :description => 'Provides a convenient way of compiling GWT property values into your module.', :tags => %w(travis issues deprecated))
  o.project('gwt-property-source-example', :description => 'A sample application that demonstrates the use of the gwt-property-source', :tags => %w(travis issues deprecated))

  # Historic: Inlined the code into all downstream libraries
  o.project('simple-session-filter', :description => 'A simple servlet filter for implementing custom session management', :tags => %w(historic))

  # Historic: Old chef related code
  o.project('knife-spoon', :description => 'A knife extension supporting cookbook workflow', :tags => %w(historic))
  o.project('chef-blank', :description => 'A blank chef repository', :tags => %w(historic))
  o.project('chef-jenkins', :description => 'Heavywater modifications to the Jenkins cookbook for Chef', :tags => %w(historic))
  o.project('chef-logstash', :description => 'A chef cookbook that installs/configures logstash', :tags => %w(historic))
  o.project('chef-postgis', :description => 'A cookbook for installing and managing Postgis', :tags => %w(historic))
  o.project('chef-psql', :description => 'A Chef cookbook that provides a set of LWRPs for interacting with postgres using the CLI.', :tags => %w(historic))
  o.project('chef-slack_handler', :description => 'Chef handler for SlackHQ', :tags => %w(historic))
  o.project('chef-smbfs', :description => 'A recipe that installs smbfs on linux hosts. It also includes a recipe for adding managed mounts.', :tags => %w(historic))
  o.project('chef-spydle', :description => 'Cookbook for installing Spydle Monitoring Server on system', :tags => %w(historic))
  o.project('chef-tomcat', :tags => %w(historic))
  o.project('chef-graphite', :description => 'Installs/Configures graphite', :tags => %w(historic))
  o.project('chef-graphite_handler', :description => 'Push chef reporting data to graphite', :tags => %w(historic))
  o.project('chef-graylog2', :description => 'Installs and configures a Graylog2 server on Ubuntu systems', :tags => %w(historic))
  o.project('chef-elasticsearch', :description => 'A chef cookbook that installs/configures elasticsearch', :tags => %w(historic))
  o.project('chef-gdash', :description => 'Cookbook to automatically deploy the Gdash web interface for Graphite.', :tags => %w(historic))
  o.project('chef-bonita', :description => 'A cookbook for installing the Bonita BPM software', :tags => %w(historic))
  o.project('chef-collectd', :description => 'A collectd cookbook for chef', :tags => %w(historic))
  o.project('chef-gelf_handler', :description => 'A Chef handler that reports to Graylog2 servers.', :tags => %w(historic))

  # Historic: Various experiments
  o.project('swinkar', :description => 'A project exploring Swing+OSGi', :tags => %w(historic))
  o.project('proxymusic', :description => 'ProxyMusic provides a binding between Java objects in memory and data formatted according to MusicXML 3.0', :tags => %w(historic))
  o.project('lesscss4j', :description => 'Less CSS For Java', :tags => %w(historic))
  o.project('tarrabah', :description => 'An experimental gelf + syslog server', :tags => %w(historic))
  o.project('gwt-performance-timing', :tags => %w(historic))
  o.project('gwt-online', :description => 'A gwt wrapper to determine when the browser is online', :tags => %w(historic))
  o.project('gwt-online-example', :description => 'A simple application demonstrating the use of the gwt-online library', :tags => %w(historic))
  o.project('gwt-packetio-example', :description => 'A sample application that demonstrates the use of the gwt-packetio library.', :tags => %w(historic))
  o.project('gwt-presenter', :tags => %w(historic))
  o.project('jsyslog-message', :description => 'A tiny library for parsing syslog messages', :tags => %w(historic))
  o.project('eyelook', :description => 'Eyelook - a minimalistic rails Image Gallery', :tags => %w(historic))
  o.project('fade', :description => 'An initial prototype Java .class file reader aimed at the JikesRVM', :tags => %w(historic))
  o.project('jasm', :description => 'Assemblers and disassemblers written in Java', :tags => %w(historic))
  o.project('jeo', :description => 'Java Geojson library', :tags => %w(historic))
  o.project('jml', :description => 'A library to ease routing JMS messages between destinations, transforming and validating the message content', :tags => %w(historic))
  o.project('spydle', :description => 'Spydle collects metrics from your services and feeds it to your metric collection system.', :tags => %w(historic))
  o.project('star-punk', :description => 'An experiment to build a little space game', :tags => %w(historic))
  o.project('tyrian', :description => 'A re-imagining of the tyrian tutorial game', :tags => %w(historic))
  o.project('gwt-space-shooter-game', :description => 'space shooter game developed with GWT and gwt-voices sound library', :tags => %w(historic))

  # FGIS Experiment
  o.project('fgis-java', :description => 'Fire Ground Information System java experiment', :tags => %w(historic))
  o.project('fgis-infrastructure', :description => 'A chef repository for building out the nodes.', :tags => %w(historic))
  o.project('fgis-geoserver', :description => 'A repository containing the configuration for Geoserver.', :tags => %w(historic))

  # Historic: Never got to production
  o.project('glassfish-bonita', :description => 'A repackaging of bonita to work under glassfish', :tags => %w(historic))
  o.project('glassfish-guvnor', :description => 'A script to build a glassfish version of the Drools Guvnor war', :tags => %w(historic))

  # Historic: Braid has been merged back upstream
  o.project('braid', :description => 'Simple tool to help track git vendor branches in a git repository. WARNING: Changes integrated to upstream', :tags => %w(historic pages))

  # Historic - Replaced by guiceyloops
  o.project('guiceyfruit', :description => 'A collection of utilities for working with Guice (Fork)', :tags => %w(historic homepage=http://code.google.com/p/guiceyfruit/))

  # Historic - Replaced by braid
  o.project('piston', :description => 'Piston is a utility that eases vendor branch management in subversion. This is a fork based off the 1.4 version of Piston', :tags => %w(historic))

  # Historic - Not needed since PhD days
  o.project('packetspy', :description => 'Java wrapper for packet capture library', :tags => %w(historic))

  # Historic: Experiments that were either aborted or migrated elsewhere
  o.project('repository', :description => 'A maven repository containing binaries from various projects', :tags => %w(historic))
  o.project('docker-alpine-java', :description => 'Oracle Java8 over AlpineLinux with glibc 2.21', :tags => %w(historic))
  o.project('docker-busybox-glassfish', :description => 'A minimal docker for running Payara/GlassFish or OpenMQ', :tags => %w(historic))
  o.project('docker-busybox-glassfish-domain', :description => 'A minimal docker image that defines a single domain in the GlassFish application server.', :tags => %w(historic))
  o.project('docker-busybox-java', :description => 'A minimal docker image containing designed to run java applications.', :tags => %w(historic))
  o.project('vagrant-windows', :tags => %w(historic))
  o.project('workstation-infrastructure', :description => 'A chef project for managing the workstations infrastructure', :tags => %w(historic))
  o.project('emacs.d', :description => 'Basic emacs configuration', :tags => %w(historic))

  # Historic buildr extensions
  o.project('buildr-bnd', :description => 'A Buildr extension for packaging OSGi bundles using Bnd. WARNING: Integrated into buildr as of version 1.4.5', :tags => %w(historic))
  o.project('buildr-examples', :description => 'A set of example buildr projects', :tags => %w(historic))
  o.project('buildr-iidea', :description => 'Intellij IDEA project-file generation tasks for buildr. WARNING: Integrated into buildr as of version 1.4.5', :tags => %w(historic))
  o.project('buildr-ipojo', :description => 'A Buildr extension for processing OSGi bundles using IPojo ', :tags => %w(historic))
  o.project('buildr-jaxb-xjc', :description => 'Buildr extension to execute the XJC binding compiler. WARNING: Integrated into buildr as of version 1.4.5', :tags => %w(historic))
  o.project('buildr-osgi-assembler', :description => 'A Buildr extension for packaging osgi applications', :tags => %w(historic))
  o.project('buildr-jacoco', :description => 'Experiments to try using jacoco in Buildr', :tags => %w(historic))

  o.projects.each do |project|
    project.tags << "homepage=http://realityforge.org/#{project.name}" if project.tags.include?('pages')
    project.tags << 'protect=master' if project.tags.include?('notify:stock')
    project.tags << 'chef' if project.name =~ /^chef-/
    project.tags << 'chef' if project.name =~ /^knife-/
    project.tags << 'docker-hub' if project.name =~ /^docker-/
    project.tags << 'travis' if project.tags.include?('docker-hub')
    project.tags << "name=#{project.name}"
  end
end

