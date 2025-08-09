# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  protected

  def after_sign_in_path_for(_)
    root_path
  end

  def after_sign_out_path_for(_)
    root_path
  end
end
