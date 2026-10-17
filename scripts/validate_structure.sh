#! /bin/bash
#
## @file                validate_structure.sh
## @brief               Validates the changes made by a pull request.
## @section LICENSE     Apache
##
## Usage: validate_structure.sh [BASE_REF [HEAD_REF]]
##   BASE_REF  defaults to HEAD^1 (first parent of the PR merge commit)
##   HEAD_REF  defaults to HEAD
##
## Checks:
##   - New or renamed files: name, size, extension and folder.
##   - Any change: symbolic links and submodules are not accepted.
##   - Any change: protected paths are managed by the parent repository.
##
## Environment (all optional):
##   MAX_FILE_SIZE_MB   files larger than this are errors   (default 50)
##   WARN_FILE_SIZE_MB  files larger than this are warnings (default 20)
##   ALLOWED_DIRS       space separated top level folders
##   ALLOWED_ROOT_FILES space separated files allowed in the repository root
##   PROTECTED_PATHS    space separated paths that a PR must not change
##
## Errors fail the run. Warnings are only reported.
## Output uses GitHub workflow annotations and the job summary when available.

set -euo pipefail
export LC_ALL=C

base_ref="${1:-HEAD^1}"
head_ref="${2:-HEAD}"
max_size_mb="${MAX_FILE_SIZE_MB:-50}"
warn_size_mb="${WARN_FILE_SIZE_MB:-20}"

read -r -a allowed_dirs <<< "${ALLOWED_DIRS:-apuntes practico teorico libros ExamenesViejos exams examples docs assets}"
read -r -a allowed_root_files <<< "${ALLOWED_ROOT_FILES:-README.md LICENSE CONTRIBUTING.md CODEOWNERS}"
read -r -a protected_paths <<< "${PROTECTED_PATHS:-.github .gitmodules Famaf-Resources-Manager}"

forbidden_chars=(' ' '#' '%' '&' '{' '}' "\\" '<' '>' '*' '?' '$' '!' "'" '"' '`' ':' '|')
blocked_extensions=(exe dll msi apk dmg bat cmd scr jar)

protected_message="Esta ruta la gestiona automáticamente el repositorio padre (Famaf-Resources-Manager). Los cambios se hacen allí, no con un PR en este repositorio."

errors=0
warnings=0
rows=()

escape_data() {
  local s="$1"
  s="${s//'%'/%25}"
  s="${s//$'\r'/%0D}"
  s="${s//$'\n'/%0A}"
  printf '%s' "$s"
}

escape_property() {
  local s
  s="$(escape_data "$1")"
  s="${s//':'/%3A}"
  s="${s//','/%2C}"
  printf '%s' "$s"
}

# report LEVEL(error|warning) PATH MESSAGE
report() {
  local level="$1" path="$2" message="$3" printable
  printf '::%s file=%s,title=%s::%s\n' \
    "$level" "$(escape_property "$path")" "$(escape_property "Estructura")" "$(escape_data "$message")"
  printable="${path//[[:cntrl:]]/?}"
  printable="${printable//'|'/\\|}"
  printable="${printable//'`'/\\\`}"
  rows+=("| ${level} | \`${printable}\` | ${message//'|'/\\|} |")
  if [[ "$level" == error ]]; then
    errors=$((errors + 1))
  else
    warnings=$((warnings + 1))
  fi
}

