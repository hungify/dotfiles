function trash() {
    echo "🗑️  Moving files to trash..."

    for var in "$@"; do
        mv "$var" "$HOME/.trash"
    done
}

c() {
    if [[ -n $1 ]]; then
        code "$1"
    else
        code .
    fi
}

z() {
    if [[ -n =$1 ]]; then
        zed "$1"
    else
        zed .
    fi
}

o() {
    if [[ -n =$1 ]]; then
        open "$1"
    else
        open .
    fi
}
