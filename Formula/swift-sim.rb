class SwiftSim < Formula
  desc "Install iOS builds from mobile-controlled coding agents"
  homepage "https://github.com/Miguelosaurus/Swift-Sim"
  url "https://github.com/Miguelosaurus/Swift-Sim/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "69a33e79c898daa92f977f1772ea6f71f534dd57f50d05bb461c15b7b72ab4ed"
  license "Apache-2.0"

  depends_on "cloudflared"
  depends_on "node@22"

  def install
    libexec.install Dir["*"]
    libexec.install ".agents", ".claude-plugin", ".cursor-plugin"

    cd libexec do
      system Formula["node@22"].opt_bin/"npm", "install", "--omit=dev", "--ignore-scripts"
    end

    write_launcher "swift-sim", "mac-helper/bin/swift-sim.js"
    write_launcher "swift-sim-helper", "mac-helper/bin/swift-sim-helper.js"
  end

  service do
    run [Formula["node@22"].opt_bin/"node", opt_libexec/"mac-helper/bin/swift-sim-helper.js", "serve"]
    keep_alive true
    log_path var/"log/swift-sim.log"
    error_log_path var/"log/swift-sim.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/swift-sim version")
  end

  private

  def write_launcher(name, script)
    (bin/name).write <<~SH
      #!/bin/bash
      export PATH="#{Formula["node@22"].opt_bin}:#{Formula["cloudflared"].opt_bin}:$PATH"
      export SWIFT_SIM_MARKETPLACE_ROOT="#{opt_libexec}"
      exec "#{Formula["node@22"].opt_bin}/node" "#{libexec}/#{script}" "$@"
    SH
  end
end
