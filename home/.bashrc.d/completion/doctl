# bash completion for doctl                                -*- shell-script -*-

__debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__my_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__handle_reply()
{
    __debug "${FUNCNAME[0]}"
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            COMPREPLY=( $(compgen -W "${allflags[*]}" -- "$cur") )
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%%=*}"
                __index_of_word "${flag}" "${flags_with_completion[@]}"
                if [[ ${index} -ge 0 ]]; then
                    COMPREPLY=()
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zfs completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions=("${must_have_one_flag[@]}")
    elif [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    else
        completions=("${commands[@]}")
    fi
    COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        COMPREPLY=( $(compgen -W "${noun_aliases[*]}" -- "$cur") )
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        declare -F __custom_func >/dev/null && __custom_func
    fi

    __ltrim_colon_completions "$cur"
}

# The arguments should be in the form "ext1|ext2|extn"
__handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1
}

__handle_flag()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # keep flag value with flagname as flaghash
    if [ -n "${flagvalue}" ] ; then
        flaghash[${flagname}]=${flagvalue}
    elif [ -n "${words[ $((c+1)) ]}" ] ; then
        flaghash[${flagname}]=${words[ $((c+1)) ]}
    else
        flaghash[${flagname}]="true" # pad "true" for bool flag
    fi

    # skip the argument to a two word flag
    if __contains_word "${words[c]}" "${two_word_flags[@]}"; then
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__handle_noun()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__handle_command()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_$(basename "${words[c]//:/__}")"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F $next_command >/dev/null && $next_command
}

__handle_word()
{
    if [[ $c -ge $cword ]]; then
        __handle_reply
        return
    fi
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __handle_flag
    elif __contains_word "${words[c]}" "${commands[@]}"; then
        __handle_command
    elif [[ $c -eq 0 ]] && __contains_word "$(basename "${words[c]}")" "${commands[@]}"; then
        __handle_command
    else
        __handle_noun
    fi
    __handle_word
}

