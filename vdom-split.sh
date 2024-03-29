#!/bin/bash
#
# Daniel Amendoeira, initial version 2024.03.29

INPUT=$1

mkdir ${INPUT%.*}

VDOM_CREATE_START=$(grep "config vdom" --line-number $INPUT | head -n 1 | cut -f1 -d:)
VDOM_CREATE_END=$(tail -n +${VDOM_CREATE_START} $INPUT | grep -Ee "^end" --line-number | head -n1 | cut -f1 -d:)

VDOM_NAMES=( $(tail -n +${VDOM_CREATE_START} $INPUT | head -n $VDOM_CREATE_END | grep edit | cut -f2 -d' ') )

VDOM_QTY=${#VDOM_NAMES[@]}

OFFSET=$(( $VDOM_CREATE_START + $VDOM_CREATE_END - 1 ))

VDOM_LINE=( $( tail -n +$(( $OFFSET + 2 )) $INPUT | grep -F -f <(printf "edit %s\n" "${VDOM_NAMES[@]}") --line-number | cut -f1 -d: ) )

#echo ${VDOM_LINE[@]}

# extract global

echo "_global"

head -n $(( ${VDOM_LINE[0]} + $OFFSET - 1 )) $INPUT > ${INPUT%.*}/_global.${INPUT#*.}

# extract all but last vdom

for (( V = 0 ; V <= $VDOM_QTY - 2 ; V++ ))
do
  echo ${VDOM_NAMES[$V]}
  sed -n "$(( ${VDOM_LINE[$V]} + $OFFSET )),$(( ${VDOM_LINE[$(( $V + 1 ))]} + $OFFSET - 2 ))p" $INPUT > ${INPUT%.*}/${VDOM_NAMES[$V]}.${INPUT#*.}
done

# extract last vdom

echo ${VDOM_NAMES[$V]}
sed -n "$(( ${VDOM_LINE[$V]} + $OFFSET )),\$p" $INPUT > ${INPUT%.*}/${VDOM_NAMES[$V]}.${INPUT#*.}
