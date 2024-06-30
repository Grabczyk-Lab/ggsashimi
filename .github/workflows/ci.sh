#!/bin/bash
set -e
set -u

fail() {
    echo ${1-""} >&2 && exit 1
}

# define global variables
bams="examples/input_bams.tsv"
region="chr10:27040584-27048100"

modes=(
    sashimi
    sashimi_anno
    sashimi_color
    sashimi_aggr
)

for mode in ${modes[@]}; do
    anno=""
    color=""
    aggr=""
    case $mode in
    sashimi_anno)
        sashimi_md5=(
            "a377e9fd6478784944e1ebbed544a6e7"
        )
        anno="-g examples/annotation.gtf"
        ;;
    sashimi_color)
        sashimi_md5=(
            "77c2fce34b2ee347e26ac3414d5a4c87"
        )
        color="-C 3"
        ;;
    sashimi_aggr)
        sashimi_md5=(
            "e71bdf32d5380688abdc27f772c2fb20"
        )
        aggr="-C 3 -O 3 -A mean_j"
        ;;
    *)
        sashimi_md5=(
            "50301d53d80f317f5a043e6b6f0ba833"
        )
        ;;
    esac
    ./ggsashimi.py $anno -b $bams -c $region $color $aggr
    md5=$(sed '/^\/\(.\+Date\|Producer\)/d' sashimi.pdf | md5sum | awk '$0=$1')
    [[ " ${sashimi_md5[@]} " =~ " ${md5} " ]] || fail "== Wrong checksum for $mode mode: $md5"
done

echo "== All checksums match"
echo "== DONE"

exit 0

