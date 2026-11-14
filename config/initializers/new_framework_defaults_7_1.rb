# Keep AES-256-CBC for encrypted cookies and messages instead of the newer
# AES-256-GCM default. Switching rotates the cookie format and signs out every
# existing session.
Rails.application.config.action_dispatch.use_authenticated_cookie_encryption = false
Rails.application.config.active_support.use_authenticated_message_encryption = false
