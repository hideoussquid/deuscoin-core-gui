#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

DEUSCOIND=${DEUSCOIND:-$SRCDIR/deuscoind}
DEUSCOINCLI=${DEUSCOINCLI:-$SRCDIR/deuscoin-cli}
DEUSCOINTX=${DEUSCOINTX:-$SRCDIR/deuscoin-tx}
DEUSCOINQT=${DEUSCOINQT:-$SRCDIR/qt/deuscoin-qt}

[ ! -x $DEUSCOIND ] && echo "$DEUSCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
DEUSVER=($($DEUSCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for deuscoind if --version-string is not set,
# but has different outcomes for deuscoin-qt and deuscoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$DEUSCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $DEUSCOIND $DEUSCOINCLI $DEUSCOINTX $DEUSCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${DEUSVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${DEUSVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
