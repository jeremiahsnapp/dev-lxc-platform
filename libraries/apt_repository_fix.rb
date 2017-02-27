# this monkey patch is in place until the following Chef Client bug gets fixed
# https://github.com/chef/chef/issues/5831

class Chef
  class Provider
    class AptRepository
      def extract_fingerprints_from_cmd(cmd)
        so = shell_out(cmd)
        so.run_command
        so.stdout.split(/\n/).map do |t|
          if z = t.match(/^fpr:+:([0-9A-F]+):/)
            z[1].split.join
          end
        end.compact
      end

      def no_new_keys?(file)
        installed_keys = extract_fingerprints_from_cmd('apt-key adv --list-public-keys --with-fingerprint --with-colons')
        proposed_keys = extract_fingerprints_from_cmd("gpg --with-fingerprint --with-colons #{file}")
        (installed_keys & proposed_keys).sort == proposed_keys.sort
      end
    end
  end
end
