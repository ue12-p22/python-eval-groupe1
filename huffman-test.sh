#!/bin/bash

REF=/Users/tparment/git/ue12-p22-python-eval-groupe1
#DEBUG=--debug

function spot() {
    for x in "$@"; do
        if [ -f $x ]; then
            echo $x
            break
        fi
    done
}

# possible locations...
step1=$(spot huffman-analyze.py hufmann-analyze.py huffman_analyze.py hufmann_analyze.py huffman-analyse.py)
step2=$(spot huffman.py hufmann.py)

echo step1=$step1 step2=$step2
[ -z "$step1" ] && { echo "cannot locate step1 - exiting"; exit 1; }
[ -z "$step2" ] && { echo "cannot locate step2 - exiting"; exit 1; }

function prep()   { echo "=========="; echo python $step1 $DEBUG "$@"; python $step1 "$@"; }
function encode() { echo "=========="; echo python $step2 $DEBUG "$@"; python $step2 "$@"; }
function decode() { echo "=========="; echo python $step2 $DEBUG --decode "$@"; python $step2 --decode "$@"; }

# create selfcoded.coder
function selfcoded() {
    local n="$1"; shift

    local s="selfcoded-$n"
    local defcoder="$s.coder"
    local expcoder="sc-$n.coder"

    prep $s.txt
    if [ -f "$defcoder" ]; then
        echo "stored coder in $defcoder"; cat $defcoder
    else
        echo default coder output file NOT WORKING
    fi

    prep $s.txt --coder $expcoder
    if [ -f "$expcoder" ]; then
        echo stored coder in $expcoder; cat $expcoder
    else
        echo explicit coder output file NOT WORKING
    fi

    encode --coder $expcoder $s.txt
    [ -f $s.txt.huf ] || echo expected $s.txt.huf not found

    decode --coder $expcoder $s.txt.huf -o $s.loop
    [ -f $s.loop ] || echo expected $s.loop not found

    encode --coder $expcoder $s.txt -o $s.huf
    [ -f $s.huf ] || echo expected $s.huf not found

    decode --coder $expcoder $s.huf -o $s.loop
    [ -f $s.loop ] || echo expected $s.loop not found

    echo "=========="
    cmp $s.txt $s.loop && echo LOOP OK || echo "LOOP KO broken with $s"

}

function english() {
    prep --coder english.coder english.txt
    encode --coder english.coder english.txt -o english.txt.huf
    decode --coder english.coder english.txt.huf -o english.loop
    cmp english.txt english.loop && echo LOOP OK || echo LOOP KO broken with english
}

###

function sc01 () { selfcoded 01; }
function sc02 () { selfcoded 02; }

function missing() {
    for file in 00-NOTE.md selfcoded-01.txt selfcoded-02.txt english.txt; do
        if [ ! -f $file ]; then
            echo installing distrib $file from $REF
            cp $REF/$file .
        fi
    done
}


function all() { sc01; sc02; english; }

main() {
    for subcommand in "$@"; do
        $subcommand
    done
}


main "$@"
