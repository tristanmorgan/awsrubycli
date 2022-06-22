# Aws (ruby) cli

This is a quick and incomplete clone of the aws-cli (python) except this one is written in Ruby.

I was hoping to hack together some sort of reflection technique to auto-generate the commands but so far I just implemented a couple of my most frequently used commands.

## Usage

    Aws commands:
      aws --version, -v   # print the version number
      aws ec2 SUBCOMMAND  # run ec2 commands
      aws help [COMMAND]  # Describe available commands or one specific command
      aws iam SUBCOMMAND  # run iam commands
      aws kms SUBCOMMAND  # run kms commands
      aws s3 SUBCOMMAND   # run s3 commands
      aws sts SUBCOMMAND  # run sts commands

      aws cloudformation delete-stack NAME       # delete a stack with name
      aws cloudformation describe-stacks [NAME]  # get stacks with name

      aws ec2 delete-key-pair                            # Deletes a key pair
      aws ec2 describe-images TAG                        # describe images with tag
      aws ec2 describe-instances TAG                     # get instances with tag
      aws ec2 describe-key-pairs                         # Describes all of your key pairs
      aws ec2 get-windows-password instance_id pem_path  # Gets the windows password for an instance

      aws iam list-access-keys  # list-access-keys
      aws iam list-users        # list-users

      aws kms create-key      # create-key
      aws kms list-keys       # list-keys

      aws s3 cp SOURCE [PATH]  # Copy from SOURCE to PATH
      aws s3 ls [SOURCE]       # list buckets or object in SOURCE
      aws s3 mb BUCKET         # make a new BUCKET
      aws s3 pressign PATH     # generate a presigned URL for PATH
      aws s3 rm PATH           # delete a PATH

      aws sts get-access-key-info  # get-caller-identity
      aws sts get-caller-identity  # get-caller-identity

awsrubycli uses [Thor](https://github.com/rails/thor) for cli argument parsing and providing the help messages.

## License

Released under the MIT License. See the LICENSE file for further details.
