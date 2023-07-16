manualContent="$manual/share/doc/nixos"

docset="$out/share/${docsetName}.docset"
contents="$docset/Contents"

function sql {
  sqlite3 "$contents/Resources/docSet.dsidx" "$1"
}

function setupSchema {
  sql "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
  sql "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"
}

function index {
  local name="$1"
  local type="$2"
  local path="$3"
  sql "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('$name', '$type', '$path');"
}

function scaffold {
  echo "Scaffolding"
  mkdir -p "$contents/Resources/Documents/options/"
  mustache "$env" "$src/Info.tpl.plist" > "$contents/Info.plist"
  mustache "$env" "$src/meta.tpl.json" > "$docset/meta.json"
  cp "$src/nixos-logo.png" "$docset/icon.png"
  setupSchema
}

function copyManual {
  echo "Copying manual"
  cp -r "$manualContent/." "$contents/Resources/Documents/"
}

function mkOptionSlug {
  local name="$1"
  echo "opt-$(echo "$name" | sed 's/[<>* ]/_/g')"
}

function indexOption {
  local name="$1"
  echo "Option '$name': indexing"
  local slug="$(mkOptionSlug "$name")"
  index "$name" "Option" "options/${slug}.html#${slug}"
}

function dropNewlines {
  sed -z 's/\n/ /g'
}

function escapeQuotes {
  sed 's/"/\\"/g'
}

function wrapHTML {
  sed 's-^-<?xml version="1.0"?><b xmlns:xlink="https://www.w3.org/1999/xlink">-;s-$-</b>-'
}

function replaceLinks {
  wrapHTML | xsltproc "$src/links.xslt" -
}

function generateOptionPage {
  local name="$1"
  echo "Option '$name': generating webpage"

  slug=$(mkOptionSlug "$name")

  optionType="$(       readOptionAttribute "$name" "type"                                                     )"
  optionDescription="$(readOptionAttribute "$name" "description" | dropNewlines | replaceLinks | escapeQuotes )"
  optionExample="$(    readOptionAttribute "$name" "example"     | dropNewlines                | escapeQuotes )"
  optionDefault="$(    readOptionAttribute "$name" "default"     | dropNewlines                | escapeQuotes )"
  # FIXME this might be properly working
  optionSource="$(     readOptionAttribute "$name" "declarations[0]"                                          )"

  echo "{ \"name\": \"$name\", \"slug\": \"$slug\", \"type\": \"$optionType\", \"description\": \"$optionDescription\", \"default\": \"$optionDefault\", \"source\": \"$optionSource\", \"example\": \"$optionExample\" }" > "${slug}.json"

  mustache "${slug}.json" "$src/option.tpl.html" > "$contents/Resources/Documents/options/${slug}.html"
}

function readOptionAttribute {
  local name="$1"
  local attribute="$2"
  jq ".\"${name}\".${attribute}" "$options/share/doc/nixos/options.json" -r
}

function processOption {
  local name="$1"
  generateOptionPage "$name"
  indexOption        "$name"
}

function listOptions {
  jq keys[] $options/share/doc/nixos/options.json -r | head -$maxOptionsToIndex
}

function processOptions {
  listOptions | while read opt; do processOption "$opt"; done
}

function archive {
  tar -cvzf "$out/share/${docsetName}.tgz" "$docset"
}

scaffold
copyManual
processOptions
archive
