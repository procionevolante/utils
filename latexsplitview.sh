#!/bin/sh
# a small script that (re)compiles a .tex file whenever it changes.
# the pdf file is also opened at at the beginning of execution

cat <<-	'EOF'
	hey, psst: did you know of the existance of `latexmk`? Me neither!
	but you should really try it, it's basically this script on steroids
EOF

if [ $# -ne 1 ]; then
	echo USAGE: $0 [.tex file] >&2
	exit 1
fi

if ! [ -r "$1" -a -f "$1" ]; then
	echo "either file '$1' does not exists or we don't have read permission"
	exit 2
fi

onexit() {
	rm -rf "$tmpdir"
	kill $pdfreaderPID
	exit
}

tmpdir="$(mktemp --tmpdir -d autotexupdate.XXXXXX)"
infile="$1"

trap onexit TERM INT QUIT

cd "$(dirname "$infile")"

# ensure we produce a valid document before opening the pdf
until pdflatex -halt-on-error -output-directory "$tmpdir" -jobname "out" "$infile"; do
	# wait for the file to change...
	echo "$infile" | entr -pzc true 
done

# start the pdf viewer
okular "$tmpdir/out.pdf" 2>/dev/null >/dev/null &
pdfreaderPID=$!

echo ---
echo 'initialization completed. Close with ^C'
echo ---

while true; do
	echo "$infile" | entr -pzc true 
	# can't execute pdflatex directly because -z doesn't forward the exit status
	# of the launched utility
	pdflatex -halt-on-error -output-directory "$tmpdir" -jobname "out" "$infile"
	if [ $? -ne 0 ]; then
		notify-send -i dialog-warning 'latexsplitview' "can't recompile!"
	fi
done

onexit
