# Utility functions for manipulating PATH vars
# Should be compatible with both bash and zsh

# NOTE: _path is used because zsh is dumb and shadows `path` with some incompatible nonsense

# path-remove directory [PATH]
function path-remove {
  local _path="$1"
  local pathVar="${2:-PATH}"
  local currPath
  if [[ -n "$BASH_VERSION" ]]; then currPath="${!pathVar}"; else currPath="${(P)pathVar}"; fi
  local newPath="$(echo -n "$currPath" | tr ':' '\n' | grep -vxF "$_path" | tr '\n' ':' | sed 's/:$//')"
  export "$pathVar"="$newPath"
}

# Add or update directory to beginning of path
# path-prepend directory [PATH]
function path-prepend {
  local _path="$1"
  local pathVar="${2:-PATH}"
  path-remove "$_path" "$pathVar"
  local cleanPath
  if [[ -n "$BASH_VERSION" ]]; then cleanPath="${!pathVar}"; else cleanPath="${(P)pathVar}"; fi
  export "$pathVar"="${_path}:${cleanPath}"
}

# Add or update directory to end of path
# path-append directory [PATH]
function path-append {
  local _path="$1"
  local pathVar="${2:-PATH}"
  path-remove "$_path" "$pathVar"
  local cleanPath
  if [[ -n "$BASH_VERSION" ]]; then cleanPath="${!pathVar}"; else cleanPath="${(P)pathVar}"; fi
  export "$pathVar"="${cleanPath}:${_path}"
}
