# FileFM

Dead simple file uploads and downloads from/to:

* HTTP
* Rackspace Cloudfiles
* Openstack Swift

## API

### Downloadinf files

*Swift*

    FileFM.download "swift://swift-server.com/container1/foofile", 
                    :progressbar => true,
                    :secure => false,
                    :destination => '/tmp/myfoofile',
                    :username => 'admin:admin',
                    :password => 'admin'

*Cloudfiles*

    FileFM.download "cloudfiles://container1/foofile", 
                    :progressbar => true,
                    :destination => '/tmp/myfoofile',
                    :username => 'foo-user',
                    :password => 'RACKSPACE-API-KEY-HERE'

*HTTP*
    
    FileFM.download "http://imaginary-server/foo-linux.iso", 
                    :progressbar => true,
                    :destination => '/tmp/ubuntu.iso'

### Uploading files
      
*Swift*

    FileFM.upload "myfoo-file.txt, 
                  "swift://swift-server.com/container1/myfoo-file.txt", 
                  :username => "admin:admin",
                  :password => "admin",
                  :secure => false,           # no SSL
                  :progressbar => true        # print progress while uploading

*Cloudfiles*

    FileFM.upload   "myfoo-file.txt",
                    "cloudfiles://container1/foofile", 
                    :progressbar => true,
                    :username => 'foo-user',
                    :password => 'RACKSPACE-API-KEY-HERE'

## Command line


*Swift*

    filefm upload --insecure --user admin:admin \
                  --password secret \
                  /home/user/my-file \
                  swift://server/container1/my-file
*Rackspace*

    filefm upload --user <rackspace-username> \
                  --password <RACKSPACE_API> \
                  <path-to-file> \
                  cloudfiles://container1/foo.tmp

*HTTP*

    filefm download http://my-server.com/my-big-file

#
# Copyright

Copyright (c) 2012 Sergio Rubio. See LICENSE.txt for
further details.

