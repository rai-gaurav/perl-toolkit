# AWS Toolkit

This is the small step to use AWS functionality using Perl. There is already [PAWS](https://metacpan.org/pod/Paws) module on CPAN for AWS stuff.
But in case you want to use aws cli, this is the way.

## Requirements -
1. [awscli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION should be set in environment. You can configure it using [awscli-configuration] (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

   Currently as an example they are in 'etc/setup_env'. Update it to appropriate value before using it and export it in environment.
3. Log4perl


## Features-
1. #### upload_to_S3:
    a. Can upload file or sync dir to S3.
    
    b. If the input is file it will use 'cp' otherwise it will use 'sync'
  
 2. #### download_from_S3: 
    a. Can download file or sync dir from S3.
    
    b. If the input is file it will use 'cp' otherwise it will use 'sync'
 
 3. #### get_from_S3: 
     a. List down the keys in the given bucket (ls)
     
  4. #### delete_from_S3: 
     a. delete whole bucket on S3


You can update the module to fulfill your own requirements.
