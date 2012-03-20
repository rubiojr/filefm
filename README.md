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

Using v2.0 authentication style (keystone)

    FileFM::Uploaders::Swift.upload("/home/user/my-file", 
                                    "swift://swift.myserver.com/container1/my-file", 
                                    { 
                                      :username => "tenant:username",
                                      :password => "secret",
                                      :auth_url => "http://my-keystone-server:5000/v2.0/tokens", 
                                      :progressbar => true
                                    })


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

Using v2.0 authentication style (keystone)

    filefm upload -A http://my-keystone-server:5000/v2.0/tokens \
                  --insecure -u admin:admin -p ADMIN \
                  /path/to/my/file \
                  swift://swift.myserver.com/container1/my-file

*Rackspace*

    filefm upload --user <rackspace-username> \
                  --password <RACKSPACE_API> \
                  <path-to-file> \
                  cloudfiles://container1/foo.tmp

*HTTP*

    filefm download http://my-server.com/my-big-file


## DEBUGGING ENABLED

    DEBUG=yes filefm upload --insecure --user admin:admin \
                  --password secret \
                  /home/user/my-file \
                  swift://server/container1/my-file

# Copyright

Copyright (c) 2012 Sergio Rubio. See LICENSE.txt for
further details.

