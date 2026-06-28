{ lib, pkgs, ... }:

let
  generationLimit = 5;
in
{
  system.activationScripts.limineNixosGenerations.text = ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
    ]}:$PATH

    boot_dir=/boot
    conf="$boot_dir/limine.conf"
    managed_dir="$boot_dir/nixos-generations"
    begin_marker="# BEGIN NIXOS GENERATIONS (managed by NixOS)"
    end_marker="# END NIXOS GENERATIONS (managed by NixOS)"

    mkdir -p "$managed_dir"

    clean_name() {
      printf '%s\n' "$1" | sed 's|^/nix/store/||; s|/|-|g'
    }

    copy_boot_file() {
      src="$(readlink -f "$1")"
      dst="$managed_dir/$(clean_name "$src")"

      if [ ! -e "$dst" ]; then
        tmp="$dst.tmp.$$"
        cp -r "$src" "$tmp"
        mv "$tmp" "$dst"
      fi

      copied_files="$copied_files $dst"
      copied_result="$dst"
    }

    entries="$(mktemp)"
    tmp_conf="$boot_dir/.limine.conf.tmp.$$"
    trap 'rm -f "$entries" "$tmp_conf"' EXIT

    {
      printf '%s\n' "$begin_marker"
      printf '/+NixOS\n'
      printf 'comment: NixOS generations (managed by NixOS)\n'

      copied_files=
      for generation in $(
        (cd /nix/var/nix/profiles && ls -d system-*-link) \
          | sed 's/system-\([0-9]\+\)-link/\1/' \
          | sort -n -r \
          | head -n ${toString generationLimit}
      ); do
        profile="/nix/var/nix/profiles/system-$generation-link"

        if [ ! -e "$profile/kernel" ] || [ ! -e "$profile/initrd" ] || [ ! -e "$profile/init" ]; then
          continue
        fi

        copy_boot_file "$profile/kernel"
        kernel="$copied_result"

        copy_boot_file "$profile/initrd"
        initrd="$copied_result"

        timestamp="$(date '+%Y-%m-%d %H:%M' -d "@$(stat -L -c '%Z' "$profile")")"
        nixos_label="$(cat "$profile/nixos-version")"
        kernel_params="$(cat "$profile/kernel-params")"

        printf '  //Generation %s\n' "$generation"
        printf '  comment: %s - %s\n' "$timestamp" "$nixos_label"
        printf '  protocol: linux\n'
        printf '  path: boot():/nixos-generations/%s\n' "$(basename "$kernel")"
        printf '  module_path: boot():/nixos-generations/%s\n' "$(basename "$initrd")"
        printf '  cmdline: init=%s/init %s\n' "$profile" "$kernel_params"
      done

      printf '%s\n' "$end_marker"
    } > "$entries"

    for fn in "$managed_dir"/*; do
      [ -e "$fn" ] || continue
      case " $copied_files " in
        *" $fn "*) ;;
        *) rm -rf -- "$fn" ;;
      esac
    done

    if [ ! -e "$conf" ]; then
      cp "$entries" "$tmp_conf"
      mv -f "$tmp_conf" "$conf"
      exit 0
    fi

    begin_count="$(grep -xcF "$begin_marker" "$conf" || true)"
    end_count="$(grep -xcF "$end_marker" "$conf" || true)"

    if [ "$begin_count" -ne "$end_count" ] || [ "$begin_count" -gt 1 ]; then
      printf 'Refusing to update %s: inconsistent NixOS generations markers\n' "$conf" >&2
      exit 1
    fi

    cp "$conf" "$tmp_conf"

    if [ "$begin_count" -eq 1 ]; then
      awk -v begin="$begin_marker" -v end="$end_marker" -v entries="$entries" '
        $0 == begin {
          while ((getline line < entries) > 0) print line
          skip = 1
          next
        }
        $0 == end {
          skip = 0
          next
        }
        !skip { print }
      ' "$conf" > "$tmp_conf"
    else
      if [ ! -e "$conf.before-nixos-generations" ]; then
        cp "$conf" "$conf.before-nixos-generations"
      fi

      printf '\n' >> "$tmp_conf"
      cat "$entries" >> "$tmp_conf"
    fi

    mv -f "$tmp_conf" "$conf"
  '';
}
