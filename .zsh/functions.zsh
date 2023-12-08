trash() {
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
    if [[ -n $1 ]]; then
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

# npm scripts
dev() {
    if [[ -f package.json ]]; then
        echo "🚧  Developing..."
        npm run dev
    else
        command dev "$@"
    fi
}

build() {
    if [[ -f package.json ]]; then
        echo "🏗️  Building..."
        npm run build
    else
        command build "$@"
    fi
}

test() {
    if [[ -f package.json ]]; then
        echo "🧪  Running tests..."
        npm run test
    else
        command test "$@"
    fi
}

coverage() {
    if [[ -f package.json ]]; then
        echo "📊  Running coverage..."
        npm run coverage
    else
        command coverage "$@"
    fi
}

start() {
    if [[ -f package.json ]]; then
        echo "🚀  Starting..."
        npm run start
    else
        command start "$@"
    fi
}

serve() {
    if [[ -f package.json ]]; then
        echo "🚀  Serving..."
        npm run serve
    else
        command serve "$@"
    fi

}

install() {
    if [[ -f package.json ]]; then
        if [[ -f yarn.lock ]]; then
            echo "📦  Installing dependencies... by yarn"
            yarn install
        elif [[ -f pnpm-lock.yaml || -f package-lock.json ]]; then
            echo "📦  Installing dependencies... by pnpm"
            pnpm install
        fi
    else
        command serve "$@"
    fi
}

run() {
    if [[ -f Cargo.toml ]]; then
        echo "🚀  Running..."
        cargo run
    else
        command run "$@"
    fi
}
