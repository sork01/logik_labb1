for f in tests/valid*.txt; do
    MAINCMD="main('"$f"')."
    echo "$(swipl -t $MAINCMD labb1.pl 2>/dev/null)"
done
