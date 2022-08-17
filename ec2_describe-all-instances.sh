#! /bin/bash

# aws cli v2 required : https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# Ensure all accounts are created as local profiles using 'aws configure sso' and provide the SSO start URL: https://camlingroup.awsapps.com/start
#

function boxedTitle ()
{ # Programmatically generate a boxed title
  if [ ! $# -eq 0 ]; then
    _TITLE="$*"                                             # Take all arguments as a single string
    printf '\n\u250c\u2500\u2500\u2500'                     # Print a single top-left angle, followed by spacing of 3 horizontal lines
    for i in $(seq 1 ${#_TITLE}); do printf '\u2500'; done  # Print a single horizontal line for each character in the title text
    printf '\u2500\u2500\u2500\u2510\n'                     # Print 3 horizontal lines, followed by a single top-right angle
    printf "\u2502   $_TITLE   \u2502\n"                    # Print a vertical line > 3 spaces > title text > 3 spaces > vertical line
    printf '\u2514\u2500\u2500\u2500'                       # Print a single bottom-left angle, followed by spacing of 3 straight lines
    for i in $(seq 1 ${#_TITLE}); do printf '\u2500'; done  # Print a single horizontal line for each character in the title text
    printf '\u2500\u2500\u2500\u2518\n\n'                   # Print 3 horizontal lines, followed by a single bottom-right angle
  else
    return 0
  fi
}

for sso_profile in $(grep -i profile ~/.aws/config | awk '{print $2}' | tr -d ']'); do

    accountid=$(aws sts get-caller-identity --query "Account" --profile "$sso_profile" --output text)
    boxedTitle "Account ID: $accountid"

    for region in $(aws ec2 --profile "$sso_profile" --region eu-west-1 describe-regions --output text --no-paginate | cut -f4); do
        printf "Region: $region\n"
        aws ec2 describe-instances --profile "$sso_profile" --query \
            'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value,InstanceID:InstanceId,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress}' \
            --output table --region "$region"
    done

done
