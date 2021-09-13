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

awsrubycli uses [Thor](https://github.com/rails/thor) for cli argument parsing and providing the help messages.

## License

Released under the MIT License. See the LICENSE file for further details.
