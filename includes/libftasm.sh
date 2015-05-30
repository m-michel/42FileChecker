#!/bin/bash

if [ "$FILECHECKER_SH" == "1" ]
then


declare -a CHK_LIBFTASM='( "check_author" "auteur" "check_libftasm_required_exists" "required functions" "check_libftasm_extra" "bonus functions" "check_libftasm_makefile" "makefile" "check_libftasm_forbidden_func" "forbidden functions" )'

declare -a LIBFTASM_MANDATORIES='(ft_bzero.s ft_strcat.s ft_isalpha.s ft_isdigit.s ft_isalnum.s ft_isascii.s ft_isprint.s ft_toupper.s ft_tolower.s ft_puts.s ft_strlen.s ft_memset.s ft_memcpy.s ft_strdup.s ft_cat.s)'

declare -a CHK_LIBFTASM_AUTHORIZED_FUNCS='(malloc write read main)'

function check_libftasm_all
{
	local FUNC TITLE i j k j2 RET0 MYPATH TESTONLY
	TESTONLY="$1"
	MYPATH=$(get_config "libftasm")
	configure_moulitest "libftasm" "$MYPATH"
	i=0
	j=1
	k=0
	display_header
	check_libftasm_top "$MYPATH"
	while [ "${CHK_LIBFTASM[$i]}" != "" ]
	do
		FUNC="${CHK_LIBFTASM[$i]}"
		(( i += 1 ))
		TITLE=`echo "${CHK_LIBFTASM[$i]}"  | sed 's/%/%%/g'`
		j2=`ft_itoa "$j"`
		printf "  $C_WHITE$j -> $TITLE$C_CLEAR\n"
		if [ "$TESTONLY" == "" -o "$TESTONLY" == "$k" ]
		then
			(eval "$FUNC" > .myret) &
			display_spinner $!
			RET0=`cat .myret | sed 's/%/%%/g'`
			printf "$RET0\n"
			printf "\n"
		else
			printf $C_GREY"  --Not performed--\n"$C_CLEAR;
			printf "\n"
		fi
		(( j += 1 ))
		(( i += 1 ))
		(( k += 1 ))
	done
	display_menu\
		""\
		"check_libftasm" "RETRY"\
		"open .myLIBFTASM_MANDATORIES" "more info: required functions"\
		"open .myLIBFTASM_BONUS" "more info: bonus functions"\
		"open .mymakefile" "more info: makefile"\
		"open .myforbiddenfunc" "more info: forbidden functions"\
		"_"\
		"open https://github.com/jgigault/42FileChecker/issues/new" "REPORT A BUG"\
		main "BACK TO MAIN MENU"
}

function check_libftasm_makefile
{
	local MYPATH
	MYPATH=$(get_config "libftasm")
	check_makefile "$MYPATH" libftasm.a
}

function check_libftasm_required_exists
{
	check_fileexists LIBFTASM_MANDATORIES
}

function check_libftasm_forbidden_func
{
	local F LOG_FILENAME
	LOG_FILENAME=.myforbiddenfunc
	if [ -f "$MYPATH/Makefile" ]
	then
		FILEN=forbiddenfuncs
		F=$RETURNPATH/tmp/$FILEN.c
		check_create_tmp_dir
		echo "#include <sys/types.h>" > $F
		echo "#define NULL ((void *)0)" >> $F
		echo "void *ft_memset(void *b, int c, size_t len);" >> $F
		echo "void *ft_memcpy(void *restrict dst, const void *restrict src, size_t n);" >> $F
		echo "void ft_bzero(void *s, size_t n);" >> $F
		echo "size_t ft_strlen(const char *s);" >> $F
		echo "char *ft_strdup(const char *s1);" >> $F
		echo "char *ft_strcat(char *restrict s1, const char *restrict s2);" >> $F
		echo "int ft_isalpha(int c);" >> $F
		echo "int ft_isdigit(int c);" >> $F
		echo "int ft_isalnum(int c);" >> $F
		echo "int ft_isascii(int c);" >> $F
		echo "int ft_isprint(int c);" >> $F
		echo "int ft_toupper(int c);" >> $F
		echo "int ft_tolower(int c);" >> $F
		echo "void ft_puts(char *str);" >> $F
		echo "void ft_cat(int fd);" >> $F
		echo "int main(void) {" >> $F
		echo "ft_memset(NULL, 0, 0);" >> $F
		echo "ft_memcpy(NULL, NULL, 0);" >> $F
		echo "ft_bzero(NULL, 0);" >> $F
		echo "ft_strlen(NULL);" >> $F
		echo "ft_strdup(NULL);" >> $F
		echo "ft_strcat(NULL, NULL);" >> $F
		echo "ft_isalpha(0);" >> $F
		echo "ft_isdigit(0);" >> $F
		echo "ft_isalnum(0);" >> $F
		echo "ft_isascii(0);" >> $F
		echo "ft_isprint(0);" >> $F
		echo "ft_toupper(0);" >> $F
		echo "ft_tolower(0);" >> $F
		echo "ft_puts(NULL);" >> $F
		echo "ft_cat(0);" >> $F
		echo "return (1); }" >> $F
		cd "$RETURNPATH"/tmp
		make re -C "$MYPATH" 1>../$LOG_FILENAME 2>&1
		if [ -f "$MYPATH"/libftasm.a ]
		then
			$CMD_RM -f "$FILEN"
			$CMD_GCC "$F" -L"$MYPATH" -lftasm -o "$FILEN" >../$LOG_FILENAME 2>/dev/null
			cd "$RETURNPATH"
			if [ -f "./tmp/$FILEN" ]
			then
				check_forbidden_func CHK_LIBFTASM_AUTHORIZED_FUNCS "./tmp/$FILEN" s
			else
				printf $C_RED"  An error occured"$C_CLEAR
			fi
		else
			printf $C_RED"  Makefile does not compile"$C_CLEAR
		fi
	else
		printf $C_RED"  Makefile not found"$C_CLEAR
	fi
}

