module InboundWebhooks
  class ApplicationController < ::ApplicationController
    # skip_forgery_protection is used to disable CSRF (Cross-Site Request Forgery) protection for this controller.
    # The webhooks are typically sent by external services and do not include CSRF tokens
    # Disabling CSRF protection allows these external requests to be processed without requiring a CSRF token.
    skip_forgery_protection
    before_action :verify_request

    protected

    # Enforce request verification
    def verify_request
      head :forbidden unless verified_request?
    end

    # The HMAC header and payload are used to compute and compare signatures to verify the authenticity of the request.
    def verified_request?
      return false unless hmac_header

      ActiveSupport::SecurityUtils.secure_compare(computed_hmac, hmac_header)
    end

    def hmac_header
      raise NotImplementedError
    end

    def computed_hmac
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), signing_secret, webhook_payload.to_json)
      Base64.strict_encode64(digest)
    end

    def signing_secret
      raise NotImplementedError
    end

    def webhook_payload
      @webhook_payload ||= JSON.parse(request.body.read)
    end
  end
end
