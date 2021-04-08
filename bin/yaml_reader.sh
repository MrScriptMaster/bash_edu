#!/bin/bash

yaml_reader() {
    [[ -f $1 ]] && [[ -r $1 ]] || return 1
    # YAML parser
    # Thanks to Jonathan (https://github.com/jasperes/bash-yaml)
    # Restrictions:
    #   * Literals must be at the same level as the key.
    #   * Doesn't work: 
    #      -- [a, b]
    #      -- {a:a, b:b}
    #      -- [|>[-]]
    # Legend:
    #  ("value")           Entry's value
    #  =("value")          First level sequence element
    #  _+=("value")        Second level sequence element
    #  __+=("value")       Third level sequence element
    #  [_]{n}+=            n-level sequence element
    #  <key>=("value")     Key-Value entry
    #  <key>_<sub_key>=("value")   First level key-value element
    #  <key>_<sub_key>_<sub_sub_key>=("value")
    #  <key>_<sub_key>...[_<subN...key>]=("value")
    __yaml_parser() {
        local yaml_file=$1
        local prefix=$2
        local delim=$(printf "\a")
        local prx=${3:-_}
        local s='[[:space:]]*'
        local w='[a-zA-Z0-9_.-]*'
        local fs="$(echo @ | tr @ '\034')"
        (
            sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |
                sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
                    -e 's/\$/\\\$/g' \
                    -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
                    -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
                    -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |
                awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("'"$prx"'")}
                    printf("%s%s%s%s=(\"%s\")%s", "'"$prefix"'",vn, $2, conj[indent-1], $3, "'"$delim"'");
                }
            }' |
                sed -e 's/_=/+=/g' |
                awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                gsub("-|\\.", "_", $1)
            }
            { print }'
        ) <"$yaml_file"
    }
    local seq_sign=${2:-_}
    local prefix=${3}
    OLD_IFS=$IFS
    IFS=$(printf "\a")
    for entry in $(__yaml_parser "$1" "$prefix" "$2"); do
        [[ -n $entry ]] && echo $entry
    done
    IFS=$OLD_IFS
}

yaml_reader "./test.yml" @
