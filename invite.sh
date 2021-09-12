##USAGE 
#(1) Put your GitHub Token in GITHUB_TOKEN variable
#(2) This uses a DIRTY method, and hence will only work with mirror-bot or any other bot based on python (kek, other languages might also work)
#(3) use the command: /invite <github_username> <github_repo>
#(4) Example /invite boxboi689 Redmi-Mt6768
#(5) If Using pc/termux, add " " Example: bash invite.sh "boxboi689 Redmi-Mt6768"


##EDIT THIS
GITHUB_TOKEN=  #Your GitHub Token Here
GITHUB_USER_NAME=boxboi689 #Your github Username
GITHUB_ORG_NAME=boxaltdumps #your github Org Name


##DO NOT EDIT
PERMISSION=push
echo "$1" | grep -e '$' > /dev/null;
CODE=$1
set -- $CODE
INVITEE_USERNAME=$1
REPO_TO_INVITE=$2
curl -i -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_ORG_NAME/$REPO_TO_INVITE/collaborators/$INVITEE_USERNAME" -X PUT -d '{"permission":"$PERMISSION"}' 2>&1 | grep message || echo "Sent Invite To $INVITEE_USERNAME to Join $REPO_TO_INVITE"

