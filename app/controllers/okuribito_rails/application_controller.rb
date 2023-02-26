module OkuribitoRails
  class ApplicationController < ActionController::Base
    protect_from_forgery

    before_action -> { head :forbidden }, if: -> { prohibited? }

    private

    def prohibited?
      OkuribitoRails.config.prohibit_webui.call
    end
  end
end
