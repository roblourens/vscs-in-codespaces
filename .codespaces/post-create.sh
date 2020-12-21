# add libssl
echo "deb http://security.debian.org/debian-security jessie/updates main" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9D6D8F6BC857C906
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA8E81B4331F7F50
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends libssl1.0.0

# add dotnet sdk v3.1.404
curl -SL https://dotnetcli.blob.core.windows.net/dotnet/Sdk/3.1.404/dotnet-sdk-3.1.404-linux-x64.tar.gz --output dotnet.tar.gz
tar -zxf dotnet.tar.gz -C /home/codespace/.dotnet --skip-old-files
rm dotnet.tar.gz

# add oh-my-bash
wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O - | sh -C

BASH_RC_FILE=~/.bashrc

PRE_OMB_BASH_CONFIG=~/.bashrc.pre-oh-my-bash
if [ -f $PRE_OMB_BASH_CONFIG ]; then
  cat $PRE_OMB_BASH_CONFIG >> $BASH_RC_FILE
  rm $PRE_OMB_BASH_CONFIG
fi

# add .bashrc config
echo "
## Color variables

# Dimmed text
export PALETTE_DIM='\e[2m'

# Bold Text
export PALETTE_BOLD='\e[1m'

# Underlined Text
export PALETTE_UNDERLINED='\e[4m'

# Blinking
export PALETTE_BLINK='\e[5m'

# Reverse
export PALETTE_REVERSE='\e[7m'

# Foreground Color
export PALETTE_BLACK='\e[30m'
export PALETTE_WHITE='\e[97m'
export PALETTE_RED='\e[31m'
export PALETTE_GREEN='\e[32m'
export PALETTE_BROWN='\e[33m'
export PALETTE_BLUE='\e[34m'
export PALETTE_PURPLE='\e[35m'
export PALETTE_CYAN='\e[36m'
export PALETTE_LIGHTGRAY='\e[37m'
export PALETTE_LIGHT_YELLOW='\e[93m'

# Background Color
export PALETTE_BLACK_U='\e[40m'
export PALETTE_RED_U='\e[41m'
export PALETTE_GREEN_U='\e[42m'
export PALETTE_BROWN_U='\e[43m'
export PALETTE_BLUE_U='\e[44m'
export PALETTE_PURPLE_U='\e[45m'
export PALETTE_CYAN_U='\e[46m'
export PALETTE_LIGHTGRAY_U='\e[47m'

# Normal Text
export PALETTE_RESET='\e[0m'

# workspace
export CODESPACE_ROOT=$(pwd)
export CODESPACE_DEFAULT_PATH="\$CODESPACE_ROOT\$ADO_REPO_DEFAULT_PATH"
alias cdroot='cd \$CODESPACE_ROOT'
alias cddefault='cd \$CODESPACE_DEFAULT_PATH'
alias ya='yarn'
# misc
code()
{
  if code-insiders -v &> /dev/null; then
      code-insiders \$@;
    else
      code \$@;
  fi
}
export -f code
alias ls='ls --color=auto'
alias ww='watch -n 1 \"date && echo -e \ &&\"'
alias refresh='exec bash'
alias bashconfig=\"code $BASH_RC_FILE\"
alias nugetconfig=\"code ~/.nuget/NuGet/NuGet.Config\"
alias ports='lsof -n -i -P | grep TCP'
# git
alias push='git push -u azdo HEAD'
alias pull='git pull azdo'
alias sync='pull && push'
alias fetch='git fetch azdo'
alias pullmaster='git pull azdo master'
alias branch='f() {
    BRANCH_NAME=\"dev/\$AZ_DO_USERNAME/\$1\";
    git pull azdo master:main --no-tags;
    git branch \$BRANCH_NAME main --color;
    git checkout \$BRANCH_NAME;
    git push -u azdo \$BRANCH_NAME;
};f'

# change dir to the repo default folder if present (codespace is initialized),
# otherwise show the hint
if ! [ -z \$CODESPACE_DEFAULT_PATH ] 2> /dev/null && [ -d \$CODESPACE_DEFAULT_PATH ]; then
  cd \$CODESPACE_DEFAULT_PATH
elif [ \$(basename \"\$0\") != 'init' ]
then
  clear
  echo -e \"\$PALETTE_DIM\n💡  Run\$PALETTE_BLUE ./init\$PALETTE_RESET\$PALETTE_DIM when ready.\n\$PALETTE_RESET\"
fi

" >> $BASH_RC_FILE

# Run the init script if ADO_PAT is already defined via secrets
if [ -n "$ADO_PAT" ]; then
  ./init
fi

mkdir ~/CEDev
cp ~/ado-in-codespaces/.codespaces/appsettings.json ~/CEDev
sed 's/"developerAlias": ""/"developerAlias": "`git config user.name`"'

dotnet restore
