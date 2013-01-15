require 'openssl'
require 'base64'

module Travis
  class Worker
    class Helpers
      module Crypt
        def decode(string)
          Base64.decode64(string)
        end

        def encode(string)
          Base64.encode64(string).gsub("\n", '').strip
        end

        def decrypt(string)
          # worker_key.private_decrypt(string)
          string
        end

        def worker_key
          @worker_key ||= OpenSSL::PKey::RSA.new(File.read(File.expand_path('~/.ssh/id_rsa.worker')))
        end
      end
    end
  end
end
