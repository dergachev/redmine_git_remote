# Ruby 1.8.7-compatible backport of Open3::capture3
#
# via https://gist.github.com/vasi/8ffc21bc09ac8fe38f76
module RedmineGitRemote
  module PoorMansCapture3

    def self.capture3(*cmd)
      # Force no shell expansion, by using a non-plain string. See ruby docs:
      #
      # `If the first argument is a two-element array, the first element is the
      # command to be executed, and the second argument is used as the argv[0]
      # value, which may show up in process listings.'
      cmd[0] = [cmd[0], cmd[0]]

      rout, wout = IO.pipe
      rerr, werr = IO.pipe

      pid = fork do
        rerr.close
        rout.close
        STDERR.reopen(werr)
        STDOUT.reopen(wout)
        exec(*cmd)
      end

      wout.close
      werr.close

      out = rout.read
      err = rerr.read
      Process.wait(pid)
      rout.close
      rerr.close
      return [out, err, $?]
    end

    def self.capture2(*cmd)
      out, err, stat = capture3(*cmd)
      STDERR.write err
      return out, stat
    end

    def self.test(*cmd)
      st, err, out = capture3(*cmd)
      p st
      p err
      p out
      puts
    end

    def self.run_tests
      test('ls', '/var')
      test('ls', '/foo')
      test('lfhlkhladfla')
      test('ls && ls')
    end
  end
end
