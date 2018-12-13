# bash color variables

NC='\033[0m'

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

B_BLACK='\033[1;30m'
B_RED='\033[1;31m'
B_GREEN='\033[1;32m'
B_YELLOW='\033[1;33m'
B_BLUE='\033[1;34m'
B_MAGENTA='\033[1;35m'
B_CYAN='\033[1;36m'
B_WHITE='\033[1;37m'

U_BLACK='\033[4;30m'
U_RED='\033[4;31m'
U_GREEN='\033[4;32m'
U_YELLOW='\033[4;33m'
U_BLUE='\033[4;34m'
U_MAGENTA='\033[4;35m'
U_CYAN='\033[4;36m'
U_WHITE='\033[4;37m'

BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

preview_colors() {
   FG_COLOR_PADDING=9
   COLUMN_PADDING=25
   BASE_COLORS='BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE'

   printf "\n%${FG_COLOR_PADDING}s   " ''
   for BG_BASE in $BASE_COLORS; do
      printf "%-${COLUMN_PADDING}s " "BG_${BG_BASE}"
   done
   echo

   for FG in $BASE_COLORS; do
      printf "%${FG_COLOR_PADDING}s | " "${FG}"
      for BG_BASE in $BASE_COLORS; do
         BG="BG_${BG_BASE}"
         printf "${!FG}${!BG}%${COLUMN_PADDING}s ${NC}" "\${${FG}}\${${BG}}"
      done
      echo
   done
   for FG_BASE in $BASE_COLORS; do
      FG="B_${FG_BASE}"
      printf "%${FG_COLOR_PADDING}s | " "${FG}"
      for BG_BASE in $BASE_COLORS; do
         BG="BG_${BG_BASE}"
         printf "${!FG}${!BG}%${COLUMN_PADDING}s ${NC}" "\${${FG}}\${${BG}}"
      done
      echo
   done
   for FG_BASE in $BASE_COLORS; do
      FG="U_${FG_BASE}"
      printf "%${FG_COLOR_PADDING}s | " "${FG}"
      for BG_BASE in $BASE_COLORS; do
         BG="BG_${BG_BASE}"
         printf "${!FG}${!BG}%${COLUMN_PADDING}s ${NC}" "\${${FG}}\${${BG}}"
      done
      echo
   done
   echo
}
