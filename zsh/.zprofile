# Login shells only, sourced after /etc/zprofile.
#
# /etc/zprofile runs `path_helper`, which discards PATH ordering and rebuilds it
# with /etc/paths + /etc/paths.d entries first, then appends whatever was already
# there. That pushes the prepends from .zshenv below /usr/bin, so a login shell
# would resolve curl to Apple's 8.7.1 and python3 to 3.9.6.
#
# Re-running the builder restores precedence. Idempotent: `typeset -U path`
# keeps the leftmost copy, so no duplicates accumulate.
(( $+functions[dotfiles_path] )) && dotfiles_path
