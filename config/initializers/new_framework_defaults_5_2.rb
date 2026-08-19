# Rails 5.2 framework defaults that are deliberately deferred.
#
# config.load_defaults 5.2 in config/application.rb turns on the full 5.0-5.2
# default set. The two below are switched back off on purpose; each is a
# behavior change rather than a bug fix, and this upgrade is meant to preserve
# behavior. Revisit them once the ladder reaches Rails 8.

# Rails 5.2 switches encrypted cookies and messages from AES-256-CBC to
# AES-256-GCM. Two reasons to wait:
#
#   1. Flipping it rotates the cookie format, which signs out every existing
#      session on deploy. That is a product decision, not an upgrade step.
#   2. It is currently broken on Ruby 2.6 against modern OpenSSL, raising
#      "OpenSSL::Cipher::CipherError: couldn't set additional authenticated
#      data" on any request that touches the session. Rails 5.2 sets the
#      additional authenticated data before the key, which OpenSSL 3 rejects.
#
# Reason 2 disappears when Phase 4 moves us to Ruby 3.3; reason 1 does not.
Rails.application.config.action_dispatch.use_authenticated_cookie_encryption = false
Rails.application.config.active_support.use_authenticated_message_encryption = false