_doctl_account_get()
{
    last_command="doctl_account_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_account_ratelimit()
{
    last_command="doctl_account_ratelimit"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_account()
{
    last_command="doctl_account"
    commands=()
    commands+=("get")
    commands+=("ratelimit")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_auth_init()
{
    last_command="doctl_auth_init"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_auth()
{
    last_command="doctl_auth"
    commands=()
    commands+=("init")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_action_get()
{
    last_command="doctl_compute_action_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_action_list()
{
    last_command="doctl_compute_action_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--action-type=")
    flags+=("--after=")
    flags+=("--before=")
    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--region=")
    flags+=("--resource-type=")
    flags+=("--status=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_action_wait()
{
    last_command="doctl_compute_action_wait"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--poll-timeout=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_action()
{
    last_command="doctl_compute_action"
    commands=()
    commands+=("get")
    commands+=("list")
    commands+=("wait")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_get()
{
    last_command="doctl_compute_droplet-action_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--action-id=")
    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_disable-backups()
{
    last_command="doctl_compute_droplet-action_disable-backups"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_reboot()
{
    last_command="doctl_compute_droplet-action_reboot"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_power-cycle()
{
    last_command="doctl_compute_droplet-action_power-cycle"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_shutdown()
{
    last_command="doctl_compute_droplet-action_shutdown"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_power-off()
{
    last_command="doctl_compute_droplet-action_power-off"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_power-on()
{
    last_command="doctl_compute_droplet-action_power-on"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_password-reset()
{
    last_command="doctl_compute_droplet-action_password-reset"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_enable-ipv6()
{
    last_command="doctl_compute_droplet-action_enable-ipv6"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_enable-private-networking()
{
    last_command="doctl_compute_droplet-action_enable-private-networking"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_upgrade()
{
    last_command="doctl_compute_droplet-action_upgrade"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_restore()
{
    last_command="doctl_compute_droplet-action_restore"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--image-id=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_resize()
{
    last_command="doctl_compute_droplet-action_resize"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--resize-disk")
    flags+=("--size=")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_rebuild()
{
    last_command="doctl_compute_droplet-action_rebuild"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--image=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_rename()
{
    last_command="doctl_compute_droplet-action_rename"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--droplet-name=")
    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_change-kernel()
{
    last_command="doctl_compute_droplet-action_change-kernel"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--kernel-id=")
    flags+=("--no-header")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action_snapshot()
{
    last_command="doctl_compute_droplet-action_snapshot"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--snapshot-name=")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet-action()
{
    last_command="doctl_compute_droplet-action"
    commands=()
    commands+=("get")
    commands+=("disable-backups")
    commands+=("reboot")
    commands+=("power-cycle")
    commands+=("shutdown")
    commands+=("power-off")
    commands+=("power-on")
    commands+=("password-reset")
    commands+=("enable-ipv6")
    commands+=("enable-private-networking")
    commands+=("upgrade")
    commands+=("restore")
    commands+=("resize")
    commands+=("rebuild")
    commands+=("rename")
    commands+=("change-kernel")
    commands+=("snapshot")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_actions()
{
    last_command="doctl_compute_droplet_actions"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_backups()
{
    last_command="doctl_compute_droplet_backups"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_create()
{
    last_command="doctl_compute_droplet_create"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--enable-backups")
    flags+=("--enable-ipv6")
    flags+=("--enable-private-networking")
    flags+=("--format=")
    flags+=("--image=")
    flags+=("--no-header")
    flags+=("--region=")
    flags+=("--size=")
    flags+=("--ssh-keys=")
    flags+=("--tag-name=")
    flags+=("--tag-names=")
    flags+=("--user-data=")
    flags+=("--user-data-file=")
    flags+=("--volumes=")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_delete()
{
    last_command="doctl_compute_droplet_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_get()
{
    last_command="doctl_compute_droplet_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--template=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_kernels()
{
    last_command="doctl_compute_droplet_kernels"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_list()
{
    last_command="doctl_compute_droplet_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--region=")
    flags+=("--tag-name=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_neighbors()
{
    last_command="doctl_compute_droplet_neighbors"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_snapshots()
{
    last_command="doctl_compute_droplet_snapshots"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_tag()
{
    last_command="doctl_compute_droplet_tag"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--tag-name=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet_untag()
{
    last_command="doctl_compute_droplet_untag"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--tag-name=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_droplet()
{
    last_command="doctl_compute_droplet"
    commands=()
    commands+=("actions")
    commands+=("backups")
    commands+=("create")
    commands+=("delete")
    commands+=("get")
    commands+=("kernels")
    commands+=("list")
    commands+=("neighbors")
    commands+=("snapshots")
    commands+=("tag")
    commands+=("untag")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_create()
{
    last_command="doctl_compute_domain_create"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--ip-address=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_list()
{
    last_command="doctl_compute_domain_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_get()
{
    last_command="doctl_compute_domain_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_delete()
{
    last_command="doctl_compute_domain_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_records_list()
{
    last_command="doctl_compute_domain_records_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--domain-name=")
    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_records_create()
{
    last_command="doctl_compute_domain_records_create"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--record-data=")
    flags+=("--record-name=")
    flags+=("--record-port=")
    flags+=("--record-priority=")
    flags+=("--record-type=")
    flags+=("--record-weight=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_records_delete()
{
    last_command="doctl_compute_domain_records_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_records_update()
{
    last_command="doctl_compute_domain_records_update"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--record-data=")
    flags+=("--record-id=")
    flags+=("--record-name=")
    flags+=("--record-port=")
    flags+=("--record-priority=")
    flags+=("--record-type=")
    flags+=("--record-weight=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain_records()
{
    last_command="doctl_compute_domain_records"
    commands=()
    commands+=("list")
    commands+=("create")
    commands+=("delete")
    commands+=("update")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_domain()
{
    last_command="doctl_compute_domain"
    commands=()
    commands+=("create")
    commands+=("list")
    commands+=("get")
    commands+=("delete")
    commands+=("records")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip_create()
{
    last_command="doctl_compute_floating-ip_create"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--droplet-id=")
    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--region=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip_get()
{
    last_command="doctl_compute_floating-ip_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip_delete()
{
    last_command="doctl_compute_floating-ip_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip_list()
{
    last_command="doctl_compute_floating-ip_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--region=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip()
{
    last_command="doctl_compute_floating-ip"
    commands=()
    commands+=("create")
    commands+=("get")
    commands+=("delete")
    commands+=("list")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip-action_get()
{
    last_command="doctl_compute_floating-ip-action_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip-action_assign()
{
    last_command="doctl_compute_floating-ip-action_assign"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip-action_unassign()
{
    last_command="doctl_compute_floating-ip-action_unassign"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_floating-ip-action()
{
    last_command="doctl_compute_floating-ip-action"
    commands=()
    commands+=("get")
    commands+=("assign")
    commands+=("unassign")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image_list()
{
    last_command="doctl_compute_image_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--public")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image_list-distribution()
{
    last_command="doctl_compute_image_list-distribution"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--public")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image_list-application()
{
    last_command="doctl_compute_image_list-application"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--public")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image_list-user()
{
    last_command="doctl_compute_image_list-user"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--public")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image_get()
{
    last_command="doctl_compute_image_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image_update()
{
    last_command="doctl_compute_image_update"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--image-name=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image_delete()
{
    last_command="doctl_compute_image_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image()
{
    last_command="doctl_compute_image"
    commands=()
    commands+=("list")
    commands+=("list-distribution")
    commands+=("list-application")
    commands+=("list-user")
    commands+=("get")
    commands+=("update")
    commands+=("delete")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image-action_get()
{
    last_command="doctl_compute_image-action_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--action-id=")
    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image-action_transfer()
{
    last_command="doctl_compute_image-action_transfer"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--region=")
    flags+=("--wait")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_image-action()
{
    last_command="doctl_compute_image-action"
    commands=()
    commands+=("get")
    commands+=("transfer")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_plugin_list()
{
    last_command="doctl_compute_plugin_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_plugin_run()
{
    last_command="doctl_compute_plugin_run"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_plugin()
{
    last_command="doctl_compute_plugin"
    commands=()
    commands+=("list")
    commands+=("run")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_region_list()
{
    last_command="doctl_compute_region_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_region()
{
    last_command="doctl_compute_region"
    commands=()
    commands+=("list")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_size_list()
{
    last_command="doctl_compute_size_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_size()
{
    last_command="doctl_compute_size"
    commands=()
    commands+=("list")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh-key_list()
{
    last_command="doctl_compute_ssh-key_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh-key_get()
{
    last_command="doctl_compute_ssh-key_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh-key_create()
{
    last_command="doctl_compute_ssh-key_create"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--public-key=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh-key_import()
{
    last_command="doctl_compute_ssh-key_import"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--public-key-file=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh-key_delete()
{
    last_command="doctl_compute_ssh-key_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh-key_update()
{
    last_command="doctl_compute_ssh-key_update"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--key-name=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh-key()
{
    last_command="doctl_compute_ssh-key"
    commands=()
    commands+=("list")
    commands+=("get")
    commands+=("create")
    commands+=("import")
    commands+=("delete")
    commands+=("update")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_tag_create()
{
    last_command="doctl_compute_tag_create"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_tag_get()
{
    last_command="doctl_compute_tag_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_tag_list()
{
    last_command="doctl_compute_tag_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_tag_update()
{
    last_command="doctl_compute_tag_update"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--tag-name=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_tag_delete()
{
    last_command="doctl_compute_tag_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_tag()
{
    last_command="doctl_compute_tag"
    commands=()
    commands+=("create")
    commands+=("get")
    commands+=("list")
    commands+=("update")
    commands+=("delete")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume_list()
{
    last_command="doctl_compute_volume_list"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume_create()
{
    last_command="doctl_compute_volume_create"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--desc=")
    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--region=")
    flags+=("--size=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume_delete()
{
    last_command="doctl_compute_volume_delete"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume_get()
{
    last_command="doctl_compute_volume_get"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    flags+=("--no-header")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume()
{
    last_command="doctl_compute_volume"
    commands=()
    commands+=("list")
    commands+=("create")
    commands+=("delete")
    commands+=("get")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume-action_attach()
{
    last_command="doctl_compute_volume-action_attach"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume-action_detach()
{
    last_command="doctl_compute_volume-action_detach"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_volume-action()
{
    last_command="doctl_compute_volume-action"
    commands=()
    commands+=("attach")
    commands+=("detach")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute_ssh()
{
    last_command="doctl_compute_ssh"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ssh-agent-forwarding")
    flags+=("--ssh-key-path=")
    flags+=("--ssh-port=")
    flags+=("--ssh-private-ip")
    flags+=("--ssh-user=")
    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_compute()
{
    last_command="doctl_compute"
    commands=()
    commands+=("action")
    commands+=("droplet-action")
    commands+=("droplet")
    commands+=("domain")
    commands+=("floating-ip")
    commands+=("floating-ip-action")
    commands+=("image")
    commands+=("image-action")
    commands+=("plugin")
    commands+=("region")
    commands+=("size")
    commands+=("ssh-key")
    commands+=("tag")
    commands+=("volume")
    commands+=("volume-action")
    commands+=("ssh")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl_version()
{
    last_command="doctl_version"
    commands=()

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_doctl()
{
    last_command="doctl"
    commands=()
    commands+=("account")
    commands+=("auth")
    commands+=("compute")
    commands+=("version")

    flags=()
    two_word_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--access-token=")
    two_word_flags+=("-t")
    flags+=("--config=")
    two_word_flags+=("-c")
    flags+=("--output=")
    two_word_flags+=("-o")
    flags+=("--trace")
    flags+=("--verbose")
    flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_doctl()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __my_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("doctl")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local last_command
    local nouns=()

    __handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_doctl doctl
else
    complete -o default -o nospace -F __start_doctl doctl
fi

# ex: ts=4 sw=4 et filetype=sh
