##README OR DIE
#(1) Do not share this file with anyone
#(2) Done Use Your Main Github Account(unless you're gay?)
#(3) Yes, using password is dumb, and git token is better, right now im in a hurry, so ill use it later
#(4) Manually Editing dumpyara.yml by changing the location of "  ROM: <link>" will break the script as the implementation is very dirty and requires the "  ROM: <link>" to be on last line
#(5) The Script Tries To Make a Neat and Tidy Commit(in the dumper repo)(not dumpyarya repo), However , The commit is decided on the link, so Nothing is Gauranteed

##USAGE
#(1) Fork this(https://github.com/mirrordump/dumper) repo and enable github actions, add the required github secrets (1) BOT_TOKEN , (2) CHAT_ID , (3) GIT_ORG_NAME , (4) GIT_TOKEN
#(2) place dump.sh wherever you want
#(3) run dump.sh <link> 
#(4) Example dump.sh https://bigota.d.miui.com/V12.0.3.0.RCOCNXM/ginkgo_images_V12.0.3.0.RCOCNXM_20210524.0000.00_11.0_cn_eda1fc3541.tgz
#(5) If Everything is done properly, it should dump to github to your Created ORG, You can keep repo private too by Filling in the DUMP_TYPE variable, by default, its set to public

##CREDITS
#(1) Techyminati For giving idea for --quiet tag


##EDIT THIS
GIT_TOKEN= #I will use this in future, im lazy rn, and dumb cause i cant use token for some gay reason idk why #If youre making your own bot, Change this git token, to get your git token visit https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token
GIT_USER_NAME= #Edit this with ypur Github Username
GIT_REPO_NAME= # Fork this repo: https://github.com/mirrordump/dumper
GIT_USER_EMAIL= #Edit this with your Github Mail
TELEGRAM_CHANNEL_NAME=@boxdumps #replace with your channel
DUMPER_REPO_WORKFLOW_URL=https://github.com/boxboi689/dumper/actions  #Your Repo Workflow Url
DUMP_TYPE=public #Set this to either public or private #Fork This Repo and also fork this repo: https://github.com/mirrordump/dumpyara.git


##DO NOT EDIT
DUMMY_VARIABLE=1
ORIGINAL_PATH=$(pwd)
ORIGINAL_GIT_USER_EMAIL=$(git config user.email)
ORIGINAL_GIT_USER_NAME=$(git config user.name)
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
git config --global credential.helper cache
echo "$1" | grep -e '^\(https\?\|ftp\)://.*$' > /dev/null;
URL=$1
SIZE=$(curl -sI --head --location $URL | grep -i content-length | awk '{print $2}') && SIZE=`echo $SIZE | sed 's/\\r//g'` #removing \r due to html
HUMAN_SIZE=$(timeout 0.5s numfmt --to=iec $SIZE) && HUMAN_SIZE=$(echo $HUMAN_SIZE'B')
if [[ $URL == *http://*/* ]]; then
  DUMMY_VARIABLE=2
elif [[ $URL == *https://*/* ]]; then
    DUMMY_VARIABLE=3
elif [[ $URL == *ftp://*/* ]]; then
    DUMMY_VARIABLE=3
elif [ -z $SIZE ]; then
    echo "Dump Failed!
    You Havent Provided A Proper link, Do Not Abuse This Feature With Your Random Requests, You Might Lose Access To This Feature If You Abuse It!"
    exit 1
fi
if [[ $SIZE -lt 400000000 ]]; then
  echo "Your File is Too Small $HUMAN_SIZE. It Can Also Be Possible That Your Link Failed Auto-Verification And Hence Is Unsupported, In That Case, Try Mirroring It And Then Dumping!"
  exit 1
fi
rm -rf $GIT_REPO_NAME
git clone --quiet --depth=1 --single-branch https://github.com/$GIT_USER_NAME/$GIT_REPO_NAME.git
CHECK=$(tail -n 1 $GIT_REPO_NAME/.github/workflows/dumpyara.yml)
echo '  'ROM_URL: $URL >> CHECK.txt
VERIFY=$(tail -n 1 CHECK.txt) && rm CHECK.txt
if [ "$CHECK" == "$VERIFY" ]
then
    echo "
    DUMP FAILED! The Link Provided was Previously Dumped Already, Please do not Misuse this Feature!
    "
elif [ "$DUMP_TYPE" == private ]
then
    cd $GIT_REPO_NAME/.github/workflows && sed -i '$d' dumpyara.yml
    echo '  'ROM_URL: $URL >> dumpyara.yml
    cd ../.. && echo 'Dummy File To Push Dumped Firmware to Private Github Repo' > private.txt 
    git add -f .
    echo $URL > CLEAN.txt && CLEAN=$(sed 's/^.*\///' CLEAN.txt) && CLEAN=$(echo "${CLEAN%.*}") && rm CLEAN.txt
    git commit --quiet -m "Dump $CLEAN"
    git push --quiet -f https://$GIT_USER_NAME:$GIT_TOKEN@github.com/$GIT_USER_NAME/$GIT_REPO_NAME
    echo "$DUMPER_REPO_WORKFLOW_URL"
elif [ "$DUMP_TYPE" == public ]
then
    cd $GIT_REPO_NAME/.github/workflows && sed -i '$d' dumpyara.yml
    echo '  'ROM_URL: $URL >> dumpyara.yml
    cd ../.. && rm -rf private.txt 
    git add -f .
    echo $URL > CLEAN.txt && CLEAN=$(sed 's/^.*\///' CLEAN.txt) && CLEAN=$(echo "${CLEAN%.*}") && rm CLEAN.txt
    git commit --quiet -m "Dump $CLEAN"
    git push --quiet -f https://$GIT_USER_NAME:$GIT_TOKEN@github.com/$GIT_USER_NAME/$GIT_REPO_NAME
    echo "$DUMPER_REPO_WORKFLOW_URL"
else
    echo "
    Fill in the Variable 'DUMP_TYPE with either public or private!
    "
fi
#CLEANUP TIME!
git config --global user.email "$ORIGINAL_GIT_USER_EMAIL"
git config --global user.name "$ORIGINAL_GIT_USER_NAME"
cd $ORIGINAL_PATH
rm -rf $GIT_REPO_NAME