check_path() {
  local path="$1" name ext top c size dir found suggestion

  name="${path##*/}"

  if [[ "$path" =~ [[:cntrl:]] ]]; then
    report error "$path" "El nombre contiene caracteres de control."
  elif [[ "$path" =~ [^\ -~] ]]; then
    report warning "$path" "El nombre contiene caracteres no ASCII (acentos, ñ, etc.). Es válido, pero puede dar problemas en algunos sistemas; considera evitarlos."
  fi

  for c in "${forbidden_chars[@]}"; do
    if [[ "$path" == *"$c"* ]]; then
      report error "$path" "El nombre contiene el carácter '${c}', que rompe enlaces o no es válido en todos los sistemas. Reemplázalo por '_' o '-'."
      break
    fi
  done

  if [[ "$name" == *.* ]]; then
    ext="${name##*.}"
    ext="${ext,,}"
    for c in "${blocked_extensions[@]}"; do
      if [[ "$ext" == "$c" ]]; then
        report error "$path" "No se aceptan archivos ejecutables o instaladores (.${ext})."
      fi
    done
  fi

  if size="$(git cat-file -s "${head_ref}:${path}" 2>/dev/null)"; then
    if (( size > max_size_mb * 1024 * 1024 )); then
      report error "$path" "El archivo pesa $(( size / 1024 / 1024 )) MB y el máximo es ${max_size_mb} MB. Comprímelo o divídelo."
    elif (( size > warn_size_mb * 1024 * 1024 )); then
      report warning "$path" "El archivo pesa $(( size / 1024 / 1024 )) MB. Considera comprimirlo."
    fi
  fi

  if [[ "$path" != */* ]]; then
    found=0
    for c in "${allowed_root_files[@]}"; do
      [[ "$name" == "$c" ]] && found=1
    done
    [[ "$name" == .* ]] && found=1
    if (( ! found )); then
      report warning "$path" "Los recursos no deberían ir en la raíz. Muévelo a una carpeta como: ${allowed_dirs[*]}."
    fi
    return
  fi

  top="${path%%/*}"
  found=0
  suggestion=""
  for dir in "${allowed_dirs[@]}"; do
    if [[ "$top" == "$dir" ]]; then
      found=1
    elif [[ "${top,,}" == "${dir,,}" ]]; then
      suggestion="$dir"
    fi
  done
  if (( ! found )); then
    if [[ -n "$suggestion" ]]; then
      report warning "$path" "La carpeta '${top}' debería llamarse '${suggestion}' (respeta mayúsculas y minúsculas)."
    else
      report warning "$path" "La carpeta '${top}' no es una carpeta estándar. Carpetas esperadas: ${allowed_dirs[*]}."
    fi
  fi
}

is_protected() {
  local path="$1" p
  for p in "${protected_paths[@]}"; do
    if [[ "$path" == "$p" || "$path" == "$p"/* ]]; then
      return 0
    fi
  done
  return 1
}

# check_change PATH MODE STATUS OLD_PATH
check_change() {
  local path="$1" mode="$2" status="$3" old_path="$4"

  if [[ -n "$old_path" ]] && is_protected "$old_path"; then
    report error "$old_path" "$protected_message"
  fi

  if is_protected "$path"; then
    report error "$path" "$protected_message"
    return 0
  fi

  if [[ "$status" == D ]]; then
    return 0
  fi

  case "$mode" in
    120000)
      report error "$path" "No se aceptan enlaces simbólicos: pueden apuntar fuera del repositorio. Agrega el archivo real."
      return 0
      ;;
    160000)
      report error "$path" "No se aceptan submódulos agregados desde un PR."
      return 0
      ;;
  esac

  if [[ "$status" == A || "$status" == R* ]]; then
    check_path "$path"
  fi
  return 0
}

if ! git rev-parse --verify --quiet "${base_ref}^{commit}" > /dev/null \
  || ! git rev-parse --verify --quiet "${head_ref}^{commit}" > /dev/null; then
  echo "No se pudieron resolver '${base_ref}' y '${head_ref}'. ¿El checkout tiene suficiente historial (fetch-depth: 2)?" >&2
  exit 2
fi

checked=0
# Raw format: ":OLDMODE NEWMODE OLDSHA NEWSHA STATUS" NUL PATH NUL (two paths for renames).
while IFS= read -r -d '' meta; do
  read -r _ new_mode _ _ status <<< "${meta#:}"
  IFS= read -r -d '' path
  old_path=""
  if [[ "$status" == R* ]]; then
    old_path="$path"
    IFS= read -r -d '' path
  fi
  checked=$((checked + 1))
  check_change "$path" "$new_mode" "$status" "$old_path"
done < <(git diff -z --raw --no-abbrev -M "$base_ref" "$head_ref")

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## Validación de estructura"
    echo
    echo "Cambios revisados: **${checked}**. Errores: **${errors}**. Avisos: **${warnings}**."
    if (( ${#rows[@]} > 0 )); then
      echo
      echo "| Nivel | Archivo | Detalle |"
      echo "|-------|---------|---------|"
      printf '%s\n' "${rows[@]}"
    fi
  } >> "$GITHUB_STEP_SUMMARY"
fi

echo "Cambios revisados: ${checked}. Errores: ${errors}. Avisos: ${warnings}."

if (( errors > 0 )); then
  exit 1
fi
