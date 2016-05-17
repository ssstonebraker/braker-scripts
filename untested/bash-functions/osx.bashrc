# Reset
Color_Off='\[\e[0m\]'       # Text Reset

# Colors will work nice when used with "Solarized" palette.
# Nothing new here
White='\[\e[0;37m\]'        # White
BPurple='\[\e[1;35m\]'      # Purple
Green='\[\e[0;32m\]'        # Green
Blue='\[\e[0;34m\]'         # Blue
Yellow='\[\e[0;33m\]'       # Yellow
Purple='\[\e[0;35m\]'       # Purple
BWhite='\[\e[1;37m\]'       # White

# custom prompt. 
# User input is colored in white
# the trap will reset the colors before execution of commands
#PS1="${BPurple}\A ${Green}\u${Color_Off}@${Blue}\h${Color_Off}\w:${BWhite}[${Color_Off}\w${BWhite}${Color_Off}]${Purple}$ \[\e[0m\]"
PS1="${BWhite}[${Green}\u${Color_Off}@${Blue}\h:${Color_Off}\w${BWhite}]${Color_Off}$ \[\e[0m\]"