function check_libftasm_extra
{
	local i j exists TOTAL TOTAL2 RET0 LOGFILENAME
	LOGFILENAME=.myLIBFTASM_BONUS
	$CMD_RM -f $LOGFILENAME $LOGFILENAME
	$CMD_TOUCH $LOGFILENAME $LOGFILENAME
	TOTAL=0
	TOTAL2=0
	for i in $(ls -1 "$MYPATH" | sed '/^\.\/\./d' | grep -E \\.\[s\]$)
	do
		j=0
		exists=0
		while [ "$exists" == "0" -a "${LIBFTASM_MANDATORIES[$j]}" != "" ]
		do
			if [ "${LIBFTASM_MANDATORIES[$j]}" == "$i" ]
			then
				exists=1
				(( TOTAL += 1 ))
			fi
			(( j += 1 ))
		done
		j=0
		while [ "$exists" == "0" -a "${LIBFTASM_BONUS[$j]}" != "" ]
		do
			if [ "${LIBFTASM_BONUS[$j]}" == "$i" ]
			then
				exists=1
				(( TOTAL += 1 ))
			fi
			(( j += 1 ))
		done
		if [ "$exists" == "0" ]
		then
			(( TOTAL2 += 1 ))
			RET0=$RET0"Extra function: $i\n"
		fi
	done
	echo "$RET0" > $LOGFILENAME
	if [ "$TOTAL2" == "0" ]
	then
		printf $C_RED"  No extra functions were found"$C_CLEAR
	else
		if [ "$TOTAL2" == "1" ]
		then
			printf $C_GREEN"  1 extra function was found"$C_CLEAR
		else
			printf $C_GREEN"  $TOTAL2 extra functions were found"$C_CLEAR
		fi
	fi
}

function check_libftasm
{
	local MYPATH
	MYPATH=$(get_config "libftasm")
	display_header
	check_libftasm_top "$MYPATH"
	if [ -d "$MYPATH" ]
	then
		display_menu\
            ""\
			check_libftasm_all "check all!"\
			"_"\
			"TESTS" "CHK_LIBFTASM" "check_libftasm_all"\
			"_"\
			config_libftasm "change path"\
			main "BACK TO MAIN MENU"
	else
		display_menu\
			""\
			config_libftasm "configure"\
			main "BACK TO MAIN MENU"
	fi
}

function config_libftasm
{
	local AB0 AB2 MYPATH
	MYPATH=$(get_config "libftasm")
	display_header
	check_libftasm_top "$MYPATH"
	printf "  Please type the absolute path to your project:\n"$C_WHITE
	cd "$HOME/"
	tput cnorm
	read -p "  $HOME/" -e AB0
	tput civis
	AB0=`echo "$AB0" | sed 's/\/$//'`
	AB2="$HOME/$AB0"
	while [ "$AB0" == "" -o ! -d "$AB2" ]
	do
		display_header
		check_libftasm_top "$MYPATH"
		printf "  Please type the absolute path to your project:\n"
		if [ "$AB0" != "" ]
		then
			printf $C_RED"  $AB2: No such file or directory\n"$C_CLEAR$C_WHITE
		else
			printf $C_WHITE""
		fi
		tput cnorm
		read -p "  $HOME/" -e AB0
		tput civis
		AB0=`echo "$AB0" | sed 's/\/$//'`
		AB2="$HOME/$AB0"
	done
	cd "$RETURNPATH"
	save_config "libftasm" "$AB2"
	printf $C_CLEAR""
	check_libftasm
}

function check_libftasm_top
{
	local LPATH=$1
	local LHOME LEN
	LHOME=`echo "$HOME" | sed 's/\//\\\\\\//g'`
	LPATH="echo \"$LPATH\" | sed 's/$LHOME/~/'"
	LPATH=`eval $LPATH`
	printf $C_WHITE"\n\n"
	if [ "$1" != "" ]
	then
		printf "  Current configuration:"
		(( LEN=$COLUMNS - 24 ))
		printf "%"$LEN"s" "LIBFTASM  "
		printf $C_CLEAR"  $LPATH\n\n"
	else
		printf "  LIBFTASM\n"
		printf "\n"
	fi
    printf ""$C_CLEAR
}

fi;